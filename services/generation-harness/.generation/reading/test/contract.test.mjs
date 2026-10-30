import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync,readFileSync,writeFileSync,rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { createHash } from 'node:crypto';
import { loadCanonical } from '../contract.ts';
import { canonicalUrl,q,vectors } from './helpers.mjs';

test('canonical snapshot and draft 2020-12 constraints are enforced without conversion',()=>{
 const c=loadCanonical(canonicalUrl);
 assert.equal(c.hash,'6345070a86b3271bc2ae348a0afcb33c928b42a1b55346809cb566a21c6478c5');
 for(const question of vectors) assert.equal(c.validator('#/$defs/'+question.type).Check(question),true,question.type);
 for(const [ref,value] of [['MatchPair',['A','text','extra']],['Uuid','not-a-uuid'],['PrivateOption',{id:'x',idx:1,contentMd:'x',isCorrect:false,imageUrl:'x'}],['FLOW_CHART',{...q('FLOW_CHART'),extra:1}],['TRUE_FALSE_NOT_GIVEN',{...q('TRUE_FALSE_NOT_GIVEN'),options:q('TRUE_FALSE_NOT_GIVEN').options.map(o=>({...o,isCorrect:true}))}]])
  assert.equal(c.validator('#/$defs/'+ref).Check(value),false,ref);
 const student={id:'q',idx:1,type:'FLOW_CHART',skill:'READING',difficulty:1,promptMd:'x',options:[]};
 assert.equal(c.validator('#/$defs/StudentQuestion').Check(student),false);
 assert.equal(c.validator('#/$defs/Uuid').Check('11111111-1111-1111-1111-111111111111'),true);
 assert.equal(c.validator('#/$defs/Uuid'),c.validator('#/$defs/Uuid'));
});
test('corrupt unavailable oversized and same-version changed contracts fail closed',()=>{
 const dir=mkdtempSync(join(tmpdir(),'reading-contract-'));
 try{const file=join(dir,'schema.json');
 for(const [text,code] of [['{','CONTRACT_INVALID'],['x'.repeat(1_000_001),'CONTRACT_RESOURCE_LIMIT'],[readFileSync(canonicalUrl,'utf8')+' ','CONTRACT_INVALID']]){
 writeFileSync(file,text);assert.throws(()=>loadCanonical(file),e=>e.code===code && !e.message.includes(dir));}
 assert.throws(()=>loadCanonical(join(dir,'absent')),e=>e.code==='CONTRACT_UNAVAILABLE');
 writeFileSync(file,readFileSync(canonicalUrl));assert.equal(loadCanonical(file).hash,loadCanonical(canonicalUrl).hash);
 }finally{rmSync(dir,{recursive:true,force:true});}
});
test('source fingerprints describe source-only evidence and drift is explicit',()=>{
 const manifest=JSON.parse(readFileSync(new URL('../sources.v1.json',import.meta.url)));
 assert.equal(manifest.verification,'source-only');assert.ok(manifest.divergences.length);
 for(const source of manifest.sources){const bytes=readFileSync(new URL('../../../../../'+source.path,import.meta.url));assert.equal(createHash('sha256').update(bytes).digest('hex'),source.sha256,source.id);}
});
