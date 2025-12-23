-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:39.903455
-- Source: ielts-mentor.com
-- Title: You Have Arranged Party For A High School Friend
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Arranged Party For A High School Friend';

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
  E'You Have Arranged Party For A High School Friend',
  E'You should spend about\n20\nminutes on this task.\nYour high school friend who has moved to another country will be visiting your country for a month. You have arranged a party for him/her.\nWrite a letter to this friend. In your letter,\ngive the date and location of the party\nsay who are coming to the party\nand mention things that he/she has missed during his/her stay in another country\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Kyle,\\nI''m so glad to hear that you''re coming to visit us after such a long time. Of course, I know that you like your new, “adopted” country, but I think that you would still be interested to know what you''ve missed after leaving our country.\\nWell, our only football stadium in the city has been made bigger to accommodate more spectators. Besides, Eric, who we all used to make fun of as a “political geek”, has started his new political career as a city council member.\\nNow comes the most fun and exciting part of this letter. In fact, we are planning to throw a “welcome” party to make your visit a special and memorable one. It''s not only going to be attended by most of our high school and college friends but also by some of our favourite high school teachers who had helped us become better students.\\nBy the way, the party will be held on the 4th of July, and the venue is “Memorial Hotel” on Traverse Street, right across the town. So, hope to see you there!\\nBest wishes,\\nJustine", "Dear Leena,\\nI''m so excited to learn from your letter that you''ll visit your home country after at least eight years! Time indeed flies! We''ve planned to make your trip memorable by arranging a \\"welcome\\" party for you, and we are looking forward to your arrival and enjoying our time together.\\nAs for the date and location of the party, we''ve decided to throw the party on 4th August, three days after your arrival, in the large backyard of Mike''s house. We''ll start gathering at Mike''s place just after the evening and the party is expected to continue till midnight.\\nAt least twenty of our high school friends and a few buddies from our neighbourhood are expected to join the party. We''ve also invited a few of your relatives including your parents and siblings. It is going to be a blast!\\nDuring the eight years of your stay in Canada, many things have happened. Our high school won the district football championship for the first time last year and we have got a new councillor in our city. Moreover, Natasha, Selina and Tania have moved to the UK, and Natasha is expecting a baby soon. Perhaps most interestingly, Sam, who had always been against doing a job has become a junior partner in a local law firm.\\nWe''re very much looking forward to your visit.\\nHave a safe journey.\\nWarm wishes,\\nRebecca\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.00 (10 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nletter to a friend\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
