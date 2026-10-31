// Offline artifact generator for one complete IELTS Academic Reading section (13 questions).
// Deterministic: no network, no provider, no clock dependence.
import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const dir = fileURLToPath(new URL('.', import.meta.url));
const passage = readFileSync(new URL('./passage.md', import.meta.url), 'utf8').trim();

const examId = 'a0000000-0000-4000-8000-000000000001';
const sectionId = 'b0000000-0000-4000-8000-000000000001';
const passageId = 'b1000000-0000-4000-8000-000000000001';
const groupIds = [1, 2, 3].map((n) => `c0000000-0000-4000-8000-00000000000${n}`);
const qid = (n) => `d0000000-0000-4000-8000-0000000000${String(n).padStart(2, '0')}`;
let optionCounter = 0;
const oid = () => `e0000000-0000-4000-8000-00000000${String(++optionCounter).padStart(4, '0')}`;

const choice = (correct) => [
  { id: oid(), idx: 1, contentMd: 'True', isCorrect: correct === 'True' },
  { id: oid(), idx: 2, contentMd: 'False', isCorrect: correct === 'False' },
  { id: oid(), idx: 3, contentMd: 'Not Given', isCorrect: correct === 'Not Given' },
];

const tfng = [
  {
    idx: 1,
    correct: 'True',
    promptMd: 'The urban heat island effect was first described systematically in the early twentieth century.',
    explanationMd: 'Paragraph A: "The effect was described systematically in the early twentieth century". The statement agrees with the passage.',
  },
  {
    idx: 2,
    correct: 'False',
    promptMd: 'Rural areas sometimes have higher temperatures than the cities immediately next to them.',
    explanationMd: 'Paragraph C states that rural areas lose heat quickly while cities cool slowly, and paragraph A reports a city-rural temperature gap. The statement contradicts the passage.',
  },
  {
    idx: 3,
    correct: 'True',
    promptMd: 'Satellite measurements record surface temperatures rather than air temperatures at street level.',
    explanationMd: 'Paragraph E: "Satellites record the temperature of surfaces rather than the air that people experience at street level". The statement agrees with the passage.',
  },
  {
    idx: 4,
    correct: 'Not Given',
    promptMd: 'Researchers have agreed on a single definition of the urban heat island.',
    explanationMd: 'Paragraph A introduces the term but the passage never reports agreement or disagreement about definitions, so the statement is not given.',
  },
  {
    idx: 5,
    correct: 'False',
    promptMd: 'The greatest health risks associated with urban heat occur during the daytime.',
    explanationMd: 'Paragraph C: "most heat-related deaths in cities occur in the small hours of the morning". The statement contradicts the passage.',
  },
  {
    idx: 6,
    correct: 'True',
    promptMd: 'Some cities have begun to require reflective surfaces in new commercial developments.',
    explanationMd: 'Paragraph F: "Some cities have begun to require reflective surfaces in new commercial developments". The statement agrees with the passage.',
  },
];

const headingBank = [
  { label: 'i', text: 'What the satellites can and cannot see' },
  { label: 'ii', text: 'Living with the heat after sunset' },
  { label: 'iii', text: 'Why cities are warmer than farmland' },
  { label: 'iv', text: 'The long history of a modern problem' },
];

const headingTargets = [
  { idx: 7, target: '7. Paragraph B', key: 'iii', text: 'Why cities are warmer than farmland' },
  { idx: 8, target: '8. Paragraph C', key: 'ii', text: 'Living with the heat after sunset' },
  { idx: 9, target: '9. Paragraph E', key: 'i', text: 'What the satellites can and cannot see' },
];

const summaryBlank = [
  { idx: 10, blank: '1', accept: ['roof'], prompt: 'the [1] surface' },
  { idx: 11, blank: '2', accept: ['cheaper'], prompt: 'are [2] to install' },
  { idx: 12, blank: '3', accept: ['mature'], prompt: 'many years to [3]' },
  { idx: 13, blank: '4', accept: ['whole cities', 'entire cities'], prompt: 'rather than across [4]' },
];

const questions = [];

for (const item of tfng) {
  questions.push({
    id: qid(item.idx),
    sectionId,
    groupId: groupIds[0],
    idx: item.idx,
    type: 'TRUE_FALSE_NOT_GIVEN',
    skill: 'READING',
    difficulty: 2,
    promptMd: item.promptMd,
    explanationMd: item.explanationMd,
    options: choice(item.correct),
  });
}

for (const item of headingTargets) {
  questions.push({
    id: qid(item.idx),
    sectionId,
    groupId: groupIds[1],
    idx: item.idx,
    type: 'MATCHING_HEADING',
    skill: 'READING',
    difficulty: 3,
    promptMd: [
      'Choose the correct heading for each paragraph from the List of Headings below.',
      '',
      'List of Headings:',
      ...headingBank.map((h) => `${h.label}. ${h.text}`),
      '',
      item.target,
    ].join('\n'),
    explanationMd: `Paragraph ${item.target.slice(-1)} is best summarised by heading ${item.key}. ${item.text}.`,
    options: headingBank.map((h, i) => ({ id: oid(), idx: i + 1, contentMd: `${h.label}. ${h.text}`, isCorrect: false })),
    matchPairs: { [String(item.idx)]: [item.key, item.text] },
  });
}

const summaryPrompt = [
  'Complete the summary below.',
  '',
  'Cities have tried a number of ways of reducing urban heat. Green roofs lower the temperature of the [1] surface, but they have only a small effect on air temperature at street level. Roofs painted with reflective material are [2] to install and can be used on buildings that already exist. Street trees provide shade and cool the surrounding air, but they need space, water and many years to [3]. Critics argue that most of these measures have been tested on individual buildings rather than across [4].',
].join('\n');

const blankAcceptTexts = {};
for (const item of summaryBlank) blankAcceptTexts[item.blank] = item.accept;

questions.push({
  id: qid(10),
  sectionId,
  groupId: groupIds[2],
  idx: 10,
  type: 'SUMMARY_COMPLETION',
  skill: 'READING',
  difficulty: 3,
  promptMd: summaryPrompt,
  explanationMd: 'The summary is drawn from paragraph F (green roofs, reflective roofs, street trees) and paragraph G (critics testing measures on individual buildings rather than across whole cities).',
  options: [],
  blankAcceptTexts,
});

const exam = {
  id: examId,
  title: 'IELTS Academic Reading - Section 1: The Urban Heat Island',
  slug: 'ielts-academic-reading-section-1-urban-heat-island',
  category: 'IELTS_ACADEMIC_READING',
  level: 'B2_C1',
  complete: true,
  expectedQuestionCount: 13,
  sections: [
    {
      id: sectionId,
      idx: 1,
      examId,
      title: 'The Urban Heat Island',
      instructionsMd:
        'The passage below is about the urban heat island. Read it carefully and answer Questions 1-13.',
      passageMd: passage,
      questionGroups: [
        {
          id: groupIds[0],
          idx: 1,
          sectionId,
          startIdx: 1,
          endIdx: 6,
          instructionMd:
            'Do the following statements agree with the information given in the passage? Write True, False or Not Given.',
          questions: questions.filter((q) => q.idx <= 6),
        },
        {
          id: groupIds[1],
          idx: 2,
          sectionId,
          startIdx: 7,
          endIdx: 9,
          instructionMd:
            'The passage has seven paragraphs, A-G. Choose the correct heading for paragraphs B, C and E from the List of Headings below. Each heading may be used only once; one heading is not needed.',
          questions: questions.filter((q) => q.idx >= 7 && q.idx <= 9),
        },
        {
          id: groupIds[2],
          idx: 3,
          sectionId,
          startIdx: 10,
          endIdx: 13,
          instructionMd: 'Write no more than two words for each answer.',
          questions: questions.filter((q) => q.idx >= 10),
        },
      ],
    },
  ],
};

// Evidence spans: exact quotations located in the passage text.
const quotes = {
  1: ['The effect was described systematically in the early twentieth century'],
  2: ['Rural areas, by contrast, lose their heat quickly once the sun goes down.'],
  3: ['Satellites record the temperature of surfaces rather than the air that people experience at street level'],
  4: ['The difference is known as the urban heat island'],
  5: ['most heat-related deaths in cities occur in the small hours of the morning'],
  6: ['Some cities have begun to require reflective surfaces in new commercial developments'],
  7: ['Waste heat from vehicles, factories, air conditioners and street lighting is released directly into the open air.'],
  8: ['so cities cool far more slowly than the countryside'],
  9: ['Air temperature is normally measured at a height of two metres inside a shaded screen'],
  10: ['Green roofs, planted with low-growing species such as sedum, can lower the temperature of a roof surface considerably'],
  11: ['Roofs painted with reflective material are cheaper to install and can be applied to buildings that already exist.'],
  12: ['they need space, water and many years to mature'],
  13: ['most have been tested on individual buildings rather than across whole cities'],
};

const evidence = {};
for (const [idx, list] of Object.entries(quotes)) {
  evidence[idx] = list.map((quote) => {
    const start = passage.indexOf(quote);
    if (start < 0) throw new Error(`Quote not found for question ${idx}: ${quote}`);
    return { sourceId: passageId, questionId: qid(Number(idx)), start, end: start + quote.length, quote };
  });
}

writeFileSync(new URL('./exam.json', import.meta.url), `${JSON.stringify(exam, null, 2)}\n`);
writeFileSync(new URL('./evidence.json', import.meta.url), `${JSON.stringify({ passageId, passage, evidence }, null, 2)}\n`);
console.log(`questions=${questions.length} passageChars=${passage.length}`);
