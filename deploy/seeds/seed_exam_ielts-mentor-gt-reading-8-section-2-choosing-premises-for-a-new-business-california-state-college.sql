-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T19:40:53.361085
-- Source: ielts-mentor.com
-- Title: GT Reading 8 Section 2 - Choosing premises for a new business & California State College
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-8-section-2-choosing-premises-for-a-new-business-california-state-college
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-8-section-2-choosing-premises-for-a-new-business-california-state-college'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-8-section-2-choosing-premises-for-a-new-business-california-state-college';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-8-section-2-choosing-premises-for-a-new-business-california-state-college';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-8-section-2-choosing-premises-for-a-new-business-california-state-college';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-8-section-2-choosing-premises-for-a-new-business-california-state-college',
    'GT Reading 8 Section 2 - Choosing premises for a new business & California State College',
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
    'Reading Passage - GT Reading 8 Section 2 - Choosing premises for a new business & California State College',
    E'# Passage\n\n# CHOOSING PREMISES FOR A NEW BUSINESS & CALIFORNIA STATE COLLEGE\n\nWhat you need Three factors dominate the priorities of small businesses looking for premises: cost, cost and cost. Nobody ever has enough money, so there is an overwhelming temptation to go for the cheapest property. It is a mistake that can take decades to rectify - and even threaten the future of a promising business. Ironically some firms swing too far in the other direction, committing themselves to a heavy initial outlay because they believe in the importance of image - and that does not come cheap. Finding the right premises is the real secret. That can, and will, vary enormously according to the type of business. But there are some general rules that apply to any operation. Location High street premises are important for shops which rely on passing trade - but these are expensive. Rents fall quickly within a few metres of main roads. Offices, however, need not be located centrally, particularly if most business is done on the phone or via email. Manufacturing and storage relies heavily on access. Think about how vans and lorries will deliver and collect goods from the premises. Nearby parking can be important for staff, and public transport can be even more so, as traffic restrictions tighten. Size This is a crucial decision. Health and Safety laws provide basic guidance on how much room is required per office desk or manufacturing operation. But remember to allow for growth. Growth Every small business aims to become a big business, but this prospect can be obstructed if the wrong decisions are made early on. It is important to consider flexibility from the start. Can a building be physically altered internally by knocking down walls or by extending outwards or adding extra floors? Is there spare land next door to expand later if necessary? Landlords obviously have to agree to any changes so it is important that the contract includes details of what will be allowed and how much extra will be charged on top of the costs of rebuilding or alteration. Planning rules must also be considered. Local authorities are not always open to discussion about the future of premises. They may have rigid rules about increasing density of development. The building may be in a conservation area or near housing, in which case it will be much more difficult to consider changes.\n\nPayday Employees are paid every other Friday. If Friday is a holiday, payday will be the following Monday. Generally, employees pick up the pay checks in their department; if not, they may be picked up at the Business Office. Overtime All time worked over eight hours in one day and forty hours in a workweek, and also the first eight hours worked on the seventh day of work in a workweek is considered overtime for non-exempt employees. The supervisor must approve all overtime before overtime occurs. Hours in excess of eight hours on the seventh day and in excess of twelve hours in one day will be paid at double time. Exempt employees receive no additional compensation for overtime hours. Parking All employees who will be parking in a staff parking zone must obtain a parking permit. A monthly pre-tax payroll deduction can be made by visiting Human Resources. If you wish to pay cash, present your staff I.D. and license number to the Cashier''s Office. The Safety Department will ticket cars without a parking permit and a fine will be applied. I.D. Card All employees are required to carry an I.D. card. If an employee loses his/her card, there will be an automatic charge of $5.00 to issue a duplicate. If an employee gives up employment, his/her I.D. card must be returned prior to the release of the final paycheck. Holidays All regular and temporary full-time employees generally receive approximately 13 paid holidays during the course of each calendar year. Regular part-time employees will receive holiday benefits worked out using a prorated system. The holiday schedule is initiated annually. Personal Holiday Each employee is granted one extra day as a Personal Holiday at the time of hire, and at the beginning of each calendar year, Personal Holiday hours must be taken at one time (eight hours full-time or prorated based on the employee''s time). Employees requesting Personal Holiday will be required to complete ‘Leave Request’ forms. No more than one Personal Holiday is authorized annually. Birthday Holiday All regular and temporary full-time or part-time employees are entitled to take their birthday off with pay. An employee has a fifteen-day span before and following his/her birthday to take the paid day off. What is known as a grace period through January 15th is given to those employees whose birthdays fall between December 16th and the end of the year.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    15,
    'SUMMARY_COMPLETION',
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
    'SUMMARY_COMPLETION',
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
    'SUMMARY_COMPLETION',
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
    'SUMMARY_COMPLETION',
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
    'SUMMARY_COMPLETION',
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
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'If business premises are located close to _______, extensions may not be allowed.Read the text below and answer Questions21-27.CALIFORNIA STATE COLLEGEWORKING CONDITIONS AND BENEFITS FOR...',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["housing"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    21,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Where do most employees collect their wages? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q21": ["their department"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    22,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Who has to authorise any overtime an employee wishes to do?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    23,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Who is not paid extra for working more than 40 hours a week? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q23": ["exempt employees"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    24,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Where should employees go if they wish to have the parking charge taken off their salary?',
    'Choose the correct answer.',
    '{"info-q24": ["HR/ HUMAN RESOURCES", "hr/ human resources"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    25,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'What method is used to calculate part-time employees′ holidays?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    26,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Which documents must employees fill in to select their Personal Holiday? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q26": ["Leave Request forms"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    27,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'What is the name of the special entitlement provided to employees with birthdays in the second half of December?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);


END$$;


COMMIT;