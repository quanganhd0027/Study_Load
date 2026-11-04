DO $$
DECLARE f record;
BEGIN
 FOR f IN SELECT p.oid::regprocedure AS signature FROM pg_proc p
 JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_type t ON t.oid=p.prorettype
 WHERE n.nspname='public' AND p.prosecdef AND t.typname IN ('trigger','event_trigger')
 LOOP EXECUTE format('REVOKE EXECUTE ON FUNCTION %s FROM PUBLIC, anon, authenticated',f.signature); END LOOP;
END; $$;