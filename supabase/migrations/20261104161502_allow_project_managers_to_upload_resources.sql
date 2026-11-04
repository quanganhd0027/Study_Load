DROP POLICY IF EXISTS project_resources_insert_member ON public.project_resources;
CREATE POLICY project_resources_insert_member ON public.project_resources FOR INSERT TO authenticated
WITH CHECK(
 public.is_active_user() AND owner_id=(SELECT auth.uid()) AND EXISTS(
  SELECT 1 FROM public.projects p WHERE p.id=project_resources.project_id AND (
   public.is_admin() OR p.created_by=(SELECT auth.uid())
   OR (p.class_id IS NOT NULL AND public.is_class_homeroom_teacher(p.class_id))
   OR EXISTS(SELECT 1 FROM public.project_members pm WHERE pm.project_id=p.id AND pm.user_id=(SELECT auth.uid()))
  )
 )
);
DROP POLICY IF EXISTS project_files_upload_member ON storage.objects;
CREATE POLICY project_files_upload_member ON storage.objects FOR INSERT TO authenticated
WITH CHECK(
 storage.objects.bucket_id='project-files'
 AND (storage.foldername(storage.objects.name))[1]=(SELECT auth.uid())::text
 AND EXISTS(
  SELECT 1 FROM public.projects p
  WHERE p.id::text=(storage.foldername(storage.objects.name))[2]
   AND (public.is_admin() OR p.created_by=(SELECT auth.uid())
    OR (p.class_id IS NOT NULL AND public.is_class_homeroom_teacher(p.class_id))
    OR EXISTS(SELECT 1 FROM public.project_members pm WHERE pm.project_id=p.id AND pm.user_id=(SELECT auth.uid())))
 )
);