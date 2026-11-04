DROP POLICY IF EXISTS project_files_delete_owner ON storage.objects;
CREATE POLICY project_files_delete_authorized ON storage.objects FOR DELETE TO authenticated
USING(
 storage.objects.bucket_id='project-files' AND (
  (storage.foldername(storage.objects.name))[1]=(SELECT auth.uid())::text
  OR EXISTS(
   SELECT 1 FROM public.project_evidence e JOIN public.projects p ON p.id=e.project_id
   WHERE e.file_path=storage.objects.name AND (
    public.is_admin() OR (e.group_id IS NOT NULL AND public.is_team_leader(e.group_id))
    OR p.created_by=(SELECT auth.uid()) OR public.is_class_homeroom_teacher(p.class_id)
   )
  )
  OR EXISTS(
   SELECT 1 FROM public.project_resources r JOIN public.projects p ON p.id=r.project_id
   WHERE r.file_path=storage.objects.name AND (
    public.is_admin() OR p.created_by=(SELECT auth.uid()) OR public.is_class_homeroom_teacher(p.class_id)
   )
  )
 )
);