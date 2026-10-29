import './offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { traceMetrics } from '../.generation/evaluation/contract-trace-metrics.mjs';
const trace = (id,args=[{question:{idx:'1'}},{question:{idx:'1'}}]) => [{type:'session',id},...args.flatMap((arguments_,i)=>[
  {type:'message',message:{role:'assistant',content:[{type:'toolCall',id:`c${i}`,name:'validate_question',arguments:arguments_}]}},
  {type:'message',message:{role:'toolResult',toolCallId:`c${i}`,toolName:'validate_question',isError:true,content:[{type:'text',text:'INPUT_SCHEMA_INVALID'}]}}
])].map(e=>JSON.stringify(e)).join('\n');
test('trace metrics deduplicate result IDs and separate local repeats from pooled repeats',()=>{
  const a={path:'a',text:trace('s1')},b={path:'b',text:trace('s2',[{question:{idx:'1'}}])};
  const r=traceMetrics([a,a,b]);
  assert.equal(r.uniqueCalls,3); assert.equal(r.uniqueResults,3); assert.equal(r.schemaFailures,3);
  assert.equal(r.withinSessionRepeatedCalls,1); assert.equal(r.pooledStructuralRepeats,2);
  assert.equal(r.inferenceTokenSavings,'NOT_MEASURED');
});
