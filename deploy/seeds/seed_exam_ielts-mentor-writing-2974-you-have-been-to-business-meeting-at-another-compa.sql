-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:10.345281
-- Source: ielts-mentor.com
-- Title: You Have Been To Business Meeting At Another Company
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Been To Business Meeting At Another Company';

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
  E'You Have Been To Business Meeting At Another Company',
  E'You should spend about\n20\nminutes on this task.\nYou have been to a business meeting at another company and saw a piece of equipment which can be useful for your company too.\nWrite a letter to your manager. In your letter:\ndescribe the piece of equipment you have seen\nwhy having the same equipment would be useful for your company\noffer your assistance in buying the equipment\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am Duong Nguyen, a junior executive at Curl Business Incorporation, writing to suggest a bookshelf for our office that I have seen in an office in Melbourne, Australia.\\nI had been to the zonal office of Stack IT Ltd last week to attend a meeting. I was quite impressed when I noticed that many employees in that office were reading novels as well as professionally helpful books. The bookshelf was placed in a room where employees often relax and read newspapers. The rack was a large one, at least 7 by 5 feet, and was made of mahogany wood. The bookshelf has a rich collection, accessible to all employees.\\nI feel that we can offer the same facility to our workers and this would be a great way to encourage them to read helpful books. Most of our employees, during their lunch and tea breaks, watch TV or gossip with each other. I believe placing a bookshelf with a rich collection of books would be helpful both for the employees and the authority.\\nI can help you order such a shelf and talk to employees to know their reading preferences.\\nI would really appreciate your kind consideration of having a bookshelf full of books in our office.\\nYours faithfully,\\nDuong Nguyen", "Dear Sir or Madam,\\nI am writing this letter to recommend a piece of equipment for our company which I believe would be highly useful. I saw this equipment at another company when I attended a business meeting there about a week ago.\\nThis useful piece of equipment, I am talking about, is a foldable whiteboard. Of course, we already have a large whiteboard in our meeting and conference room, but the problem with this large whiteboard is that it is really inconvenient to carry it to another room if we want to do some important presentation there.\\nBut, luckily, this whiteboard would solve that problem for us since we can always fold it and carry it anywhere at ease. Besides, this foldable whiteboard can be broken into pieces, like some furniture, which will make it easy for us to place it on almost any kind or size of surface. And, this foldable whiteboard becomes like an average size briefcase, about 24 inches long and 18 inches wide, after folding it.\\nSo, if you think that this foldable whiteboard could be a piece of useful equipment for our office, I would be more than happy to assist you in buying it.\\nYours faithfully,\\nJack Nicholas\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (6 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
