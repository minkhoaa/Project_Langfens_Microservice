-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:29.336091
-- Source: ielts-mentor.com
-- Title: You Have Recently Learned About A Piece Of Equipment
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Recently Learned About A Piece Of Equipment';

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
  E'You Have Recently Learned About A Piece Of Equipment',
  E'You should spend about\n20\nminutes on this task.\nYou have recently learned about a piece of equipment that would help you at your workplace.\nWrite a letter to your manager. In your letter,\ndescribe the equipment\nexplain how it might be useful at your workplace\noffer help in purchasing it\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear .......................,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Henry,\\nI recently came across a piece of office equipment at another office that I found exciting and believe could greatly enhance our workplace environment. This is a \\"standing desk\\" that I am talking about. Given the long hours that many of us spend at our desks, a standing desk would provide significant health and productivity benefits.\\nStanding desks are known to reduce the risks associated with prolonged sitting, such as back pain and poor posture. Since we work long hours in front of our computers, those standing desks could be an excellent choice. According to a journal, these desks also promote better blood circulation and boost the concentration and energy levels of employees. By incorporating these desks into our office, I believe, we could improve overall employee well-being, leading to higher efficiency.\\nIf you find this idea worth considering, I would be happy to assist in researching suitable models within our budget and coordinating with suppliers to find the best option. Please let me know if you would like me to provide further details.\\nThank you in advance.\\nYours sincerely,\\nAmelia Martin\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (4 Votes)\\nGT Writing Task 1\\nLetter to office manager\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
