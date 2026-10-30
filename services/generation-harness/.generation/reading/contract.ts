import { openSync, readSync, closeSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { Compile } from 'typebox/compile';
import type { CanonicalContext, CanonicalRecord, CanonicalValidator, Report } from './types.ts';
import { CONTRACT_ID,CONTRACT_VERSION,object,keysEqual } from './support.ts';
export const canonicalUrl=new URL('../contracts/question-types.v1.schema.json',import.meta.url);
export const CONTRACT_HASH='6345070a86b3271bc2ae348a0afcb33c928b42a1b55346809cb566a21c6478c5';
const failure=(code: string)=>Object.assign(new Error(code),{code});
export function boundedRead(url: URL | string,limit=1_000_000): Buffer {
 let fd: number | undefined;try{fd=openSync(url,'r');const b=Buffer.alloc(limit+1);let n=0,k;
  while(n<b.length && (k=readSync(fd,b,n,b.length-n,null))>0)n+=k;
  if(n>limit)throw failure('CONTRACT_RESOURCE_LIMIT');return b.subarray(0,n);
 }catch(e){if((e as {code?: string}).code==='CONTRACT_RESOURCE_LIMIT')throw e;throw failure('CONTRACT_UNAVAILABLE');}finally{if(fd!==undefined)closeSync(fd);}
}
function freeze<T>(v: T): T{if(v&&typeof v==='object'){Object.values(v).forEach(freeze);Object.freeze(v);}return v;}
export function loadCanonical(url: URL | string=canonicalUrl): CanonicalContext {
 const bytes=boundedRead(url);let schema: CanonicalRecord;
 try{schema=JSON.parse(bytes.toString('utf8'));}catch{throw failure('CONTRACT_INVALID');}
 const meta=schema?.['x-langfens'];
 if(schema?.$id!==CONTRACT_ID || meta?.contractVersion!==CONTRACT_VERSION)throw failure('CONTRACT_VERSION_UNSUPPORTED');
 const hash=createHash('sha256').update(bytes).digest('hex');
 if(hash!==CONTRACT_HASH || schema.$schema!=='https://json-schema.org/draft/2020-12/schema' || !object(meta.registry)||!object(meta.semanticRules))throw failure('CONTRACT_INVALID');
 const types=schema.$defs.QuestionType.enum;
 if(!keysEqual(types,Object.keys(meta.registry)))throw failure('CONTRACT_INVALID');
 const propertyNames=new Set<string>(),stack: CanonicalRecord[]=[schema];
 while(stack.length){const v=stack.pop()!;if(!object(v)&&!Array.isArray(v))continue;
  if(v.$ref && !v.$ref.startsWith('#/$defs/'))throw failure('CONTRACT_INVALID');
  if(v.properties)Object.keys(v.properties).forEach(k=>propertyNames.add(k));Object.values(v).forEach(x=>{if(x&&typeof x==='object')stack.push(x);});
 }
 for(const [type,e] of Object.entries(meta.registry) as [string,CanonicalRecord][])if(e.schema!==`#/$defs/${type}` || !schema.$defs[type] || !meta.answerFamilies[e.family] || e.rules.some((id: string)=>!meta.semanticRules[id]))throw failure('CONTRACT_INVALID');
 freeze(schema);const cache=new Map<string,CanonicalValidator>();
 const c: CanonicalContext={schema,meta,hash,propertyNames,validator(ref: string){
  if(!/^#\/\$defs\/[^/]+$/.test(ref)||!schema.$defs[ref.slice(8)])throw failure('CONTRACT_INVALID');
  if(!cache.has(ref)){try{cache.set(ref,Compile({$schema:schema.$schema,$defs:schema.$defs,$ref:ref}));}catch{throw failure('VALIDATOR_CAPABILITY_UNAVAILABLE');}}
  return cache.get(ref)!;
 }};
 // Canonical-derived conformance probes, never a weaker fallback schema.
 try{
  if(c.validator('#/$defs/MatchPair').Check(['A','text','extra']) || c.validator('#/$defs/Uuid').Check('invalid') || !c.validator('#/$defs/Uuid').Check('11111111-1111-1111-1111-111111111111') || c.validator('#/$defs/PublicOption').Check({id:'x',idx:1,contentMd:'x',imageUrl:'x'}))throw failure('VALIDATOR_CAPABILITY_UNAVAILABLE');
 }catch{throw failure('VALIDATOR_CAPABILITY_UNAVAILABLE');}
 return c;
}

const examples=new WeakMap<CanonicalContext,CanonicalRecord[]>();
export function getQuestionSpec(c: CanonicalContext,r: Report,type: unknown): CanonicalRecord {
 if(typeof type!=='string' || !Object.hasOwn(c.meta.registry,type)) {
  r.diagnostic('TYPE_UNSUPPORTED','/type','Unsupported canonical question type.','Use one of the available exact canonical literals.',c.schema.$defs.QuestionType.enum);
  return {availableTypes:[...c.schema.$defs.QuestionType.enum]};
 }
 const entry=c.meta.registry[type], required=new Set<string>(), properties=new Map<string,CanonicalRecord[]>(),seen=new Set<string>();
 function visit(node: CanonicalRecord): void{if(!node||typeof node!=='object')return;if(node.$ref){if(seen.has(node.$ref))return;seen.add(node.$ref);visit(c.schema.$defs[node.$ref.slice(8)]);}
  (node.required??[]).forEach((k: string)=>required.add(k));for(const [k,v] of Object.entries(node.properties??{})){if(!properties.has(k))properties.set(k,[]);properties.get(k)!.push(v as CanonicalRecord);}
  (node.allOf??[]).forEach(visit);
 }
 visit(c.schema.$defs[type]);
 const fields=Object.fromEntries([...properties].map(([k,v])=>[k,v.length===1?v[0]:{allOf:v}]));
 const constraints=c.schema.$defs[type];
 const definitions: CanonicalRecord={},refs: any[]=[constraints,...Object.values(fields)];
 while(refs.length){const v=refs.pop();if(!v||typeof v!=='object')continue;
  if(v.$ref&&!Object.hasOwn(definitions,v.$ref.slice(8))){const name=v.$ref.slice(8);definitions[name]=c.schema.$defs[name];refs.push(definitions[name]);}
  Object.values(v).forEach(x=>{if(x&&typeof x==='object')refs.push(x);});
 }
 if(!examples.has(c)){try{const bytes=boundedRead(new URL('../contracts/test-vectors/canonical-questions.v1.json',import.meta.url));if(createHash('sha256').update(bytes).digest('hex')!=='7f62f43e030fb37e37bd78619f147f9b6844f946a1bd2c7743b4d072ec14b287')throw failure('EXAMPLE_UNAVAILABLE');examples.set(c,freeze(JSON.parse(bytes.toString('utf8'))));}catch{throw failure('EXAMPLE_UNAVAILABLE');}}
 const example=examples.get(c)!.find(q=>q.type===type);
 if(!example || !c.validator(entry.schema).Check(example))throw failure('EXAMPLE_UNAVAILABLE');
 r.check('SPEC_RETRIEVAL','PASS',`${CONTRACT_ID}${entry.schema}`,'/type','contract');
 return {type,schemaRef:entry.schema,requiredFields:[...required],fields:structuredClone(fields),constraints:structuredClone(constraints),supportingDefinitions:structuredClone(definitions),answerFamily:{name:entry.family,...c.meta.answerFamilies[entry.family]},presentation:entry.presentation,semanticConstraints:entry.rules.map((id: string)=>({id,...c.meta.semanticRules[id],provenance:`${CONTRACT_ID}#/x-langfens/semanticRules/${id}`})),example:structuredClone(example),exampleValidity:{structure:'PASS',semantic:'UNVERIFIED'}};
}
