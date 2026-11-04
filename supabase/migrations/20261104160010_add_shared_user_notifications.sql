CREATE TABLE IF NOT EXISTS public.user_notifications (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
 actor_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,title text NOT NULL CHECK(length(trim(title))>0),
 body text NOT NULL DEFAULT '',notification_type text NOT NULL DEFAULT 'activity',target_id text NULL,
 read_at timestamptz NULL,created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS user_notifications_inbox_idx ON public.user_notifications(user_id,created_at DESC);
ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.user_notifications FROM anon,PUBLIC;
GRANT SELECT,INSERT ON public.user_notifications TO authenticated;
GRANT UPDATE(read_at) ON public.user_notifications TO authenticated;
CREATE POLICY user_notifications_select_own ON public.user_notifications FOR SELECT TO authenticated USING(public.is_active_user() AND user_id=auth.uid());
CREATE POLICY user_notifications_insert_related ON public.user_notifications FOR INSERT TO authenticated WITH CHECK(public.is_active_user() AND actor_id=auth.uid() AND user_id<>auth.uid() AND (
 EXISTS(SELECT 1 FROM public.class_members a JOIN public.class_members b ON b.class_id=a.class_id WHERE a.student_id=auth.uid() AND b.student_id=user_notifications.user_id AND (public.is_admin() OR public.has_class_officer_role(a.class_id,'class_president') OR public.has_class_officer_role(a.class_id,'academic_vp') OR public.has_class_officer_role(a.class_id,'labor_vp')))
 OR EXISTS(SELECT 1 FROM public.project_members a JOIN public.project_members b ON b.project_id=a.project_id WHERE a.user_id=auth.uid() AND b.user_id=user_notifications.user_id)
 OR EXISTS(SELECT 1 FROM public.class_team_members a JOIN public.class_team_members b ON b.team_id=a.team_id WHERE a.student_id=auth.uid() AND b.student_id=user_notifications.user_id AND a.left_at IS NULL AND b.left_at IS NULL)
));
CREATE POLICY user_notifications_update_read_own ON public.user_notifications FOR UPDATE TO authenticated USING(public.is_active_user() AND user_id=auth.uid()) WITH CHECK(public.is_active_user() AND user_id=auth.uid());