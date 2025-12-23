-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:08.643275
-- Source: ielts-mentor.com
-- Title: Write Your First Letter To Homestay Host Family
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write Your First Letter To Homestay Host Family';

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
  E'Write Your First Letter To Homestay Host Family',
  E'You should spend about\n20\nminutes on this task.\nYou are going to visit New Zealand for an ''English and Homestay'' program. You have just received details of your homestay host family.\nWrite your first letter to the family. In your letter,\nintroduce yourself\nask the family some questions to get information that is important to you\ntell the family about your arrival date and time\nYou should write at least\n150\nwords.\nYou do NOT need to write any addresses.\nBegin your letter as follows:\nDear ...................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Albert,\\nI am writing to thank you for agreeing to be my English and Homestay host. I would really appreciate some information from you and would like to inform you that I will arrive at your house in New Zealand in July.\\nI am Jacques Gordon, a French by nationality, but currently pursuing my graduation in accounting at the London University in the UK. My parents and siblings live in Paris. I enrolled in the \\"English and Homestay program\\" a few months ago and my intention was to take the opportunity to learn the language efficiently.\\nI would be glad to know about you - more specifically what you do and how many members do you have in your family and so on. I would also like to know about some traditions and formalities you respect in New Zealand. I will be travelling to New Zealand for the first time and hence your suggestion about the etiquette of being a guest would be highly appreciated.\\nMy expected arrival date is on 19th August 2025 and the flight is scheduled to reach Wellington Airport at 6.00 pm local time. It would be great if you could fetch me from the airport. If you have another schedule, I would take a taxi to your address.\\nI am really looking forward to spending some quality time with you and your family. Please write to me at your convenience.\\nYours Sincerely,\\nJacques Gordon\\n[", "Dear Mr Nithan,\\nI am Preeti Roy, a 22-year-old student from India. I applied for an English Homestay program at the University of Wellington and I have received a letter from the university, apprising me that you will be my host family. I really appreciate that you have agreed to host me at your house.\\nI am from Delhi, India and I am pursuing my Engineering degree from the University of Technology in Delhi. My father is a doctor and my mother is an architect. I have two siblings and they are juniors to me. I applied for the English Homestay programme last June to further enhance my English speaking skills.\\nI was wondering if you could advise me on the weather and etiquette in Wellington as I have never been there. What type of dress should I bring? Could you also inform me of the distance between your home and the university and what will be the easiest way to reach the university? Besides, I am coming to New Zealand for the first time and have no idea about the common cultures and manners you respect. Please advise me on that as well.\\nI will arrive in Wellington on 10th December, probably around 10:30 in the morning. I want to reach a week earlier as I want to explore the surrounding areas. Kindly also inform me of the best way to reach your home from the airport.\\nLooking forward to meeting you soon.\\nYours sincerely,\\nPreeti Roy\\n[by  -\\nPreeti\\n]\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.75 (8 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nRequesting-information-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
