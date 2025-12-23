-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:33.880900
-- Source: ielts-mentor.com
-- Title: Problems With The Public Transport You Use
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Problems With The Public Transport You Use';

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
  E'Problems With The Public Transport You Use',
  E'You should spend about\n20\nminutes on this task.\nThere have been some problems with the public transport you use to commute daily.\nWrite a letter to the manager of the public transport company.\nIn your letter:\ndescribe the problems\nexplain how these problems are affecting you and others\nsuggest what could be done about it\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am a regular user of your transportation service and take your buses to travel to and from my office on weekdays. I am writing to bring to your attention a few critical issues inflicted upon me and other commuters who use your service. I am hoping you would address these issues promptly.\\nFirst, during the last couple of weeks, your buses are making recurring delays and this is affecting our arrival at our workplaces on time. To add more grief, a few buses do not arrive at all. A number of times, I had to wait for more than an hour and then hail a taxi to reach my office. Finally, some buses are full when they arrive, and as a result, cannot take any more passengers from the Victoria Bus Stand. This situation forces me and many other travellers to either take the congested bus and stand all the way in a miserable condition or wait for the next bus. I believe if this keeps happening, it would reduce people''s trust in your service.\\nI suggest that you add a few more transport to accommodate the passengers and manage the timetable rigidly.\\nThank you for giving the matter your attention, and I hope to hear your reply soon.\\nYours faithfully,\\nJohn Andrews", "Dear Sir or Madam,\\nI understand that this is not the type of letter you would like to see from the commuters who use the transportations of your company, but I am left with no other choice but to write it. We, the local residents, of little lake Tahoma town are dealing with some frustrating problems with our public transportation system who use your transportation almost daily.\\nYour company has only a few public buses in Lake Tahoma town even though it has a rather sizeable population, and those few buses are just not enough to transport users to their desired locations on time. To make things even further complicated, a couple of bus drivers have become a bit too old for their jobs, and as such, they fail to appear for their duties every once in a while, leaving many residents completely clueless about how or when they would reach their destinations. This is not an ideal situation, especially, for the people who have to go to their jobs daily.\\nTherefore, I would like to request you to get some more public buses on our roads immediately, and enough skilled and competent drivers to ensure a smooth commuting system in our town.\\nYours faithfully,\\nHenry Jones\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.13 (28 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nSajidpasha\\n1 year\\nThere is no bus from Lingasugur to Raichur after 4 pm. This is a daily problem.\\nReply\\nQuote\\nSaniya\\n1 year 4 months\\nSir, my request is that I and my friend study in ETE Nizamuddin and go by bus no DL IPD 5089. The bus custodian does not give the pass and says get it online. And today at 4:20 pm he stopped the bus in the middle of the road and made everyone get off saying that the bus was not working. His way of talking was also rude. Please get it done on him.\\nReply\\nQuote\\nJamara\\n1 year 5 months\\nThe worst transport is the bus 37 to Richmond every day I finish my work at 4:30 it takes more than one to get to the and the worst thing is that it is always full and never stops near my work when are they going to do something to improve this ???? Please\\nReply\\nQuote\\nSuma\\n1 year 9 months\\nI was travelling from Dabaspete to Bangalore on bus number 4541 on 16.3.2024 at 2 o''clock. The bus conductor''s behaviour was very rash and unprofessional. I showed him the soft copy of the bus ticket on my mobile phone but he asked for a hard copy. I would like to complaint about his behaviour and expect that things will be sorted out soon.\\nReply\\nQuote\\nSobia\\n6 years 4 months\\nI want to see some materials for my IELTS test preparation.\\nReply\\nQuote\\nSobia\\n4 years 4 months\\nSamer here, please upload some good content for band 7+.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
