CREATE OR REPLACE FUNCTION public.lookup_worker_by_phone(p_phone text)
RETURNS TABLE (id uuid, full_name text, phone_number text)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT w.id, w.full_name, w.phone_number
  FROM public.workers AS w
  WHERE auth.uid() IS NOT NULL
    AND pg_catalog.regexp_replace(w.phone_number, '[^0-9]', '', 'g')
      = pg_catalog.regexp_replace(COALESCE(p_phone, ''), '[^0-9]', '', 'g')
  LIMIT 1;
$$;

REVOKE ALL ON FUNCTION public.lookup_worker_by_phone(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.lookup_worker_by_phone(text) FROM anon;
GRANT EXECUTE ON FUNCTION public.lookup_worker_by_phone(text) TO authenticated;
