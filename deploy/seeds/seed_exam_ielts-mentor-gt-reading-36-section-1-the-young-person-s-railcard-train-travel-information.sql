-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T21:58:32.129094
-- Source: ielts-mentor.com
-- Title: GT Reading 36 Section 1 - The Young Person's Railcard & Train Travel Information
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-36-section-1-the-young-person-s-railcard-train-travel-information
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-36-section-1-the-young-person-s-railcard-train-travel-information'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-36-section-1-the-young-person-s-railcard-train-travel-information';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-36-section-1-the-young-person-s-railcard-train-travel-information';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-36-section-1-the-young-person-s-railcard-train-travel-information';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-36-section-1-the-young-person-s-railcard-train-travel-information',
    'GT Reading 36 Section 1 - The Young Person''s Railcard & Train Travel Information',
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
    'Reading Passage - GT Reading 36 Section 1 - The Young Person''s Railcard & Train Travel Information',
    E'# Passage\n\n# The Young Person''s Railcard & TRAIN TRAVEL INFORMATION\n\nA Young Person''s Railcard gives young people the opportunity to purchase discounted rail tickets across Britain. Just imagine where it could take you - to festivals, to see distant friends or to London for a weekend break.\n\nWho can apply? Absolutely anybody between 16 and 25 can apply. You will need to provide proof that you are under 26 years of age. For this, only your birth certificate, driving licence, passport or medical card will be acceptable. Alternatively, if you are a mature student over this age but in full-time education, you can also apply. In order to prove your eligibility, you will need to get your headteacher, tutor, or head of department to sign the application form as well as one of your photos, the latter also needing to be officially stamped. ''Full-time education'' is defined as over 15 hours per week for at least 20 weeks a year. Then go along to any major railway station, rail-appointed travel agent or authorised student travel office with your completed application form from this leaflet, together with £28, two passport-sized photos and proof of eligibility.\n\nUsing your railcard You can use it at any time - weekends, Bank Holidays or during the week. But if you travel before 10 am Monday to Friday (except during July and August) minimum fares will apply. For full details of these, please ask at your local station or contact a rail-appointed travel agent.\n\nConditions In cases where a railcard does not bear the user''s signature, it will be treated as invalid. Neither your railcard nor any tickets bought with it may be used by anybody else. Unless there are no purchase facilities available at the station where you began your journey, you will be required to pay the full fare if you are unable to produce a valid ticket for inspection during a journey. Reduced rate tickets are not available for first-class travel or for Eurostar links to France and Belgium. Passengers will be charged the full rate if they want to use these services.\n\n1. Railcard applicants over 25 need to be involved in ............................. . 2. For mature, full-time students, one of the photographs submitted must be signed and ............................. . 3. At certain times of the year, there are no ............................ for railcard holders at any time of day. 4. If your railcard doesn''t have your ............................. it will be impossible to use it for travel. 5. The benefits of a railcard are not transferable to ............................. . 6. If you have no ticket but boarded a train at a station without any ............................. you will still be eligible for a discounted ticket. 7. If railcard holders wish to use the Eurostar network they must pay the ............................. .\n\nTICKET TYPE | DISCOUNT* | NOTES standard returns | 20% | return within 60 days of outward trip same day returns | 25% | ticket cannot be altered or refunded children | 40% | children between 4 and 11 students | 25% | student card must be shown senior citizens | 25% | seniors card must be shown groups (10-25 people) | 15% | discount on each section of the trip globe-trotter tickets | according to ticket | Railpass, Tourist Card, Econopass -------------------------------------------------------------------------------------------------------- * Only one discount may apply to each fare. Tickets may be refunded not later than 5 minutes before the departure of the train for a charge of 15% of the ticket price, or the journey may be changed to another day for a charge of 10% of the ticket price. (Not applicable to same day returns.) You may change your ticket once without charge for a journey on the same day as the original ticket. INFORMATION OF INTEREST TO TRAVELLERS • When you buy your ticket it is up to you to check that the dates and times of the journey on it are exactly as you requested. • Ticket control and access to each train platform will be open until 2 minutes before departure of the train. • Each traveller may take one suitcase and one item of hand luggage. You may also check in 15kgs. of luggage not later than 30 minutes before departure, at no extra charge. • If you would like to charter a train, or make reservations for over 25 passengers travelling together, call the Sales Department.\n\nIf the arrival of your train at your destination is delayed by more than 5 minutes according to the timetable, we will refund the full price of your ticket if the delay is caused by our company.\n\nLarge groups people who want to reserve seats should get in touch with the 9 ........................... . If travellers cancel their trip, they will usually receive back the ticket price less 10 ........................... , or they may change the date of their trip by paying 11 ........................... of the original value. These concessions do not apply in the case of 12 ........................... . It is the passenger''s responsibility to make sure the 13 ........................... and are correct. Travellers should ensure they are ready to board the train with at least 14 ........................... to spare. They may take a suitcase with them in the carriage as well as hand luggage. A traveller may check in 15 kilos maximum weight of luggage but this must be done at least 30 minutes before the train leaves.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Railcard applicants over 25 need to be involved in _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q1": ["full-time education"]}'::jsonb
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
    'For mature, full-time students, one of the photographs submitted must be signed and _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q2": ["For mature"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'At certain times of the year, there are no _______ for railcard holders at any time of day.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q3": ["minimum fares"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'If your railcard doesn''t have your _______ it will be impossible to use it for travel.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q4": ["signature"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'The benefits of a railcard are not transferable to _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q5": ["anybody else"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'If you have no ticket but boarded a train at a station without any _______ you will still be eligible for a discounted ticket.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q6": ["purchase facilities"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'If railcard holders wish to use the Eurostar network they must pay the _______ .Readthe text below and answerQuestions 8-14.TRAIN TRAVEL INFORMATIONWe offer several distinct options for you to choose...',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q7": ["full fare", "", "full rate"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Choose the correct letter, A, B, C or D.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Choose the correct letter, A, B, C or D.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Choose the correct letter, A, B, C or D.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Choose the correct letter, A, B, C or D.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Choose the correct letter, A, B, C or D.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Choose the correct letter, A, B, C or D.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Choose the correct letter, A, B, C or D.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);


END$$;


COMMIT;