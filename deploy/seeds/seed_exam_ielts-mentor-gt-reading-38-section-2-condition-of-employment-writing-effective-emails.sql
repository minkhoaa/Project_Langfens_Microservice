-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T20:26:32.400277
-- Source: ielts-mentor.com
-- Title: GT Reading 38 Section 2 - Condition of Employment & Writing effective Emails
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-38-section-2-condition-of-employment-writing-effective-emails
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-38-section-2-condition-of-employment-writing-effective-emails'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-38-section-2-condition-of-employment-writing-effective-emails';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-38-section-2-condition-of-employment-writing-effective-emails';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-38-section-2-condition-of-employment-writing-effective-emails';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-38-section-2-condition-of-employment-writing-effective-emails',
    'GT Reading 38 Section 2 - Condition of Employment & Writing effective Emails',
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
    'Reading Passage - GT Reading 38 Section 2 - Condition of Employment & Writing effective Emails',
    E'# Passage\n\n# CONDITIONS OF EMPLOYMENT & WRITING EFFECTIVE EMAILS\n\nWeekly hours of work – 40 hours per week at the ordinary hourly rate of pay for most full-time employees, plus reasonable additional hours (penalty rates apply). Part-time employees work a regular number of hours and days each week, but fewer hours than full-time workers. Casual employees are employed on an hourly or daily basis. Entitlements (full-time employees): Parental leave – up to 12 months’ unpaid leave for maternity, paternity and adoption related leave. Sick leave – up to 10 days’ paid sick leave per year; more than 4 continuous days requires a medical certificate. Annual leave – 4 weeks’ paid leave per annum, plus an additional week for shift workers. Public holidays – a paid day off on a public holiday, except where reasonably requested to work. Employees working on public holidays are entitled to 15% above their normal hourly rate. Notice of termination – 2 weeks’ notice of termination (3 weeks if the employee is more than 55 years old and has at least 2 years of continuous service) Note: The entitlements you receive will depend on whether you are employed on a full-time, part-time or casual basis. If you work part-time, you should receive all the entitlements of a full-time employee but on a prorata or proportional basis. If you are a casual worker, you do not have rights to any of the above entitlements nor penalty payments. Casual workers have no guarantee of hours to be worked and they do not have to be given advance notice of termination.\n\ni. Written communication ii. Clarity iii. Style iv. Research v. End of message vi. One point per email vii. Relevance viii. Specify the response you want ix. The subject line x. Internal emails\n\nFollow these simple rules to make a positive impression and get an appropriate response. A. Like a headline in a newspaper: it should grab the recipient’s attention and specify what the message is about – use a few well chosen words. If the email is one of a series e.g. a weekly newsletter, include the date in the subject line. Never leave it blank. B. If you need to email someone about several different issues, write a separate email for each subject. This allows the recipient to reply to each one individually in a timely manner. For instance, one subject might be dealt with quickly while another could involve some research. If you have several related points, put them all in the same email but present each point in a numbered or bulleted paragraph. C. Your email should be clear and concise. Sentences should be short and to the point. The purpose of the message should be outlined in the first paragraph and the body should contain all of the relevant information. D. Be sure to include a ‘call to action’ – a phone call or a follow-up appointment perhaps. To ensure a prompt reply, incorporate your contact information – name, title, company, phone/fax numbers or extensions, even your business address if necessary. Even internal messages must have contact information. E. Emails, even internal ones, should not be too informal – after all, they are written forms of communication. Use your spell-check and avoid slang. F. Only use this technique for very short messages or reminders where all the relevant information can fit in the subject line. Write EOM at the end of the line to indicate that the recipient doesn’t have to open the email.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    15,
    'SHORT_ANSWER',
    'READING',
    2,
    'Part-time workers are entitled to a higher rate of pay if they work more than their usual number of hours per week.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q15": ["NOT GIVEN"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    16,
    'SHORT_ANSWER',
    'READING',
    2,
    'Casual workers may be hired by the hour or by the day.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q16": ["TRUE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    17,
    'SHORT_ANSWER',
    'READING',
    2,
    'A full-timer who takes a year off to have a baby can return to the same employer.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q17": ["TRUE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    18,
    'SHORT_ANSWER',
    'READING',
    2,
    'A full-time worker needs a doctor’s note if he is sick for 4 days in a row.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q18": ["FALSE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    19,
    'SHORT_ANSWER',
    'READING',
    2,
    'A full-time night-shift worker is entitled to 5 weeks’ paid holiday each year.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q19": ["TRUE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    20,
    'SHORT_ANSWER',
    'READING',
    2,
    'Any workers over 55 are entitled to 3 weeks’ notice of termination.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["minutes"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    21,
    'SHORT_ANSWER',
    'READING',
    2,
    'Casual workers can be dismissed without notice.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q21": ["TRUE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    22,
    'SHORT_ANSWER',
    'READING',
    2,
    'Section A',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q22": ["ix"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    23,
    'SHORT_ANSWER',
    'READING',
    2,
    'Section B',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q23": ["vi"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    24,
    'SHORT_ANSWER',
    'READING',
    2,
    'Section C',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q24": ["ii"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    25,
    'SHORT_ANSWER',
    'READING',
    2,
    'Section D',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q25": ["viii"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    26,
    'SHORT_ANSWER',
    'READING',
    2,
    'Section E',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q26": ["iii"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    27,
    'SHORT_ANSWER',
    'READING',
    2,
    'Section F',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q27": ["v.<br", "><br", ">Section 3: 28. E"]}'::jsonb
  );


END$$;


COMMIT;