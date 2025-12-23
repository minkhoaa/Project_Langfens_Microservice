-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:13.076689
-- Source: ielts-mentor.com
-- Title: Invite A Friend To Your Home For Dinner
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Invite A Friend To Your Home For Dinner';

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
  E'Invite A Friend To Your Home For Dinner',
  E'You should spend about\n20\nminutes on this task.\nYou made a friend when you visited another city a few months ago. This friend has come to your city for some work and will stay for another week. You want to invite this friend to your home for dinner.\nWrite a letter to your friend. In your letter,\nexpress how you feel about him/her visiting your city\ninvite the friend to your home for dinner\ngive location and date when you would want him/her to come\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Cane,\\nI''m so glad to know that you''re currently visiting my city for some work. I also hope that you''re managing to do your work without any trouble. I''m so looking forward to meeting you.\\nI had always wanted to invite you to visit me and my city after meeting you about 6 months ago. But because of my busy work schedule, I couldn’t do so yet. But, now that you are already in my city, I don’t really want to let pass this opportunity to invite you. In fact, I want to invite you to my home in order to enjoy some dinner with me next Saturday which would be the 20th of September.\\nAs for my location, I live only about a 15-minute drive away from your hotel. All you need to do is head towards the west on Highway 9 and drive about 10 minutes to reach Edmond Street. After reaching Edmond Street, drive about 5 minutes on Fuller road towards the north until you reach the midway mall. My home is right behind the mall. But, don’t hesitate to call me if you''ve any trouble finding my location.\\nHope to see you soon then!\\nWarm wishes,\\nPeter\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.22 (9 Votes)\\nIELTS Letter Writing\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
