-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:03:40.572041
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (General) #8
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-general-8
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-general-8'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-general-8';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-general-8';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-general-8';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-general-8',
    'IELTS Reading Sample (General) #8',
    'IELTS Reading Practice Test: IELTS Reading Sample (General) #8',
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
    'Reading Passage - IELTS Reading Sample (General) #8',
    E'# Passage\n\nGeneral Reading Passage 18\nHow Babies Learn Language\nDuring the first year of a child’s life, parents and carers \n	are concerned with its physical development; during the second year, they watch \n	the baby’s language development very carefully. It is interesting just how easily \n	children learn language. Children who are just three or four years old, who \n	cannot yet tie their shoelaces, are able to speak in full sentences without \n	any specific language training.\nThe current view of child language development is that it \n	is an instinct - something as natural as eating or sleeping. According to experts \n	in this area, this language instinct is innate - something each of us is born \n	with. But this prevailing view has not always enjoyed widespread acceptance.\nIn the middle of last century, experts of the time, including \n	a renowned professor at Harvard University in the United States, regarded child \n	language development as the process of learning through mere repetition. Language \n	“habits” developed as young children were rewarded for repeating language correctly \n	and ignored or punished when they used incorrect forms of language. Over time, \n	a child, according to this theory, would learn language much like a dog might \n	learn to behave properly through training.\nYet even though the modern view holds that language is instinctive, \n	experts like Assistant Professor Lise Eliot are convinced that the interaction \n	a child has with its parents and caregivers is crucial to its developments. \n	The language of the parents and caregivers act as models for the developing \n	child. In fact, a baby’s day-to-day experience is so important that the child \n	will learn to speak in a manner very similar to the model speakers it hears.\nGiven that the models parents provide are so important, it \n	is interesting to consider the role of "baby talk" in the child’s language development. \n	Baby talk is the language produced by an adult speaker who is trying to exaggerate \n	certain aspects of the language to capture the attention of a young baby.\nDr Roberta Golinkoff believes that babies benefit from baby \n	talk. Experiments show that immediately after birth babies respond more to infant-directed \n	talk than they do to adult-directed talk. When using baby talk, people exaggerate \n	their facial expressions, which helps the baby to begin to understand what is \n	being communicated. She also notes that the exaggerated nature and repetition \n	of baby talk helps infants to learn the difference between sounds. Since babies \n	have a great deal of information to process, baby talk helps. Although there \n	is concern that baby talk may persist too long, Dr Golinkoff says that it stops \n	being used as the child gets older, that is, when the child is better able to \n	communicate with the parents.\nProfessor Jusczyk has made a particular study of babies’ \n	ability to recognise sounds, and says they recognise the sound of their own \n	names as early as four and a half months. Babies know the meaning of Mummy and \n	Daddy by about six months, which is earlier than was previously believed. By \n	about nine months, babies begin recognizing frequent patterns in language. A \n	baby will listen longer to the sounds that occur frequently, so it is good to \n	frequently call the infant by its name.\nAn experiment at Johns Hopkins University in USA, in which \n	researchers went to the homes of 16 nine-month-olds, confirms this view. The \n	researchers arranged their visits for ten days out of a two week period. During \n	each visit the researcher played an audio tape that included the same three \n	stories. The stories included odd words such as “python” or “hornbill”, words \n	that were unlikely to be encountered in the babies’ everyday experience. After \n	a couple of weeks during which nothing was done, the babies were brought to \n	the research lab, where they listened to two recorded lists of words. The first \n	list included words heard in the story. The second included similar words, but \n	not the exact ones that were used in the stories.\nJusczyk found the babies listened longer to the words that \n	had appeared in the stories, which indicated that the babies had extracted individual \n	words from the story. When a control group of 16 nine-month-olds, who had not \n	heard the stories, listened to the two groups of words, they showed no preference \n	for either list.\nThis does not mean that the babies actually understand the \n	meanings of the words, just the sound patterns. It supports the idea that people \n	are born to speak, and have the capacity to learn language from the day they \n	are born. This ability is enhanced if they are involved in conversation. And, \n	significantly, Dr Eliot reminds parents that babies and toddlers need to feel \n	they are communicating. Clearly, sitting in front of the television is not enough; \n	the baby must be having an interaction with another speaker.\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Children can learn their first language without being taught.',
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
    2,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'From the time of their birth, humans seem to have an ability to learn language.',
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
    3,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'According to experts in the 1950s and ‘60s, language learning is very similar to the training of animals.',
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
    4,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Repetition in language learning is important, according to Dr Eliot.',
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
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Dr Golinkoff is concerned that “baby talk” is spoken too much by some parents.',
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
    6,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The first word a child learns to recognise is usually “Mummy” or “Daddy”.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThe study of (1) _______ in very young children has changed considerably \n	in the last 50 years. It has been established that children can speak independently \n	at age (2) (...) , and that this ability \n	is innate. The child will, in fact, follow the speech patterns and linguistic behaviour \n	of its carers and parents who act as (3) (...) .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q7": ["language development"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThe study of (1) (...) in very young children has changed considerably \n	in the last 50 years. It has been established that children can speak independently \n	at age (2) _______ , and that this ability \n	is innate. The child will, in fact, follow the speech patterns and linguistic behaviour \n	of its carers and parents who act as (3) (...) .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q8": ["3-4 years"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThe study of (1) (...) in very young children has changed considerably \n	in the last 50 years. It has been established that children can speak independently \n	at age (2) (...) , and that this ability \n	is innate. The child will, in fact, follow the speech patterns and linguistic behaviour \n	of its carers and parents who act as (3) _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q9": ["models"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nBabies actually benefit from “baby talk”, in which adults (4) _______ both sounds and facial expressions. Babies'' ability \n	to (5) (...) sound patterns rather \n	than words comes earlier than was previously thought. It is very important that \n	babies are included in (6) (...) .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": ["exaggerate"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nBabies actually benefit from “baby talk”, in which adults (4) (...) both sounds and facial expressions. Babies'' ability \n	to (5) _______ sound patterns rather \n	than words comes earlier than was previously thought. It is very important that \n	babies are included in (6) (...) .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["recognise"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nBabies actually benefit from “baby talk”, in which adults (4) (...) both sounds and facial expressions. Babies'' ability \n	to (5) (...) sound patterns rather \n	than words comes earlier than was previously thought. It is very important that \n	babies are included in (6) _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["conversation", "interaction", "communication"]}'::jsonb
  );


END$$;


COMMIT;