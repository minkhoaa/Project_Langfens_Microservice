import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { callTool } from '../domain.ts';
import { initialize,q,hasCode,check } from './helpers.mjs';
await initialize();

test('P1-03 composed Markdown wrappers cannot hide private annotations in public fields',()=>{
 const prefixes=['- > ','1. > ## ','> - > ### ','## > - ','  + > 2) > ','> '.repeat(64)];
 for(const prefix of prefixes)for(const field of ['promptMd','option','wordList']){
  const x=q('MATCHING_INFORMATION'),text=prefix+'**Answer key:** PRIVATE_SENTINEL';
  if(field==='option')x.options[0].contentMd=text;else if(field==='wordList')x.wordList=[text];else x.promptMd+='\n'+text;
  const r=callTool('inspect_delivery_projection',{question:x});
  assert.ok(hasCode(r,'STUDENT_ANSWER_HINT'),`${prefix} ${field}`);
  assert.equal(r.data.studentQuestion,undefined);assert.equal(JSON.stringify(r).includes('PRIVATE_SENTINEL'),false);
 }
 for(const prefix of prefixes){
  const x=q('SHORT_ANSWER');x.promptMd=prefix+'Answers: Use ONE WORD ONLY for each answer.';
  assert.ok(callTool('inspect_delivery_projection',{question:x}).data.studentQuestion);
 }
});
test('P1-11 legacy heading header without a colon retains exact bank checks',()=>{
 for(const header of ['List of Headings','List of Headings:','  List of Headings  ','LIST OF HEADINGS','Choose a heading. List of Headings:']){
  const x=q('MATCHING_HEADING');x.promptMd=x.promptMd.replace('List of Headings:',header);
  const r=callTool('validate_question',{question:x});assert.equal(hasCode(r,'HEADING_BANK_MISSING'),false,header);
  x.promptMd=x.promptMd.replace('iii.','iv.');assert.ok(hasCode(callTool('validate_question',{question:x}),'HEADING_BANK_MISSING'));
 }
});
test('P2-08 Which TWO/THREE counts participate in cardinality and conflict detection',()=>{
 const x=q('MULTIPLE_CHOICE_MULTIPLE');
 for(const prompt of ['Which TWO features are mentioned?','Which 2 statements are true?','Choose TWO answers. Which two features are mentioned?']){
  x.promptMd=prompt;assert.equal(check(callTool('validate_question',{question:x}),'MULTIPLE_SELECTION_COUNT.shape'),'PASS',prompt);
 }
 x.promptMd='Which THREE features are mentioned?';assert.ok(hasCode(callTool('validate_question',{question:x}),'CHOICE_COUNT_INSTRUCTION_MISMATCH'));
 x.promptMd='Choose TWO answers. Which THREE features are mentioned?';assert.equal(check(callTool('validate_question',{question:x}),'MULTIPLE_SELECTION_COUNT.shape'),'UNVERIFIED');
});
