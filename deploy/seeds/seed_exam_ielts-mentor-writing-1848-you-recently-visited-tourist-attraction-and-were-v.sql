-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:29.598275
-- Source: ielts-mentor.com
-- Title: You Recently Visited Tourist Attraction And Were Very Pleased
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Recently Visited Tourist Attraction And Were Very Pleased';

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
  E'You Recently Visited Tourist Attraction And Were Very Pleased',
  E'You should spend about\n20\nminutes on this task.\nYou recently visited a tourist attraction and you were very pleased with the help given to you by the staff.\nWrite a letter to the head of staff at the tourist attraction. In your letter:\ngive details of the circumstances of your visit\ndescribe the help given to you by the staff\nsay what you want the head staff to do\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am Pham Van Duc, a tourist from Vietnam, recently been to your Illusion 3D Art Museum in Kuala Lumpur, Malaysia and had been overwhelmed both with the collection and courteous staff. I am writing to express my appreciation for the wonderful experience that I had during my visit to your Museum.\\nI took a week-long vacation to Kuala Lumpur with my wife and daughter in August and learned about your Museum from TripAdvisor, a useful website for tourists. After we reached your Museum, the receptionist explained what we can expect once inside and what we can do to enjoy our time. She was very friendly and cooperative. Once we got inside, another staff member greeted us and then escorted us to different worth enjoying 3D collections. My daughter had thoroughly enjoyed her time and we took several pictures to capture the moment. He was with us until the last moment and had been quite cordial.\\nI would like to thank you for a great museum with a fabulous selection and on top of that, gracious staff members who have a genuine smile and a positive mentality to let visitors enjoy their time. Please convey my regards and best wishes to them.\\nYours faithfully,\\nPham Van Duc", "Dear Sir or Madam,\\nI have recently visited the famous Vinevasi Waterfall after learning it from a friend and took your service for the tour. The service I was offered was excellent and I would like to thank you for that.\\nI was not exactly planning to visit the waterfall, but, then I had to travel to Kuala Lumpur suddenly for a business trip, and that is when I remembered what my friend had told me about your tourist place. So, after finishing my work, I decided to visit your beautiful tourist attraction for a couple of days. But, after arriving there, I asked myself why I had not planned for a longer stay because all of your staff members were very courteous and friendly. They did not just make sure that I was comfortable on the tourist bus and at the hotel, but also made sure my belongings were kept in the right place. They took me to the best local restaurant and informed me a great deal about the history of the place.\\nI would like to thank you. Also, please convey my good wishes to your staff. I would like to mention that, after talking to some staff members, I felt like they were not getting enough time off from their works. So, I would be glad if you try to address that issue to make sure that they feel appreciated even more for what they do.\\nYours faithfully,\\nRogerio Frugardo\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.14 (11 Votes)\\nIELTS Letter Writing\\nAcademic Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
