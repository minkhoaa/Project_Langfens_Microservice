-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:14.402038
-- Source: ielts-mentor.com
-- Title: You Are Due To Move Into Rented Apartment
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Due To Move Into Rented Apartment';

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
  E'You Are Due To Move Into Rented Apartment',
  E'You should spend about\n20\nminutes on this task.\nYou are due to move into a rented apartment next month but you will not be able to because you have some problems.\nWrite a letter to the landlord. In your letter:\nexplain your situation\ndescribe your problems\ntell him/her when you think you can move in\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear ..................,\nModel\nAnswer 1:\nDear Mrs Anna,\nI have recently agreed to rent your apartment, and I am supposed to move there on August 1st. I am afraid I cannot do so in August due to some personal problems. I am hoping that you would allow me to move into your apartment at the beginning of September instead.\nI am Koharu Rio, signed a rental agreement with you on July 15th and I am due to move into your apartment C4 located in Cranberry Street on the 1st of August. I have already paid you two months rent upfront. However, the sudden news of my mother-in-law''s sickness propels us to change our plan. I along with my husband and children will travel to Japan sometime next week. I am not sure how long we will be staying there but it would not be less than a week I guess.\nAfter we get back from Japan, my husband and I both will be terribly busy to cover our work at our offices and hence shifting our house would be impossible for us. I would request you to consider my circumstances and allow me to move into your apartment at the beginning of September.\nI look forward to hearing from you soon regarding this.\nYours sincerely,\nKoharu Rio',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Alfred,\\nI am writing to inform you that I would not be able to move into your apartment, C-4, at the beginning of November as promised. Due to a professional reason, I am staying in Australia and will not be back before 28th November 2019. I am hoping that you would allow me to move into your apartment at the beginning of December instead.\\nI was expecting to finish my work at the end of this weekend. However, I would not act according to my plan as one of my clients had an accident and was admitted to a hospital. Doctors advised him complete bed rest for two weeks and strictly warned him not to take part in any business activity.\\nI would only meet him after two weeks from now, I wanted to skip the meeting but was unable to do so due to numerous business works we take from this party. Therefore, I have changed my plan and will come back two weeks later than originally decided, which is 29th November. Considering the situation, I would request you to allow me to move into your apartment in the first week of December.\\nYours faithfully,\\nFahad Sultan\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
