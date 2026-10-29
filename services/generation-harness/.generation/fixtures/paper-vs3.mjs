// Offline fixture construction only, not a generation pipeline or production rotation.
import { readFileSync } from "node:fs";
import { uuid, vs2Exam, vs2Evidence, vs2Answers } from "./reading.mjs";
export const vs3Blueprint = JSON.parse(readFileSync(new URL("./blueprint-vs3.json", import.meta.url), "utf8"));

const seedParagraphs = [
  "A. The Alder Valley seed archive began as a village exchange in 1982. Farmers donated envelopes of beans and barley because commercial catalogues no longer listed several local varieties. The founders recorded the donor and the collection site for every sample. Their aim was to preserve regional crop diversity, not to sell improved seed to international companies.",
  "B. Before storage, technicians dry the seeds in a chamber containing silica gel. They then seal each batch in foil packets and place the packets in freezers. Drying slows chemical reactions inside the seed, while the sealed packaging prevents moisture from returning. The archive uses no chemical pesticides during this preparation stage.",
  "C. Storage alone cannot guarantee survival. Every five years, technicians place a small selection of seeds on damp paper and count the seedlings. If fewer than eighty percent germinate, the remaining stock is planted in an isolated field. Pollination is controlled there to prevent mixing between varieties, and the fresh harvest replaces the ageing batch.",
  "D. The archive sends duplicate packets to a partner collection in another valley as insurance against fire. Local schools may request small educational samples without charge. Farmers receiving larger quantities agree to return seed after harvest. A public catalogue lists collection sites, but the donors' home addresses are kept confidential. Volunteers update the catalogue each winter."
];
const soundParagraphs = [
  "A. Urban sound should be treated as an ecological resource rather than merely a nuisance, argues researcher Mira Chen. A single average noise reading cannot describe the experience of a square: the same reading may represent a fountain or an engine. Planners should therefore record the sources of sounds as well as their intensity. Chen rejects the idea that every public place ought to be silent.",
  "B. Chen's team asked residents to carry recorders along fixed walking routes. Participants annotated moments they found welcoming or stressful. The recordings were collected in spring and autumn, not throughout the year. Near a tram stop, residents valued the bell because it warned them of approaching vehicles. The team published anonymised route maps but withheld recordings containing identifiable conversations.",
  "C. A trial courtyard used a planted screen to separate benches from a delivery lane. Microphones showed little reduction in average sound levels, yet interviews recorded a marked improvement in comfort. Chen attributes this partly to the screen hiding the vehicles. She warns that planting is not a substitute for reducing hazardous exposure, and says that visual design and acoustic measurement answer different questions.",
  "D. The next trial will compare morning deliveries with afternoon deliveries at the same courtyard. Shopkeepers will keep diaries to record delays, while residents will describe interruptions to their activities. Chen argues that a successful policy must consider both groups. She does not promise a universal noise threshold: the purpose of a place should guide the interpretation of its measurements."
];
export const vs3Passages = [vs2Exam().sections[0].passageMd, seedParagraphs.join("\n\n"), soundParagraphs.join("\n\n")];

// Each row carries exactly one mark, one public question and one independently bound quotation.
// Matching choices are public in the instruction; matchPairs remain private grading data.
const rows = {
  14: ["matching", "Choose the best heading for paragraph A.", "ii", "The origin of a regional collection", seedParagraphs[0]],
  15: ["matching", "Choose the best heading for paragraph B.", "iv", "Preparing seeds for long storage", seedParagraphs[1]],
  16: ["matching", "Choose the best heading for paragraph C.", "i", "Testing and renewing ageing stocks", seedParagraphs[2]],
  17: ["matching", "Choose the best heading for paragraph D.", "v", "Sharing access while protecting the collection", seedParagraphs[3]],
  18: ["truth", "The archive was established to sell improved seeds internationally.", "FALSE", null, "Their aim was to preserve regional crop diversity, not to sell improved seed to international companies."],
  19: ["truth", "Chemical pesticides are used when preparing seeds for storage.", "FALSE", null, "The archive uses no chemical pesticides during this preparation stage."],
  20: ["truth", "The partner collection has more staff than the Alder Valley archive.", "NOT GIVEN", null, "The archive sends duplicate packets to a partner collection in another valley as insurance against fire."],
  21: ["completion", "Technicians use [21] gel to dry the seeds.", "silica", null, "technicians dry the seeds in a chamber containing silica gel"],
  22: ["completion", "Seeds are sealed in [22] packets before freezing.", "foil", null, "They then seal each batch in foil packets and place the packets in freezers."],
  23: ["completion", "The sealed packets stop [23] from returning.", "moisture", null, "the sealed packaging prevents moisture from returning"],
  24: ["short", "How often are germination tests performed? Write NO MORE THAN TWO WORDS.", "five years", null, "Every five years, technicians place a small selection of seeds on damp paper and count the seedlings."],
  25: ["short", "In what kind of field is replacement stock grown? Write NO MORE THAN TWO WORDS.", "isolated field", null, "the remaining stock is planted in an isolated field"],
  26: ["short", "In which season do volunteers update the catalogue? Write ONE WORD ONLY.", "winter", null, "Volunteers update the catalogue each winter."],
  27: ["truth", "Chen believes that planners should identify the sources of urban sounds.", "YES", null, "Planners should therefore record the sources of sounds as well as their intensity."],
  28: ["truth", "Chen thinks all public spaces should be silent.", "NO", null, "Chen rejects the idea that every public place ought to be silent."],
  29: ["truth", "Chen considers planting sufficient protection against dangerous sound exposure.", "NO", null, "She warns that planting is not a substitute for reducing hazardous exposure"],
  30: ["truth", "Chen believes that the next trial will cost less than the first trial.", "NOT GIVEN", null, "The next trial will compare morning deliveries with afternoon deliveries at the same courtyard."],
  31: ["matching", "Which paragraph mentions different sound sources producing the same average reading?", "A", "Paragraph A", "the same reading may represent a fountain or an engine"],
  32: ["matching", "Which paragraph explains why some recordings were not released?", "B", "Paragraph B", "withheld recordings containing identifiable conversations"],
  33: ["matching", "Which paragraph reports improved comfort without a large change in measured sound?", "C", "Paragraph C", "Microphones showed little reduction in average sound levels, yet interviews recorded a marked improvement in comfort."],
  34: ["matching", "Which paragraph describes a proposed comparison of delivery times?", "D", "Paragraph D", "The next trial will compare morning deliveries with afternoon deliveries at the same courtyard."],
  35: ["completion", "Residents followed fixed walking routes while carrying [35].", "recorders", null, "Chen's team asked residents to carry recorders along fixed walking routes."],
  36: ["completion", "A planted [36] separated the courtyard benches from a delivery lane.", "screen", null, "A trial courtyard used a planted screen to separate benches from a delivery lane."],
  37: ["completion", "Shopkeepers will record delays in [37].", "diaries", null, "Shopkeepers will keep diaries to record delays"],
  38: ["choice", "Why did residents value the tram bell?", "It warned them of approaching vehicles.", ["It made the square silent.", "It warned them of approaching vehicles.", "It measured traffic speed.", "It identified individual passengers."], "residents valued the bell because it warned them of approaching vehicles"],
  39: ["choice", "What partly explained the courtyard's improved comfort?", "Vehicles were hidden from view.", ["Average sound levels fell to zero.", "Deliveries were banned.", "Vehicles were hidden from view.", "All benches were removed."], "Chen attributes this partly to the screen hiding the vehicles."],
  40: ["choice", "According to Chen, how should planners interpret sound measurements?", "In relation to the purpose of the place.", ["Using one universal threshold.", "By ignoring residents' accounts.", "Only from night-time readings.", "In relation to the purpose of the place."], "the purpose of a place should guide the interpretation of its measurements"]
};
const typeFamilies = {
  MATCHING_HEADING: "matching", MATCHING_INFORMATION: "matching", MATCHING_FEATURES: "matching", MATCHING_ENDINGS: "matching", CLASSIFICATION: "matching",
  TRUE_FALSE_NOT_GIVEN: "truth", YES_NO_NOT_GIVEN: "truth", SUMMARY_COMPLETION: "completion", SENTENCE_COMPLETION: "completion", TABLE_COMPLETION: "completion", NOTE_COMPLETION: "completion", FORM_COMPLETION: "completion", SHORT_ANSWER: "short", MULTIPLE_CHOICE_SINGLE: "choice"
};
const headingInstructions = "Choose a heading for each paragraph. Headings: i Testing and renewing ageing stocks; ii The origin of a regional collection; iii Commercial seed pricing; iv Preparing seeds for long storage; v Sharing access while protecting the collection. Write the roman numeral.";
function instruction(type) {
  if (type === "MATCHING_HEADING") return headingInstructions;
  if (typeFamilies[type] === "matching") return "Choose paragraph A, B, C or D for each statement. You may use a letter more than once.";
  if (typeFamilies[type] === "truth") return type === "YES_NO_NOT_GIVEN" ? "Write YES, NO or NOT GIVEN according to the writer's views." : "Write TRUE, FALSE or NOT GIVEN according to the passage.";
  if (typeFamilies[type] === "completion") return "Choose ONE WORD ONLY from the passage for each answer.";
  if (type === "SHORT_ANSWER") return "Answer each question using the word limit stated in its prompt.";
  return "Choose one option for each question.";
}

export function vs3Fixture(blueprint = vs3Blueprint) {
  const paper = vs2Exam();
  // Section 1 is byte-for-byte the VS2 Section, including examId, group and option IDs.
  paper.title = "IELTS Academic Reading — deterministic full paper VS3";
  const evidence = [vs2Evidence()];
  const answers = vs2Answers();
  for (const config of blueprint.sections.filter(s => !s.preserveVs2)) {
    const sid = `s${config.idx}`, passageMd = vs3Passages[config.idx - 1];
    if (!passageMd) throw new Error("Fixture has no passage for selected section");
    const sectionEvidence = [];
    const questionGroups = config.groups.map((g, i) => {
      const gid = `${sid}-g${i + 1}`;
      const questions = Array.from({ length: g.count }, (_, offset) => {
        const idx = g.start + offset;
        const row = rows[idx];
        if (!row || row[0] !== typeFamilies[g.type]) throw new Error(`Fixture blueprint/data incompatibility at Q${idx}`);
        const [family, promptMd, key, display, quote] = row;
        const q = { id: uuid(idx), groupId: gid, idx, type: g.type, promptMd, options: [], explanationMd: `PRIVATE-VS3-S${config.idx}-Q${idx}: ${quote}`, modelAnswers: [key] };
        let answer;
        if (family === "truth" || family === "choice") {
          const labels = family === "choice" ? display : g.type === "YES_NO_NOT_GIVEN" ? ["YES", "NO", "NOT GIVEN"] : ["TRUE", "FALSE", "NOT GIVEN"];
          q.options = labels.map((contentMd, j) => ({ id: uuid(10000 + idx * 10 + j), idx: j + 1, contentMd, isCorrect: contentMd === key }));
          answer = { selectedOptionIds: q.options.filter(o => o.isCorrect).map(o => o.id) };
        } else if (family === "matching") {
          q.matchPairs = { [idx]: [key, display] };
          answer = { textAnswer: JSON.stringify({ [idx]: key }) };
        } else if (family === "completion") {
          q.blankAcceptTexts = { [idx]: [key] };
          answer = { textAnswer: JSON.stringify({ [idx]: key }) };
        } else {
          q.shortAnswerAcceptTexts = [key];
          answer = { textAnswer: key };
        }
        answers.push({ questionId: q.id, answer });
        const start = passageMd.indexOf(quote);
        if (start < 0) throw new Error(`Missing section evidence for Q${idx}`);
        sectionEvidence.push({ questionId: q.id, start, end: start + quote.length, quote });
        return q;
      });
      return { id: gid, sectionId: sid, idx: i + 1, startIdx: g.start, endIdx: g.start + g.count - 1, instructionMd: instruction(g.type), questions };
    });
    paper.sections.push({ id: sid, examId: paper.id, idx: config.idx, title: config.idx === 2 ? "The Alder Valley Seed Archive" : "Listening to the City", passageMd, questionGroups });
    evidence.push(sectionEvidence);
  }
  return { paper, evidence, answers, requirements: { sectionScoringUnits: [...blueprint.sectionScoringUnits], answerSlotCount: blueprint.answerSlotCount } };
}
