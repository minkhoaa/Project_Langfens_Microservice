-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:42.330563
-- Source: ielts-mentor.com
-- Title: City Council Is Planning To Pull Down A Historic Building
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'City Council Is Planning To Pull Down A Historic Building';

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
  E'City Council Is Planning To Pull Down A Historic Building',
  E'You should spend about\n20\nminutes on this task.\nYour city council is planning to pull down one of the historic buildings in your town because they do not have funds to renovate it. As a citizen, you do not want it to happen.\nWrite a letter to the city council. In your letter,\nsay what the importance of this historic building is\nmention why it should be renovated rather than pull down\nsuggest a plan to raise funds and maintain the building in the future\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing this letter to draw your attention to an issue which is rather important for preserving the historical importance of this old city.\\nI am referring to a decision of our city council to pull down a historic building on Forest Creek Street, right across the town. As far as I know, the building has been standing there for over two centuries. Some legends about this historic building say that it was erected by a renowned military leader of our country who led a revolt against the oppressive feudal leaders back in the days. Some also say that the marble, used in this building, was actually sourced from Medieval Europe. But, whatever the case, this historic building should be renovated, simply because it has some astonishing design and structure, connecting us to our glorious past.\\nI understand that availability of funds is an issue here, but if we can convince the local businessmen here, profiting from the visitors who are coming to see this historic building, to contribute some funds to maintain the building, I am sure that we will not have to pull down the building.\\nI hope you will take initiates to preserve this important historic building in our town.\\nYours faithfully,\\nNathan Astle\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.42 (13 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
