import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fauxAssistantMessage } from 'generation-ai';
import { createNativeFixture } from './native-helpers.mjs';
import { callTool,createDomain } from '../domain.ts';
import { vectors,q,hasCode,canonicalUrl } from './helpers.mjs';
const meta=JSON.parse(readFileSync(canonicalUrl))['x-langfens'];
test('root npm test includes all offline Reading regressions without replacing existing suites',()=>{
 const scripts=JSON.parse(readFileSync(new URL('../../../package.json',import.meta.url))).scripts;
 assert.match(scripts.test,/test\/config\.test\.mjs/);assert.match(scripts.test,/test\/config-resources\.test\.mjs/);assert.match(scripts.test,/test\/config-restoration\.test\.mjs/);assert.match(scripts.test,/\.generation\/reading\/test\/\*\.test\.mjs/);assert.match(scripts.test,/npm run test -w generation-subagents/);
});
test('native explicit discovery and combined loading register exactly 13 tools once',async t=>{
 for(const loading of ['explicit','discovery','both']){const f=await createNativeFixture(t,{loading});const all=f.session.getAllTools().map(d=>d.name);assert.equal(new Set(all).size,17,loading);assert.equal(f.definitions.length,13,loading);for(const name of ['read','bash','edit','write'])assert.ok(all.includes(name));const r=JSON.parse((await f.invoke('get_question_spec',{type:'SHORT_ANSWER'})).content[0].text);assert.equal(r.status,'PASS');}
});
test('native agent discovery is identical with and without Reading',async t=>{
 const baseline=await createNativeFixture(t,{withReading:false}),reading=await createNativeFixture(t);
 assert.deepEqual(baseline.subagents.discoverAgents(baseline.cwd,baseline.agentDir),reading.subagents.discoverAgents(reading.cwd,reading.agentDir));assert.deepEqual(reading.childContext.agents.map(a=>a.name),['fixture-reader']);
});
test('native single and concurrent parallel delegation keep fresh histories and ordered results',async t=>{
 const f=await createNativeFixture(t);f.faux.setResponses([ctx=>{assert.deepEqual(ctx.messages.filter(m=>m.role==='user').map(m=>m.content[0].text),['public-only']);return fauxAssistantMessage('single');}]);
 const single=await f.subagents.executeSubagent({agent:'fixture-reader',task:'public-only'},f.childContext);assert.equal(single.status,'completed');assert.equal(single.results[0].output,'single');
 let started=0,release;const gate=new Promise(resolve=>{release=resolve;});
 const respond=async ctx=>{const task=ctx.messages.find(m=>m.role==='user').content[0].text;if(++started===2)release();await gate;return fauxAssistantMessage('result-'+task);};
 f.faux.setResponses([respond,respond]);const parallel=await f.subagents.executeSubagent({tasks:[{agent:'fixture-reader',task:'one'},{agent:'fixture-reader',task:'two'}]},f.childContext);
 assert.equal(started,2);assert.equal(parallel.status,'completed');assert.deepEqual(parallel.results.map(r=>r.output),['result-one','result-two']);assert.notEqual(parallel.results[0].sessionId,parallel.results[1].sessionId);
 for(const child of parallel.results){const history=readFileSync(child.sessionFile,'utf8');assert.equal(history.includes('parent-private-history'),false);assert.equal(history.includes('PRIVATE_ANSWER_SENTINEL'),false);}
 // Message isolation is not a filesystem sandbox claim.
});
test('all canonical rule IDs are represented and no unsupported rule silently passes',()=>{
 const covered=new Set();for(const question of vectors){const r=callTool('validate_question',{question});for(const id of meta.registry[question.type].rules){covered.add(id);assert.ok(r.checks.some(c=>c.id===id),question.type+':'+id);if(r.checks.find(c=>c.id===id).status==='UNVERIFIED')assert.ok(r.diagnostics.some(d=>d.provenance?.some(p=>p.endsWith('/'+id))),id);}}
 assert.deepEqual([...covered].sort(),Object.keys(meta.semanticRules).sort());
});
test('native transcripts retain safe JSON/details without pretending structuredContent survives',async t=>{
 const f=await createNativeFixture(t);const event=await f.invoke('validate_question',{question:q('SHORT_ANSWER')});assert.ok(event.structuredContent);const transcript=f.session.messages.find(m=>m.role==='toolResult');assert.equal(transcript.structuredContent,undefined);assert.deepEqual(transcript.details,event.details);
});
test('unexpected execution errors and adversarial inputs are bounded value-free reports',()=>{
 const malicious={ [Symbol.toPrimitive](){throw Error('PRIVATE_SENTINEL');} };const r=createDomain().call(malicious,{});assert.equal(r.status,'ERROR');assert.ok(hasCode(r,'INTERNAL_ERROR'));assert.equal(JSON.stringify(r).includes('PRIVATE_SENTINEL'),false);
 for(const value of [undefined,null,[],{},'PRIVATE_SENTINEL',JSON.parse('{"__proto__":{"private":"PRIVATE_SENTINEL"}}')]){const result=callTool('validate_question',{question:value});assert.equal(result.status,'FAIL');assert.equal(JSON.stringify(result).includes('PRIVATE_SENTINEL'),false);}
});
