-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T18:51:06.086964
-- Source: mini-ielts.com
-- Title: The Ecological Importance of Bees
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-the-ecological-importance-of-bees
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-the-ecological-importance-of-bees'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-ecological-importance-of-bees';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-ecological-importance-of-bees';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-the-ecological-importance-of-bees';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-the-ecological-importance-of-bees',
    'The Ecological Importance of Bees',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://i.ytimg.com/vi/YaaQUGPXtnU/maxresdefault.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - The Ecological Importance of Bees',
    E'**Questions 1-5:**\nChoose the correct heading for each section from the list of headings below.\n\nWrite the correct number, **i-xi**.\n\n---\n\n**Questions 6-12:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**Questions 13-13:**\nChoose the correct letter, **A**, **B**, **C** or **D**.',
    E'**Paragraph A.**\\nSometime in the early Cretaceous period of the Earth''s history, hunting wasps of a certain type became bees by adopting a vegetarian diet: they began to rely more and more on the pollen of plants as a source of protein for themselves and their offspring, as an alternative to insects. In so doing, they accidentally transported pollen on their bodies to other plants of the same species, bringing about pollination. The stage was thus set for a succession of ever-closer mutual adaptations of bees and flowering plants. In particular, flowers began to reward bees for their unwitting role in their reproduction by providing richer sources of pollen and another source of nutrition, nectar.\\n\\n**Paragraph B.**\\nToday about 15 per cent of our diet consists of crops which are pollinated by bees. The meat and other animal products we consume are ultimately derived from bee- pollinated forage crops, and account for another 15 per cent. It follows that around one third of our food is directly or indirectly dependent on the pollinating services of bees. On a global basis, the annual value of agricultural crops dependent on the pollination services of bees is estimated at £1,000 million (US$1,590 million). Much of this pollination is due to honey bees, and in monetary terms it exceeds the value of the annual honey crop by a factor of fifty.\\n\\n**Paragraph C.**\\nBut the apparently harmonious relationship between bees and plants conceals a conflict of interests. Although flowers need bees and vice versa, it pays each partner to minimise its costs and maximise its profits. This may sound like an extreme case of attributing human qualities to non-human species, but using the marketplace and the principles of double-entry book keeping as metaphors may give US some insights into what is really going on between bees and flowering plants. In the real world, both flower and bee operate in a competitive marketplace. A community of retailers, the flowers, seek to attract more or less discriminating consumers, the bees. Each flower has to juggle the costs and benefits of investing in advertising, by colour and scent, and providing rewards, nectar and pollen, clearly a species which depends on cross-pollination is on a knife-edge: it must provide sufficient nectar to attract the interest of a bee, but not enough to satisfy all of its needs in one visit. A satiated bee would return to its nest rather than visit another flower. The bee, on the other hand, is out to get the maximum amount of pollen and nectar. It must assess the quality and quantity of rewards which are on offer and juggle its energy costs so that it makes a calorific profit on each foraging trip. The apparent harmony between plants and bees is therefore not all that it seems. Instead, it is an equilibrium based on compromises between the competing interests of the protagonists.\\n\\n**Paragraph D.**\\nThis sounds remarkably like the ideas of the 18th-century economist Adam Smith. In his book, The Wealth of Nations, Smith postulated that in human society the competitive interactions of different ‘economic units'' eventually resulted in a balanced, or ‘harmonious’ society. One might predict, therefore, that economists would find the relationships between bees and plants of some interest. This is the case in Israel, where economists are collaborating with botanists and entomologists in a long-term study of the pollination biology of the native flora, in an attempt to understand the dynamics of the relationship between communities of bees and plants.\\n\\n**Paragraph E.**\\nThis sort of study is of more than passing academic interest. It is important that authorities understand the dynamic relationships between plants and their pollinators. This is especially true when, say, devising conservation policies. A good example comes from the forests of tropical South America. Here, as in all rainforests, there is a high diversity of tree species. There may be more than 120 per acre, but in a given acre there may only be one or two individuals of any one species: These trees are pollinated by large, fast-flying bees. There is evidence that certain types of bees learn the distribution of these scattered trees and forage regularly along the same routes. This is called ‘trap-lining’ and the bees forage for up to 23 km from their nests. The bees are therefore acting as long distance pollinators.\\n\\n**Paragraph F.**\\nAn issue of current concern in tropical forest conservation is that of trying to estimate the minimum sustainable size of islands'' of forest reserve in areas where large-scale felling is taking place. There is much discussion on seed dispersal distances. But this is only one half of the equation, so far as the reproduction of trees is concerned. There is another question that must be addressed in order to calculate whether proposed forest reserves are close enough to the nearest large tract of forest: ‘what is the flight range of these long-distance foragers?'' We need to know much more about bees and their relationships with plants before this question can be answered.\\n\\n**Paragraph G.**\\nBees, then, are vital to our survival. Furthermore, much of the visual impact of human environments derives from vegetation, and most vegetation is dependent on bees for pollination. Thus, as pollinators of crops and natural vegetation, bees occupy key positions in the web of relationships which sustain the living architecture of our planet.\\n\\n'
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
    'Paragraph A',
    '',
    '{"paragraph-a-q1": ["ii", "ii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Parallels between bee and human activities', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. An evolutionary turning point', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. A lack of total co-operation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. The preservation of individual plant species', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The commercial value of bees', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The structure of flowering plants', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The pursuit of self-interest', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The need for further research', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph B',
    '',
    '{"paragraph-b-q2": ["v", "v"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Parallels between bee and human activities', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. An evolutionary turning point', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. A lack of total co-operation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. The preservation of individual plant species', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The commercial value of bees', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The structure of flowering plants', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The pursuit of self-interest', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The need for further research', false);

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
    '{"paragraph-d-q3": ["i", "i"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Parallels between bee and human activities', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. An evolutionary turning point', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. A lack of total co-operation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. The preservation of individual plant species', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The commercial value of bees', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The structure of flowering plants', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The pursuit of self-interest', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The need for further research', false);

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
    '{"paragraph-e-q4": ["iv", "iv"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Parallels between bee and human activities', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. An evolutionary turning point', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. A lack of total co-operation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. The preservation of individual plant species', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The commercial value of bees', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The structure of flowering plants', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The pursuit of self-interest', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The need for further research', false);

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
    '{"paragraph-f-q5": ["viii", "viii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Parallels between bee and human activities', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. An evolutionary turning point', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. A lack of total co-operation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. The preservation of individual plant species', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The commercial value of bees', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The structure of flowering plants', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The pursuit of self-interest', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The need for further research', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Hunting wasps used to feed on other _______ , rather than on vegetation.',
    '',
    '{"blank-q6": ["INSECTS"]}'::jsonb
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
    'Flowering plants started to reward bees with rich pollen and an additional food in the form of _______',
    '',
    '{"blank-q7": ["NECTAR"]}'::jsonb
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
    'Approximately _______ of human food production relies on the activity of bees.',
    '',
    '{"blank-q8": ["ONE THIRD"]}'::jsonb
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
    'If the process of _______ is to take place effectively, bees need to travel from one flower to another before going back to the nest.',
    '',
    '{"blank-q9": ["CROSS-POLLINATION"]}'::jsonb
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
    'Bees need to balance the _______ of each trip against the calorific rewards they obtain.',
    '',
    '{"blank-q10": ["ENERGY COSTS"]}'::jsonb
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
    'There can be over 120 different _______ in. an acre of rainforest.',
    '',
    '{"blank-q11": ["TREE SPECIES"]}'::jsonb
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
    'The bees that pollinate large forests regularly practise an activity known as _______',
    '',
    '{"blank-q12": ["TRAP-LINING"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_HEADING',
    'READING',
    2,
    'Choose the correct letter , A, B, C or D. Write the correct letter in box 13 on your  answer sheet. Which is the best title for Reading Passage ?',
    '',
    '{"choose-the-correct-letter-,-a,-b,-c-or-d.-write-the-correct-letter-in-box-13-on-your -answer-sheet.-which-is-the-best-title-for-reading-passage-?-q13": ["a", "a"]}'
  );


END$$;


COMMIT;