-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T10:13:43.160320
-- Source: mini-ielts.com
-- Title: Self-regulatory focus theory
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-self-regulatory-focus-theory
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-self-regulatory-focus-theory'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-self-regulatory-focus-theory';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-self-regulatory-focus-theory';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-self-regulatory-focus-theory';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-self-regulatory-focus-theory',
    'Self-regulatory focus theory',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766632422/ielts/self-regulatory-focus-theory_t_8b7f98ad3f73.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Self-regulatory focus theory',
    E'## Listening Test\n\nThis test has 10 questions:\n- **Questions 1-10:** Note Completion',
    E'# Listening Test - Self-regulatory Focus Theory and Leadership\n\nThis is a listening practice test about self-regulatory focus theory and its application to leadership. Listen carefully to the audio recording and answer the questions below.\n\n**Instructions:**\nYou will hear the recording ONCE only. Answer all questions based on what you hear in the audio.\n\n**About the Audio:**\nThis lecture covers self-regulatory focus theory, which explains how people''s focus affects their behavior. The theory distinguishes between promotion goals (approaching pleasure and achievement) and prevention goals (avoiding pain and punishment). The audio also discusses how chronic and situational factors influence people''s focus, and how different leadership styles (transformational vs transactional) can inspire different types of focus in followers.\n\n**Question Topics:**\n- Self-regulatory focus theory concepts\n- Factors affecting people''s focus (chronic and situational)\n- How promotion and prevention focus differ\n- Transformational and transactional leadership styles'
  ,
    'https://www.youtube.com/embed/Xcj-__XQVo8?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Promotion goals focus on _______',
    '',
    '{"blank-q1": ["ACHIEVEMENT"]}'::jsonb
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
    'The Chronic Factor comes from one''s _______',
    '',
    '{"blank-q2": ["PERSONALITY"]}'::jsonb
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
    'The _______ Factor',
    '',
    '{"blank-q3": ["SITUATIONAL"]}'::jsonb
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
    'we are more likely to focus on promotion goals when with a _______',
    '',
    '{"blank-q4": ["FRIEND"]}'::jsonb
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
    'Promotion Focus: People think about an ideal version of themselves, their _______ and their gains.',
    '',
    '{"blank-q5": ["ASPIRATIONS"]}'::jsonb
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
    'Leadership behaviour and _______ affects people''s focus',
    '',
    '{"blank-q6": ["STYLE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'pay special attention to the _______ of their followers',
    '',
    '{"blank-q7": ["DEVELOPMENT"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'passionately communicate a clear _______',
    '',
    '{"blank-q8": ["VISION"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'create _______ to make expectations clear',
    '',
    '{"blank-q9": ["STRUCTURES"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Promotion Focus is good for jobs requiring _______',
    '',
    '{"blank-q10": ["INNOVATION"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 10, E'## Questions 1-10\n\nComplete the notes below.\n\nWrite **ONE WORD ONLY** for each answer.\n\n### ''Self-regulatory focus theory'' and leadership\n\n**Self-regulatory focus theory**\n- People''s focus is to approach pleasure or avoid pain\n- Promotion goals focus on **1** _______\n- Prevention goals emphasise avoiding punishment\n\n**Factors that affect people''s focus**\n\n*The Chronic Factor*\n- comes from one''s **2** _______\n\n*The **3** _______ Factor*\n- we are more likely to focus on promotion goals when with a **4** _______\n- we are more likely to focus on prevention goals with our boss\n\n**How people''s focus affects them**\n- Promotion Focus: People think about an ideal version of themselves, their **5** _______ and their gains.\n- Prevention Focus: People think about their ''ought'' self and their obligations\n\n**Leaders**\n- Leadership behaviour and **6** _______ affects people''s focus\n\n*Transformational Leaders:*\n- pay special attention to the **7** _______ of their followers\n- passionately communicate a clear **8** _______\n- inspire promotion focus in followers\n\n*Transactional Leaders:*\n- create **9** _______ to make expectations clear\n- emphasise the results of a mistake\n- inspire prevention focus in followers\n\n**Conclusion**\n- Promotion Focus is good for jobs requiring **10** _______\n- Prevention Focus is good for work such as a surgeon\n- Leaders'' actions affect which focus people use');

END$$;


COMMIT;