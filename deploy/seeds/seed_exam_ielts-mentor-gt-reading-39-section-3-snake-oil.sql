-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T20:28:35.747755
-- Source: ielts-mentor.com
-- Title: GT Reading 39 Section 3 - Snake Oil
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-39-section-3-snake-oil
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-39-section-3-snake-oil'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-39-section-3-snake-oil';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-39-section-3-snake-oil';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-39-section-3-snake-oil';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-39-section-3-snake-oil',
    'GT Reading 39 Section 3 - Snake Oil',
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
    'Reading Passage - GT Reading 39 Section 3 - Snake Oil',
    E'# Passage\n\n# Snake Oil\n\ni. Where to buy the best Echinacea ii. What ''snake oil'' contained iii. Growing Echinacea iv. How to use the Echinacea plant v. Earlier applications of Echinacea vi. The origins of the term ''snake oil'' vii. Early research into the effectiveness of Echinacea viii. How ''snake oil'' was first invented ix. The use of Echinacea in new locations x. Modern evidence of the effectiveness of Echinacea xi. Early kinds of ''snake oil''\n\nA. Back in the days of America''s Wild West, when cowboys roamed the range and people were getting themselves caught up in gunfights, a new phrase - ''snake oil'' – entered the language. It was a dismissive term for the patent medicines, often useless, sold by travelling traders who always claimed miraculous cures for everything from baldness to snakebite. Selling ''snake oil'' was almost as risky a business as cattle stealing; you might be run out of town if your particular medicine, as you realised it would, failed to live up to its claims. Consequently, the smarter - ''snake oil'' sellers left town before their customers had much chance to evaluate the ''cure'' they had just bought. B. The remarkable thing about many of the medicines dismissed then as ''snake oil'' is not so much that they failed to live up to the outrageous claims made for them - those that weren''t harmless coloured water could be positively dangerous. What''s remarkable is that so many of the claims made for some of these remedies, or at least their ingredients, most of them, plant based, have since been found to have at least some basis in fact. One, Echinacea, eventually turned out to be far more potent than even its original promoter claimed. Echinacea first appeared in ''Meyer''s Blood Purifier'', promoted as a cure-all by a Dr H.C.F. Meyer - a lay doctor with no medical qualifications. ''Meyer''s Blood Purifier'' claimed not only to cure snakebite, but also to eliminate a host of other ailments. C. Native to North America, the roots of Echinacea, or purple coneflower, had been used by the Plains Indians for all kinds of ailments long before Meyer came along. They applied poultices of it to wounds and stings, used it for teeth and gum disease and made a tea from it to treat everything from colds and measles to arthritis. They even used it for snakebite. D. Settlers quickly picked up on the plant''s usefulness but until Meyer sent samples of his ''blood purifier'' to John Lloyd, a pharmacist, it remained a folk remedy. Initially dismissing Meyer''s claims as nonsense, Lloyd was eventually converted after a colleague, John King, tested the herb and successfully used it to treat bee stings and nasal congestion. In fact, he went much further in his claims than Meyer ever did and by the 1890s a bottle of tincture(1) of Echinacea could be found in almost every American home, incidentally making a fortune for Lloyd''s company, Lloyd Brothers Pharmacy. E. As modern antibiotics became available, the use of Echinacea products declined and from the 1940s to the 1970s it was pretty much forgotten in the USA. It was a different story in Europe, where both French and German herbalists and homeopaths continued to make extensive use of it. It had been introduced there by Gerhard Madaus, who travelled from Germany to America in 1937, returning with seed to establish commercial plots of Echinacea. His firm conducted extensive research on echinacin, a concentrate they made from the juice of flowering tops of the plants he had brought back. It was put into ointments, liquids for internal and external use, and into products for injections. F. There is no evidence that Echinacea is effective against snakebite, but Dr Meyer – who genuinely believed in Echinacea - would probably be quite amused if he could come back and see the uses to which modern science has put ''his'' herb. He might not be surprised that science has confirmed Echinacea''s role as a treatment for wounds, or that it has been found to be helpful in relieving arthritis, both claims Meyer made for the herb. He might though be surprised to learn how Echinacea is proving to be an effective weapon against all sorts of disease, particularly infections. German researchers had used it successfully to treat a range of infections and found it to be effective against bacteria and protozoa (2). There are many other intriguing medical possibilities for extracts from the herb, but its apparent ability to help with our more common ailments has seen thousands of people become enthusiastic converts. Dozens of packaged products containing extracts of Echinacea can now be found amongst the many herbal remedies and supplements on the shelves of health stores and pharmacies. Many of those might be the modern equivalents of ''snake oil'', but Echinacea at least does seem to have some practical value. G. Echinacea is a dry prairie plant, drought-resistant and pretty tolerant of most soils, although it does best in good soil with plenty of sun. Plants are usually grown from seed but they are sometimes available from nurseries. Echinacea is a distinctive perennial with erect, hairy, spotted stems up to a meter tall. Flower heads look like daisies, with purple rayed florets and a dark brown central cone. The leaves are hairy; the lower leaves are oval to lance-shaped and coarsely and irregularly toothed. H. There are nine species of Echinacea in all but only three are generally grown for medicinal use. All have similar medicinal properties. Most European studies have used liquid concentrates extracted from the tops of plants, whereas extraction in the USA has usually been from the roots. Today most manufacturers blend both, sometimes adding flowers and seeds to improve the quality. For the home grower, the roots of all species seem equally effective. Dig them up in autumn after the tops have died back after the first frost. Wash and dry them carefully and store them in glass containers. You can harvest the tops throughout the summer and even eat small amounts of leaf straight from the plant. Even if you don''t make your fortune from this herb, there are few sights more attractive than a field of purple coneflowers in all their glory. And with a few Echinacea plants nearby, you''ll never go short of a cure. ---------------------------------------------------------- (1) a liquid containing a special ingredient (2) a type of micro-organism'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section C',
    'Choose the correct answer.',
    '{"section-c-q28": ["v", "v. Earlier applications of Echinacea"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Where to buy the best Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What ''snake oil'' contained', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Growing Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. How to use the Echinacea plant', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Earlier applications of Echinacea', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The origins of the term ''snake oil''', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Early research into the effectiveness of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. How ''snake oil'' was first invented', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The use of Echinacea in new locations', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Modern evidence of the effectiveness of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Early kinds of ''snake oil''', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section D',
    'Choose the correct answer.',
    '{"section-d-q29": ["vii", "vii. Early research into the effectiveness of Echinacea"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Where to buy the best Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What ''snake oil'' contained', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Growing Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. How to use the Echinacea plant', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Earlier applications of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The origins of the term ''snake oil''', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Early research into the effectiveness of Echinacea', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. How ''snake oil'' was first invented', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The use of Echinacea in new locations', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Modern evidence of the effectiveness of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Early kinds of ''snake oil''', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section E',
    'Choose the correct answer.',
    '{"section-e-q30": ["ix", "ix. The use of Echinacea in new locations"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Where to buy the best Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What ''snake oil'' contained', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Growing Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. How to use the Echinacea plant', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Earlier applications of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The origins of the term ''snake oil''', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Early research into the effectiveness of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. How ''snake oil'' was first invented', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The use of Echinacea in new locations', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Modern evidence of the effectiveness of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Early kinds of ''snake oil''', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section F',
    'Choose the correct answer.',
    '{"section-f-q31": ["x", "x. Modern evidence of the effectiveness of Echinacea"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Where to buy the best Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What ''snake oil'' contained', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Growing Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. How to use the Echinacea plant', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Earlier applications of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The origins of the term ''snake oil''', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Early research into the effectiveness of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. How ''snake oil'' was first invented', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The use of Echinacea in new locations', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Modern evidence of the effectiveness of Echinacea', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Early kinds of ''snake oil''', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section G',
    'Choose the correct answer.',
    '{"section-g-q32": ["iii", "iii. Growing Echinacea"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Where to buy the best Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What ''snake oil'' contained', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Growing Echinacea', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. How to use the Echinacea plant', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Earlier applications of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The origins of the term ''snake oil''', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Early research into the effectiveness of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. How ''snake oil'' was first invented', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The use of Echinacea in new locations', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Modern evidence of the effectiveness of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Early kinds of ''snake oil''', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section H',
    'Choose the correct answer.',
    '{"section-h-q33": ["iv", "iv. How to use the Echinacea plant"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Where to buy the best Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What ''snake oil'' contained', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Growing Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. How to use the Echinacea plant', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Earlier applications of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The origins of the term ''snake oil''', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Early research into the effectiveness of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. How ''snake oil'' was first invented', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The use of Echinacea in new locations', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Modern evidence of the effectiveness of Echinacea', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Early kinds of ''snake oil''', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    '34. ''Snake oil'' sellers believed their product was effective.',
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
    35,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    '35. Most people in the Wild West mistrusted ''snake oil''.',
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
    36,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    '36. Some ''snake oils'' were mostly water.',
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
    37,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    '37. All ''snake oils'' contained Echinacea.',
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
    38,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    '38. Echinacea has been proven to kill microbes.',
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
    39,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    '39. The highest quality Echinacea is grown in America.',
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
    40,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    '40. More than one part of the Echinacea plant has a medicinal use.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);


END$$;


COMMIT;