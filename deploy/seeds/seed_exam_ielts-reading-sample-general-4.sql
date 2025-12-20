-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:04:05.292849
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (General) #4
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-general-4
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-general-4'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-general-4';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-general-4';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-general-4';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-general-4',
    'IELTS Reading Sample (General) #4',
    'IELTS Reading Practice Test: IELTS Reading Sample (General) #4',
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
    'Reading Passage - IELTS Reading Sample (General) #4',
    E'# Passage\n\nAcademic Reading Passage 33\nUniversities in Britain\nA)\nToday in Britain there are 124 state universities, \n	but only one private university - the University of Buckingham. Before the 19th \n	century there were only six universities: Oxford. Cambridge, Aberdeen, Edinburgh, \n	Glasgow and St Andrews. Universities were usually linked to the Church and were \n	established between the 13th and 15th centuries. They often have good reputations, \n	beautiful old buildings, traditions and usually offer a wide range of courses.\nB)\nA number of universities were established \n	in the 19th and early 20th centuries as a result of the industrial revolution \n	and they began training highly skilled people for industry. These universities \n	were generally established in major industrial centres such as Birmingham, Manchester, \n	Newcastle and other big cities. Sometimes called modern or civic universities, \n	these universities have the advantage of well-established libraries, academic \n	specialities and accommodation that is close to campus. These universities are \n	often able to provide accommodation for all first year students.\nC)\nA number of new universities were established \n	in the 1960s when children born after World War 2 entered the higher education \n	system. The government decided to expand higher education to educate these students. \n	The advantage of these universities is that they are well planned and most of \n	the living and teaching facilities are on campus.\nD)\nBefore 1992, higher education in the UK was \n	split into polytechnics and universities. The polytechnics provided skilled \n	people for the industries situated in their region - they focused on vocational \n	and professional subjects. For many years, polytechnics didn''t have the same \n	influence as universities. However, by 1992, educational standards in polytechnics \n	were as good as universities and many became universities. Many of these universities \n	also offer diploma courses.\nE)\nThese universities are made of several smaller \n	colleges which come together to form a single university under a senate committee. \n	There are only seven of these institutions in the UK - London University, Oxford \n	and Cambridge are examples. Specialist colleges offer a range of courses in \n	one discipline - for example agriculture, music, design or medicine. Some of \n	these colleges may only offer- postgraduate programmes. These colleges are usually \n	small, with a limited number of students.\nF)\nUniversities have different locations. The \n	older universities often have teaching facilities and student accommodation \n	situated close together. Students in these usually socialise in a particular \n	part of the city and there is a strong sense of community despite being in a \n	large city. Some city campuses are situated on the outskirts of the city. These \n	very often have the space to provide sports facilities and accommodation. They \n	are also close enough to the city for students to enjoy city life. Some universities, \n	notably Oxford and Cambridge, have a collegiate structure - that is, students \n	are members of colleges within the university. These colleges are the centre \n	of social life and academic life. Academic staff usually live at the college, \n	and students and staff enjoy easy relationships.\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section A',
    'Choose the correct answer.',
    '{"section-a-q1": ["ii", "ii. Old universities"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Campus types', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Old universities', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Universities during the industrial revolution', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. University colleges', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rising standards in higher education', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The second expansion', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Former polytechnics', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section B',
    'Choose the correct answer.',
    '{"section-b-q2": ["iii", "iii. Universities during the industrial revolution"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Campus types', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Old universities', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Universities during the industrial revolution', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. University colleges', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rising standards in higher education', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The second expansion', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Former polytechnics', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section C',
    'Choose the correct answer.',
    '{"section-c-q3": ["vi", "vi. The second expansion"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Campus types', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Old universities', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Universities during the industrial revolution', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. University colleges', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rising standards in higher education', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The second expansion', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Former polytechnics', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section D',
    'Choose the correct answer.',
    '{"section-d-q4": ["vii", "vii. Former polytechnics"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Campus types', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Old universities', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Universities during the industrial revolution', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. University colleges', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rising standards in higher education', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The second expansion', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Former polytechnics', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section E',
    'Choose the correct answer.',
    '{"section-e-q5": ["iv", "iv. University colleges"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Campus types', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Old universities', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Universities during the industrial revolution', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. University colleges', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rising standards in higher education', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The second expansion', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Former polytechnics', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section F',
    'Choose the correct answer.',
    '{"section-f-q6": ["i", "i. Campus types"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Campus types', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Old universities', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Universities during the industrial revolution', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. University colleges', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Rising standards in higher education', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The second expansion', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Former polytechnics', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n7 Why were several universities established during the 19th and 20th centuries? _______ 8 What did the government decide to do in the 1960s? (...) 9 What qualification do many former polytechnics provide? (...) 10 What are colleges the centre of? (...)',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q7": ["the industrial revolution"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n8 What did the government decide to do in the 1960s? _______ 9 What qualification do many former polytechnics provide? (...) 10 What are colleges the centre of? (...)',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q8": ["expand higher education"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n9 What qualification do many former polytechnics provide? _______ 10 What are colleges the centre of? (...)',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q9": ["vocational and professional"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n10 What are colleges the centre of? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": ["social life", "academic life"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n11 have accommodation and educational facilities on campus. _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["NU"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n12 provide various courses on a single subject. _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["UC"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n13 have lecturers and students living in the same place. _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q13": ["OU"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n14 were linked to religious institutions. _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q14": ["OU"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    15,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n15 were built in growing cities. _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q15": ["CU"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    16,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n16 offer diploma courses. _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q16": ["FP"]}'::jsonb
  );


END$$;


COMMIT;