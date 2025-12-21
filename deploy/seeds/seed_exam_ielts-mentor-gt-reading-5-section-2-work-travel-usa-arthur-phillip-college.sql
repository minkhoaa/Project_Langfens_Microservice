-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T11:55:18.356300
-- Source: ielts-mentor.com
-- Title: GT Reading 5 Section 2 - Work & Travel USA & Arthur Phillip College
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-5-section-2-work-travel-usa-arthur-phillip-college
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-5-section-2-work-travel-usa-arthur-phillip-college'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-5-section-2-work-travel-usa-arthur-phillip-college';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-5-section-2-work-travel-usa-arthur-phillip-college';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-5-section-2-work-travel-usa-arthur-phillip-college';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-5-section-2-work-travel-usa-arthur-phillip-college',
    'GT Reading 5 Section 2 - Work & Travel USA & Arthur Phillip College',
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
    'Reading Passage - GT Reading 5 Section 2 - Work & Travel USA & Arthur Phillip College',
    E'**Questions 15-20:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 21-27:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 26-26:**\nChoose the correct heading for each section from the list of headings below.\n\nWrite the correct number, **i-xi**.\n\n---\n\n• return flight from Sydney to Los Angeles (onward travel in the USA not included) • 3 months'' insurance cover • 2 nights'' accommodation on arrival plus meet and greet and airport transfer • arrival orientation by experienced InterExchange staff • visa application fees You also have:\n\n• access to a J-l visa enabling you to work in the USA • an extensive directory of employers • InterExchange support throughout the program • 24-hour emergency support throughout the length of the program\n\nInterExchange has 50 years'' experience in international student exchange programs. 18,000 students from around the world travel yearly to the USA on this very program. InterExchange also offers you work opportunities in other countries.\n\n• is a non-profit, non-governmental organisation • has 700 professional staff in 30 countries worldwide • was founded in 1947 InterExchange operates these programs for students all around the world. It offers you trained and travelled staff, plus full support during the application process. You can choose any job that interests you anywhere in the USA, whether that is working in a law firm in Boston, a famous ski resort in Colorado or serving coffee and doughnuts in the buzzing streets of New York. You can select the period you work and the period you travel; you may want to work for 1 month and travel for 3 or work the entire duration of your stay. The choice is yours.\n\n• a full-time student at an Australian university or TAFE college • presently enrolled, or finishing this year, or you have deferred a year of study • over 18 years old by November in the academic year in which you apply to InterExchange • enthusiastic about the experience of a lifetime ...\n\n15. The program cost includes internal flights within the USA. 16. Emergency assistance offered in the program includes legal advice. 17. InterExchange offers similar programs in countries other than the USA. 18. InterExchange is part of a government program. 19. There are no restrictions on the type of job you can do. 20. There is an upper age limit for applicants.\n\nEach of the short paragraphs below (21-27) gives information about Arthur Phillip College. Read each paragraph and choose which of the linked sections of the website, A-L, would contain this information.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    15,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The program cost includes internal flights within the USA.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    16,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Emergency assistance offered in the program includes legal advice.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    17,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'InterExchange offers similar programs in countries other than the USA.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    18,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'InterExchange is part of a government program.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    19,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'There are no restrictions on the type of job you can do.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    20,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'There is an upper age limit for applicants.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    21,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'All students receive a transcript of results and relevant award documentation when they end their studies with the College.',
    'Choose the correct answer.',
    '{"info-q21": ["J", "j"]}'
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
    'On enrolment, all students receive automatic membership to the Social Club and Public Speaking Club. Students may choose to participate in any arranged activities. The College encourages and promotes...',
    'Choose the correct answer.',
    '{"info-q22": ["K", "k"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    23,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Successful completion and the achievement of an A or B result in some courses will enable students to achieve advanced standing in these subjects if they proceed to university study. For a list of...',
    'Choose the correct answer.',
    '{"info-q23": ["E", "e"]}'
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
    'Arthur Phillip College is one of the top business colleges in Sydney, Australia. The College offers a wide range of educational and training programs in business and related areas. Its accredited...',
    'Choose the correct answer.',
    '{"info-q24": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    25,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'At Arthur Phillip College you will learn from lectures, seminars, case studies, group projects, individual assignments and class workshops. Lectures and seminars present concepts and ideas and...',
    'Choose the correct answer.',
    '{"info-q25": ["G", "g"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    26,
    'MATCHING_HEADING',
    'READING',
    2,
    'Courses at Arthur Phillip College involve an average of 25 hours per week of tuition time, with supervised group study accounting for a further 5 hours per week. At least 10 hours per week of...',
    'Choose the correct answer.',
    '{"courses-at-arthur-phillip-college-involve-an-average-of-25-hours-per-week-of-tuition-time,-with-supervised-group-study-accounting-for-a-further-5-hours-per-week.-at-least-10-hours-per-week-of...-q26": ["i", "i"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    27,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'During this program, you will meet the Director of Studies, teachers and key administrative staff such as the Accommodation Officer and Student Counsellor so that, right from your first day, you will...',
    'Choose the correct answer.',
    '{"info-q27": ["C", "c"]}'
  );


END$$;


COMMIT;