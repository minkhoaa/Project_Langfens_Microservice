-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T04:58:32.360681
-- Source: mini-ielts.com
-- Title: A debit card
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-a-debit-card
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-a-debit-card'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-a-debit-card';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-a-debit-card';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-a-debit-card';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-a-debit-card',
    'A debit card',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766530818/ielts/a-debit-card_thumbpad_b035105cfaeb.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - A debit card',
    E'**Questions 1-6:**\nLabel the diagram below.\nWrite **ONE OR TWO WORDS** for each answer.',
    E'# A Debit Card\n\n## Listening: Label the Diagram (Questions 1-6)\n\nIn this listening exercise, you will hear a description of a debit card and its various parts. Listen carefully to identify and label each component of the card. A debit card is a payment card that allows you to make purchases by deducting money directly from your bank account. Unlike credit cards, debit cards do not involve borrowing money.\n\nDebit cards have several important security features and identification elements. These include the cardholder''s personal information, security features to prevent fraud, and the bank''s branding. Pay attention to the speaker''s description of where each element is located on the card.\n\n---\n\n## Debit Card Diagram (Questions 1-6)\n\n![Debit Card Diagram](https://res.cloudinary.com/df41zs8il/image/upload/v1766531048/ielts/credit_9523d2957c15.jpg)\n\n**Label the parts of the debit card:**\n- **1** _______ (Cardholder''s identification image)\n- **2** _______ (Data storage strip on back)\n- **3** _______ (Cardholder''s handwritten name)\n- **4** _______ (Issuing bank''s symbol)\n- **5** _______ (Expiration information)\n- **6** _______ (Electronic security component)\n\nWrite **ONE OR TWO WORDS** for each answer.'
  ,
    'https://www.youtube.com/embed/oCQGttCjkwg?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Cardholder''s identification image: _______',
    '',
    '{"blank-q1": ["picture"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Data storage strip on back of card: _______',
    '',
    '{"blank-q2": ["magnetic strip"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Cardholder''s handwritten name: _______',
    '',
    '{"blank-q3": ["signature"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Issuing bank''s symbol: _______',
    '',
    '{"blank-q4": ["bank logo"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Expiration information on card: _______',
    '',
    '{"blank-q5": ["date"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Electronic security component: _______',
    '',
    '{"blank-q6": ["chip"]}'::jsonb
  );


END$$;


COMMIT;