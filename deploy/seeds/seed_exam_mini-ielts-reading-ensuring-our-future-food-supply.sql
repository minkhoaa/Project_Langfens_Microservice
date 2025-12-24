-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T13:45:00.442267
-- Source: mini-ielts.com
-- Title: Ensuring our future food supply
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-ensuring-our-future-food-supply
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-ensuring-our-future-food-supply'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-ensuring-our-future-food-supply';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-ensuring-our-future-food-supply';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-ensuring-our-future-food-supply';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-ensuring-our-future-food-supply',
    'Ensuring our future food supply',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://uq.edu.au/research/impact/stories/feeding-the-future/assets/UTOFnn8bTm/safeguarding-future-food-supply-1855x1000.jpeg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Ensuring our future food supply',
    E'**Questions 1-7:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 8-13:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.',
    E'**Paragraph A.**\\nClimate change and new diseases threaten the limited varieties of seeds we depend on for food. Luckily, we still have many of the seeds used in the past-but we must take steps to save them.\\n\\n**Paragraph B.**\\nSix miles outside the town of Decorah, Iowa in the USA, an 890-acre stretch of rolling fields and woods called Heritage Farm is letting its crops go to seed. Everything about Heritage Farm is in stark contrast to the surrounding acres of intensively farmed fields of corn and soybean that are typical of modern agriculture. Heritage Farm is devoted to collecting rather than growing seeds. It is home to the Seed Savers Exchange, one of the largest non government-owned seed banks in the United States.\\n\\n**Paragraph C.**\\nIn 1975 Diane Ott Whealy was given the seedlings of two plant varieties that her great grandfather had brought to America from Bavaria in 1870: Grandpa Ott’s morning glory and his German Pink tomato. Wanting to preserve similar traditional varieties, known as heirloom plants, Diane and her husband, Kent, decided to establish a place where the seeds of the past could be kept and traded. The exchange now has more than 13,000 members, and the many thousands of heirloom varieties they have donated are kept in its walk-in coolers, freezers, and root cellars the seeds of many thousands of heirloom varieties and, as you walk around an old red barn that is covered in Grandpa Ott’s beautiful morning glory blossoms, you come across the different vegetables, herbs, and flowers they have planted there.\\n\\n**Paragraph D.**\\n"Each year our members list their seeds in this,"Diane Ott Whealy says, handing over a copy of the Seed Savers Exchange 2010 Yearbook. It is as thick as a big-city telephone directory, with page after page of exotic beans, garlic, potatoes, peppers, apples, pears, and plums-each with its own name and personal history .For example, there’s an Estonian Yellow Cherry tomato, which was brought to the seed bank by “an elderly Russian lady” who lived in Tallinn, and a Persian Star garlic from “a bazaar in Samarkand.”There’s also a bean donated by archaeologists searching for pygmy elephant fossils in New Mexico.\\n\\n**Paragraph E.**\\nHeirloom vegetables have become fashionable in the United States and Europe over the past decade, prized by a food movement that emphasizes eating locally and preserving the flavor and uniqueness of heirloom varieties. Found mostly in farmers'' markets and boutique groceries, heirloom varieties have been squeezed out of supermarkets in favor of modern single-variety fruits and vegetables bred to ship well and have a uniform appearance, not to enhance flavor. But the movement to preserve heirloom varieties goes way beyond the current interest in North America and Europe in tasty, locally grown food. It’s also a campaign to protect the world’s future food supply.Most people in the well-fed world give little thought to where their food comes from or how it’s grown. They wander through well-stocked supermarkets without realizing that there may be problem ahead.We’ve been hearing for some time about the loss of flora and fauna in our rainforests.Very little,by contrast,is being said or done about the parallel decline in the diversity of the foods we eat.\\n\\n**Paragraph F.**\\nFood variety extinction is happening all over the world - and it''s happening fast. In the United States an estimated 90 percent of historic fruit and vegetable varieties are no longer grown. Of the 7,000 different apple varieties that were grown in the 1800s, fewer than a hundred remain. In the Philippines thousands of varieties of rice once thrived; now only about a hundred are grown there. In China 90 percent of the wheat varieties cultivated just a hundred years ago have disappeared. Experts estimate that in total we have lost more than 50 percent of the world''s food varieties over the past century.\\n\\n**Paragraph G.**\\nWhy is this a problem? Because if disease or future climate change affects one of the handful of plants we''ve come to depend on to feed our growing planet, we might desperately need one of those varieties we''ve let become extinct. The loss of the world''s cereal diversity is a particular cause for concern. A fungus called Ug99, which was first identified in Uganda in 1999, is spreading across the world''s wheat crops. From Uganda it moved to Kenya, Ethiopia, Sudan, and Yemen. By 2007 it had jumped the Persian Gulf into Iran. Scientists predict that the fungus will soon make its way into India and Pakistan, then spread to Russia and China, and eventually the USA.\\n\\n**Paragraph H.**\\nRoughly 90 percent of the world''s wheat has no defense against this particular fungus. If it reached the USA, an estimated one billion dollars'' worth of crops would be at risk. Scientists believe that in Asia and Africa alone, the portion currently in danger could leave one billion people without their primary food source. A famine with significant humanitarian consequences could follow, according to Rick Ward of Cornell University.\\n\\n**Paragraph I.**\\nThe population of the world is expected to reach nine billion by 2045. Some experts say we’ll need to double our food production to keep up with this growth. Given the added challenge of climate change and disease, it is becoming ever more urgent to find ways to increase food yield. The world has become increasingly dependent upon a technology-driven, one-size-fits-all approach to food supply. Yet the best hope for securing our food''s future may depend on our ability to preserve the locally cultivated foods of the past.\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Heritage Farm is different from most other nearby farms.',
    '',
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
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Most nongovernment-owned seed banks are bigger than Seed Savers Exchange.',
    '',
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
    3,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Diane Ott Whealy''s grandfather taught her a lot about seed varieties.',
    '',
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
    4,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The seeds people give to the Seed Savers Exchange are stored outdoors.',
    '',
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
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Diane and her husband choose which heirloom seeds to grow on Heritage Farm.',
    '',
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
    6,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The seeds are listed in alphabetical order in The Seed Savers Exchange Yearbook.',
    '',
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
    7,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The Seed Savers Exchange Yearbook describes how each seed was obtained.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'want fruit and vegetables to be standard in their _______',
    '',
    '{"blank-q8": ["APPEARANCE"]}'::jsonb
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
    'while people know about plants disappearing from _______ very few know about the decline in fruit and vegetable varieties',
    '',
    '{"blank-q9": ["RAINFORESTS"]}'::jsonb
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
    'less than 100 of the types of _______ once available in the USA are still grown',
    '',
    '{"blank-q10": ["APPLES"]}'::jsonb
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
    'over _______ of food varieties around the world have disappeared in the last 100 years',
    '',
    '{"blank-q11": ["50 PERCENT"]}'::jsonb
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
    'Rick Ward believes the threat to food supplies in Asia and Africa might lead to a _______',
    '',
    '{"blank-q12": ["FAMINE"]}'::jsonb
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
    'twice the amount of food may be needed because of an increase in _______',
    '',
    '{"blank-q13": ["POPULATION"]}'::jsonb
  );


END$$;


COMMIT;