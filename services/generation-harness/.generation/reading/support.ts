import { types } from 'node:util';
import type { CanonicalContext, CanonicalRecord, Category, Check, Diagnostic, ReadingResult, Report, Status } from './types.ts';

export const CONTRACT_ID='urn:langfens:question-types:1.0.0';
export const CONTRACT_VERSION='1.0.0';
export const LIMITS=Object.freeze({bytes:2_000_000,nodes:50_000,depth:32,entries:10_000,diagnostics:250,checks:2000});
export const object=(v: unknown): v is CanonicalRecord=>v!==null && typeof v==='object' && !Array.isArray(v);
export const own=(o: object,k: PropertyKey)=>Object.hasOwn(o,k);
export const pointer=(k: string | number)=>String(k).replaceAll('~','~0').replaceAll('/','~1');
export const at=(base: string,k: string | number)=>`${base==='/'?'':base}/${pointer(k)}`;
export const nonblank=(v: unknown): v is string=>typeof v==='string' && /\S/u.test(v);
export const positive=(v: unknown): v is number=>typeof v==='number' && Number.isInteger(v) && v>0 && v<=2147483647;
export const uuid=(v: unknown): v is string=>typeof v==='string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v);
export const identity=(v: string)=>uuid(v)?v.toLowerCase():v;
export const keysEqual=(a: unknown[],b: unknown[])=>JSON.stringify(a.map(v=>JSON.stringify(v)).sort())===JSON.stringify(b.map(v=>JSON.stringify(v)).sort());
export const asciiFold=(s: string)=>s.replace(/^[ \t\r\n\f\v]+|[ \t\r\n\f\v]+$/g,'').replace(/[A-Z]/g,c=>c.toLowerCase());
const rank={PASS:0,UNVERIFIED:1,FAIL:2,ERROR:3};
export function createReport(info: {hash?: string}={}): Report {
  const result: ReadingResult={status:'PASS',contractVersion:CONTRACT_VERSION,contractId:CONTRACT_ID,contractHash:info.hash??null,checks:[],diagnostics:[]};
  const outcomes: Record<Status,number>={PASS:0,UNVERIFIED:0,FAIL:0,ERROR:0};
  const elevate=(status: Status)=>{outcomes[status]++;if(rank[status]>rank[result.status]) result.status=status;};
  const r: Report={result,
    mark(){return {...outcomes};},
    statusSince(mark){for(const status of ['ERROR','FAIL','UNVERIFIED'] as const)if(outcomes[status]>mark[status])return status;return 'PASS';},
    addCheck(check) {
      elevate(check.status);
      if(result.checks.length<LIMITS.checks) result.checks.push(check);
      else if(result.checks.length===LIMITS.checks) {
        result.checks.push({id:'CHECK_DETAIL_LIMIT',category:'contract',path:'/',status:'UNVERIFIED',provenance:[]}); elevate('UNVERIFIED');
      }
    },
    addDiagnostic(d) {
      elevate(d.status);
      if(result.diagnostics.length<LIMITS.diagnostics) result.diagnostics.push(d);
      else if(result.diagnostics.length===LIMITS.diagnostics) {
        result.diagnostics.push({code:'DIAGNOSTIC_LIMIT',status:'UNVERIFIED',path:'/',message:'Additional diagnostics were omitted.',suggestedCorrection:'Correct reported errors and validate again.'}); elevate('UNVERIFIED');
      }
    },
    check(id,status,provenance=[],path='/',category='semantic') {this.addCheck({id,status,path,category,provenance:Array.isArray(provenance)?provenance:[provenance]});},
    diagnostic(code,path,message,suggestedCorrection='Correct the indicated field using the requested canonical specification.',expected,status='FAIL',rule,extra={}) {
      this.addDiagnostic({code,status,path:path||'/',message,suggestedCorrection,...(expected!==undefined?{expected}:{}),...(rule?{provenance:[`${CONTRACT_ID}#/x-langfens/semanticRules/${rule}`]}:{}),...extra});
    },
    pending(code,path,message,rule,correction='Supply independent, revision-bound evidence for this check.') {this.diagnostic(code,path,message,correction,undefined,'UNVERIFIED',rule);},
    finish(data) {
      if(data!==undefined) result.data=data;
      if(Buffer.byteLength(JSON.stringify(result))>LIMITS.bytes) return {status:'ERROR',contractVersion:CONTRACT_VERSION,contractId:CONTRACT_ID,contractHash:result.contractHash,checks:[],diagnostics:[{code:'OUTPUT_LIMIT',status:'ERROR',path:'/',message:'Result exceeds the output resource limit.',suggestedCorrection:'Validate a smaller artifact.',expected:LIMITS.bytes}]};
      return result;
    },
  }; return r;
}

// Iterative traversal counts encoded JSON bytes and never evaluates getters/proxy traps.
export function inputProblem(value: unknown): {code: string} | null {
  const active=new Set<unknown>(), stack: {v: unknown; depth?: number; exit?: boolean}[]=[{v:value,depth:0}], fail=(code: string)=>({code}); let nodes=0, bytes=0;
  const stringBytes=(s: string)=>{if(Buffer.byteLength(s)>LIMITS.bytes) return LIMITS.bytes+1;return Buffer.byteLength(JSON.stringify(s));};
  while(stack.length) {
    const item=stack.pop()!; if(item.exit){active.delete(item.v);continue;}
    const {v,depth=0}=item;
    if(++nodes>LIMITS.nodes || depth>LIMITS.depth) return fail('INPUT_LIMIT');
    if(v===null) bytes+=4;
    else if(typeof v==='string') bytes+=stringBytes(v);
    else if(typeof v==='boolean') bytes+=v?4:5;
    else if(typeof v==='number' && Number.isFinite(v)) bytes+=String(v).length;
    else if(typeof v==='object') {
      if(types.isProxy(v)) return fail('INPUT_NON_JSON');
      const array=Array.isArray(v), proto=Object.getPrototypeOf(v);
      if(array ? proto!==Array.prototype : proto!==Object.prototype && proto!==null) return fail('INPUT_NON_JSON');
      if(active.has(v)) return fail('INPUT_NON_JSON');
      const names=Reflect.ownKeys(v);
      if(names.some(k=>typeof k==='symbol')) return fail('INPUT_NON_JSON');
      const keys=(array?names.filter(k=>k!=='length'):names) as string[];
      if(keys.length>LIMITS.entries || (array && v.length>LIMITS.entries)) return fail('INPUT_LIMIT');
      if(array && (keys.length!==v.length || keys.some((k,i)=>k!==String(i)))) return fail('INPUT_NON_JSON');
      active.add(v);stack.push({exit:true,v});bytes+=2+Math.max(0,keys.length-1);
      for(let i=keys.length-1;i>=0;i--) {
        const k=keys[i], d=Object.getOwnPropertyDescriptor(v,k)!;
        if(!d.enumerable || !own(d,'value')) return fail('INPUT_NON_JSON');
        if(!array) bytes+=stringBytes(k)+1;
        stack.push({v:d.value,depth:depth+1});
      }
    } else return fail('INPUT_NON_JSON');
    if(bytes>LIMITS.bytes) return fail('INPUT_LIMIT');
  }
  return null;
}
export function fields(r: Report,value: unknown,allowed: string[],required: string[],path: string): value is CanonicalRecord {
  if(!object(value)) {r.diagnostic('OBJECT_REQUIRED',path,'Expected a JSON object.','Supply a JSON object.');return false;}
  for(const k of required) if(!own(value,k)) r.diagnostic('FIELD_REQUIRED',at(path,k),'Required field is absent.','Supply this field.');
  Object.keys(value).forEach((k,i)=>{if(!allowed.includes(k)) r.diagnostic('FIELD_UNKNOWN',path,'An unknown field is present.','Remove the unknown field at the reported property index.',undefined,'FAIL',undefined,{propertyIndex:i});});
  return true;
}
export function checkArguments(raw: unknown,requiredNames: string[],optionalNames: string[]=[]): ReadingResult | null {
  const r=createReport(), p=inputProblem(raw);
  if(p) {r.diagnostic(p.code,'/','Input is non-JSON or exceeds deterministic resource limits.','Supply plain bounded JSON values.',p.code==='INPUT_LIMIT'?LIMITS:undefined);return r.finish();}
  if(!object(raw)) {r.diagnostic('ARGUMENTS_OBJECT_REQUIRED','/','Tool arguments must be an object.','Supply the documented outer argument object.');return r.finish();}
  fields(r,raw,[...requiredNames,...optionalNames],requiredNames,'/');return r.result.status==='PASS'?null:r.finish();
}
export function identities(r: Report,items: unknown[],path: string,key='id',caseInsensitive=false): void {
  const seen=new Set();items.forEach((x,i)=>{if(!object(x)||typeof x[key]!=='string')return;const k=caseInsensitive?x[key].toLowerCase():identity(x[key]);if(seen.has(k))r.diagnostic('IDENTITY_DUPLICATE',at(at(path,i),key),'Identity is duplicated in this scope.','Use a unique stable identity.',undefined,'FAIL','COMMON');seen.add(k);});
}
function safeLocation(c: CanonicalContext,value: unknown,instancePath: string,base: string): {path: string; propertyIndex?: number} {
  const safe=c.propertyNames; let v: any=value,path=base;
  for(const encoded of instancePath.split('/').slice(1)) {
    const k=encoded.replaceAll('~1','/').replaceAll('~0','~');
    if(!safe.has(k) && !/^(?:0|[1-9][0-9]{0,18})$/.test(k)) return {path,propertyIndex:object(v)?Object.keys(v).indexOf(k):0};
    path=at(path,k);v=v?.[k];
  } return {path};
}
export function structural(c: CanonicalContext,r: Report,value: unknown,ref: string,path: string,checkId='STRUCTURE'): boolean {
  const validator=c.validator(ref), valid=validator.Check(value);
  r.check(checkId,valid?'PASS':'FAIL',`${c.schema.$id}${ref}`,path,'structure');
  if(valid)return true;
  for(const e of validator.Errors(value)) {
    const location=safeLocation(c,value,e.instancePath??'',path), keyword=e.keyword??'invalid';
    const props=keyword==='required'?e.params.requiredProperties:keyword==='additionalProperties'?e.params.additionalProperties:keyword==='unevaluatedProperties'?e.params.unevaluatedProperties:null;
    const list=Array.isArray(props)?props:props?[props]:[];
    for(const key of list.length?list:[null]) {
      let where=location;
      if(key!==null && c.propertyNames.has(key)) where={...location,path:at(location.path,key)};
      else if(key!==null) {const obj=(e.instancePath??'').split('/').slice(1).reduce((v: any,k: string)=>v?.[k.replaceAll('~1','/').replaceAll('~0','~')],value);where={path:location.path,propertyIndex:object(obj)?Object.keys(obj).indexOf(key):0};}
      r.diagnostic(`SCHEMA_${keyword.replace(/([A-Z])/g,'_$1').toUpperCase()}`,where.path,`Canonical ${keyword} constraint violated.`,undefined,undefined,'FAIL',undefined,where);
    }
  }return false;
}
