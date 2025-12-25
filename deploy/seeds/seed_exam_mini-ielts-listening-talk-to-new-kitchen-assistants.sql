-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T01:28:27.906789
-- Source: mini-ielts.com
-- Title: Talk to new kitchen assistants
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-talk-to-new-kitchen-assistants
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-talk-to-new-kitchen-assistants'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-talk-to-new-kitchen-assistants';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-talk-to-new-kitchen-assistants';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-talk-to-new-kitchen-assistants';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-talk-to-new-kitchen-assistants',
    'Talk to new kitchen assistants',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766600907/ielts/kitchen-assistant_thumbpad_b27d98e683a9.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Talk to new kitchen assistants',
    E'## Questions 1-4\n\nChoose the correct letter, **A**, **B** or **C**.\n\n**1.** What does Joy Parkins say she likes most about her job?\n- **A** dealing with the public\n- **B** the variety of the work\n- **C** working with a team\n\n**2.** What is Joy''s main concern about the kitchen assistants'' appearance?\n- **A** jewellery\n- **B** hair\n- **C** footwear\n\n**3.** Why is it particularly busy in the kitchen today?\n- **A** It is a public holiday.\n- **B** The head chef is absent.\n- **C** It is the weekend.\n\n**4.** Which piece of kitchen equipment are assistants under 18 not allowed to use?\n- **A** the food mixer\n- **B** the meat slicer\n- **C** the electric fryers\n\n---\n## Questions 5-6\n\nChoose **TWO** letters, **A-E**.\n\nWhich TWO things does Joy say about the job?\n\n- **A** They have to follow orders immediately.\n- **B** The kitchen gets very hot.\n- **C** They may not be able to take a break.\n- **D** They have to do overtime.\n- **E** The work is physically demanding.\n\n---\n## Questions 7-10\n\nWhat responsibility does each of the following staff members have?\n\nChoose **FOUR** answers from the box and write the correct letter, **A-F**, next to Questions 7-10.\n\n### Responsibilities:\n- **A** training courses\n- **B** food stocks\n- **C** first aid\n- **D** breakages\n- **E** staff discounts\n- **F** timetables\n\n**7.** Joy Parkins _______\n**8.** David Field _______\n**9.** Dexter Wills _______\n**10.** Mike Smith _______\n',
    E'# Orientation for New Kitchen Assistants\n\n**Joy Parkins:**\n"Good morning everyone and welcome. I''m Joy Parkins, the restaurant manager. **I''ll be looking after your induction and running your training courses** during your probationary period. I''m very pleased to see you all here for your first day. You are now part of a vital team, and your work in the kitchen is crucial for the restaurant''s success.\n\nPeople often ask me what I enjoy about this role. For me, it''s definitely **the variety of the work**—no two days are the same, and I love that.\n\nI know it can be daunting at first. The kitchen gets very hot, and it is physically demanding work—you''ll be on your feet all day. However, the most important thing you must remember is that **you have to follow orders immediately**. Speed and accuracy are essential to keep the service running smoothly.\n\nRegarding safety rules: please note that no jewelry is allowed. You must also wear the provided non-slip footwear at all times. Also, a strict rule for those of you under 18: you are **not allowed to use the meat slicer** under any circumstances.\n\nYou might be wondering why it''s so busy today. It''s actually a public holiday, so we are expecting a full house.\n\nI''d like to introduce you to some key staff members who you will be working with. **David Field** is our designated first aider, so if you injure yourself, please go to him. **Dexter Wills** is in charge of reporting breakages—if you drop anything, let him know. **Mike Smith** manages our food stocks and orders supplies. Finally, if you have questions about your shifts, please check the timetables on the noticeboard."\n\nThis summary covers the key points of the orientation talk.'
  ,
    'https://www.youtube.com/embed/P1aLIrkhtCc?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What does Joy Parkins say she likes most about her job?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. dealing with the public', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the variety of the work', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. working with a team', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What is Joy''s main concern about the kitchen assistants'' appearance?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. jewellery', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. hair', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. footwear', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Why is it particularly busy in the kitchen today?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. It is a public holiday.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. The head chef is absent.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It is the weekend.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which piece of kitchen equipment are assistants under 18 not allowed to use?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the food mixer', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the meat slicer', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the electric fryers', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Which TWO things does Joy say about the job? (Selection 1)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. They have to follow orders immediately', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. The kitchen gets very hot', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They may not be able to take a break', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. They have to do overtime', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. The work is physically demanding', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Which TWO things does Joy say about the job? (Selection 2)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. They have to follow orders immediately', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. The kitchen gets very hot', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They may not be able to take a break', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. They have to do overtime', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. The work is physically demanding', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Joy Parkins',
    '',
    '{"info-q7": ["A", "a"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. training courses', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. food stocks', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. first aid', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. breakages', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. staff discounts', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. timetables', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'David Field',
    '',
    '{"info-q8": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. training courses', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. food stocks', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. first aid', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. breakages', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. staff discounts', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. timetables', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Dexter Wills',
    '',
    '{"info-q9": ["D", "d"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. training courses', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. food stocks', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. first aid', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. breakages', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. staff discounts', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. timetables', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Mike Smith',
    '',
    '{"info-q10": ["B", "b"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. training courses', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. food stocks', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. first aid', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. breakages', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. staff discounts', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. timetables', false);



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 4, E'## Questions 1-4\n\nChoose the correct letter, **A**, **B** or **C**.\n\n**1.** What does Joy Parkins say she likes most about her job?\n- **A** dealing with the public\n- **B** the variety of the work\n- **C** working with a team\n\n**2.** What is Joy''s main concern about the kitchen assistants'' appearance?\n- **A** jewellery\n- **B** hair\n- **C** footwear\n\n**3.** Why is it particularly busy in the kitchen today?\n- **A** It is a public holiday.\n- **B** The head chef is absent.\n- **C** It is the weekend.\n\n**4.** Which piece of kitchen equipment are assistants under 18 not allowed to use?\n- **A** the food mixer\n- **B** the meat slicer\n- **C** the electric fryers\n');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 5, 6, E'## Questions 5-6\n\nChoose **TWO** letters, **A-E**.\n\nWhich TWO things does Joy say about the job?\n\n- **A** They have to follow orders immediately.\n- **B** The kitchen gets very hot.\n- **C** They may not be able to take a break.\n- **D** They have to do overtime.\n- **E** The work is physically demanding.\n');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 7, 10, E'## Questions 7-10\n\nWhat responsibility does each of the following staff members have?\n\nChoose **FOUR** answers from the box and write the correct letter, **A-F**, next to Questions 7-10.\n\n### Responsibilities:\n- **A** training courses\n- **B** food stocks\n- **C** first aid\n- **D** breakages\n- **E** staff discounts\n- **F** timetables\n\n**7.** Joy Parkins _______\n**8.** David Field _______\n**9.** Dexter Wills _______\n**10.** Mike Smith _______\n');

END$$;


COMMIT;