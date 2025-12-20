-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T19:40:53.360253
-- Source: ielts-mentor.com
-- Title: GT Reading 14 Section 2 - Mistakes when applying for a job & H&S Certificate
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-14-section-2-mistakes-when-applying-for-a-job-h-s-certificate
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-14-section-2-mistakes-when-applying-for-a-job-h-s-certificate'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-14-section-2-mistakes-when-applying-for-a-job-h-s-certificate';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-14-section-2-mistakes-when-applying-for-a-job-h-s-certificate';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-14-section-2-mistakes-when-applying-for-a-job-h-s-certificate';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-14-section-2-mistakes-when-applying-for-a-job-h-s-certificate',
    'GT Reading 14 Section 2 - Mistakes when applying for a job & H&S Certificate',
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
    'Reading Passage - GT Reading 14 Section 2 - Mistakes when applying for a job & H&S Certificate',
    E'# Passage\n\n# Mistakes when applying for a job & HEALTH AND SAFETY CERTIFICATE FOR THE CONSTRUCTION INDUSTRY\n\nThere are many mistakes that people make when writing their resume (CV) or completing a job application. Here are some of the most common and most serious. The biggest problem is perhaps listing the duties for which you were responsible in a past position: all this tells your potential employers is what you were supposed to do. They do not necessarily know the specific skills you used in executing them, nor do they know what results you achieved - both of which are essential. In short, they won’t know if you were the best, the worst, or just average in your position. The more concrete information you can include, the better. As far as possible, provide measurements of what you accomplished. If any innovations you introduced saved the organization money, how much did they save? If you found a way of increasing productivity, by what percentage did you increase it? Writing what you are trying to achieve in life - your objective - is a waste of space. It tells the employer what you are interested in. Do you really think that employers care what you want? No, they are interested in what they want! Instead, use that space for a career summary. A good one is brief - three to four sentences long. A good one will make the person reviewing your application want to read further. Many resumes list ‘hard’ job-specific skills, almost to the exclusion of transferable, or ‘soft’, skills. However, your ability to negotiate effectively, for example, can be just as important as your technical skills. All information you give should be relevant, so carefully consider the job for which you are applying. If you are applying for a job that is somewhat different than your current job, it is up to you to draw a connection for the resume reviewer, so that they will understand how your skills will fit in their organization. The person who reviews your paperwork will not be a mind reader. If you are modest about the skills you can offer, or the results you have achieved, a resume reader may take what you write literally, and be left with a low opinion of your ability: you need to say exactly how good you are. On the other hand, of course, never stretch the truth or lie.\n\nWho should register for this course? The H&S Certificate is aimed at people who work as supervisors within the construction industry (whether or not that is part of their job title), who are required to ensure that activities under their control are undertaken safely. Course duration Option 1 - Conversion Course (for those who have a PHS Certificate - see below): 10 days, either one day a week or two weeks full-time. Option 2 - Full Course (for all others): 15 days, either one day a week or three weeks full-time. For both options, the written exam and practical assessment take half a day. About the course The course provides thorough preparation for the H&S Certificate, which is an award in health and safety specifically designed for the construction industry. It combines theory with practice, ensuring that those who gain the certificate are capable of managing health and safety throughout each stage of the construction process, from planning and design to use and finally demolition. You may already be one step towards gaining an H&S Certificate The PHS (Principles of Health and Safety) Certificate can be taken separately or as part of the H&S Certificate. If you gained this qualification no more than five years before entering for the H&S Certificate, it will be recognised as contributing to your Certificate without the need to repeat that unit of the course. Course content The H&S Certificate is divided into three units. Unit 1 covers the principles of health and safety (and is identical to the PHS Certificate), Unit 2 covers the identification and control of hazards, and Unit 3 deals with practical applications of health and safety. How is the course assessed? Candidates take written examinations for Units 1 and 2. Unit 3 is assessed by a practical examination testing the ability to identify health and safety issues in a construction workplace. Unit 3 needs to be taken within 14 days of a written examination. A full certificate is issued on successful completion of all three units. Funding Candidates from non-EU countries may be eligible for a small number of grants. These cover the cost of tuition, but not examination fees. For details, please contact the Registrar. Enquiries For further information please contact our administration office.'
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
    'It is a mistake to specify your _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q15": ["duties"]}'::jsonb
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
    'Do not include a description of your _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q16": ["objective"]}'::jsonb
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
    'Include soft skills such as an ability to _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q17": ["negotiate"]}'::jsonb
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
    'Think hard about the position so you can ensure that the information in your application is _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q18": ["relevant"]}'::jsonb
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
    'Make the _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q19": ["connection"]}'::jsonb
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
    'Do not be too _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["modest"]}'::jsonb
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
    'Which position is the Certificate intended for? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q21": ["supervisor(s)"]}'::jsonb
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
    'How many days must a student without a PHS Certificate study?',
    'Choose the correct answer.',
    '{"info-q22": ["15 (DAYS)", "15 (days)"]}'
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
    'What is the last stage of the construction process that is covered by the course? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q23": ["demolition"]}'::jsonb
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
    'For how long does a PHS Certificate count towards the H&S Certificate?',
    'Choose the correct answer.',
    '{"info-q24": ["5 YEARS", "5 years"]}'
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
    25,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'What do students learn to identify and deal with in Unit 2? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q25": ["hazards"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    26,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'What type of examination is used for Unit 3? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q26": ["practical"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    27,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'What will a grant pay for? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q27": ["tuition"]}'::jsonb
  );


END$$;


COMMIT;