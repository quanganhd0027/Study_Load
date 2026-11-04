CREATE TABLE IF NOT EXISTS public.library_items (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),owner_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
 name text NOT NULL CHECK(length(trim(name))>0),description text NULL,external_url text NULL,file_path text NULL,
 shared_with uuid[] NOT NULL DEFAULT '{}',created_at timestamptz NOT NULL DEFAULT now(),updated_at timestamptz NOT NULL DEFAULT now(),
 CHECK(external_url IS NOT NULL OR file_path IS NOT NULL OR length(trim(coalesce(description,'')))>0)
);
CREATE INDEX IF NOT EXISTS library_items_owner_created_idx ON public.library_items(owner_id,created_at DESC);
ALTER TABLE public.library_items ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.library_items FROM anon,PUBLIC;
GRANT SELECT,INSERT,UPDATE,DELETE ON public.library_items TO authenticated;
CREATE POLICY library_items_select_owner_or_shared ON public.library_items FOR SELECT TO authenticated USING(public.is_active_user() AND (owner_id=auth.uid() OR auth.uid()=ANY(shared_with)));
CREATE POLICY library_items_insert_owner ON public.library_items FOR INSERT TO authenticated WITH CHECK(public.is_active_user() AND owner_id=auth.uid());
CREATE POLICY library_items_update_owner ON public.library_items FOR UPDATE TO authenticated USING(public.is_active_user() AND owner_id=auth.uid()) WITH CHECK(public.is_active_user() AND owner_id=auth.uid());
CREATE POLICY library_items_delete_owner ON public.library_items FOR DELETE TO authenticated USING(public.is_active_user() AND owner_id=auth.uid());
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types) VALUES('study-library','study-library',false,5242880,ARRAY['image/jpeg','image/png','image/webp','image/heic','text/plain','application/pdf','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document']) ON CONFLICT(id) DO UPDATE SET public=false,file_size_limit=5242880,allowed_mime_types=EXCLUDED.allowed_mime_types;
CREATE POLICY study_library_upload_own ON storage.objects FOR INSERT TO authenticated WITH CHECK(bucket_id='study-library' AND (storage.foldername(name))[1]=auth.uid()::text);
CREATE POLICY study_library_read_owner_or_shared ON storage.objects FOR SELECT TO authenticated USING(bucket_id='study-library' AND ((storage.foldername(name))[1]=auth.uid()::text OR EXISTS(SELECT 1 FROM public.library_items li WHERE li.file_path=storage.objects.name AND auth.uid()=ANY(li.shared_with))));
CREATE POLICY study_library_update_own ON storage.objects FOR UPDATE TO authenticated USING(bucket_id='study-library' AND (storage.foldername(name))[1]=auth.uid()::text) WITH CHECK(bucket_id='study-library' AND (storage.foldername(name))[1]=auth.uid()::text);
CREATE POLICY study_library_delete_own ON storage.objects FOR DELETE TO authenticated USING(bucket_id='study-library' AND (storage.foldername(name))[1]=auth.uid()::text);