import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { validateQuestion } from '../question.ts';
import { initialize,inspect,q,hasCode,check } from './helpers.mjs';
await initialize();
test('classification preserves statement 23 without requiring an unused category',()=>{
 const x=q('CLASSIFICATION');x.promptMd='Classify each statement.\n23. River transport';x.matchPairs={'23':['A','River transport']};x.options=[{id:'a',idx:1,contentMd:'A. Natural',isCorrect:false},{id:'b',idx:2,contentMd:'B. Artificial',isCorrect:false}];
 assert.notEqual(inspect(validateQuestion,x).status,'FAIL');
 x.matchPairs={'22':['Z','Wrong']};const r=inspect(validateQuestion,x);assert.ok(hasCode(r,'MATCH_TARGET_KEY_MISMATCH'));assert.ok(hasCode(r,'MATCH_BANK_KEY_UNKNOWN'));
});
test('matching targets bank keys display labels duplicates and distractors are joined exactly',()=>{
 const x=q('MATCHING_FEATURES');x.matchPairs['2']=['Z','Wrong'];let r=inspect(validateQuestion,x);assert.ok(hasCode(r,'MATCH_BANK_KEY_UNKNOWN'));assert.ok(hasCode(r,'MATCH_DISPLAY_INVALID'));
 x.options[1].contentMd=x.options[0].contentMd;assert.ok(hasCode(inspect(validateQuestion,x),'MATCH_BANK_LABEL_DUPLICATE'));
 const y=q('MATCHING_FEATURES');y.matchPairs['3']=['C','Third'];y.promptMd+='\n3. Third';assert.ok(hasCode(inspect(validateQuestion,y),'MATCH_DISTRACTOR_MISSING'));
 y.promptMd+='\n3. Duplicate';assert.ok(hasCode(inspect(validateQuestion,y),'MATCH_TARGET_KEY_MISMATCH'));
});
test('permitted reuse is not mandatory but used reuse needs permission',()=>{
 const x=q('MATCHING_FEATURES');assert.equal(hasCode(inspect(validateQuestion,x),'FEATURE_REUSE_INSTRUCTION_MISMATCH'),false);
 x.matchPairs['2'][0]='A';x.promptMd='1. Target one\n2. Target two';assert.ok(hasCode(inspect(validateQuestion,x),'FEATURE_REUSE_INSTRUCTION_MISMATCH'));
 x.promptMd='You may use any letter more than once.\n'+x.promptMd;assert.equal(hasCode(inspect(validateQuestion,x),'FEATURE_REUSE_INSTRUCTION_MISMATCH'),false);
 for(const type of ['MATCHING_HEADING','MATCHING_ENDINGS']){const y=q(type);y.matchPairs['2'][0]=y.matchPairs['1'][0];assert.ok(hasCode(inspect(validateQuestion,y),type==='MATCHING_HEADING'?'HEADING_REUSED':'ENDING_REUSED'));}
});
test('heading banks are complete and information word lists stay unsupported data',()=>{
 const x=q('MATCHING_HEADING');assert.equal(check(inspect(validateQuestion,x),'HEADING.shape'),'PASS');x.promptMd=x.promptMd.replace('iii. Travel\n','');assert.ok(hasCode(inspect(validateQuestion,x),'HEADING_BANK_MISSING'));
 const y=q('MATCHING_INFORMATION');y.wordList=['river'];assert.ok(hasCode(inspect(validateQuestion,y),'WORD_BANK_UNSUPPORTED'));
 y.options[0].contentMd='A. Not a paragraph';assert.ok(hasCode(inspect(validateQuestion,y),'PARAGRAPH_BANK_INVALID'));
});
test('FLOW_CHART is ordering and reports source divergence without completion substitution',()=>{
 const x=q('FLOW_CHART');const r=inspect(validateQuestion,x);assert.ok(hasCode(r,'SOURCE_CONTRACT_DIVERGENCE'));assert.equal(hasCode(r,'FLOW_COMPLETION_UNSUPPORTED'),false);
 x.orderCorrects=['same','same'];assert.equal(inspect(validateQuestion,x).status,'FAIL');
 x.orderCorrects={Steps:['a','b']};assert.equal(inspect(validateQuestion,x).status,'FAIL');
});
