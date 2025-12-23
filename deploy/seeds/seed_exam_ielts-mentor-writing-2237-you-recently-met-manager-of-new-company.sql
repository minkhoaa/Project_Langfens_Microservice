-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:15.454204
-- Source: ielts-mentor.com
-- Title: You Recently Met Manager Of New Company
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Recently Met Manager Of New Company';

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
  E'You Recently Met Manager Of New Company',
  E'You should spend about\n20\nminutes on this task.\nYou recently met the manager of a new company that started in your city. After the meeting, the manager wrote you a letter offering a job at this company. However, you cannot accept the job offer.\nWrite to the manager and say:\nhow you feel about the job offer\nwhy you can''t accept it\nprovide a reference to your friend who might be interested\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear ....................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Alex,\\nHope you are doing great. I thoroughly enjoyed our conversation during our meeting and would like to thank you for a fabulous lunch. I am so honoured to be offered a job at your company. However, I cannot accept it right now.\\nI am really fortunate that you have offered me the position of “Design Engineer” in the Biomedical Device Manufacturing company that you have recently started in our city. But unfortunately, I am in a situation to deny this offer because of the contract I have with my current employer. I am quite happy with the remuneration, working environment and facilities I get from my current job and have no plan to change my job now.\\nThough I cannot be a part of your new team, I could suggest one of my friends - Ruhan Chowdhury,  who is a passionate Engineer and is currently seeking a job opportunity. After hearing from you, I can ask him to meet you personally for an interview to discuss his credentials. He is a talented individual and I believe he would add value to your company.\\nI regret not accepting this offer but I hope once my contract is over, I would be privileged to work for your company and thank you for the offer.\\nLooking forward to receiving your reply soon.\\nYours faithfully,\\nS. Nivetha\\n[", "Dear Mr Roger,\\nHope you are fine. I thoroughly enjoyed talking to you the other day, and I am also glad and flattered that you have chosen to offer me a position at your company as a Supply Chain Executive.\\nBut, as much as I like your offer, I regret that I will not be able to accept it at this time, primarily because I do not really have any formal experience of working in this particular field. Besides, I am holding a senior position at my current job, and I really like it, even though, it does not pay as much as you are willing to pay me. Hope you understand my position.\\nBut, I can certainly recommend a prospective candidate for this job, who I do not only know personally, but he also has the experience of working as a junior Supply Chain Associate at a small manufacturing firm.\\nLast time, when I talked to him, he was planning to switch his company for a better position. I will send him over to you if you wish.\\nThank you once again for your generous offer.\\nYours sincerely,\\nFreddie Marcus\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.25 (12 Votes)\\nIELTS Letter Writing\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nRipalkumar Patel\\n7 years\\nI think we can''t use the name of a person in the formal type letter. I think we should use \\" Dear Sir\\".\\nReply\\nQuote\\nTahirabid\\n10 years 2 months\\nMy essay test is today.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
