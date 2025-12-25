-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T01:53:09.038139
-- Source: mini-ielts.com
-- Title: Theatre Studies Course
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-theatre-studies-course
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-theatre-studies-course'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-theatre-studies-course';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-theatre-studies-course';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-theatre-studies-course';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-theatre-studies-course',
    'Theatre Studies Course',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766602388/ielts/theatre-studies_thumbpad_e97925706d7e.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Theatre Studies Course',
    E'## Questions 1-5\n\nChoose the correct letter, **A**, **B** or **C**.\n\n**1.** What helped Rob to prepare for the play?\n- **A** reading previous reviews\n- **B** watching a film of it\n- **C** going to see it in London\n\n**2.** To prepare the lighting, the students had to\n- **A** go to a theatre workshop\n- **B** read a manual\n- **C** ask a technician\n\n**3.** What do Rob and Mia agree was the weakest part of the performance?\n- **A** the acting\n- **B** the costumes\n- **C** the staging\n\n**4.** What does Rob say about his role in the play?\n- **A** He planned to memorize his lines better.\n- **B** He felt he was not right for the part.\n- **C** He enjoyed working with the other actors.\n\n**5.** What did the group find most challenging?\n- **A** managing the budget\n- **B** designing the set\n- **C** finding suitable props\n\n---\n## Questions 6-10\n\nWhat action is required for each of the following stages in doing the ''year abroad'' option?\n\nChoose **FIVE** answers from the box and write the correct letter, **A-G**, next to questions 6-10.\n\n\n### Actions\n- **A** be on time\n- **B** get a letter of recommendation\n- **C** plan for financial costs\n- **D** make a shortlist of universities\n- **E** apply for a visa\n- **F** read the student handbook\n- **G** attend an interview\n\n\n**6.** in the second year of the course _______\n**7.** when first choosing where to go _______\n**8.** when sending in your application _______\n**9.** when you have been accepted _______\n**10.** when you arrive at the university _______\n',
    E'# Section 1: Theatre Studies Course\n\n**Instructions for the Candidate:**\n\nYou will hear a conversation between a student called Rob, who is in the first year of a Theatre Studies course, and another student called Mia. They are discussing a recent group performance, their feedback on the experience, and future course options.\n\n**Questions 1-10**\n\n**Questions 1-5**\nChoose the correct letter, **A**, **B** or **C**.\nListen carefully to the discussion about the play ''Starlight'', specific comments on the costume design, lighting, and the overall performance evaluation.\n\n**Questions 6-10**\nChoose **FIVE** answers from the box and write the correct letter, **A-G**, next to questions 6-10.\nYou will need to identify the correct action for each stage of the ''year abroad'' option mentioned in the conversation.\n\n*Note: This text is provided for context. In the actual examination, you will only hear the audio recording and must answer based on what you hear.*'
  ,
    'https://www.youtube.com/embed/s5FV1CHNIag?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What helped Rob to prepare for the play?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. reading previous reviews', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. watching a film of it', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. going to see it in London', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'To prepare the lighting, the students had to',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. go to a theatre workshop', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. read a manual', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. ask a technician', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What do Rob and Mia agree was the weakest part of the performance?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the acting', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the costumes', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the staging', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What does Rob say about his role in the play?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. He planned to memorize his lines better', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. He felt he was not right for the part', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He enjoyed working with the other actors', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What did the group find most challenging?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. managing the budget', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. designing the set', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. finding suitable props', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'in the second year of the course',
    '',
    '{"info-q6": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'when first choosing where to go',
    '',
    '{"info-q7": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'when sending in your application',
    '',
    '{"info-q8": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'when you have been accepted',
    '',
    '{"info-q9": ["G", "g"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'when you arrive at the university',
    '',
    '{"info-q10": ["C", "c"]}'
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 5, E'## Questions 1-5\n\nChoose the correct letter, **A**, **B** or **C**.\n\n**1.** What helped Rob to prepare for the play?\n- **A** reading previous reviews\n- **B** watching a film of it\n- **C** going to see it in London\n\n**2.** To prepare the lighting, the students had to\n- **A** go to a theatre workshop\n- **B** read a manual\n- **C** ask a technician\n\n**3.** What do Rob and Mia agree was the weakest part of the performance?\n- **A** the acting\n- **B** the costumes\n- **C** the staging\n\n**4.** What does Rob say about his role in the play?\n- **A** He planned to memorize his lines better.\n- **B** He felt he was not right for the part.\n- **C** He enjoyed working with the other actors.\n\n**5.** What did the group find most challenging?\n- **A** managing the budget\n- **B** designing the set\n- **C** finding suitable props\n');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 6, 10, E'## Questions 6-10\n\nWhat action is required for each of the following stages in doing the ''year abroad'' option?\n\nChoose **FIVE** answers from the box and write the correct letter, **A-G**, next to questions 6-10.\n\n\n### Actions\n- **A** be on time\n- **B** get a letter of recommendation\n- **C** plan for financial costs\n- **D** make a shortlist of universities\n- **E** apply for a visa\n- **F** read the student handbook\n- **G** attend an interview\n\n\n**6.** in the second year of the course _______\n**7.** when first choosing where to go _______\n**8.** when sending in your application _______\n**9.** when you have been accepted _______\n**10.** when you arrive at the university _______\n');

END$$;


COMMIT;