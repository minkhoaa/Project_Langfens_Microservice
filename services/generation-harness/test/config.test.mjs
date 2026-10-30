import './offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, statSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { Value } from 'typebox/value';
import { SettingsManager } from 'generation-harness-core';
import { configuration } from '../scripts/configuration.mjs';
import { configurationPanel, openConfiguration } from '../scripts/configuration-ui.mjs';
import { harnessRoot } from '../scripts/runtime.mjs';
import { VirtualTerminal } from '../packages/tui/test/virtual-terminal.ts';
function fixture(t) {
  const root=mkdtempSync(join(tmpdir(),'harness-config-'));t.after(()=>rmSync(root,{recursive:true,force:true}));
  mkdirSync(join(root,'.generation'));const env={GENERATION_HARNESS_RUNTIME_DIR:join(root,'runtime'),PI_CODING_AGENT_DIR:join(root,'host-pi')};
  const create=scope=>configuration({root,env,scope});return {root,env,create,controller:create('project')};
}
test('read-only config uses local paths and never creates state or discovers credentials',t=>{
  const {controller,root}=fixture(t),snapshot=controller.show();
  assert.equal(snapshot.authorizesLivePilot,false);assert.equal(snapshot.preferences.defaultProvider.value,null);
  assert.equal(existsSync(join(root,'runtime')),false);assert.equal(existsSync(join(root,'host-pi')),false);
  assert.ok(controller.paths.user.startsWith(root));assert.ok(controller.paths.models.startsWith(root));
});
test('project settings override isolated user settings using native merge semantics',t=>{
  const {controller,create}=fixture(t);create('user').update('defaultModel','user-model');controller.update('defaultModel','project-model');
  const snapshot=controller.show();assert.equal(snapshot.preferences.defaultModel.value,'project-model');assert.equal(snapshot.preferences.defaultModel.source,'project');
  const native=SettingsManager.create(join(controller.paths.project,'../..'),join(controller.paths.user,'..'));
  assert.equal(native.getDefaultModel(),snapshot.preferences.defaultModel.value);
  controller.update('defaultModel',undefined,true);assert.equal(controller.show().preferences.defaultModel.value,'user-model');
});
test('validated edits preserve unrelated native settings and use private atomic files',t=>{
  const {controller}=fixture(t);
  writeFileSync(controller.target,JSON.stringify({extensions:['./extensions/reading.ts'],customExtension:{retained:true}}));
  controller.update('retry.provider.maxRetries','0');controller.update('defaultThinkingLevel','high');
  const stored=JSON.parse(readFileSync(controller.target,'utf8'));assert.deepEqual(stored.extensions,['./extensions/reading.ts']);assert.deepEqual(stored.customExtension,{retained:true});
  assert.equal(stored.retry.provider.maxRetries,0);assert.equal(stored.defaultThinkingLevel,'high');
  if(process.platform!=='win32') assert.equal(statSync(controller.target).mode&0o777,0o600);
  const before=readFileSync(controller.target,'utf8');
  for(const [key,value] of [['defaultThinkingLevel','wrong'],['quietStartup','42'],['retry.maxRetries','-1'],['retry.maxRetries','0.5'],['__proto__.secret','yes'],['defaultProvider',''],['defaultModel','bad\u001b[2J']]) assert.throws(()=>controller.update(key,value));
  assert.equal(readFileSync(controller.target,'utf8'),before);
});
test('malformed settings and escaping symlinks fail closed',t=>{
  const {controller,root}=fixture(t);writeFileSync(controller.target,'{broken');assert.throws(()=>controller.show());
  rmSync(controller.target);const other=join(root,'other.json');writeFileSync(other,'{}');symlinkSync(other,controller.target);assert.throws(()=>controller.show(),/symlink/);
});
test('runtime root symlinks do not redirect config into host settings',t=>{
  const {root,env}=fixture(t);mkdirSync(join(root,'host'));symlinkSync(join(root,'host'),env.GENERATION_HARNESS_RUNTIME_DIR,'dir');
  assert.throws(()=>configuration({root,env}),/symlink/);
});
test('endpoint example validates without restoring removed Reading or native-setting overrides',()=>{
  const example=JSON.parse(readFileSync(join(harnessRoot,'.generation/config/models.example.json'),'utf8'));
  assert.equal(Value.Check(JSON.parse(readFileSync(join(harnessRoot,'packages/generation-harness-core/schemas/models.schema.json'),'utf8')),example),true);
  assert.equal(existsSync(join(harnessRoot,'.generation/config/reading.json')),false);
});
test('CLI is safe without TTY and supports isolated user edits, paths and validation',t=>{
  const {env,root}=fixture(t),script=join(harnessRoot,'scripts/config.mjs');
  const run=args=>spawnSync(process.execPath,[script,...args],{cwd:root,env:{...process.env,...env,GENERATION_HARNESS_OFFLINE:'1'},encoding:'utf8'});
  let result=run([]);assert.equal(result.status,0,result.stderr);assert.equal(JSON.parse(result.stdout).authorizesLivePilot,false);assert.equal(existsSync(env.GENERATION_HARNESS_RUNTIME_DIR),false);
  result=run(['--scope','user','--set','defaultProvider','test-provider']);assert.equal(result.status,0,result.stderr);
  const agent=join(env.GENERATION_HARNESS_RUNTIME_DIR,'agent');writeFileSync(join(agent,'auth.json'),'DO NOT READ CREDENTIALS');writeFileSync(join(agent,'models.json'),'DO NOT DISCOVER MODELS');
  for(const args of [['--show'],['--paths'],['--validate'],['--scope','user','--unset','defaultProvider'],['--help']]) {result=run(args);assert.equal(result.status,0,result.stderr);assert.doesNotMatch(result.stdout,/DO NOT READ|DO NOT DISCOVER/);}
  for(const args of [['--set','defaultModel'],['--scope','host'],['--show','--validate'],['config']]) assert.equal(run(args).status,1);
  assert.equal(existsSync(join(root,'host-pi')),false);
});
test('native settings-list panel supports enum and text edits without a session',t=>{
  const {controller}=fixture(t);controller.update('defaultThinkingLevel','medium');let closed=false;
  const panel=configurationPanel(controller,{onClose:()=>{closed=true;}});
  panel.selectItem('defaultThinkingLevel');panel.handleInput('\r');assert.equal(controller.show().preferences.defaultThinkingLevel.value,'high');
  panel.selectItem('defaultProvider');panel.handleInput('\r');panel.handleInput('test-provider');panel.handleInput('\r');assert.equal(controller.show().preferences.defaultProvider.value,'test-provider');
  for(const width of [40,80,120]) assert.ok(panel.render(width).length>0);
  panel.handleInput('\x1b');assert.equal(closed,true);
});
test('standalone native TUI starts and exits with a virtual terminal, no model runtime',async t=>{
  const {controller}=fixture(t),terminal=new VirtualTerminal(100,30);
  const opening=openConfiguration(controller,{terminal,view:'settings'});await terminal.waitForRender();
  assert.match(terminal.getViewport().join('\n'),/Configuration \(project\)/);
  terminal.sendInput('\x1b');await opening;
  assert.equal(existsSync(controller.paths.models),false);
});
test('model credentials storage and persistence: set-key, unset-key, and project isolation',t=>{
  const {controller,root,env}=fixture(t);

  // 1. Initially no credentials in isolated test runtime
  assert.deepEqual(controller.getAuthProviders(),[]);

  // 2. Set an API key directly in project runtime
  const saved=controller.setProviderApiKey('custom-provider','sk-valid-key-1234');
  assert.equal(saved.provider,'custom-provider');
  assert.equal(existsSync(controller.paths.auth),true);

  // Verify permissions and file contents on disk
  if(process.platform!=='win32') assert.equal(statSync(controller.paths.auth).mode&0o777,0o600);
  const diskAuth=JSON.parse(readFileSync(controller.paths.auth,'utf8'));
  assert.equal(diskAuth['custom-provider'].type,'api_key');
  assert.equal(diskAuth['custom-provider'].key,'sk-valid-key-1234');

  // Verify getAuthProviders returns provider metadata without leaking secret key in summary
  const providers=controller.getAuthProviders();
  assert.equal(providers.length,1);
  assert.equal(providers[0].provider,'custom-provider');
  assert.equal(providers[0].type,'api_key');
  assert.equal(providers[0].status,'configured');

  // Verify credentials isolation property in show()
  const snapshot=controller.show();
  assert.equal(snapshot.credentials.isolation,'PROJECT_LOCAL_ONLY');
  assert.equal(existsSync(join(root,'host-pi')),false);

  // 3. Remove key
  const removed=controller.removeProviderApiKey('custom-provider');
  assert.equal(removed.removed,true);
  assert.deepEqual(controller.getAuthProviders(),[]);

  // 4. Verify settings persistence: update changes actually modify settings files on disk
  controller.update('defaultThinkingLevel','high');
  controller.update('defaultProvider','custom-provider');
  const diskSettings=JSON.parse(readFileSync(controller.paths.project,'utf8'));
  assert.equal(diskSettings.defaultThinkingLevel,'high');
  assert.equal(diskSettings.defaultProvider,'custom-provider');
});
