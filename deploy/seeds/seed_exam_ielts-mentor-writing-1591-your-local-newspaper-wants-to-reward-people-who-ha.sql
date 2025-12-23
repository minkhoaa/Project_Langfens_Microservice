-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:53.929448
-- Source: ielts-mentor.com
-- Title: Your Local Newspaper Wants To Reward People Who Have Contributed
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Local Newspaper Wants To Reward People Who Have Contributed';

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
  E'Your Local Newspaper Wants To Reward People Who Have Contributed',
  E'You should spend about\n20\nminutes on this task.\nYour local newspaper wants to reward people who have contributed a lot to the community.\nWrite a letter to the newspaper. In your letter:\nsuggest someone who deserves the reward\nmention what they have done to help the community\nsay what reward you would like to give this person\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am a resident of Kensington, Melbourne, writing to express my appreciation for your decision to reward people who have selflessly helped others and brought positive changes to the community. I would like to recommend someone for the award who has contributed immensely to make our community a better place.\\nMr Albenny, a retired government officer, also knows as the pioneer of the green movement in our community, deserves the award more than anyone else. He has been working on the Green Movement project for more than 20 years and has since inspired a thousand others to plant trees and save the environment. His dedication is inspiring and three years ago our community received national recognition due to the green movement pioneered by Mr Albenny. He is a highly revered person who is equally loved by his friends and foes.\\nI personally believe that you should consider him for the award you are intending to present to people with their great contributions to the community. What can be more inspiring when someone''s actions motivate hundreds of others to make the world a better place to live in? A simple crest or a trophy as the award would suffice, but you should make the award-giving ceremony open for all.\\nOnce again thank you for your time and initiative.\\nYours faithfully,\\nHelena Gomez", "Dear Sir or Madam,\\nI am the assistant manager of the Kennedy Women Development Organization. I have recently noticed your advertisement dated 12th April 2025 and writing this letter to recommend a person who I believe deserves the reward you intend to present.\\nMy organisation’s director, Mrs Hemamalinee, is the person I would like to suggest for this reward. She has been working for widow women for more than three decades. She is a capable, experienced and talented woman absolutely fitting to receive this award.\\nShe utilises her time for other needy women. Both as a director and individually, she has supported many widows and destitute women. With her dedication, support and willingness, she has become a role model in our community. She never differentiates people based on their race, religion, disability and colour. That is, she treats all equally and she is an exemplary personality for many.\\nI would like to suggest a reward for this excellent lady; a trophy printed with her name and her service to the community. This should be an award for her lifetime achievement. Many women who obtained support through her would be utterly happy if she receives this reward. We would be highly thankful if you could nominate Mrs Hemamalinee on your list.\\nYours faithfully,\\nNiro Renu\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
