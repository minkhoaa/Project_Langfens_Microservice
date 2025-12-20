-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T20:26:32.425194
-- Source: ielts-mentor.com
-- Title: GT Reading 38 Section 1 - Volunteers &  Camping in the bush
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-38-section-1-volunteers-camping-in-the-bush
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-38-section-1-volunteers-camping-in-the-bush'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-38-section-1-volunteers-camping-in-the-bush';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-38-section-1-volunteers-camping-in-the-bush';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-38-section-1-volunteers-camping-in-the-bush';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-38-section-1-volunteers-camping-in-the-bush',
    'GT Reading 38 Section 1 - Volunteers &  Camping in the bush',
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
    'Reading Passage - GT Reading 38 Section 1 - Volunteers &  Camping in the bush',
    E'# Passage\n\n# CAMPING IN THE BUSH\n\nVOLUNTEERS Thank you for volunteering to work one-on-one with some of the students at our school who need extra help. SMOKING POLICY Smoking is prohibited by law in the classrooms and anywhere on the school grounds. SAFETY AND HEALTH Volunteers are responsible for their own personal safety and should notify the school of any preexisting medical conditions. Prescription and any other medications that you normally carry with you must be handed into the school nurse on arrival and collected on departure. If you require them, the nurse will dispense them to you in her office. SIGN IN A signing book is located at office reception. Please sign this register every time you come to the school. This is important for insurance purposes and emergency situations. After signing the book, collect a Visitor’s badge from the office. This must be worn at all times when you are on school premises. Remember to return the badge afterwards. MESSAGES Teachers will communicate with volunteers via telephone, email or messages left at the office. Always ask for messages. You may communicate with teachers in the same way – the preferred method is to leave a memo in the relevant teacher’s pigeonhole. These can be found at the end of the corridor in the staffroom block. WORK HOURS We understand that your time commitment is entirely voluntary and therefore flexible. If your personal schedule should change and this affects your availability, please contact the Coordinator for Volunteers at the school on extension 402; alternatively, you could drop into her office situated in F block. ROLE OF THE COORDINATOR The Coordinator is responsible for matching volunteer tutors with students, organising tutorial rooms, ensuring student attendance and overseeing volunteer tutor training. If you encounter any problems, contact her as above.\n\nMINIMAL IMPACT BUSH WALKING Responsible campers observe minimal impact bush walking practices. This is a code of ethics and behaviour aimed at preserving the natural beauty of bush walking areas. PLANNING Good planning is the key to safe and successful camping trips. Obtaining a camping permit in advance of leaving to camp out overnight in a national park is obligatory. Bookings are also compulsory for some parks. There could be limits on group sizes in some parks. Occasionally campsites may be closed owing to bush-fire danger or for other reasons. Always obtain permission from the owner prior to crossing private property. EQUIPMENT As well as your usual bush walking gear, you will need the right equipment for camping. A fuel stove and fuel for cooking is essential: not only is it safer, faster and cleaner; but it is easier to use in wet weather. It is recommended that you pitch a freestanding tent which requires few pegs and therefore has less eco-logical impact. Take a sleeping mat, if you have one, to put your sleeping bag on for a more comfortable night’s sleep. You will also need a hand trowel to bury human waste – for proper sanitation and hygiene. CAMPFIRES The traditional campfire actually causes a huge amount of environmental damage. If you gather firewood, you are removing the vital habitat of insects, reptiles, birds and small mammals. When campfires lead to bush-fires, they create enormous danger to native bush inhabitants and bush-walkers alike and result in destruction of the environment. Under no circumstances should you light a fire in the bush. CAMPSITES Erect your tent at an existing site if possible; otherwise try to find a spot where you won’t damage vegetation. Never cut branches or move rocks or disturb the soil unnecessarily. Aim to leave your campsite as you found it or even cleaner. RUBBISH Remove all rubbish – carry it out with you. Don’t attempt to burn or bury rubbish because this creates a fire hazard and/or disturbs the soil. Animals can dig up buried rubbish and scatter it about. Never feed the local wildlife – carry out all food scraps as these disturb the natural nutrient balance and can create weed problems. WALK SAFELY Keep on the track. Wear footwear suitable for the terrain. Take a map.\n\nThe passage refers to three ways in which campers should behave. Classify the following behaviours as something that campers A must do B may do C must not do Write the correct letter A, B or C, in boxes 8–14 on your answer sheet. 8. get the landowner’s consent before walking across his land 9. Use a sleeping mat 10. Make a campfire in the bush 11. Feed the birds 12. Use a freestanding tent 13. Dig a hole to bury rubbish in 14. Get authorisation before setting out to camp in a national park'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SHORT_ANSWER',
    'READING',
    2,
    'As a volunteer, you will be helping students individually.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q1": ["As a volunteer"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'SHORT_ANSWER',
    'READING',
    2,
    'You may smoke in the playground.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q2": ["5"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SHORT_ANSWER',
    'READING',
    2,
    'You cannot take any medicine while at the school.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q3": ["0"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SHORT_ANSWER',
    'READING',
    2,
    'If you forget to sign the register, you won’t be insured for accidents.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q4": ["If you forget to sign the register"]}'::jsonb
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
    'The best way of communicating with teachers is in writing.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q5": ["TRUE"]}'::jsonb
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
    'You can choose your own hours of work.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q6": ["TRUE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SHORT_ANSWER',
    'READING',
    2,
    'The coordinator keeps student attendance rolls.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q7": ["TRUE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SHORT_ANSWER',
    'READING',
    2,
    'get the landowner’s consent before walking across his land',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q8": ["get the landowner"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Use a sleeping mat',
    'Choose the correct answer.',
    '{"info-q9": ["B", "b"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Make a campfire in the bush',
    'Choose the correct answer.',
    '{"info-q10": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Feed the birds',
    'Choose the correct answer.',
    '{"info-q11": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Use a freestanding tent',
    'Choose the correct answer.',
    '{"info-q12": ["B", "b"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Dig a hole to bury rubbish in',
    'Choose the correct answer.',
    '{"info-q13": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Get authorisation before setting out to camp in a national park',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);


END$$;


COMMIT;