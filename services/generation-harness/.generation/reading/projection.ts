import type { CanonicalContext, CanonicalRecord, Report } from './types.ts';
import { structural,own,at,keysEqual } from './support.ts';
import { validateQuestion } from './question.ts';
import { readBlankMarkers } from './rules/completion.ts';
import { readMatchingPresentation } from './rules/matching.ts';
const privateField=/(?:["'](?:blankAcceptTexts|blankAcceptRegex|shortAnswerAcceptTexts|shortAnswerAcceptRegex|matchPairs|orderCorrects|isCorrect|explanationMd|modelAnswers|evidence|reviews?)["']\s*:)/i;
const privateHeader=/(?:^|[\n.!?][ \t]*)(?:(?:\*\*|__|\*|_)[ \t]*)?(?<header>(?:the\s+)?(?:answer\s+keys?|answers?|keys?|correct\s+answers?|correct\s+order|teacher\s+notes?|solutions?))\s*(?:(?:\*\*|__|\*|_)\s*)?[:=]\s*(?:(?:\*\*|__|\*|_)\s*)?(?<value>[^\n]*)/gim;
const benignTaskDirection=/^(?:write\s+no\s+more\s+than\s+(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten)\s+words?(?:\s+only)?(?:\s+for\s+each\s+answer)?|use\s+(?:(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)\s+words?\s+only\s+for\s+each\s+answer|no\s+more\s+than\s+(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten)\s+words?(?:\s+only)?(?:\s+for\s+each\s+answer)?)|respond\s+in\s+one\s+sentence|complete\s+the\s+sentences?\s+using\s+the\s+passage)\.?$/i;
const stripPresentationPrefix=/^[ \t]*(?:>[ \t]*)*(?:#{1,6}[ \t]+)?(?:(?:[-*+]|[0-9]{1,9}[.)])[ \t]+)?[ \t]*/;
function privateAnnotation(text: string): boolean {
 if(privateField.test(text))return true;
 const normalized=text.split('\n').map(line=>line.replace(stripPresentationPrefix,'')).join('\n');
 for(const match of normalized.matchAll(privateHeader)){
  const header=match.groups?.header?.replace(/^the\s+/i,'').toLowerCase();
  if((header==='answer'||header==='answers')&&benignTaskDirection.test(match.groups?.value?.trim()??''))continue;
  return true;
 }
 return false;
}
function allow(value: CanonicalRecord,properties: CanonicalRecord): CanonicalRecord{const publicValue: CanonicalRecord={};for(const key of Object.keys(properties))if(own(value,key))Object.defineProperty(publicValue,key,{value:structuredClone(value[key]),enumerable:true,writable:true,configurable:true});return publicValue;}
export function inspectProjection(c: CanonicalContext,r: Report,q: CanonicalRecord): CanonicalRecord {
 const summary=validateQuestion(c,r,q),provenance=`${c.schema.$id}#/x-langfens/semanticRules/PROJECTION`;
 const base={inputIdentities:[],fieldPrivacyStatus:'UNVERIFIED',semanticPrivacyStatus:'UNVERIFIED',consumerCompatibility:'UNVERIFIED'};
 if(!summary.structuralValid)return base;
 const student=allow(q,c.schema.$defs.StudentQuestion.properties);
 // flowChartNodes is not a private canonical field; no solution-ordered array is copied.
 student.options=q.options.map((o: CanonicalRecord)=>allow(o,c.schema.$defs.PublicOption.properties));
 const scan=(v: unknown,path: string)=>{
  if(typeof v==='string'){if(privateAnnotation(v))r.diagnostic('STUDENT_ANSWER_HINT',path,'Public content contains an explicit private-answer annotation.','Remove private answer annotations from public content.',undefined,'FAIL','PROJECTION');return;}
  if(Array.isArray(v)){v.forEach((item,i)=>scan(item,at(path,i)));return;}
  if(v&&typeof v==='object')for(const [key,item] of Object.entries(v as CanonicalRecord))scan(item,at(path,key));
 };
 scan(student,'/question');
 let ids: {kind: string; id: string}[]=[];
 if(summary.family==='single'||summary.family==='multiple')ids=student.options.map((o: CanonicalRecord)=>({kind:'option',id:o.id}));
 else if(summary.family==='completion'){
  const markers=readBlankMarkers(student.promptMd);ids=markers.ids.map(id=>({kind:'blank',id}));
  if(markers.malformed||markers.duplicateIds.length||!keysEqual(markers.ids,Object.keys(q.blankAcceptTexts)))r.diagnostic('PUBLIC_FIELD_DROPPED','/question/promptMd','Public blank identities do not match required input slots.','Author exact visible blank markers.',undefined,'FAIL','PROJECTION');
 }else if(summary.family==='short')ids=[{kind:'short',id:student.id}];
 else if(summary.family==='matching'){
  const {targets}=readMatchingPresentation(c,q);ids=targets.map(t=>({kind:'target',id:t.id}));
  if(!keysEqual(targets.map(t=>t.id),Object.keys(q.matchPairs)))r.diagnostic('PUBLIC_FIELD_DROPPED','/question/promptMd','Visible target identities do not match required inputs.','Author exact public statements; never recover them from private pairs.',undefined,'FAIL','PROJECTION');
 }else{
  const nodes=[...student.promptMd.matchAll(/^\s*-\s+([a-z0-9]+(?:-[a-z0-9]+)*):\s*([^\n]+)$/gm)].map(m=>({key:m[1],label:m[2].trim()}));
  if(!keysEqual(nodes.map(n=>n.key),q.orderCorrects)||nodes.some(n=>!n.label)){
   r.pending('FLOW_PUBLIC_NODES_UNAVAILABLE','/question/promptMd','Explicit public flow labels are unavailable or do not match the node key set.','FLOW_ORDERING','Author public - key: label lines without revealing the solution order.');
   r.check('PROJECTION','UNVERIFIED',provenance,'/question','projection');return base;
  }
  student.flowChartNodes=nodes.sort((a: {key: string},b: {key: string})=>a.key<b.key?-1:a.key>b.key?1:0);scan(student.flowChartNodes,at('/question','flowChartNodes'));ids=student.flowChartNodes.map((n: {key: string})=>({kind:'node',id:n.key}));
 }
 const valid=structural(c,r,student,'#/$defs/StudentQuestion','/question','STUDENT_STRUCTURE');
 const failed=r.result.status==='FAIL'||r.result.status==='ERROR';
 r.check('PROJECTION_FIELDS',valid&&!failed?'PASS':'FAIL',provenance,'/question','projection');
 r.pending('STUDENT_SEMANTIC_PRIVACY_UNVERIFIED','/question','Field allowlisting cannot establish absence of encoded or semantic answer hints.','PROJECTION');
 r.pending('BLIND_ISOLATION_UNVERIFIED','/question','Public projection and fresh context are not OS filesystem isolation.','COMPATIBILITY');
 r.check('PROJECTION','UNVERIFIED',provenance,'/question','projection');
 return {...base,fieldPrivacyStatus:valid&&!failed?'PASS':'FAIL',...(!failed&&valid?{studentQuestion:student,inputIdentities:ids}:{})};
}
