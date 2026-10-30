import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { createReport, checkArguments } from '../support.ts';

// Removing guards, invoking accessors, or truncating away failures must break these tests.
test('status precedence and raw argument boundaries', () => {
  const r=createReport();
  for(const status of ['PASS','UNVERIFIED','FAIL','ERROR']) r.addCheck({id:status,category:'contract',status,path:'/',provenance:[]});
  assert.equal(r.finish().status,'ERROR');
  for(const x of [null,undefined,[],3,{}]) assert.equal(checkArguments(x,['question']).status,'FAIL');
  assert.equal(checkArguments({question:null},['question']),null);
  assert.equal(checkArguments({question:'x'.repeat(2_000_001)},['question']).status,'FAIL');
});
test('resource limits include delimiters and exact byte boundaries', () => {
  const n=2_000_000-Buffer.byteLength(JSON.stringify({question:''}));
  assert.equal(checkArguments({question:'x'.repeat(n)},['question']),null);
  assert.equal(checkArguments({question:'x'.repeat(n+1)},['question']).diagnostics[0].code,'INPUT_LIMIT');
  assert.equal(checkArguments({question:Array(10_001).fill(0)},['question']).status,'FAIL');
  let v=0; for(let i=0;i<32;i++) v=[v];
  assert.equal(checkArguments({question:v},['question']).status,'FAIL');
  v=0; for(let i=0;i<31;i++) v=[v];
  assert.equal(checkArguments({question:v},['question']),null);
  const many={question:Array.from({length:6},()=>Array(9000).fill(0))};
  assert.equal(checkArguments(many,['question']).diagnostics[0].code,'INPUT_LIMIT');
});
test('cycles differ from repeated acyclic references', () => {
  const shared={a:1}; assert.equal(checkArguments({question:[shared,shared]},['question']),null);
  shared.a=shared; assert.equal(checkArguments({question:shared},['question']).status,'FAIL');
});
test('getters proxies and non-JSON values are not evaluated', () => {
  let calls=0; const getter={get secret(){calls++;return 1;}};
  const proxy=new Proxy({}, {ownKeys(){calls++;throw Error('private');}});
  for(const value of [getter,proxy,Array(1),undefined,()=>0,Symbol(),1n,NaN,Infinity,new Date(),Object.create({a:1})])
    assert.equal(checkArguments({question:value},['question']).status,'FAIL');
  assert.equal(calls,0);
  const plain=JSON.parse('{"__proto__":{"x":1},"constructor":2}');
  assert.equal(checkArguments({question:plain},['question']),null);
  assert.equal(checkArguments({question:Object.assign(Object.create(null),{a:1})},['question']),null);
});
test('unknown property names cannot leak private payloads', () => {
  const r=checkArguments({question:{},PRIVATE_SENTINEL:'PRIVATE_SENTINEL'},['question']);
  assert.equal(r.status,'FAIL'); assert.equal(JSON.stringify(r).includes('PRIVATE_SENTINEL'),false);
  assert.equal(r.diagnostics[0].path,'/'); assert.equal(r.diagnostics[0].propertyIndex,1);
});
test('report caps retain hidden failure severity and bound output', () => {
  const r=createReport();
  for(let i=0;i<251;i++) r.addDiagnostic({code:'X',status:'UNVERIFIED',path:'/',message:'x',suggestedCorrection:'x'});
  r.addDiagnostic({code:'PRIVATE',status:'FAIL',path:'/',message:'x',suggestedCorrection:'x'});
  assert.equal(r.finish().status,'FAIL'); assert.equal(r.finish().diagnostics.length,251);
  const c=createReport(); for(let i=0;i<2001;i++) c.addCheck({id:'X',status:'PASS',path:'/',category:'contract',provenance:[]});
  assert.equal(c.finish().status,'UNVERIFIED'); assert.equal(c.finish().checks.length,2001);
  const large=createReport().finish({payload:'x'.repeat(2_000_001)});
  assert.equal(large.status,'ERROR'); assert.equal(large.data,undefined);
});
