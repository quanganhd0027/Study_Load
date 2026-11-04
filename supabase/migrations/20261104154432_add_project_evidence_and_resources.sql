CREATE TABLE IF NOT EXISTS public.project_evidence (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),project_id uuid NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
 group_id uuid NULL REFERENCES public.class_teams(id) ON DELETE SET NULL,title text NOT NULL CHECK(length(trim(title))>0),
 description text NULL,external_url text NULL,submitted_by uuid NOT NULL REFERENCES public.profiles(id),
 contributors uuid[] NOT NULL DEFAULT '{}',status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','approved','needs_revision')),
 reviewed_by uuid NULL REFERENCES public.profiles(id),reviewed_at timestamptz NULL,
 created_at timestamptz NOT NULL DEFAULT now(),updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS project_evidence_project_created_idx ON public.project_evidence(project_id,created_at DESC);
ALTER TABLE public.project_evidence ENABLE ROW LEVEL SECURITY;
GRANT SELECT,INSERT,UPDATE,DELETE ON public.project_evidence TO authenticated;
REVOKE ALL ON public.project_evidence FROM anon,PUBLIC;
CREATE POLICY project_evidence_select_relevant ON public.project_evidence FOR SELECT TO authenticated USING(
 public.is_active_user() AND (submitted_by=auth.uid() OR EXISTS(SELECT 1 FROM public.projects p WHERE p.id=project_evidence.project_id AND
 (public.is_admin() OR p.created_by=auth.uid() OR (p.class_id IS NOT NULL AND (public.is_class_member(p.class_id) OR public.is_class_homeroom_teacher(p.class_id))) OR (p.team_id IS NOT NULL AND (public.is_team_member(p.team_id) OR public.is_team_leader(p.team_id)))))
);
CREATE POLICY project_evidence_insert_member ON public.project_evidence FOR INSERT TO authenticated WITH CHECK(
 public.is_active_user() AND submitted_by=auth.uid() AND EXISTS(SELECT 1 FROM public.project_members pm WHERE pm.project_id=project_evidence.project_id AND pm.user_id=auth.uid())
 AND (group_id IS NULL OR EXISTS(SELECT 1 FROM public.class_team_members tm WHERE tm.team_id=project_evidence.group_id AND tm.student_id=auth.uid() AND tm.left_at IS NULL))
);
CREATE POLICY project_evidence_update_reviewer ON public.project_evidence FOR UPDATE TO authenticated USING(
 public.is_active_user() AND (public.is_admin() OR submitted_by=auth.uid() OR EXISTS(SELECT 1 FROM public.projects p WHERE p.id=project_evidence.project_id AND (p.created_by=auth.uid() OR (p.class_id IS NOT NULL AND public.is_class_homeroom_teacher(p.class_id)))))
) WITH CHECK(
 public.is_active_user() AND (public.is_admin() OR submitted_by=auth.uid() OR EXISTS(SELECT 1 FROM public.projects p WHERE p.id=project_evidence.project_id AND (p.created_by=auth.uid() OR (p.class_id IS NOT NULL AND public.is_class_homeroom_teacher(p.class_id)))))
);
CREATE POLICY project_evidence_delete_authorized ON public.project_evidence FOR DELETE TO authenticated USING(
 public.is_active_user() AND (public.is_admin() OR submitted_by=auth.uid() OR (group_id IS NOT NULL AND public.is_team_leader(group_id)) OR EXISTS(SELECT 1 FROM public.projects p WHERE p.id=project_evidence.project_id AND (p.created_by=auth.uid() OR (p.class_id IS NOT NULL AND public.is_class_homeroom_teacher(p.class_id)))))
);
CREATE TABLE IF NOT EXISTS public.project_resources (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),project_id uuid NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
 group_id uuid NULL REFERENCES public.class_teams(id) ON DELETE SET NULL,name text NOT NULL CHECK(length(trim(name))>0),
 description text NULL,external_url text NULL,owner_id uuid NOT NULL REFERENCES public.profiles(id),created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS project_resources_project_created_idx ON public.project_resources(project_id,created_at DESC);
ALTER TABLE public.project_resources ENABLE ROW LEVEL SECURITY;
GRANT SELECT,INSERT,UPDATE,DELETE ON public.project_resources TO authenticated;
REVOKE ALL ON public.project_resources FROM anon,PUBLIC;
CREATE POLICY project_resources_select_relevant ON public.project_resources FOR SELECT TO authenticated USING(
 public.is_active_user() AND (owner_id=auth.uid() OR EXISTS(SELECT 1 FROM public.projects p WHERE p.id=project_resources.project_id AND
 (public.is_admin() OR p.created_by=auth.uid() OR (p.class_id IS NOT NULL AND (public.is_class_member(p.class_id) OR public.is_class_homeroom_teacher(p.class_id))) OR (p.team_id IS NOT NULL AND (public.is_team_member(p.team_id) OR public.is_team_leader(p.team_id)))))
);
CREATE POLICY project_resources_insert_member ON public.project_resources FOR INSERT TO authenticated WITH CHECK(
 public.is_active_user() AND owner_id=auth.uid() AND EXISTS(SELECT 1 FROM public.project_members pm WHERE pm.project_id=project_resources.project_id AND pm.user_id=auth.uid())
);
CREATE POLICY project_resources_update_owner_or_manager ON public.project_resources FOR UPDATE TO authenticated USING(
 public.is_active_user() AND (owner_id=auth.uid() OR public.is_admin() OR EXISTS(SELECT 1 FROM public.projects p WHERE p.id=project_resources.project_id AND (p.created_by=auth.uid() OR (p.class_id IS NOT NULL AND public.is_class_homeroom_teacher(p.class_id)))))
) WITH CHECK(
 public.is_active_user() AND (owner_id=auth.uid() OR public.is_admin() OR EXISTS(SELECT 1 FROM public.projects p WHERE p.id=project_resources.project_id AND (p.created_by=auth.uid() OR (p.class_id IS NOT NULL AND public.is_class_homeroom_teacher(p.class_id)))))
);
CREATE POLICY project_resources_delete_owner_or_manager ON public.project_resources FOR DELETE TO authenticated USING(
 public.is_active_user() AND (owner_id=auth.uid() OR public.is_admin() OR EXISTS(SELECT 1 FROM public.projects p WHERE p.id=project_resources.project_id AND (p.created_by=auth.uid() OR (p.class_id IS NOT NULL AND public.is_class_homeroom_teacher(p.class_id)))))
);