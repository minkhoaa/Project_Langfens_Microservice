import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { Value } from 'typebox/value';
import reading from '../../extensions/reading.ts';
import { createReadingTools } from '../tools.ts';
import { callTool } from '../domain.ts';
import { vectors,q,hasCode } from './helpers.mjs';
import { createNativeFixture } from './native-helpers.mjs';

const families={
 create_single_choice:['MULTIPLE_CHOICE_SINGLE','TRUE_FALSE_NOT_GIVEN','YES_NO_NOT_GIVEN','MULTIPLE_CHOICE_SINGLE_IMAGE'],
 create_multiple_choice:['MULTIPLE_CHOICE_MULTIPLE'],
 create_completion:['SUMMARY_COMPLETION','TABLE_COMPLETION','NOTE_COMPLETION','FORM_COMPLETION','SENTENCE_COMPLETION','DIAGRAM_LABEL','MAP_LABEL'],
 create_matching:['MATCHING_HEADING','MATCHING_INFORMATION','MATCHING_FEATURES','MATCHING_ENDINGS','CLASSIFICATION'],
 create_short_answer:['SHORT_ANSWER'],create_flow_chart:['FLOW_CHART'],
};
function tools(){const definitions=[];reading({registerTool:d=>definitions.push(d)});return definitions;}
function input(name,type){
 const question=q(type),{skill,options,...args}=question;
 if(families[name].length===1)delete args.type;
 if(options.length)args.options=options.map(({idx,isCorrect,...option})=>name==='create_matching'?option:{...option,isCorrect});
 return args;
}
async function execute(name,args){const tool=tools().find(d=>d.name===name);assert.ok(tool,`${name} must be registered`);return (await tool.execute('creation',args)).structuredContent;}
function rejected(report,path){assert.equal(report.status,'FAIL');assert.equal(report.data?.question,undefined);assert.ok(report.diagnostics.some(d=>d.path===path),JSON.stringify(report.diagnostics));assert.ok(report.diagnostics.every(d=>d.suggestedCorrection));}

test('six native builders cover all 19 types without altering the seven existing declarations',async()=>{
 const definitions=tools();assert.equal(definitions.length,13);assert.equal(new Set(definitions.map(d=>d.name)).size,13);
 assert.equal(JSON.stringify(definitions.slice(0,7)),JSON.stringify(createReadingTools()));
 assert.equal(Object.values(families).flat().length,19);
 for(const [name,types] of Object.entries(families))for(const type of types){
  const args=input(name,type),before=structuredClone(args),tool=definitions.find(d=>d.name===name);
  assert.equal(Value.Check(tool.parameters,args),true,type);
  const native=await tool.execute(type,args),report=native.structuredContent;
  assert.equal(report.status,'UNVERIFIED',type);assert.equal(native.isError,false,type);
  assert.equal(report.data.validation.structuralValid,true,type);
  assert.deepEqual(report.data.question,q(type),type);assert.deepEqual(args,before);
  assert.deepEqual(report.diagnostics,callTool('validate_question',{question:report.data.question}).diagnostics,type);
  assert.deepEqual(native.details,report);assert.deepEqual(JSON.parse(native.content[0].text),report);
  const missingAnswer=structuredClone(args);delete missingAnswer[args.options?'options':name==='create_completion'?'blankAcceptTexts':name==='create_short_answer'?'shortAnswerAcceptTexts':'orderCorrects'];
  rejected((await tool.execute(type,missingAnswer)).structuredContent,args.options?'/options':name==='create_completion'?'/blankAcceptTexts':name==='create_short_answer'?'/shortAnswerAcceptTexts':'/orderCorrects');
 }
});
test('builders generate only local option identities, contiguous indices and contract-safe empty banks',async()=>{
 const args=input('create_single_choice','MULTIPLE_CHOICE_SINGLE');args.options.forEach(o=>delete o.id);
 const a=await execute('create_single_choice',args),b=await execute('create_single_choice',args);
 assert.deepEqual(a,b);assert.deepEqual(a.data.question.options.map(o=>({id:o.id,idx:o.idx})),args.options.map((_,i)=>({id:`${args.id}:option:${i+1}`,idx:i+1})));
 assert.equal(a.data.question.skill,'READING');
 for(const [name,type] of [['create_completion','SENTENCE_COMPLETION'],['create_short_answer','SHORT_ANSWER'],['create_flow_chart','FLOW_CHART']])assert.deepEqual((await execute(name,input(name,type))).data.question.options,[]);
 const matching=await execute('create_matching',input('create_matching','CLASSIFICATION'));assert.ok(matching.data.question.options.every(o=>o.isCorrect===false));
});
test('builders reject malformed, coerced, unsupported and unrelated fields with actionable paths',async()=>{
 const name='create_single_choice',valid=input(name,'MULTIPLE_CHOICE_SINGLE');
 for(const [patch,path] of [[{idx:'1'},'/idx'],[{difficulty:0},'/difficulty'],[{id:' '},'/id'],[{sectionId:null},'/sectionId'],[{promptMd:''},'/promptMd'],[{type:'SHORT_ANSWER'},'/type'],[{options:[{contentMd:'x',isCorrect:'true'}]},'/options/0/isCorrect']])rejected(await execute(name,{...valid,...patch}),path);
 const missing={...valid};delete missing.promptMd;rejected(await execute(name,missing),'/promptMd');
 for(const args of [null,[],{...valid,PRIVATE_SENTINEL:'PRIVATE_SENTINEL'},{...valid,evidence:{quote:'PRIVATE_SENTINEL'}}]){
  const report=await execute(name,args);rejected(report,'/');assert.equal(JSON.stringify(report).includes('PRIVATE_SENTINEL'),false);
 }
 const getter={...valid};Object.defineProperty(getter,'promptMd',{enumerable:true,get(){throw Error('PRIVATE_SENTINEL');}});
 for(const args of [getter,{...valid,promptMd:'x'.repeat(2_000_001)}])rejected(await execute(name,args),'/');
});
test('canonical structural and semantic failures withhold artifacts rather than repairing answers',async()=>{
 const cases=[
  ['create_single_choice','MULTIPLE_CHOICE_SINGLE',a=>a.options.forEach(o=>o.isCorrect=false),'/question/options'],
  ['create_single_choice','MULTIPLE_CHOICE_SINGLE',a=>a.options[1].contentMd=a.options[0].contentMd,'/question/options/1/contentMd'],
  ['create_single_choice','MULTIPLE_CHOICE_SINGLE',a=>a.options[1].id=a.options[0].id,'/question/options/1/id'],
  ['create_single_choice','TRUE_FALSE_NOT_GIVEN',a=>a.options[0].contentMd='TRUE','/question/options/0/contentMd'],
  ['create_single_choice','MULTIPLE_CHOICE_SINGLE_IMAGE',a=>{delete a.imageUrl;a.options.forEach(o=>{delete o.imageUrl;delete o.altText;});},'/question'],
  ['create_multiple_choice','MULTIPLE_CHOICE_MULTIPLE',a=>a.promptMd='Choose THREE answers.','/question/promptMd'],
  ['create_completion','SENTENCE_COMPLETION',a=>a.promptMd='Use ONE WORD. Missing [999].','/question/promptMd'],
  ['create_completion','DIAGRAM_LABEL',a=>delete a.imageUrl,'/question/imageUrl'],
  ['create_completion','MAP_LABEL',a=>delete a.imageUrl,'/question/imageUrl'],
  ['create_matching','MATCHING_FEATURES',a=>Object.values(a.matchPairs)[0][0]='Z','/question/matchPairs/1'],
 ];
 for(const [name,type,mutate,path] of cases){const args=input(name,type);mutate(args);rejected(await execute(name,args),path);}
 const flow=input('create_flow_chart','FLOW_CHART');flow.orderCorrects[1]=flow.orderCorrects[0];rejected(await execute('create_flow_chart',flow),'/orderCorrects');
 const short=input('create_short_answer','SHORT_ANSWER');short.shortAnswerAcceptTexts=[];rejected(await execute('create_short_answer',short),'/shortAnswerAcceptTexts');
});
test('optional canonical fields and supplied media/regex are preserved, never inferred',async()=>{
 const short=input('create_short_answer','SHORT_ANSWER');short.shortAnswerAcceptRegex=['^supplied$'];short.groupId='supplied-group';short.explanationMd='Supplied private explanation.';
 const report=await execute('create_short_answer',short);assert.equal(report.data.question.groupId,'supplied-group');assert.deepEqual(report.data.question.shortAnswerAcceptRegex,['^supplied$']);assert.ok(hasCode(report,'DOTNET_REGEX_PARITY_UNVERIFIED'));
 const completion=input('create_completion','SENTENCE_COMPLETION');completion.blankAcceptRegex=Object.fromEntries(Object.keys(completion.blankAcceptTexts).map(k=>[k,['^supplied$']]));
 assert.deepEqual((await execute('create_completion',completion)).data.question.blankAcceptRegex,completion.blankAcceptRegex);
 const unsupported=input('create_short_answer','SHORT_ANSWER');unsupported.blankAcceptTexts={'1':['invented']};rejected(await execute('create_short_answer',unsupported),'/');
});
test('all 13 tools are callable through native loading; builders reject before coercion without retries',async t=>{
 const f=await createNativeFixture(t,{loading:'explicit'});assert.equal(f.definitions.length,13);
 for(const [name,types] of Object.entries(families))for(const type of types){const native=await f.invoke(name,input(name,type));assert.equal(native.isError,false,type);assert.equal(native.structuredContent.data.question.type,type);assert.deepEqual(native.structuredContent,native.details);}
 for(const name of Object.keys(families)){
  const native=await f.invoke(name,{...input(name,families[name][0]),idx:'1'});rejected(native.structuredContent,'/idx');assert.equal(native.isError,true);assert.deepEqual(JSON.parse(native.content[0].text),native.details);
 }
 assert.equal(f.faux.state.callCount,(19+6)*2);
 const tool=tools().find(d=>d.name==='create_short_answer'),controller=new AbortController();controller.abort();
 const cancelled=await tool.execute('cancel',input('create_short_answer','SHORT_ANSWER'),controller.signal);assert.equal(cancelled.structuredContent.status,'ERROR');assert.ok(hasCode(cancelled.structuredContent,'EXECUTION_ABORTED'));
});
