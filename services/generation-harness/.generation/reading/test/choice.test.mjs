import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { validateQuestion } from '../question.ts';
import { initialize,inspect,q,hasCode,check } from './helpers.mjs';
await initialize();
test('choice collisions and correct/distractor conflicts are diagnosed',()=>{
 const x=q('MULTIPLE_CHOICE_SINGLE');x.options[1].contentMd=' river ';
 const r=inspect(validateQuestion,x);assert.ok(hasCode(r,'OPTION_CONTENT_DUPLICATE'));assert.ok(hasCode(r,'DISTRACTOR_KEY_CONFLICT'));
});
test('explicit selection count must match private key cardinality',()=>{
 const x=q('MULTIPLE_CHOICE_MULTIPLE');x.promptMd='Choose THREE answers.';
 assert.ok(hasCode(inspect(validateQuestion,x),'CHOICE_COUNT_INSTRUCTION_MISMATCH'));
 for(const prompt of ['Choose TWO answers. Choose THREE answers.','Select whichever answers apply.']){x.promptMd=prompt;assert.ok(hasCode(inspect(validateQuestion,x),'CHOICE_COUNT_INSTRUCTION_UNVERIFIED'));}
 x.promptMd='Select 2 answers.';assert.equal(check(inspect(validateQuestion,x),'MULTIPLE_SELECTION_COUNT.shape'),'PASS');
});
test('truth label casing is exact but shape is not proof of proposition truth',()=>{
 const x=q('TRUE_FALSE_NOT_GIVEN');const r=inspect(validateQuestion,x);
 assert.ok(hasCode(r,'NOT_GIVEN_ABSENCE_UNVERIFIED'));assert.equal(check(r,'TRUTH_EVIDENCE'),'UNVERIFIED');
 x.options[0].contentMd='TRUE';assert.equal(inspect(validateQuestion,x).status,'FAIL');
});
test('broader Unicode equivalence is not inferred from JS case folding',()=>{
 const x=q('MULTIPLE_CHOICE_SINGLE');x.options[0].contentMd='İ';x.options[1].contentMd='i';
 const r=inspect(validateQuestion,x);assert.equal(hasCode(r,'OPTION_CONTENT_DUPLICATE'),false);assert.ok(hasCode(r,'CHOICE_NORMALIZATION_UNVERIFIED'));
});
