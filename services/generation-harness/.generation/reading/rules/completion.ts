import type { CanonicalContext, CanonicalRecord, Report, Status } from '../types.ts';
import { at,keysEqual } from '../support.ts';
export function readBlankMarkers(promptMd: string): {ids: string[]; duplicateIds: string[]; malformed: boolean} {
 const ids=[...promptMd.matchAll(/\[([1-9][0-9]*)\]/g)].map(m=>m[1]);
 const seen=new Set(),duplicateIds=[];for(const id of ids){if(seen.has(id))duplicateIds.push(id);seen.add(id);}
 return {ids,duplicateIds,malformed:/_{2,}|\[\s+[0-9]+\s*\]|\[[0-9]+\s+\]|\[0[0-9]*\]|\[blank-q[^\]]*\]|\[[1-9][0-9]*\]\s*(?:to|[-–—])\s*\[[1-9][0-9]*\]/i.test(promptMd)};
}
export function runCompletionRule(id: string,c: CanonicalContext,r: Report,q: CanonicalRecord,path: string): Status {
 const provenance=`${c.schema.$id}#/x-langfens/semanticRules/${id}`,start=r.mark();
 let shape: Status='PASS';
 if(id==='BLANKS'){
  const markers=readBlankMarkers(q.promptMd),keys=Object.keys(q.blankAcceptTexts);
  if(markers.duplicateIds.length)r.diagnostic('BLANK_MARKER_DUPLICATE',at(path,'promptMd'),'A blank marker occurs more than once.','Use one explicit marker per blank.',undefined,'FAIL',id);
  if(markers.malformed || !keysEqual(markers.ids,keys))r.diagnostic('BLANK_MARKER_KEY_MISMATCH',at(path,'promptMd'),'Explicit markers and accepted-text keys do not agree.','Author each [N] marker once; preserve independent blank IDs.',undefined,'FAIL',id);
  for(const k of new Set([...keys,...Object.keys(q.blankAcceptRegex??{})]))if(BigInt(k)>9223372036854775807n)r.diagnostic('BLANK_KEY_OVERFLOW',at(path,'blankAcceptTexts'),'A blank ID exceeds positive signed Int64.','Use a positive decimal identity within signed Int64.', '9223372036854775807','FAIL',id);
  for(const k of Object.keys(q.blankAcceptRegex??{}))if(!Object.hasOwn(q.blankAcceptTexts,k))r.diagnostic('REGEX_KEY_WITHOUT_TEXT',at(at(path,'blankAcceptRegex'),k),'Regex-bearing blank has no accepted text.','Supply accepted text for this exact blank ID.',undefined,'FAIL',id);
  if(!/\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten)\s+(?:words?|numbers?)\b/i.test(q.promptMd))r.diagnostic('WORD_LIMIT_MISSING',at(path,'promptMd'),'No explicit word/number limit is recognizable.','State an explicit answer word/number limit.',undefined,'FAIL',id);
  r.pending('WORD_LIMIT_PROFILE_UNVERIFIED',path,'Accepted-answer word counting requires an independently tested counting convention.',id);
 }else if(id==='COMPLETION_LAYOUT'){
  const p=q.promptMd;
  const valid=q.type==='TABLE_COMPLETION'?/^\s*\|?.*\|.*\n\s*\|?\s*:?-{3,}/m.test(p):q.type==='NOTE_COMPLETION'?/^\s*[-*+]\s+.+\[[1-9][0-9]*\]/m.test(p):q.type==='FORM_COMPLETION'?/^[^\n:]+:\s*[^\n]*\[[1-9][0-9]*\]/m.test(p):true;
  if(!valid){shape='UNVERIFIED';r.pending('COMPLETION_LAYOUT_UNVERIFIED',at(path,'promptMd'),'This layout presentation cannot be established by the supported mechanical parser.',id,'Supply independent rendering evidence or use a recognizable public layout.');}
  r.pending('LAYOUT_RENDERING_UNVERIFIED',at(path,'promptMd'),'Renderer input reachability, Markdown behavior and coherent content require independent review.',id);
 }else if(id==='REGEX'){
  if(q.blankAcceptRegex || q.shortAnswerAcceptRegex)r.pending('DOTNET_REGEX_PARITY_UNVERIFIED',path,'Actual .NET regex syntax, anchoring and normalization have not been executed.',id);
  else r.check('REGEX.patterns','PASS',provenance,path);
  r.pending('DOTNET_NORMALIZATION_UNVERIFIED',path,'Actual .NET answer normalization has not been executed.',id);
 }else if(id==='SHORT_INPUT'){
  r.pending('SHORT_INPUT_UNREACHABLE',path,'One marker-free text input is required; actual renderer reachability is unverified.',id);
 }else if(id==='MEDIA'){
  r.pending('MEDIA_ASSET_UNVERIFIED',path,'Asset accessibility, authorization, content and consumer propagation are unverified.',id);
 }else{
  r.pending('LABEL_ALIGNMENT_UNVERIFIED',path,'Image callouts and answer-input alignment require image and consumer evidence.',id);
 }
 const status=r.statusSince(start);
 if(status==='FAIL'||status==='ERROR')shape=status;
 else if(id!=='COMPLETION_LAYOUT')shape=status;
 r.check(`${id}.shape`,shape,provenance,path);
 r.check(id,status,provenance,path);
 return shape;
}
