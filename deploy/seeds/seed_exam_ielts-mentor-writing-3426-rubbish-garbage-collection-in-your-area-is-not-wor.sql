-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:24.103196
-- Source: ielts-mentor.com
-- Title: Rubbish Garbage Collection In Your Area Is Not Working Properly
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Rubbish Garbage Collection In Your Area Is Not Working Properly';

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
  E'Rubbish Garbage Collection In Your Area Is Not Working Properly',
  E'You should spend about\n20\nminutes on this task.\nThe system used for rubbish/garbage collection in your local area is not working properly. This is causing problems for you and your neighbours.\nWrite a letter to the local council.\nIn your letter:\ndescribe how the rubbish collection system is not working properly\nexplain how this is affecting you and your neighbours\nsuggest what should be done about the problem\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to express a grave situation that the community of \\"Lake West Spring\\" is facing due to the faulty and inadequate rubbish management system, especially for the last three to four weeks.\\nWith relation to the problems, the number of rubbish bins installed in the area is insufficient considering the total population. Moreover, for the last couple of weeks, garbage collector''s lorries have not been picking up the trash in time, and deposit of all waste has started to scatter around the bins or on the streets.\\nSince the garbage bins are overflowing with litter, it attracts some street dogs who rampage the rubish every night. It has also become a breeding ground for mosquitoes, houseflies and other insects which can lead to the spread of infectious diseases. Moreover, the bad odour from garbage has started reaching our house which hampers our peaceful and healthy living.\\nI would like to suggest that the local council look into the matter urgently and make sure the garbage lorries come to our community every other day to empty the bins. Besides, for a long-term solution, more large waste bins should be erected in the region as soon as possible and the garbage should definitely be picked up in a timely manner.\\nI hope you will take immediate measures to solve the problems and consider my suggestions.\\nYours faithfully,\\nElmina Rose", "Dear Sir or Madam,\\nI am writing to bring to your attention the ongoing issues with the rubbish collection system in our neighbourhood, Lodi Road, New Delhi. Over the past few weeks, the service has been inconsistent, with collections either being delayed by several days or, in some cases, missed entirely. I am hoping that you will take the necessary actions to resolve this issue.\\nThis problem is causing significant inconvenience to residents. Overflowing bins have led to an unpleasant odour, and scattered rubbish is attracting pests such as rats and stray animals. Additionally, with the recent warm weather, the situation has worsened, posing a potential health risk to our community. Many neighbours have expressed their frustration, as we rely on a timely and efficient waste disposal system.\\nTo resolve this issue, I kindly request that the council reviews the current collection schedule and ensures that waste is removed regularly and on time. It would also be helpful if a contact point were provided so that residents could report missed collections promptly.\\nI appreciate your prompt attention to this matter and look forward to a resolution soon.\\nYours faithfully,\\nManoj Monmohon", "Dear Sir or Madam,\\nI cannot really believe that I am writing such a letter to you about the messy rubbish collecting situation in my neighbourhood. And I am hoping that your mediation would solve the problem.\\nThe garbage management authority in my area these days is not really picking up the rubbish in due time. Sometimes, the rubbishes are even left for days, especially the liquid and organic waste, which become decomposed and then eventually spread foul smell all over. However, it wouldn’t exactly be so bad if some wild animals were not able to penetrate into the garbage bin to increase the risk of spreading some bad diseases. Besides, we feel really abashed when some of our friends and relatives complain about the foul smell in our neighbourhood while visiting us. So, it is indeed a really embarrassing situation for a country like ours where the waste management system has been generally good over the years.\\nTherefore, I would like to request you to look into the matter and get some serious and trained professionals to get the job done in order to ensure a clean and disease-free neighbourhood for us.\\nYours faithfully,\\nJane Nancy\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.50 (17 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nAnupama Valappil\\n5 years 2 months\\nIt is very useful.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
