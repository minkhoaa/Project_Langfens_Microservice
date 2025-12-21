-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T13:03:57.275991
-- Source: ielts-mentor.com
-- Title: GT Reading 8 Section 2 - Choosing Premises & California State College
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-8-section-2-choosing-premises-california-state-college
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-8-section-2-choosing-premises-california-state-college'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-8-section-2-choosing-premises-california-state-college';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-8-section-2-choosing-premises-california-state-college';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-8-section-2-choosing-premises-california-state-college';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-8-section-2-choosing-premises-california-state-college',
    'GT Reading 8 Section 2 - Choosing Premises & California State College',
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
    'Reading Passage - GT Reading 8 Section 2 - Choosing Premises & California State College',
    E'**Questions 15-20:**\nComplete the sentences below.\n\nChoose **NO MORE THAN TWO WORDS** from the text for each answer.\n\n---\n\n# CHOOSING PREMISES FOR A NEW BUSINESS\n\n**What you need**\nThree factors dominate the priorities of small businesses looking for premises: cost, cost and cost. Nobody ever has enough money, so there is an overwhelming temptation to go for the cheapest property. It is a mistake that can take decades to rectify - and even threaten the future of a promising business.\n\nIronically some firms swing too far in the other direction, committing themselves to a heavy initial outlay because they believe in the importance of image - and that does not come cheap. Finding the right premises is the real secret. That can, and will, vary enormously according to the type of business. But there are some general rules that apply to any operation.\n\n**Location**\nHigh street premises are important for shops which rely on passing trade - but these are expensive. Rents fall quickly within a few metres of main roads. Offices, however, need not be located centrally, particularly if most business is done on the phone or via email.\n\nManufacturing and storage relies heavily on access. Think about how vans and lorries will deliver and collect goods from the premises. Nearby parking can be important for staff, and public transport can be even more so, as traffic restrictions tighten.\n\n**Size**\nThis is a crucial decision. Health and Safety laws provide basic guidance on how much room is required per office desk or manufacturing operation. But remember to allow for growth.\n\n**Growth**\nEvery small business aims to become a big business, but this prospect can be obstructed if the wrong decisions are made early on. It is important to consider flexibility from the start. Can a building be physically altered internally by knocking down walls or by extending outwards or adding extra floors? Is there spare land next door to expand later if necessary?\n\nLandlords obviously have to agree to any changes so it is important that the contract includes details of what will be allowed and how much extra will be charged on top of the costs of rebuilding or alteration. Planning rules must also be considered. Local authorities are not always open to discussion about the future of premises. They may have rigid rules about increasing density of development. The building may be in a conservation area or near housing, in which case it will be much more difficult to consider changes.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    15,
    'SENTENCE_COMPLETION',
    'READING',
    2,
    'Some people choose expensive premises because they want to create an impressive _______ for their company.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q15": ["image"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    16,
    'SENTENCE_COMPLETION',
    'READING',
    2,
    'Businesses which depend on _______ need to be on or near the principal shopping areas.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q16": ["passing trade"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    17,
    'SENTENCE_COMPLETION',
    'READING',
    2,
    'Businesses which produce goods must check there is _______ to the premises for delivery vehicles.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q17": ["access"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    18,
    'SENTENCE_COMPLETION',
    'READING',
    2,
    'When choosing a building for your premises, find out whether _______ could be removed to create more room.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q18": ["walls"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    19,
    'SENTENCE_COMPLETION',
    'READING',
    2,
    'Make sure that the _______ states what type of building alterations might be permitted.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q19": ["contract"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    20,
    'SENTENCE_COMPLETION',
    'READING',
    2,
    'If business premises are located close to _______, extensions may not be allowed.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["housing"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    21,
    'SHORT_ANSWER',
    'READING',
    2,
    'Where do most employees collect their wages? _______',
    'Write the correct answer from the passage.',
    ARRAY['their department', 'in their department']::text[]
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    22,
    'SHORT_ANSWER',
    'READING',
    2,
    'Who has to authorise any overtime an employee wishes to do? _______',
    'Write the correct answer from the passage.',
    ARRAY['the supervisor', 'supervisor']::text[]
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    23,
    'SHORT_ANSWER',
    'READING',
    2,
    'Who is not paid extra for working more than 40 hours a week? _______',
    'Write the correct answer from the passage.',
    ARRAY['exempt employees']::text[]
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    24,
    'SHORT_ANSWER',
    'READING',
    2,
    'Where should employees go if they wish to have the parking charge taken off their salary? _______',
    'Write the correct answer from the passage.',
    ARRAY['Human Resources']::text[]
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    25,
    'SHORT_ANSWER',
    'READING',
    2,
    'What method is used to calculate part-time employees'' holidays? _______',
    'Write the correct answer from the passage.',
    ARRAY['prorated system', 'a prorated system']::text[]
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    26,
    'SHORT_ANSWER',
    'READING',
    2,
    'Which documents must employees fill in to select their Personal Holiday? _______',
    'Write the correct answer from the passage.',
    ARRAY['Leave Request forms', 'Leave Request']::text[]
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid,
    sec1,
    27,
    'SHORT_ANSWER',
    'READING',
    2,
    'What is the name of the special entitlement provided to employees with birthdays in the second half of December? _______',
    'Write the correct answer from the passage.',
    ARRAY['grace period', 'a grace period']::text[]
  );


END$$;


COMMIT;