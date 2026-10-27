import './offline.mjs';
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { runtimeLaunch } from '../scripts/runtime.mjs';
import test from 'node:test';
import { discoverAndLoadExtensions } from 'langfens-harness-core';

const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
test('vendored local subagent extension registers its tool and lifecycle without global packages',async t=>{
  const cwd=mkdtempSync(join(tmpdir(),'langfens-extension-'));
  t.after(()=>rmSync(cwd,{recursive:true,force:true}));
  const entry=join(root,'packages/langfens-subagents/dist/index.js');
  assert.ok(existsSync(entry),'local subagent workspace must be built');
  const result=await discoverAndLoadExtensions([entry],cwd,join(cwd,'agent'));
  t.after(()=>result.runtime.invalidate());
  assert.deepEqual(result.errors,[]);
  assert.equal(result.extensions.length,1);
  assert.deepEqual([...result.extensions[0].tools.keys()],['subagent']);
  assert.ok(result.extensions[0].handlers.has('session_start'));
  assert.ok(result.extensions[0].handlers.has('session_shutdown'));
});

for(const source of [false,true]) {
  test(`${source?'source':'compiled'} root launcher loads the local subagent by default`,t=>{
    const dir=mkdtempSync(join(tmpdir(),'langfens-default-extension-'));
    t.after(()=>rmSync(dir,{recursive:true,force:true}));
    const snapshot=join(dir,'tools.json'), inspect=join(dir,'inspect.mjs');
    writeFileSync(inspect,`import {writeFileSync} from 'node:fs'; export default api=>api.on('session_start',()=>writeFileSync(${JSON.stringify(snapshot)},JSON.stringify(api.getAllTools().map(t=>t.name))));`);
    const args=[...(source?['--source']:[]),'--mode','rpc','--no-session','--extension',inspect];
    const launch=runtimeLaunch(args,{PATH:'/usr/bin:/bin',LANGFENS_HARNESS_RUNTIME_DIR:join(dir,'runtime')});
    const output=execFileSync(launch.command,launch.args,{cwd:launch.cwd,env:{...launch.env,NODE_OPTIONS:`--import=${new URL('./offline.mjs',import.meta.url).href}`},
      input:'{"type":"get_state","id":"owned"}\n',encoding:'utf8',timeout:20000});
    const tools=JSON.parse(readFileSync(snapshot,'utf8'));
    assert.equal(tools.filter(name=>name==='subagent').length,1);
    assert.ok(output.trim().split('\n').map(line=>JSON.parse(line)).some(line=>line.id==='owned'&&line.success));
  });
}

test('the actual vendored child SDK loader rejects foreign roots without importing global code',async t=>{
  for(const kind of ['missing','foreign-link']) {
    const dir=mkdtempSync(join(tmpdir(),'langfens-child-owner-'));
    t.after(()=>rmSync(dir,{recursive:true,force:true}));
    const pkg=join(dir,'packages/langfens-subagents'), helper=join(pkg,'dist/runs/shared/harness-spawn.js');
    mkdirSync(dirname(helper),{recursive:true});writeFileSync(join(pkg,'package.json'),'{"name":"langfens-subagents","type":"module"}');
    copyFileSync(join(root,'packages/langfens-subagents/dist/runs/shared/harness-spawn.js'),helper);
    const marker=join(dir,'foreign-imported'),foreign=join(dir,'node_modules/langfens-harness-core');
    mkdirSync(join(foreign,'dist'),{recursive:true});
    writeFileSync(join(foreign,'package.json'),'{"name":"langfens-harness-core","version":"1.4.0","type":"module","main":"dist/index.js"}');
    writeFileSync(join(foreign,'dist/index.js'),`import {writeFileSync} from 'node:fs';writeFileSync(${JSON.stringify(marker)},'wrong');`);
    if(kind==='foreign-link') symlinkSync(foreign,join(dir,'packages/langfens-harness-core'),'dir');
    const actual=await import(pathToFileURL(helper).href);
    await assert.rejects(actual.loadHostHarnessCore(),/Foreign|ENOENT|local/i);
    assert.equal(existsSync(marker),false);
  }
});
