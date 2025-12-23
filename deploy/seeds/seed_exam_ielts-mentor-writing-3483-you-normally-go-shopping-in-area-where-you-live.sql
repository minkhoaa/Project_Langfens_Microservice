-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:16.918919
-- Source: ielts-mentor.com
-- Title: You Normally Go Shopping In Area Where You Live
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Normally Go Shopping In Area Where You Live';

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
  E'You Normally Go Shopping In Area Where You Live',
  E'You should spend about\n20\nminutes on this task.\nYou normally go shopping in the area where you live. However, you think some of the facilities for shoppers could be improved there.\nWrite a letter to your local newspaper. In your letter:\nsay in general what you like about shopping in your area\nsay what is wrong with the facilities\nsuggest how they can be improved\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nYour newspaper has a reputation for discussing different issues, related to the development works and improvements in our town. And I sure hope that you would take notice of this particular issue as well and publish it in your newspaper in order to attract the attention of the authority.\\nThe issue is related to the improvement of shopping facilities in the Ferguson area where I like to visit and do shopping. Of course, I do not really have much to complain about the shops in my area since most of them are generally offer affordable prices and carry quality products. I also like the fact that most of these shops are easily accessible from all directions.\\nHowever, when it comes to keeping the parking spaces in front of the shops clean and tidy, as well as offering some extra sitting arrangement or resting places for the tired and elderly shoppers, the shops in my area certainly could use some improvements.\\nTherefore, I suggest that the shops employ enough staff to keep the parking spaces clean while providing some comfortable sitting arrangements also for the elderly shoppers to rest. I hope you will publish an editorial in your newspaper regarding this.\\nThank you in advance.\\nYours faithfully,\\nLydia Olivia\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.94 (8 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nNosheen\\n4 years 8 months\\nYou normally go shopping in the area where you live. However, you think some of the facilities for shoppers could be improved there.\\nWrite a letter to your local newspaper.\\nDear Sir or Madam,\\nI am Nosheen Imran, a teacher by profession, have been living in the south park area for a little over one year. As everything about this locality is marvellous including its picturesque views, amazing people and dazzling shopping district, I believe some measures should be taken to improve a shoppers experience.\\nTo commence with, the shopping market is easily accessible and has a lot of high-quality products and amenities at affordable prices. Needless to say, the shop owners and salespersons are also very cordial and professional. However, the parking space is inadequate and away from the shops which make it difficult for people to find a suitable parking spot and elderly people cannot walk all the way to the market entrance. Moreover, the entrance gate is always crowded with long lines of people trying to pass the security check.\\nTherefore, I would suggest you publish an editorial regarding this so that the concerned authority takes proactive measures to ensure enough parking to cater to all customers. Moreover, a separate gate should be introduced for the elderly and women with kids to enter the market.\\nI hope you will consider my suggestion and take steps to help enhance our shopping experience to improve our community experience.\\nThank you in advance.\\nYours faithfully,\\nNosheen Imran\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
