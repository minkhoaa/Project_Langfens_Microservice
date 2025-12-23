-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:00.433543
-- Source: ielts-mentor.com
-- Title: Change The Dates Of The Visit To Your Friend In Australia
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Change The Dates Of The Visit To Your Friend In Australia';

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
  E'Change The Dates Of The Visit To Your Friend In Australia',
  E'You should spend about\n20\nminutes on this task.\nYou arranged to visit a friend in Australia, but an important event at home now means that you must change the dates of the visit.\nWrite a letter to your friend.\nIn your letter,\nexplain the important event\napologise for the situation\nsuggest a new arrangement\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Alistar,\\nHope all is well with you.  First of all, I''d like to apologize to you since I won’t be able to visit you in Australia next week because of some important event.  I know that this news probably would frustrate you just as much as it did me, but if I explain the situation to you in brief, you''ll probably understand why I''ll need to change the plan.\\nThe reason, for which, I''m changing the schedule of this visit is that I''ll have to attend the high school graduation ceremony of my only cousin (paternal), with whom I''m very close.  He''d informed me about his upcoming graduation ceremony, which will also take place next week, well in advance.  But it just slipped my mind somehow.  Now, seeing me skipping one of the most important events of my cousin’s life like this would certainly make him feel sad which I just wouldn’t like to see.\\nNow that I just explained the situation to you, you probably wouldn’t mind if I plan to visit you early next month and start making arrangements for this.\\nWarm wishes,\\nAlex\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.86 (7 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nIELTS Apology Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
