// Deterministic fixtures, not examples of real IELTS quality.
export const types = [
  "MULTIPLE_CHOICE_SINGLE", "MULTIPLE_CHOICE_MULTIPLE", "TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN", "MULTIPLE_CHOICE_SINGLE_IMAGE",
  "SUMMARY_COMPLETION", "TABLE_COMPLETION", "NOTE_COMPLETION", "FORM_COMPLETION", "SENTENCE_COMPLETION", "SHORT_ANSWER",
  "DIAGRAM_LABEL", "MAP_LABEL", "MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS", "CLASSIFICATION", "FLOW_CHART",
];
export const uuid = n => `00000000-0000-0000-0000-${String(n).padStart(12, "0")}`;
export function question(type, idx = 1, groupId = "g1") {
  const q = { id: uuid(idx), groupId, idx, type, promptMd: "The plants are watered every [1] days.", options: [], explanationMd: "PRIVATE-EXPLANATION-SENTINEL", modelAnswers: ["PRIVATE-MODEL-ANSWER-SENTINEL"] };
  if (["MULTIPLE_CHOICE_SINGLE", "MULTIPLE_CHOICE_MULTIPLE", "MULTIPLE_CHOICE_SINGLE_IMAGE", "TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"].includes(type)) {
    const labels = type === "TRUE_FALSE_NOT_GIVEN" ? ["TRUE", "FALSE", "NOT GIVEN"] : type === "YES_NO_NOT_GIVEN" ? ["YES", "NO", "NOT GIVEN"] : ["Two days", "Three days", "Four days"];
    q.promptMd = "How often are the plants watered?";
    q.options = labels.map((contentMd, i) => ({ id: uuid(1000 + idx * 10 + i), idx: i + 1, contentMd, isCorrect: i === 0 || (i === 1 && type === "MULTIPLE_CHOICE_MULTIPLE") }));
    if (type === "MULTIPLE_CHOICE_SINGLE_IMAGE") q.imageUrl = "fixtures/plant.svg";
  } else if (type === "SHORT_ANSWER") q.shortAnswerAcceptTexts = ["two"];
  else if (["MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS", "CLASSIFICATION"].includes(type)) {
    q.promptMd = "Match statement 1 to heading A (Watering) or B (Harvest).";
    q.matchPairs = { "1": ["A", "Watering"] };
  } else if (type === "FLOW_CHART") {
    q.promptMd = "Arrange nodes: water, plant, harvest.";
    q.orderCorrects = ["plant", "water", "harvest"];
  } else q.blankAcceptTexts = { "1": ["two"] };
  return q;
}
export function group(questions = [question("SUMMARY_COMPLETION")], id = "g1", sectionId = "s1") {
  return { id, sectionId, idx: 1, startIdx: questions[0]?.idx ?? 1, endIdx: questions.at(-1)?.idx ?? 1, instructionMd: "Write ONE WORD for each answer.", questions };
}
export const passageMd = "In the glasshouse, the plants are watered every two days. The harvest begins in June.";
export function exam(g = group()) {
  return { id: "e1", title: "Offline Reading fixture", sections: [{ id: "s1", examId: "e1", idx: 1, title: "Glasshouse", passageMd, questionGroups: [g] }] };
}
export function completeExam() {
  let idx = 1;
  return { id: "e1", title: "Complete offline paper", sections: [14, 13, 13].map((n, i) => {
    const sid = `s${i + 1}`, gid = `g${i + 1}`;
    const questions = Array.from({ length: n }, () => question("SUMMARY_COMPLETION", idx++, gid));
    return { id: sid, examId: "e1", idx: i + 1, title: sid, passageMd, questionGroups: [group(questions, gid, sid)] };
  }) };
}
export function correctAnswer(q) {
  if (q.options.length) return { selectedOptionIds: q.options.filter(o => o.isCorrect).map(o => o.id) };
  if (q.matchPairs) return { textAnswer: JSON.stringify(Object.fromEntries(Object.entries(q.matchPairs).map(([k, xs]) => [k, xs[0]]))) };
  if (q.orderCorrects) return { textAnswer: JSON.stringify(q.orderCorrects) };
  return { textAnswer: "two" };
}

export const vs2PassageMd = "The Barbegal aqueduct and mill complex is a Roman watermill installation located in southern France. Described as the greatest known concentration of mechanical power in the ancient world, the complex comprised sixteen overshot water wheels arranged in two parallel sets of eight down a steep hillside. Hydraulic engineers estimate that the facility could grind up to twenty-five tonnes of grain daily, enough to produce flour for the entire population of the nearby city of Arelate (modern Arles), which numbered approximately twelve thousand inhabitants in the second century AD.\n\nExcavations led by archaeologist Fernand Benoit in the late 1930s revealed that each mill race was driven by a single stone aqueduct that divided into two channels at the crest of the hill. Carbonate encrustations preserved on the surviving stonework indicate that the waterwheels operated almost continuously throughout the year, rather than intermittently or seasonally. A notable feature of the Barbegal mills was the use of wood for both the gears and axle shafts, while the flumes and retaining structures were constructed from dressed limestone blocks and hydraulic mortar.\n\nRecent isotopic analysis of the millstones has demonstrated that the basalt utilised in their manufacture originated from quarries in the Massif Central, nearly two hundred kilometres north of the site. This finding disproved earlier theories asserting that local limestone was used for the grindstones. Transporting such dense volcanic stone over that distance required substantial logistical organisation, suggesting that the Roman imperial state played a direct role in funding and managing the complex. Furthermore, researchers found no evidence of slave quarters near the mills, leading social historians to conclude that the workforce was composed of free paid labourers who resided in adjacent farming settlements.";

export function vs2Exam() {
  const g1Questions = [
    {
      id: uuid(1), groupId: "g1", idx: 1, type: "TRUE_FALSE_NOT_GIVEN",
      promptMd: "The Barbegal complex contained sixteen water wheels arranged in four equal rows.",
      options: [
        { id: uuid(101), idx: 1, contentMd: "TRUE", isCorrect: false },
        { id: uuid(102), idx: 2, contentMd: "FALSE", isCorrect: true },
        { id: uuid(103), idx: 3, contentMd: "NOT GIVEN", isCorrect: false },
      ],
      explanationMd: "The complex comprised sixteen overshot water wheels arranged in two parallel sets of eight, not four rows.",
      modelAnswers: ["FALSE"],
    },
    {
      id: uuid(2), groupId: "g1", idx: 2, type: "TRUE_FALSE_NOT_GIVEN",
      promptMd: "The flour produced at Barbegal was sufficient to feed the entire population of Arelate.",
      options: [
        { id: uuid(104), idx: 1, contentMd: "TRUE", isCorrect: true },
        { id: uuid(105), idx: 2, contentMd: "FALSE", isCorrect: false },
        { id: uuid(106), idx: 3, contentMd: "NOT GIVEN", isCorrect: false },
      ],
      explanationMd: "Hydraulic engineers estimate the facility could grind enough to produce flour for the entire population of the nearby city of Arelate.",
      modelAnswers: ["TRUE"],
    },
    {
      id: uuid(3), groupId: "g1", idx: 3, type: "TRUE_FALSE_NOT_GIVEN",
      promptMd: "The waterwheels at Barbegal operated only during the autumn harvest season.",
      options: [
        { id: uuid(107), idx: 1, contentMd: "TRUE", isCorrect: false },
        { id: uuid(108), idx: 2, contentMd: "FALSE", isCorrect: true },
        { id: uuid(109), idx: 3, contentMd: "NOT GIVEN", isCorrect: false },
      ],
      explanationMd: "Carbonate encrustations indicate that the waterwheels operated almost continuously throughout the year, rather than intermittently or seasonally.",
      modelAnswers: ["FALSE"],
    },
    {
      id: uuid(4), groupId: "g1", idx: 4, type: "TRUE_FALSE_NOT_GIVEN",
      promptMd: "The millstones at Barbegal were manufactured from local limestone.",
      options: [
        { id: uuid(110), idx: 1, contentMd: "TRUE", isCorrect: false },
        { id: uuid(111), idx: 2, contentMd: "FALSE", isCorrect: true },
        { id: uuid(112), idx: 3, contentMd: "NOT GIVEN", isCorrect: false },
      ],
      explanationMd: "Isotopic analysis disproved earlier theories asserting that local limestone was used for the grindstones, showing basalt was used instead.",
      modelAnswers: ["FALSE"],
    },
    {
      id: uuid(5), groupId: "g1", idx: 5, type: "TRUE_FALSE_NOT_GIVEN",
      promptMd: "The Roman imperial state levied a special tax on grain ground at Barbegal.",
      options: [
        { id: uuid(113), idx: 1, contentMd: "TRUE", isCorrect: false },
        { id: uuid(114), idx: 2, contentMd: "FALSE", isCorrect: false },
        { id: uuid(115), idx: 3, contentMd: "NOT GIVEN", isCorrect: true },
      ],
      explanationMd: "The passage mentions state management and funding, but there is no mention of a tax levied on grain.",
      modelAnswers: ["NOT GIVEN"],
    },
  ];

  const g2Questions = [
    {
      id: uuid(6), groupId: "g2", idx: 6, type: "SUMMARY_COMPLETION",
      promptMd: "Excavations in the late 1930s showed that water was supplied to the mill races by an [6] that split into two channels.",
      options: [],
      blankAcceptTexts: { "6": ["aqueduct"] },
      explanationMd: "Each mill race was driven by a single stone aqueduct that divided into two channels at the crest of the hill.",
      modelAnswers: ["aqueduct"],
    },
    {
      id: uuid(7), groupId: "g2", idx: 7, type: "SUMMARY_COMPLETION",
      promptMd: "Timber was chosen as the material for constructing both the axle shafts and the [7].",
      options: [],
      blankAcceptTexts: { "7": ["gears"] },
      explanationMd: "A notable feature was the use of wood for both the gears and axle shafts.",
      modelAnswers: ["gears"],
    },
    {
      id: uuid(8), groupId: "g2", idx: 8, type: "SUMMARY_COMPLETION",
      promptMd: "Scientific tests revealed that the millstones were cut from [8] sourced from the Massif Central.",
      options: [],
      blankAcceptTexts: { "8": ["basalt"] },
      explanationMd: "Recent isotopic analysis demonstrated that the basalt utilised in their manufacture originated from quarries in the Massif Central.",
      modelAnswers: ["basalt"],
    },
    {
      id: uuid(9), groupId: "g2", idx: 9, type: "SUMMARY_COMPLETION",
      promptMd: "Because no living quarters for enslaved people were found, experts believe the mill workers were [9] employees.",
      options: [],
      blankAcceptTexts: { "9": ["free", "paid"] },
      explanationMd: "Social historians concluded that the workforce was composed of free paid labourers.",
      modelAnswers: ["free"],
    },
  ];

  const g3Questions = [
    {
      id: uuid(10), groupId: "g3", idx: 10, type: "MULTIPLE_CHOICE_SINGLE",
      promptMd: "According to hydraulic engineers, how much grain could the Barbegal mill complex process per day?",
      options: [
        { id: uuid(116), idx: 1, contentMd: "twelve tonnes", isCorrect: false },
        { id: uuid(117), idx: 2, contentMd: "sixteen tonnes", isCorrect: false },
        { id: uuid(118), idx: 3, contentMd: "twenty-five tonnes", isCorrect: true },
        { id: uuid(119), idx: 4, contentMd: "two hundred tonnes", isCorrect: false },
      ],
      explanationMd: "The facility could grind up to twenty-five tonnes of grain daily.",
      modelAnswers: ["twenty-five tonnes"],
    },
    {
      id: uuid(11), groupId: "g3", idx: 11, type: "MULTIPLE_CHOICE_SINGLE",
      promptMd: "What physical evidence suggested that the Barbegal waterwheels operated year-round?",
      options: [
        { id: uuid(120), idx: 1, contentMd: "Carbonate encrustations", isCorrect: true },
        { id: uuid(121), idx: 2, contentMd: "Preserved hydraulic mortar", isCorrect: false },
        { id: uuid(122), idx: 3, contentMd: "Roman tax records", isCorrect: false },
        { id: uuid(123), idx: 4, contentMd: "Written diaries of Fernand Benoit", isCorrect: false },
      ],
      explanationMd: "Carbonate encrustations preserved on the surviving stonework indicate year-round operation.",
      modelAnswers: ["Carbonate encrustations"],
    },
    {
      id: uuid(12), groupId: "g3", idx: 12, type: "MULTIPLE_CHOICE_SINGLE",
      promptMd: "The distance from the basalt quarries to Barbegal indicated that",
      options: [
        { id: uuid(124), idx: 1, contentMd: "grain transport along the river was hazardous.", isCorrect: false },
        { id: uuid(125), idx: 2, contentMd: "the imperial administration participated in managing the facility.", isCorrect: true },
        { id: uuid(126), idx: 3, contentMd: "local stonemasons lacked quarrying skills.", isCorrect: false },
        { id: uuid(127), idx: 4, contentMd: "water levels in the aqueduct fluctuated severely.", isCorrect: false },
      ],
      explanationMd: "Logistics over two hundred kilometres suggested the Roman imperial state played a direct role in funding and managing the complex.",
      modelAnswers: ["the imperial administration participated in managing the facility."],
    },
    {
      id: uuid(13), groupId: "g3", idx: 13, type: "MULTIPLE_CHOICE_SINGLE",
      promptMd: "Social historians believe the workforce at Barbegal lived",
      options: [
        { id: uuid(128), idx: 1, contentMd: "in barracks inside the mill complex.", isCorrect: false },
        { id: uuid(129), idx: 2, contentMd: "in the port city of Massif Central.", isCorrect: false },
        { id: uuid(130), idx: 3, contentMd: "in neighboring agricultural communities.", isCorrect: true },
        { id: uuid(131), idx: 4, contentMd: "on transport barges on the river.", isCorrect: false },
      ],
      explanationMd: "Social historians concluded that the workforce resided in adjacent farming settlements.",
      modelAnswers: ["in neighboring agricultural communities."],
    },
  ];

  const g1 = {
    id: "g1", sectionId: "s1", idx: 1, startIdx: 1, endIdx: 5,
    instructionMd: "Do the following statements agree with the information given in Reading Passage 1? In boxes 1–5 on your answer sheet, write TRUE if the statement agrees with the information, FALSE if the statement contradicts the information, or NOT GIVEN if there is no information on this.",
    questions: g1Questions,
  };

  const g2 = {
    id: "g2", sectionId: "s1", idx: 2, startIdx: 6, endIdx: 9,
    instructionMd: "Complete the summary below. Choose ONE WORD ONLY from the passage for each answer. Write your answers in boxes 6–9 on your answer sheet.",
    questions: g2Questions,
  };

  const g3 = {
    id: "g3", sectionId: "s1", idx: 3, startIdx: 10, endIdx: 13,
    instructionMd: "Choose the correct letter, A, B, C or D. Write the correct letter in boxes 10–13 on your answer sheet.",
    questions: g3Questions,
  };

  return {
    id: "e-vs2",
    title: "IELTS Academic Reading Vertical Slice 2 — Offline Validated Section",
    sections: [
      {
        id: "s1", examId: "e-vs2", idx: 1,
        title: "The Roman Watermill Complex at Barbegal",
        passageMd: vs2PassageMd,
        questionGroups: [g1, g2, g3],
      },
    ],
  };
}

export function vs2Evidence() {
  const spans = [
    { questionId: uuid(1), quote: "sixteen overshot water wheels arranged in two parallel sets of eight" },
    { questionId: uuid(2), quote: "enough to produce flour for the entire population of the nearby city of Arelate" },
    { questionId: uuid(3), quote: "operated almost continuously throughout the year, rather than intermittently or seasonally" },
    { questionId: uuid(4), quote: "basalt utilised in their manufacture originated from quarries in the Massif Central, nearly two hundred kilometres north of the site. This finding disproved earlier theories asserting that local limestone was used" },
    { questionId: uuid(5), quote: "Roman imperial state played a direct role in funding and managing the complex" },
    { questionId: uuid(6), quote: "single stone aqueduct that divided into two channels" },
    { questionId: uuid(7), quote: "use of wood for both the gears and axle shafts" },
    { questionId: uuid(8), quote: "basalt utilised in their manufacture originated from quarries in the Massif Central" },
    { questionId: uuid(9), quote: "workforce was composed of free paid labourers who resided in adjacent farming settlements" },
    { questionId: uuid(10), quote: "grind up to twenty-five tonnes of grain daily" },
    { questionId: uuid(11), quote: "Carbonate encrustations preserved on the surviving stonework indicate that the waterwheels operated almost continuously throughout the year" },
    { questionId: uuid(12), quote: "Transporting such dense volcanic stone over that distance required substantial logistical organisation, suggesting that the Roman imperial state played a direct role in funding and managing the complex" },
    { questionId: uuid(13), quote: "resided in adjacent farming settlements" },
  ];
  return spans.map(s => {
    const start = vs2PassageMd.indexOf(s.quote);
    if (start === -1) throw new Error(`Evidence quote not found in vs2PassageMd: ${s.quote}`);
    return { questionId: s.questionId, start, end: start + s.quote.length, quote: s.quote };
  });
}

export function vs2Answers() {
  return [
    { questionId: uuid(1), answer: { selectedOptionIds: [uuid(102)] } },
    { questionId: uuid(2), answer: { selectedOptionIds: [uuid(104)] } },
    { questionId: uuid(3), answer: { selectedOptionIds: [uuid(108)] } },
    { questionId: uuid(4), answer: { selectedOptionIds: [uuid(111)] } },
    { questionId: uuid(5), answer: { selectedOptionIds: [uuid(115)] } },
    { questionId: uuid(6), answer: { textAnswer: '{"6":"aqueduct"}' } },
    { questionId: uuid(7), answer: { textAnswer: '{"7":"gears"}' } },
    { questionId: uuid(8), answer: { textAnswer: '{"8":"basalt"}' } },
    { questionId: uuid(9), answer: { textAnswer: '{"9":"free"}' } },
    { questionId: uuid(10), answer: { selectedOptionIds: [uuid(118)] } },
    { questionId: uuid(11), answer: { selectedOptionIds: [uuid(120)] } },
    { questionId: uuid(12), answer: { selectedOptionIds: [uuid(125)] } },
    { questionId: uuid(13), answer: { selectedOptionIds: [uuid(130)] } },
  ];
}
