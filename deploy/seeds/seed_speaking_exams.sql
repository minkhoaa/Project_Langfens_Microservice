-- ============================================
-- IELTS Speaking Exam Pack — Mock speaking prompts
-- ============================================

BEGIN;

-- ============================================
-- TASK 1 — Speaking Part 1
-- ExamType: 1 = Part 1
-- ============================================

INSERT INTO "speaking_exams" (
  "Id", "Title", "TaskText", "ExamType", "Level",
  "Tags", "CreatedAt", "CreatedBy"
) VALUES
(
  gen_random_uuid(),
  E'Speaking Part 1: Hometown',
  E'Let’s talk about your hometown or village.\n\n- What kind of place is it?\n- What’s the most interesting part of your town/village?\n- What kind of jobs do the people in your town/village do?\n- Would you say it’s a good place to live? (Why?)',
  1, 'B1', 'ielts,speaking,part1,hometown',
  now(), '00000000-0000-0000-0000-000000000000'
),
(
  gen_random_uuid(),
  E'Speaking Part 1: Work or Studies',
  E'Let’s talk about your work or studies.\n\n- Do you work or are you a student?\n- Why did you choose that job/subject?\n- What is the most difficult part of your job/studies?\n- What do you like most about your job/studies?',
  1, 'B1', 'ielts,speaking,part1,work,studies',
  now(), '00000000-0000-0000-0000-000000000000'
),

-- ============================================
-- TASK 2 — Speaking Part 2
-- ExamType: 2 = Part 2
-- ============================================
(
  gen_random_uuid(),
  E'Speaking Part 2: Describe a book',
  E'Describe a book that you enjoyed reading because you had to think a lot.\n\nYou should say:\n- what this book was\n- why you decided to read it\n- what reading this book made you think about\n\nand explain why you enjoyed reading it.',
  2, 'B2', 'ielts,speaking,part2,book',
  now(), '00000000-0000-0000-0000-000000000000'
),
(
  gen_random_uuid(),
  E'Speaking Part 2: Describe a historical building',
  E'Describe a historical building you have visited.\n\nYou should say:\n- where it was\n- what it looked like\n- what you learned there\n\nand explain why you liked visiting this building.',
  2, 'B2', 'ielts,speaking,part2,building,history',
  now(), '00000000-0000-0000-0000-000000000000'
),

-- ============================================
-- TASK 3 — Speaking Part 3
-- ExamType: 3 = Part 3
-- ============================================
(
  gen_random_uuid(),
  E'Speaking Part 3: Reading and Books',
  E'Let’s consider reading and books in general.\n\n- Do people read more today than in the past?\n- Do you think printed books will eventually disappear completely?\n- What are the advantages of reading a book compared to watching a movie based on the book?',
  3, 'C1', 'ielts,speaking,part3,reading,books',
  now(), '00000000-0000-0000-0000-000000000000'
),
(
  gen_random_uuid(),
  E'Speaking Part 3: Historical Buildings',
  E'Let’s consider historical buildings in general.\n\n- Why do you think people like to visit historical buildings?\n- Should the government pay to preserve historical buildings, or should they be funded privately?\n- What impact does preserving historical buildings have on a city’s development?',
  3, 'C1', 'ielts,speaking,part3,building,history',
  now(), '00000000-0000-0000-0000-000000000000'
);

COMMIT;
