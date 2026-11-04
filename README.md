# StudyLoad

StudyLoad is a browser-based study planner with Supabase authentication and shared academic data.

## Run locally

Open `index.html` in a browser or run:

```bash
python -m http.server 8000
```

Then visit `http://localhost:8000`.

## Supabase setup

The browser client is configured in `supabase-client.js` with the project URL and a **publishable** key. Never place a Supabase secret or service-role key in frontend code.

Required Auth configuration:

- Enable email/password sign-in.
- Set the production Site URL and allowed redirect URLs.
- If email confirmation is enabled, users must confirm their email before signing in.
- The `handle_new_user()` trigger creates a student profile from Auth metadata. New registrations cannot self-assign teacher or admin roles.

## Data integration

The frontend now reads and writes these shared Supabase domains:

- **Identity:** Supabase Auth and `profiles`; teacher access requests are reviewed through the admin RPC.
- **Classes:** class roster, homeroom teachers, subject teachers, subjects. Class and subject creation/assignment is restricted to admins.
- **Assignments:** class assignments are stored in `assignments`; per-student status and actual time are stored in `assignment_progress`; confirmed study sessions are stored in `study_sessions`.
- **Projects:** projects and members, class teams and team leaders, project tasks, project evidence and project resources.
- **Personal state:** preferences, personal tasks and busy-time settings are stored in `user_app_state` and protected by user-scoped RLS.

Database-side RLS and validated RPCs remain authoritative. Frontend role checks are for user experience only.

## Current limitations — not production sign-off

The following parts of the existing UI are **not yet fully connected** to their dedicated Supabase domain tables and must not be treated as shared/production-ready workflows:

- Duty schedules and duty evidence submissions/reviews.
- Officer tasks, role delegations, announcements and read receipts.
- Class weekly reports and team weekly updates.
- Personal library file storage and cross-user sharing.
- Uploading binary files for project evidence/resources (current project evidence/resources support text and external links).
- Complete profile administration, account banning, and all admin user-management screens.

Legacy browser-local demo data and sample accounts are not automatically migrated into the relational schema. Personal tasks remain in the user's app-state snapshot; only class assignments have per-student relational progress. No live browser end-to-end test has been completed in this integration pass.

## Security checks to complete before public production

- Review the 41 existing `SECURITY DEFINER` functions exposed to authenticated users; each must have a verified authorization check or restricted EXECUTE grants.
- Enable leaked-password protection in Supabase Auth.
- Re-run Supabase Security and Performance Advisors and address remaining policy/index findings.
- Test registration, email confirmation, role boundaries, class membership, assignment progress, project membership and evidence review with separate student, teacher and admin accounts.
- Configure production Auth redirect URLs and verify the deployed domain.

## Database migrations added in this integration

- `add_user_app_state`
- `fix_project_task_initial_status`
- `add_project_evidence_and_resources`
- `restrict_project_evidence_review`
- `restrict_user_app_state_privileges`
- `restrict_trigger_function_execution`
- `align_project_task_status_and_team_leader_access`

## Branch and review

Integration work is isolated on `feat/supabase-integration`. The draft pull request targets `main`; it has not been merged and production deployment has not been performed.
