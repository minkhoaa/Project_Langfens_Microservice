import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
const stable = x => x && typeof x === 'object' ? Array.isArray(x) ? `[${x.map(stable).join(',')}]` : `{${Object.keys(x).sort().map(k=>`${JSON.stringify(k)}:${stable(x[k])}`).join(',')}}` : JSON.stringify(x);
const hash = x => createHash('sha256').update(x).digest('hex');
const names = new Set(['get_question_spec','validate_question','validate_group','validate_exam','verify_evidence','check_grading_parity','inspect_delivery_projection']);
export function traceMetrics(traces) {
  const calls = new Map(), results = new Map(), sessions = new Set(), artifacts = [];
  let malformedLines = 0, unidentifiedMessages = 0;
  for (const {path, text} of traces) {
    artifacts.push({path,sha256:hash(text),bytes:Buffer.byteLength(text)});
    let sessionId;
    for (const line of text.split('\n').filter(Boolean)) {
      let e; try { e = JSON.parse(line); } catch { malformedLines++; continue; }
      if (e.type === 'session' && e.id) { sessionId=e.id; sessions.add(sessionId); }
      const m = e.message;
      if (!m) continue;
      if (!sessionId) { unidentifiedMessages++; continue; }
      if (m.role === 'assistant' && Array.isArray(m.content)) for (const c of m.content) {
        if (c.type === 'toolCall' && names.has(c.name)) calls.set(`${sessionId}/${c.id}`,{sessionId,name:c.name,args:c.arguments});
      }
      if (m.role === 'toolResult' && names.has(m.toolName)) results.set(`${sessionId}/${m.toolCallId}`,{sessionId,name:m.toolName,isError:!!m.isError,schemaFailure:JSON.stringify(m.content).includes('INPUT_SCHEMA_INVALID')});
    }
  }
  const within = new Set(), pooled = new Set(); let withinSessionRepeatedCalls=0, pooledStructuralRepeats=0;
  for (const c of calls.values()) {
    const signature = stable([c.name,c.args]), local=`${c.sessionId}/${signature}`;
    if (within.has(local)) withinSessionRepeatedCalls++; else within.add(local);
    if (pooled.has(signature)) pooledStructuralRepeats++; else pooled.add(signature);
  }
  return {artifacts,sessions:sessions.size,uniqueCalls:calls.size,uniqueResults:results.size,schemaFailures:[...results.values()].filter(r=>r.schemaFailure).length,nativeSchemaErrors:[...results.values()].filter(r=>r.schemaFailure && r.isError).length,schemaDiagnosticResults:[...results.values()].filter(r=>r.schemaFailure && !r.isError).length,toolErrors:[...results.values()].filter(r=>r.isError).length,withinSessionRepeatedCalls,pooledStructuralRepeats,malformedLines,unidentifiedMessages,inferenceTokenSavings:'NOT_MEASURED',method:'Deduplicate session-id/tool-call-id; exact tool-name + stable-key-order arguments. Within-session repeated calls and pooled structural repeats have different denominators. Retries/artifact revisions are not inferred from repeated calls.'};
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const [out,...paths]=process.argv.slice(2);
  if (!out || !paths.length) throw Error('Usage: node contract-trace-metrics.mjs NEW-OUT.json EXPLICIT-SESSION.jsonl ...');
  const result=traceMetrics(paths.map(path=>({path,text:readFileSync(path,'utf8')})));
  writeFileSync(out,JSON.stringify(result,null,2)+'\n',{flag:'wx',mode:0o600});
  console.log(JSON.stringify({...result,artifacts:result.artifacts.length},null,2));
}
