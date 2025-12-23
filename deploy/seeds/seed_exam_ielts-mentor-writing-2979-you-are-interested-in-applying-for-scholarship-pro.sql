-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:07.660309
-- Source: ielts-mentor.com
-- Title: You Are Interested In Applying For Scholarship Program
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Interested In Applying For Scholarship Program';

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
  E'You Are Interested In Applying For Scholarship Program',
  E'You should spend about\n20\nminutes on this task.\nYou are interested in applying for a scholarship program to study at a foreign university.\nWrite a letter to inquire about the course. In your letter:\nexplain which course you are interested in\nsay what you know about the university\nexplain why you should receive the scholarship\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,\nSample\nAnswer 1:\nDear Sir or Madam,\nI have recently completed my graduation from the Singapore University of Technology and Design and my major was Engineering Systems and Design. I am writing to get the details about the scholarship program that your university offers as I am really interested to complete my Master''s degree from your university.\nI would like to pursue my Master''s degree at Loughborough University and I am looking forward to getting a scholarship in the faculty of Engineering System and Design. As I want to build a career in the Engineering sector, I would like to complete my Master''s degree in the same faculty that I did for my graduation.\nI am convinced that doing the post-graduation at Loughborough University would be an excellent decision for me as the university offers the opportunity to study a subject at an advanced level, develop personal and professional skills, and it is one of the best universities in the UK. The 440-acre single-site campus offers great facilities for students, staff and gives every student the opportunity they need to achieve their full potential. I would be very proud to be a part of this glorious university.\nI want to continue my Master''s course in Engineering Systems and would be able to do so only if I am granted a scholarship as I come from a middle-class family. My Engineering Systems and Design graduation course had 138 credits in total and I achieve a CGPA of 3.89 out of 4.0. I have part-time job experience in the Engineering design field and I believe I can prove my competency for the scholarship provided that I get an opportunity.\nI look forward to your reply and would really appreciate your guidance regarding this.\nYours faithfully,\nLee Gordon',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing this letter to inquire about a scholarship program that your university offers to foreign students. I have already finished my bachelor’s degree in Economics, and now I want to pursue a master’s degree in the same subject.\\nI have already learned quite a lot about your university by reading everything on its website. Needless to say, I like everything about your university which includes very modern and well-equipped classrooms, a universal curriculum, affordable hostel accommodation, and highly qualified and experienced professors and lecturers. However, what I find the most impressive about your university is its very high campus placement rate which is about 75 per cent.\\nI know it is not easy to get a scholarship at your university, but I think that my good grades in bachelor degree (GPA 3.90 out of 4) and a high score in TOEFL (623 out of 677) would make me eligible to receive a scholarship in my subject.\\nI look forward to hearing your response on my eligibility to receive a scholarship at your university.\\nYours faithfully,\\nKishor Gupta\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.58 (12 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nInquiry Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nNeha\\n7 years 7 months\\nDear Sir/ Madam,I am writing this letter to express my interest in pursuing Catering Diploma course from the Sydney University. I would like to apply for a scholarship as my previous academic records and job experiences make me eligible for that. I am hoping to get enrolled in this prestigious university and complete my dream course in Catering Management. Sydney University has an enviable track record of producing top class professionals who not only excel in their professional life but do something good for the humanity. Built in 1850, the academic environment, course curriculum and teachers of this university make it one of the best universities in Australia and I want to get enrolled in this university to receive a top class degree and learn skills for life. This is one of the best Public research university and has always prioritised research work for the greater benefits of all.I am very happy to say that I have an average CGPA of 3.80 and I scored an overall 8 band score in my IELTS exam. A few of my articles have been published in the renowned research papers and I have three years work experience in hotel management. I would be grateful if you could help me with the procedure of applying for the course and being eligible for the scholarship.I look forward to hearing from you soon.Yours faithfully,Neha Bohra\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
