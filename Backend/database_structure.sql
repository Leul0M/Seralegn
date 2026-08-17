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
