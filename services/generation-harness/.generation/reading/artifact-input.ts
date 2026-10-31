import { open } from 'node:fs/promises';
import { resolve } from 'node:path';
import { LIMITS,object,own } from './support.ts';

export const fileReference={type:'object',properties:{file:{type:'string',minLength:1},pointer:{type:'string',pattern:'^(?:/(?:[^~]|~[01])*)*$'}},required:['file'],additionalProperties:false,
 description:'Read a saved artifact instead of retransmitting it: {file:"exam.json",pointer:"/sections/0/questionGroups/0/questions/0"}. RFC 6901 pointer; omit for the JSON root. For passage only, omit pointer to read exact UTF-8 text. Paths are relative to tool cwd. Files are read anew, never cached.'};

// Extension input convenience only: canonical validators still receive the exact, unmodified value.
// No coercion, wrapper repair, searching, implicit defaults, artifact cache or recursive references.
export async function artifactInput(value: unknown,cwd: string,text=false): Promise<unknown> {
 if(!object(value)||!own(value,'file'))return value;
 if(Object.keys(value).some(k=>!['file','pointer'].includes(k))||typeof value.file!=='string'||!value.file.trim()||
  (own(value,'pointer')&&(typeof value.pointer!=='string'||!new RegExp(fileReference.properties.pointer.pattern).test(value.pointer))))throw Error('ARTIFACT_REFERENCE_INVALID');
 const handle=await open(resolve(cwd,value.file),'r');let content: string;
 try{
  const stat=await handle.stat();if(!stat.isFile()||stat.size>LIMITS.bytes)throw Error('ARTIFACT_INPUT_LIMIT');
  // Bound the read even if the file grows after stat.
  const buffer=Buffer.alloc(stat.size+1);let length=0;
  while(length<buffer.length){const {bytesRead}=await handle.read(buffer,length,buffer.length-length,length);if(!bytesRead)break;length+=bytesRead;}
  if(length>stat.size)throw Error('ARTIFACT_CHANGED_DURING_READ');content=buffer.subarray(0,length).toString('utf8');
 }finally{await handle.close();}
 if(text&&!own(value,'pointer'))return content;
 let node: unknown=JSON.parse(content);
 for(const encoded of (value.pointer??'').split('/').slice(1)){
  const key=encoded.replaceAll('~1','/').replaceAll('~0','~');
  if(node===null||typeof node!=='object'||!own(node,key)||(Array.isArray(node)&&!/^(0|[1-9][0-9]*)$/.test(key)))throw Error('ARTIFACT_POINTER_MISSING');
  node=(node as Record<string,unknown>)[key];
 }
 return node;
}
