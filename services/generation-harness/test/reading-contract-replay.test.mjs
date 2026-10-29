import './offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createAgentSession, DefaultResourceLoader, ModelRuntime, SessionManager, SettingsManager } from 'generation-harness-core';
import { InMemoryCredentialStore, fauxAssistantMessage, fauxProvider, fauxToolCall } from 'generation-ai';
import { question } from '../.generation/fixtures/reading.mjs';
import { canonicalPilot } from '../.generation/fixtures/canonical-v1.mjs';
import { traceMetrics } from '../.generation/evaluation/contract-trace-metrics.mjs';

test('bounded native offline replay records duplicate calls, schema failures and terminal question-local repairs', async t => {
  const root=resolve(fileURLToPath(new URL('..',import.meta.url))),temp=mkdtempSync(join(tmpdir(),'canonical-replay-'));
  t.after(()=>rmSync(temp,{recursive:true,force:true}));
  const agentDir=join(temp,'agent');
  const runtime=await ModelRuntime.create({credentials:new InMemoryCredentialStore(),modelsPath:null,refreshOnCreate:false});
  const faux=fauxProvider({models:[{id:'replay'}]});runtime.registerNativeProvider(faux.provider);
  const loader=new DefaultResourceLoader({cwd:root,agentDir,settingsManager:SettingsManager.create(root,agentDir)});await loader.reload();
  assert.deepEqual(loader.getExtensions().errors,[]);
  const manager=SessionManager.inMemory();
  const {session}=await createAgentSession({cwd:root,agentDir,modelRuntime:runtime,model:faux.getModel('replay'),resourceLoader:loader,sessionManager:manager});
  t.after(()=>session.dispose());await session.bindExtensions({mode:'rpc'});
  const q=question('SUMMARY_COMPLETION'),bad={...q,promptMd:'No blank here.'};
  const calls=[['get_question_spec',{type:q.type}],['validate_question',{question:{...q,idx:'1'}}],['validate_question',{question:{...q,idx:'1'}}],['validate_question',{draft:{type:'MULTIPLE_CHOICE_SINGLE',options:[null,3]}}],['validate_question',{question:bad}],['validate_question',{question:bad}],['validate_question',{question:q}],['validate_exam',{canonicalExam:canonicalPilot(),complete:false,requirements:{profile:'strict-academic'}}]];
  for (const [i,[name,args]] of calls.entries()) {
    faux.setResponses([fauxAssistantMessage(fauxToolCall(name,args,{id:`replay-${i}`}),{stopReason:'toolUse'}),fauxAssistantMessage('Offline replay only.')]);
    await session.prompt(`Run deterministic offline case ${i}.`);
  }
  const entries=manager.getEntries();
  const results=entries.filter(e=>e.type==='message' && e.message.role==='toolResult').map(e=>e.message);
  assert.equal(results.length,8);
  assert.ok(results[1].isError && results[2].isError);
  assert.ok(results[5].details.diagnostics.some(d=>d.code==='REPAIR_NO_PROGRESS'));
  assert.ok(results[6].details.diagnostics.some(d=>d.code==='REPAIR_LIMIT_EXCEEDED'));
  assert.equal(results[7].details.status,'PASS');
  const text=[{type:'session',id:manager.getSessionId()},...entries].map(e=>JSON.stringify(e)).join('\n');
  const metrics=traceMetrics([{path:'synthetic-native-offline-replay',text}]);
  assert.equal(metrics.uniqueCalls,8);assert.equal(metrics.uniqueResults,8);assert.equal(metrics.schemaFailures,3);assert.equal(metrics.nativeSchemaErrors,2);assert.equal(metrics.schemaDiagnosticResults,1);assert.equal(metrics.withinSessionRepeatedCalls,2);
  t.diagnostic(JSON.stringify({evidenceClass:'OFFLINE_FAUX_NATIVE_REPLAY',...metrics,comparison:'Historical provider traces are unmatched corpora, not a measured token-savings A/B test.'}));
});
