-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:45.051666
-- Source: ielts-mentor.com
-- Title: Letter To Cancel Part Time Course At A College
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Letter To Cancel Part Time Course At A College';

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
  E'Letter To Cancel Part Time Course At A College',
  E'You should spend about\n20\nminutes on this task.\nYou recently booked a part-time course at a college. You now need to cancel your booking.\nWrite a letter to the college administrator. In your letter,\nsay which part-time course you booked\nexplain why you need to cancel your booking\nask about booking a different course\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nMy name is Charley Sanders, and I am writing this letter to cancel my enrollment in a part-time course at your college which I was planning to take this coming summer. Please let me explain what prompted me to do this.\\nThe course, in which I enrolled as a part-time student, is called “Digital Photography”, and it was to be finished within three months from the date of its commencement. To tell the truth, I was quite excited about completing this short course until my company asked me to work full-time this coming summer. In case you are wondering, I am currently working as a part-time employee at a ready-made garments factory as a Quality Assurance Associate, and if I start working as a full-time employee, I just will not have enough time to carry on with the course. In other words, a conflict in my schedule is what is forcing me to cancel this course.\\nBut, the good thing is that I can book another course after my working hours, and if that is an option, I would be more than happy to be enrolled in a computer networking course.\\nThanks for being so understanding.\\nYours faithfully,\\nCharley Sanders", "Dear Sir or Madam,\\nI am Emily Jones, and I am formally writing to request the cancellation of my booking for the Evening Photography Course at your college, which was scheduled to begin on March 15th.\\nUnfortunately, due to unexpected work commitments at my office, I will no longer be able to attend the course as planned. My work schedule has changed, and I am now required to stay late in the evenings, making it impossible for me to participate in the sessions.\\nHowever, I am still very interested in taking a course at your college. Could you please provide me with information about any weekend photography courses or other part-time programmes that might suit my availability? I would appreciate any guidance on how to transfer my booking or enrol in a different course.\\nThank you for your assistance. I look forward to your response.\\nYours faithfully,\\nEmily Jones\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.85 (17 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nShalini Sharma\\n1 year\\nDear Sir or Madam,\\nMy name is Shalini Sharma, and I am writing this letter to cancel my booking of a part-time course that I opted for at your college.\\nI took a palliative care course part-time. However, recently I have learned that this course is more suitable for nursing students. Since I have a Physiotherapy background, I do not think this course will be more valuable and useful in the future with that aspect.\\nI am extremely interested in booking a full-time Kinesiology course at your college. This course is quite relevant to what I have already done. Additionally, this course, due to its relevance, can provide me with more job opportunities in the coming time.\\nTherefore, I request you to cancel my present course booking and re-book me for the Kinesiology course. My sincere apology for the inconvenience.\\nI look forward to hearing from you soon.\\nYours faithfully,\\nShalini Sharma\\nReply\\nQuote\\nJarnail Singh\\n2 years 8 months\\nGreat explanation.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
