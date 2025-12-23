-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:04.205351
-- Source: ielts-mentor.com
-- Title: You Are Organising Local Committee Meeting
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Organising Local Committee Meeting';

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
  E'You Are Organising Local Committee Meeting',
  E'You should spend about\n20\nminutes on this task.\nYou are organising a local committee meeting. You would like a local MP to attend the meeting to contribute to a discussion about green areas in the community.\nWrite a letter of invitation to the MP''s secretary, Mrs Shelton.\nIn your letter,\nintroduce your committee\nsay why you are having the meeting\ninvite the MP to attend\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear ...................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mrs Shelton,\\nI am an organising member of the non-profit organisation\\n''Our Green Planet''\\n, writing on behalf of our foundation and community members to invite the honourable MP, Mr Alex Cooper, to attend a conference about green areas on 21st December 2021 at Grand Replicon Hall. I am hoping that you would inform the honourable MP regarding the meeting and schedule his time for the same.\\nWe are proud to have a delegate who represents us in the parliament and is an advocate of the green movement. As a founding member of the ''Our Green Planet'', I deem him the best person to have a discussion with the local citizens in this regard. ''Our Green Planet'' has started its journey in 2016 and working to increase awareness about the green movement. Our organization has been highlighted in numerous national and international events and publications.\\n21\\nst\\nDecember will be our 8th anniversary of this wonderful journey and we would like to make it special by focusing on our goal, spreading awareness among people about how individual steps can make our planet a better place to live in. We would be highly motivated if the honourable MP can spare some of his precious time and attend the meeting to discuss his views on that. We are expecting him to stay for an hour.\\nIt would be so kind of you if you could inform our respected MP about the invitation and explain to him how important it is for us to have him.\\nThanks in advance.\\nYours faithfully,\\nLaura Matthew", "Dear Mrs Shelton,\\nI am the general secretary of the “Keep Your City Green\\" committee of our municipality area, and, as the name of this committee implies, its job is to mobilise and motivate the good citizens of our municipality to make them aware of the benefits of green environment in and around our municipality. We also work on tree plantations.\\nAnd as a part of this effort of ours, we try to organise a discussion session quarterly, in which, renowned, respected and learned residents of our community take part and express their valuable opinions about the progress of our involvements and efforts. But, to make the efforts of this committee even more acceptable, engaging and successful among the citizens of our area, we could certainly use the valuable insights from the honourable MP of our constituent.\\nNow, I fully understand that our honourable MP is a very busy person because of his political works and other priorities, but I would surely like to hope that he would squeeze some time out of his busy work schedule to attend our discussion session which will be held from 10.00 am to 12.30 pm on 15\\nth\\nSeptember.\\nYours faithfully,\\nGeorge Tobias\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (5 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nInvitation-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
