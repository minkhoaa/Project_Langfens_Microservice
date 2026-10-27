import './offline.mjs';
import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import test from 'node:test';
import { createAgentSession, DefaultResourceLoader, ModelRuntime, SessionManager, SettingsManager } from 'langfens-harness-core';
import { InMemoryCredentialStore, fauxAssistantMessage, fauxProvider, fauxToolCall } from 'langfens-ai';

const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
async function fixture(t) {
  const entry=join(root,'packages/langfens-subagents/dist/index.js');
  assert.ok(existsSync(entry),'local subagent execution implementation must exist');
  const api=await import(pathToFileURL(entry).href);
  const cwd=mkdtempSync(join(tmpdir(),'langfens-child-'));
  t.after(()=>rmSync(cwd,{recursive:true,force:true}));
  const modelRuntime=await ModelRuntime.create({credentials:new InMemoryCredentialStore(),modelsPath:null,refreshOnCreate:false});
  const faux=fauxProvider({models:[{id:'parent'},{id:'agent'},{id:'override'}]});
  modelRuntime.registerNativeProvider(faux.provider);
  return {api,cwd,faux,context:{cwd,agentDir:join(cwd,'agent'),sessionDir:join(cwd,'sessions'),parentSessionId:'parent-sentinel',
    modelRuntime,parentModel:faux.getModel('parent'),agents:[{name:'worker',systemPrompt:'Complete only the delegated task.',tools:['read']} ]}};
}

test('single delegation uses a real local child session and file tool with usage and progress',async t=>{
  const {api,cwd,faux,context}=await fixture(t);
  writeFileSync(join(cwd,'tiếng Việt file.txt'),'child local data');
  faux.setResponses([
    fauxAssistantMessage(fauxToolCall('read',{path:'tiếng Việt file.txt'}),{stopReason:'toolUse'}),
    ctx=>{assert.match(ctx.messages.find(m=>m.role==='toolResult').content[0].text,/child local data/);return {...fauxAssistantMessage('read-complete'),usage:{input:5,output:3,cacheRead:0,cacheWrite:0,totalTokens:8,cost:{input:0,output:0,cacheRead:0,cacheWrite:0,total:0}}};}
  ]);
  const events=[];
  const result=await api.executeSubagent({agent:'worker',task:'Read the file'}, {...context,onProgress:e=>events.push(e)});
  assert.equal(result.status,'completed');assert.equal(result.results.length,1);
  const child=result.results[0];assert.equal(child.output,'read-complete');assert.equal(child.model,'faux/parent');
  assert.notEqual(child.sessionId,'parent-sentinel');assert.ok(child.sessionFile.startsWith(context.sessionDir+'/'));
  assert.ok(existsSync(child.sessionFile));assert.ok(child.usage.totalTokens>0);
  assert.equal(faux.state.callCount,2);
  assert.ok(events.some(e=>e.status==='running'));assert.ok(events.some(e=>e.tool==='read'));
  assert.equal(events.at(-1).status,'completed');
  assert.match(readFileSync(child.sessionFile,'utf8'),/read-complete/);
});

test('ordered delegation propagates previous output and isolates histories with model override precedence',async t=>{
  const {api,faux,context}=await fixture(t);context.agents[0].model='faux/agent';
  faux.setResponses([
    (ctx,_opts,_state,model)=>{assert.equal(model.id,'override');return fauxAssistantMessage('FIRST-RESULT');},
    (ctx,_opts,_state,model)=>{
      assert.equal(model.id,'agent');
      const users=ctx.messages.filter(m=>m.role==='user');
      assert.equal(users.length,1);assert.deepEqual(users[0].content,[{type:'text',text:'Second sees FIRST-RESULT, root original task'}]);
      return fauxAssistantMessage('SECOND-RESULT');
    }
  ]);
  const result=await api.executeSubagent({task:'original task',chain:[
    {agent:'worker',task:'First task',model:'faux/override'},
    {agent:'worker',task:'Second sees {previous}, root {task}'}
  ]},context);
  assert.equal(result.status,'completed',JSON.stringify(result));assert.deepEqual(result.results.map(r=>r.output),['FIRST-RESULT','SECOND-RESULT']);
  assert.deepEqual(result.results.map(r=>r.model),['faux/override','faux/agent']);
  assert.notEqual(result.results[0].sessionId,result.results[1].sessionId);
});

test('invalid sequence inputs fail before any inference, including invalid later model',async t=>{
  const {api,faux,context}=await fixture(t);
  for(const input of [{chain:[]},{agent:'missing',task:'no'},
    {chain:[{agent:'worker',task:'valid'},{agent:'worker',task:'invalid',model:'missing/model'}]}]) {
    await assert.rejects(api.executeSubagent(input,context),/agent|chain|model/i);
  }
  await assert.rejects(api.executeSubagent({agent:'worker',task:'no'},{...context,agents:[...context.agents,...context.agents]}),/duplicate/i);
  assert.equal(faux.state.callCount,0);
});

test('partial provider failure and empty terminal response cannot become successful child results',async t=>{
  const {api,faux,context}=await fixture(t);
  faux.setResponses([fauxAssistantMessage('partial secret',{stopReason:'error',errorMessage:'fixture failure'}),fauxAssistantMessage('')]);
  const failed=await api.executeSubagent({chain:[{agent:'worker',task:'fail'},{agent:'worker',task:'must not start'}]},context);
  assert.equal(failed.status,'failed');assert.equal(failed.results.length,1);assert.match(failed.results[0].error,/fixture failure/);
  assert.equal(faux.state.callCount,1);
  const empty=await api.executeSubagent({agent:'worker',task:'empty'},context);
  assert.equal(empty.status,'failed');assert.match(empty.results[0].error,/empty|output/i);
});

test('registered extension delegates through the parent native tool loop and keeps SDK agentDir',async t=>{
  const {api,faux,context}=await fixture(t);
  const settingsManager=SettingsManager.inMemory({cacheWarming:'off',retry:{enabled:false},compaction:{enabled:false}});
  const loader=new DefaultResourceLoader({cwd:context.cwd,agentDir:context.agentDir,settingsManager,noExtensions:true,
    noSkills:true,noThemes:true,noPromptTemplates:true,noContextFiles:true,
    extensionFactories:[api.createSubagentExtension({agents:context.agents})]});
  await loader.reload();
  const parentManager=SessionManager.create(context.cwd,join(context.cwd,'parent-sessions'));
  const {session}=await createAgentSession({cwd:context.cwd,agentDir:context.agentDir,modelRuntime:context.modelRuntime,
    model:context.parentModel,resourceLoader:loader,settingsManager,sessionManager:parentManager});
  t.after(()=>session.dispose());await session.bindExtensions({mode:'rpc'});
  faux.setResponses([
    fauxAssistantMessage(fauxToolCall('subagent',{agent:'worker',task:'child native task'}),{stopReason:'toolUse'}),
    ctx=>{assert.deepEqual(ctx.messages.filter(m=>m.role==='user').at(-1).content,[{type:'text',text:'child native task'}]);return fauxAssistantMessage('CHILD-NATIVE');},
    ctx=>{assert.match(ctx.messages.find(m=>m.role==='toolResult'&&m.toolName==='subagent').content[0].text,/CHILD-NATIVE/);return fauxAssistantMessage('PARENT-DONE');}
  ]);
  const events=[];session.subscribe(e=>events.push(e));
  await session.prompt('Parent task');
  assert.equal(session.getLastAssistantText(),'PARENT-DONE',JSON.stringify(session.messages));assert.equal(faux.state.callCount,3);
  assert.ok(events.some(e=>e.type==='tool_execution_update'&&e.toolName==='subagent'));
});

test('agent files use the retained frontmatter parser only in Langfens roots',async t=>{
  const {api,cwd,context}=await fixture(t);
  mkdirSync(join(context.agentDir,'agents'),{recursive:true});
  writeFileSync(join(context.agentDir,'agents','worker.md'),'---\nname: worker\nmodel: faux/agent\ntools:\n  - read\n  - bash\n---\nFocused local worker.');
  mkdirSync(join(cwd,'.pi','agents'),{recursive:true});
  writeFileSync(join(cwd,'.pi','agents','poison.md'),'---\nname: must-not-load\n---\nHost data');
  const agents=api.discoverAgents(cwd,context.agentDir);
  assert.equal(agents.length,1);assert.deepEqual(agents[0].tools,['read','bash']);
  assert.equal(agents[0].systemPrompt,'Focused local worker.');
  mkdirSync(join(cwd,'.langfens','agents'),{recursive:true});
  writeFileSync(join(cwd,'.langfens','agents','duplicate.md'),'---\nname: worker\n---\nDuplicate');
  assert.throws(()=>api.discoverAgents(cwd,context.agentDir),/duplicate/i);
});

test('simultaneous parents retain independent child cwd, sessions and provider state',async t=>{
  const one=await fixture(t),two=await fixture(t);
  for(const [index,item] of [[1,one],[2,two]]) {
    writeFileSync(join(item.cwd,'owned.txt'),`owner-${index}`);
    item.faux.setResponses([
      fauxAssistantMessage(fauxToolCall('read',{path:'owned.txt'}),{stopReason:'toolUse'}),
      ctx=>{assert.equal(ctx.messages.find(m=>m.role==='toolResult').content[0].text,`owner-${index}`);return fauxAssistantMessage(`answer-${index}`);}
    ]);
  }
  const before=process.cwd(),environment={...process.env};
  const [first,second]=await Promise.all([one.api.executeSubagent({agent:'worker',task:'read'},one.context),two.api.executeSubagent({agent:'worker',task:'read'},two.context)]);
  assert.equal(first.results[0].output,'answer-1');assert.equal(second.results[0].output,'answer-2');
  assert.notEqual(first.results[0].sessionId,second.results[0].sessionId);
  assert.ok(first.results[0].sessionFile.startsWith(one.context.sessionDir+'/'));
  assert.ok(second.results[0].sessionFile.startsWith(two.context.sessionDir+'/'));
  assert.equal(one.faux.state.callCount,2);assert.equal(two.faux.state.callCount,2);
  assert.equal(process.cwd(),before);assert.deepEqual({...process.env},environment);
});

test('abort cancels an actual child bash process and does not start the next step',{timeout:8000},async t=>{
  const {api,cwd,faux,context}=await fixture(t);context.agents[0].tools=['bash'];
  const marker=join(cwd,'started.pid'),controller=new AbortController();
  const script=`require('node:fs').writeFileSync(${JSON.stringify(marker)},String(process.pid));setTimeout(()=>{},30000)`;
  faux.setResponses([fauxAssistantMessage(fauxToolCall('bash',{command:`${JSON.stringify(process.execPath)} -e ${JSON.stringify(script)}`}),{stopReason:'toolUse'})]);
  let timer;
  try {
    const result=await api.executeSubagent({chain:[{agent:'worker',task:'wait locally'},{agent:'worker',task:'must not start'}]}, {
      ...context,signal:controller.signal,onProgress:e=>{if(e.tool==='bash'&&!timer)timer=setInterval(()=>{if(existsSync(marker)){clearInterval(timer);controller.abort();}},10);}
    });
    assert.equal(result.status,'cancelled');assert.equal(result.results.length,1);assert.equal(faux.state.callCount,1);
    assert.ok(existsSync(marker),'real Node child reached its tool body');
    const pid=Number(readFileSync(marker,'utf8'));
    assert.throws(()=>process.kill(pid,0),/ESRCH/);
  } finally {clearInterval(timer);controller.abort();}
});

test('abort during child inference settles cancellation and prevents a later sequence step',{timeout:5000},async t=>{
  const {api,faux,context}=await fixture(t);const controller=new AbortController();
  faux.setResponses([async (_ctx,opts)=>{
    await new Promise(resolve=>{if(opts.signal.aborted)return resolve();opts.signal.addEventListener('abort',resolve,{once:true});});
    return fauxAssistantMessage('',{stopReason:'aborted'});
  }]);
  let timer;
  try {
    const run=api.executeSubagent({chain:[{agent:'worker',task:'wait'},{agent:'worker',task:'must not start'}]}, {
      ...context,signal:controller.signal,onProgress:event=>{if(event.status==='running'&&!timer)timer=setTimeout(()=>controller.abort(),30);}
    });
    const result=await run;
    assert.equal(result.status,'cancelled');assert.equal(result.results.length,1);assert.equal(faux.state.callCount,1);
  } finally {clearTimeout(timer);}
});
