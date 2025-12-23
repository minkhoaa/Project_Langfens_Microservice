-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:43.381645
-- Source: ielts-mentor.com
-- Title: There Is A Problem With Bicycle Parking
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'There Is A Problem With Bicycle Parking';

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
  E'There Is A Problem With Bicycle Parking',
  E'You should spend about\n20\nminutes on this task.\nYou recently started commuting to work by bicycle and discovered that there is a problem with bicycle parking near the building where you work.\nWrite a letter to the building manager. In your letter,\nexplain the reason for using a bicycle to commute\nmention what problems you have encountered with parking\nwhat you recommend to solve the problems\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing this letter to draw your attention to a problem which is related to the bicycle parking in your building where I park my bicycle. I am hoping that you would solve it as soon as possible.\\nI have recently started using a bicycle to commute to work because it saves time by helping me avoid the morning traffic rush. Besides, I like to rely on this “two-wheel” vehicle, instead of using public transportation or private cars, because it helps me remain in good physical shape.\\nBut, it looks like I will have to give up on riding this bicycle because I am seldom getting any empty parking space for my bicycle in the parking lot of our office building. After all, on one hand, the parking lot is not that large, and on the other hand, too many car owners, working in this area, come with their private cars and occupy all the parking spaces. They are even occupying the little space which is designated for motorcycle and bicycle parking.\\nNow, I can not really ask you to expand the parking lot, but I can ask you to request the car owners to at least leave the empty parking spaces which are designated for bicycle parking. Your intervention can solve this problem immediately.\\nYours faithfully,\\nJay Leno\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.81 (8 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
