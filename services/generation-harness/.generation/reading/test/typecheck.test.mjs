import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { fileURLToPath } from 'node:url';

test('Reading TypeScript implementation passes the existing strict compiler settings',async()=>{
 const root=new URL('../../../',import.meta.url);
 const result=await promisify(execFile)(process.execPath,[fileURLToPath(new URL('node_modules/typescript/bin/tsc',root)),'--project',fileURLToPath(new URL('../tsconfig.json',import.meta.url))],{cwd:fileURLToPath(root),env:{...process.env,GENERATION_HARNESS_OFFLINE:'1'}}).catch(e=>({code:e.code,stdout:e.stdout,stderr:e.stderr}));
 assert.equal(result.code??0,0,result.stdout+result.stderr);
});
