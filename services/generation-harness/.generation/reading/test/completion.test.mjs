import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { validateQuestion } from '../question.ts';
import { initialize,inspect,q,hasCode,check } from './helpers.mjs';
await initialize();
test('blank IDs are independent of idx and require exact unique public markers',()=>{
 const x=q('SENTENCE_COMPLETION');x.idx=7;x.promptMd='ONE WORD ONLY. [23] and [25].';x.blankAcceptTexts={'23':['river'],'25':['forest']};
 assert.notEqual(inspect(validateQuestion,x).status,'FAIL');
 x.promptMd+=' Again [23].';assert.ok(hasCode(inspect(validateQuestion,x),'BLANK_MARKER_DUPLICATE'));
 for(const prompt of ['ONE WORD ONLY. [24].','ONE WORD ONLY. [ 23 ] and [25].','ONE WORD ONLY. ___[23] and [25].','ONE WORD ONLY. [23] to [25].','ONE WORD ONLY. [023] and [25].','ONE WORD ONLY. [blank-q23] and [25].']){x.promptMd=prompt;assert.equal(inspect(validateQuestion,x).status,'FAIL',prompt);}
});
test('blank Int64 limits accepted texts regex subset and word-limit uncertainty',()=>{
 const x=q('SENTENCE_COMPLETION');x.blankAcceptTexts={'9223372036854775807':['wide']};x.promptMd='ONE WORD ONLY. [9223372036854775807].';
 assert.notEqual(inspect(validateQuestion,x).status,'FAIL');
 x.blankAcceptTexts={'9223372036854775808':['wide']};x.promptMd='ONE WORD ONLY. [9223372036854775808].';assert.ok(hasCode(inspect(validateQuestion,x),'BLANK_KEY_OVERFLOW'));
 x.blankAcceptTexts={'23':['very wide river']};x.promptMd='River [23].';x.blankAcceptRegex={'25':['(']};
 const r=inspect(validateQuestion,x);for(const code of ['WORD_LIMIT_MISSING','REGEX_KEY_WITHOUT_TEXT','DOTNET_REGEX_PARITY_UNVERIFIED'])assert.ok(hasCode(r,code),code);
 x.promptMd='ONE WORD ONLY. [23].';delete x.blankAcceptRegex;assert.ok(hasCode(inspect(validateQuestion,x),'WORD_LIMIT_PROFILE_UNVERIFIED'));
});
test('layout checks recognize table note form without certifying Markdown rendering',()=>{
 for(const type of ['TABLE_COMPLETION','NOTE_COMPLETION','FORM_COMPLETION']){
  assert.equal(check(inspect(validateQuestion,q(type)),'COMPLETION_LAYOUT.shape'),'PASS');
  const x=q(type);x.promptMd='ONE WORD ONLY. [1].';assert.ok(hasCode(inspect(validateQuestion,x),'COMPLETION_LAYOUT_UNVERIFIED'));
 }
});
test('option-only media and marker-free short answer preserve their families',()=>{
 const x=q('MULTIPLE_CHOICE_SINGLE_IMAGE');assert.notEqual(inspect(validateQuestion,x).status,'FAIL');
 assert.ok(hasCode(inspect(validateQuestion,x),'MEDIA_ASSET_UNVERIFIED'));delete x.options[0].altText;assert.equal(inspect(validateQuestion,x).status,'FAIL');
 const s=inspect(validateQuestion,q('SHORT_ANSWER'));assert.equal(s.data.answerSlots,1);assert.ok(hasCode(s,'SHORT_INPUT_UNREACHABLE'));
 for(const type of ['DIAGRAM_LABEL','MAP_LABEL']){const r=inspect(validateQuestion,q(type));assert.ok(hasCode(r,'LABEL_ALIGNMENT_UNVERIFIED'));}
});
test('answer regexes are never executed with JavaScript and normalization is unverified',()=>{
 for(const pattern of ['(', '(?<name>river)', '(?>river)', '^(a+)+$']){const x=q('SENTENCE_COMPLETION');x.blankAcceptRegex={'1':[pattern]};const r=inspect(validateQuestion,x);assert.ok(hasCode(r,'DOTNET_REGEX_PARITY_UNVERIFIED'));assert.equal(hasCode(r,'DOTNET_REGEX_INVALID'),false);}
});
