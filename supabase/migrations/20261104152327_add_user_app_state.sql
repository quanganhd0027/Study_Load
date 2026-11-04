CREATE TABLE IF NOT EXISTS public.user_app_state (
 user_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
 state jsonb NOT NULL DEFAULT '{}'::jsonb,
 updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.user_app_state ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read their own app state" ON public.user_app_state FOR SELECT TO authenticated USING ((SELECT auth.uid())=user_id);
CREATE POLICY "Users can create their own app state" ON public.user_app_state FOR INSERT TO authenticated WITH CHECK ((SELECT auth.uid())=user_id);
CREATE POLICY "Users can update their own app state" ON public.user_app_state FOR UPDATE TO authenticated USING ((SELECT auth.uid())=user_id) WITH CHECK ((SELECT auth.uid())=user_id);
GRANT SELECT,INSERT,UPDATE ON public.user_app_state TO authenticated;