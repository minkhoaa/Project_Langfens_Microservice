-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T16:17:41.545483
-- Source: mini-ielts.com
-- Title: Water Hyacinth
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-water-hyacinth
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-water-hyacinth'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-water-hyacinth';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-water-hyacinth';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-water-hyacinth';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-water-hyacinth',
    'Water Hyacinth',
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
    'Reading Passage - Water Hyacinth',
    E'**Questions 1-2:**\nChoose **TWO** letters, **A-E**. Which two problems are caused by water hyacinth?\n\n---\n\n**Questions 3-6:**\nChoose the correct letter, **A**, **B** or **C**.\n\n---\n\n**Questions 7-10:**  \nWhat is the benefit of the cut down water hyacinth to each of the following aspects?\nChoose **FOUR** answers from the box (**A-F**).\n\n**Benefits:**\n- **A** can reduce the effect of global warming\n- **B** can be used as alternative energy resource\n- **C** can make quick profits\n- **D** can produce materials for plants to grow in\n- **E** can be good for human health\n- **F** can produce fertilizer\n\n---\n\n# Listening Test - Water Hyacinth\n\nThis is a listening practice test about water hyacinth, an invasive aquatic plant that has become a major environmental problem in many tropical and subtropical regions around the world.\n\n**About the Audio:**\nYou will hear a discussion between a presenter and an environmental expert named John. They discuss the problems caused by water hyacinth, including its impact on fishing, electricity production, and local ecosystems. The conversation also covers potential solutions, including biological control methods, mechanical removal, and economic uses for the harvested plants.\n\n**Instructions:**\nListen carefully to the audio recording and answer the questions below. You will hear the recording ONCE only. The test includes multiple choice questions and matching questions about benefits of harvested water hyacinth.\n\n**Question Topics:**\n- Problems caused by water hyacinth (Questions 1-2)\n- Origins and environmental factors (Questions 3-6)  \n- Benefits of harvested water hyacinth (Questions 7-10)'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_MULTIPLE',
    'READING',
    2,
    'Which two problems are caused by water hyacinth? (Choose TWO)',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. plants and fish are poisoned', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Farmers cannot fish', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the dam''s structure is damaged', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Electricity production is affected', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. electricity consumption increases', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Where was water hyacinth originally from?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Latin America', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Africa', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Europe', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What is the primary cause of the decrease in nutrients from the soil?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. soil erosion', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. a change of rainfall', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. loss of trees', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'When will the biological solution bring risks to the environment?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. immediately', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. 6 months later', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. many years later', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What does John say about the mechanical solution?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. ineffective', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. dangerous', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. expensive', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_FEATURES',
    'READING',
    2,
    'dried water hyacinth',
    'Choose the correct answer.',
    '{"feature-q7": ["D", "D"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_FEATURES',
    'READING',
    2,
    'mushroom farmers',
    'Choose the correct answer.',
    '{"feature-q8": ["C", "C"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_FEATURES',
    'READING',
    2,
    'oyster and straw mushrooms',
    'Choose the correct answer.',
    '{"feature-q9": ["E", "E"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_FEATURES',
    'READING',
    2,
    'cows',
    'Choose the correct answer.',
    '{"feature-q10": ["B", "B"]}'
  );


END$$;


COMMIT;