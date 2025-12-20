-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T20:26:32.369074
-- Source: ielts-mentor.com
-- Title: GT Reading 35 Section 3 - The Iron Bridge
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-35-section-3-the-iron-bridge
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-35-section-3-the-iron-bridge'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-35-section-3-the-iron-bridge';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-35-section-3-the-iron-bridge';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-35-section-3-the-iron-bridge';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-35-section-3-the-iron-bridge',
    'GT Reading 35 Section 3 - The Iron Bridge',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - GT Reading 35 Section 3 - The Iron Bridge',
    E'# Passage\n\n# THE IRON BRIDGE\n\n(A) The Iron Bridge crosses the River Severn in Coalbrookdale, in the west of England. It was the first cast-iron bridge to be successfully erected, and the first large cast-iron structure of the industrial age in Europe, although the Chinese were expert iron-casters many centuries earlier. (B) Rivers used to be the equivalent of today’s motorways, in that they were extensively used for transportation. The River Severn, which starts its life on the Welsh mountains and eventually enters the sea between Cardiff and Bristol, is the longest navigable river in Britain. It was ideal for transportation purposes, and special boats were built to navigate the waters. By the middle of the eighteenth century, the Severn was one of the busiest rivers in Europe. Local goods, including coal, iron products, wool, grain and cider, were sent by the river. Among the goods coming upstream were luxuries such as sugar, tea, coffee and wine. In places, the riverbanks were lined with wharves and the river was often crowded with boats loading or unloading. (C) In 1638, Basil Brooke patented a steel-making process and built a furnace at Coalbrookdale. This later became the property of Abraham Darby (referred to as Abraham Darby I to distinguish him from his son and grandson of the same name). After serving an apprenticeship in Birmingham, Darby had started a business in Bristol, but he moved to Coalbrookdale in 1710 with an idea that coke derived from coal could provide a more economical alternative to charcoal as a fuel for ironmaking. This led to cheaper, more efficient ironmaking from the abundant supplies of coal, iron and limestone in the area. (D) His son, Abraham Darby II, pioneered the manufacture of cast iron, and had the idea of building a bridge over the Severn, as ferrying stores of all kinds across the river, particularly the large quantities of fuel for the furnaces at Coalbrookdale and other surrounding ironworks, involved considerable expense and delay. However, it was his son Abraham Darby III (born in 1750) who, in 1775, organised a meeting to plan the building of a bridge. This was designed by a local architect, Thomas Pritchard, who had the idea of constructing it of iron. (E) Sections were cast during the winter of 1778-9 for a 7-metre-wide bridge with a span of 31 metres, 12 metres above the river. Construction took three months during the summer of 1779, and remarkably, nobody was injured during the construction process - a feat almost unheard of even in modern major civil engineering projects. Work on the approach roads continued for another two years, and the bridge was opened to traffic in 1781. Abraham Darby III funded the bridge by commissioning paintings and engravings, but he lost a lot on the project, which had cost nearly double the estimate, and he died leaving massive debts in 1789, aged only Since 1934 the bridge has been open only to pedestrians. Universally recognised as the symbol of the Industrial Revolution, the Iron Bridge now stands at the heart of the Ironbridge Gorge World Heritage Site. (F) It has always been a mystery how the bridge was built. Despite its pioneering technology, no eye-witness accounts are known which describe the iron bridge being erected - and certainly, no plans have survived. However, recent discoveries, research and experiments have shed new light on exactly how it was built, challenging the assumptions of recent decades. In 1997 a small watercolour sketch by Elias Martin came to light in the Swedish capital, Stockholm. Although there is a wealth of early views of the bridge by numerous artists, this is the only one which actually shows it under construction. (G) Up until recently, it had been assumed that the bridge had been built from both banks, with the inner supports tilted across the river. This would have allowed river traffic to continue unimpeded during construction. But the picture clearly shows sections of the bridge being raised from a barge in the river. It contradicted everything historians had assumed about the bridge, and it was even considered that the picture could have been a fake as no other had come to light. So in 2001, a half-scale model of the bridge was built, in order to see if it could have been constructed in the way depicted in the watercolour. Meanwhile, a detailed archaeological, historical and photographic survey was done by the Ironbridge Gorge Museum Trust, along with a 3D CAD (computer-aided design) model by English Heritage. (H) The results tell us a lot more about how the bridge was built. We now know that all the large castings were made individually as they are all slightly different. The bridge wasn’t welded or bolted together as metal bridges are these days. Instead it was fitted together using a complex system of joints normally used for wood - but this was the traditional way in which iron structures were joined at the time. The construction of the model proved that the painting shows a very realistic method of constructing the bridge that could work and was in all probability the method used. (I) Now only one mystery remains in the Iron Bridge story. The Swedish watercolour sketch had apparently been torn from a book which would have contained similar sketches. It had been drawn by a Swedish artist who lived in London for 12 years and travelled Britain drawing what he saw. Nobody knows what has happened to the rest of the book, but perhaps the other sketches still exist somewhere. If they are ever found they could provide further valuable evidence of how the Iron Bridge was constructed.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    28,
    'SHORT_ANSWER',
    'READING',
    2,
    'When was the furnace bought by Darby originally constructed?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q28": ["1638"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    29,
    'SHORT_ANSWER',
    'READING',
    2,
    'When were the roads leading to the bridge completed?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q29": ["1781"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    30,
    'SHORT_ANSWER',
    'READING',
    2,
    'When was the bridge closed to traffic?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q30": ["1934"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    31,
    'SHORT_ANSWER',
    'READING',
    2,
    'When was a model of the bridge built?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q31": ["2001"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'There is no written evidence of how the original bridge was constructed.',
    'Choose the correct answer.',
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
    33,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The painting by Elias Martin is the only one of the bridge when it was new.',
    'Choose the correct answer.',
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
    34,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The painting shows that the bridge was constructed from the two banks.',
    'Choose the correct answer.',
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
    35,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The original bridge and the model took equally long to construct.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    36,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Elias Martin is thought to have made other paintings of the bridge.',
    'Choose the correct answer.',
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
    37,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Why a bridge was required across the River Severn',
    'Choose the correct answer.',
    '{"info-q37": ["D", "d"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'H', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'I', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    38,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A method used to raise money for the bridge',
    'Choose the correct answer.',
    '{"info-q38": ["E", "e"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'H', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'I', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    39,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Why Coalbrookdale became attractive to iron makers',
    'Choose the correct answer.',
    '{"info-q39": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'H', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'I', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    40,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'How the sections of the bridge were connected to each other',
    'Choose the correct answer.',
    '{"info-q40": ["H", "h"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'H', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'I', false);


END$$;


COMMIT;