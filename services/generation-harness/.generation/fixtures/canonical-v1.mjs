import { families } from '../reading/contracts.ts';
import { vs2Exam, uuid } from './reading.mjs';

// Synthetic shape fixtures only: no production keys, media or semantic-quality claim.
export function canonicalQuestion(type, idx = 1) {
  const family = families[type];
  const q = { id: uuid(idx), sectionId: 's1', groupId: 'g1', idx, type, skill: 'READING', difficulty: 2, promptMd: 'What does the passage describe?', options: [] };
  const options = labels => labels.map((contentMd, i) => ({ id: uuid(1000 + idx * 10 + i), idx: i + 1, contentMd, isCorrect: family === 'single' ? i === 0 : family === 'multiple' ? i < 2 : false }));
  if (family === 'single' || family === 'multiple') {
    q.options = options(type === 'TRUE_FALSE_NOT_GIVEN' ? ['True', 'False', 'Not Given'] : type === 'YES_NO_NOT_GIVEN' ? ['Yes', 'No', 'Not Given'] : ['River', 'Forest', 'Desert']);
    if (family === 'multiple') q.promptMd = 'Choose TWO answers.';
    if (type === 'MULTIPLE_CHOICE_SINGLE_IMAGE') q.options.forEach((o,i) => Object.assign(o, { imageUrl: `fixtures/authorized-${i}.svg`, altText: `Synthetic option ${i}` }));
  } else if (family === 'completion') {
    q.promptMd = 'Write ONE WORD ONLY. Water comes from the [1].';
    if (type === 'TABLE_COMPLETION') q.promptMd = 'Write ONE WORD ONLY.\n| Source | Answer |\n| --- | --- |\n| Water | [1] |';
    if (type === 'NOTE_COMPLETION') q.promptMd = 'Write ONE WORD ONLY.\n- Source: [1]';
    if (type === 'FORM_COMPLETION') q.promptMd = 'Write ONE WORD ONLY.\nSource: [1]';
    if (type === 'DIAGRAM_LABEL' || type === 'MAP_LABEL') q.imageUrl = 'fixtures/authorized-labels.svg';
    q.blankAcceptTexts = { '1': ['river'] };
  } else if (family === 'matching') {
    const headings = type === 'MATCHING_HEADING';
    q.options = options(headings ? ['i. Water', 'ii. Food', 'iii. Travel'] : type === 'MATCHING_INFORMATION' ? ['A. Paragraph A', 'B. Paragraph B', 'C. Paragraph C'] : ['A. Water', 'B. Food', 'C. Travel']);
    q.promptMd = `${headings ? 'List of Headings:\ni. Water\nii. Food\niii. Travel\n' : ''}You may use any letter more than once.\n1. Target one\n2. Target two`;
    q.matchPairs = { '1': [headings ? 'i' : 'A', headings ? 'Water' : 'Target one'], '2': [headings ? 'ii' : 'B', headings ? 'Food' : 'Target two'] };
  } else if (family === 'flow') {
    q.promptMd = 'Arrange the public process nodes.';
    q.orderCorrects = ['collect-water', 'heat-water'];
  } else {
    q.promptMd = 'Write ONE WORD ONLY. What supplies the water?';
    q.shortAnswerAcceptTexts = ['river'];
  }
  return q;
}

export function canonicalPilot() {
  const exam = vs2Exam();
  for (const s of exam.sections) for (const g of s.questionGroups) for (const q of g.questions) {
    // Explicit fixture adapter, not a production importer or key repair.
    delete q.modelAnswers;
    Object.assign(q, { sectionId: s.id, skill: 'READING', difficulty: 2 });
    if (q.type === 'TRUE_FALSE_NOT_GIVEN') for (const o of q.options) o.contentMd = { TRUE: 'True', FALSE: 'False', 'NOT GIVEN': 'Not Given' }[o.contentMd];
  }
  return exam;
}
