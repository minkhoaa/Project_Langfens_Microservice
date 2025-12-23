-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:21.281180
-- Source: ielts-mentor.com
-- Title: You Need To Return To Your Country Before End Of Semester
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Need To Return To Your Country Before End Of Semester';

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
  E'You Need To Return To Your Country Before End Of Semester',
  E'You should spend about\n20\nminutes on this task.\nYou are studying overseas. You need to return to your country before the end of the semester for a family event.\nWrite a letter to your supervisor. In your letter,\n- request some time off\n- explain why you need to leave early\n- reassure him/her that your studies will not suffer\nYou should write at least\n150\nwords.\nYou\ndo NOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Joseph,\\nI am a student at your university and my major is finance. I need to visit my home country owing to my sister''s marriage ceremony on 22nd November 2025. I am hoping that you would permit me to take a week''s leave from 17th to 23rd November.\\nInevitably, being the only brother of the bride-to-be, shopping and some important rituals are to be taken care of by me and therefore my family members and relatives are expecting me to arrive a little earlier. I am quite aware that I have my semester exams on 15th December and I assure you that my travel would no way affect my studies. In fact, I have prepared all the subjects well in advance so I could succeed in the assessment tests with good scores.\\nI would be grateful if you could approve my leave and pray for my sister.\\nLooking forward to hearing from you.\\nYours sincerely,\\nNivetha Roy\\n[", "Dear Ms Corey,\\nI am pursuing my graduation in computer science at your college and I am in my fifth semester. I am writing to request some time off classes, so as to ensure my presence in a family event in my home country next month. But I can assure you that I will get back to my classes on time and cover my studies.\\nYou would be glad to know that my sister is getting married on 5th September and as the only elder sibling, a major share of responsibilities rests on my shoulders to precede and conduct the programme in a well-appreciated manner. My presence in the rituals is highly expected. Therefore, I would request you to allow me the leave for a week starting from 1st September.\\nI can assure you that I will resume my classes on 7th September. It is almost certain that after beholding the functions and post-marriage formalities, I will fly my way back within a week''s time. Finally, I pledge to you that, this short period of time, by no means, will hinder my preparation for the semester final. I am quite keen about this and hereby reassure you that my studies will not suffer.\\nYours sincerely,\\nVineeth Vera\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
