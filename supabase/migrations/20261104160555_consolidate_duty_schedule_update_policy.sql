DROP POLICY IF EXISTS duty_schedules_submit_own ON public.duty_schedules;
DROP POLICY IF EXISTS duty_schedules_update_manager ON public.duty_schedules;
CREATE POLICY duty_schedules_update_authorized ON public.duty_schedules
FOR UPDATE TO authenticated
USING (
 public.is_active_user() AND (
  (student_id=(SELECT auth.uid()) AND status IN ('pending','rejected'))
  OR public.is_admin()
  OR public.is_class_homeroom_teacher(class_id)
  OR public.has_class_officer_role(class_id,'labor_vp')
 )
)
WITH CHECK (
 public.is_active_user() AND (
  (student_id=(SELECT auth.uid()) AND status='submitted')
  OR public.is_admin()
  OR public.is_class_homeroom_teacher(class_id)
  OR public.has_class_officer_role(class_id,'labor_vp')
 )
);