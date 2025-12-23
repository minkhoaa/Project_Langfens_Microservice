-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:18.677307
-- Source: ielts-mentor.com
-- Title: Letter To Friend Expressing Interest To Seek Employment
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Friend Expressing Interest To Seek Employment';

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
  E'Letter To Friend Expressing Interest To Seek Employment',
  E'You should spend about\n20\nminutes on this task.\nWrite a letter to a friend who works in a foreign country expressing your interest to seek employment in a different country.\nIn your letter, include:\nwhy you want to work in a different country\nwhat type of work you will be looking for\nquestions you have about working in a different country that your friend may be able to answer\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear ..................\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sindhu,\\nHope this letter finds you and your family in good health. I am sorry for not writing to you for a long but I guess you can realise my hectic schedule for the past couple of weeks since I wrote about it in my previous letter. I have decided to work in Australia and expecting your opinion regarding this.\\nNow, a sigh of relief! My project works are complete and I am looking for a new opportunity to work abroad. You know me well - I have always wanted to make life enjoyable by making positive changes and I have recently decided to work and live in a multi-cultural environment. I think it would be fascinating to socialise with people of different origins while I can further enhance my career and live in a better environment.\\nThus I am looking forward to getting a job in Biomedical Engineering, as I always did, in Australia as a permanent employee either in a manufacturing or a service-related company. So, I need some information from you since you have already been to different countries and now in Australia in the same industry. Is it mandatory for me to get a work permit or can I migrate with a temporary work visa and later find a job? Should I take any exams like IELTS or TOEFL? If so what would be the score requirement? And finally, can I apply for some jobs before moving to Australia?\\nLooking forward to hearing your response in this regard. We will find some time soon. Convey my regards to your family.\\nWarm wishes,\\nNivetha\\n[", "Dear Rahul,\\nHope all is fine and you are enjoying your vacation. I am writing to seek your advice on working in Singapore and need your help and guidance regarding this. I am hoping that you can share your opinion with me.\\nThe foremost reason for choosing Singapore to work in is that the country invites skilled employees from all around the world. The experience and expertise I have achieved over the past five years can be judiciously and prudently utilised to get a permanent job in a company in Singapore. Moreover, the remuneration and facilities in the IT sector in Singapore is unmatched, according to my findings.\\nThis, however, does not mean that I will be opt-in for a job easily and I understand that migrating to a new country has its demerits. I plan to apply for opportunities that would be limited to the subjects over which I possess core competency, which includes \\"Programming\\" and \\"Artificial Intelligence\\".\\nIt is in this respect that I need your guidance. I would be thankful if you can guide me on the work culture that is followed and is acceptable in Singapore. Apart from this, I also want to know the attitude of the locals towards the foreign nationals who work in such companies as their counterparts.\\nSince you have spent a considerable amount of time working there, it would be quite convenient for you to compare the basic requirements, expectations and behavioural changes that one undergoes during the transitional phase.\\nI would be thankful if you could help me by sharing your valuable experience in this regard.\\nWarm wishes,\\nNeeraj\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
