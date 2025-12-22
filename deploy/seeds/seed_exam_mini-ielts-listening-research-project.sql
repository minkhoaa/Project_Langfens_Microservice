-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T09:20:09.822669
-- Source: mini-ielts.com
-- Title: Research Project
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-research-project
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-research-project'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-research-project';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-research-project';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-research-project';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-research-project',
    'Research Project',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Research Project',
    E'**Questions 1-6:** Choose the correct letter, A, B or C.\n\n**Questions 7-8:** Choose the correct answer from A-E. (Answer 1 of 2, Answer 2 of 2)\n\n**Questions 9-10:** Choose the correct answer from A-E. (Answer 1 of 2, Answer 2 of 2)',
    E'# Passage\n\nHello, John. Come in and sit down. You''re here to discuss your research project, are you? Yes. I''ve more or less decided what to do, but I''d like your opinion. Fine. You''ve chosen a topic? Yes, I want to look at how people use public services in their local area. Things like parks and swimming pools. Right. Well, the kind of information you''ll get is very useful for town planning, of course. Do you have a special interest in public services? Not really. It''s just that I found a report in the college library about an investigation that was done ten years ago, and I thought it would be interesting to do a parallel one. 10 years is a relatively short space of time. What do you expect to find? Do you think things will be more or less the same as before? I think there will be some differences. For example, I think the number of people going to the library will have decreased. And I''d guess that older people are using the sports center more often than they used to. Fine. So those are your hypotheses. Now, what sort of data are you going to use? I was thinking of using official records from the management or the local council and analyzing them. They should be easy to obtain. I don''t think that sort of information would be confidential. Yes, you''re probably right. There might not be as much information as you''d like, but it would certainly be the easiest kind of data to work with. But have you considered using a questionnaire as well? It''s okay to get data from more than one source? Absolutely. It''s a bonus. You''ve already done the module on questionnaire design, haven''t you? And it''ll be good to get experience, because next year you''ll have to do something similar for your final dissertation on a bigger scale. Okay. And what are the variables you''ll be looking at? Are you going to look at people''s level of education? Whether they have a degree, for example? I hadn''t planned to. Do you think I should? Well, you might see some interesting patterns. Okay. And that''ll tie in nicely with my plans to analyze the kind of work people do. What about the size of your sample? Have you got any thoughts on the number of questionnaires you might send out? The previous study surveyed 120 people. I don''t think I can really analyze more than 50, working by myself, so I should probably distribute about 80 questionnaires altogether to allow for wastage. Do you think that''s enough? Definitely. I know that your project guidelines recommend a minimum of 100, but that''s an ideal number. And you''re working by yourself. And anyway, this assignment is mainly about giving you practice in research methods. Right. And think of ways you can encourage people to actually complete the questionnaire. For example, to make sure that your questions make sense, you should try them out beforehand. Okay, that''s no problem. My friends will help. Good. Sometimes you get unpredicted responses and you have to rephrase a question. And I know that you usually get a better return if you deliver questionnaires in person, but there will be too many. But I could enclose a stamped envelope for the return post. It''s a bit expensive, but I think it would be worth it. Yes. Good. Some people say that another way of increasing returns is to make the questionnaires anonymous. But usually people put their names on anyway, so I don''t think that would make much difference. Okay. And can you give me a bit more advice about the questionnaire? Would it be a good idea to have a short paragraph at the top explaining what I''m doing and why? Definitely. And don''t forget you''ll need to get a bit of information about your subjects, what age group they''re in and perhaps how long they''ve lived in the area. So you''ll need questions for that. Yes, I suppose that will mean it takes a bit longer to complete. But should I give them my phone number in case there''s anything they''re not sure about? I wouldn''t if I were you. No. Okay. And do I have to use open ended questions as well as closed questions? I know the books say it''s better to have a mixture. Well, it depends. In this case, I''d stick to close questions. The results will be much more manageable like that. If I draft some questions tomorrow, would it be okay to bring them?'
  ,
    'https://www.youtube.com/embed/VIDEO_ID_PLACEHOLDER');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'How did John choose the topic of his research project?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. He thought the information would be useful for town planning.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. He has a special interest in the use of public services.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He read about a similar study which had been done earlier.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'During his research, John is expecting to find that',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The use of public services has altered very little.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. A group of people has changed its habits.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The most frequently used facility is the library.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What is the problem with using official records?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. They may be lacking in detail.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. They may not be readily available.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They may be difficult to analyse.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What does the tutor think about John using a questionnaire to get information?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. He needs to do a course in questionnaire design first.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. He should use this method instead of looking at public records.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He will find the practice he gets useful the following year.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which new variable does John agree to add to his investigation?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Occupation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Income group', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Qualifications', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'How many questionnaires will John distribute?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The same number as in the previous study', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. A greater number than he needs for analysis', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The number recommended in the project guidelines', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which strategies will John use to encourage people to fill out his questionnaire? (Answer 1 of 2)',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Using simple language', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Delivering the questionnaires in person', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Making the questionnaires anonymous', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Providing return envelopes', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Trialing the questionnaire on friends', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which strategies will John use to encourage people to fill out his questionnaire? (Answer 2 of 2)',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Using simple language', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Delivering the questionnaires in person', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Making the questionnaires anonymous', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Providing return envelopes', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Trialing the questionnaire on friends', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which advice does the tutor give John about his questionnaire? (Answer 1 of 2)',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. There should be a mixture of question types.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Some questions should elicit personal information.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. There should be an introduction to explain the survey''s purpose.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. A telephone number should be provided for queries.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. The questions should only take a few minutes to answer.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which advice does the tutor give John about his questionnaire? (Answer 2 of 2)',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. There should be a mixture of question types.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Some questions should elicit personal information.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. There should be an introduction to explain the survey''s purpose.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. A telephone number should be provided for queries.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. The questions should only take a few minutes to answer.', false);


END$$;


COMMIT;