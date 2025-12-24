-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T13:45:01.143036
-- Source: mini-ielts.com
-- Title: THE STORY OF COFFEE
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-the-story-of-coffee
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-the-story-of-coffee'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-story-of-coffee';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-story-of-coffee';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-the-story-of-coffee';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-the-story-of-coffee',
    'THE STORY OF COFFEE',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://musicart.xboxlive.com/7/fa670600-0000-0000-0000-000000000002/504/image.jpg?w=1920&h=1080',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - THE STORY OF COFFEE',
    E'**Questions 1-6:**\nThe reading passage on The Story of Coffee has 7 paragraphs A – G.\nFrom the list of headings below choose the most suitable headings for paragraphs B – G.\nWrite the appropriate number (i – xi) in boxes 1-6 on your answer sheet.\n\n**NB:** There are more headings than paragraphs, so you will not use them all.\n\n**List of Headings:**\ni. Growing Coffee\nii. Problems with Manufacture\niii. Processing the Bean\niv. First Contact\nv. Arabian Coffee\nvi. Coffee Varieties\nvii. Modern Coffee\nviii. The Spread of Coffee\nix. Consuming Coffee\nx. Climates for Coffee\nxi. The Coffee Plant\n\n*Example: Paragraph A → iv*\n\n---\n\n**Questions 7-9:**\nComplete the labels on the diagram of a coffee bean below.\nChoose your answers from the text and write them in boxes 7-9 on your answer sheet.\n\n---\n\n**Questions 10-13:**\nUsing the information in the passage, complete the flowchart below.\nWrite your answers in boxes 10-13 on your answer sheet.\nUse NO MORE THAN THREE WORDS from the passage for each answer.',
    E'# THE STORY OF COFFEE\n\n**Paragraph A.**\nCoffee was first discovered in Eastern Africa in an area we know today as Ethiopia. A popular legend refers to a goat herder by the name of Kaldi, who observed his goats acting unusually friskily after eating berries from a bush. Curious about this phenomenon, Kaldi tried eating the berries himself. He found that these berries gave him renewed energy.\n\n**Paragraph B.**\nThe news of this energy laden fruit quickly moved throughout the region. Coffee berries were transported from Ethiopia to the Arabian Peninsula, and were first cultivated in what today is the country of Yemen. Coffee remained a secret in Arabia before spreading to Turkey and then to the European continent by means of Venetian trade merchants.\n\n**Paragraph C.**\nCoffee was first eaten as a food though later people in Arabia would make a drink out of boiling the beans for its narcotic effects and medicinal value. Coffee for a time was known as Arabian wine to Muslims who were banned from alcohol by Islam. It was not until after coffee had been eaten as a food product, a wine and a medicine that it was discovered, probably by complete accident in Turkey, that by roasting the beans a delicious drink could be made. The roasted beans were first crushed and then boiled in water, creating a crude version of the beverage we enjoy today. The first coffee houses were opened in Europe in the 17th Century and in 1675, the Viennese established the habit of refining the brew by filtering out the grounds, sweetening it, and adding a dash of milk.\n\n**Paragraph D.**\nIf you were to explore the planet for coffee, you would find about 60 species of coffee plants growing wild in Africa, Malaysia, and other regions. But only about ten of them are actually cultivated. Of these ten, two species are responsible for almost all the coffee produced in the world: Coffea Arabica and Coffea Canephora (usually known as Robusta). Because of ecological differences existing among the various coffee producing countries, both types have undergone many mutations and now exist in many sub-species.\n\n**Paragraph E.**\nAlthough wild plants can reach 10 - 12 metres in height, the plantation one reaches a height of around four metres. This makes the harvest and flowering easier, and cultivation more economical. The flowers are white and sweet-scented like the Spanish jasmine. Flowers give way to a red, darkish berry. At first sight, the fruit is like a big cherry both in size and in colour. The berry is coated with a thin, red film (epicarp) containing a white, sugary mucilaginous flesh (mesocarp). Inside the pulp there are the seeds in the form of two beans coupled at their flat surface. Beans are in turn coated with a kind of resistant, golden yellow parchment, (called endocarp). When peeled, the real bean appears with another very thin silvery film. The bean is bluish green verging on bronze, and is at the most 11 millimetres long and 8 millimetres wide.\n\n**Paragraph F.**\nCoffee plants need special conditions to give a satisfactory crop. The climate needs to be hot-wet or hot temperate, between the Tropic of Cancer and the Tropic of Capricorn, with frequent rains and temperatures varying from 15 to 25 Degrees C. The soil should be deep, hard, permeable, well irrigated, with well-drained subsoil. The best lands are the hilly ones or from just-tilled woods. The perfect altitude is between 600 and 1200 metres, though some varieties thrive at 2000-2200 metres. Cultivation aimed at protecting the plants at every stage of growth is needed. Sowing should be in sheltered nurseries from which, after about six months, the seedlings should be moved to plantations in the rainy season where they are usually alternated with other plants to shield them from wind and excessive sunlight. Only when the plant is five years old can it be counted upon to give a regular yield. This is between 400 grams and two kilos of arabica beans for each plant, and 600 grams and two kilos for robusta beans.\n\n**Paragraph G.**\nHarvesting time depends on the geographic situation and it can vary greatly therefore according to the various producing countries. First, the ripe beans are picked from the branches. Pickers can selectively pick approximately 250 to 300 pounds of coffee cherry a day. At the end of the day, the pickers bring their heavy burlap bags to pulping mills where the cherry coffee can be pulped (or wet milled). The pulped beans then rest, covered in pure rainwater to ferment overnight. The next day the wet beans are hand-distributed upon the drying floor to be sun dried. This drying process takes from one to two weeks depending on the amount of sunny days available. To make sure they dry evenly, the beans need to be raked many times during this drying time. Two weeks later the sun dried beans, now called parchment, are scooped up, bagged and taken to be milled. Huge milling machines then remove the parchment and silver skin, which renders a green bean suitable for roasting. The green beans are roasted according to the customers'' specifications and, after cooling, the beans are then packaged and mailed to customers.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph B',
    '',
    '{"paragraph-b-q1": ["viii", "viii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Growing Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Problems with Manufacture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Processing the Bean', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. First Contact', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Arabian Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Coffee Varieties', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Modern Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The Spread of Coffee', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Consuming Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Climates for Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. The Coffee Plant', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph C',
    '',
    '{"paragraph-c-q2": ["ix", "ix"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Growing Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Problems with Manufacture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Processing the Bean', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. First Contact', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Arabian Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Coffee Varieties', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Modern Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The Spread of Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Consuming Coffee', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Climates for Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. The Coffee Plant', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph D',
    '',
    '{"paragraph-d-q3": ["vi", "vi"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Growing Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Problems with Manufacture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Processing the Bean', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. First Contact', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Arabian Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Coffee Varieties', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Modern Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The Spread of Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Consuming Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Climates for Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. The Coffee Plant', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph E',
    '',
    '{"paragraph-e-q4": ["xi", "xi"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Growing Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Problems with Manufacture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Processing the Bean', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. First Contact', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Arabian Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Coffee Varieties', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Modern Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The Spread of Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Consuming Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Climates for Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. The Coffee Plant', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph F',
    '',
    '{"paragraph-f-q5": ["i", "i"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Growing Coffee', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Problems with Manufacture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Processing the Bean', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. First Contact', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Arabian Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Coffee Varieties', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Modern Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The Spread of Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Consuming Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Climates for Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. The Coffee Plant', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph G',
    '',
    '{"paragraph-g-q6": ["iii", "iii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Growing Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Problems with Manufacture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Processing the Bean', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. First Contact', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Arabian Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Coffee Varieties', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Modern Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The Spread of Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Consuming Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Climates for Coffee', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. The Coffee Plant', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'The outer coating of the coffee berry is called the _______.',
    '',
    '{"blank-q7": ["epicarp"]}'::jsonb
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
    'Inside the coating is a white, sugary mucilaginous flesh called the _______.',
    '',
    '{"blank-q8": ["mesocarp"]}'::jsonb
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
    'The resistant, golden yellow parchment coating the beans is called the _______.',
    '',
    '{"blank-q9": ["endocarp"]}'::jsonb
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
    'First, ripe beans are picked and taken to pulping mills where they can be pulped (or _______).',
    '',
    '{"blank-q10": ["wet milled"]}'::jsonb
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
    'The pulped beans rest in pure rainwater to ferment _______.',
    '',
    '{"blank-q11": ["overnight"]}'::jsonb
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
    'During the drying process, beans need to be _______ many times to dry evenly.',
    '',
    '{"blank-q12": ["raked"]}'::jsonb
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
    'The green beans are roasted according to the _______ and then packaged.',
    '',
    '{"blank-q13": ["customers' specifications"]}'::jsonb
  );


END$$;


COMMIT;