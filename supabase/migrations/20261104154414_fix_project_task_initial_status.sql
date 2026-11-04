-- Ensure newly created project tasks use the status enum expected by the UI and task workflow.
CREATE OR REPLACE FUNCTION public.create_project_task(
 p_project_id uuid,p_title text,p_description text DEFAULT NULL::text,
 p_assigned_to uuid DEFAULT NULL::uuid,p_estimated_minutes integer DEFAULT NULL::integer,
 p_deadline timestamptz DEFAULT NULL
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE v_project record; v_task_id uuid;
BEGIN
 IF NOT public.is_active_user() THEN RAISE EXCEPTION 'Tài khoản không hoạt động'; END IF;
 SELECT * INTO v_project FROM public.projects WHERE id=p_project_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Không tìm thấy dự án'; END IF;
 IF NOT (public.is_admin() OR public.is_class_homeroom_teacher(v_project.class_id)
  OR (v_project.team_id IS NOT NULL AND public.is_team_leader(v_project.team_id))
  OR (v_project.team_id IS NULL AND v_project.created_by=auth.uid())) THEN
  RAISE EXCEPTION 'Bạn không có quyền giao nhiệm vụ trong dự án';
 END IF;
 IF p_title IS NULL OR length(trim(p_title))=0 THEN RAISE EXCEPTION 'Tên nhiệm vụ không được để trống'; END IF;
 IF p_estimated_minutes IS NOT NULL AND p_estimated_minutes<=0 THEN RAISE EXCEPTION 'Thời gian dự kiến phải lớn hơn 0'; END IF;
 IF p_assigned_to IS NOT NULL AND NOT EXISTS(
  SELECT 1 FROM public.project_members pm JOIN public.profiles p ON p.id=pm.user_id
  WHERE pm.project_id=p_project_id AND pm.user_id=p_assigned_to AND p.is_banned=false
 ) THEN RAISE EXCEPTION 'Người nhận không phải thành viên dự án'; END IF;
 INSERT INTO public.project_tasks(project_id,title,description,assigned_to,estimated_minutes,status,deadline)
 VALUES(p_project_id,trim(p_title),p_description,p_assigned_to,p_estimated_minutes,'not_started',p_deadline)
 RETURNING id INTO v_task_id;
 INSERT INTO public.audit_logs(actor_id,class_id,action,target_table,target_id,details)
 VALUES(auth.uid(),v_project.class_id,'project_task_created','project_tasks',v_task_id::text,
  jsonb_build_object('project_id',p_project_id,'assigned_to',p_assigned_to));
 RETURN v_task_id;
END; $$;