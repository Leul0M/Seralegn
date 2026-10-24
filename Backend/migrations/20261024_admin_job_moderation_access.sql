BEGIN;

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
