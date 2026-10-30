import './offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync,mkdirSync,writeFileSync,readFileSync,rmSync,symlinkSync,existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawn } from 'node:child_process';
import { createInterface } from 'node:readline';
import { pathToFileURL } from 'node:url';
import { runtimeLaunch,harnessRoot } from '../scripts/runtime.mjs';
import { configuration } from '../scripts/configuration.mjs';
import { getHarnessRoles,getHarnessAgents,getHarnessTools } from '../scripts/configuration-harness-info.mjs';
import { resourceConfigurationPanel } from '../scripts/configuration-resources-ui.mjs';
import { inspectResources,resourceRows,toggleResource } from '../scripts/configuration-resources.mjs';

function fixture(t){const root=mkdtempSync(join(tmpdir(),'config-restore-'));t.after(()=>rmSync(root,{recursive:true,force:true}));mkdirSync(join(root,'.generation','agents'),{recursive:true});const env={GENERATION_HARNESS_RUNTIME_DIR:join(root,'runtime')};return {root,env,controller:configuration({root,env,scope:'project'})};}
test('Reading alias loads only native extensions, uses project cwd and preserves default cwd',t=>{
 const {root,env}=fixture(t),launch=runtimeLaunch(['--reading','--mode','rpc'],env);
 assert.equal(launch.cwd,harnessRoot);assert.equal(launch.args.includes('--reading'),false);assert.equal(launch.args.includes('--approve'),false);
 assert.ok(launch.args.includes(join(harnessRoot,'.generation/extensions/reading.ts')));assert.ok(launch.args.includes(join(harnessRoot,'scripts/config-extension.mjs')));
 assert.equal(runtimeLaunch([],env).cwd,join(root,'runtime','workspace'));
 assert.equal(runtimeLaunch(['--reading','--cwd',root],env).cwd,root);
 assert.equal(runtimeLaunch(['--reading','--no-extensions'],env).args.includes(join(harnessRoot,'.generation/extensions/reading.ts')),false);
});
test('config shows launcher-pinned Reading and config extensions as locked, not editable filters',async t=>{
 const {env}=fixture(t),launch=runtimeLaunch(['--reading'],env),controller=configuration({root:harnessRoot,env:launch.env,scope:'project'});
 const catalog=await inspectResources(controller),rows=resourceRows(controller,catalog);
 for(const path of [join(harnessRoot,'.generation/extensions/reading.ts'),join(harnessRoot,'scripts/config-extension.mjs')]){const matches=rows.filter(row=>row.path===path);assert.equal(matches.length,1);assert.equal(matches[0].locked,true);assert.throws(()=>toggleResource(controller,catalog,matches[0]),/CLI override/);}
});
test('restored inventory derives tools and agents without reviving fixed Reading policy',t=>{
 const {root,controller}=fixture(t);writeFileSync(join(root,'.generation/agents/custom.md'),'---\nname: custom-author\ntools: [read, write]\n---\nUse model-directed tools.');
 const agents=getHarnessAgents(root,controller.runtime);assert.deepEqual(agents.map(a=>a.name),['custom-author']);assert.deepEqual(agents[0].tools,['read','write']);
 const categories=getHarnessTools(root),reading=categories.find(c=>c.category==='IELTS Reading Domain Tools');assert.equal(reading.items.length,7);
 assert.match(reading.items.find(t=>t.name==='check_grading_parity').parameters,/submission/);
 assert.doesNotMatch(JSON.stringify([...getHarnessRoles(),...categories]),/13[–-]14|40 scoring|Multi-Agent Pipeline|Verifies \.NET backend parity|Fails closed on symlink escape/);
});
test('credential edits reject symlink escape and corrupt files without overwriting secrets',t=>{
 const {root,controller}=fixture(t),outside=join(root,'outside.json');mkdirSync(join(controller.runtime,'agent'),{recursive:true});writeFileSync(outside,'{"private":"SENTINEL"}');symlinkSync(outside,controller.paths.auth);
 assert.throws(()=>controller.setProviderApiKey('test','synthetic'));assert.throws(()=>controller.getAuthProviders());assert.equal(readFileSync(outside,'utf8'),'{"private":"SENTINEL"}');
 rmSync(controller.paths.auth);writeFileSync(controller.paths.auth,'{corrupt');assert.throws(()=>controller.setProviderApiKey('test','synthetic'));assert.equal(readFileSync(controller.paths.auth,'utf8'),'{corrupt');
});
test('malformed settings errors do not echo private file contents',t=>{
 const {controller}=fixture(t);writeFileSync(controller.paths.project,'PRIVATE_SENTINEL');assert.throws(()=>controller.show(),error=>!error.message.includes('PRIVATE_SENTINEL'));
});
test('provider summaries never expose credentials or arbitrary credential type payloads',t=>{
 const {controller}=fixture(t);mkdirSync(join(controller.runtime,'agent'),{recursive:true});writeFileSync(controller.paths.auth,JSON.stringify({test:{type:'PRIVATE_SENTINEL',key:'PRIVATE_SENTINEL'}}));assert.equal(JSON.stringify(controller.show()).includes('PRIVATE_SENTINEL'),false);
});
test('settings editor accepts per-keystroke WASD text without navigating away',async t=>{
 const {controller}=fixture(t);const empty={global:{extensions:[],skills:[],prompts:[],themes:[]},project:{extensions:[],skills:[],prompts:[],themes:[]},packages:[],launcher:[]};const panel=await resourceConfigurationPanel(controller,{inspect:async()=>empty});
 panel.handleInput('\x1bOQ'); // F2
 // First preference is defaultProvider; Enter opens its native text editor.
 panel.handleInput('\r');for(const character of 'wasd-provider')panel.handleInput(character);panel.handleInput('\r');assert.equal(controller.show().preferences.defaultProvider.value,'wasd-provider');assert.match(panel.render(120).join('\n'),/^Settings/);
});
test('Reading launcher actually loads native tools and /config with isolated SDK state',async t=>{
 const {env}=fixture(t),launch=runtimeLaunch(['--reading'],env);
 const {createAgentSession,DefaultResourceLoader,ModelRuntime,SessionManager,SettingsManager}=await import('generation-harness-core');
 const {InMemoryCredentialStore}=await import('generation-ai');
 const modelRuntime=await ModelRuntime.create({credentials:new InMemoryCredentialStore(),modelsPath:null,refreshOnCreate:false});
 const settingsManager=SettingsManager.inMemory({cacheWarming:'off',retry:{enabled:false}});
 const paths=launch.args.flatMap((arg,i)=>arg==='--extension'?[launch.args[i+1]]:[]);
 const loader=new DefaultResourceLoader({cwd:launch.cwd,agentDir:launch.env.GENERATION_HARNESS_AGENT_DIR,settingsManager,noExtensions:true,noSkills:true,noThemes:true,noPromptTemplates:true,noContextFiles:true,additionalExtensionPaths:paths});
 await loader.reload();assert.deepEqual(loader.getExtensions().errors,[]);
 const {session}=await createAgentSession({cwd:launch.cwd,agentDir:launch.env.GENERATION_HARNESS_AGENT_DIR,modelRuntime,settingsManager,resourceLoader:loader,sessionManager:SessionManager.inMemory(launch.cwd)});
 t.after(async()=>{try{await session.extensionRunner.emit({type:'session_shutdown',reason:'quit'});}finally{session.dispose();}});await session.bindExtensions({mode:'rpc'});
 const tools=session.getAllTools().map(tool=>tool.name);for(const name of ['read','bash','edit','write','get_question_spec','validate_question','validate_group','validate_exam','verify_evidence','check_grading_parity','inspect_delivery_projection'])assert.ok(tools.includes(name),name);
 assert.ok(session.extensionRunner.getRegisteredCommands().some(command=>command.name==='config'));
});

test('start:reading RPC exposes /config without model inference or host credentials',async t=>{
 const {env}=fixture(t);
 await new Promise((resolve,reject)=>{
  const child=spawn(process.execPath,['--import',pathToFileURL(join(harnessRoot,'test/offline.mjs')).href,join(harnessRoot,'scripts/run.mjs'),'--reading','--mode','rpc','--no-session','--offline'],{cwd:harnessRoot,env:{...process.env,...env},stdio:['pipe','pipe','pipe']});
  let stderr='',done=false;const finish=error=>{if(done)return;done=true;clearTimeout(timer);child.kill('SIGTERM');error?reject(error):resolve();};
  const timer=setTimeout(()=>finish(Error('Reading RPC launch timeout: '+stderr)),20000);
  t.after(()=>{clearTimeout(timer);child.kill('SIGTERM');});child.stderr.on('data',chunk=>{stderr+=chunk;});child.on('error',finish);child.on('exit',code=>{if(!done)finish(Error('Reading RPC exited '+code+': '+stderr));});
  const lines=createInterface({input:child.stdout});lines.on('line',line=>{let response;try{response=JSON.parse(line);}catch{return;}if(response.id==='config-commands'){try{assert.equal(response.success,true);assert.ok(response.data.commands.some(command=>command.name==='config'));finish();}catch(error){finish(error);}}});
  child.stdin.on('error',()=>{});child.stdin.write(JSON.stringify({id:'config-commands',type:'get_commands'})+'\n');
 });
});

test('package aliases point to the runnable launcher/config and include config regressions',()=>{
 const pkg=JSON.parse(readFileSync(join(harnessRoot,'package.json')));assert.equal(pkg.scripts['start:reading'],'node scripts/run.mjs --reading');assert.equal(pkg.scripts.config,'node scripts/config.mjs');assert.match(pkg.scripts.test,/config-restoration\.test\.mjs/);
});
