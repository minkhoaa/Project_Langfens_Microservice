import type { CanonicalContext, CanonicalRecord, Report, Status } from '../types.ts';
import { asciiFold,at } from '../support.ts';
const numbers: Record<string, number>={one:1,two:2,three:3,four:4,five:5,six:6,seven:7,eight:8,nine:9,ten:10};
export function runChoiceRule(id: string,c: CanonicalContext,r: Report,q: CanonicalRecord,path: string): Status {
 const provenance=`${c.schema.$id}#/x-langfens/semanticRules/${id}`,start=r.mark();
 if(id==='CHOICE'){
  const seen=new Map<string,CanonicalRecord>();q.options.forEach((o: CanonicalRecord,i: number)=>{
   const key=asciiFold(o.contentMd),previous=seen.get(key);
   if(previous){r.diagnostic('OPTION_CONTENT_DUPLICATE',at(at(at(path,'options'),i),'contentMd'),'Option text collides with another option.','Use distinct option content.',undefined,'FAIL',id);
    if(previous.isCorrect!==o.isCorrect)r.diagnostic('DISTRACTOR_KEY_CONFLICT',at(at(path,'options'),i),'A distractor collides with a correct option.','Replace the conflicting distractor.',undefined,'FAIL',id);
   }else seen.set(key,o);
  });
  r.pending('CHOICE_NORMALIZATION_UNVERIFIED',at(path,'options'),'Full .NET Unicode trimming/case equivalence has not been executed.',id);
 }else if(id==='MULTIPLE_SELECTION_COUNT'){
  const counts=[...q.promptMd.matchAll(/\b(?:choose|select|pick)\s+(?:exactly\s+)?(\d+|one|two|three|four|five|six|seven|eight|nine|ten)\s+(?:answers?|options?|letters?)\b/gi)].map(m=>numbers[m[1].toLowerCase()]??Number(m[1]));
  if(counts.length===0 || new Set(counts).size!==1){r.pending('CHOICE_COUNT_INSTRUCTION_UNVERIFIED',at(path,'promptMd'),'Selection count is absent or ambiguous.',id,'State one unambiguous number of options to select.');}
  else if(counts[0]!==q.options.filter((o: CanonicalRecord)=>o.isCorrect).length)r.diagnostic('CHOICE_COUNT_INSTRUCTION_MISMATCH',at(path,'promptMd'),'Stated selection count differs from the correct-option count.','Make the instruction and private key cardinality agree.',undefined,'FAIL',id);
 }else{
  r.pending('TRUTH_AMBIGUOUS',at(path,'promptMd'),'Fact/view distinction and proposition truth require independent passage review.',id);
  r.pending('NOT_GIVEN_ABSENCE_UNVERIFIED',path,'No independent evidence establishes absence of the relevant proposition.',id);
 }
 const status=r.statusSince(start);
 const shape=status==='FAIL'||status==='ERROR'?status:id==='MULTIPLE_SELECTION_COUNT'||id==='TRUTH_EVIDENCE'?status:'PASS';
 r.check(`${id}.shape`,shape,provenance,path);
 r.check(id,status,provenance,path);
 return shape;
}
