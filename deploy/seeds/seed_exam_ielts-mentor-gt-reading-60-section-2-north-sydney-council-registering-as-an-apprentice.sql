-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T00:54:12.934115
-- Source: ielts-mentor.com
-- Title: GT Reading 60 Section 2 - North Sydney Council & Registering As An Apprentice
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-60-section-2-north-sydney-council-registering-as-an-apprentice
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-60-section-2-north-sydney-council-registering-as-an-apprentice'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-60-section-2-north-sydney-council-registering-as-an-apprentice';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-60-section-2-north-sydney-council-registering-as-an-apprentice';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-60-section-2-north-sydney-council-registering-as-an-apprentice';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-60-section-2-north-sydney-council-registering-as-an-apprentice',
    'GT Reading 60 Section 2 - North Sydney Council & Registering As An Apprentice',
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
    'Reading Passage - GT Reading 60 Section 2 - North Sydney Council & Registering As An Apprentice',
    E'# Passage\n\n# North Sydney Council & Registering As An Apprentice\n\n**Paragraph A.**\nNorth Sydney Council recognises the importance of balancing the demands of your work with the demands of your personal life.\n\n**Paragraph B.**\nThe standard working week for full-time council employees is 35 hours For ''Indoor Staff'' and 38 hours for ''Outdoor Staff'', worked over 5 days. Indoor staff are able to access the benefit of flexi time. A number of these occasionally work from home where appropriate – an example of an initiative that can provide flexibility at certain stages of an employee''s career.\n\n**Paragraph C.**\nStaff are entitled to 3 weeks per annum sick or carer''s leave. In addition to the normal parental leave/maternity leave provisions, women who have completed 12 months of continuous service can access a total of 9 Weeks'' maternity leave that can be taken either as 9 weeks at full pay or as 18 weeks at half pay.\n\n**Paragraph D.**\nThe annual entitlement to paid holidays is 20 days, pro-rata for part-time. After 5 years of continuous service, employees are entitled to 6.5 weeks Long Service Leave (LSL).\n\n**Paragraph E.**\nOur Financial Advice Program is conducted in partnership with FuturePlus Financial Services. We provide the services of advisors specialising in pensions, and all our employees are given the opportunity to meet them as part of the induction process.\n\n**Paragraph F.**\nThe Employee Assistance Program (EAP) is a counselling service provided at no charge to all employees and their families. The service is available by phone or face to face. The EAP provides registered psychologists for employees wishing to discuss work or non-work matters confidentially. Employees can also access information, such as articles and self assessments, online via eapdirect.\n\n---\n\n# Registering As An Apprentice\n\n**Paragraph G.**\nIf you are keen to acquire new skills and learn best through ''hands-on'' experiences, then registered apprenticeship is a good option for you. These programmes always involve work experience as well as classroom instruction and produce workers skilled in the occupation. There is a written contract to be signed by the apprentice and the employer, which acknowledges their joint commitment to the training process. This contract is approved and registered by the New York State Department of Labor.\n\n**Paragraph H.**\nHow Do I Qualify? First of all you must meet the employer''s minimum qualifications. This could be a high school diploma or the equivalent. However, some employers will ask for specific high school courses, prior experience, or occupationally related courses.\n\n**Paragraph I.**\nWhat Is My Training Like? Training for each apprenticeable occupation is conducted according to a training outline that has been standardized for the occupation. This assures that apprentices across the state have the same sets of basic competencies and skills. At the successful completion of each registered apprenticeship, the Department of Labor awards the apprentice a ''Certificate of Completion'', which is a nationally recognized credential.\n\n**Paragraph J.**\nThe length of time it takes you to learn the skills of the occupation depends upon two things: the standard training outline and your aptitude. Each trade has a definite term of training, listed in years. As a registered apprentice, you may progress according to that established training term, or you may become skilled more quickly or more slowly. It may even be that you start your apprenticeship with credit toward the goal. Your employer may choose to award you this for previous working experience in the occupation, or for prior coursework related to the occupation.\n\n**Paragraph K.**\nAs an apprentice, you are part of the employer''s workforce. You work full-time for the employer. A registered apprentice works under the guidance of more experienced craft workers called journey workers. From them, you learn the skills of the trade. As you master each skill, you become a more productive employee.\n\n**Paragraph L.**\nAt the same time as you are working, you are also required to attend classes (usually in the evenings). The location and times of these are set up by the local education agent in consultation with the employer. Your progress is tracked by you, your employer and your education provider. Successful completion of all requirements results in your certificate.\n'
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
    'Which employees may choose not to work regular hours? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q15": ["indoor staff"]}'::jsonb
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
    'How much time off each year is an employee able to take to look after a relative _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q16": ["3 weeks"]}'::jsonb
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
    'What kind of leave involves a choice between two alternative periods of time? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q17": ["maternity leave"]}'::jsonb
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
    'How long must employees have worked without a break before being entitled to additional holidays _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q18": ["5 years"]}'::jsonb
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
    'What does the Financial Advice Program advise staff about? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q19": ["pensions"]}'::jsonb
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
    'What kind of professional people can employees see if they want to talk about their job in private? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["psychologists"]}'::jsonb
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
    'You and your employer will need to sign a _______ before training starts.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q21": ["written contract"]}'::jsonb
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
    'Employers may have different minimum requirements regarding applicants’ _______ and experience.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q22": ["qualifications"]}'::jsonb
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
    'Each industry has its own standardised _______of training.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q23": ["outline"]}'::jsonb
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
    'You may be given credit for work experience or if you have done relevant _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q24": ["coursework"]}'::jsonb
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
    'You will be considered as a member of the _______ during the apprenticeship.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q25": ["workforce"]}'::jsonb
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
    'While at work, apprentices are supervised by what are known as _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q26": ["journey workers"]}'::jsonb
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
    'Employers are consulted when deciding the _______ and schedule for lessons.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q27": ["location"]}'::jsonb
  );


END$$;


COMMIT;