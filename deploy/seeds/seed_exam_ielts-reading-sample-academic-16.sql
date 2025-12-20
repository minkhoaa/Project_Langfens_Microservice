-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:03:44.984076
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #16
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-16
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-16'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-16';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-16';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-16';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-16',
    'IELTS Reading Sample (Academic) #16',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #16',
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
    'Reading Passage - IELTS Reading Sample (Academic) #16',
    E'# Passage\n\nAcademic Reading Passage 36\nA neuroscientist reveals how to think differently\nIn the last decade a revolution has occurred in the way that \n	scientists think about the brain. We now know that the decisions humans make \n	can be traced to the firing patterns of neurons in specific parts of the brain. \n	These discoveries have led to the field known as neuroeconomics, which studies \n	the brain''s secrets to success in an economic environment that demands innovation \n	and being able to do things differently from competitors. A brain that can do \n	this is an iconoclastic one. Briefly, an iconoclast is a person who does something \n	that others say can''t be done.\nThis definition implies that iconoclasts are different from \n	other people, but more precisely, it is their brains that are different in three \n	distinct ways: perception, fear response, and social intelligence. Each of these \n	three functions utilizes a different circuit in the brain. Naysayers might suggest \n	that the brain is irrelevant, that thinking in an original, even revolutionary, \n	way is more a matter of personality than brain function. But the field of neuroeconomics \n	was born out of the realization that the physical workings of the brain place \n	limitations on the way we make decisions. By understanding these constraints, \n	we begin to understand why some people march to a different drumbeat.\nThe first thing to realize is that the brain suffers from \n	limited resources. It has a fixed energy budget, about the same as a 40 watt \n	light bulb, so it has evolved to work as efficiently as possible. This is where \n	most people are impeded from being an iconoclast. For example, when confronted \n	with information streaming from the eyes, the brain will interpret this information \n	in the quickest way possible. Thus it will draw on both past experience and \n	any other source of information, such as what other people say, to make sense \n	of what it is seeing. This happens all the time. The brain takes shortcuts that \n	work so well we are hardly ever aware of them. We think our perceptions of the \n	world are real, but they are only biological and electrical rumblings. Perception \n	is not simply a product of what your eyes or ears transmit to your brain. More \n	than the physical reality of photons or sound waves, perception is a product \n	of the brain.\nPerception is central to iconoclasm. Iconoclasts see things \n	differently to other people. Their brains do not fall into efficiency pitfalls \n	as much as the average person''s brain. Iconoclasts, either because they were \n	born that way or through learning, have found ways to work around the perceptual \n	shortcuts that plague most people. Perception is not something that is hardwired \n	into the brain. It is a learned process, which is both a curse and an opportunity \n	for change. The brain faces the fundamental problem of interpreting physical \n	stimuli from the senses. Everything the brain sees, hears, or touches has multiple \n	interpretations. The one that is ultimately chosen is simply the brain''s best \n	theory. In technical terms, these conjectures have their basis in the statistical \n	likelihood of one interpretation over another and are heavily influenced by \n	past experience and, importantly for potential iconoclasts, what other people \n	say.\nThe best way to see things differently to other people is \n	to bombard the brain with things it has never encountered before. Novelty releases \n	the perceptual process from the chains of past experience and forces the brain \n	to make new judgments. Successful iconoclasts have an extraordinary willingness \n	to be exposed to what is fresh and different. Observation of iconoclasts shows \n	that they embrace novelty while most people avoid things that are different.\nThe problem with novelty, however, is that it tends to trigger \n	the brain''s fear system. Fear is a major impediment to thinking like an iconoclast \n	and stops the average person in his tracks. There are many types of fear, but \n	the two that inhibit iconoclastic thinking and people generally find difficult \n	to deal with are fear of uncertainty and fear of public ridicule. These may \n	seem like trivial phobias. But fear of public speaking, which everyone must \n	do from time to time, afflicts one-third of the population. This makes it too \n	common to be considered a mental disorder. It is simply a common variant of \n	human nature, one which iconoclasts do not let inhibit their reactions.\nFinally, to be successful iconoclasts, individuals must sell \n	their ideas to other people. This is where social intelligence comes in. Social \n	intelligence is the ability to understand and manage people in a business setting. \n	In the last decade there has been an explosion of knowledge about the social \n	brain and how the brain works when groups coordinate decision making. Neuroscience \n	has revealed which brain circuits are responsible for functions like understanding \n	what other people think, empathy, fairness, and social identity. These brain \n	regions play key roles in whether people convince others of their ideas. Perception \n	is important in social cognition too. The perception of someone''s enthusiasm, \n	or reputation, can make or break a deal. Understanding how perception becomes \n	intertwined with social decision making shows why successful iconoclasts are \n	so rare.\nIconoclasts create new opportunities in every area from artistic \n	expression to technology to business. They supply creativity and innovation \n	not easily accomplished by committees. Rules aren''t important to them. Iconoclasts \n	face alienation and failure, but can also be a major asset to any organization. \n	It is crucial for success in any field to understand how the iconoclastic mind \n	works.\n\n.'
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
    'Neuroeconomics is a field of study which seeks to',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Acause a change in how scientists understand brain chemistry.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bunderstand how good decisions are made in the brain.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cunderstand how the brain is linked to achievement in competitive fields.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dtrace the specific firing patterns of neurons in different areas of the brain.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'According to the writer, iconoclasts are distinctive because',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Athey create unusual brain circuits.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Btheir brains function differently.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Ctheir personalities are distinctive.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dthey make decisions easily.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'According to the writer, the brain works efficiently because',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Ait uses the eyes quickly.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bit interprets data logically.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cit generates its own energy.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dit relies on previous events.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'The writer says that perception is',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Aa combination of photons and sound waves.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Ba reliable product of what your senses transmit.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Ca result of brain processes.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Da process we are usually conscious of.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'According to the writer, an iconoclastic thinker',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Acentralises perceptual thinking in one part of the brain.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bavoids cognitive traps.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Chas a brain that is hardwired for learning.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dhas more opportunities than the average person.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Exposure to different events forces the brain to think differently.',
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
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Iconoclasts are unusually receptive to new experiences.',
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
    'Most people are too shy to try different things.',
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
    'If you think in an iconoclastic way, you can easily overcome fear.',
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
    10,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'When concern about embarrassment matters less, other fears become irrelevant.',
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
    11,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Fear of public speaking is a psychological illness.',
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
    12,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Thinking like a successful iconoclast is demanding because it',
    'Choose the correct answer.',
    '{"info-q12": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The concept of the social brain is useful to iconoclasts because it',
    'Choose the correct answer.',
    '{"info-q13": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Iconoclasts are generally an asset because their way of thinking',
    'Choose the correct answer.',
    '{"info-q14": ["C", "c"]}'
  );


END$$;


COMMIT;