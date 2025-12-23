-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:19.436863
-- Source: ielts-mentor.com
-- Title: You Paid Refundable Deposit When You Rented Apartment
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Paid Refundable Deposit When You Rented Apartment';

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
  E'You Paid Refundable Deposit When You Rented Apartment',
  E'You should spend about\n20\nminutes on this task.\nYou paid a refundable deposit when you rented an apartment a year ago. You left the apartment last month in good condition but the landlord won''t return your deposit.\nWrite a letter to the landlord. In your letter,\nintroduce yourself and say why you are writing\nask for the return of your deposit\ninform the landlord of possible action if he/she does not agree to refund the amount\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Clive,\\nI hope you and your family are doing well. My name is Louis Fabian, and I rented one of your apartments on Jenkins Avenue and lived there for a year before leaving the place last month. Anyway, the reason, for which, I am writing this letter to you is that even though I left the apartment in good condition, I did not receive my money, as per the leasing agreement, which was paid to you as a refundable deposit when I rented your apartment.\\nOf course, not receiving the refundable deposit from you is frustrating enough for me, but even more frustrating is the fact that you did not care to specify any possible reasons as to why I should not get my deposit back.\\nAnd since you failed to give me any reason whatsoever as to why I should not get my deposit back, it is only fair that you refund my money to me without any delay. But, if you are not willing to cooperate with me on this, I am afraid that I will have to take legal action against you to decide the matter in court.\\nYours sincerely,\\nLouis Fabian\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.82 (11 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
