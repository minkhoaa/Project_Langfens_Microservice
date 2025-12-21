-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T00:58:30.582408
-- Source: ielts-mentor.com
-- Title: GT Reading 27 Section 3 - From Londinium to London
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-27-section-3-from-londinium-to-london
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-27-section-3-from-londinium-to-london'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-27-section-3-from-londinium-to-london';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-27-section-3-from-londinium-to-london';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-27-section-3-from-londinium-to-london';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-27-section-3-from-londinium-to-london',
    'GT Reading 27 Section 3 - From Londinium to London',
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
    'Reading Passage - GT Reading 27 Section 3 - From Londinium to London',
    E'# Passage\n\n# From Londinium to London',
    E'**Paragraph A.**\nThe history of London spans a period of approximately 2,000 years. On its way to becoming one of the present-day financial and cultural capitals of the world, momentous highs and lows have accompanied the town. By 43 AD, an early point in its history, a time when Romans had invaded Britain, it had already been a target of several external invasions. The Roman settlers there at the time named the area Londinium, which is commonly believed to be the origin of the present-day name, London.\n\n**Paragraph B.**\nResearchers believe that before the Romans, no city existed where London is today. It was just a rural area with significant richness and attractiveness in terms of natural resources and location. They base this on the fact that only very scattered evidence of farming, burial and habitation have been uncovered in the area. Early Roman London, which is also referred to as The First London, was a very small area that existed for just 17 years. Around 61 AD the Celtic-speaking Iceni tribe from Eastern Britain, who opposed the occupying forces of the Roman Empire, stormed the city and burnt it to the ground. By 100 AD it was rebuilt according to a development plan and was made the capital of the Roman province of Britannia. By the 2nd century AD, London had a population of approximately 60,000. In the 3rd century AD, however, due to internal troubles within the Roman Empire, the city was brought down again. By the 5th century AD, it had become an abandoned city.\n\n**Paragraph C.**\nDuring the next century, the area near London saw the settlement of a new race of people, the Anglo-Saxons. These people started to migrate about 1 kilometre upstream from the Roman London city. Their settlement was called Lundenwic, and had fishing and trading as its economic base. Disaster struck for the city in 850 AD when its defence was broken down by a major Viking1 raid. However, the Viking occupation which had lasted for 20 years was overturned by Alfred the Great, the new King of England, who succeeded in establishing power via a peaceful agreement. He rebuilt the defensive wall for the city to protect his people. Gradually, as a result of contributions by the then ruling kings, London once again became an international trading centre and political powerhouse. However, in the late 10th century Vikings raided again and took control of the city and forced the ruling King Ethelred to flee. His army then made a counter attack and won. Thus, English control was once more established.\n\n**Paragraph D.**\nKing Canute ruled London and the adjacent countryside until his death in 1042, when his son, Edward, took control and re-founded Westminster Abbey. By this time London had already become the largest city in the whole of England. In 1066 William the Conqueror became the King of England and built a castle in the southeast part to better keep a watchful eye on its inhabitants. The later kings expanded the castle, which is now known as the Tower of London. During 1097 William II built Westminster Hall adjacent to the Westminster Abbey as a key structure in the new Palace of Westminster, which was the main royal residence all through the Middle Ages. Primarily, because of the unique administration through the Corporation of London, which was the municipal governing body that later became the City of London Corporation, London became a centre of trade and commerce and was named the capital of England in the 12th century.\n\n**Paragraph E.**\nIn 1588 the Spanish Armada sailed against England and was defeated. The defeat of the Spanish led to more political stability in England allowing London to prosper even more. Good times followed until tragedy struck during the middle and late 16th century through The Great Fire of London. Starting from a small bakery, the fire burnt to the ground, the homes of 70,000 of London’s 80,000 inhabitants. Rebuilding the city would take ten long years. The middle of the 17th century was also a matter of great misfortune for London due to an outbreak of the Great Plague, which caused the deaths of almost a fifth of the population.\n\n**Paragraph F.**\nThe first quarter of the 18th century saw London become and remain the world’s largest city. Major developments within this period included the building of a rail network and a city metro system; the systematic development of a workforce; a local government system and other large-scale building of infrastructure. After World War II, London became home to a large number of immigrants - especially those from other parts of the Commonwealth - making London one of the most culturally diverse cities in the whole of Europe. Despite occasional set-backs - like the Brixton Riots in the early 1980s - the integration of new migrants into London was comparatively smoother than other regions around the United Kingdom.\n\n**Paragraph G.**\nFrom the 1980s onward, some successful economic reforms and revival programs were implemented in London that significantly contributed to re-establish it as a pre-eminent international centre. Today London is considered by many to be the most important and influential city in Europe with around 32% of all foreign exchange around the world occurring in the city on a daily basis. The British government continues to devote more resources to the development of London with the people of the city now preparing to hosting the 2012 Summer Olympics. 1Ship-borne warriors originating from Scandinavia i.e. northern Europe.'
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
    'Write the correct letter, A-F.\n\n28. an example of two groups of people making an agreement, not to war',
    'Choose the correct answer.',
    '{"info-q28": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n29. a big upcoming event for London',
    'Choose the correct answer.',
    '{"info-q29": ["G", "g"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n30. London as a deserted city',
    'Choose the correct answer.',
    '{"info-q30": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n31. commonly believed to be the origination of the word ‘London’',
    'Choose the correct answer.',
    '{"info-q31": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n32. London and a mass disease',
    'Choose the correct answer.',
    '{"info-q32": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n33. most of the city dwellers lost their dwelling place',
    'Choose the correct answer.',
    '{"info-q33": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n34. the main reason why London became the capital of England',
    'Choose the correct answer.',
    '{"info-q34": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    35,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Write the correct letter, A-F.\n\n35. an example of a conclusion made by those who study history.',
    'Choose the correct answer.',
    '{"info-q35": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    36,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n36. The Romans gave London its name.',
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
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n37. A sudden attack on The First London totally destroyed it.',
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
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n38. The area, once known as Early Roman London, now joins with modern-day London.',
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
    39,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n39. In order to control the people of London more effectively, William the Conqueror built a castle.',
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
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n40. 70,000 houses were burnt by the Great Fire of London.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);


END$$;


COMMIT;