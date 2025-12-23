-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:30.426259
-- Source: ielts-mentor.com
-- Title: You Have Been Doing Voluntary Work To Help Local Community
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Been Doing Voluntary Work To Help Local Community';

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
  E'You Have Been Doing Voluntary Work To Help Local Community',
  E'You should spend about\n20\nminutes on this task.\nYou have been doing some voluntary work to help your local community. However, now you are unable to continue doing this work.\nWrite a letter to the manager of the organisation where you have been working. In your letter:\ndescribe the work you have been doing\nexplain why you can no longer do this work\nrecommend another person who is interested in the work\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .................\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Patrick,\\nI am a cadet in your community-based rehabilitation team and I have been with this group since 2017. I regret to inform you that I will not be able to continue with your organisation effective from 1st December 2025 as I am leaving for my home country once and for all.\\nIt has been a wonderful journey for me so far. I was predominantly working with the rehabilitation team, assisting the medical panel of experts as a volunteer doctor. My duties mainly comprised of the initial assessment of patients, who are from the indigent part of our local community. The assessment mainly included monitoring their physical, social and emotional wellness.\\nAs you may remember, I was pursuing my postgraduation at Boston University. Now that my study permit has expired, I am preparing to leave for my home country in a couple of weeks. Henceforth, can no longer work for the team I had been a part of.\\nHowever, it would be my pleasure, to introduce one of my juniors in college, who is willing to take over my position in the team. Now, the whole charade of recruitment of a new employee, the prerequisites and all, as intended, I leave it upon you. His name is Jackson Dave and he will be in contact with you soon.\\nOnce again, I would take this opportunity to thank everyone who stood beside me during my tenure with the group. I wish every success of the organisation.\\nSincerely yours,\\nJane Smith", "Dear Mr Reeve,\\nHope you are well. I am writing this letter to inform you that sadly, I won’t be able to continue my voluntary work for your organisation as I will move to another city at the beginning of September.\\nJust so you know, I have been involved with your organisation for almost 2 years, and I must say that I have enjoyed it so much. Helping homeless people, collecting non-perishable food items from people in order to donate to your food bank, and cleaning our neighbourhood from time to time were some excellent work that I did. Besides, I have learned about how to build a team and motivate its members in a good humanitarian cause as well as how to coordinate their activities.\\nIn fact, after working here for almost 2 years, I started to consider each and every staff of this organisation as my family. But, as much as I would like to continue, the truth is I won’t be able to do so because I will have to move to another city with my family for some professional reasons.\\nHowever, before I leave, I would like to recommend Mr Marcus, one of my colleagues at my current office, who has expressed his interest to carry on with the task that I was doing. I hope you can meet him next Friday to talk to him in detail.\\nThank you once again and I will miss you all.\\nYours sincerely,\\nJohn Trent\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.77 (11 Votes)\\nIELTS Letter Writing\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
