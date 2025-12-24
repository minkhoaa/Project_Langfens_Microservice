-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T13:45:01.489858
-- Source: mini-ielts.com
-- Title: Fishbourne Roman Palace
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-fishbourne-roman-palace
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-fishbourne-roman-palace'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-fishbourne-roman-palace';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-fishbourne-roman-palace';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-fishbourne-roman-palace';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-fishbourne-roman-palace',
    'Fishbourne Roman Palace',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMs3esdOebUyoyO--kmRXeGL5g7ee-iluYxvXT75EuCNAhRLiix2iblM8cfzAp8GROAB0&usqp=CAU',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Fishbourne Roman Palace',
    E'**Questions 1-6:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 7-13:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.',
    E'**Paragraph A.**\\nFishbourne Roman Palace is in the village of Fishbourne in West Sussex, England. This large palace was built in the 1st century AD, around thirty years after the Roman conquest of Britain ,on the site of Roman army grain stores which had been established after the invasion, in the reign of the Roman Emperor Claudius in 43 AD. The rectangular palace was built around formal gardens, the northern half of which have been reconstructed. There were extensive alterations in the 2nd and 3rd centuries AD, with many of the original black and white mosaic floors being overlaid with more sophisticated coloured ones , including a perfectly preserved mosaic of a dolphin in the north wing. More alterations were in progress when the palace burnt down in around 270 AD, after which it was abandoned.\\n\\n**Paragraph B.**\\nLocal people had long believed that a Roman palace once existed in the area .However, it was not until 1960 that the archaeologist Barry Cunliffe, of Oxford University, first systematically excavated the site, after workmen had accidentally uncovered a wall while they were laying a water main .The Roman villa excavated by Cunliffe''s team was so grand that it became known as Fishbourne Roman Palace ,and a museum was erected to preserve some of the remains .This is administered by the Sussex Archaeological Society.\\n\\n**Paragraph C.**\\nIn its day, the completed palace would have comprised four large wings with colonnaded fronts. The north and east wings consisted of suites of private rooms built around courtyards, with a monumental entrance in the middle of the east wing. In the north-east corner there was an assembly hall. The west wing contained state rooms, a large ceremonial reception room, and a gallery. The south wing contained the owner’s private apartments. The palace included as many as 50 mosaic floors, under-floor central heating and a bathhouse. In size, Fishbourne Palace would have been approximately equivalent to some of the great Roman palaces of Italy, and was by far the largest known Roman residence north of the European Alps, at about 500 feet (150m)square. A team of volunteers and professional archaeologists are involved in an ongoing archaeological excavation on the site of nearby, possibly military, buildings.\\n\\n**Paragraph D.**\\nThe first buildings to be erected on the site were constructed in the early part of the conquest in 43 AD. Later, two timber buildings were constructed, one with clay and mortar floors and plaster walls, which appears to have been a house of some comfort. These buildings were demolished in the 60s AD and replaced by a substantial stone house, which included colonnades, and a bath suite. It has been suggested that the palaces itself, incorporating the previous house in its south-east corner, was constructed around 73-75 AD. However, Dr Miles Russell, of Bournemouth University, reinterpreted the ground plan and the collection of objects found and has suggested that, given the extremely close parallels with the imperial palace of Domitian in Rome, its construction may more plausibly date to after 92 AD.\\n\\n**Paragraph E.**\\nWith regard to who lived in Fishbourne Palace, there are a number of theories; for example ,one proposed by Professor Cunliffe is that ,in its early phase, the palace was the residence of Tiberius\\n\\n**Paragraph F.**\\nClaudius Cogidubnus ,a local chieftain who supported the Romans ,and who may have been installed as king of a number of territories following the first stage of the conquest. Cogidubnus is known from a reference to his loyalty in Agricola, a work by the Roman writer Tacitus, and from an inscription commemorating a temple dedicated to the gods Neptune and Minerva found in the nearby city of Chichester. Another theory is that it was built for Sallustius Lucullus, a Roman governor of Britain of the late 1st century, who may have been the son of the British prince Adminius. Two inscriptions recording the presence of Lucullus have been found in Chichester, and the redating by Miles Russell of the palace was designed for Lucullus, then it may have only been in use for a few years, as the Roman historian Suetonius records that Lucullus was executed by the Emperor Domitian in or shortly after 93 AD.\\n\\n**Paragraph G.**\\nAdditional theories suggest that either Verica, a British king of the Roman Empire in the years preceding the Claudian invasion, was owner of the palace, or Tiberius Claudius Catuarus , following the recent discovery of a gold ring belonging to him. The palace outlasted the original owner, whoever he was, and was extensively re-planned early in the 2nd century AD, and subdivided into a series of lesser apartments. Further redevelopment was begun in the late 3rd century AD, but these alterations were incomplete when the north wing was destroyed in a fire in around 270 AD. The damage was too great repair, and the palace was abandoned and later dismantled.\\n\\n**Paragraph H.**\\nA modern museum had been built by the Sussex Archaeological Society, incorporating most of the visible remains , including one wing of the palace. The gardens have been re-planted using authentic plants from the Roman period.\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Fishbourne Palace was the first structure to be built on its site.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Fishbourne Palace was renovated more than once',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Fishbourne Palace was large in comparison with Roman palaces in Italy.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Research is continuing in the area close to Fishbourne Palace.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Researchers agree on the identity of the person for whom Fishbourne Palace was constructed.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Fishbourne Palace was burnt down by local people.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'The first buildings on the site contained food for the _______',
    '',
    '{"blank-q7": ["ROMAN ARMY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'The palace building surrounded _______',
    '',
    '{"blank-q8": ["GARDENS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'In the 2 nd and 3 rd centuries colour was added to the _______ of the palace.',
    '',
    '{"blank-q9": ["FLOORS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'The first part of the palace to be found was part of a _______',
    '',
    '{"blank-q10": ["WALL"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Sallustius Lucullus - he may have lived there until approximately _______ AD',
    '',
    '{"blank-q11": ["93"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    12,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Catuarus - his _______ was found there',
    '',
    '{"blank-q12": ["GOLD RING"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '• A _______ has been built on the site to help protect it.',
    '',
    '{"blank-q13": ["MODERN MUSEUM"]}'::jsonb
  );


END$$;


COMMIT;