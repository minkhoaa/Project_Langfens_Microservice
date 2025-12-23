-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:45.161983
-- Source: ielts-mentor.com
-- Title: You Went To Local Restaurant With Family And Were Very Satisfied
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Went To Local Restaurant With Family And Were Very Satisfied';

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
  E'You Went To Local Restaurant With Family And Were Very Satisfied',
  E'You should spend about\n20\nminutes on this task.\nRecently you went to a local restaurant with your family and you were very satisfied with their food and service. Write a letter to the editor of a local newspaper to tell him/her about it. Describe the meal you and your family members had and let the editor know why you think the restaurant is worth visiting.\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am a fan of your informative editorial and articles which I try to read as often as I can. I also like to share and exchange local information with my fellow residents of this town on different forums, such as your newspaper. And, as a part of this information sharing effort, I would like to talk about a restaurant, where I visited recently with my family members, which I think is worth visiting.\\nWe tried several meals at that restaurant, and I must say that they were of top quality because they all seemed to be made with fresh ingredients. I especially liked their “mushroom fettuccine”, made with some perfectly grinded hot pepper flakes and evenly cut mushrooms. The French fries served there were also very delicious and chewy. Besides, I also liked the nice sitting arrangement there in front of their spacious porch, which was nicely decorated with different kinds of flower plants. As for the customer service there, I think that the staff at the restaurant knew perfectly well how to make their customer happy.\\nSo, based on these findings, I would certainly recommend this restaurant to anybody and hope that you would publish an article reviewing and recommending this restaurant to your readers.\\nYours faithfully,\\nGeorge Malone", "Dear Sir or Madam,\\nI am a regular reader of your daily newspaper “Times of India.” I am writing this letter to inform you about an authentic restaurant called “Step and Eat” which I have visited recently with my family. I reckon this is a worth visiting place for others and hoping that you would write a review on this eatery to let others know about this fabulous place.\\nLocated on Smith Street near the National Park, it is a multi-cuisine restaurant. I went there with my family last Sunday. As we are fond of Italian food, my husband ordered an Italian meal. The meal comprised of a delicious soup, a signature dish of the hotel known as mixed vegetable spaghetti and at the end we had a mouth savouring dessert called Green Marshmallows which had a perfect creamy texture. It was one of the memorable dinners I have ever had with my family.\\nThe restaurant is worth visiting for everyone in the town because it offers a wide range of varieties in food to satisfy the human palate. Moreover, it maintains proper cleanliness and hygiene. The staff members are so polite, co-operative and professional - which gives a diligent feeling to the customers.\\nHence, I request you to write an article or review on this restaurant so that more people could come to know and visit it.\\nI look forward to hearing from you.\\nYours faithfully,\\nVishwa Vinutna\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
