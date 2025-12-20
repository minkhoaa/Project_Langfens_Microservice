-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T18:31:16.076303
-- Source: ielts-mentor.com
-- Title: GT Reading Test 39 Section 1 - Holiday Plus & Sydney Travel College
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-test-39-section-1-holiday-plus-sydney-travel-college
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-test-39-section-1-holiday-plus-sydney-travel-college'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-test-39-section-1-holiday-plus-sydney-travel-college';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-test-39-section-1-holiday-plus-sydney-travel-college';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-test-39-section-1-holiday-plus-sydney-travel-college';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-test-39-section-1-holiday-plus-sydney-travel-college',
    'GT Reading Test 39 Section 1 - Holiday Plus & Sydney Travel College',
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
    'Reading Passage - GT Reading Test 39 Section 1 - Holiday Plus & Sydney Travel College',
    E'# Passage\n\n**Passage 1: Holiday Plus**\n\n**A. Mountain Lodge Retreat**\nMountain Lodge offers skiing and hiking packages. Transfer from airport takes 3 hours. Activities include canoeing and tennis at no extra cost. Self-drive automobile is the fastest way to travel. Open year-round except May.\n\n**B. Beach Paradise Resort**  \nBeach Paradise includes a complimentary city tour. Transfer from airport takes 1.5 hours. Suitable for families with children of all ages.\n\n**C. Adventure Camp**\nAdventure Camp has activities for adults and teenagers only - not suitable for young children. Transfer from airport takes 2 hours.\n\n---\n\n**Passage 2: Sydney Travel College - Travel Insurance Requirements**\n\nAs this course includes a total of three months'' travel outside Australia, travel insurance is compulsory.\n\n**1. Medical**\nAustralia has reciprocal medical arrangements with the governments of the eight nations you will be visiting. This arrangement will cover all emergency hospital treatment. However, students will have to take out insurance such as Multiplan to cover the costs of all visits to doctors, and other non-emergency medical situations.\n\nIf you have a serious accident or illness, Multiplan insurance will cover the cost of your flight back to Australia, if required. Depending on the circumstances, this may also pay for either medical personnel or a family member to accompany you home. Multiplan insurance may not cover all pre-existing medical conditions.\n\nIf you do require medical treatment overseas, and you want to make a claim on your insurance, the claim will not be accepted unless you produce both your student card and your travel insurance card.\n\n**2. Belongings**\nThe Multiplan policy covers most student requirements:\n- The present value of items that are stolen, provided that you have purchase receipts\n- Replacement value of your briefcase or backpack and study books\n- Portable computers and CD players, if you specifically list them as items in the policy\n\n**3. Cancellation**\nThis insurance covers any non-refundable deposit if you have to cancel due to ''unforeseen circumstances outside your control''. It does not provide cover if you change your study or travel plans for other reasons.\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'This holiday doesn''t cater for young children.',
    'Choose the correct answer.',
    '{"info-q1": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'This holiday provides a tour at no extra cost.',
    'Choose the correct answer.',
    '{"info-q2": ["B", "b"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'This holiday involves most travel time from the airport.',
    'Choose the correct answer.',
    '{"info-q3": ["A", "a"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SHORT_ANSWER',
    'READING',
    2,
    'When will one of the holiday locations not be open? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q4": ["MAY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SHORT_ANSWER',
    'READING',
    2,
    'Which two outdoor activities are provided at no extra cost at Mountain Lodge? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q5": ["CANOEING AND TENNIS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SHORT_ANSWER',
    'READING',
    2,
    'What is the fastest way to travel to Mountain Lodge? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q6": ["SELF-DRIVE AUTOMOBILE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A student travelling overseas suddenly needs hospital treatment.',
    'Choose the correct answer.',
    '{"info-q7": ["A", "a"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. covered by government arrangements', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. not covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. covered in some situations', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A student consults a doctor regarding a minor problem while abroad.',
    'Choose the correct answer.',
    '{"info-q8": ["B", "b"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. covered by government arrangements', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. covered by the Multiplan policy', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. not covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. covered in some situations', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A parent goes overseas to bring an injured or sick student to Australia.',
    'Choose the correct answer.',
    '{"info-q9": ["D", "d"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. covered by government arrangements', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. not covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. covered in some situations', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A student is treated overseas for an illness he/she had before leaving Australia.',
    'Choose the correct answer.',
    '{"info-q10": ["D", "d"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. covered by government arrangements', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. not covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. covered in some situations', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A student who requires medical treatment has lost his/her travel insurance card.',
    'Choose the correct answer.',
    '{"info-q11": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. covered by government arrangements', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. not covered by the Multiplan policy', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. covered in some situations', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A student''s study books are lost.',
    'Choose the correct answer.',
    '{"info-q12": ["B", "b"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. covered by government arrangements', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. covered by the Multiplan policy', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. not covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. covered in some situations', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A student''s laptop is stolen.',
    'Choose the correct answer.',
    '{"info-q13": ["D", "d"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. covered by government arrangements', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. not covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. covered in some situations', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A student changes his/her mind about plans to study and decides not to take the booked flight.',
    'Choose the correct answer.',
    '{"info-q14": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. covered by government arrangements', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. covered by the Multiplan policy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. not covered by the Multiplan policy', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. covered in some situations', false);


END$$;


COMMIT;