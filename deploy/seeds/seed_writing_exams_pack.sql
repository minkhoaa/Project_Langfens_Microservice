-- ============================================
-- IELTS Writing Exam Pack — 12 popular prompts
-- Task 1 (Academic + GT) + Task 2 (opinion / discuss / problem-solution)
-- Idempotent: cleans by Slug before insert.
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Helper: drop existing rows with these slugs so re-runs are clean.
DELETE FROM "writing_exams" WHERE "Slug" IN (
  'task1-academic-bar-chart-population-by-age',
  'task1-academic-line-graph-internet-users',
  'task1-academic-pie-chart-energy-sources',
  'task1-academic-process-bottle-recycling',
  'task1-gt-letter-complaint-noisy-neighbour',
  'task1-gt-letter-job-application-receptionist',
  'task2-opinion-children-screen-time',
  'task2-opinion-university-tuition-free',
  'task2-discuss-cars-vs-public-transport',
  'task2-discuss-traditional-vs-modern-buildings',
  'task2-problem-solution-traffic-congestion',
  'task2-problem-solution-air-pollution-cities'
);

-- ============================================
-- TASK 1 — Academic
-- ExamType: 1 = Task 1
-- ============================================

INSERT INTO "writing_exams" (
  "Id", "Title", "Slug", "TaskText", "ExamType", "Level",
  "Tags", "ModelAnswers", "CreatedAt", "CreatedBy", "ImageUrl"
) VALUES
(
  gen_random_uuid(),
  E'Population by Age Group — Bar Chart',
  'task1-academic-bar-chart-population-by-age',
  E'The chart below shows the percentage of the population in different age groups in three countries (UK, Japan, India) in 2020 and projected for 2050.\n\nSummarise the information by selecting and reporting the main features, and make comparisons where relevant.\n\nWrite at least 150 words.',
  1, 'B2', 'ielts,task1,academic,bar-chart',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
),
(
  gen_random_uuid(),
  E'Internet Users by Region — Line Graph',
  'task1-academic-line-graph-internet-users',
  E'The line graph below shows the number of internet users (in millions) in four regions of the world (North America, Europe, Asia, Africa) between 2000 and 2020.\n\nSummarise the information by selecting and reporting the main features, and make comparisons where relevant.\n\nWrite at least 150 words.',
  1, 'B2', 'ielts,task1,academic,line-graph',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
),
(
  gen_random_uuid(),
  E'Sources of Energy in Australia — Pie Chart',
  'task1-academic-pie-chart-energy-sources',
  E'The two pie charts below show the main sources of energy used in Australia in 1990 and in 2020.\n\nSummarise the information by selecting and reporting the main features, and make comparisons where relevant.\n\nWrite at least 150 words.',
  1, 'B2', 'ielts,task1,academic,pie-chart',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
),
(
  gen_random_uuid(),
  E'Plastic Bottle Recycling Process',
  'task1-academic-process-bottle-recycling',
  E'The diagram below shows the process by which used plastic bottles are recycled into new products.\n\nSummarise the information by selecting and reporting the main features, and make comparisons where relevant.\n\nWrite at least 150 words.',
  1, 'B2', 'ielts,task1,academic,process',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
),

-- ============================================
-- TASK 1 — General Training (letters)
-- ============================================
(
  gen_random_uuid(),
  E'Letter of Complaint — Noisy Neighbour',
  'task1-gt-letter-complaint-noisy-neighbour',
  E'You live in a flat. You have been having problems with the noise from a neighbour''s flat above you.\n\nWrite a letter to your neighbour. In your letter,\n- explain who you are\n- describe the problem\n- suggest what could be done\n\nWrite at least 150 words.\n\nYou do NOT need to write any addresses.\n\nBegin your letter as follows:\nDear .......................,',
  1, 'B1', 'ielts,task1,gt,letter,complaint',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
),
(
  gen_random_uuid(),
  E'Letter of Application — Receptionist Position',
  'task1-gt-letter-job-application-receptionist',
  E'You have seen an advertisement for a part-time receptionist position at a hotel near where you live. You would like to apply for this job.\n\nWrite a letter to the hotel manager. In your letter,\n- explain why you would like to work at this hotel\n- describe the experience and skills you have\n- give details of when you would be available to start\n\nWrite at least 150 words.\n\nYou do NOT need to write any addresses.\n\nBegin your letter as follows:\nDear Sir or Madam,',
  1, 'B1', 'ielts,task1,gt,letter,application',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
),

-- ============================================
-- TASK 2 — Opinion (Agree/Disagree)
-- ExamType: 2 = Task 2
-- ============================================
(
  gen_random_uuid(),
  E'Children and Screen Time',
  'task2-opinion-children-screen-time',
  E'Some people believe that children today spend too much time on smartphones, tablets and computers, and this is harming their development.\n\nTo what extent do you agree or disagree?\n\nGive reasons for your answer and include any relevant examples from your own knowledge or experience.\n\nWrite at least 250 words.',
  2, 'B2', 'ielts,task2,opinion,technology',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
),
(
  gen_random_uuid(),
  E'Free University Tuition',
  'task2-opinion-university-tuition-free',
  E'Some people think that all university education should be free for everyone, while others believe that students or their families should pay for it.\n\nDiscuss both views and give your own opinion.\n\nGive reasons for your answer and include any relevant examples from your own knowledge or experience.\n\nWrite at least 250 words.',
  2, 'C1', 'ielts,task2,discussion,education',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
),

-- ============================================
-- TASK 2 — Discuss both views
-- ============================================
(
  gen_random_uuid(),
  E'Cars vs Public Transport',
  'task2-discuss-cars-vs-public-transport',
  E'Some people think that the government should encourage people to use public transport instead of private cars to reduce traffic and pollution. Others believe that owning a private car is a personal right.\n\nDiscuss both views and give your own opinion.\n\nGive reasons for your answer and include any relevant examples from your own knowledge or experience.\n\nWrite at least 250 words.',
  2, 'B2', 'ielts,task2,discussion,transport,environment',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
),
(
  gen_random_uuid(),
  E'Traditional vs Modern Buildings',
  'task2-discuss-traditional-vs-modern-buildings',
  E'Some people think that historical buildings should be preserved at all costs. Others believe that they should be replaced with modern buildings that are more efficient and useful.\n\nDiscuss both views and give your own opinion.\n\nGive reasons for your answer and include any relevant examples from your own knowledge or experience.\n\nWrite at least 250 words.',
  2, 'C1', 'ielts,task2,discussion,architecture,culture',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
),

-- ============================================
-- TASK 2 — Problem & Solution
-- ============================================
(
  gen_random_uuid(),
  E'Solving Traffic Congestion',
  'task2-problem-solution-traffic-congestion',
  E'In many large cities around the world, traffic congestion is becoming a serious problem.\n\nWhat are the main causes of this problem, and what measures could be taken to solve it?\n\nGive reasons for your answer and include any relevant examples from your own knowledge or experience.\n\nWrite at least 250 words.',
  2, 'B2', 'ielts,task2,problem-solution,transport',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
),
(
  gen_random_uuid(),
  E'Air Pollution in Cities',
  'task2-problem-solution-air-pollution-cities',
  E'Air pollution is a major problem in many cities today. Vehicles, factories and rapid urbanisation are all contributing to declining air quality.\n\nWhat problems does this cause, and what solutions can governments and individuals adopt?\n\nGive reasons for your answer and include any relevant examples from your own knowledge or experience.\n\nWrite at least 250 words.',
  2, 'B2', 'ielts,task2,problem-solution,environment,health',
  NULL, now(), '00000000-0000-0000-0000-000000000000', ''
);

COMMIT;

-- Verification: should print 12 + 1 (existing letter exam) = 13 rows
SELECT COUNT(*) AS total_writing_exams FROM "writing_exams";
SELECT "ExamType",
       CASE "ExamType" WHEN 1 THEN 'Task 1' WHEN 2 THEN 'Task 2' ELSE 'Unknown' END AS task,
       COUNT(*) AS count
FROM "writing_exams" GROUP BY "ExamType" ORDER BY "ExamType";
