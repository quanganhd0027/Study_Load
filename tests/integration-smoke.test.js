const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const read = (name) => fs.readFileSync(path.join(root, name), 'utf8');
const app = read('app.js');
const html = read('index.html');
const client = read('supabase-client.js');

test('Supabase client loads before the application bundle', () => {
  const sdk = html.indexOf('supabase-js@2.118.0');
  const config = html.indexOf('supabase-client.js');
  const appScript = html.lastIndexOf('app.js');
  assert.ok(sdk >= 0 && config > sdk && appScript > config);
});

test('browser configuration contains only a publishable Supabase key', () => {
  assert.match(client, /sb_publishable_/);
  assert.doesNotMatch(client, /publishableKey\\s*=\\s*['\"][^'\"]*(?:sb_secret_|service_role|eyJhbGci)/);
  assert.match(client, /wbodoxqobkonkafjhfoh\.supabase\.co/);
});

test('legacy browser password authentication has been removed', () => {
  assert.doesNotMatch(app, /studyload_accounts_v1|studyload_session_v1|passwordHash|hashPassword/);
  assert.match(app, /signInWithPassword/);
  assert.match(app, /signUp/);
});

test('core class operations are wired to Supabase', () => {
  for (const marker of [
    "from('duty_schedules')",
    "from('duty_evidence')",
    "from('officer_tasks')",
    "from('class_announcements')",
    "from('announcement_reads')",
    "from('role_delegations')",
    "from('class_weekly_reports')",
    "from('team_weekly_updates')",
    "from('user_notifications')"
  ]) assert.ok(app.includes(marker), 'Missing data integration: ' + marker);
});

test('private file workflows use private Supabase Storage buckets', () => {
  for (const bucket of ['assignment-evidence', 'duty-evidence', 'project-files', 'study-library']) {
    assert.ok(app.includes("storage.from('" + bucket + "')"), 'Missing storage workflow: ' + bucket);
  }
});

test('admin profile editing preserves the selected theme', () => {
  assert.match(app, /name="theme"><option value="system" .*u\.theme==='system'/);
  assert.match(app, /admin_update_user_profile/);
});

test('project and admin workflows are present', () => {
  for (const marker of [
    'function renderClassTools()',
    'function manageClass(classId)',
    'function renderAdminUsers()',
    'function projectTaskForm(p,g)',
    'function evidenceForm(p,g)',
    'function resourceForm(p,g)'
  ]) assert.ok(app.includes(marker), 'Missing workflow: ' + marker);
});

test('all applied Supabase migrations are tracked in the repository', () => {
  const dir = path.join(root, 'supabase', 'migrations');
  const files = fs.readdirSync(dir).filter(x => x.endsWith('.sql'));
  assert.equal(files.length, 19);
  assert.ok(files.every(x => /^\d{14}_[a-z0-9_]+\.sql$/.test(x)));
});
