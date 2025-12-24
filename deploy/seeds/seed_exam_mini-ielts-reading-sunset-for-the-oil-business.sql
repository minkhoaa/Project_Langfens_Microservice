-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T20:36:52.741466
-- Source: mini-ielts.com
-- Title: Sunset for the Oil Business
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-sunset-for-the-oil-business
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-sunset-for-the-oil-business'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-sunset-for-the-oil-business';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-sunset-for-the-oil-business';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-sunset-for-the-oil-business';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-sunset-for-the-oil-business',
    'Sunset for the Oil Business',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://images.mini-ielts.com/images/2022/05/sunset-for-the-oil-business_resized.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Sunset for the Oil Business',
    E'**Questions 1-5:**\nDo the following statements agree with the claims of the writer?\n\nWrite\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this\n\n---\n\n**Questions 6-9:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**Questions 10-14:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n---\n\n### Images for Questions 6-9\n\n\n![Question 6-9 Option A](https://ieltstrainingonline.com/wp-content/uploads/2019/09/46-IELTS-Reading-28-v28111-q27-40-32-35-300x169.jpg)\n',
    E'**Paragraph A.**\\nThe world is about to run out of oil. Or perhaps not. It depends whom you believe…\\n\\n**Paragraph B.**\\nMembers of the Department Analysis Centre (ODAC) recently met in London and presented technical data that support their grim forecast that the world is perilously close to running out of oil. Leading lights of this moment, including the geologists Colin Campbell, rejected rival views presented by American geological survey and the international energy agency that contradicted their findings. Dr Campbell even decried the amazing display of ignorance, denial and obfuscation by government, industry and academics on this topic.\\n\\n**Paragraph C.**\\nSo is the oil really running out? The answer is easy: Yes. Nobody seriously disputes the notion that oil is, for all practical purposes, a non-renewable resource that will run out someday, be that years or decades away. The harder question is determining when precisely oil will begin to get scarce. And answering that question involves scaling Hubbert’s peak.\\n\\n**Paragraph D.**\\nM. King Hubbert, a Shell geologist of legendary status among depletion experts, forecast in 1956 that oil production in the United States would peak in the early 1970s and then slowly decline, in something resembling a bell-shaped curve. At the time, his forecast was controversial, and many rubbished it. After 1970, however, empirical evidence proved him correct: oil production in America did indeed peak and has been in decline ever since.\\n\\n**Paragraph E.**\\nDr Hubbert’s analysis drew on the observation that oil production in a new area typically rises quickly at first, as the easiest and cheapest reserves are tapped. Over time, reservoirs age and go into decline, and so lifting oil becomes more expensive. Oil from that area then becomes less competitive in relation to other fuels, or to oil from other areas. As a result, production slows down and usually tapers off and declines. That, he argued, made for a bell-shaped curve.\\n\\n**Paragraph F.**\\nHis successful prediction has emboldened a new generation of geologists to apply his methodology on a global scale. Chief among them are the experts at ODAC, who worry that the global peak in production will come in the next decade. Dr Campbell used to argue that the peak should have come already; he now thinks it is just around the corner. A heavyweight has now joined this gloomy chorus. Kenneth Deffeyes of Princeton University argues in a lively new book (“The View from Hubbert’s Peak”) that global oil production could peak as soon as 2004.\\n\\n**Paragraph G.**\\nThat sharply contradicts mainstream thinking. America’s Geological Survey prepared an exhaustive study of oil depletion last year (in part to rebut Dr Campbell’s arguments) that put the peak of production some decades off. The IEA has just weighed in with its new “World Energy Outlook”, which foresees enough oil to comfortably meet the demand to 2020 from remaining reserves. René Dahan, one of ExxonMobil’s top managers, goes further: with an assurance characteristic of the world’s largest energy company, he insists that the world will be awash in oil for another 70 years.\\n\\n**Paragraph H.**\\nWho is right? In making sense of these wildly opposing views, it is useful to look back at the pitiful history of oil forecasting. Doomsters have been predicting dry wells since the 1970s, but so far the oil is still gushing. Nearly all the predictions for 2000 made after the 1970s oil shocks were far too pessimistic. America’s Department of Energy thought that oil would reach $150 a barrel (at 2000 prices); even Exxon predicted a price of $100.\\n\\n**Paragraph I.**\\nMichael Lynch of DRI-WEFA, an economic consultancy, is one of the few oil forecasters who has got things generally right. In a new paper, Dr Lynch analyses those historical forecasts. He finds evidence of both bias and recurring errors, which suggests that methodological mistakes (rather than just poor data) were the problem. In particular, he faults forecasters who used Hubbert-style analysis for relying on fixed estimates of how much “ultimately recoverable” oil there really is below ground, in the industry’s jargon: that figure, he insists, is actually a dynamic one, as improvements in infrastructure, knowledge and technology raise the amount of oil which is recoverable.\\n\\n**Paragraph J.**\\nThat points to what will probably determine whether the pessimists or the optimists are right: technological innovation. The first camp tends to be dismissive of claims of forthcoming technological revolutions in such areas as deep-water drilling and enhanced recovery. Dr Deffeyes captures this end-of-technology mindset well. He argues that because the industry has already spent billions on technology development, it makes it difficult to ask today for new technology, as most of the wheels have already been invented.\\n\\n**Paragraph K.**\\nYet techno-optimists argue that the technological revolution in oil has only just begun. Average recovery rates (how much of the known oil in a reservoir can actually be brought to the surface) are still only around 30-35%. Industry optimists believe that new techniques on the drawing board today could lift that figure to 50-60% within a decade.\\n\\n**Paragraph L.**\\nGiven the industry’s astonishing track record of innovation, it may be foolish to bet against it. That is the result of adversity: the nationalisations of the 1970s forced Big Oil to develop reserves in expensive, inaccessible places such as the North Sea and Alaska, undermining Dr Hubbert’s assumption that cheap reserves are developed first. The resulting upstream investments have driven down the cost of finding and developing wells over the last two decades from over $20 a barrel to around $6 a barrel. The cost of producing oil has fallen by half, to under $4 a barrel.\\n\\n**Paragraph M.**\\nSuch miracles will not come cheap, however, since much of the world’s oil is now produced in ageing fields that are rapidly declining. The IEA concludes that global oil production need not peak in the next two decades if the necessary investments are made. So how much is necessary? If oil companies are to replace the output lost at those ageing fields and meet the world’s ever-rising demand for oil, the agency reckons they must invest $1 trillion in non-OPEC countries over the next decade alone. That’s quite a figure.\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Hubbert has a high-profile reputation amongst ODAC members.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Oil is likely to last longer than some other energy sources.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The majority of geologists believe that oil with start to run out sometime this decade.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Over 50 percent of the oil we know about is currently being recovered.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'History has shown that some of Hubbert’s principles were mistaken.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Many people believed Hubbert’s theory was _______ when it was originally presented.',
    '',
    '{"blank-q6": ["CONTROVERSIAL"]}'::jsonb
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
    '(1) When an oilfield is _______ , it is easy to…',
    '',
    '{"blank-q7": ["TAPPED"]}'::jsonb
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
    '(2) The recovery of the oil gets more _______ as the reservoir gets older',
    '',
    '{"blank-q8": ["EXPENSIVE"]}'::jsonb
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
    '(3) The oilfield can’t be as _______ as other areas.',
    '',
    '{"blank-q9": ["COMPETITIVE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_FEATURES',
    'READING',
    2,
    'has found fault in the geological research procedure',
    '',
    '{"feature-q10": ["E", "E"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_FEATURES',
    'READING',
    2,
    'has provided the longest-range forecast regarding oil supply',
    '',
    '{"feature-q11": ["D", "D"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_FEATURES',
    'READING',
    2,
    'has convinced others that oil production will follow a particular model',
    '',
    '{"feature-q12": ["B", "B"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_FEATURES',
    'READING',
    2,
    'has accused fellow scientists of refusing to see the truth',
    '',
    '{"feature-q13": ["A", "A"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_FEATURES',
    'READING',
    2,
    'has expressed doubt over whether improved methods of extracting oil are possible.',
    '',
    '{"feature-q14": ["C", "C"]}'
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 5, E'## Questions 1-5\n\nDo the following statements agree with the claims of the writer?\n\nWrite\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this\n\n---\n\n');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 6, 9, E'## Questions 6-9\n\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n\n\n![Diagram](https://ieltstrainingonline.com/wp-content/uploads/2019/09/46-IELTS-Reading-28-v28111-q27-40-32-35-300x169.jpg)');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 10, 14, E'## Questions 10-14\n\nLook at the following statements (Questions 10-14) and the list of people below.\n\nMatch each statement with the correct person, **A-E**.\n\nWrite the correct letter **A-E**.\n\n**NB** You may use any letter more than once.\n\n### List of People:\n- **A** Colin Campell\n- **B** M. King Hubbert\n- **C** Kenneth Deffeyes\n- **D** Rene Dahan\n- **E** Michael Lynch\n');

END$$;


COMMIT;