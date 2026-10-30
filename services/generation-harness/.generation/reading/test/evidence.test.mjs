import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { verifyEvidence } from '../evidence.ts';
import { initialize,inspect,q,hasCode,check } from './helpers.mjs';
await initialize();
test('exact source spans pass mechanically but never prove truth or NOT GIVEN',()=>{
 const x=q('TRUE_FALSE_NOT_GIVEN'),passage={id:'p1',text:'A river flows north.'},evidence={sourceId:'p1',questionId:x.id,start:2,end:7,quote:'river'};
 const r=inspect(verifyEvidence,x,passage,evidence);assert.equal(check(r,'EVIDENCE_SPAN'),'PASS');assert.equal(r.status,'UNVERIFIED');assert.equal(r.data.semanticStatus,'UNVERIFIED');
 const bad=inspect(verifyEvidence,x,passage,{...evidence,sourceId:'other',quote:'PRIVATE_SENTINEL'});assert.ok(hasCode(bad,'EVIDENCE_SOURCE_MISMATCH'));assert.ok(hasCode(bad,'EVIDENCE_SPAN_MISMATCH'));assert.equal(JSON.stringify(bad).includes('PRIVATE_SENTINEL'),false);
});
test('UTF-16 boundaries and references are exact without normalization or quote search',()=>{
 const x=q('SHORT_ANSWER'),p={id:'p',text:'😀e\u0301'};
 for(const [start,end,quote,want] of [[0,2,'😀','UNVERIFIED'],[0,1,'\ud83d','FAIL'],[1,2,'\ude00','FAIL'],[2,4,'e\u0301','UNVERIFIED'],[2,4,'é','FAIL'],[-1,2,'x','FAIL'],[3,2,'x','FAIL'],[0,5,'x','FAIL']])assert.equal(inspect(verifyEvidence,x,p,{sourceId:'p',start,end,quote}).status,want);
 assert.ok(hasCode(inspect(verifyEvidence,x,'river',{start:0,end:5,quote:'river',sourceId:'p'}),'EVIDENCE_SOURCE_UNVERIFIED'));
 assert.ok(hasCode(inspect(verifyEvidence,x,p,{start:0,end:2,quote:'😀',questionId:'wrong'}),'EVIDENCE_QUESTION_MISMATCH'));
});
test('malformed evidence aggregates independent errors without throwing',()=>{
 for(const evidence of [null,[],3,{}, {start:0,end:1,quote:'x',extra:null},{start:'0',end:1,quote:'x'}])assert.equal(inspect(verifyEvidence,q('SHORT_ANSWER'),{id:'p',text:'x'},evidence).status,'FAIL');
});
