-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:04.930477
-- Source: ielts-mentor.com
-- Title: You Would Like To Give Presentation
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Would Like To Give Presentation';

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
  E'You Would Like To Give Presentation',
  E'You should spend about\n20\nminutes on this task.\nYou recently attended a conference and you would like to give a presentation in your office about the information you gained by attending the conference.\nWrite a letter to your manager asking for permission to give a presentation. In your letter:\ndescribe what type of presentation you have in mind\nwhat topics it would cover and how long it would take\nwho should participate in the presentation and where should it be conducted\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ................,\nSample Answer 1:\nDear Mr Walee,\nI have recently attended a conference in Dubai and I believe I have accumulated some valuable information in call forwarding technology, roaming and data transfer in the telecom industry. I am wondering if you would permit me to give a presentation to our team in order to present them with some insights into what the recent telecom world looks like.\nMy plan for the presentation session is to cover two important topics which were reported at the conference I attended. I am thinking to get the guys gathered in the meeting room on Monday morning, at 9:00 am. With your permission, I will do it in two separate sessions to present topics - "Modern challenges facing mobile telecom in international call forwarding, roaming and data clusterisation" and "New emerging services". I think the presentation will last for two hours, an hour for each module.\nI have attached the materials which will be narrated in the session. Your approval is kindly requested for the content of the presentation and for the member of the team to attend it. My suggestion is to involve the whole team as it is extremely important related to our work environment and job performance.\nI am looking forward to hearing from you soon regarding this.\nYours sincerely,\nAlwhab Mansur\n[Written by - ABD Alwhab Mansur]',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Walee,\\nI have recently attended a conference in Dubai and I believe I have accumulated some valuable information in call forwarding technology, roaming and data transfer in the telecom industry. I am wondering if you would permit me to give a presentation to our team in order to present them with some insights into what the recent telecom world looks like.\\nMy plan for the presentation session is to cover two important topics which were reported at the conference I attended. I am thinking to get the guys gathered in the meeting room on Monday morning, at 9:00 am. With your permission, I will do it in two separate sessions to present topics - \\"Modern challenges facing mobile telecom in international call forwarding, roaming and data clusterisation\\" and \\"New emerging services\\". I think the presentation will last for two hours, an hour for each module.\\nI have attached the materials which will be narrated in the session. Your approval is kindly requested for the content of the presentation and for the member of the team to attend it. My suggestion is to involve the whole team as it is extremely important related to our work environment and job performance.\\nI am looking forward to hearing from you soon regarding this.\\nYours sincerely,\\nAlwhab Mansur\\n[", "Dear Mr Martin,\\nI am writing this letter to ask for your kind permission in order to make a presentation in our office for the purpose of sharing some important information. It is worth mentioning that I learned about the information by attending a conference a few days ago that talked about \\"strategies to meet project deadlines\\" in a very eloquent and elaborated manner.\\nAnyway, the conference had continued for almost three hours since a good number of experts and experienced professionals attended it and exchanged their views and opinions on this very important issue. But, as far as I am concerned, in my presentation, I would mostly cover the subject of planning effectively to meet the deadlines and how important it is for us to finish our projects in time. In other words, my presentation would mostly deal with the issues we can address to complete our projects in time.\\nBy the way, I would like to conduct this presentation in our meeting room, and anybody can attend this if they feel interested.\\nHope you will permit me to conduct the presentation which deals with an important issue.\\nYours sincerely,\\nRudy Robinson\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.55 (11 Votes)\\nIELTS Letter Writing\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nAsma Akter\\n7 years 11 months\\nIt''s really helpful for us.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
