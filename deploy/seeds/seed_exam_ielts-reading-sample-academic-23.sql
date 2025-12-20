-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:03:03.932750
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #23
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-23
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-23'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-23';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-23';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-23';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-23',
    'IELTS Reading Sample (Academic) #23',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #23',
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
    'Reading Passage - IELTS Reading Sample (Academic) #23',
    E'# Passage\n\nIELTS Reading Academic 23\nYou are what you speak\nDoes your mother tongue really affect the way you see the world?\nDoes the language you speak influence the way you think? Does it help define your world view? Anyone who has tried to master a foreign tongue has at least thought about the possibility.\nAt first glance the idea seems perfectly plausible. Conveying even simple messages requires that you make completely different observations depending on your language. Imagine being asked to count some pens on a table. As an English speaker, you only have to count them and give the number. But a Russian may need to consider the gender and a Japanese speaker has to take into account their shape (long and cylindrical) as well, and use the number word designated for items of that shape.\nOn the other hand, surely pens are just pens, no matter what your language compels you to specify about them? Little linguistic peculiarities, though amusing, don’t change the objective world we are describing. So how can they alter the way we think?\nScientists and philosophers have been grappling with this thorny question for centuries. There have always been those who argue that our picture of the Universe depends on our native tongue. Since the 1960s, however, with the ascent of thinkers like Noam Chomsky, and a host of cognitive scientists, the consensus has been that linguistic differences don’t really matter, that language is a universal human trait, and that our ability to talk to one another owes more to our shared genetics than to our varying cultures. But now the pendulum is beginning to swing the other way as psychologists re-examine the question.\nA new generation of scientists is not convinced that language is innate and hard-wired into our brain and they say that small, even apparently insignificant differences between languages do affect the way speakers perceive the world. ‘The brain is shaped by experience,’ says Dan Slobin of the University of California at Berkeley. ‘Some people argue that language just changes what you attend to,’ says Lera Boroditsky of the Massachusetts Institute of Technology. ‘But what you attend to changes what you encode and remember.’ In short, it changes how you think.\nTo start with the simplest and perhaps subtlest example, preparing to say something in a particular language demands that you pay attention to certain things and ignore others. In Korean, for instance, simply to say ‘hello’ you need to know if you’re older or younger than the person you’re addressing. Spanish speakers have to decide whether they are on intimate enough terms to call someone by the informal\ntu\nrather than the formal\nUsted\n. In Japanese, simply deciding which form of the word ‘I’ to use demands complex calculations involving things such as your gender, their gender and your relative status. Slobin argues that this process can have a huge impact on what we deem important and, ultimately, how we think about the world.\nWhether your language places an emphasis on an object’s shape, substance or function also seems to affect your relationship with the world, according to John Lucy, a researcher at the Max Planck Institute of Psycholinguistics in the Netherlands. He has compared American English with Yucatec Maya, spoken in Mexico’s Yucatan Peninsula. Among the many differences between the two languages is the way objects are classified. In English, shape is implicit in many nouns. We think in terms of discrete objects, and it is only when we want to quantify amorphous things like sugar that we employ units such as ‘cube’ or ‘cup’. But in Yucatec, objects tend to be defined by separate words that describe shape. So, for example, ‘long banana’ describes the fruit, while ‘flat banana’ means the ‘banana leaf’ and ‘seated banana’ is the ‘banana tree’.\nTo find out if this classification system has any far-reaching effects on how people think, Lucy asked English- and Yucatec-speaking volunteers to do a likeness task. In one experiment, he gave them three combs and asked which two were most alike. One was plastic with a handle, another wooden with a handle, the third plastic without a handle. English speakers thought the combs with handles were more alike, but Yucatec speakers felt the two plastic combs were. In another test, Lucy used a plastic box, a cardboard box and a piece of cardboard. The Americans thought the two boxes belonged together, whereas the Mayans chose the two cardboard items. In other words, Americans focused on form, while the Mayans focused on substance.\nDespite some criticism of his findings, Lucy points to his studies indicating that, at about the age of eight, differences begin to emerge that reflect language. ‘Everyone comes with the same possibilities,’ he says, ‘but there’s a tendency to make the world fi t into our linguistic categories.’ Boroditsky agrees, arguing that even artificial classification systems, such as gender, can be important.\nNevertheless, the general consensus is that while the experiments done by Lucy, Boroditsky and others may be intriguing, they are not compelling enough to shift the orthodox view that language does not have a strong bearing on thought or perception. The classic example used by Chomskians to back this up is colour. Over the years many researchers have tried to discover whether linguistic differences in categorising colours lead to differences in perceiving them. Colours, after all, fall on a continuous spectrum, so we shouldn’t be surprised if one person’s ‘red’ is another person’s ‘orange’. Yet most studies suggest that people agree on where the boundaries are, regardless of the colour terms used in their own language.\nBy Alison Motluk.\nNew Scientist, 30 November 2002\n\n.'
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
    'Learning a foreign language makes people consider the relationship between language and thought.',
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
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'In the last century cognitive scientists believed that linguistic differences had a critical effect on communication.',
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
    3,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Dan Slobin agrees with Chomsky on how we perceive the world.',
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
    4,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Boroditsky has conducted gender experiments on a range of speakers.',
    'Choose the correct answer.',
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
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The way we perceive colour is a well-established test of the effect of language on thought.',
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
    6,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The importance of the relative age of speakers',
    'Choose the correct answer.',
    '{"info-q6": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The use of adjectives to distinguish the names of objects or things',
    'Choose the correct answer.',
    '{"info-q7": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A need to use some numbers with the correct gender',
    'Choose the correct answer.',
    '{"info-q8": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A relationship between form and number',
    'Choose the correct answer.',
    '{"info-q9": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The need to know how friendly your relationship is with the person you are addressing',
    'Choose the correct answer.',
    '{"info-q10": ["D", "d"]}'
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nIn the likeness task, Lucy gave his subjects three combs. Two of these were made of the same _______ and two were alike in that they had the same (...) . In another experiment, plastic and (...) items were used.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["material"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nIn the likeness task, Lucy gave his subjects three combs. Two of these were made of the same (...) and two were alike in that they had the same _______ . In another experiment, plastic and (...) items were used.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["design"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nIn the likeness task, Lucy gave his subjects three combs. Two of these were made of the same (...) and two were alike in that they had the same (...) . In another experiment, plastic and _______ items were used.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q13": ["cardboard"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThe _______ that English and Yucatec speakers used to group these objects helped him show that speakers of different languages think about things differently.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q14": ["method"]}'::jsonb
  );


END$$;


COMMIT;