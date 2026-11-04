DROP POLICY IF EXISTS user_notifications_insert_related ON public.user_notifications;
CREATE POLICY user_notifications_insert_related ON public.user_notifications FOR INSERT TO authenticated
WITH CHECK(public.is_active_user() AND actor_id=(SELECT auth.uid()) AND user_id<>(SELECT auth.uid()) AND (
 (public.is_admin() AND EXISTS(SELECT 1 FROM public.class_members cm WHERE cm.student_id=user_notifications.user_id))
 OR EXISTS(SELECT 1 FROM public.class_members a JOIN public.class_members b ON b.class_id=a.class_id WHERE a.student_id=(SELECT auth.uid()) AND b.student_id=user_notifications.user_id AND (public.has_class_officer_role(a.class_id,'class_president') OR public.has_class_officer_role(a.class_id,'academic_vp') OR public.has_class_officer_role(a.class_id,'labor_vp')))
 OR EXISTS(SELECT 1 FROM public.class_homeroom_teachers ht JOIN public.class_members cm ON cm.class_id=ht.class_id WHERE ht.teacher_id=(SELECT auth.uid()) AND ht.ended_at IS NULL AND cm.student_id=user_notifications.user_id)
 OR EXISTS(SELECT 1 FROM public.class_subject_teachers st JOIN public.class_members cm ON cm.class_id=st.class_id WHERE st.teacher_id=(SELECT auth.uid()) AND cm.student_id=user_notifications.user_id)
 OR EXISTS(SELECT 1 FROM public.projects p JOIN public.project_members pm ON pm.project_id=p.id WHERE p.created_by=(SELECT auth.uid()) AND pm.user_id=user_notifications.user_id)
 OR EXISTS(SELECT 1 FROM public.project_members a JOIN public.project_members b ON b.project_id=a.project_id WHERE a.user_id=(SELECT auth.uid()) AND b.user_id=user_notifications.user_id)
 OR EXISTS(SELECT 1 FROM public.project_members pm JOIN public.projects p ON p.id=pm.project_id WHERE pm.user_id=(SELECT auth.uid()) AND (p.created_by=user_notifications.user_id OR EXISTS(SELECT 1 FROM public.class_homeroom_teachers ht WHERE ht.class_id=p.class_id AND ht.teacher_id=user_notifications.user_id AND ht.ended_at IS NULL)))
 OR EXISTS(SELECT 1 FROM public.class_team_members a JOIN public.class_team_members b ON b.team_id=a.team_id WHERE a.student_id=(SELECT auth.uid()) AND b.student_id=user_notifications.user_id AND a.left_at IS NULL AND b.left_at IS NULL)
));