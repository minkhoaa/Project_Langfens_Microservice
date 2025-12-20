-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T23:34:07.570355
-- Source: ielts-mentor.com
-- Title: GT Reading 39 Section 2 - Kenichi Software & Is Everyone Entitled to Paid Holidays?
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-39-section-2-kenichi-software-is-everyone-entitled-to-paid-holidays
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-39-section-2-kenichi-software-is-everyone-entitled-to-paid-holidays'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-39-section-2-kenichi-software-is-everyone-entitled-to-paid-holidays';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-39-section-2-kenichi-software-is-everyone-entitled-to-paid-holidays';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-39-section-2-kenichi-software-is-everyone-entitled-to-paid-holidays';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-39-section-2-kenichi-software-is-everyone-entitled-to-paid-holidays',
    'GT Reading 39 Section 2 - Kenichi Software & Is Everyone Entitled to Paid Holidays?',
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
    'Reading Passage - GT Reading 39 Section 2 - Kenichi Software & Is Everyone Entitled to Paid Holidays?',
    E'# Passage\n\n# Kenichi Software: Security Guidelines for Staff & Is Everyone Entitled to Paid Holidays?\n\nGeneral It is in everyone''s interest to maintain a high level of security in the workplace. You should immediately challenge any person who appears to be on the premises without proper authorisation, or inform a senior member of staff about any odd or unusual activity. Company Property You are advised that it is within the company''s legal rights to detain any person on the grounds that they may be involved in the unauthorised removal of company property. The company reserves the right to search staff members leaving or entering the premises and to inspect any article or motor vehicle on company property. It is a condition of employment that you submit to such action if requested. It is in your own interest to ensure that you have proper authority before removing any item of company property from a company building. Any member found removing company property from the building without proper authority will be subject to disciplinary action. Identity Badges You will be issued with an identity badge, which should be worn at all times when you are on company premises. The purpose of these badges is to safeguard our security. Badges are issued by Human Resources, and contractors and people visiting the company on a one-off basis are also obliged to wear them. Confidential Matters In the course of your work, you may have access to information relating to the company''s business, or that of a supplier or customer. Such material, even where it appears comparatively trivial, can have a serious effect on the company, supplier or customer if it falls into the wrong hands. It is, therefore, essential that you should at all times be aware of the serious view the company would take of disclosure of such material to outsiders. You must treat as confidential all information, data, specifications, drawings and all documents relating to the company''s business and/or its trading activities, and not divulge, use, or employ them except in the company''s service. Before you leave the company, you must hand over to your manager all private notes relevant to the company''s business, activities, prices, accounts, costs etc. Legal proceedings may be initiated for any misuse or unauthorized disclosure of such confidential information, whether during employment or afterwards.\n\nThe Working Time Regulations (WTRs) introduced a new right to paid holidays for most workers. However, some workers were not covered when the WTRs came into force in October 1998. Since the regulations were amended, with effect from 1 August 2003, the majority of these workers have been entitled to paid holidays, and since 1 August 2004, the regulations have also applied to junior doctors. Workers who qualify are entitled to no fewer than four weeks of paid holiday a year, and public holidays (normally eight days in England and Wales) count towards this. However, workers and employers can agree longer holidays. For the first year of work, special accrual rules apply. For each month of employment, workers are entitled to one-twelfth of the annual holiday. After the first year of employment, you can take your holiday entitlement at any time, with your employer''s approval. Before taking holidays, you must give your employer notice of at least twice the length of the holiday you want to take: for instance, to take a five-day holiday, you must give at least ten days'' notice. If your employer does not want you to take that holiday, they can give you counter-notice equal to the holiday - for example, five days'' notice not to take a five-day holiday. If the employer wants you to take holiday at a given time, e.g. when there is a shutdown at the same time every year,'' they must give you notice of at least twice the length of the holiday. There is no right for the worker to take that holiday at a different time. Holiday cannot be carried over to the next year, unless your contract of employment allows this to happen. Nor can you be paid in lieu of your holiday. However, when you leave the job, you are entitled to receive payment for any outstanding holiday, provided your contract specifically allows for this. It may be that your contract gives you better rights, or your holiday rights might be specified in a collective agreement. Your union representative can advise you on this.'
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
    'If you see anything suspicious, you should report it to a _______ employee.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q15": ["senior"]}'::jsonb
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
    'If the company wants to stop you and _______ you, you have to agree to it.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q16": ["search"]}'::jsonb
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
    'If you take things belonging to the company without permission, you will face _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q17": ["disciplinary action"]}'::jsonb
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
    'Staff, _______ and visitors must all wear a badge on company premises.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q18": ["contractors"]}'::jsonb
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
    'You must not pass on confidential information to _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q19": ["outsiders"]}'::jsonb
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
    'If you leave the company, you have to hand in any _______ you have made on matters concerning the company.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["(private) notes"]}'::jsonb
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
    'In what year were the regulations extended to cover most of the workers who were originally excluded?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q21": ["2003"]}'::jsonb
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
    'What is the minimum annual paid holiday which workers are entitled to?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q22": ["4 weeks"]}'::jsonb
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
    'During a worker''s first year of employment, what proportion of their annual holiday does a month''s work give? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q23": ["one-twelfth"]}'::jsonb
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
    'What can an employer give a worker to stop them taking holiday that they have requested?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q24": ["counter-notice"]}'::jsonb
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
    'What is given as a possible reason for an employee having to take a holiday at a certain time?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q25": ["shutdown"]}'::jsonb
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
    'When an employee leaves their job, what should be given in place of any holiday they have not taken?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q26": ["payment"]}'::jsonb
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
    'Apart from a contract, what type of document may set out an employee''s holiday rights?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q27": ["collective agreement"]}'::jsonb
  );


END$$;


COMMIT;