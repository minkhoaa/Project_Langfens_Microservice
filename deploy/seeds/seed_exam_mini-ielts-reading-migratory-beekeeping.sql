-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T01:04:33.597647
-- Source: mini-ielts.com
-- Title: Migratory Beekeeping
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-migratory-beekeeping
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-migratory-beekeeping'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-migratory-beekeeping';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-migratory-beekeeping';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-migratory-beekeeping';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-migratory-beekeeping',
    'Migratory Beekeeping',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766599304/ielts/beekeprs_thumbpad_a3d992ba3636.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Migratory Beekeeping',
    E'**Questions 1-7:**\nThe flow chart below outlines the movements of the migratory beekeeper.\nComplete the flow chart. Choose your answers from the box.\n\n---\n\n**Questions 8-11:**\nLabel the diagram below.\nChoose **ONE OR TWO WORDS** from the Reading Passage for each answer.\n\n---\n\n**Questions 12-15:**\nDo the following statements agree with the claims of the writer?\n\nWrite:\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this\n\n---\n\n### Diagram for Questions 8-11\n\n![A Beehive](https://res.cloudinary.com/df41zs8il/image/upload/v1766599315/ielts/01_0dcc9fc534f3.jpg)',
    E'**Paragraph A.**\n\nTo eke out a full-time living from their honeybees, about half the nation’s 2,000 commercial beekeepers pull up stakes each spring, migrating north to find more flowers for their bees. Besides turning floral nectar into honey, these hardworking insects also pollinate crops for farmers -for a fee. As autumn approaches, the beekeepers pack up their hives and go south, scrambling for pollination contracts in hot spots like California’s fertile Central Valley.\n\n**Paragraph B.**\n\nOf the 2,000 commercial beekeepers in the United States about half migrate This pays off in two ways Moving north in the summer and south in the winter lets bees work a longer blooming season, making more honey — and money — for their keepers. Second, beekeepers can carry their hives to farmers who need bees to pollinate their crops. Every spring a migratory beekeeper in California may move up to 160 million bees to flowering fields in Minnesota and every winter his family may haul the hives back to California, where farmers will rent the bees to pollinate almond and cherry trees.\n\n**Paragraph C.**\n\nMigratory beekeeping is nothing new. The ancient Egyptians moved clay hives, probably on rafts, down the Nile to follow the bloom and nectar flow as it moved toward Cairo. In the 1880s North American beekeepers experimented with the same idea, moving bees on barges along the Mississippi and on waterways in Florida, but their lighter, wooden hives kept falling into the water. Other keepers tried the railroad and horse- drawn wagons, but that didn’t prove practical. Not until the 1920s when cars and trucks became affordable and roads improved, did migratory beekeeping begin to catch on.\n\n**Paragraph D.**\n\nFor the Californian beekeeper, the pollination season begins in February. At this time, the beehives are in particular demand by farmers who have almond groves; they need two hives an acre. For the three-week long bloom, beekeepers can hire out their hives for $32 each. It’s a bonanza for the bees too. Most people consider almond honey too bitter to eat so the bees get to keep it for themselves.\n\n**Paragraph E.**\n\nBy early March it is time to move the bees. It can take up to seven nights to pack the 4,000 or so hives that a beekeeper may own. These are not moved in the middle of the day because too many of the bees would end up homeless. But at night, the hives are stacked onto wooden pallets, back-to-back in sets of four, and lifted onto a truck. It is not necessary to wear gloves or a beekeeper’s veil because the hives are not being opened and the bees should remain relatively quiet. Just in case some are still lively, bees can be pacified with a few puffs of smoke blown into each hive’s narrow entrance.\n\n**Paragraph F.**\n\nIn their new location, the beekeeper will pay the farmer to allow his bees to feed in such places as orange groves. The honey produced here is fragrant and sweet and can be sold by the beekeepers. To encourage the bees to produce as much honey as possible during this period, the beekeepers open the hives and stack extra boxes called supers on top. These temporary hive extensions contain frames of empty comb for the bees to fill with honey. In the brood chamber below, the bees will stash honey to eat later. To prevent the queen from crawling up to the top and laying eggs, a screen can be inserted between the brood chamber and the supers. Three weeks later the honey can be gathered.\n\n**Paragraph G.**\n\nFoul smelling chemicals are often used to irritate the bees and drive them down into the hive’s bottom boxes, leaving the honey- filled supers more or less bee free. These can then be pulled off the hive. They are heavy with honey and may weigh up to 90 pounds each. The supers are taken to a warehouse. In the extracting room, the frames are lilted out and lowered into an “uncapper” where rotating blades shave away the wax that covers each cell. The uncapped frames are put in a carousel that sits on the bottom of a large stainless steel drum. The carousel is filled to capacity with 72 frames. A switch is flipped and the frames begin to whirl at 300 revolutions per minute; centrifugal force throws the honey out of the combs. Finally the honey is poured into barrels for shipment.\n\n**Paragraph H.**\n\nAfter this, approximately a quarter of the hives weakened by disease, mites, or an ageing or dead queen, will have to be replaced. To create new colonies, a healthy double hive, teeming with bees, can be separated into two boxes. One half will hold the queen and a young, already mated queen can be put in the other half, to make two hives from one. By the time the flowers bloom, the new queens will be laying eggs, filling each hive with young worker bees. The beekeeper’s family will then migrate with them to their summer location.\n\n**Paragraph I.**\n\nAdapted from “America''s Beekeepers: Hives for Hire” by Alan Mairson, National Geographic.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'TABLE_COMPLETION',
    'READING',
    2,
    'In March, beekeepers _______ for migration at night when the hives are full and the bees are generally tranquil.',
    '',
    '{"blank-q1": ["PREPARE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'TABLE_COMPLETION',
    'READING',
    2,
    'In March, beekeepers prepare for migration at night when the hives are _______ and the bees are generally tranquil.',
    '',
    '{"blank-q2": ["FULL"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'TABLE_COMPLETION',
    'READING',
    2,
    'A little _______ can ensure that this is the case.',
    '',
    '{"blank-q3": ["SMOKE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'TABLE_COMPLETION',
    'READING',
    2,
    'They transport their hives to orange groves where farmers _______ beekeepers for placing them on their land.',
    '',
    '{"blank-q4": ["CHARGE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'TABLE_COMPLETION',
    'READING',
    2,
    'After three weeks, the supers can be taken to a warehouse where _______ are used to remove the wax and extract the honey from the combs.',
    '',
    '{"blank-q5": ["MACHINES"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'TABLE_COMPLETION',
    'READING',
    2,
    'After three weeks, the supers can be taken to a warehouse where machines are used to remove the wax and extract the honey from the _______.',
    '',
    '{"blank-q6": ["COMBS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'TABLE_COMPLETION',
    'READING',
    2,
    'After the honey collection, the old hives are rejected. Good double hives are _______ and re-queened and the beekeeper transports them to their summer base.',
    '',
    '{"blank-q7": ["SPLIT"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'Label 8 (top cover/lid) _______',
    '',
    '{"blank-q8": ["HEXAGONAL CELLS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'Label 9 (frames/slats) _______',
    '',
    '{"blank-q9": ["FRAMES"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'Label 10 (queen excluder) _______',
    '',
    '{"blank-q10": ["SCREEN"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'Label 11 (bottom board/entrance) _______',
    '',
    '{"blank-q11": ["BROOD CHAMBER"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The Egyptians keep bees on the banks of the Nile.',
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
    13,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'First attempts at migratory beekeeping in America were unsuccessful.',
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
    14,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Bees keep honey for themselves in the bottom of the hive.',
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
    15,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The honey is spun to make it liquid.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 7, E'## Questions 1-7\n\nThe flow chart below outlines the movements of the migratory beekeeper as described in Reading Passage.\n\nComplete the flow chart.\n\nChoose your answers from the box below and write your answers in boxes 1-7 on your answer sheet.\n\n### List of Words/Phrases:\nsmoke, chemicals, pay, barrels, protection, charge, set off, light, split, pollinate, machines, supers, combs, screen, prepare, full, empty, queens\n\n---\n\n**Example:** In February, Californian farmers hire bees to help **pollinate** almond trees.\n\n**1.** In March, beekeepers _______ for migration at night when the hives are **2** _______ and the bees are generally tranquil.\n\n**3.** A little _______ can ensure that this is the case.\n\n**4.** They transport their hives to orange groves where farmers _______ beekeepers for placing them on their land. Here the bees make honey.\n\n**5.** After three weeks, the supers can be taken to a warehouse where _______ are used to remove the wax and extract the honey from the **6** _______.\n\n**7.** After the honey collection, the old hives are rejected. Good double hives are _______ and re-queened and the beekeeper transports them to their summer base.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 8, 11, E'## Questions 8-11\n\nLabel the diagram below.\n\nChoose **ONE OR TWO WORDS** from the Reading Passage for each answer.\n\nWrite your answers in boxes 8-11 on your answer sheet.\n\n![A Beehive Diagram](https://res.cloudinary.com/df41zs8il/image/upload/v1766599315/ielts/01_0dcc9fc534f3.jpg)\n\n**8.** _______\n\n**9.** _______\n\n**10.** _______\n\n**11.** _______');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 12, 15, E'## Questions 12-15\n\nDo the following statements agree with the claims of the writer?\n\nWrite:\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this\n\n**12.** The Egyptians keep bees on the banks of the Nile.\n\n**13.** First attempts at migratory beekeeping in America were unsuccessful.\n\n**14.** Bees keep honey for themselves in the bottom of the hive.\n\n**15.** The honey is spun to make it liquid.');

END$$;


COMMIT;