-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:30.412761
-- Source: ielts-mentor.com
-- Title: You Are A Member Of An International Students Club
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are A Member Of An International Students Club';

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
  E'You Are A Member Of An International Students Club',
  E'You should spend about\n20\nminutes on this task.\nYou are a member of an International Students'' club. The club is organising an event to celebrate popular food from around the world.\nWrite a letter to the event organiser, Luis. In your letter,\noffer to make a popular dish from your country\ndescribe what this dish is\nexplain why it should be included in the event\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Luis,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Luis,\\nThank you very much for your initiative to organise this fabulous event to celebrate famous food from all corners of the world. Here, I am writing to express my interest in contributing to the upcoming international food event. As a proud Canadian, I would love to prepare a traditional dish from my country called \\"poutine\\" for everyone to enjoy.\\nPoutine is a beloved Canadian dish that consists of crispy French fries topped with rich cheese curds and smothered in savoury brown gravy. Originating from Quebec, it has become an iconic comfort food across Canada and is enjoyed by people of all backgrounds. Some variations even include additional toppings such as smoked meat.\\nI believe poutine would be a great addition to the event because it represents Canadian cuisine’s fusion of simple ingredients with bold flavours. Moreover, its hearty and indulgent nature makes it a crowd-pleaser that I am sure many attendees would love to try.\\nPlease let me know if I can go ahead with this contribution.\\nLooking forward to your response.\\nYours sincerely,\\nEmma Johnson", "Dear Luis,\\nI am excited about the upcoming international food event and would like to thank you for organising it. I would love to contribute to this event by preparing a famous dish from China called Peking Duck.\\nAs you might already know, Peking Duck is one of China’s most iconic and celebrated dishes, originating from Beijing. It features crispy, golden-brown roasted duck served with thin pancakes, spring onions, cucumber, and a rich hoisin sauce. The combination of textures and flavours - crispy skin, tender meat, and sweet-savoury sauce - makes it a truly unforgettable dish. Traditionally, it is prepared using a special roasting technique that enhances its flavour and ensures a perfect crunch.\\nI believe Peking Duck would be an excellent addition to the event because it represents China’s rich culinary heritage and is widely loved around the world. It would provide attendees with an authentic taste of Chinese cuisine and add diversity to the selection of dishes at the event. Please let me know if I can go ahead with this contribution.\\nLooking forward to your response.\\nYours sincerely,\\nChen Hao\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (5 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
