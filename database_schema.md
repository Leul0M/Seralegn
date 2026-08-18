# Database Schema & Workflow Documentation

This document describes the database design, workflows, and core transaction mechanisms for the **Seralegn Platform**, a gig-economy marketplace connecting Homeowners and Workers.

---

## 1. Architectural Overview

To ensure separation of concerns, robust Row Level Security (RLS), and clean onboarding flows, the database uses three separate user tables referencing Supabase's `auth.users` rather than a single `profiles` table:
* **`home_owners`**: Simple homeowner profiles.
* **`workers`**: Contains worker verification data (Fayda National ID), monetization settings, status flags, and bans.
* **`admins`**: Administrator accounts for moderating the platform.

---

## 2. Platform Workflows

### A. Homeowner Workflow
1. **Registration**: Authenticates with Supabase Auth -> Inserts profile in `home_owners`.
2. **Posting a Job**: Inserts a row into `jobs` with `status = 'open'` and `worker_id = NULL`.
3. **Claim Notification**: Receives an event/notification when a worker claims the job.
4. **Completion**: Taps "Confirm Completion" once work is done -> Updates `jobs.status = 'completed'` and sets `completed_at = now()`.
5. **Flagging (Optional)**: If a worker exhibits misconduct, the homeowner can submit a row in `reports` containing the details.

### B. Worker Workflow
1. **Registration & Verification**:
   * Enters details + **Fayda Number** (Ethiopian National ID) -> Inserts profile in `workers` with `fayda_verified = false`.
   * On registration, a **30-day free trial** is activated (`trial_ends_at = now() + INTERVAL '30 days'`).
   * The worker **cannot claim jobs** until an admin reviews documents and updates `fayda_verified = true`.
2. **Subscription Management (Chapa Gateway)**:
   * When `trial_ends_at` is close to expiring, the worker pays through Chapa.
   * A ledger record is inserted in `subscriptions` with `status = 'pending'`.
   * On Chapa webhook confirmation, `status` changes to `'success'` and `subscription_expires_at` is extended by 30 days.
3. **Claiming Jobs (Race-Condition Protected)**:
   * Worker calls the RPC function `claim_job_securely`.
   * If successful, the job changes to `'claimed'` with the worker's ID and `claimed_at = now()`.
   * **Ghosting Timeout**: The worker must start the job. If they do not start it within 90 minutes, a cron script runs to release it.
4. **Job Execution**:
   * Workers tap "Start Job" -> Updates `jobs.status = 'in_progress'` and sets `started_at = now()`.
   * Worker taps "Complete Job" -> Updates `jobs.status = 'pending_confirmation'`.
   * Homeowner confirmation updates the status to `'completed'`.

### C. Admin Dashboard Workflow
1. **Fayda Verification**: Reviews profiles with `fayda_verified = false`, matches documents, and sets the flag to `true`.
2. **Moderation & Flags**:
   * Reviews homeowner-filed complaints in `reports`.
   * Applies strikes: increments `workers.flag_count`. If `flag_count >= 3`, toggles `is_suspended = true` to automatically revoke access.
3. **Monitoring Status**: Queries the `admin_worker_status` View to check days remaining for active subscriptions/trials.

---

## 3. Database Transaction & Automation Logic

### Double-Claim Prevention (RPC)
An atomic PostgreSQL function ensures that if two workers claim a job at the exact same millisecond, only the first transaction succeeds.
```sql
CREATE OR REPLACE FUNCTION claim_job_securely(p_job_id UUID, p_worker_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_updated BOOLEAN := false;
BEGIN
  UPDATE jobs 
  SET 
    worker_id = p_worker_id, 
    status = 'claimed', 
    claimed_at = now()
  WHERE 
    id = p_job_id 
    AND status = 'open' 
    AND worker_id IS NULL;
    
  IF FOUND THEN
    v_updated := true;
  END IF;
  
  RETURN v_updated;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Stale Job Release (pg_cron)
To prevent workers from hoarding or ghosting claimed jobs, a background process runs every 10 minutes to reset jobs to `open` if they remain in `claimed` state for > 90 minutes:
```sql
SELECT cron.schedule(
  'release-ghosted-jobs',
  '*/10 * * * *',
  $$
  UPDATE jobs 
  SET 
    worker_id = NULL, 
    status = 'open', 
    claimed_at = NULL 
  WHERE 
    status = 'claimed' 
    AND claimed_at < now() - INTERVAL '90 minutes';
  $$
);
```

---

## 4. PostgreSQL DDL Schema Script

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Enums
CREATE TYPE job_status AS ENUM (
  'open',
  'claimed',
  'in_progress',
  'pending_confirmation',
  'completed',
  'cancelled'
);

CREATE TYPE subscription_status AS ENUM (
  'pending',
  'success',
  'failed'
);

-- 2. User Profiles Tables
CREATE TABLE home_owners (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  phone_number TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE workers (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  phone_number TEXT UNIQUE NOT NULL,
  fayda_number TEXT UNIQUE NOT NULL,
  fayda_verified BOOLEAN DEFAULT false NOT NULL,
  trial_ends_at TIMESTAMPTZ DEFAULT (now() + INTERVAL '30 days') NOT NULL,
  subscription_expires_at TIMESTAMPTZ,
  flag_count INTEGER DEFAULT 0 NOT NULL,
  is_suspended BOOLEAN DEFAULT false NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE admins (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 3. Marketplace Tables
CREATE TABLE jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_owner_id UUID NOT NULL REFERENCES home_owners(id) ON DELETE CASCADE,
  worker_id UUID REFERENCES workers(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  photos TEXT[],
  offered_price NUMERIC NOT NULL CHECK (offered_price >= 0),
  status job_status DEFAULT 'open' NOT NULL,
  location_lat NUMERIC(9, 6),
  location_lng NUMERIC(9, 6),
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  claimed_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

-- 4. Moderation & Stripe System
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_owner_id UUID NOT NULL REFERENCES home_owners(id) ON DELETE CASCADE,
  worker_id UUID NOT NULL REFERENCES workers(id) ON DELETE CASCADE,
  job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  reviewed_by_admin UUID REFERENCES admins(id) ON DELETE SET NULL,
  resolution_notes TEXT,
  strike_applied BOOLEAN DEFAULT false NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 5. Payments Ledger
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  worker_id UUID NOT NULL REFERENCES workers(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL CHECK (amount > 0),
  chapa_tx_ref TEXT UNIQUE NOT NULL,
  status subscription_status DEFAULT 'pending' NOT NULL,
  chapa_response JSONB,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 6. Indexes
CREATE INDEX idx_jobs_home_owner ON jobs(home_owner_id);
CREATE INDEX idx_jobs_worker ON jobs(worker_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_reports_worker ON reports(worker_id);
CREATE INDEX idx_subscriptions_worker ON subscriptions(worker_id);
CREATE INDEX idx_subscriptions_tx_ref ON subscriptions(chapa_tx_ref);

-- 7. Views
CREATE OR REPLACE VIEW admin_worker_status AS
SELECT 
  id,
  full_name,
  phone_number,
  fayda_number,
  fayda_verified,
  flag_count,
  is_suspended,
  GREATEST(
    COALESCE(EXTRACT(DAY FROM (trial_ends_at - now())), 0),
    COALESCE(EXTRACT(DAY FROM (subscription_expires_at - now())), 0)
  )::INT AS days_left
FROM workers;
```
