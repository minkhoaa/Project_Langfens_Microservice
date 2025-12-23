-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:23.042383
-- Source: ielts-mentor.com
-- Title: Few Problems Have Emerged In Your Apartment
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Few Problems Have Emerged In Your Apartment';

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
  E'Few Problems Have Emerged In Your Apartment',
  E'You should spend about\n20\nminutes on this task.\nYou have been living in an apartment for the last three years. A few problems have emerged in your apartment since the last repair.\nWrite a letter to your landlord.\nIn your letter,\ngive details of the last repair work\nwhat the problems are now\nhow you would like the landlord to solve these problems\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ......................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Daniel,\\nI am writing this letter to remind you about some emergency repair works that need to be carried out at the flat I am living in.\\nThe last time you did the repair work in the kitchen, one of the bathrooms and two windows was almost two years ago. The repair work was done very professionally, and except for the kitchen, other works still look new.\\nHowever, this time, other problems have emerged, and I have detected a few leaks in the kitchen which need to be fixed immediately. The paint has started to come off, and I am not sure when was the last time the flat was painted. Besides, there is water logging in the drain pipes and it is causing great inconvenience for me.\\nI would greatly appreciate it if you could arrange for these repairs and paint works as soon as possible by hiring a professional service as you did before. Please contact me on my mobile phone to make arrangements for the work to start.\\nThank you in advance for your support.\\nYours sincerely,\\nMaria Garcia\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.50 (16 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nLetter to landlord\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nSita\\n5 years 8 months\\nDear Mrs Susan,\\nI hope you are fine. I am writing this letter to express my dissatisfaction regarding the repair works done by the mechanic whom you hired and sent to my apartment a week ago.\\nLast week, instead of Mr George - who usually does the work, a new mechanic and handyman came and did the repair works at my flat including the heater, laundry machine, and kitchen shelves repair and replacement works. Also, the microwave oven has been repaired by him at my request. The laundry machine is in good condition now, but repairs regarding the heater and shelves are not yet solved.\\nThe heater was in working condition but yesterday all of a sudden it stopped working. We tried again and again but once we switch on the heater, the main power fails. Since winter has started, we have to depend more on the heater. Moreover, the children can not tolerate such severe cold without the functioning room heater.\\nI think Mr George will be good at these types of works as he is more experienced and has good knowledge about our apartment. I would be extremely pleased if you would call him and look into this as an urgent matter.\\nYours Sincerely,\\nElsa Sita\\nReply\\nQuote\\nNimi\\n5 years 8 months\\nDear Mr. Wilson,\\nI hope you are doing excellent. I am writing this letter to you to inform you about the leakage in the ceiling of the apartment where I have been living for the last couple of years.\\nAs you are aware, I have been living in the apartment since November 2020, and the issue of leakage has cropped up in the last couple of months. Although we had got that fixed three weeks ago, the problem has resurfaced. In addition to the leakage, secondary issues such as damage to the ceiling paint and cracks in the walls have developed in the apartment. This has become even graver after the apartment owner above our flat has started doing some renovation work.\\nCan I request you to firstly speak with the owner of the above apartment and explain to him the issues faced by us due to the improper restructure work done by the mason? Also, can you please send some professionals to fix the leakage and paint in the apartment?\\nI will be working from home the entire next week and can assist in supervising the activity done by them.\\nI look forward o hearing from you soon.\\nYours Sincerely,\\nNimisha Acharya\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
