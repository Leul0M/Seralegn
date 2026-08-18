-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- 1. ENUMS
-- =============================================================================

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

-- =============================================================================
-- 2. USER PROFILES TABLES
-- =============================================================================

CREATE TABLE clients (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  phone_number TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE workers (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  phone_number TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
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
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- =============================================================================
-- 3. MARKETPLACE TABLES
-- =============================================================================

CREATE TABLE jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
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

-- =============================================================================
-- 4. MODERATION & REPORTS SYSTEM
-- =============================================================================

CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  worker_id UUID NOT NULL REFERENCES workers(id) ON DELETE CASCADE,
  job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  reviewed_by_admin UUID REFERENCES admins(id) ON DELETE SET NULL,
  resolution_notes TEXT,
  strike_applied BOOLEAN DEFAULT false NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- =============================================================================
-- 5. PAYMENTS LEDGER (SUBSCRIPTIONS)
-- =============================================================================

CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  worker_id UUID NOT NULL REFERENCES workers(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL CHECK (amount > 0),
  chapa_tx_ref TEXT UNIQUE NOT NULL,
  status subscription_status DEFAULT 'pending' NOT NULL,
  chapa_response JSONB,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- =============================================================================
-- 6. INDEXES
-- =============================================================================

CREATE INDEX idx_jobs_client ON jobs(client_id);
CREATE INDEX idx_jobs_worker ON jobs(worker_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_reports_worker ON reports(worker_id);
CREATE INDEX idx_subscriptions_worker ON subscriptions(worker_id);
CREATE INDEX idx_subscriptions_tx_ref ON subscriptions(chapa_tx_ref);

-- =============================================================================
-- 7. VIEWS
-- =============================================================================

-- SECURITY INVOKER ensures this view respects the RLS policies
-- of the querying user, not the view creator (superuser).
CREATE OR REPLACE VIEW admin_worker_status
  WITH (security_invoker = true)
AS
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

-- =============================================================================
-- 8. TRANSACTION LOGIC / FUNCTIONS
-- =============================================================================

-- Double-Claim Prevention (Atomic Claim Job RPC)
-- SECURITY DEFINER is intentional here so the UPDATE can bypass RLS on the jobs table.
-- search_path is pinned to `public` to prevent search_path hijacking attacks.
-- anon role is explicitly revoked so only authenticated workers can call this.
CREATE OR REPLACE FUNCTION claim_job_securely(p_job_id UUID, p_worker_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
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
$$;

-- Revoke execute from unauthenticated users
REVOKE EXECUTE ON FUNCTION claim_job_securely(UUID, UUID) FROM anon;

-- =============================================================================
-- 9. AUTOMATION LOGIC (CRON SCHEDULES)
-- =============================================================================

-- Stale Job Release (pg_cron)
-- Runs every 10 minutes to release claimed jobs that have not started within 90 minutes.
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

-- =============================================================================
-- 10. ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================

-- clients: each user can only access their own profile row
CREATE POLICY "clients: own row select" ON clients FOR SELECT USING (auth.uid() = id);
CREATE POLICY "clients: own row update" ON clients FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "clients: insert own row" ON clients FOR INSERT WITH CHECK (auth.uid() = id);

-- workers: each worker can only access their own profile row
CREATE POLICY "workers: own row select" ON workers FOR SELECT USING (auth.uid() = id);
CREATE POLICY "workers: own row update" ON workers FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "workers: insert own row" ON workers FOR INSERT WITH CHECK (auth.uid() = id);

-- admins: each admin can only access their own profile row
CREATE POLICY "admins: own row select" ON admins FOR SELECT USING (auth.uid() = id);
CREATE POLICY "admins: own row update" ON admins FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "admins: insert own row" ON admins FOR INSERT WITH CHECK (auth.uid() = id);

-- jobs: clients manage their own jobs; workers can see open jobs and their assigned jobs
CREATE POLICY "jobs: client can manage own jobs" ON jobs FOR ALL USING (auth.uid() = client_id);
CREATE POLICY "jobs: workers can view open jobs" ON jobs FOR SELECT
  USING (status = 'open' OR auth.uid() = worker_id);

-- reports: clients can create and view their own reports
CREATE POLICY "reports: client can insert" ON reports FOR INSERT WITH CHECK (auth.uid() = client_id);
CREATE POLICY "reports: client can view own reports" ON reports FOR SELECT USING (auth.uid() = client_id);

-- subscriptions: workers can view and insert their own subscription records
CREATE POLICY "subscriptions: worker can view own" ON subscriptions FOR SELECT USING (auth.uid() = worker_id);
CREATE POLICY "subscriptions: worker can insert own" ON subscriptions FOR INSERT WITH CHECK (auth.uid() = worker_id);
