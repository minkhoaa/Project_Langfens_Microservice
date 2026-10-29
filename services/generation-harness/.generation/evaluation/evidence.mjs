import { createHash } from 'node:crypto';
import { readFile, realpath, stat } from 'node:fs/promises';
import { isAbsolute, relative, resolve, sep } from 'node:path';
export const sha256 = value => createHash('sha256').update(value).digest('hex');
export function manifestDigest(entries) {
  return sha256(JSON.stringify(entries.map(e=>({role:e.role,path:e.path,sha256:e.sha256,sessionId:e.sessionId??null})).sort((a,b)=>JSON.stringify(a)<JSON.stringify(b)?-1:JSON.stringify(a)>JSON.stringify(b)?1:0)));
}
export function manifestProblems(input) {
  const entries=input.manifest??[], problems=[];
  for(const role of ['assignment','prompt','rubric','canonical','projection','native_results','lifecycle','generator_raw','solver_raw','reviewer_raw','human_review']) {
    if(!entries.some(e=>e.role===role)) problems.push(`Missing manifest role: ${role}`);
  }
  if(new Set(entries.map(e=>e.path)).size!==entries.length) problems.push('Duplicate manifest paths');
  const calls=[{role:'generator_raw',...input.generator},...input.solverAnswers.map(x=>({role:'solver_raw',...x})),...input.reviews.map(x=>({role:'reviewer_raw',...x}))];
  for(const call of calls) if(!entries.some(e=>e.role===call.role && e.sessionId===call.sessionId && e.sha256===sha256(call.raw??''))) problems.push(`Unbound raw response: ${call.role}/${call.sessionId??'missing'}`);
  if(!input.protocolAudit || input.protocolAudit.manifestDigest!==manifestDigest(entries)) problems.push('Human audit is not bound to this manifest');
  return [...new Set(problems)];
}
// Reads only explicitly supplied run files, never credentials/global configuration.
export async function auditManifest(input, root) {
  const problems=manifestProblems(input);
  if(!root || problems.length) return {verdict:'UNCERTAIN',problems:root?problems:['Evidence root not supplied',...problems]};
  let base;
  try { base=await realpath(root); } catch { return {verdict:'UNCERTAIN',problems:['Evidence root unavailable']}; }
  for(const entry of input.manifest) {
    const escape=p=>p==='..' || p.startsWith(`..${sep}`) || isAbsolute(p);
    if(isAbsolute(entry.path) || escape(relative(base,resolve(base,entry.path)))) return {verdict:'FAIL',problems:['Evidence path escapes run root']};
    try {
      const file=await realpath(resolve(base,entry.path));
      if(escape(relative(base,file))) return {verdict:'FAIL',problems:['Evidence symlink escapes run root']};
      if(!(await stat(file)).isFile()) return {verdict:'FAIL',problems:['Evidence entry is not a file']};
      const bytes=await readFile(file);
      if(sha256(bytes)!==entry.sha256) return {verdict:'FAIL',problems:['Evidence digest mismatch']};
      if(entry.role==='rubric' && sha256(bytes)!==sha256(await readFile(new URL('./rubric.json',import.meta.url)))) return {verdict:'FAIL',problems:['Rubric revision mismatch']};
    } catch { return {verdict:'UNCERTAIN',problems:['Evidence file unavailable']}; }
  }
  return {verdict:'PASS',problems:[]};
}
