-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T16:22:19.613949
-- Source: ielts-mentor.com
-- Title: GT Reading 62: Section 1 - Music Clubs & Biological Research Institute
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-62-section-1-music-clubs-biological-research-institute
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-62-section-1-music-clubs-biological-research-institute'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-62-section-1-music-clubs-biological-research-institute';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-62-section-1-music-clubs-biological-research-institute';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-62-section-1-music-clubs-biological-research-institute';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-62-section-1-music-clubs-biological-research-institute',
    'GT Reading 62: Section 1 - Music Clubs & Biological Research Institute',
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
    'Reading Passage - GT Reading 62: Section 1 - Music Clubs & Biological Research Institute',
    E'# Passage\n\n# Music Clubs & Biological Research Institute\n\nA. Whitehay Youth Music is intended for anyone aged between 6 and 14 who is keen to perform in public. The club is limited to 30 members at any time, and we operate a waiting list for membership. Two concerts are performed every year and every member takes part. Members must have reached at least an intermediate standard on their instrument. The group meets in the Jubilee Hall on Wednesday evenings during term time for rehearsals and for workshops in which members learn how to improve their playing.\n\nB. Whitehay Music Club brings together music lovers from around the district, for enjoyable evenings of food and music. We meet monthly in members'' homes, and during the evening we have a buffet meal and listen to recordings of both well-known and not so well-known music. The music is preceded by a brief talk providing background information about the composers and the music. Every few months we organise a coach trip to a musical event within a radius of 50 km.\n\nC. Whitehay Philharmonic is an amateur orchestra, founded in 1954. Two or three times a year, it performs a wide range of music to large and appreciative audiences from the area, in the town''s Jubilee Hall. New members are always welcome, and can take part in rehearsals, although there may not be room for everyone to perform in the concerts. Because the orchestra only partly finances its performances through ticket sales, members with marketing experience are particularly welcome, in order to build sales.\n\nD. Whitehay Music Society is primarily a fundraising group that organises a range of money-making activities - from street collections to seeking sponsorship from local businesses. The money raised is used to support professional musicians if, for example, illness prevents them from earning a living. As a member, you will receive a monthly newsletter describing our work, and containing details of concerts, operas and other performances, both locally and nationally. Everybody is welcome to join the society: children are particularly welcome, along with their parents.\n\n1. It needs members who can find ways of increasing audience numbers. 2. All its members perform in club concerts. 3. It distributes information about musical events to its members. 4. It requires its members to have reached a certain level as performers. 5. One of its aims is to introduce its members to music they may not be familiar with. 6. It helps children to develop their musical skills. 7. Its performances are popular with local people. 8. It helps people who are in financial need.\n\nWelcome to the Biological Research Institute campus. We hope that your visit will be enjoyable and interesting. Please read the information below and comply with the instructions given.\n\nOn arrival, you should report to the Reception building by the main entrance gate, where you will be issued with a pass. This must be visible at all times during your visit to the campus.\n\nIf you are driving a vehicle, please inform Reception. They will contact Security, who will identify the area where you should park your car. Please ensure that you park it in the designated area. You must keep to the campus speed limit (10 mph) at all times. Cars are parked at the owner''s risk.\n\nFor your own safety, please follow the instructions displayed on noticeboards around the campus, as well as all instructions issued by authorised personnel. Do not enter any restricted areas or touch any machinery or other equipment unless authorised. Visitors must be accompanied by their host at all times whilst on the campus.\n\nEntry into certain areas requires the wearing of special clothing or equipment. This will be provided for you by your host, who will advise you on the appropriate protection for the areas you visit.\n\nUnless your host has previously obtained permission from the Institute management, photography, whether still or video, is not permitted in any part of the campus.\n\nChildren under the age of 16 must be accompanied by an adult at all times, and should only be brought on campus if the Institute management has previously agreed to this. No nursery facilities are available for visiting children.\n\n9. If you come by car, will tell you where to park it. 10. Advice on can be seen on noticeboards. 11. You will need to obtain authorisation before touching equipment such as . 12. Permission from the management is required if you want to do any kind of . 13. The Institute does not provide a for children visiting the campus. 14. You should phone 3333 if any kind of occurs.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'It needs members who can find ways of increasing audience numbers.',
    'Choose the correct answer.',
    '{"info-q1": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'All its members perform in club concerts.',
    'Choose the correct answer.',
    '{"info-q2": ["A", "a"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'It distributes information about musical events to its members.',
    'Choose the correct answer.',
    '{"info-q3": ["D", "d"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'It requires its members to have reached a certain level as performers.',
    'Choose the correct answer.',
    '{"info-q4": ["A", "a"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'One of its aims is to introduce its members to music they may not be familiar with.',
    'Choose the correct answer.',
    '{"info-q5": ["B", "b"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'It helps children to develop their musical skills.',
    'Choose the correct answer.',
    '{"info-q6": ["A", "a"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Its performances are popular with local people.',
    'Choose the correct answer.',
    '{"info-q7": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'It helps people who are in financial need.',
    'Choose the correct answer.',
    '{"info-q8": ["D", "d"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'If you come by car, _______ will tell you where to park it.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q9": ["SECURITY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Advice on _______ can be seen on noticeboards.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q10": ["SAFETY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'You will need to obtain authorisation before touching equipment such as _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q11": ["MACHINERY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    12,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Permission from the management is required if you want to do any kind of _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q12": ["PHOTOGRAPHY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'The Institute does not provide a _______ for children visiting the campus.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q13": ["NURSERY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    14,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'You should phone 3333 if any kind of _______ occurs.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q14": ["ACCIDENT"]}'::jsonb
  );


END$$;


COMMIT;