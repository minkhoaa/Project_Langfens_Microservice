-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:49:14.654163
-- Source: ielts-mentor.com
-- Title: Write Letter Of Recommendation For Your Friend
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write Letter Of Recommendation For Your Friend';

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
  E'Write Letter Of Recommendation For Your Friend',
  E'You should spend about\n20\nminutes on this task.\nOne of your friends wants to apply for a job that involves working with foreign teenagers. Write a letter of recommendation for him/her.\nIn your letter, express:\nhow well you know your friend\nwhat qualifications he/she has\nwhy you think she would be suitable for the job\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,\nSample Answer 1:\nDear Sir or Madam,\nI am writing this letter to recommend one of my close friends, Millie Mercy, for the position of assistant supervisor in your organisation. She has an outstanding academic record, prior work experience with children and an amiable personality which would make her a suitable candidate to work in your organisation.\nI have been close to Millie since my childhood. She was my classmate both in school and college. Due to her leadership quality, excellent academic performance and pleasant personality, teachers and students loved her dearly. She won a prestigious prize during her school graduation ceremony and then got admitted to Johanson''s Merit College where she was an active organiser of social events.\nShe completed her graduation from the University of Eden and then worked as an interpreter for the United Nation. Afterwards, she travelled extensively and worked closely with two different humanitarian organisations in many parts of the world. She can speak English, French and Spanish fluently. She even has prior teaching experience and children love her very much.\nI would definitely recommend her for the position you have advertised. Should you need any further information please do not hesitate to write to me.\nYours faithfully,\nElyse Villani',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing this letter to recommend one of my close friends, Millie Mercy, for the position of assistant supervisor in your organisation. She has an outstanding academic record, prior work experience with children and an amiable personality which would make her a suitable candidate to work in your organisation.\\nI have been close to Millie since my childhood. She was my classmate both in school and college. Due to her leadership quality, excellent academic performance and pleasant personality, teachers and students loved her dearly. She won a prestigious prize during her school graduation ceremony and then got admitted to Johanson''s Merit College where she was an active organiser of social events.\\nShe completed her graduation from the University of Eden and then worked as an interpreter for the United Nation. Afterwards, she travelled extensively and worked closely with two different humanitarian organisations in many parts of the world. She can speak English, French and Spanish fluently. She even has prior teaching experience and children love her very much.\\nI would definitely recommend her for the position you have advertised. Should you need any further information please do not hesitate to write to me.\\nYours faithfully,\\nElyse Villani", "Dear Sir or Madam,\\nI have been notified by one of my close friends that your organisation is looking for a few bilingual assistant tutors to work with foreign children. I am writing to you to recommend one of my best friends, Anna Pattison, whom I consider a deserving candidate for the post.\\nI know Anna for more than 14 years. She used to be my classmate at the Cherry Blossom International School and then at Saint John College. She used to be an enthusiastic organiser and participant in extracurricular activities. For her outstanding leadership skills and cheerful personality, she was nominated class captain for most of her academic years in school. Her excellent skills in both English and Spanish make her ideal for the post that involved working closely with children.\\nShe completed her graduation from Arts major and received a distinctive medal for her exceptional academic performance. Upon her graduation, she worked as a teacher in an international school in London, where she has been teaching bilingual lessons for five years. What’s more, she loves being around children and easily wins their hearts.\\nTherefore, I do not hesitate to recommend her as an ideal candidate for the post you advertised. I am sure she would be an excellent candidate for the post.\\nYours faithfully,\\nEnya Brennan\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.75 (10 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
