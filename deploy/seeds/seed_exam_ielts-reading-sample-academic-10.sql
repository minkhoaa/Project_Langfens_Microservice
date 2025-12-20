-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T13:51:33.737400
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #10
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-10
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-10'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-10';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-10';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-10';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-10',
    'IELTS Reading Sample (Academic) #10',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #10',
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
    'Reading Passage - IELTS Reading Sample (Academic) #10',
    E'# Passage\n\nAcademic Reading 28\nAustralian Aborigines Demand Return of Remains\nAs a former British colony, Australia has close cultural and historical links with the United Kingdom, due to the British and Irish settlers who arrived in droves in the 19th and 20th centuries. One aspect of this contact is the role of Britain, and British archaeologists and collectors, in taking Aboriginal bones, relics and artefacts from Australia to museums and collections in the UK. Now leaders of the indigenous people of Australia, the Aborigines, are demanding that any Aboriginal remains in the UK are returned to Australia.\nIn 19th century Britain, there was a mania for collecting all kinds of objects from other countries. These were sent home, where they were kept in museums such as the British Museum and the Natural History Museum. Museums in the UK have a huge number of such objects - objects which, say protesters, were basically stolen during Britain''s long colonial history, with little or no regard for the feelings or rights of the people to whom the objects originally belonged.\nNow the Australian Prime Minister is supporting Aboriginal calls for the objects and remains to be returned to their original home. A spokesman for the Aboriginal Council of New South Wales, Stevie McCoy, said: "The bones do not belong abroad. They belong here. This is about beliefs, and a traditional Aboriginal belief is that our ancestors can only find peace if their remains are buried in the homeland."\nThere are certainly lots of Aboriginal remains in the UK, although their exact locations are not entirely clear. What is known is that, between them, the British Museum and the Natural History Museum have some 2,000 - 2,5000 artefacts composed of human remains, although the museums point out that only about 500 of these are of Aboriginal origin. Dr William Cowell Bell, for the London Museum Association, adds that "A lot of the objects are not human remains in their original form, but are made out of human remains. These include decorated skulls and bones from which charms and amulets have been created." A smaller number of similar artefacts are known to be held in collections in Oxford and Cambridge.\nThere is some sensitivity to Aboriginal demands in the archaeological world. Lady Amanda Spurway, life president of the Glover Museum in London, says that the museum has had its small collection of Aboriginal remains packed ready for return for a decade, and is only waiting for information about where they must go.\nThe National College of Surgeons says it will return the remains of any individual who can be named (although it is obviously difficult to put names to them after such a long time). This growing sensitivity to the hitherto ignored rights of indigenous peoples around the world has caused some relics to be restored to their original country, particularly in Scotland, where a group of Aboriginal remains has already been returned. Edinburgh University has returned skulls and bones to Tasmania and New Zealand.\nOne problem, according to legal expert Ewan Mather, is that the law allowing museums to decide what to do with these objects is more relaxed in Scotland. English museums, on the other hand, are not allowed (either by law or by the groups of trustees who run them) to just hand back remains of their own accord. However, British supporters of the Aborigines claim that such restrictive laws are inhumane in the modern world, and that it would be a simple enough matter to change them in order to allow the items to be returned.\nA further objection to handing back relics is because of their scientific value, claim some museum directors. Dr Bell believes that the size of the collection in the Natural History Museum in Lincoln made it a very valuable resource in the analysis of the way of life of Aborigines, and could be used to study the origin and development of the people. Breaking up the collection might mean that such knowledge could be lost forever.\nAboriginal groups, however, respond by pointing out that the scientific importance of the remains has to be seen against a backdrop of human rights. "I doubt whether the British government would allow several thousand bones of British soldiers to be used for ''scientific purposes'' in any other country," said Stevie McCoy, with a hint of irony. "Would the families allow it? I think there would be a public outcry, no matter how old the remains were. This practice [of taking bones and human remains] went on from the first moment the white man came to Australia right up to the early part of the 20th century. It is a scandal."\nThe British government, meanwhile, has announced that it will set up a working party to discuss the possibility of changes to the law. This might allow museums to negotiate on their own with Aboriginal and other groups around the world.\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_MULTIPLE',
    'READING',
    2,
    'The Aboriginal demand that bones be returned to Australia is based on whichTWOideas?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The rightful place for the remains is Australia.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Britain had no right to take the remains.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The remains have religious significance for Aborigines.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Some remains have already been returned.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Aboriginal ancestors cannot find peace unless their remains are laid to rest there.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_MULTIPLE',
    'READING',
    2,
    'WhichTWOfactors might cause problems when it comes to returning the remains?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Scottish and English law does not allow museums to return objects.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It is not clear what will happen to the remains once they have been returned.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The remains are scientifically important and need to be studied.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Not all the Australian artefacts are human remains.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Some museums do not have the right to return objects to their countries of origin.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_MULTIPLE',
    'READING',
    2,
    'WhichTWOpoints may help to speed up the process of returning the remains?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The British government is going to discuss the return of Aboriginal items.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Some items have already been returned to their countries of origin.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. There is already some sympathy to the Aborigines'' claims in the world of archaeology.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Not all the Australian artefacts are human remains.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. The remains have religious significance for Aborigines.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'No country would allow the bones of its citizens to be used for scientific purposes in another country.',
    'Choose the correct answer.',
    '{"info-q4": ["B", "b"]}'
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
    'The Glover Museum is ready to return its Aboriginal bones.',
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
    'Australian remains are a useful resource for scientific study.',
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
    'It would be a problem to accurately identify the human remains.',
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
    'Many Aboriginal remains in Britain have been made into artefacts.',
    'Choose the correct answer.',
    '{"info-q8": ["C", "c"]}'
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
    'Discrepancies in the laws of different countries can hinder the return of relics.',
    'Choose the correct answer.',
    '{"info-q9": ["E", "e"]}'
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nAborigines believe that the remains should be returned for \n	a number of reasons. First is the fact that the relics were taken during the period \n	when Australia was a 10 . \n	The Aborigine belief that their ancestors can only 11 if their bones are returned is a further \n	factor. Thirdly, the res _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": ["colony", "British colony"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nAborigines believe that the remains should be returned for \n	a number of reasons. First is the fact that the relics were taken during the period \n	when Australia was a 10 . \n	The Aborigine belief that their ancestors can only 11 if their bones are returned is a further \n	factor. Thirdly, the res _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["find peace"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nAborigines believe that the remains should be returned for \n	a number of reasons. First is the fact that the relics were taken during the period \n	when Australia was a 10 . \n	The Aborigine belief that their ancestors can only 11 if their bones are returned is a further \n	factor. Thirdly, the res _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["legal"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nAborigines believe that the remains should be returned for \n	a number of reasons. First is the fact that the relics were taken during the period \n	when Australia was a 10 . \n	The Aborigine belief that their ancestors can only 11 if their bones are returned is a further \n	factor. Thirdly, the res _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q13": ["resource"]}'::jsonb
  );


END$$;


COMMIT;