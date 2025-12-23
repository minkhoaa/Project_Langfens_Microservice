-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:50.295108
-- Source: ielts-mentor.com
-- Title: You Have Taken Cruise On Holiday And Have Been Disappointed
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Taken Cruise On Holiday And Have Been Disappointed';

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
  E'You Have Taken Cruise On Holiday And Have Been Disappointed',
  E'You should spend about\n20\nminutes on this task.\nYou have taken a cruise on a holiday and have been disappointed with the experience.\nWrite a letter to the cruise provider. In your letter, say:\n-  what went wrong\n-  how you felt about it\n-  what do you want to be done about it\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,\nSample Answer 1:\nDear Sir or Madam,\nI have recently taken a cruise provided by your company on a holiday in Belarus. But the experience was below standard. I am writing to bring your attention to this unsatisfactory experience that I had with the Rose Cruises on March 17, 2025.\nRegrettably, the boat was battered and small - contrary to what was advertised. It departed at least 40 minutes later than the scheduled time. Moreover, it was cold inside but when all the passengers boarded, the windows became drizzled due to poor ventilation, which made it impossible to enjoy the views.\nFurthermore, even though we were promised a private table, we could not find one and no one came forward to explain it! The place was so crowded that we had a hard time moving from one place to another. Enough service persons were not present and we had to wait around 30 minutes to get our breakfast which was served cold. This was a stressful experience for both me and my wife.\nI do not feel that is unreasonable to expect a full refund of the money paid to you following the misrepresentation of what Rose Cruises were offering. We expect, therefore, a refund of the full €300.\nYours faithfully,\nTom Behan',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI have recently taken a cruise provided by your company on a holiday in Belarus. But the experience was below standard. I am writing to bring your attention to this unsatisfactory experience that I had with the Rose Cruises on March 17, 2025.\\nRegrettably, the boat was battered and small - contrary to what was advertised. It departed at least 40 minutes later than the scheduled time. Moreover, it was cold inside but when all the passengers boarded, the windows became drizzled due to poor ventilation, which made it impossible to enjoy the views.\\nFurthermore, even though we were promised a private table, we could not find one and no one came forward to explain it! The place was so crowded that we had a hard time moving from one place to another. Enough service persons were not present and we had to wait around 30 minutes to get our breakfast which was served cold. This was a stressful experience for both me and my wife.\\nI do not feel that is unreasonable to expect a full refund of the money paid to you following the misrepresentation of what Rose Cruises were offering. We expect, therefore, a refund of the full €300.\\nYours faithfully,\\nTom Behan", "Dear Sir or Madam,\\nAfter taking a holiday cruise recently, provided by your company, I felt that I needed to write this letter to bring a few things to your attention as far as my experience with your cruise service is concerned.\\nIn fact, the whole time, as long as I was on my holiday in your cruise ship, I felt like your company did not have any idea about how to professionally run and manage a holiday cruise. To begin with the problem, Initially, I was told that I would get a cabin on the top floor of the ship, for the price I was paying, so that I could enjoy the view of the ocean in the best way possible. But, when I got on your ship, I was given a cabin on the middle floor. Besides, I could also smell some kind of bad odour that was coming out of the ship. Finally, I was offered a very average quality of food for the whole week of my voyage.\\nIn such a situation, I do not think that expecting a full refund from your company is unreasonable since the quality of your service was way below standard.\\nYours faithfully,\\nPeter Onslow\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (6 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nSabrina Qamar\\n7 years 4 months\\nDear Mr. Louis,\\nI am writing to express my disappointment with the dining experience on your cruise a week ago. I booked your cruise for a night, from Mumbai to Goa, to celebrate our marriage anniversary. But it was not a good experience - to say the least.\\nAs this was our first marriage anniversary we wanted to make it memorable. For that purpose, we ordered exotic cuisines like oysters, large pizza topped with lobster, two cocktails, a large cake and some dessert items. But I was appalled to see what I received on my table. The meal was completely opposite to what we ordered! Moreover, they plainly apologies for not having cake and handed us a hefty bill.\\nUnfortunately, it became memorable but for the worse experience. However, some of your facilities are above average but I was completely disappointed by your catering service.\\nI want a 50% refund of my amount as that was an utter waste of our money and time. I also want you to look into this matter seriously and display only those items in your brochure which you actually have.\\nI am looking forward to your prompt action.\\nYours sincerely,\\nAngela Jones\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
