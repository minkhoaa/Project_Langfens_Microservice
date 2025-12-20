-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:02:30.800151
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #30
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-30
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-30'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-30';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-30';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-30';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-30',
    'IELTS Reading Sample (Academic) #30',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #30',
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
    'Reading Passage - IELTS Reading Sample (Academic) #30',
    E'# Passage\n\nIELTS Reading Academic 30\nLost for Words\nMany minority languages are on the danger list\nIn the Native American Navajo nation which sprawls across four states in the American south-west, the native language is dying. Most of its speakers are middle-age or elderly. Although many students take classes in Navajo, the schools are run in English. Street sign, supermarket goods and even their own newspaper are all in English. Not surprisingly, linguists doubt that any native speakers of Navajo will remain in a hundred years’ time.\nNavajo is far from alone. Half the world’s 6,800 languages are likely to vanish within two generations - that’s one language lost every ten days. Never before has the planet’s linguistic diversity shrunk at such a pace. “At the moment, we are heading for about three or four languages dominating the world”, says Mark Pagel, an evolutionary biologist at the University of Reading. “It’s a mass extinction, and whether we will ever rebound from the loss is difficult to know.’\nIsolation breeds linguistic diversity as a result, the world is peppered with languages spoken by only a few people. Only 250 languages have more than a million speakers, and at least 3,000 have fewer than 2,500. It is not necessarily these small languages that are about to disappear. Navajo is considered endangered despite having 150,000 speakers. What makes a language endangered is not that the number of speakers, but how old they are. If it is spoken by children it is relatively safe. The critically endangered languages are those that are only spoken by the elderly, according to Michael Krauss, director of the Alaska Native Language Center, in Fairbanks.\nWhy do people reject the language of their parent? It begins with a crisis of confidence when a small community finds itself alongside a larger, wealthier society, says Nicholas Ostler of Britain’s Foundation for Endangered Languages, in Bath. ‘People lose faith in their culture’ he says. ‘When the next generation reaches their teens, they might not want to be induced into the old tradition.’\nThe change is not always voluntary. Quite often, governments try to kill off a minority language by banning its use in public or discouraging its use in school, all to promote national unity. The former US policy of running Indian reservation in English, for example, effectively put languages such as Navajo on the danger list. But Salikoko Mufwene, who chairs the Linguistics Department at the University of Chicago, argues that the deadliest weapon is not government policy but economic globalisation. ‘Native Americans have not lost pride in their language, but they have had to adapt to socio-economic pressures’ he says. ‘They cannot refuse to speak English if most commercial activity is in English". But are languages worth saving? At the very least, there is a loss of data for the study of languages and their evolution, which relies on comparisons between languages, both living and dead. When an unwritten and unrecorded language disappears, it is lost to science.\nLanguage is also intimately bond up with culture, so it may be difficult to reserve one without the other. ‘If a person shifts from Navajo to English, they lose something'' Mufwene says. ‘Moreover, the loss of diversity may also deprive us of different ways of looking at the world’, says Pagel. There is mounting evidence that learning a language produces physiological changes in brain. ‘Your brain and mine are different from the brain of someone, who speaks French, for instance’ Pagel says, and this could affect our thoughts and perceptions. ‘The patterns and connections we make among various concepts may be structured by the linguistic habits of our community.’\nSo despite linguists’ best efforts, many languages will disappear over the next century. But a growing interest in cultural identity may prevent the direst predictions from coming true. ‘The key to fostering diversity is for people to learn their ancestral tongue, as well as the dominant language’ says Doug Whalen, founder and president of the Endangered Language Fund in New Haven, Connecticut. ‘Most of these languages will not survive without a large degree of bilingualism’ he says. In New Zealand, classes for children have slowed the erosion of Maori and rekindled interest in the language. A similar approach in Hawaii has produced about 8000 new speakers of Polynesian languages in the past few years. In California, ‘apprentice’ programmes have provided life support to several indigenous languages. Volunteer ''apprentices'' pair up with one of the last living speakers of Native American tongue to learn a traditional skill such as basket weaving, with instruction exclusively in the endangered language. After about 300 hours of training, they are generally sufficiently fluent to transmit the language to the next generation. But Mufwene says that preventing a language dying out is not the same as giving it new life by using every day. ‘Preserving a language is more likely preserving fruits in a jar’ he says.\nHowever, preservation can bring a language back from the dead. There are examples of languages that have survived in written form and then been revived by latter generations. But a written form is essential for this, so the mere possibility of revival has led many speakers of endangered languages to develop systems of writing where none existed before.\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Endangered languages cannot be saved unless people learn to speak more than one language.',
    'Choose the correct answer.',
    '{"info-q1": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Saving languages from extinction is not in itself a satisfactory goal.',
    'Choose the correct answer.',
    '{"info-q2": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The way we think may be determined by our language.',
    'Choose the correct answer.',
    '{"info-q3": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Young people often reject the established way of life in their community.',
    'Choose the correct answer.',
    '{"info-q4": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A change of language may mean a loss of traditional culture.',
    'Choose the correct answer.',
    '{"info-q5": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The Navajo language will die out because it currently has too few speakers.',
    'Choose the correct answer.',
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
    7,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'A large number of native speakers fails to guarantee the survival of a language.',
    'Choose the correct answer.',
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
    8,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'National governments could do more to protect endangered languages.',
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
    9,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The loss of linguistic diversity is inevitable.',
    'Choose the correct answer.',
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
    10,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThere are currently approximately 6,800 languages in the world. This great variety of languages came about largely as a result of geographical . But in today''s world, factors such as government initiatives and are contributing to a huge decrease in the number of languages. One factor which may help  _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": ["isolation"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThere are currently approximately 6,800 languages in the world. This great variety of languages came about largely as a result of geographical . But in today''s world, factors such as government initiatives and are contributing to a huge decrease in the number of languages. One factor which may help  _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["economic globalisation", "economic globalization", "socio-economic pressures"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThere are currently approximately 6,800 languages in the world. This great variety of languages came about largely as a result of geographical . But in today''s world, factors such as government initiatives and are contributing to a huge decrease in the number of languages. One factor which may help  _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["cultural identity"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThere are currently approximately 6,800 languages in the world. This great variety of languages came about largely as a result of geographical . But in today''s world, factors such as government initiatives and are contributing to a huge decrease in the number of languages. One factor which may help  _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q13": ["traditional skill"]}'::jsonb
  );


END$$;


COMMIT;