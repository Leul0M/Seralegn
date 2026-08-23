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
  password_hash TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE workers (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  phone_number TEXT UNIQUE NOT NULL,
  password_hash TEXT DEFAULT '',
  fayda_number TEXT UNIQUE,
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
  password_hash TEXT DEFAULT '',
  is_approved BOOLEAN DEFAULT false NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- =============================================================================
-- 3. MARKETPLACE & BOOKING TABLES
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
  is_completed BOOLEAN DEFAULT false NOT NULL,
  neighborhood TEXT DEFAULT '',
  address_detail TEXT DEFAULT '',
  client_name TEXT DEFAULT '',
  client_phone TEXT DEFAULT '',
  location_lat NUMERIC(9, 6),
  location_lng NUMERIC(9, 6),
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  claimed_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  worker_id UUID REFERENCES workers(id) ON DELETE SET NULL,
  client_name TEXT NOT NULL,
  client_phone TEXT NOT NULL,
  worker_name TEXT NOT NULL,
  worker_phone TEXT NOT NULL,
  category TEXT NOT NULL,
  booking_date TIMESTAMPTZ NOT NULL,
  time_slot TEXT NOT NULL,
  address TEXT NOT NULL,
  notes TEXT,
  status TEXT DEFAULT 'pending' NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
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
CREATE INDEX idx_jobs_is_completed ON jobs(is_completed);
CREATE INDEX idx_bookings_client ON bookings(client_id);
CREATE INDEX idx_bookings_worker ON bookings(worker_id);
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
-- 8. TRANSACTION LOGIC / RPC FUNCTIONS
-- =============================================================================

-- Double-Claim Prevention (Atomic Claim Job RPC)
-- SECURITY DEFINER is intentional here so the UPDATE can bypass RLS on the jobs table.
-- search_path is pinned to `public` to prevent search_path hijacking attacks.
-- Verifies caller identity matches p_worker_id or is authenticated user.
CREATE OR REPLACE FUNCTION claim_job_securely(p_job_id UUID, p_worker_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_updated BOOLEAN := false;
BEGIN
  -- Ensure calling user is authenticated and matches p_worker_id
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
$$;

-- Revoke execute from unauthenticated users
REVOKE EXECUTE ON FUNCTION claim_job_securely(UUID, UUID) FROM anon;

-- Client Job Completion Approval RPC
-- Client calls this function to approve completed work.
-- Sets is_completed to TRUE and updates status to 'completed'.
CREATE OR REPLACE FUNCTION approve_job_completion(p_job_id UUID, p_client_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
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
$$;

REVOKE EXECUTE ON FUNCTION approve_job_completion(UUID, UUID) FROM anon;

-- Admin Approval RPC
-- SECURITY DEFINER allows an approved admin to bypass RLS to update another admin's record
CREATE OR REPLACE FUNCTION admin_approve_admin(p_admin_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_approved BOOLEAN;
  v_updated BOOLEAN := false;
BEGIN
  -- Check if the caller is an approved admin
  SELECT is_approved INTO v_caller_approved FROM admins WHERE id = auth.uid();
  
  IF v_caller_approved = true THEN
    UPDATE admins SET is_approved = true WHERE id = p_admin_id;
    IF FOUND THEN
      v_updated := true;
    END IF;
  END IF;
  
  RETURN v_updated;
END;
$$;
REVOKE EXECUTE ON FUNCTION admin_approve_admin(UUID) FROM anon;

-- Admin Get Admins RPC
-- SECURITY DEFINER allows an approved admin to view all admins
CREATE OR REPLACE FUNCTION admin_get_admins()
RETURNS TABLE (
  id UUID,
  full_name TEXT,
  is_approved BOOLEAN,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_approved BOOLEAN;
BEGIN
  -- Check if the caller is an approved admin
  SELECT a.is_approved INTO v_caller_approved FROM admins a WHERE a.id = auth.uid();
  
  IF v_caller_approved = true THEN
    RETURN QUERY SELECT a.id, a.full_name, a.is_approved, a.created_at FROM admins a ORDER BY a.created_at DESC;
  ELSE
    -- Return nothing if caller is not an approved admin
    RETURN;
  END IF;
END;
$$;
REVOKE EXECUTE ON FUNCTION admin_get_admins() FROM anon;

-- =============================================================================
-- 9. ADMIN RPC FUNCTIONS (Used by Web Admin Panel)
-- =============================================================================

CREATE OR REPLACE FUNCTION admin_create_user(
  email TEXT,
  password TEXT,
  full_name TEXT,
  phone_number TEXT,
  user_role TEXT,
  fayda_number TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_new_id UUID := gen_random_uuid();
BEGIN
  IF user_role = 'client' THEN
    INSERT INTO clients (id, full_name, phone_number, password_hash)
    VALUES (v_new_id, full_name, phone_number, password);
  ELSIF user_role = 'worker' THEN
    INSERT INTO workers (id, full_name, phone_number, fayda_number, fayda_verified, password_hash)
    VALUES (v_new_id, full_name, phone_number, fayda_number, false, password);
  ELSE
    RAISE EXCEPTION 'Invalid user role specified';
  END IF;

  RETURN v_new_id;
END;
$$;

CREATE OR REPLACE FUNCTION admin_delete_user(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM clients WHERE id = p_user_id;
  DELETE FROM workers WHERE id = p_user_id;
  RETURN true;
END;
$$;

CREATE OR REPLACE FUNCTION admin_create_job(
  p_client_id UUID,
  p_title TEXT,
  p_category TEXT,
  p_description TEXT,
  p_offered_price NUMERIC
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_job_id UUID;
BEGIN
  INSERT INTO jobs (client_id, title, category, description, offered_price, status, is_completed)
  VALUES (p_client_id, p_title, p_category, p_description, p_offered_price, 'open', false)
  RETURNING id INTO v_job_id;

  RETURN v_job_id;
END;
$$;

CREATE OR REPLACE FUNCTION admin_delete_job(p_job_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM jobs WHERE id = p_job_id;
  RETURN true;
END;
$$;

-- =============================================================================
-- 10. AUTOMATION LOGIC (CRON SCHEDULES)
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
-- 11. ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================

-- Explicitly enable RLS on every table
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

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
CREATE POLICY "jobs: workers can update assigned jobs" ON jobs FOR UPDATE
  USING (auth.uid() = worker_id);

-- bookings: clients & assigned workers can view/manage bookings
CREATE POLICY "bookings: client can manage own" ON bookings FOR ALL USING (auth.uid() = client_id);
CREATE POLICY "bookings: worker can view assigned" ON bookings FOR SELECT USING (auth.uid() = worker_id);
CREATE POLICY "bookings: worker can update assigned" ON bookings FOR UPDATE USING (auth.uid() = worker_id);

-- reports: clients can create and view their own reports
CREATE POLICY "reports: client can insert" ON reports FOR INSERT WITH CHECK (auth.uid() = client_id);
CREATE POLICY "reports: client can view own reports" ON reports FOR SELECT USING (auth.uid() = client_id);

-- subscriptions: workers can view and insert their own subscription records
CREATE POLICY "subscriptions: worker can view own" ON subscriptions FOR SELECT USING (auth.uid() = worker_id);
CREATE POLICY "subscriptions: worker can insert own" ON subscriptions FOR INSERT WITH CHECK (auth.uid() = worker_id);

-- =============================================================================
-- 12. ADMIN AUTHENTICATION RPC FUNCTIONS
-- =============================================================================

CREATE OR REPLACE FUNCTION signup_admin(
  p_full_name TEXT,
  p_email TEXT,
  p_password TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
  v_existing UUID;
  v_new_id UUID;
  v_admin RECORD;
  v_encrypted_pw TEXT;
BEGIN
  -- Check if admin already exists in public.admins
  SELECT id INTO v_existing FROM public.admins WHERE LOWER(email) = LOWER(p_email);
  IF v_existing IS NOT NULL THEN
    RETURN json_build_object('success', false, 'message', 'An account with this email already exists.');
  END IF;

  -- Check if user already exists in auth.users
  SELECT id INTO v_existing FROM auth.users WHERE LOWER(email) = LOWER(p_email);

  IF v_existing IS NOT NULL THEN
    v_new_id := v_existing;
  ELSE
    v_new_id := gen_random_uuid();
    v_encrypted_pw := extensions.crypt(p_password, extensions.gen_salt('bf'));

    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000'::uuid,
      v_new_id,
      'authenticated',
      'authenticated',
      p_email,
      v_encrypted_pw,
      now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('name', p_full_name, 'role', 'admin'),
      now(),
      now()
    );
  END IF;

  -- Insert into public.admins referencing the auth.users ID
  INSERT INTO public.admins (id, full_name, email, password_hash, is_approved, created_at)
  VALUES (v_new_id, p_full_name, p_email, p_password, false, now())
  RETURNING * INTO v_admin;

  RETURN json_build_object(
    'success', true, 
    'user', json_build_object(
      'id', v_admin.id,
      'email', v_admin.email,
      'name', v_admin.full_name,
      'full_name', v_admin.full_name,
      'role', 'admin',
      'is_approved', false
    )
  );
END;
$$;

CREATE OR REPLACE FUNCTION login_admin(
  p_email TEXT,
  p_password TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
  v_admin RECORD;
BEGIN
  SELECT id, full_name, email, password_hash, is_approved
  INTO v_admin
  FROM public.admins
  WHERE LOWER(email) = LOWER(p_email);

  IF v_admin IS NULL THEN
    RETURN json_build_object('success', false, 'message', 'Invalid email or password.');
  END IF;

  IF v_admin.password_hash <> p_password AND v_admin.password_hash <> 'managed_by_supabase' THEN
    RETURN json_build_object('success', false, 'message', 'Invalid email or password.');
  END IF;

  RETURN json_build_object(
    'success', true,
    'user', json_build_object(
      'id', v_admin.id,
      'email', v_admin.email,
      'name', v_admin.full_name,
      'full_name', v_admin.full_name,
      'role', 'admin',
      'is_approved', v_admin.is_approved
    ),
    'isAdmin', true,
    'isApproved', v_admin.is_approved
  );
END;
$$;


