# StudyLoad

StudyLoad is a browser-based study planner with Supabase authentication, shared class workflows, project collaboration, and per-user cloud state.

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
- `handle_new_user()` creates a student profile from Auth metadata. New registrations cannot self-assign teacher or admin roles.

## Integrated data domains

- **Identity and administration:** Supabase Auth, profiles, teacher-role requests, account role/banning/profile management, class and subject administration.
- **Classes:** class rosters, homeroom and subject teacher assignments, class membership.
- **Assignments:** class assignments, per-student progress, study sessions, private assignment evidence uploads.
- **Personal planner:** personal tasks, busy-time windows, reminder preferences and other per-user app state synced through `user_app_state`.
- **Class operations:** duty schedules, duty evidence uploads/reviews, officer tasks, class officer roles, temporary role delegations, announcements and read receipts.
- **Reports:** class weekly reports and per-member team weekly updates.
- **Projects:** projects and members, class teams and team leaders, project tasks, evidence and resource uploads.
- **Library:** private personal files, per-user sharing, signed file access and external links.
- **Notifications:** per-user cloud activity inbox for class/project events plus local due-date reminders.

The frontend role checks are only for user experience. Database RLS and authorization-checked RPCs remain authoritative. Private Storage buckets are used for personal library, project files, assignment evidence and duty evidence.

## Database migrations

The Supabase migrations applied during integration are tracked in `supabase/migrations/`:

- `20261104152327_add_user_app_state`
- `20261104154414_fix_project_task_initial_status`
- `20261104154432_add_project_evidence_and_resources`
- `20261104154440_restrict_project_evidence_review`
- `20261104154621_restrict_user_app_state_privileges`
- `20261104154714_restrict_trigger_function_execution`
- `20261104154750_align_project_task_status_and_team_leader_access`
- `20261104155545_add_private_shared_library`
- `20261104155833_allow_library_metadata_only_items`
- `20261104160010_add_shared_user_notifications`
- `20261104160027_allow_class_teacher_activity_notifications`
- `20261104160053_add_private_project_file_storage`
- `20261104160213_allow_admin_class_notifications`
- `20261104160442_allow_project_evidence_review_notifications`
- `20261104160555_consolidate_duty_schedule_update_policy`
- `20261104160632_optimize_notification_policy_auth_uid`
- `20261104161113_drop_duplicate_indexes`
- `20261104161215_authorize_project_manager_file_cleanup`

## Known limitations before production sign-off

- No full browser end-to-end test has yet been completed with separate student, teacher, and administrator accounts. CI checks JavaScript syntax, frontend wiring and static integration markers; it does not exercise every workflow or RLS edge case.
- Existing browser-local demo/sample data is not automatically migrated into relational Supabase records.
- Notifications are stored in the cloud inbox, but there is no push delivery while the browser is closed.
- Email confirmation, password reset, and production redirect configuration still require a real deployed-domain test.
- Supabase Security Advisor still reports 41 callable `SECURITY DEFINER` functions for authenticated users. These include intended RPCs and authorization helpers; each function still needs an individual privilege/authorization review.
- Supabase Auth leaked-password protection remains disabled and should be enabled in the project Auth settings.
- Performance Advisor still reports 49 RLS initplan notices, 27 unindexed foreign keys and 45 unused indexes. Five duplicate indexes and the duplicate duty UPDATE policy were removed; remaining index changes require workload measurements.

## Branch and review

Integration work is isolated on `feat/supabase-integration`. The draft pull request targets `main`. It has not been merged; production promotion is intentionally held until multi-role browser tests and the remaining security review pass.
