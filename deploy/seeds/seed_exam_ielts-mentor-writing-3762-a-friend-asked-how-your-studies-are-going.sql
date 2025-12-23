-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:46.657218
-- Source: ielts-mentor.com
-- Title: A Friend Asked How Your Studies Are Going
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'A Friend Asked How Your Studies Are Going';

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
  E'A Friend Asked How Your Studies Are Going',
  E'You should spend about\n20\nminutes on this task.\nAn English-speaking friend of yours has written to you to ask you how your studies are going.\nWrite an email to this friend. In your email,\ntell your friend how you are preparing for the exam\ntell him/her how you feel about it\ntell him your expectations\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your email as follows:\nDear ......................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Julian,\\nThank you so much for writing to me and giving details about yourself. I''m also glad to know that you''re doing fine with your studies and work.\\nAs for your question regarding how I''m doing with my studies, it''s not exactly going too well because I''m a bit overwhelmed with my studies now.  In fact, now I''m spending a lot more time than usual studying because I''m preparing for my 6th-semester final exams. I''m somewhat done with my revisions for all the major subjects except “Business Finance” and \\"Management Information System\\" – two subjects I''m currently struggling with.\\nOf course, I''ve already met the teachers of these subjects a few times to discuss and understand a few critical topics, but I''m still not too sure that I actually understand them! I need to study more to secure a good grade.\\nSo, it''s fair to say that I''m a bit nervous now because if I don’t do well in these subjects this semester, my overall grade is probably going to be affected a bit more negatively than I had initially thought. After all, my previous grades haven’t really been that good. So, please wish me luck!\\nBest regards,\\nSiyam\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.50 (10 Votes)\\nGT Writing Task 1\\nemail writing\\nemail to friend\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nSylvester Rodrigues\\n2 years 11 months\\nAn English-speaking friend of yours has written to you to ask you how your studies are going. Write an email to this friend.\\nDear Sam,\\nThank you so much for writing to me. I''m glad to know that you are preparing for your second-semester examinations. I''m doing good and going well.\\nAs for your enquiry about how my studies are going on, I''d like to say that my studies are going well, and I''m working hard for my upcoming semester-final exams. Though sometimes, I feel nervous thinking about how my exam paper will be, I''m confident that it''ll go well! Rest assured, I''m giving my best. I''ve completed some subjects, while in the process of revising subjects like Finance, Arts and so on.\\nI had spoken to some of my faculty members when I visited my college and took some pieces of advice from them regarding the two toughest subjects which are Business Studies and Macroeconomics. I hope I will get a good overall grade in my term final exams.\\nI''m hoping for the best and praying for an easy question paper to do excellent in my exams.\\nSo please wish me luck!!\\nWarm regards,\\nJames\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
