-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:45.198710
-- Source: ielts-mentor.com
-- Title: You Would Like To Get Enrolled In Qualification Course
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Would Like To Get Enrolled In Qualification Course';

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
  E'You Would Like To Get Enrolled In Qualification Course',
  E'You should spend about\n20\nminutes on this task.\nYou would like to get enrolled in a qualification course. Write a letter to the person in charge of the course and ask for detailed information regarding the course, fees and prerequisites.\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am John Parkinson writing in regard to getting enrolled in a diploma course that your institution has recently invited candidates to apply to. I am hoping that you would provide me with some further details regarding this.\\nI have learned about the course from a website, and I require more details to apply to this course. I have recently earned a Bachelor of Arts degree from the University of Edinburgh and hold a diploma in Basic Computing. I would like to enhance my skills in this arena and your course ''Advanced Diploma in Computing'' seems a fitting one to me.\\nCould you please write back to me with details about the course, particularly about what topics it will cover and how long it will take? I would also like to know the admission process and course fee. So kindly mention all the costs this course includes and also inform me how should I apply.\\nIf there is a special requirement to apply to the course, I should know it beforehand. I would be much obliged if you can provide me with the details at your earliest as I am looking forward to getting enrolled in this course soon.\\nYours faithfully,\\nJohn Parkinson\\nModel\\nAnswer 2:\\nDear Sir or Madam,\\nI am Caroline Norton, writing to request some information about the two-year diploma program in architectural design that your institute offers. I am keen to get registered in this course and that is why require further information regarding it.\\nIn relation to the course, I learned about the course from an advertisement published in a local newspaper, but sadly, I did not find all the details. Firstly, I would like to ask if this is a full-time or a part-time course and which subjects of architecture are included in it? Furthermore, does it provide practical training to the participants? And, can you please inform me of the total cost of the course? Lastly, is there any previous qualification related to the architecture required for eligibility?\\nI will be very grateful to you if you kindly send me these details as I am really hoping to get enrolled in it. I hope to hear from you soon.\\nYours faithfully,\\nCaroline Norton\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
