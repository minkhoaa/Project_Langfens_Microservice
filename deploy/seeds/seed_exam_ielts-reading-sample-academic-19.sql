-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:03:28.196983
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #19
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-19
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-19'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-19';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-19';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-19';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-19',
    'IELTS Reading Sample (Academic) #19',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #19',
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
    'Reading Passage - IELTS Reading Sample (Academic) #19',
    E'# Passage\n\nAcademic Reading Passage 39\nThe robots are coming - or are they?\nWhat is the current state of play in Artificial Intelligence?\nA.\nCan robots advance so far that they become the ultimate threat to our existence? Some scientists say no, and dismiss the very idea of Artificial Intelligence. The human brain, they argue, is the most complicated system ever created, and any machine designed to reproduce human thought is bound to fail. Physicist Roger Penrose of Oxford University and others believe that machines are physically incapable of human thought. Colin McGinn of Rutgers University backs this up when he says that Artificial Intelligence ‘is like sheep trying to do complicated psychoanalysis. They just don’t have the conceptual equipment they need in their limited brains.’\nB.\nArtificial Intelligence, or AI, is different from most technologies in that scientists still understand very little about how intelligence works. Physicists have a good understanding of Newtonian mechanics and the quantum theory of atoms and molecules, whereas the basic laws of intelligence remain a mystery. But a sizeable number of mathematicians and computer scientists, who are specialists in the area, are optimistic about the possibilities. To them it is only a matter of time before a thinking machine walks out of the laboratory. Over the years, various problems have impeded all efforts to create robots. To attack these difficulties, researchers tried to use the ‘top-down approach’, using a computer in an attempt to program all the essential rules onto a single disc. By inserting this into a machine, it would then become self-aware and attain a human-like intelligence.\nC.\nIn the 1950s and 1960s great progress was made, but the shortcomings of these prototype robots soon became clear. They were huge and took hours to navigate across a room. Meanwhile, a fruit fly, with a brain containing only a fraction of the computing power, can effortlessly navigate in three dimensions. Our brains, like the fruit fly’s, unconsciously recognise what we see by performing countless calculations. This unconscious awareness of patterns is exactly what computers are missing. The second problem is robots’ lack of common sense. Humans know that water is wet and that mothers are older than their daughters. But there is no mathematics that can express these truths. Children learn the intuitive laws of biology and physics by interacting with the real world. Robots know only what has been programmed into them.\nD.\nBecause of the limitations of the top-down approach to Artificial Intelligence, attempts have been made to use a ‘bottom-up’ approach instead - that is, to try to imitate evolution and the way a baby learns. Rodney Brooks was the director of MIT’s Artificial Intelligence laboratory, famous for its lumbering ‘top-down’ walking robots. He changed the course of research when he explored the unorthodox idea of tiny ‘insectoid’ robots that learned to walk by bumping into things instead of computing mathematically the precise position of their feet. Today many of the descendants of Brooks’ insectoid boots are on Mars gathering data for NASA (the National Aeronautics and Space Administration), running across the dusty landscape of the planet. For all their successes, in mimicking the behaviour of insects, however, robots using neural networks have performed miserably when their programmers have tried to duplicate in them the behaviour of higher organisms such as mammals. MIT’s Marvin Minsky summarises the problems of AI: ‘The history of AI is sort of funny because the first real accomplishment were beautiful things, like a machine that could do well in a maths course. But then we started to try to make machines that could answer questions about simple children’s stories. There’s no machine today that can do that.’\nE.\nThere are people who believe that eventually there will be a combination between the top-down and bottom-up, which may provide the key to Artificial Intelligence. As adults, we blend the two approaches. It has been suggested that our emotions represent the quality that most distinguishes us as human, that it is impossible for machines ever to have emotions. Computer expert Hans Moravec thinks that in the future robots will be programmed with emotions such as fear to protect themselves so that they can signal to humans when their batteries are running low, for example. Emotions are vital in decision-making. People who have suffered a certain kind of brain injury lose the ability to experience emotions and become unable to make decisions. Without emotions to guide them, they debate endlessly over their options. Moravec points out that as robots become more intelligent and are able to make choices, they could likewise become paralysed with indecision. To aid them, robots of the future might need to have emotions hardwired into their brains.\nF.\nThere is no universal consensus as to whether machines can be conscious, or even, in human terms, what consciousness means. Minsky suggests the thinking process in our brain is not localised but spread out, with different centres competing with one another at any given time. Consciousness may then be viewed as a sequence of thoughts and images issuing from these different, smaller ‘minds’, each one competing for our attention. Robots might eventually attain a ‘silicon consciousness’. Robots, in fact, might one day embody an architecture for thinking and processing information that is different from ours - but also indistinguishable. If that happens, the question of whether they really ‘understand’ becomes largely irrelevant. A robot that has perfect mastery of syntax, for all practical purposes, understands what is being said.\n\n.'
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
    'An insect that proves the superiority of natural intelligence over Artificial Intelligence',
    'Choose the correct answer.',
    '{"info-q1": ["C", "c"]}'
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
    'Robots being able to benefit from their mistakes',
    'Choose the correct answer.',
    '{"info-q2": ["D", "d"]}'
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
    'Many researchers not being put off believing that Artificial Intelligence will eventually be developed',
    'Choose the correct answer.',
    '{"info-q3": ["B", "b"]}'
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
    'An innovative approach that is having limited success',
    'Choose the correct answer.',
    '{"info-q4": ["D", "d"]}'
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
    'The possibility of creating Artificial Intelligence being doubted by some academics',
    'Choose the correct answer.',
    '{"info-q5": ["A", "a"]}'
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
    'No generally accepted agreement of what our brains do',
    'Choose the correct answer.',
    '{"info-q6": ["F", "f"]}'
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
    'Robots not being able to extend their intelligence in the same way as humans',
    'Choose the correct answer.',
    '{"info-q7": ["C", "c"]}'
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
    'Colin McGinn',
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
    'Marvin Minsky',
    'Choose the correct answer.',
    '{"info-q9": ["C", "c"]}'
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
    'Hans Moravec',
    'Choose the correct answer.',
    '{"info-q10": ["A", "a"]}'
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nDespite some advances, the early robots had certain weaknesses. They were given the information they needed on a 11 . This was known as the ‘top-down’ approach and enabled them to do certain tasks but they were unable to recognise 12 . Nor did they have any intuition or ability to make decisions bas _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["disc"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nDespite some advances, the early robots had certain weaknesses. They were given the information they needed on a 11 . This was known as the ‘top-down’ approach and enabled them to do certain tasks but they were unable to recognise 12 . Nor did they have any intuition or ability to make decisions bas _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["patterns"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nDespite some advances, the early robots had certain weaknesses. They were given the information they needed on a 11 . This was known as the ‘top-down’ approach and enabled them to do certain tasks but they were unable to recognise 12 . Nor did they have any intuition or ability to make decisions bas _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q13": ["Mars"]}'::jsonb
  );


END$$;


COMMIT;