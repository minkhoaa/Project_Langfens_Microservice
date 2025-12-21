-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T02:49:20.210536
-- Source: ielts-mentor.com
-- Title: GT Reading 7 Section 3 - Glow-worms
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-7-section-3-glow-worms
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-7-section-3-glow-worms'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-7-section-3-glow-worms';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-7-section-3-glow-worms';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-7-section-3-glow-worms';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-7-section-3-glow-worms',
    'GT Reading 7 Section 3 - Glow-worms',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - GT Reading 7 Section 3 - Glow-worms',
    E'# Passage',
    E'**Paragraph A.**\nThe glow-worm belongs to a family of beetles known as the lampyridae or fireflies. The fireflies are a huge group containing over 2000 species, with new ones being discovered all the time. The feature which makes fireflies and glow-worms so appealing is their ability to produce an often dazzling display of light. The light is used by the adult fireFlies as a signal to attract a mate, and each species must develop its own \'\'call-sign\'\' to avoid being confused with other species glowing nearby. So within any one area each species will differ from its neighbours in some way, For example in the colour or pattern of its light, how long the pulses of light last, the interval between pulses and whether it displays in flight or from the ground.\n\n**Paragraph B.**\nThe fireflies\'\' almost magical light has attracted human attention for generations. It is described in an ancient Chinese encyclopaedia written over 2000 years ago by a pupil of Confucius. Fireflies often featured in Japanese and Arabian folk medicine. All over the world, they have been the inspiration for countless poems, paintings and stories. In Britain, for example, there are plenty of anecdotes describing how glow-worms have been used to read by or used as emergency bicycle lamps when a cyclist\'\'s batteries have failed without warning. Early travellers in the New World came back with similar stories, of how the native people of Central America would collect a type of click beetle and release them indoors to light up their huts. Girls threaded them around their feet to illuminate the forest paths at night.\n\nFireflies very similar to those we see today have been found fossilised in rocks which were formed about 30 million years ago, and their ancestors were probably glowing long before then. It is impossible to be sure exactly when and where the first Firefly appeared. The highest concentrations of firefly species today are to be found in the tropics of South America, which may mean either that this is where they First evolved, or simply that they prefer the conditions there.\n\nWherever they first arose, fireflies have since spread to almost every part of the globe. Today members of the Firefly family can be found almost anywhere outside the Arctic and Antarctic circles.\n\n**Paragraph C.**\nAs with many insects, the glow-worm\'\'s life is divided into four distinct stages: the egg, the larva (equivalent to the caterpillar of a butterfly), the pupa (or chrysalis) and the adult. The glow-worm begins its life in the autumn as a pale yellow egg. The freshly laid egg is extremely fragile but within a day its surface has hardened into a shell. The egg usually takes about 35 days to hatch, but the exact time varies according to the temperature, from about 27 days in hot weather to more than 45 days in cold weather. By the time it is due to hatch, the glow-worm\'\'s light organ is fully developed, and its glow signals that the egg will soon hatch.\n\nAfter it has left the egg, the larva slowly grows from a few millimetres into the size and shape of a matchstick. The larval stage is the only time the insect can feed. The larva devotes much of its life to feeding and building up its food reserves so that as an adult it will be free to concentrate all its efforts on the task of finding a mate and reproducing. Throughout its time as a larva, approximately 15 months, the glow-worm emits a bright light. The larva\'\'s light is much fainter than the adult female\'\'s but it can still be seen more than five metres away.\n\nIn the final stage of a glow-worm\'\'s life, the larva encases itself in a pupa) skin while it changes from the simple larva to the more complex adult fly. When the adult Ay emerges from the pupa the male seeks a female with whom it can mate. After mating, the female lays about 120 eggs. The adult flies have no mouth parts, cannot eat and therefore only live a few days. When people talk of seeing a glow-worm they normally mean the brightly glowing adult female.\n\n**Paragraph D.**\nIn some countries, the numbers of glow-worms have been falling. Evidence suggests that there has been a steady decrease in the British glow-worm population since the 1950s and possibly before that. Possible causes for the decline include habitat destruction, pollution and changes in climate. Thousands of acres of grassland have been built upon and glow-worm sites have become increasingly isolated from each other. The widespread use of pesticides and fertilisers may also have endangered the glow-worm. Being at the top of a food chain it is likely to absorb any pollutants eaten by the snails on which it feeds. The effect of global warming on rainfall and other weather patterns may also be playing a part in the disappearance of glow-worms. A lot more research will be needed, however, before the causes of the glow-worm\'\'s gradual decline are clear.\n\n**Paragraph E.**\nAlthough glow-worms are found wherever conditions are damp, food is in good supply and there is an over-hanging wall, they are most spectacular in caves. For more than 100 years the glow-worm caves in New Zealand have attracted millions of people from all over the world. The caves were first explored in 1887 by a local Maori chief, Tane Tinorau, and an English surveyor, Fred Mace. They built a raft and, with candles as their only light, they floated into the cave where the stream goes underground. As their eyes adjusted to the darkness they saw myriad lights reflecting off the water. Looking up they discovered that the ceiling was dotted with the lights of thousands of glow-worms. They returned many times to explore further, and on an independent trip, Tane discovered the upper level of the cave and an easier access. The authorities were advised and government surveyors mapped the caves. By 1888 Tane Tinorau had opened the cave to tourists.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n28. threats to the glow-worm',
    'Choose the correct answer.',
    '{"info-q28": ["D", "d"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n29. ways in which glow-worms have been used',
    'Choose the correct answer.',
    '{"info-q29": ["B", "b"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n30. variations in type of glow-worm',
    'Choose the correct answer.',
    '{"info-q30": ["A", "a"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n31. glow-worm distribution',
    'Choose the correct answer.',
    '{"info-q31": ["B", "b"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n32. glow-worms becoming an attraction',
    'Choose the correct answer.',
    '{"info-q32": ["E", "e"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n33. the life-cycle of a glow-worm',
    'Choose the correct answer.',
    '{"info-q33": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n34. Scientists have only recently been able to list the exact number of glow-worm species.',
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
    35,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n35. The first fireflies appeared 30 million years ago.',
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
    36,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n36. Glow-worm populations are decreasing faster in some countries than in others.',
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
    37,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n37. Heat affects the production of glow-worm larvae.',
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
    38,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n38. Adulthood is the longest stage of a glow-worm''s life.',
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
    39,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n39. The exact reason why glow-worm numbers are decreasing is unknown.',
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
    40,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n40. Glow-worms are usually found in wet areas.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);


END$$;


COMMIT;