-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:31.320238
-- Source: ielts-mentor.com
-- Title: People Are Having Problems With Their Internet Connection
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'People Are Having Problems With Their Internet Connection';

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
  E'People Are Having Problems With Their Internet Connection',
  E'You should spend about\n20\nminutes on this task.\nPeople in your area are having problems with their internet connection. Write a letter to the company which provides the connection.\nIn your letter,\ndescribe the problems\nexplain how it is affecting people\nsay what the company should do to help\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to express my discontent with the internet connection that your company provides in our area. The disruptive internet connection is causing a great problem for us, and I am hoping that you would resolve it as soon as possible.\\nYour company is supposed to provide technology that guarantees an uninterrupted internet connection. However, this does not seem to be the case. For the last couple of weeks, we have been experiencing extremely slow connectivity, and sometimes the internet is totally inaccessible. During peak hours, the internet speed is as slow as a few KB per second only!\\nMany people in our area, including my husband, work from home, and a disruptive internet connection means they are unable to work. Due to poor connectivity, they can not send finished assignments to their clients on time. Frequent disconnections also affect people who do video conferencing online. Besides, we are often unable to do online shopping, send important emails and pay utility bills online.\\nI expected that your staff would deal with the situation with utmost importance without any delay, but no meaningful action was taken so far. So, please send your staff to come over and check if you need to install new cables since they might be fairly old. Take any other measure necessary to resolve the slow connectivity.\\nWe are expecting a prompt resolution from you.\\nYours faithfully,\\nRebecca Porter\\nModel\\nAnswer 2:\\nDear Sir or Madam,\\nI am writing to let you know that we have been experiencing a disruptive internet connection in our area for the last two weeks. We are very concerned about the unstable internet connectivity, and the inconvenience is hampering our work and life to a great extent. I hope you will investigate the problem and take the appropriate steps to solve it.\\nWhile the average internet speed is unbelievably slow now, we often experience no connectivity at all. The average download speed in the past was more than 50MB/s which has dropped to less than 2MB/s these days. There is little hope for sharing large files and videos and people who work from home are suffering immensely due to this sluggish connection. People who make video calls are the worst sufferer.\\nI believe it is your responsibility to make sure things like this are addressed promptly. I assume that in order to maintain user trust, your team needs to work very hard to make sure this does not happen again. Please check the cables and routers installed in our area to find and solve the problem.\\nI hope you will take steps to prove that you are worthy of our trust.\\nYours faithfully,\\nDavid Buchanan\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.72 (27 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
