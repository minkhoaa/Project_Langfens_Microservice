-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T12:43:18.431081
-- Source: ielts-mentor.com
-- Title: GT Reading 8 Section 1 - Eastern Energy & Microwave Oven
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-8-section-1-eastern-energy-microwave-oven
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-8-section-1-eastern-energy-microwave-oven'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-8-section-1-eastern-energy-microwave-oven';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-8-section-1-eastern-energy-microwave-oven';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-8-section-1-eastern-energy-microwave-oven';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-8-section-1-eastern-energy-microwave-oven',
    'GT Reading 8 Section 1 - Eastern Energy & Microwave Oven',
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
    'Reading Passage - GT Reading 8 Section 1 - Eastern Energy & Microwave Oven',
    E'**Questions 1-7:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n# EASTERN ENERGY\n\nWe are here to help and provide you with personal advice on any matters connected with your bill or any other queries regarding your gas and electricity supply.\n\n**Moving home**\nPlease give as much notice as possible if you are moving home, but at least 48 hours is required for us to make the necessary arrangements for your gas and electricity supply. Please telephone our 24-hour line on 01316 753219 with details of your move. In most cases, we are happy to accept your meter reading on the day you move. Tell the new occupant that Eastern Energy supplies the household, to ensure the service is not interrupted. Remember we can now supply electricity and gas at your new address, anywhere in the UK. If you do not contact us, you may be held responsible for the payment for electricity used after you have moved.\n\n**Meter reading**\nEastern Energy uses various types of meter ranging from the traditional dial meter to new technology digital display meters. Always read the meter from left to right, ignoring any red dials. If you require assistance, contact our 24-hour line on 0600 7310 310.\n\n**Energy Efficiency Line**\nIf you would like advice on the efficient use of energy, please call our Energy Efficiency Line on 0995 7626 513. Please do not use this number for any other enquiries.\n\n**Special services**\nPasswords - you can choose a password so that, whenever we visit you at home, you will know it is us. For more information, ring our helpline on 0995 7290 290.\n\n**Help and advice**\nIf you need help or advice with any issues, please contact us on 01316 440188.\n\n**Complaints**\nWe hope you will never have a problem or cause to complain, but, if you do, please contact our complaints handling team at PO Box 220, Stanfield, ST55 6GF or telephone us on 01316 753270.\n\n**Supply failure**\nIf you experience any problems with your electricity supply, please call free on 0600 7838 836, 24 hours a day, seven days a week.'
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
    'Customers should inform Eastern Energy of a change of address on arrival at their new home.',
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
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Customers are expected to read their own gas or electricity meters.',
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
    3,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'It is now cheaper to use gas rather than electricity as a form of heating.',
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
    4,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Eastern Energy supplies energy to households throughout the country.',
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
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The Energy Efficiency Line also handles queries about energy supply.',
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
    6,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'All complaints about energy supply should be made by phone.',
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
    7,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Customers are not charged for the call when they report a fault in supply.',
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
    8,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph A',
    'Choose the correct answer.',
    '{"paragraph-a-q8": ["v", "v. Rapid cooking times"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Re-heating', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Foods with skins', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Keeping your oven clean', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Standing time', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rapid cooking times', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Using a thermometer', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Small quantities of food', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Deep fat frying', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Foods low in moisture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Liquids', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph B',
    'Choose the correct answer.',
    '{"paragraph-b-q9": ["vii", "vii. Small quantities of food"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Re-heating', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Foods with skins', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Keeping your oven clean', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Standing time', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rapid cooking times', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Using a thermometer', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Small quantities of food', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Deep fat frying', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Foods low in moisture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Liquids', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph C',
    'Choose the correct answer.',
    '{"paragraph-c-q10": ["ix", "ix. Foods low in moisture"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Re-heating', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Foods with skins', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Keeping your oven clean', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Standing time', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rapid cooking times', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Using a thermometer', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Small quantities of food', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Deep fat frying', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Foods low in moisture', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Liquids', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph D',
    'Choose the correct answer.',
    '{"paragraph-d-q11": ["ii", "ii. Foods with skins"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Re-heating', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Foods with skins', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Keeping your oven clean', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Standing time', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rapid cooking times', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Using a thermometer', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Small quantities of food', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Deep fat frying', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Foods low in moisture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Liquids', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph E',
    'Choose the correct answer.',
    '{"paragraph-e-q12": ["x", "x. Liquids"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Re-heating', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Foods with skins', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Keeping your oven clean', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Standing time', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rapid cooking times', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Using a thermometer', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Small quantities of food', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Deep fat frying', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Foods low in moisture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Liquids', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph F',
    'Choose the correct answer.',
    '{"paragraph-f-q13": ["i", "i. Re-heating"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Re-heating', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Foods with skins', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Keeping your oven clean', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Standing time', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rapid cooking times', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Using a thermometer', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Small quantities of food', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Deep fat frying', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Foods low in moisture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Liquids', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph G',
    'Choose the correct answer.',
    '{"paragraph-g-q14": ["iii", "iii. Keeping your oven clean"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Re-heating', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Foods with skins', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Keeping your oven clean', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Standing time', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rapid cooking times', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Using a thermometer', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Small quantities of food', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Deep fat frying', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Foods low in moisture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Liquids', false);


END$$;


COMMIT;