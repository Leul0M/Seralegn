CREATE OR REPLACE FUNCTION public.create_app_profile_for_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_role text := NEW.raw_user_meta_data ->> 'role';
  v_phone text := NEW.raw_user_meta_data ->> 'phone_number';
  v_full_name text := COALESCE(NEW.raw_user_meta_data ->> 'full_name', 'User');
BEGIN
  IF v_role = 'client' THEN
    INSERT INTO public.clients (id, full_name, phone_number)
    VALUES (NEW.id, v_full_name, v_phone);
  ELSIF v_role = 'worker' THEN
    INSERT INTO public.workers (
      id,
      full_name,
      phone_number,
      fayda_number,
      fayda_verified
    )
    VALUES (
      NEW.id,
      v_full_name,
      v_phone,
      NULLIF(NULLIF(NEW.raw_user_meta_data ->> 'fayda_number', ''), 'N/A'),
      COALESCE(
        (NEW.raw_user_meta_data ->> 'fayda_verified')::boolean,
        false
      )
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS create_app_profile_after_auth_signup ON auth.users;

CREATE TRIGGER create_app_profile_after_auth_signup
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.create_app_profile_for_auth_user();
