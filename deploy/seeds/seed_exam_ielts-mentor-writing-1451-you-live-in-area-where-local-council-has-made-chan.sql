-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:07.240547
-- Source: ielts-mentor.com
-- Title: You Live In Area Where Local Council Has Made Changes
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Live In Area Where Local Council Has Made Changes';

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
  E'You Live In Area Where Local Council Has Made Changes',
  E'You should spend about\n20\nminutes on this task.\nYou live in an area where the local council has made some changes to regulations. You believe these changes are not good for the residents.\nWrite a letter to a councillor. In your letter:\nintroduce yourself\ndescribe the problem\nsay what you think the council should do about the situation\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear Sir or Madam,\nSample\nAnswer 1:\nDear Sir or Madam,\nI am Patrick Moon, a resident of Cabourne, Lincolnshire and a medical doctor by profession. I am writing to express my opposing views on the recent changes that the council have applied recently. I hope you would reconsider the imposed changes as they are against the people''s interests.\nThe decision to restrict public entry to Central Lincolnshire Park is not acceptable to most of the residents. Many residents, with whom I have talked in the past weeks, feel very negatively regarding the council''s decision. Moreover, the council has decided to impose a weekly subscription fee for the public library access which I believe is not a good move considering a large number of student members.\nThe ''Central Lincolnshire Park'' is a place where local residents can freely walk, meet others, enjoy the scenic beauty of mother nature and play with children. It should be open to all. Moreover, the library access should be free to students while you can expect some membership fees from other readers. Please reconsider the changes that have been recently made as they are in no way helping people which is one of the important responsibilities of the council.\nI would really appreciate it if you analyse the changes and put people''s interests above all.\nYours faithfully,\nPatrick Moon',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am Alicia Vikander, a resident of the Asperö, Gothenburg area and a university lecturer, writing to express my disapproval of the recent holding tax increase. The sudden increment is not cordially accepted by the people and as a representative of these people, you are requested to reconsider it.\\nIncreasing the holding tax to 25% from the next June would create some rage among ordinary citizens. People in our area are already paying an 18% holding tax, which is 2-3% higher than the national average, and making it 25% would only bring dissatisfaction to the local citizens. As a law-abiding resident, I have always honoured the regulation but I, as well as many others, also feel strongly about the decision.\\nAs a solution, I would like you to invite some members of the community to discuss the changes - a way to show that you are always respectful of people''s decisions and make the holding tax less than 20%.\\nI sincerely thank you for your consideration and judgement.\\nYours faithfully,\\nAlicia Vikander\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.29 (12 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
