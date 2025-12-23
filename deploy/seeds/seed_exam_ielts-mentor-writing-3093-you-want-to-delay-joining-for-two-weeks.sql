-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:46.528519
-- Source: ielts-mentor.com
-- Title: You Want To Delay Joining For Two Weeks
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Want To Delay Joining For Two Weeks';

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
  E'You Want To Delay Joining For Two Weeks',
  E'You should spend about\n20\nminutes on this task.\nYou have been offered a job, asking you to start next week. You want the job very much but, because of a previous commitment, you want to delay the start for another two weeks.\nWrite to the manager, accepting the job, but explaining your situation and asking for a change to your start date.\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,\nSample Answer 1:\nDear Sir or Madam,\nI am absolutely honoured to learn from your email that you have finalised my joining as an executive in your company. I consider it a great leap forward towards my future career, and I will serve my position with my best effort. However, I am writing to seek your permission for a delay in the joining date.\nI am afraid I cannot join on 15th June, the date you expect me to start. After I formally notified my current employer a month ago, they welcomed my decision. However, they have recently requested an extension to hand over the projects I am currently working on and train a colleague. I am already committed to a project with my current employer and I will need another week to finish it. Thus, the new request from my manager forces me to work another two weeks with them.\nTherefore, I would request you to delay my joining date and I am absolutely positive about starting with you from the 1st of July. I hope you will allow me to finish my commitment to my current employer and let me join your company on 1st July.\nYours faithfully,\nDaren Smith',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am absolutely honoured to learn from your email that you have finalised my joining as an executive in your company. I consider it a great leap forward towards my future career, and I will serve my position with my best effort. However, I am writing to seek your permission for a delay in the joining date.\\nI am afraid I cannot join on 15th June, the date you expect me to start. After I formally notified my current employer a month ago, they welcomed my decision. However, they have recently requested an extension to hand over the projects I am currently working on and train a colleague. I am already committed to a project with my current employer and I will need another week to finish it. Thus, the new request from my manager forces me to work another two weeks with them.\\nTherefore, I would request you to delay my joining date and I am absolutely positive about starting with you from the 1st of July. I hope you will allow me to finish my commitment to my current employer and let me join your company on 1st July.\\nYours faithfully,\\nDaren Smith", "Dear Sir or Madam,\\nI am Elina Afrin, writing to express my gratitude for the job offer extended to me. I am excited about the opportunity to join your team as a senior software developer and contribute to the success of the company.\\nHowever, I regret to inform you that due to a prior commitment, I am unable to start the job next week as requested. I am currently working on an important project at my current office, which will require my attention for the next two weeks.\\nI want to assure you that my commitment to the role and my enthusiasm for the opportunity remain unwavering, and I am very much looking forward to joining your company. Considering the circumstances, I am requesting a delay in my start date by two weeks to accommodate my existing commitment. I can assure you that I will also use the additional time to prepare thoroughly for my new role.\\nThank you for your understanding and flexibility in this matter. I am eager to begin my employment with your esteemed company and am confident that my delayed start will not impact my ability to contribute effectively.\\nI look forward to hearing from you soon regarding the revised start date.\\nYours faithfully,\\nElina Afrin", "Dear Sir or Madam,\\nFirst of all, I would like to thank you for offering me the position of Senior Accounting Analyst at your company. Not to mention, I would like to start the job as soon as possible since I am looking forward to starting my work at your company. But, it looks like I will not be able to start from next week, as you have asked, because of a few commitments with my current employer.\\nIn fact, the employment contract, I have with my current employer, clearly states I will have to give my current employer at least two weeks'' notice before leaving the company. Besides, I still have a few important projects in my hands to finish all by myself and hand them over to my superior because, currently, I am the only qualified personnel in my company to take care of these tasks in a professional manner.\\nTherefore, based on these prior commitments and obligations I mentioned above, I would be grateful to you if you kindly delay my starting date for this job position until another two weeks.\\nThank you for your consideration in advance.\\nYours faithfully,\\nAdam Finch", "Dear Sir or Madam,\\nThank you very much for offering me the position of Senior Business Analyst at your company. I am thrilled to accept this opportunity and eager to contribute my skills and experience to your team. The prospect of working with such a talented and diverse team is particularly exciting, and I am confident that I can make a positive impact from day one.\\nHowever, I am writing to respectfully request a slight adjustment to the proposed start date of 1st October. Due to a prior commitment I made several months ago with my current employer, I am unable to begin full-time employment until 14th October, two weeks from the originally proposed date. I understand the importance of timely onboarding for new hires, and I am fully committed to ensuring a smooth transition.\\nI apologize for any inconvenience this may cause, and I appreciate your understanding. My enthusiasm for this role remains strong, and I am confident that I can quickly become a valuable asset to your team.\\nThank you again for offering me this exciting opportunity. I look forward to hearing from you regarding my request.\\nYours faithfully,\\nAron Anderson\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.40 (10 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
