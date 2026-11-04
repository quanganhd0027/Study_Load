REVOKE ALL PRIVILEGES ON TABLE public.user_app_state FROM anon,authenticated,PUBLIC;
GRANT SELECT,INSERT,UPDATE ON TABLE public.user_app_state TO authenticated;