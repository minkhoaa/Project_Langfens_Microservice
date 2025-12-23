-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:33.372670
-- Source: ielts-mentor.com
-- Title: Your Friend Has Asked For Your Help With A College Project
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Friend Has Asked For Your Help With A College Project';

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
  E'Your Friend Has Asked For Your Help With A College Project',
  E'You should spend about\n20\nminutes on this task.\nYour English-speaking friend has asked for your help with a college project he/she is doing about celebrating New Year in different countries.\nWrite a letter to your friend. In your letter,\nsay how important New Year is to people in your country\ndescribe how New Year is celebrated in your country\nexplain what you like about New Year celebrations in your country\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear James,\\nI hope you''re doing excellent. I’m delighted to help with your college project on the topic ''New Year celebrations'', and I''m so happy that you wrote to me about that.\\nIn my country, the New Year is one of the most significant events of the year, marking a fresh start filled with hope and aspirations. Many people see it as an opportunity to set personal and professional goals, making it a time of great enthusiasm and positivity.\\nNew Year’s Eve is typically celebrated with grand fireworks displays, lively street parties, and family gatherings. In major cities, such as London, thousands of people gather along the River Thames to witness the iconic fireworks at midnight. Many also host private parties, where friends and family toast the arrival of the new year with champagne. Additionally, it is customary to sing Auld Lang Syne, a traditional song symbolising friendship and nostalgia.\\nWhat I love most about New Year’s celebrations here is the incredible sense of unity and joy. Regardless of background, people come together to embrace new beginnings, which creates an atmosphere of hope and excitement. This is one of my favourite times of the year.\\nI hope this helps! Let me know if you need more details.\\nWarm wishes,\\nHenry", "Dear Leslie,\\nI''m so delighted to receive your letter in which you''ve informed me about a college project on \\"the New Year celebration\\" in a different country than yours. I''ll share some information that I believe will help you complete the project.\\nTo give you some details of the importance of the New Year to the people in my country, I''d like to mention that this is perhaps the most celebrated event in my country where people from all walks of life come together with renewed hope, motivation and joy. They look forward to the upcoming year with new fervour, and most of them have some kind of New Year resolution that they take seriously.\\nOn New Year''s Eve, people exchange greetings and messages and wear the best dresses. They greet each other and share fond memories with dear ones. They also have lively street parties and fireworks that lighten the sky like bright daylight. Bright sky lanterns, mostly red, are a common sight.\\nPersonally, I like the way people greet each other on that day which brings them together. I also love the fact that they meet their loved ones, and all of them harness new inspirations to do better in the coming year which is really inspiring for me.\\nI hope this will help you complete your project. In case you need more information, I am always here to help.\\nBest wishes,\\nGrace\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (5 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nletter to a friend\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
