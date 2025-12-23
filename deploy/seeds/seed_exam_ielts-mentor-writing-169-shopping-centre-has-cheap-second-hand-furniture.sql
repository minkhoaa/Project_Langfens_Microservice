-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:20.648715
-- Source: ielts-mentor.com
-- Title: Shopping Centre Has Cheap Second Hand Furniture
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Shopping Centre Has Cheap Second Hand Furniture';

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
  E'Shopping Centre Has Cheap Second Hand Furniture',
  E'You should spend about\n20\nminutes on this task.\nYou have just rented an unfurnished flat and a friend has told you that the Opportunity Shop in the shopping centre has cheap second-hand furniture.\nWrite to the shop owner describing what you need and asking whether they have these items and what they cost.\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI have just arrived from overseas and purchased a flat which needs some furniture. A friend has recommended me your store and he and told me that you sell budget-friendly second-hand furniture and I am writing to inquire about a few of them that I intend to purchase.\\nRegarding my intention to purchase furniture, I would like a single bed, a kitchen table, four chairs, a cupboard for clothes, a bookcase and a wooden cabinet. If you sell home appliances, I would like a microwave oven, a television set and a rice cooker. The furniture must be in good condition and the electronic goods must be branded products with at least six months valid warranty remaining.\\nI would really appreciate it if you could inform me of the availability of those items along with their prices and details. I hope you can offer a good bargain as I am looking for something cheap. If you do not supply electrical goods, can you recommend another shop which does? Also, could you let me know when can I come and inspect the items in person?\\nI look forward to hearing from you soon.\\nYours faithfully,\\nGarcia Hall", "Dear Sir or Madam,\\nI have just rented an unfurnished flat after arriving in this town about a couple of weeks ago. Well, as you can understand that since I am new in this town, I don’t really know many places or shops here where I would be able to purchase some cheap or second-hand furniture.\\nLuckily, however, one of my friends, who lives in this town, advised me that I visit \\"Naomi Furniture\\", an Opportunity Shop, to find what I have been looking for. Needless to say, I liked what my friend had suggested after seeing your collection online.\\nAnyway, I am looking to buy a standard single bed, a couple of sofa chairs, a wardrobe, a bedside table, and a medium-size dining table along with 4 chairs. I could also use a standard office desk and a desk chair. I think that’s all the furniture I need for now.\\nSo, if you please let me know whether you have them or not, and how much they could possibly cost me, I would really appreciate it.\\nYours faithfully,\\nLarry Nixon", "Dear Sir or Madam,\\nI am writing this letter to inquire about the availability of some furniture I wish to purchase. A friend has recommended your store to me for purchasing inexpensive second-hand furniture which happens to be in the shopping centre in the Blue Bird square. I have recently purchased a flat and need some furniture.\\nIn this context, I would like to know the cost of certain items which I require for my unfurnished apartment. I would appreciate a quotation for a pair of sofa set with two side tables, a dining table comprising of eight chairs, a centre table and items required in the bedroom like the king-size bed, a dressing table and one wooden almirah of not more than seven feet height.\\nPlease send me the best possible price which you can offer for those items. Apart from this, you must categorically mention any other cost that might incur from the purchase including the transportation cost and VAT.\\nI have also been informed by my friend that you offer a cash discount for purchases over $500. In this respect, I would further like to inform you that I will pay the total amount in one go and purchase items more than 500 dollar''s worth. So I am expecting a discount.\\nIn anticipation of an early reply.\\nYours faithfully,\\nNeeraj Mehra\\n[", "is not a good answer. The tone is even up to the point of being impolite. The long sentences also make it difficult to read.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
