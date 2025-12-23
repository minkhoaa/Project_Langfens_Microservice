-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:30.365962
-- Source: ielts-mentor.com
-- Title: You Recently Enjoyed Meal At Restaurant To Celebrate Special Occasion
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Recently Enjoyed Meal At Restaurant To Celebrate Special Occasion';

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
  E'You Recently Enjoyed Meal At Restaurant To Celebrate Special Occasion',
  E'You should spend about\n20\nminutes on this task.\nYou recently enjoyed a meal at a restaurant to celebrate a special occasion, and you were very pleased with the food and service.\nWrite a letter to the restaurant manager.\nIn your letter,\ngive details of your visit to the restaurant\nmention the reason for the celebration\nsay what was good about the food and the service\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,\nSample Answer 1:\nDear Sir or Madam,\nI am writing to you to express my satisfaction with the excellent service and high quality of food that your restaurant provided us last Sunday, on the occasion of my 30th birthday.\nWe were a party of fifteen, which included my family, close friends and colleagues from work. Your staff went out of their way to provide seating arrangements that were easily accessible. The waiters were extremely professional, polite and obviously experienced as they did not encroach too much on the proceeding.\nYour current menu offers plenty of choices, as does your wine list, and everything was available. We were very pleased with the quality and quantity of the dishes served. I ordered the rack or mutton ribs, which was deliciously succulent and, if anything, maybe slightly too large! Nevertheless, we managed to finish it. I was similarly impressed with the variety of local and international wines you served. The wine that was ordered arrived at the correct temperature that each wine should be consumed. The waiters were familiar with the etiquette, and the service was paramount.\nAll in all, our group enjoyed a delicious meal at your establishment, and I had a very happy birthday.\nThank you once again.\nYours faithfully,\nDenis Brian',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to you to express my satisfaction with the excellent service and high quality of food that your restaurant provided us last Sunday, on the occasion of my 30th birthday.\\nWe were a party of fifteen, which included my family, close friends and colleagues from work. Your staff went out of their way to provide seating arrangements that were easily accessible. The waiters were extremely professional, polite and obviously experienced as they did not encroach too much on the proceeding.\\nYour current menu offers plenty of choices, as does your wine list, and everything was available. We were very pleased with the quality and quantity of the dishes served. I ordered the rack or mutton ribs, which was deliciously succulent and, if anything, maybe slightly too large! Nevertheless, we managed to finish it. I was similarly impressed with the variety of local and international wines you served. The wine that was ordered arrived at the correct temperature that each wine should be consumed. The waiters were familiar with the etiquette, and the service was paramount.\\nAll in all, our group enjoyed a delicious meal at your establishment, and I had a very happy birthday.\\nThank you once again.\\nYours faithfully,\\nDenis Brian", "Dear Sir or Madam,\\nI am writing to express my appreciation for the meal and service that your restaurant provided us last Sunday on the occasion of my 21st birthday.\\nYour restaurant is located near my office, and I took a few friends and colleagues to celebrate my birthday based on a recommendation from one of my colleagues. We had lunch at your establishment and it was fabulous. The experience made my birthday even special, and I am quite thankful for an auspicious service and delicious menu.\\nWe were greeted properly just when we entered the restaurant, and surprisingly, the manager himself came down to us and arranged an excellent sitting place for us from where we enjoyed a great view. A waiter came to tantalize our taste buds explaining the details of the menu. We had the \\"Thai soup\\" to start with. It was served just perfectly, and it smelled great. Then we opted for mackerel and fried rice which were well flavoured and had a decent portion of 4 fillets with each serving. For the main course, we had the lamb cutlets which melted in our mouths tenderly and came with a delightfully spiced harissa sauce. I must say that your food made our day!\\nWe absolutely took away something truly special from this visit. Thank you once again for a fantastic experience at your establishment. We can not wait until our next visit!\\nYours faithfully,\\nTom Chatfield\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 2.69 (26 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nNaomi Eboigbe\\n1 year 3 months\\nNice sample; I would like to download it.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
