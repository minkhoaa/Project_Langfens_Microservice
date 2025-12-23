-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:29.976164
-- Source: ielts-mentor.com
-- Title: A Friend Recently Had Gone To An Excellent Restaurant
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'A Friend Recently Had Gone To An Excellent Restaurant';

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
  E'A Friend Recently Had Gone To An Excellent Restaurant',
  E'You should spend about\n20\nminutes on this task.\nA friend recently told you that he/she had gone to an excellent restaurant. You wonder if this restaurant will be suitable for your birthday party next week.\nWrite a letter to your friend. In your letter,\ntell your friend about your planned party\nask for details of the restaurant\nask what kind of food it serves and if your friend has any particular recommendations\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .......................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Ben,\\nI hope you’re doing great! The other day you were talking about an excellent restaurant you visited, and I was wondering if it might be a good place for my birthday party next week.\\nI’m planning a small gathering with close friends, and I want to celebrate in a place with great food and a nice atmosphere.  Could you please let me know the name of the restaurant and how to get there? Since we’re in London, I’d love to know if it’s easily accessible by public transport. I''d also be interested in knowing if car parking is available nearby as some of my friends would love to drive their cars. Also please give me their Facebook or Google Business Page addresses so that I can contact them.\\nPlease do come to the party. I’d also love to hear more about the type of cuisine they serve. Do they have any standout dishes you’d recommend? If you have any personal favourites from the menu, I’d love to know so I can check them out in advance.\\nLooking forward to your reply!\\nWarm wishes,\\nNathan\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (5 Votes)\\nGT Writing Task 1\\nInformal Letter\\nRequesting-information-letter\\nletter to a friend\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
