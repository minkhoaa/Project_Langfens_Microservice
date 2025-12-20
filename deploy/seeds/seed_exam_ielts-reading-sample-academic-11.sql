-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:04:22.246957
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #11
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-11
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-11'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-11';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-11';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-11';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-11',
    'IELTS Reading Sample (Academic) #11',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #11',
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
    'Reading Passage - IELTS Reading Sample (Academic) #11',
    E'# Passage\n\nAcademic Reading Passage 29\nWHAT A WASTE!\nEvery day, all over the world, unwanted waste is disposed of from both domestic and commercial sources, usually with insufficient attention paid to the resulting problems. The increase in excess refuse and how to dispense with it has become a major headache for the government and the environmental agencies.\nThis has certainly been the case in Britain where there has been a steady rise in the amount of rubbish generated in recent years. In industry, the mining, agriculture and construction sectors are the biggest culprits, being amongst the greatest producers of waste. Also, household waste has grown at a rate of 3% a year as a consequence of society becoming more affluent and thus consuming more goods, resulting in more rubbish to discard. As this waste is economically and environmentally costly to deal with, local authorities have been required to ensure that the arrangements made to dispose of the surplus detritus are efficient and practicable, considering social as well as economic implications.\nFor many years, the preferred option for refuse disposal in Britain has been the landfill. In fact, the UK, more than any other European country, makes use of landfills to get rid of its biodegradable waste. However, problems have arisen with this method and alternative solutions have had to be researched.\nOne of the biggest drawbacks to landfills is the cost. In the past this was not the case as land was plentiful and cheap with abandoned quarries and mines often being utilised. But by 2015, since space for approved and licensed landfills will have run out, viable alternatives to waste disposal have to be found. Another disadvantage is the environmental impact made by the acids and hazardous chemicals that are leaked from the landfills. Older sites depended on these substances being diluted naturally by rain but this often did not occur and surrounding agricultural land was affected and livestock poisoned. Nowadays, more modern landfills use liners within the pits to contain any dangerous material and the liquid is then collected, treated and discharged within the site itself. But perhaps the most apparent annoyance for the general public living in the immediate vicinity of the landfill is the nuisance that results from the traffic, the noise, the dust and the unpleasant odours emanating from the site. Although no risks to human health have been verified, symptoms such as headaches, drowsiness and exhaustion have been reported by people living close to landfills. These may have been caused by toxic emissions from the site but they may be connected to the impact that living next to the sites can have on stress and anxiety.\nIn order to reduce the amount of waste being sent to the landfill, a special tax was introduced in 1996, to discourage this practice. The charges range from two to eleven pounds per tonne depending on the type of rubbish being discarded and due to this tax the amount of waste from the construction industry has been markedly reduced. Other targets have been set to reduce biodegradable waste deposited in these sites by 2006 but it is thought that the greatest impact could be made through the introduction of more intensive recycling, which could be funded from the proceeds of the landfill tax.\nIn Europe, Britain is bottom of the recycling table with the lowest rate of 8% compared to the Netherlands where they recycle 72% of their detritus. According to government research, only 7% of plastic was salvaged, as was only 22% of the six billion glass containers manufactured annually in Britain. On the other hand, the same sources found that 90% of car batteries and 66% of lead is recycled. This proportion is high because of the economic value of the material and so reprocessing is an opportunity to gain an income from an environmentally friendly undertaking. Also, of the thirteen billion steel cans produced yearly, about a quarter come from recycled metal. These goods only consume 25% of the energy needed to make the same products from raw materials.\nBiodegradable wastes can be made into organic compost to use as fertiliser for the land. At present less than half the local authorities have facilities for this and about a fifth of municipal waste is being treated but in some areas, schemes are being set up to collect waste from both domestic properties and supermarkets to help effect this procedure.\nYet even now in the 21st century, less progressive authorities are still constructing and employing incinerators to dispose of waste despite the subsequent health hazards. They also have to confront opposition from the public over a policy which has proved to be the most unpopular technology since the introduction of nuclear power.\nSo, what can be done to encourage more recycling? Probably what should be the government’s priority is the reduction in the number of landfills in regular use. Even materials that are biodegradable such as paper cannot easily be broken down as the landfill pits are constructed to keep air out and moisture in, thus slowing down the process to degrade this matter. Therefore, more reprocessing plants for refuse must be constructed to replace the outmoded landfills. Also, companies should be encouraged to take a more responsible approach to the packaging of their products, only using the minimum and environmentally friendly recycled materials. Then, the public must be convinced of the benefits of recycling and be made aware of the ecological consequences of not recycling. In Britain, more intensive reprocessing would lower the production of gases harmful to the ozone layer by 12.8 million tonnes of carbon a year, the equivalent of taking nearly five million cars off the road. Also, a strong incentive for the public to support recycling is the prospect of higher employment. In Germany, it has been estimated that 150,000 people are employed in the recycling business, a number greater than those employed in the steel industry. It is believed that up to 50,000 jobs could be created in Britain if recycling was adopted.\nWhat will happen in the future regarding the disposal of waste matter very much depends on the attitude and party policies of the particular government in power. Yet, if reforms to the methods of waste disposal are not made, serious environmental problems will arise in the immediate future, the consequences of which are too dire to contemplate.\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_FEATURES',
    'READING',
    2,
    'More household waste is produced because',
    'Choose the correct answer.',
    '{"feature-q1": ["C", "C. as the population becomes wealthier, their capacity to consume more increases"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. there is a lot of mining in Britain', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. dangerous materials are collected in landfills', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. as the population becomes wealthier, their capacity to consume more increases', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. there is relatively little recycling of degradable matter in Britain', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. landfills poison animals', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. a lot of waste from food shops is made into fertilisers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. problems for people residing nearby', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'H. using incinerators is the most popular method of rubbish disposal', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'I. the most common means of waste disposal is burying refuse', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_HEADING',
    'READING',
    2,
    'In Britain',
    'Choose the correct answer.',
    '{"in-britain-q2": ["i", "i. the most common means of waste disposal is burying refuse"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'a. there is a lot of mining in Britain', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'b. dangerous materials are collected in landfills', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'c. as the population becomes wealthier, their capacity to consume more increases', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'd. there is relatively little recycling of degradable matter in Britain', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'e. landfills poison animals', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'f. a lot of waste from food shops is made into fertilisers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'g. problems for people residing nearby', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'h. using incinerators is the most popular method of rubbish disposal', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'i. the most common means of waste disposal is burying refuse', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Landfills create',
    'Choose the correct answer.',
    '{"feature-q3": ["G", "G. problems for people residing nearby"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. there is a lot of mining in Britain', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. dangerous materials are collected in landfills', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. as the population becomes wealthier, their capacity to consume more increases', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. there is relatively little recycling of degradable matter in Britain', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. landfills poison animals', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. a lot of waste from food shops is made into fertilisers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. problems for people residing nearby', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'H. using incinerators is the most popular method of rubbish disposal', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'I. the most common means of waste disposal is burying refuse', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Unlike Europe',
    'Choose the correct answer.',
    '{"feature-q4": ["D", "D. there is relatively little recycling of degradable matter in Britain"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. there is a lot of mining in Britain', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. dangerous materials are collected in landfills', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. as the population becomes wealthier, their capacity to consume more increases', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. there is relatively little recycling of degradable matter in Britain', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. landfills poison animals', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. a lot of waste from food shops is made into fertilisers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. problems for people residing nearby', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'H. using incinerators is the most popular method of rubbish disposal', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'I. the most common means of waste disposal is burying refuse', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Landfills are not approved of because',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Athey use agricultural land.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bthey have always been expensive to run.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cthey need to have a licence.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dthey produce dangerous emissions.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'A tax was imposed in order',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Ato encourage recycling.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bto dissuade people from using landfills.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cto punish the building industry.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dto gather money for the government.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nSolutions to the problem of how to dispose \n	of excess rubbish must be found. With the dramatic increase in both 7 and industrial rubbish, the 8 must devise new policies to deal with the matter. \n	The well established 9 are now \n	considered 10 so it is preferable \n	to send the refuse to 11 works _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q7": ["domestic"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nSolutions to the problem of how to dispose \n	of excess rubbish must be found. With the dramatic increase in both 7 and industrial rubbish, the 8 must devise new policies to deal with the matter. \n	The well established 9 are now \n	considered 10 so it is preferable \n	to send the refuse to 11 works _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q8": ["government"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nSolutions to the problem of how to dispose \n	of excess rubbish must be found. With the dramatic increase in both 7 and industrial rubbish, the 8 must devise new policies to deal with the matter. \n	The well established 9 are now \n	considered 10 so it is preferable \n	to send the refuse to 11 works _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q9": ["landfills"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nSolutions to the problem of how to dispose \n	of excess rubbish must be found. With the dramatic increase in both 7 and industrial rubbish, the 8 must devise new policies to deal with the matter. \n	The well established 9 are now \n	considered 10 so it is preferable \n	to send the refuse to 11 works _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": ["outmoded"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nSolutions to the problem of how to dispose \n	of excess rubbish must be found. With the dramatic increase in both 7 and industrial rubbish, the 8 must devise new policies to deal with the matter. \n	The well established 9 are now \n	considered 10 so it is preferable \n	to send the refuse to 11 works _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["reprocessing", "recycling"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nSolutions to the problem of how to dispose \n	of excess rubbish must be found. With the dramatic increase in both 7 and industrial rubbish, the 8 must devise new policies to deal with the matter. \n	The well established 9 are now \n	considered 10 so it is preferable \n	to send the refuse to 11 works _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["degrade"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nSolutions to the problem of how to dispose \n	of excess rubbish must be found. With the dramatic increase in both 7 and industrial rubbish, the 8 must devise new policies to deal with the matter. \n	The well established 9 are now \n	considered 10 so it is preferable \n	to send the refuse to 11 works _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q13": ["recycled"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nSolutions to the problem of how to dispose \n	of excess rubbish must be found. With the dramatic increase in both 7 and industrial rubbish, the 8 must devise new policies to deal with the matter. \n	The well established 9 are now \n	considered 10 so it is preferable \n	to send the refuse to 11 works _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q14": ["consequences"]}'::jsonb
  );


END$$;


COMMIT;