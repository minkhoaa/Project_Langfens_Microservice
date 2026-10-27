import './offline.mjs';
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { copyFileSync, mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { pathToFileURL, fileURLToPath } from 'node:url';
import test from 'node:test';
import { runtimeLaunch } from '../scripts/runtime.mjs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const core = join(root, 'packages/langfens-harness-core');
const guard = new URL('./offline.mjs', import.meta.url).href;
function scratch(t) {
  const dir = mkdtempSync(join(tmpdir(), 'langfens-sdk-isolation-'));
  t.after(() => rmSync(dir, {recursive:true, force:true}));
  return dir;
}

test('SDK defaults use the owned runtime without the launcher preload or host package override', t => {
  const dir = scratch(t), host = join(dir,'host'), runtime = join(dir,'runtime');
  mkdirSync(join(host,'.pi/agent'), {recursive:true});
  writeFileSync(join(host,'.pi/agent/auth.json'), '{"host":"not-a-real-credential"}');
  const probe = `
    import assert from 'node:assert/strict';
    import {getAgentDir,getSessionsDir,getPackageDir} from ${JSON.stringify(pathToFileURL(join(core,'dist/config.js')).href)};
    assert.equal(getAgentDir(), ${JSON.stringify(join(runtime,'agent'))});
    assert.equal(getSessionsDir(), ${JSON.stringify(join(runtime,'sessions'))});
    assert.equal(getPackageDir(), ${JSON.stringify(core)});
    console.log('sdk-owned');
  `;
  const output = execFileSync(process.execPath, ['--input-type=module','-e',probe], {
    cwd: host, encoding:'utf8', timeout:15000,
    env: {PATH:'/usr/bin:/bin',HOME:host,USERPROFILE:host,NODE_OPTIONS:`--import=${guard}`,
      NODE_PATH:join(host,'node_modules'),PI_PACKAGE_DIR:host,PI_CODING_AGENT_DIR:join(host,'.pi/agent'),
      LANGFENS_HARNESS_PACKAGE_DIR:host,LANGFENS_HARNESS_RUNTIME_DIR:runtime}
  });
  assert.equal(output.trim(),'sdk-owned');
});

test('an explicit tool cwd does not relocate private runtime state', t => {
  const dir = scratch(t), cwd = join(dir,'project with spaces'), state = join(dir,'state');
  mkdirSync(cwd,{recursive:true});
  const launch = runtimeLaunch(['--source','--cwd',cwd], {PATH:'/usr/bin:/bin',LANGFENS_HARNESS_RUNTIME_DIR:state});
  assert.equal(launch.cwd,cwd);
  assert.equal(launch.env.LANGFENS_HARNESS_AGENT_DIR,join(state,'agent'));
  assert.equal(launch.env.LANGFENS_HARNESS_SESSION_DIR,join(state,'sessions'));
  assert.ok(!launch.args.includes('--cwd'));
});

test('separate SDK runtime roots keep sessions independent without mutating process state', async t => {
  const {createAgentSession, ModelRuntime} = await import(pathToFileURL(join(core,'dist/index.js')).href);
  const {InMemoryCredentialStore, fauxProvider} = await import('langfens-ai');
  const dir = scratch(t), cwd = join(dir,'project');mkdirSync(cwd,{recursive:true});
  const environment = {...process.env}, originalCwd = process.cwd();
  const runtime = await ModelRuntime.create({credentials:new InMemoryCredentialStore(),modelsPath:null,refreshOnCreate:false});
  const faux = fauxProvider();runtime.registerNativeProvider(faux.provider);
  const sessions=[];
  try {
    for (const name of ['one','two']) {
      const {session} = await createAgentSession({cwd,runtimeDir:join(dir,name),modelRuntime:runtime,model:faux.getModel()});
      sessions.push(session);
      assert.ok(session.sessionManager.getSessionFile().startsWith(join(dir,name,'sessions')+'/'));
    }
    assert.notEqual(sessions[0].sessionManager.getSessionId(),sessions[1].sessionManager.getSessionId());
    sessions[0].sessionManager.appendMessage({role:'user',content:'only one',timestamp:Date.now()});
    assert.equal(sessions[1].sessionManager.buildSessionContext().messages.length,0);
    assert.equal(process.cwd(),originalCwd);
    assert.deepEqual({...process.env},environment);
  } finally {for(const session of sessions) session.dispose();}
});

test('launcher rejects foreign, malformed and symlinked core roots without PATH fallback', async t => {
  for (const kind of ['missing','malformed','wrong-name','foreign-link','missing-entry']) {
    const dir = scratch(t), scripts = join(dir,'scripts'), pkg = join(dir,'packages/langfens-harness-core');
    mkdirSync(scripts,{recursive:true});
    mkdirSync(dirname(pkg),{recursive:true});
    copyFileSync(join(root,'scripts/runtime.mjs'),join(scripts,'runtime.mjs'));
    if (kind === 'foreign-link') {
      const foreign=join(dir,'foreign');mkdirSync(foreign,{recursive:true});
      writeFileSync(join(foreign,'package.json'),JSON.stringify({name:'langfens-harness-core'}));
      symlinkSync(foreign,pkg,'dir');
    } else if (kind !== 'missing') {
      mkdirSync(pkg,{recursive:true});
      writeFileSync(join(pkg,'package.json'),kind==='malformed'?'not json':JSON.stringify({name:kind==='missing-entry'?'langfens-harness-core':'foreign-core'}));
    }
    const local = await import(pathToFileURL(join(scripts,'runtime.mjs')).href);
    assert.throws(() => local.runtimeLaunch(['--source'], {PATH:'/fake/global/bin',LANGFENS_HARNESS_RUNTIME_DIR:join(dir,'state')}), /local|owned|core|manifest|ENOENT/i,kind);
  }
});
