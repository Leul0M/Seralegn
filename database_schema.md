# Database Schema & Workflow Documentation

This document describes the database design, workflows, and core transaction mechanisms for the **Seralegn Platform**, a gig-economy marketplace connecting Clients and Workers.

---

## 1. Architectural Overview

To ensure separation of concerns, robust Row Level Security (RLS), and clean onboarding flows, the database uses three separate user tables referencing Supabase's `auth.users`:
* **`clients`**: Client user profiles.
* **`workers`**: Contains worker verification data (Fayda National ID), monetization settings, status flags, and bans.
* **`admins`**: Administrator accounts for moderating the platform.

---

## 2. Platform Workflows

### A. Client Workflow
1. **Registration**: Authenticates with Supabase Auth -> Inserts profile in `clients`.
2. **Posting a Job**: Inserts a row into `jobs` with `status = 'open'`, `is_completed = false`, and `worker_id = NULL`.
3. **Claim Notification**: Receives an event/notification when a worker claims the job.
4. **Approval & Completion**: Once the worker completes the task (`status = 'pending_confirmation'`), the client taps "Approve Work" -> Calls `approve_job_completion(p_job_id, p_client_id)` RPC which sets `is_completed = true`, `jobs.status = 'completed'`, and `completed_at = now()`.
5. **Flagging (Optional)**: If a worker exhibits misconduct, the client can submit a row in `reports` containing the details.

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
   * Worker calls the RPC function `claim_job_securely(p_job_id, p_worker_id)`.
   * If successful, the job changes to `'claimed'` with the worker's ID and `claimed_at = now()`.
   * **Ghosting Timeout**: The worker must start the job within 90 minutes; otherwise, a cron script releases it.
4. **Job Execution**:
   * Workers tap "Start Job" -> Updates `jobs.status = 'in_progress'` and sets `started_at = now()`.
   * Worker taps "Finish Work" -> Updates `jobs.status = 'pending_confirmation'`. `is_completed` remains `false`.
   * Worker waits for client approval. Client approval sets `is_completed = true` and `status = 'completed'`.

### C. Admin Dashboard Workflow
1. **Fayda Verification**: Reviews profiles with `fayda_verified = false`, matches documents, and sets the flag to `true`.
2. **Moderation & Flags**:
   * Reviews client-filed complaints in `reports`.
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
  IF auth.uid() IS NOT NULL AND auth.uid() <> p_worker_id THEN
    RAISE EXCEPTION 'Unauthorized claim: worker ID mismatch.';
  END IF;

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

### Client Approval RPC
```sql
CREATE OR REPLACE FUNCTION approve_job_completion(p_job_id UUID, p_client_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_updated BOOLEAN := false;
BEGIN
  IF auth.uid() IS NOT NULL AND auth.uid() <> p_client_id THEN
    RAISE EXCEPTION 'Unauthorized approval: client ID mismatch.';
  END IF;

  UPDATE jobs
  SET 
    is_completed = true,
    status = 'completed',
    completed_at = now()
  WHERE 
    id = p_job_id 
    AND client_id = p_client_id
    AND status = 'pending_confirmation';

  IF FOUND THEN
    v_updated := true;
  END IF;

  RETURN v_updated;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 4. PostgreSQL DDL Schema Summary

- **`clients`**: `id` (UUID, PK, FK to auth.users), `full_name`, `phone_number`, `password_hash`, `created_at`
- **`workers`**: `id` (UUID, PK, FK to auth.users), `full_name`, `phone_number`, `password_hash`, `fayda_number`, `fayda_verified`, `trial_ends_at`, `subscription_expires_at`, `flag_count`, `is_suspended`, `created_at`
- **`admins`**: `id` (UUID, PK, FK to auth.users), `full_name`, `email`, `password_hash`, `created_at`
- **`jobs`**: `id`, `client_id`, `worker_id`, `title`, `category`, `description`, `photos`, `offered_price`, `status`, `is_completed`, `neighborhood`, `address_detail`, `client_name`, `client_phone`, `location_lat`, `location_lng`, `created_at`, `claimed_at`, `started_at`, `completed_at`
- **`bookings`**: `id`, `client_id`, `worker_id`, `client_name`, `client_phone`, `worker_name`, `worker_phone`, `category`, `booking_date`, `time_slot`, `address`, `notes`, `status`, `created_at`
- **`reports`**: `id`, `client_id`, `worker_id`, `job_id`, `reason`, `reviewed_by_admin`, `resolution_notes`, `strike_applied`, `created_at`
- **`subscriptions`**: `id`, `worker_id`, `amount`, `chapa_tx_ref`, `status`, `chapa_response`, `created_at`
```
