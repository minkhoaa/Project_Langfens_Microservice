-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T07:44:54.922734
-- Source: mini-ielts.com
-- Title: The Treloar Valley Passenger Ferry
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-the-treloar-valley-passenger-ferry
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-the-treloar-valley-passenger-ferry'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-the-treloar-valley-passenger-ferry';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-the-treloar-valley-passenger-ferry';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-the-treloar-valley-passenger-ferry';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-the-treloar-valley-passenger-ferry',
    'The Treloar Valley Passenger Ferry',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766536696/ielts/damenferry1806_thumbpad_8f6a08af9caa.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - The Treloar Valley Passenger Ferry',
    E'**Questions 1-4:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**Questions 5-10:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.',
    E'# The Treloar Valley Passenger Ferry\n\nYou will hear part of a podcast for visitors to the popular holiday region called the Treloar Valley.\n\n---\n\n## Questions 1-4\n\nChoose the correct letter, **A, B** or **C**.\n\n**1.** The Treloar Valley passenger ferry\n- **A** usually starts services in April.\n- **B** departs at the same time each day.\n- **C** is the main means of transport for local villagers.\n\n**2.** What does the speaker say about the river cruise?\n- **A** It can be combined with a train journey.\n- **B** It''s unsuitable for people who have walking difficulties.\n- **C** The return journey takes up to four hours.\n\n**3.** What information is given about train services in the area?\n- **A** Trains run non-stop between Calton and Plymouth.\n- **B** One section of the rail track is raised.\n- **C** Bookings can be made by telephone or the Internet.\n\n**4.** The ''Rover'' bus ticket\n- **A** can be used for up to five journeys a day.\n- **B** is valid for weekend travel only.\n- **C** has recently gone down in price.\n\n---\n\n## Questions 5-10\n\nLabel the map below. Write the correct letter, **A-H**, next to questions 5-10.\n\n![Treloar Valley Map](https://res.cloudinary.com/df41zs8il/image/upload/v1766536873/ielts/treloar_valley_map.png)\n\n- **5** Bus stop → _______\n- **6** Car park → _______\n- **7** Museum → _______\n- **8** Mill → _______\n- **9** Potter''s studio → _______\n- **10** Cafe → _______\n'
  ,
    'https://www.youtube.com/embed/U3edRudczyA');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'The Treloar Valley passenger ferry',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. usually starts services in April.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. departs at the same time each day.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. is the main means of transport for local villagers.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What does the speaker say about the river cruise?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. It can be combined with a train journey.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It''s unsuitable for people who have walking difficulties.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The return journey takes up to four hours.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What information is given about train services in the area?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Trains run non-stop between Calton and Plymouth.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. One section of the rail track is raised.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Bookings can be made by telephone or the Internet.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'The ''Rover'' bus ticket',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. can be used for up to five journeys a day.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. is valid for weekend travel only.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. has recently gone down in price.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Bus stop',
    '',
    '{"info-q5": ["H", "h"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Car park',
    '',
    '{"info-q6": ["F", "f"]}'
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
    'Museum',
    '',
    '{"info-q7": ["E", "e"]}'
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
    'Mill',
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
    'Potter''s studio',
    '',
    '{"info-q9": ["B", "b"]}'
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
    'Cafe',
    '',
    '{"info-q10": ["D", "d"]}'
  );


END$$;


COMMIT;