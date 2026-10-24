BEGIN;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_catalog.pg_constraint
    WHERE conrelid = 'public.jobs'::regclass
      AND conname = 'jobs_client_id_fkey'
      AND (
        contype <> 'f'
        OR confrelid <> 'public.clients'::regclass
        OR conkey <> ARRAY[
          (SELECT attnum::smallint
           FROM pg_catalog.pg_attribute
           WHERE attrelid = 'public.jobs'::regclass
             AND attname = 'client_id'
             AND NOT attisdropped)
        ]
        OR confkey <> ARRAY[
          (SELECT attnum::smallint
           FROM pg_catalog.pg_attribute
           WHERE attrelid = 'public.clients'::regclass
             AND attname = 'id'
             AND NOT attisdropped)
        ]
      )
  ) THEN
    RAISE EXCEPTION 'Constraint jobs_client_id_fkey exists but does not reference clients.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_catalog.pg_constraint
    WHERE conrelid = 'public.jobs'::regclass
      AND conname = 'jobs_client_id_fkey'
      AND contype = 'f'
      AND confrelid = 'public.clients'::regclass
      AND conkey = ARRAY[
        (SELECT attnum::smallint
         FROM pg_catalog.pg_attribute
         WHERE attrelid = 'public.jobs'::regclass
           AND attname = 'client_id'
           AND NOT attisdropped)
      ]
      AND confkey = ARRAY[
        (SELECT attnum::smallint
         FROM pg_catalog.pg_attribute
         WHERE attrelid = 'public.clients'::regclass
           AND attname = 'id'
           AND NOT attisdropped)
      ]
  ) THEN
    ALTER TABLE public.jobs
      ADD CONSTRAINT jobs_client_id_fkey
      FOREIGN KEY (client_id)
      REFERENCES public.clients (id)
      ON DELETE CASCADE
      NOT VALID;
  END IF;
END;
$$;

DROP POLICY IF EXISTS "clients: approved admins can view" ON public.clients;
CREATE POLICY "clients: approved admins can view" ON public.clients FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.admins
    WHERE admins.id = auth.uid() AND admins.is_approved
  ));

DROP POLICY IF EXISTS "workers: approved admins can view" ON public.workers;
CREATE POLICY "workers: approved admins can view" ON public.workers FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.admins
    WHERE admins.id = auth.uid() AND admins.is_approved
  ));

DROP POLICY IF EXISTS "jobs: approved admins can view" ON public.jobs;
CREATE POLICY "jobs: approved admins can view" ON public.jobs FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.admins
    WHERE admins.id = auth.uid() AND admins.is_approved
  ));

COMMIT;
