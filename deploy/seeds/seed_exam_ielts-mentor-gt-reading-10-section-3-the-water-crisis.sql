-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T19:40:53.364027
-- Source: ielts-mentor.com
-- Title: GT Reading 10 Section 3 - The Water Crisis
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-10-section-3-the-water-crisis
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-10-section-3-the-water-crisis'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-10-section-3-the-water-crisis';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-10-section-3-the-water-crisis';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-10-section-3-the-water-crisis';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-10-section-3-the-water-crisis',
    'GT Reading 10 Section 3 - The Water Crisis',
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
    'Reading Passage - GT Reading 10 Section 3 - The Water Crisis',
    E'# Passage\n\n# THE WATER CRISIS\n\ni. American water withdrawal ii. Economic pricing iii. What the future holds iv. Successful measurestaken by some v. The role of research vi. The thirsty sectors vii. Ways of reducing waste viii. Interdependence of natural resources ix. The demands of development x. The consequences for agriculture Paragraph B Paragraph D Paragraph F ..................... . As well as increased consumption per capita, the growing demand for fresh water is due to a bigger global 36 ...................... than in the past. The only way to control this increase in demand is to charge high prices for water while also promoting conservation measures. Improvements in irrigation systems and industrial processes could dramatically increase the efficiency of water use. There are examples of industries in some rich countries that have reduced their consumption rates through price increases, the application of 37 ...................... and recycling. But in agricultural and domestic sectors, the price of water is still subsidised so it is not regarded as a commodity that people need to pay a realistic price for. Other ways of protecting supplies are to reduce water loss resulting from 38 ...................... in the supply systems and to find ways of utilising used water. Longer term measures, such as improved environmental 39 ...................... . would protect the ecosystem and ensure the replenishment of groundwater for future generations. Without such measures, future supplies are uncertain, especially when global warming is expected to interfere with rainfall patterns and to worsen the 40 ...................... already suffered by many countries today.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '28. Paragraph A',
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
    29,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '29. Paragraph B',
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
    30,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '30. Paragraph C',
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
    31,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '31. Paragraph D',
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
    32,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '32. Paragraph E',
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
    33,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '33. Paragraph F',
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
    34,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '34. Paragraph G THE WATER CRISIS Greater efficiency in water use is needed to meet the growing demands of a changing world A. Per capita water usage has been on an upward trend for many years. As countries industrialise and their citizens become more prosperous, their individual water usage increases rapidly. Annual per capita water withdrawals in the USA, for example, are about 1,700 cubic metres, four times the level in China and fifty times the level in Ethiopia. In the 21st century, the world''s limited supply of renewable fresh water is having to meet demands of both larger total population and increased per capita consumption. The only practical ways to resolve this problem in the longer term are economic pricing in conjunction with conservation measures. B. Agriculture consumes about 70% of the world''s fresh water, so improvements in irrigation can make the greatest impact. At present, average efficiency in the use of irrigated water in agriculture may be as low as 50%. Simple changes could improve the rate substantially, though it is unrealistic to expect very high levels of water-use efficiency in many developing countries, faced as they are with a chronic lack of capital and a largely untrained rural workforce. After agriculture, the industry is the second biggest user of water and, in terms of value added per litre used, is sixty times more productive than agriculture. However, some industrial processes use vast amounts of water. For example, production of 1 kg of aluminium might require 1,500 litres of water. Paper production too is often very water-intensive. Though new processes have greatly reduced consumption, there is still plenty of room for big savings in industrial uses of water. C. In rich countries, water consumption has gradually been slowed down by price increases and the use of modern technology and recycling. In the USA, industrial production has risen fourfold since 1950, while water consumption has fallen by more than a third. Japan and Germany have similarly improved their use of water in manufacturing processes. Japanese industry, for example, now recycles more than 75% of process water. However, industrial water consumption is continuing to increase sharply in developing countries. With domestic and agricultural demands also increasing, the capacity of water supply systems is under growing strain. D. Many experts believe that the best way to counter this trend is to impose water charges based on the real cost of supplies. This would provide a powerful incentive for consumers to introduce water-saving processes and recycling. Few governments charge realistic prices for water, especially to farmers. Even in rich California, farmers get water for less than a tenth of the cost of supply. In many developing countries there is virtually no charge for irrigation water, while energy prices are heavily subsidised too (which means that farmers can afford to run water pumps day and night). Water, which was once regarded as a free gift from heaven, is becoming a commodity which must be bought and sold on the open market just like oil. In the oil industry, the price increases which hit the market in the 1970s, coupled with concerns that supplies were running low, led to new energy conservation measures all over the world. It was realised that investing in new sources was a far more costly option than improving the efficiency of use. A similar emphasis on conservation will be the best and cheapest option for bridging the gap between water supply and demand. E. One way to cut back on water consumption is simply to prevent leaks. It is estimated that in some of the biggest cities of the Third World, more than half of the water entering the system is lost through leaks in pipes, dripping taps and broken installations. Even in the UK, losses were estimated at 25% in the early 1990s because of the failure to maintain the antiquated water supply infrastructure. In addition, huge quantities of water are consumed because used water from sewage pipes, storm drains and factories is merely flushed away and discharged into rivers or the sea. The modern approach, however, is to see used water as a resource which can be put to good use - either in irrigation or, after careful treatment, as recycled domestic water. Israel, for instance, has spent heavily on used water treatment. Soon, treated, recycled water will account for most farm irrigation there. There are other examples in cities such as St Petersburg, Florida, where all municipal water is recycled back into domestic systems. F. Another way of conserving water resources involves better management of the environment generally. Interference with the ecosystem can have a severe effect on both local rainfall patterns and water run-off. Forest clearings associated with India''s Kabini dam project reduced local rainfall by 25%, a phenomenon observed in various other parts of the world where large-scale deforestation has taken place. Grass and other vegetation act as a sponge which absorbs rainfall both in the plants and in the ground. Removal of the vegetation means that rainfall runs off the top of the land, accelerating erosion instead of being gradually fed into the soil to renew groundwater. G. Global warming is bound to affect rainfall patterns, though there is considerable disagreement about its precise effects. But it is likely that, as sea levels rise, countries in low-lying coastal areas will be hit by seawater penetration of groundwater. Other countries will experience changes in rainfall which could have a major impact on agricultural yield - either for better or for worse. In broad terms, it is thought that rainfall zones will shift northwards, adding to the water deficit in Africa, the Middle East and the Mediterranean - a grim prospect indeed.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Per capita water usage has been on an upward trend for many years. As countries industrialise and their citizens become more prosperous, their individual water usage increases rapidly. Annual per capita water withdrawals in the USA, for example, are about 1,700 cubic metres, four times the level in China and fifty times the level in Ethiopia. In the 21st century, the world''s limited supply of renewable fresh water is having to meet demands of both larger total population and increased per capita consumption. The only practical ways to resolve this problem in the longer term are economic pricing in conjunction with conservation measures.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Agriculture consumes about 70% of the world''s fresh water, so improvements in irrigation can make the greatest impact. At present, average efficiency in the use of irrigated water in agriculture may be as low as 50%. Simple changes could improve the rate substantially, though it is unrealistic to expect very high levels of water-use efficiency in many developing countries, faced as they are with a chronic lack of capital and a largely untrained rural workforce. After agriculture, the industry is the second biggest user of water and, in terms of value added per litre used, is sixty times more productive than agriculture. However, some industrial processes use vast amounts of water. For example, production of 1 kg of aluminium might require 1,500 litres of water. Paper production too is often very water-intensive. Though new processes have greatly reduced consumption, there is still plenty of room for big savings in industrial uses of water.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. In rich countries, water consumption has gradually been slowed down by price increases and the use of modern technology and recycling. In the USA, industrial production has risen fourfold since 1950, while water consumption has fallen by more than a third. Japan and Germany have similarly improved their use of water in manufacturing processes. Japanese industry, for example, now recycles more than 75% of process water. However, industrial water consumption is continuing to increase sharply in developing countries. With domestic and agricultural demands also increasing, the capacity of water supply systems is under growing strain.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Many experts believe that the best way to counter this trend is to impose water charges based on the real cost of supplies. This would provide a powerful incentive for consumers to introduce water-saving processes and recycling. Few governments charge realistic prices for water, especially to farmers. Even in rich California, farmers get water for less than a tenth of the cost of supply. In many developing countries there is virtually no charge for irrigation water, while energy prices are heavily subsidised too (which means that farmers can afford to run water pumps day and night). Water, which was once regarded as a free gift from heaven, is becoming a commodity which must be bought and sold on the open market just like oil. In the oil industry, the price increases which hit the market in the 1970s, coupled with concerns that supplies were running low, led to new energy conservation measures all over the world. It was realised that investing in new sources was a far more costly option than improving the efficiency of use. A similar emphasis on conservation will be the best and cheapest option for bridging the gap between water supply and demand.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    35,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ _______ . As well as increased consumption per capita, the growing demand for fresh water is due to a bigger global',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q35": ["prosperous"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    36,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ _______ than in the past. The only way to control this increase in demand is to charge high prices for water while also promoting conservation measures. Improvements in irrigation systems and...',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q36": ["population"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    37,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ _______ and recycling. But in agricultural and domestic sectors, the price of water is still subsidised so it is not regarded as a commodity that people need to pay a realistic price for.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q37": []}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    38,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ _______ in the supply systems and to find ways of utilising used water.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q38": ["leaks"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    39,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ _______ . would protect the ecosystem and ensure the replenishment of groundwater for future generations. Without such measures, future supplies are uncertain, especially when global warming...',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q39": ["management"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    40,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ _______ already suffered by many countries today.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q40": ["water deficit"]}'::jsonb
  );


END$$;


COMMIT;