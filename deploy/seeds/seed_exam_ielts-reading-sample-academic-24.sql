-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:02:59.930465
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #24
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-24
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-24'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-24';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-24';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-24';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-24',
    'IELTS Reading Sample (Academic) #24',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #24',
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
    'Reading Passage - IELTS Reading Sample (Academic) #24',
    E'# Passage\n\nIELTS Reading Academic 24\nThe Birth of Blue\nAs a primary colour, blue has been the most difficult for artists and scientists to create.\nArtists have always been enhanced by blue, yet fine blues have long been difficult to obtain. Blues are relatively rare in nature, and painters throughout the ages have therefore found themselves at the mercy of what contemporary chemical technology could offer. Some blues have been prohibitively expensive, others were unreliable. The quest for a good blue has driven some crucial technological innovations, showing that the interaction of art and science has not always been a one-way affair.\nThe first pigments were simply ground-up coloured minerals dug from the earth. But few blue minerals are suitable as pigments - so there are no blues in cave art. Ancient Egyptian artists used blue prominently, however, because they knew how to make a fine artificial pigment, now known as Egyptian blue.\nThe discovery of Egyptian blue, like that of many other artificial pigments, was almost certainly an accident. The Egyptians manufactured blue-glazed stones and ornaments called\nfaience\nusing a technique they inherited from the Mesopotamians. Faience manufacture was big business in the ancient world-it was traded all over Europe by 1500 BC. Faience is made by heating stone ornaments in a kiln with copper minerals such as malachite. Egyptian blue, which was made from at least 2500 BC, comes from firing chalk or limestone with sand and copper minerals, and probably appeared by the chance mixture of these ingredients in a faience kiln.\nScientists recently deduced the secrets of another ancient blue: Maya blue, used for centuries throughout central America before the Spanish Conquest. This is a kind of clay - a mineral made of sheets of atoms - with molecules of the blue dye indigo wedged between the sheets. Using indigo in this way makes it less liable to decompose. No one has made colours this way since the Mayas, and no one knows exactly how they did it. But technologists are now interested in using the same trick to make stable pigments from other dyes.\nThe finest pigment available to mediartists was ultramarine, which began to appear in Western art in the 13th century. It was made from the blue mineral\nlapis lazuli\n, of which only one source was known: the remote mines of Badakshan, now in Afghanistan. In addition to the difficulty of transporting the mineral over such distances, making the pigment was a tremendously laborious business. Lapis lazuli turns greyish when powdered because of impurities in the mineral. To extract the pure blue pigment, the powder has to be mixed to a dough with wax and kneaded repeatedly in water.\nAs a result, ultramarine could cost more than its weight in gold, and medieval artists were very selective in using it. Painters since the Renaissance craved a cheaper, more accessible, blue to compare with ultramarine. Things improved in 1704, when a Berlin-based colour maker called Diesbach discovered the first "modern" synthetic pigment: Prussian blue. Diesbach was trying to make a red pigment, using a recipe that involved the alkali potash. But Diesbach''s potash was contaminated with animal oil, and the synthesis did not work out as planned. Instead of red, Diesbach made blue.\nThe oil had reacted to produce cyanide, a vital ingredient of Prussian blue. Diesbach kept his recipe secret for many years, but it was discovered and published in 1724, after which anyone could make the colour. By the 1750s, it cost just a tenth of ultramarine. But it wasn''t such a glorious blue, and painters still weren''t satisfied. They got a better alternative in 1802, when the French chemist Louis Jacques Thenard invented cobalt blue.\nBest of all was the discovery in 1826 of a method for making ultramarine itself. The French Society for the Encouragement of National Industry offered a prize of 6,000 francs in 1824 to anyone who could make artificial ultramarine at an affordable price. The Toulouse chemist Jean-Baptiste Guimet was awarded the prize two years later, when he showed that ultramarine could be made by heating china clay, soda, charcoal, sand and sulphur in a furnace. This meant that there was no longer any need to rely on the scarce natural source, and ultramarine eventually became a relatively cheap commercial pigment (called French ultramarine, as it was first mass-produced in Paris).\nIn the 1950s, synthetic ultramarine became the source of what is claimed to be the world''s most beautiful blue. Invented by the French artist Yves Klein in collaboration with a Parisian paint manufacturer, Edouard Adam, International Klein Blue is a triumph of modern chemistry. Klein was troubled by how pigments lost their richness when they were mixed with liquid binder to make a paint. With Adam''s help, he found that a synthetic resin, thinned with organic solvents, would retain this vibrant texture in the dry paint layer. In 1957, Klein launched his new blue with a series of monochrome paintings, and in 1960 he protected his invention with a patent.\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What was the main disadvantage in using ultramarine for medieval artists?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. It contained a number of impurities.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It was excessively expensive.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The colour wasn''t permanent.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The preparation process was hazardous.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'The discovery of Prussian blue was the result of',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Ausing the wrong quantity of an ingredient.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bmixing the wrong ingredients together.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cincluding an ingredient that was impure.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dusing an ingredient of the wrong colour.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Derived from a scarce natural resource',
    'Choose the correct answer.',
    '{"info-q3": ["C", "c"]}'
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
    'Specially designed to retain its depth of colour when used in paint',
    'Choose the correct answer.',
    '{"info-q4": ["G", "g"]}'
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
    'Was cheap to produce but had limited appeal for artists',
    'Choose the correct answer.',
    '{"info-q5": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Made using a technique which is not yet fully understood',
    'Choose the correct answer.',
    '{"info-q6": ["B", "b"]}'
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
    'Thought to have been produced during another manufacturing process',
    'Choose the correct answer.',
    '{"info-q7": ["A", "a"]}'
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
    'Came to be manufactured inexpensively in large quantities',
    'Choose the correct answer.',
    '{"info-q8": ["F", "f"]}'
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThe colours used in cave paintings and other early art were made by crushing _______ . However, later artists have generally had to rely on the (...) of the day for their supplies of blue. Among the first examples of the widespread use of blue was in (...) art. Over the centuries, many more attempts to create acceptable blues have been made, some of which have led to significant (...) .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q9": ["minerals", "coloured minerals", "colored minerals"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThe colours used in cave paintings and other early art were made by crushing (...) . However, later artists have generally had to rely on the _______ of the day for their supplies of blue. Among the first examples of the widespread use of blue was in (...) art. Over the centuries, many more attempts to create acceptable blues have been made, some of which have led to significant (...) .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": ["technology", "chemical technology", "science"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThe colours used in cave paintings and other early art were made by crushing (...) . However, later artists have generally had to rely on the (...) of the day for their supplies of blue. Among the first examples of the widespread use of blue was in _______ art. Over the centuries, many more attempts to create acceptable blues have been made, some of which have led to significant (...) .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["Egyptian", "Ancient Egyptian"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThe colours used in cave paintings and other early art were made by crushing (...) . However, later artists have generally had to rely on the (...) of the day for their supplies of blue. Among the first examples of the widespread use of blue was in (...) art. Over the centuries, many more attempts to create acceptable blues have been made, some of which have led to significant _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["technological innovations"]}'::jsonb
  );


END$$;


COMMIT;