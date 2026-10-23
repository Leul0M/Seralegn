BEGIN;

ALTER TABLE public.clients
  ADD COLUMN IF NOT EXISTS fayda_qr_hash TEXT;

ALTER TABLE public.clients
  ADD COLUMN IF NOT EXISTS fayda_verified BOOLEAN DEFAULT false;

ALTER TABLE public.workers
  ADD COLUMN IF NOT EXISTS fayda_qr_hash TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS clients_fayda_qr_hash_key
  ON public.clients (fayda_qr_hash);

CREATE UNIQUE INDEX IF NOT EXISTS workers_fayda_qr_hash_key
  ON public.workers (fayda_qr_hash);

ALTER TABLE public.clients
  ADD CONSTRAINT clients_fayda_qr_hash_format_check
  CHECK (
    fayda_qr_hash IS NULL
    OR fayda_qr_hash ~ '^[0-9a-f]{64}$'
  );

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_catalog.pg_constraint
    WHERE conname = 'workers_fayda_qr_hash_format_check'
      AND conrelid = 'public.workers'::regclass
  ) THEN
    ALTER TABLE public.workers
      ADD CONSTRAINT workers_fayda_qr_hash_format_check
      CHECK (
        fayda_qr_hash IS NULL
        OR fayda_qr_hash ~ '^[0-9a-f]{64}$'
      );
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.enforce_global_fayda_identity()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF NEW.fayda_qr_hash IS NULL THEN
    RETURN NEW;
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.clients c
    WHERE c.fayda_qr_hash = NEW.fayda_qr_hash
      AND c.id <> NEW.id
  ) OR EXISTS (
    SELECT 1 FROM public.workers w
    WHERE w.fayda_qr_hash = NEW.fayda_qr_hash
      AND w.id <> NEW.id
  ) THEN
    RAISE EXCEPTION 'This Fayda identity is already linked to another account.';
  END IF;

  IF NEW.fayda_verified AND NEW.fayda_qr_hash IS NULL THEN
    RAISE EXCEPTION 'A Fayda QR scan is required before verifying an account.';
  END IF;

  IF TG_OP = 'UPDATE' AND OLD.fayda_qr_hash IS NOT NULL
     AND NEW.fayda_qr_hash IS DISTINCT FROM OLD.fayda_qr_hash THEN
    RAISE EXCEPTION 'The Fayda QR identity cannot be changed after registration.';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_client_fayda_identity ON public.clients;
DROP TRIGGER IF EXISTS enforce_worker_fayda_identity ON public.workers;

CREATE TRIGGER enforce_client_fayda_identity
BEFORE INSERT OR UPDATE ON public.clients
FOR EACH ROW
EXECUTE FUNCTION public.enforce_global_fayda_identity();

CREATE TRIGGER enforce_worker_fayda_identity
BEFORE INSERT OR UPDATE ON public.workers
FOR EACH ROW
EXECUTE FUNCTION public.enforce_global_fayda_identity();

DROP VIEW IF EXISTS public.admin_worker_status;

DROP FUNCTION IF EXISTS public.admin_create_user(text, text, text, text, text, text);
DROP FUNCTION IF EXISTS public.admin_create_user(text, text, text, text, text);

ALTER TABLE public.workers
  DROP COLUMN IF EXISTS fayda_number;

CREATE VIEW public.admin_worker_status
  WITH (security_invoker = true)
AS
SELECT
  id,
  full_name,
  phone_number,
  fayda_verified,
  flag_count,
  is_suspended,
  GREATEST(
    COALESCE(EXTRACT(DAY FROM (trial_ends_at - now())), 0),
    COALESCE(EXTRACT(DAY FROM (subscription_expires_at - now())), 0)
  )::INT AS days_left
FROM public.workers;

GRANT SELECT ON public.admin_worker_status TO authenticated;

CREATE OR REPLACE FUNCTION public.create_app_profile_for_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_role text := NEW.raw_user_meta_data ->> 'role';
  v_phone text := NEW.raw_user_meta_data ->> 'phone_number';
  v_qr_hash text := NULLIF(NEW.raw_user_meta_data ->> 'fayda_qr_hash', '');
  v_full_name text := COALESCE(NEW.raw_user_meta_data ->> 'full_name', 'User');
BEGIN
  IF v_role = 'client' THEN
    IF v_qr_hash IS NULL OR v_qr_hash !~ '^[0-9a-f]{64}$' THEN
      RAISE EXCEPTION 'A valid Fayda QR scan is required to create a client account.';
    END IF;

    INSERT INTO public.clients (
      id,
      full_name,
      phone_number,
      fayda_qr_hash,
      fayda_verified
    )
    VALUES (
      NEW.id,
      v_full_name,
      v_phone,
      v_qr_hash,
      COALESCE(
        (NEW.raw_user_meta_data ->> 'fayda_verified')::boolean,
        false
      )
    );
  ELSIF v_role = 'worker' THEN
    IF v_qr_hash IS NULL OR v_qr_hash !~ '^[0-9a-f]{64}$' THEN
      RAISE EXCEPTION 'A valid Fayda QR scan is required to create a worker account.';
    END IF;

    INSERT INTO public.workers (
      id,
      full_name,
      phone_number,
      fayda_qr_hash,
      fayda_verified
    )
    VALUES (
      NEW.id,
      v_full_name,
      v_phone,
      v_qr_hash,
      COALESCE(
        (NEW.raw_user_meta_data ->> 'fayda_verified')::boolean,
        false
      )
    );
  END IF;

  RETURN NEW;
END;
$$;

CREATE FUNCTION public.admin_create_user(
  email TEXT,
  password TEXT,
  full_name TEXT,
  phone_number TEXT,
  user_role TEXT
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
  ELSE
    RAISE EXCEPTION 'Worker accounts must be created through the Fayda QR signup flow.';
  END IF;

  RETURN v_new_id;
END;
$$;

COMMIT;
