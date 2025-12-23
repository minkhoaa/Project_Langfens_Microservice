-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:05.480434
-- Source: ielts-mentor.com
-- Title: Friend You Met Last Year Has Invited You To Visit
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Friend You Met Last Year Has Invited You To Visit';

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
  E'Friend You Met Last Year Has Invited You To Visit',
  E'You should spend about\n20\nminutes on this task.\nA friend you met last year has invited you to visit him/her in his/her country. You have never been there before and need some information before you leave.\nWrite a letter to your friend. In your letter:\nrequest some advice about a gift for his/her family\nask about activities and clothing in his/her country\nfind out about the food\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ...................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Jacob,\\nIt was indeed a great pleasure to receive your letter and to learn that you have a new job. I still cherish our friendship and can never forget the splendid time we had together in a vibrant city like Milan. I''m so thrilled to be invited to visit you in Seattle in the United States which I''m looking forward to very much.\\nAs I''ve never been to the United States and have little idea about the weather and culture there, I would really appreciate your suggestions and tips. I would like to bring some gifts for you and your family and wondering what might be appropriate! Could you please help me with this?\\nI''ve applied for the visa and I am expecting to travel to the USA sometime during the next month. What is the weather like at this time of the year and what type of dresses would be suitable? I am not sure about the activities you have in mind for me and some suggestions would be great. As you know I am a vegan and I hope this would not be a problem while I am there. Also, I would not mind experimenting with some local food and would be ready to enjoy some fun activities.\\nCan''t wait to meet you. Stay fine and take care.\\nWarm wishes,\\nNick", "Dear Leena,\\nHope you are doing excellent. Once again, it was indeed so amazing that I met such a wonderful person like you last year. I also want to thank you for extending me an invitation to visit your country.\\nI have already made all sorts of arrangements to visit you this November, but before I head off to your country, I would like to have some information from your part, if possible. To be more particular, I could surely use some advice on what kinds of gifts are traditionally preferred or liked in your country so that I can buy the perfect gifts for you and your family.\\nI would also like to know what sorts of clothes I should carry with me since I am not sure about what the temperatures are going to be like in your place at that time of the year. Finally, information regarding what kinds of activities and food would be suitable for me, or I would enjoy there, after arriving in your country, would also be highly appreciated.\\nPlease do get back to me as soon as you can.\\nWarm wishes,\\nRosaline\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.68 (11 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nAnkit\\n6 years 3 months\\nIELTS Writing task 1.\\nReply\\nQuote\\nAbd Alwhab Mansur\\n7 years 11 months\\nDear Shanj,I hope you''re doing well. And wish you all the best in your career and life. I still remember the nice moments we spent together last summer in South Africa. I am so honoured to receive your invitation to visit your fabulous country ''Japan''. I expect to visit you and I need some information regarding this.First of all, as I will meet your parents, I want to bring few gifts for them. We are used to following this trend in my country and I am wondering what kind of gifts you think would be appropriate? Second, as you know, my country has a hot climate and I have no idea about the weather in Japan at this period of the year. I need your advice on the kind of clothes I should bring. I also need to be prepared for any activity we may do while staying in your town.I need your advice about the availability of Arabic restaurants in Japan. I need to get along with your local food also. Hope to hear from you, and to see you soon.Yours, Abdalwhab.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
