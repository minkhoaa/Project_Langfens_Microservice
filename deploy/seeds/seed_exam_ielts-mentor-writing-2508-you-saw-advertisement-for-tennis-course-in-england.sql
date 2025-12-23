-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:11.300233
-- Source: ielts-mentor.com
-- Title: You Saw Advertisement For Tennis Course In England
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Saw Advertisement For Tennis Course In England';

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
  E'You Saw Advertisement For Tennis Course In England',
  E'You should spend about\n20\nminutes on this task.\nYou saw an advertisement for a tennis course in England but you have some problems and can’t stay for the whole course.\nWrite a letter to the course director. In your letter,\nexplain your interest in the course\ndescribe your problems\nfind out whether a refund is possible if you leave early\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am Stephen Gore, writing to inquire some details about the tennis course that you conduct. I would specifically like to know your refund policy for people who cannot complete the whole course.\\nI have recently noticed your advertisement in a daily newspaper and as a passionate learner of this sport, I would like to get enrolled in this three-month-long program. As the course is intended for the intermediate players of tennis, it would be a good fit for me.\\nHowever, there are some issues that I would like to resolve before getting enrolled in this course. First, the timing of the course. According to the advert of yours, it is from 4:00 to 6:00 in the evening. However, I cannot join it before 5:30 pm. Is there any option to adjust the timing or date? I guess that would be necessary for learners who have full-time jobs. Besides, I will probably travel to Sydney, Australia during my course schedule and would stay there for almost two months. Considering this, can I get a refund in case I do not complete the whole course? What is the refund policy? Finally, I would request you to email the document checklists to join the course.\\nThank you in advance. A prompt response would be highly appreciated.\\nYours faithfully,\\nStephen Gore", "Dear Sir or Madam,\\nI am writing this letter in response to an advertisement, which was published online a few days ago, where it shows that your tennis academy in Nottinghamshire is offering a short tennis course for beginners.\\nGiven how much interested I really am in becoming a good tennis player, I had naturally become very interested after seeing the word “short”. But, then my excitement died down a little after noticing that the short was not really that short after all. In fact, I would need to spend at least 4 weeks in England to finish the whole course, which could be a bit problematic since I would need to return to my country after three weeks. I have got three weeks vacation from my job which I am planning to use in learning tennis.\\nTherefore, I was just wondering if I would be allowed to join the course with some sort of guarantee that I would get a partial refund for my course should I go back to my country before finishing the entire course or maybe you can make a special arrangement so that I can finish it in three weeks.\\nI will wait for your response.\\nYours faithfully,\\nMartin Freeman\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.88 (12 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nIvan\\n8 years\\nLetter Topic: You saw an advertisement for a tennis course in England but you have some problems and can’t stay the whole course.Write a letter to the course director. In your letter, explain your interest in the course describe your problems find out if a refund is possible if you leave early.An Answer:Dear Sir,I have recently noticed an advertisement in a local newspaper about a tennis course you are holding and decided to write you and find out more about it. I am very fond of tennis and I have been playing it from my childhood. Therefore, I want to be enrolled as a member of your team, and practise at least three times a week.Unfortunately, I arrived in London on a business trip, and I do not know how long I will be here. It could be a week or a month. Thus, I would like to know if it is possible for me to get a refund if my circumstances change and my trip finishes unpredictably. If so what would be the return policy? Also, enlighten me with the details of the facilities offered and regulations of the course and playground.I look forward to your response in the closest future.With the best wishes,Yours Sincerely,Ivan Kuzmenko.\\nReply\\nQuote\\nVahid\\n8 years 10 months\\n...keen on having a job...\\nReply\\nQuote\\nGianna\\n8 years 11 months\\n...look forward to ~ ing is correct.\\nReply\\nQuote\\nMarwa\\n8 years 11 months\\nKeen to have a job? I think keen on the job???\\nReply\\nQuote\\nJojo\\n9 years\\nI look forward to hearing! I think ''I am looking forward to \\"hear\\" from you'' is correct.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
