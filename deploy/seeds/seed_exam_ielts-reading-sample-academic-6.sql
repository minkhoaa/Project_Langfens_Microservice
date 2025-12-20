-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:04:42.438971
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #6
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-6
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-6'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-6';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-6';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-6';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-6',
    'IELTS Reading Sample (Academic) #6',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #6',
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
    'Reading Passage - IELTS Reading Sample (Academic) #6',
    E'# Passage\n\nAcademic Reading 23 - Passage 1\nChinese Stretch to Catch up with Teenage Model\nTHE young in China are going to desperate lengths to add extra inches to their height in pursuit of celebrity and wealth. They are being urged on by a government shamed by the news that, for the first time in history, the Japanese now stand taller than the Chinese. There is constant pressure on Chinese adolescents to think tall. The government is encouraging them to drink milk as a way of promoting growth, while magazines and television are replete with the images of lanky supermodels and basketball stars.\nOne of the greatest influences has been the astonishing success of Huang Xinye, a 14-year-old schoolgirl from a fishing village in southern China. She was whisked away by talent scouts for a modelling contest late last year. Until then, her 6ft 1in frame had marked her out as a gawky also-ran in the school playground. Having won the contest, Huang was spotted by the international modelling agency Elite and flown to Europe. The news of her glamorous new life and the £12,000 that she won in the modelling contest has inspired thousands to attempt to follow in her footsteps - even if they don''t have her natural advantages.\nTeenagers are inundating hospitals that claim to be able to enhance their height with requests for leg-lengthening operations. Xia Hetao, a doctor whose clinics perform the operation said: "I have received many letters from people saying that, because they were born short, they have suffered and are looking for some solace."\nIf they are accepted on Xia''s waiting list, the aspiring patients are guaranteed only more pain in the short run. Xia slices the thigh bone in half and inserts a steel rod supported by a metal frame on the outside of the bone. The patient cranks the mechanism wider every day, forcing the leg to grow longer. Most can stand the pain only for the month that it takes to stretch an inch, but others persist. The record is held by a young man who gained 6.5 inches. Last year, The Telegraph highlighted the case of the British girl, Emma Richards, 16, from Wadebridge, Cornwall, who underwent a series of leg-lengthening operations to gain an extra five inches so that she could become an air stewardess.\nEven in successful cases in China, the lengthening and attendant physiotherapy and rehabilitation lasts months. Frequently, however, the result is disastrous - the bone never sets properly, but constantly breaks, eventually turning the patient into an invalid.\nThose who either cannot afford the equivalent of the £2,000 that the doctor charges or are unwilling to suffer the pain that it entails can take advantage of scores of products that claim to boost growth - ranging from the absurd to the downright dangerous. In department stores throughout the country, salesmen entice shoppers to try the Wanlijian shoe pad, a magnetic insole that claims to stimulate pressure points in the foot, triggering the release of a natural growth hormone.\nWhite-coated salesmen on the same shopping floors tout a vast array of lotions and pills for enhancing growth, such as "Increasing Brains and Stature" tablets, which contain a double boost for the anxious consumer. Manufacturers of such products claim that sales are booming, thanks in large part to the emergence of towering young role models such as Huang Xinye.\nZhang Mei is one of the many who want to look like Huang. She says cosmetic surgery will create undreamt-of opportunities for her. She and her friends swap tales of operations to lengthen their legs, enlarge their breasts, reduce their thighs, straighten their noses and tuck their eyelids. She said: "A nice body is the passport through the door leading to our dream life."\nTeenage boys have their own giant heroes, in the form of a trio of basketball players known as the "Walking Great Wall". The average height of Yao Ming, Wang Zhizhi and Menk Bateer is 7 ft 6 in. At last year''s Olympic Games, they towered over rivals from Scandinavia and confidently looked the American Dream Team straight in the eye. Since then, China''s growing legion of basketball fans has been proudly confident that a Chinese player will one day establish the country as a great force in the sport.\nFor centuries, the Chinese have derisively referred to the Japanese as "dwarfs", which is why the news that the average Chinese person is now smaller than his Japanese counterpart caused such official consternation. The explanation is undoubtedly the better nutrition enjoyed by recent generations of Japanese, which is why Beijing has made it compulsory for every schoolchild from nursery school upwards to drink a quarter-pint of milk every day. Officials believe that the reason for China''s physical shortfall is the fact that Japanese children drink 18 times as much milk a year as Chinese infants. However, the order to drink milk is not popular with children, most of whom (as with the majority of Chinese) are lactose-intolerant and, therefore, have difficulty digesting the natural sugars in milk. It has been accepted by all, however, as a necessary evil if modern Chinese people are to achieve the greater goal of a taller nation.\nHeight and beauty, though, are not always enough, as Huang Xinye is discovering. "When I have enough money, I will buy a place in Beijing for my family," she said as she boarded a plane for Geneva late last year. Sadly, her parents are still in their fishing village as Huang is struggling to make her name on the international modelling circuit.\nBy DAMIEN MCELROY, The Daily Telegraph | April 10, 2001\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which of the following is the Chinese government using to stimulate their citizens to grow?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Huang Xinye.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Magazines and television.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Dozens of products.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Milk.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'How much taller does the average patient grow after having the bone stretching operation?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, '6.5 inches', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, '1 inch', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, '5 inches', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, '16 inches', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Generally, the Chinese are motivated to have the operation because of the possibility of:',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'being taller than their Japanese counterparts.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'being world class athletes.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'becoming rich and famous.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'overcoming an inferiority complex.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'The main problem with the government’s strategies is that:',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'the operation is too expensive.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'many of the growth stimulating products do not work.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'the recovery process puts the patients’ health at risk.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'the Chinese race cannot digest milk properly.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'The Chinese government adopted the new policy because it:',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'wants China to be a great sporting nation.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'it is embarrassed.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'wants to promotes a better quality of life for its citizens.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'is trying to stimulate the growth of new industries.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Having cosmetic surgery like the stretching operation can result in a more glamorous career.',
    'Choose the correct answer.',
    '{"info-q6": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The stretching operation helps people who feel prejudiced by their lack of height.',
    'Choose the correct answer.',
    '{"info-q7": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Being tall is a question of national pride.',
    'Choose the correct answer.',
    '{"info-q8": ["C", "c"]}'
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
    'Being tall does not necessarily result in success.',
    'Choose the correct answer.',
    '{"info-q9": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The public is easily influenced when it comes to increasing their height.',
    'Choose the correct answer.',
    '{"info-q10": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Until recently, being well above average height was more of a disadvantage than a desirable quality.',
    'Choose the correct answer.',
    '{"info-q11": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The traditional diet is the cause of their nations small stature.',
    'Choose the correct answer.',
    '{"info-q12": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Alternatives are available for people who do not have the means to pay for the stretching operation.',
    'Choose the correct answer.',
    '{"info-q13": ["E", "e"]}'
  );


END$$;


COMMIT;