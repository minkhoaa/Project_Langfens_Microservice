-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:10.089364
-- Source: ielts-mentor.com
-- Title: You All Want To Do Some More Language Training
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You All Want To Do Some More Language Training';

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
  E'You All Want To Do Some More Language Training',
  E'You should spend about\n20\nminutes on this task.\nYou and your colleagues have recently attended a foreign language training course organized by your company. Now you all want to do some more language training.\nWrite a letter to your manager. In your letter,\nsay how you and your colleagues felt about the course\nexplain why you all want to do more language training\nsuggest when and where the training could take place\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nFirst, I would like to thank you for arranging a French language training course last month which I and a couple of my colleagues have recently finished. Needless to say, we all feel very ecstatic and empowered to have had this awesome opportunity to learn this important language. We believe it will make us way more confident about our communication skills and abilities, both personally and professionally.\\nTo tell you something about this course - it was designed very thoughtfully, especially, for beginners like us. The course instructions were very clear and simple, and it became very interesting from time to time as the course also aimed to teach us the French culture in some entertaining manners.\\nAnyway, while this short language course was good enough for us to learn the basics of the French language, some more training is needed to communicate more professionally with French-speaking people and companies more effectively. We can get this training in our second meeting room which is left unused pretty much all the time. We would like to have another professional French language trainer along with the previous trainer for this. We are ready to start this training anytime in September.\\nYours sincerely,\\nElmina Flora\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.86 (7 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
