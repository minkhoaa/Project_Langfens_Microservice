-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:09.882880
-- Source: ielts-mentor.com
-- Title: Letter To Bank Requesting Information About Obtaining Business Loan
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Bank Requesting Information About Obtaining Business Loan';

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
  E'Letter To Bank Requesting Information About Obtaining Business Loan',
  E'You should spend about\n20\nminutes on this task.\nYou want to start your own small business. Write a letter to a bank requesting information about obtaining a business loan to finance your new company.\nIn your letter, include the following information:\nwhat kind of business you want to start\nhow much money you need\nthe length of time over which you would expect to repay the money\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,\nSample\nAnswer 1:\nDear Sir or Madam,\nI am writing to inquire about the possibility of a business loan from your bank to finance a startup business I have planned to commence soon. I am hoping you would provide me with some information and document requirements so that I can apply for the loan.\nI have completed my graduation from the University of Edison and my major was marketing. Now I am interested to start a coffee shop of my own and need a loan to support it. I own the location of the shop and have some prior experience of working at a large coffee shop. A business outlining firm responsible for the business plan has suggested a capital requirement of $10,000 for the coffee shop. I can finance 50% of the fund requirement and need another $5000 as a loan from your bank.\nMy father would be ready to be a guarantor for the loan and I can repay the loan amount with interest within 2 years. However, I need three months'' grace period before I start repaying my monthly instalment.\nI would really appreciate it if you could send me details of the loan including the interest rates, monthly instalment amount and so on. Also, forward me the documents I need to fill in and submit to actually apply for the loan.\nYours faithfully,\nJames Moore',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI have been dealing with your bank for a long time, and I think it is time to take our business relationship to the next level. Anyway, I am writing this letter to you because I need a term loan as I am planning to start a small business within the next few months.\\nConcerning the business I have in my mind, it is going to be a bakery factory where I am intending to bake all kinds of bread and cakes and then supply them to the neighbouring cities to maximize my sales and revenue. By the way, I have already done some cost calculations and based on it, I would require about $7,500 to start the business. Of course, I also have a little bit of my own money which would help me cover some of the other expenses for starting this business.\\nAnyway, I want it to be a short term loan. So, please structure my loan payment in such a way so that I am able to pay it back within 2 years as equated monthly installation.\\nI hope to hear a positive reply from you soon.\\nYours faithfully,\\nJoseph Abraham\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.86 (7 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nRequesting-information-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
