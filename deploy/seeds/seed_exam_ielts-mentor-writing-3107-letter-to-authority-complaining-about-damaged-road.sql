-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:39.712639
-- Source: ielts-mentor.com
-- Title: Letter To Authority Complaining About Damaged Road
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Authority Complaining About Damaged Road';

-- Insert into writing_exams table
INSERT INTO "writing_exams" (
  "Id",
  "Title", 
  "TaskText",
  "ExamType",
  "Level",
  "Tags",
  "ModelAnswers",
  "CreatedAt",
  "CreatedBy"
)
VALUES (
  gen_random_uuid(),
  E'Letter To Authority Complaining About Damaged Road',
  E'You should spend about\n20\nminutes on this task.\nThe road in front of your house got damaged a long ago and nothing has been done about it. Write a letter to the municipal authority complaining about the damaged road.\nIn your letter:\nintroduce yourself\nexplain the condition of the road\nand suggest what they should do\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am Cory Gardner, a local resident of Ipswich, Queensland‎, Australia, writing on behalf of the residents of the area to notify you about a dilapidated road which is causing unbearable misery for us.\\nI work at a local school and teach mathematics to young students. This is the first time I am writing to the municipal office to complain about something. Park Street, the only road we use to get off and in, from the community, was damaged around three months ago when we had a heavy downpour for a week. The roads have many holes, and crumbly places, and are below usable condition with uneven flagstones.\\nWe expectantly waited for a month when a team of engineers inspected the road in July. But nothing has been done so far to alleviate our suffering.\\nI would request you to send a team to probe the condition of the road and take immediate action to have it repaired. We already have had some minor accidents in the past months and would like you to prevent a major one.\\nYours faithfully,\\nCory Gardner", "Dear Sir or Madam,\\nI am a resident of one of the major suburbs of Johor Bahru city, and I am writing this letter to express my disappointment and frustration over the inaction and negligence of our municipal authority regarding a damaged road.\\nI requested our municipal office to repair the road, which got damaged because of excessive rains and transportation of heavily-loaded vehicles, in front of my house almost a year ago. But, surprisingly, no visible action has been taken yet to show that the damaged road is going to be rebuilt anytime soon. As a result, this road has become really dangerous for even riding a motorbike on it, let alone large vehicles. It even becomes more terrible for travelling, especially when it rains and the water accumulates in the potholes of the damaged road surface because people can not really see the road properly when driving on it.\\nSo, I would like to request you to take the necessary steps on an urgent basis in order to fix the damaged road in front of my house as soon as possible before some major accidents happen.\\nYours sincerely,\\nYan Lee\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.62 (17 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nComplaints-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nD K Tiwari\\n6 years 3 months\\nI need the letter format for repairing the park in our village.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
