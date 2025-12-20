-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:04:09.334680
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #14
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-14
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-14'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-14';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-14';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-14';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-14',
    'IELTS Reading Sample (Academic) #14',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #14',
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
    'Reading Passage - IELTS Reading Sample (Academic) #14',
    E'# Passage\n\nAcademic Reading Passage 32\nLIFE WITHOUT DEATH\nby Duncan Turner\nUntil recently, the thought that there might ever be \n		a cure for ageing seemed preposterous. Growing older and more decrepit appeared \n		to be an inevitable and necessary part of being human. Over the last decade, \n		however, scientists have begun to see ageing differently. Some now believe \n		that the average life-expectancy may soon be pushed up to 160 years; others \n		think that it may be extended to 200 or 300 years. A handful even wonder \n		whether we might one day live for a millennium or more.\nBehind this new excitement is the theory that the primary \n		cause of ageing lies in highly reactive molecules called free radicals, \n		left behind by the oxygen we breathe. Free radicals react with the molecules \n		in our bodies, damaging DNA, proteins and other cell tissues, and are known \n		to be implicated in diseases as diverse as cataracts, cancer and Alzheimer''s. \n		The body does its best to protect itself against free radicals by producing \n		its own chemicals to prevent ageing, such as vitamins E and C, but it is \n		always fighting a losing battle.\nA year ago Gordon Lithgow of the University of Manchester \n		discovered a way to help combat free radicals. Using one of these anti-ageing \n		chemicals. he managed to increase the lifespan of one species of earthworm \n		by 50 per cent. Despite cautionary words from the scientists, many welcomed \n		this as the first step towards a drug which would extend life. Research \n		involving the mutation of genes has also thrown up fascinating results: \n		after identifying two of the genes that appear to control how long the earthworm \n		lives, similar genes were found in organisms as various as fruit-flies, \n		mice and human beings. When one considers the vast evolutionary distances \n		that separate these species, it suggests that we may have discovered a key \n		to how ageing is regulated throughout the entire animal kingdom.\nIn June last year a small American company called Eukarion \n		sought permission to carry out the first trials of an anti-ageing drug, \n		SCS, on human beings. Although it will initially be used to treat diseases \n		associated with old age, Eukarion said, that ''if the effect of treating \n		diseases of old age is to extend life, everyone''s going to be happy.''\nSome scientists, however, are quick to discourage \n		extravagant speculation. ''There is no evidence whatsoever that swallowing \n		any chemical would have an effect on mammals'', says Rich Miller of the University of Michigan. ''And those people who claim it\nmight need to go out and do some \n		experimenting''. Some research, moreover, has produced alarming results. \n		As well as controlling ageing, these, genes also partly control the hormones which regulate growth. \n		The upshot of this is that although the lives of mutant mice can be extended \n		by up to 80 per cent, they remain smaller than normal.\nQuite apart from these sorts of horrors, the ethical \n		implications of extending human lifespan are likely to worry many people. \n		Even if the falling birth-rates reported in the world''s developed nations \n		were to be repeated throughout the world, would this be sufficient to compensate \n		for massively extended life-expectancy, and would we be willing to see the \n		demographic balance of our society change out of all recognition? David \n		Gems, the head of the Centre for Research into Ageing at University College, \n		London, is enthusiastic about the opportunities opened up by extended life, \n		but even he observes, ''If people live much longer, the proportion of children \n		would. of course, be very small. It strikes me that it might feel rather \n		claustrophobic: all those middle-aged people and very few children or young \n		people.''\nThe philosopher John Polkinghorne emphasises that any \n		discussion of the merits of life-extending therapies must take into account \n		the quality of the life that is lived: ''One would not wish to prolong life \n		beyond the point it had ceased to be creative and fulfilling and meaningful,'' \n		he says. ''Presumably, there would have to come a point at which life ceased \n		to be creative and became just repetition. Clearly, there are only so many \n		rounds of golf one would want to play.''\nBut Polkinghorne, a member of the Human Genetics Commission, \n		also observes that so far our experience of extended life-expectancy has \n		not resulted in world-weariness. Throughout the last century, life-expectancy \n		rose consistently, thanks to improved diet, better hygiene, continuous medical \n		innovation and the provision of free or subsidised healthcare. In 1952 the \n		Queen sent out 225 telegrams to people on their 100th birthday; in 1996 \n		she sent out 5218. ''Consider also, the lives of our Roman and Anglo-Saxon \n		ancestors'' he says. By and large, the doubling of human lifespan we have \n		seen since then has not been a bad thing. Life has not become frustrating \n		and boring. For example, we now live to see our children''s children, and \n		this is good.''\n\n.'
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
    'Scientific predictions about how much it will be possible to lengthen human life vary greatly.',
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
    'MULTIPLE_CHOICE_MULTIPLE',
    'READING',
    2,
    'ChooseTWOletters A-E.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. They are a partial cause of certain diseases.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. They escape into the atmosphere when we breathe.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They are present in two vitamins.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. They harm our body chemistry.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. They are produced by our bodies.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Research into extending life involves both new drugs and changes to genes.',
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
    'Scientific experiments have not succeeded in making any animals live longer.',
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
    5,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Most people in the future will decide not to have children.',
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
    6,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Life expectancy has improved partly because people eat better.',
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
    7,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Eukarion',
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
    'Rich Miller',
    'Choose the correct answer.',
    '{"info-q8": ["D", "d"]}'
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
    'David Gems',
    'Choose the correct answer.',
    '{"info-q9": ["A", "a"]}'
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
    'John Polkinghorne',
    'Choose the correct answer.',
    '{"info-q10": ["C", "c"]}'
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nIn one experiment using anti-ageing chemicals, \n	the life of (11) _______ was extended \n	by half. (12) (...) like the ones \n	which control the ageing process in these animals have also been found in other \n	species. Unfortunately, however, experiments on (13) (...) have been less successful: while they live longer, \n	the (14) (...) controlling their \n	growth are also affected with the result',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["earthworms"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nIn one experiment using anti-ageing chemicals, \n	the life of (11) (...) was extended \n	by half. (12) _______ like the ones \n	which control the ageing process in these animals have also been found in other \n	species. Unfortunately, however, experiments on (13) (...) have been less successful: while they live longer, \n	the (14) (...) controlling their \n	growth are also affected with the result',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["Genes"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nIn one experiment using anti-ageing chemicals, \n	the life of (11) (...) was extended \n	by half. (12) (...) like the ones \n	which control the ageing process in these animals have also been found in other \n	species. Unfortunately, however, experiments on (13) _______ have been less successful: while they live longer, \n	the (14) (...) controlling their \n	growth are also affected with the result',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q13": ["mice"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nIn one experiment using anti-ageing chemicals, \n	the life of (11) (...) was extended \n	by half. (12) (...) like the ones \n	which control the ageing process in these animals have also been found in other \n	species. Unfortunately, however, experiments on (13) (...) have been less successful: while they live longer, \n	the (14) _______ controlling their \n	growth are also affected with the result',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q14": ["hormones"]}'::jsonb
  );


END$$;


COMMIT;