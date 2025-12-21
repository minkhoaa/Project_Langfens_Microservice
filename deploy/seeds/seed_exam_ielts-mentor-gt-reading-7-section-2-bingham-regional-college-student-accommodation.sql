-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T12:30:22.232697
-- Source: ielts-mentor.com
-- Title: GT Reading 7 Section 2 - Bingham Regional College & Student Accommodation
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-7-section-2-bingham-regional-college-student-accommodation
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-7-section-2-bingham-regional-college-student-accommodation'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-7-section-2-bingham-regional-college-student-accommodation';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-7-section-2-bingham-regional-college-student-accommodation';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-7-section-2-bingham-regional-college-student-accommodation';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-7-section-2-bingham-regional-college-student-accommodation',
    'GT Reading 7 Section 2 - Bingham Regional College & Student Accommodation',
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
    'Reading Passage - GT Reading 7 Section 2 - Bingham Regional College & Student Accommodation',
    E'**Questions 15-20:**\n\nDo the following statements agree with the information given in the text about the International Students'' Orientation Programme?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 21-27:**\n\nLook at the five accommodation options A-E. Which option is described by each statement below?\n\nWrite the correct letter, **A-E**.\n\n*NB: You may use any letter more than once.*\n\n---\n\n# BINGHAM REGIONAL COLLEGE\n\n## International Students'' Orientation Programme\n\n**What is it?**\n\nIt is a course which will introduce you to the College and to Bingham. It takes place in the week before term starts, from 24th - 28th September inclusive, but you should plan to arrive in Bingham on the 22nd or 23rd September.\n\n**Why do we think it is important?**\n\nWe want you to have the best possible start to your studies and you need to find out about all the opportunities that college life offers. This programme aims to help you do just that. It will enable you to get to know the College, its facilities and services. You will also have the chance to meet staff and students.\n\n**How much will it cost?**\n\n**International students (non-European Union students)**\n\nFor those students who do not come from European Union (EU) countries, and who are not used to European culture and customs, the programme is very important and you are strongly advised to attend. Because of this, the cost of the programme, exclusive of accommodation, is built into your tuition fees.\n\n**EU students**\n\nEU students are welcome to take part in this programme for a fee of £195, exclusive of accommodation.\n\nFees are not refundable.\n\n**Accommodation costs (international and EU students)**\n\nIf you have booked accommodation for the year ahead (41 weeks) through the College in one of the College residences (Cambourne House, Hanley House, the Student Village or a College shared house), you do not have to pay extra for accommodation during the Orientation programme. If you have not booked accommodation in the College residences, you can ask us to pre-book accommodation for you for one week only (Orientation Programme week) in a hotel with other international students. The cost of accommodation for one week is approximately £165. Alternatively, you can arrange your own accommodation for that week in a flat, with friends or a local family.\n\n**What is included during the programme?**\n\n**Meals:** lunch and an evening meal are provided as part of the programme, beginning with supper on Sunday 23rd September and finishing with lunch at midday on Friday 28th September. Please note that breakfast is not available.\n\n**Information sessions:** including such topics as accommodation, health, religious matters, welfare, immigration, study skills, careers and other ''essential information''.\n\n**Social activities:** including a welcome buffet and a half-day excursion round Bingham.\n\n**Transport:** between your accommodation and the main College campus, where activities will take place.\n\n---\n\n# Student Accommodation\n\nThe College offers five basic accommodation options. Here is some information to help you make your choice.\n\n**A. CAMBOURNE HOUSE** - self-catering, student residence, located in the town centre about 2 miles from the main College campus. Up to 499 students live in 6, 7 and 8 bedroom flats, all with en-suite shower rooms. Rent is £64 per week, including bills (not telephone). Broadband Internet connections and telephones, with communal kitchen/dining and lounge areas. Parking space is available, with permits costing £60 per term.\n\n**B. STUDENT VILLAGE** - features 3, 4, 5 and 7 bedroom, self-catering shared houses for 250 students close to the main College campus. Rent is £60 per week inclusive of bills (except telephone). Parking is available with permits costing £90 for the academic year.\n\n**C. HANLEY HOUSE** - a second, modern, self-catering residence in the town centre for 152 students. Eighteen rooms per floor with communal kitchens, lounges, bathrooms and toilets. Rent is £53 per week including bills (not telephone). There is no space for parking nearby.\n\n**D. GLENCARRICK HOUSE** - a privately-owned and managed student residence in the town centre above a multi-storey car park, close to a major nightclub and housing 120 students. Rooms are allocated by the College Accommodation Service. Rents range from £58.50 to £68.50 for a single en-suite room or larger en-suite room respectively. A small extra charge is made for electricity.\n\n**E. HOUSE SHARES** - this recent initiative is a range of shared houses for 140 students, conforming to standards set by us to meet all legal safety requirements. A room in a shared house costs between £45 and £55 per week, exclusive of bills, and will be within a 4-mile radius of both campuses. As with halls of residence, the rent is payable termly.'
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
    'Participants are advised to arrive one or two days early.',
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
    16,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The cost of the programme for European Union students, excluding accommodation, is £195.',
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
    17,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The number of places available is strictly limited.',
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
    18,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Some students are not charged extra for accommodation during the programme.',
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
    19,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The College will arrange accommodation with local families.',
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
    20,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'You can obtain breakfast at the College for an extra charge.',
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
    21,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'This is possibly inconvenient for car owners.',
    'Choose the correct answer.',
    '{"info-q21": ["C", "c"]}'
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
    'This is best if you like surfing the Web.',
    'Choose the correct answer.',
    '{"info-q22": ["A", "a"]}'
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
    'Of the College residences, this has the fewest students.',
    'Choose the correct answer.',
    '{"info-q23": ["D", "d"]}'
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
    'This is a new option offered by the College.',
    'Choose the correct answer.',
    '{"info-q24": ["E", "e"]}'
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
    'You have to organise parking a year at a time.',
    'Choose the correct answer.',
    '{"info-q25": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    26,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'This accommodation does not belong to the College.',
    'Choose the correct answer.',
    '{"info-q26": ["D", "d"]}'
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
    'Here you definitely do not have your own bathroom.',
    'Choose the correct answer.',
    '{"info-q27": ["C", "c"]}'
  );


END$$;


COMMIT;