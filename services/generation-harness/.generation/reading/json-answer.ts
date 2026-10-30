import type { Report } from './types.ts';
import { inputProblem,LIMITS } from './support.ts';
// A bounded lexical pass rejects duplicate members before the single document decode.
export function parseAnswerJson(r: Report,text: string,path: string): {valid: boolean; value?: unknown} {
 let i=0,nodes=0;const abort=(code: string): never=>{throw {code};};
 const ws=()=>{while(i<text.length&&/[\x20\t\r\n]/.test(text[i]))i++;};
 function str(): string{const start=i;if(text[i++]!=='"')abort('SUBMISSION_JSON_INVALID');while(i<text.length){const ch=text[i++];if(ch==='"')return text.slice(start,i);if(ch.charCodeAt(0)<32)abort('SUBMISSION_JSON_INVALID');if(ch==='\\'){const esc=text[i++];if(esc==='u'){if(!/^[0-9a-fA-F]{4}$/.test(text.slice(i,i+4)))abort('SUBMISSION_JSON_INVALID');i+=4;}else if(!esc||!('"\\/bfnrt'.includes(esc)))abort('SUBMISSION_JSON_INVALID');}}return abort('SUBMISSION_JSON_INVALID');}
 function value(depth: number): void{ws();if(depth>LIMITS.depth||++nodes>LIMITS.nodes)abort('SUBMISSION_JSON_LIMIT');
  if(text[i]==='{'){
   i++;ws();const keys=new Set();let count=0;if(text[i]==='}'){i++;return;}
   while(i<text.length){ws();if(++count>LIMITS.entries)abort('SUBMISSION_JSON_LIMIT');const key=JSON.parse(str());if(keys.has(key))abort('SUBMISSION_JSON_DUPLICATE_KEY');keys.add(key);ws();if(text[i++]!==':')abort('SUBMISSION_JSON_INVALID');value(depth+1);ws();if(text[i]==='}'){i++;return;}if(text[i++]!==',')abort('SUBMISSION_JSON_INVALID');}abort('SUBMISSION_JSON_INVALID');
  }else if(text[i]==='['){i++;ws();let count=0;if(text[i]===']'){i++;return;}while(i<text.length){if(++count>LIMITS.entries)abort('SUBMISSION_JSON_LIMIT');value(depth+1);ws();if(text[i]===']'){i++;return;}if(text[i++]!==',')abort('SUBMISSION_JSON_INVALID');}abort('SUBMISSION_JSON_INVALID');
  }else if(text[i]==='"')str();
  else{const token=text.slice(i).match(/^(?:true|false|null|-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?)/);if(!token)return abort('SUBMISSION_JSON_INVALID');i+=token[0].length;}
 }
 try{
  if(typeof text!=='string')abort('SUBMISSION_JSON_INVALID');if(Buffer.byteLength(text)>LIMITS.bytes)abort('SUBMISSION_JSON_LIMIT');
  value(0);ws();if(i!==text.length)abort('SUBMISSION_JSON_INVALID');
  const decoded=JSON.parse(text),problem=inputProblem(decoded);if(problem)abort(problem.code==='INPUT_LIMIT'?'SUBMISSION_JSON_LIMIT':'SUBMISSION_JSON_INVALID');return {valid:true,value:decoded};
 }catch(error){const e=error as {code?: string};const code=['SUBMISSION_JSON_INVALID','SUBMISSION_JSON_LIMIT','SUBMISSION_JSON_DUPLICATE_KEY'].includes(e?.code??'')?e.code!: 'SUBMISSION_JSON_INVALID';r.diagnostic(code,path,'Encoded answer JSON is malformed, ambiguous or exceeds resource limits.','Supply bounded JSON with unique exact answer identities.');return {valid:false};}
}
