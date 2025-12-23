-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:03.962022
-- Source: ielts-mentor.com
-- Title: Facilities For Shoppers Could Be Improved
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Facilities For Shoppers Could Be Improved';

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
  E'Facilities For Shoppers Could Be Improved',
  E'You should spend about\n20\nminutes on this task.\nYou normally go shopping in the area where you live. However, you think some of the facilities for shoppers could be improved.\nWrite a letter to your local newspaper. In your letter:\nsay in general what you like about shopping in your area\nsay what is wrong with the facilities\nsuggest how they can be improved\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing this letter to express my opinion about the local shopping area where I frequently go shopping. They offer some really nice amenities but there are still scopes for improvements. I am hoping you would publish it in your newspaper so that the market authority learn about it and take initiatives to develop the area.\\nTo start with, the Agora Community Shopping Complex is the largest shopping market in our town where several thousand people shop every day. The strictly monitored market price and the availability of the products under a single roof are two attractive aspects of this market. Moreover, I like the way the shops are arranged on each floor. Overall, I am happy with this market and visit it almost twice to thrice each month.\\nRegrettably, most of the shoppers still do not accept international credit cards. I have seen many tourists suffer due to this. Since this is a tourists area and many foreigners visit this market, international credit cards should be accepted by all merchants. Besides, the food court area is really compact and cannot serve many customers at a time. One has to stand in a cue for a long even for a cup of tea! This area should be extended and more food businesses should be encouraged to open new shops for the convenience of shoppers.\\nI think your newspaper is widely read in our area and if you run a poll regarding the issues I mentioned, you will find a realistic picture of it. Please publish an editorial and help improve the local people''s shopping experience.\\nThank you in advance for giving the matter your attention.\\nYours faithfully,\\nMark Almond", "Dear Sir or Madam,\\nI am a regular reader of your newspaper, and I am writing this letter to express my opinion about the local shops in our area where I like to do my shopping. I hope that you would be kind enough to publish these comments of mine so that the proper authority can look into the matters and take appropriate actions.\\nGenerally speaking, the shops and the shopping facilities in our area are not really that bad since they all try to offer a great shopping experience to their customers. In fact, there is no shortage of amenities such as great lighting systems, facilities for clean drinking water and a great air conditioning system. However, when it comes to proper hygiene, enough parking spaces and security (especially, when shopping at night), I am afraid that most of our shopping facilities are not up to the standards.\\nNow, I understand that these problems will not get fixed overnight, but if our local government allocates some extra budgets in taking care of these issues while pushing the shop owners to be more proactive, I think that most of these issues would be resolved.\\nThank you for your attention.\\nYours faithfully,\\nRebecca Hall\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.04 (12 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
