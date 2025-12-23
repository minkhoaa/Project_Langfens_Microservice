-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:40.505029
-- Source: ielts-mentor.com
-- Title: You Want To Organise A Party In Your Office
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Want To Organise A Party In Your Office';

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
  E'You Want To Organise A Party In Your Office',
  E'You should spend about\n20\nminutes on this task.\nYou want to organise a party in your office to celebrate something.\nWrite a letter to your manager about the party at the office. In your letter,\nsay what the party is about\nmention why it is necessary\nexplain what you expect from him/her to do\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am writing to inform you about a party in our office that we are planning to organise next Friday afternoon, after office hours.\\nThis party or celebration was long overdue, not only because our company has achieved the “excellence in customer service” reward this year, but also because all of us have worked tirelessly to make this company successful. In fact, some of us have worked so hard over the past few years that we did not even take a holiday for the whole year, barring some sick leaves. So, when they saw the fruits of their labour, they naturally wanted to celebrate their success, and hence the party.\\nI believe, such a party or celebration is necessary once in a while because it would recognize the efforts and hard work of our dedicated employees which then, in turn, would motivate them to work even harder.\\nNow, we would request you to attend the party for a few minutes and say a few words on how to take our company even further ahead of its competitors. Your presence would be highly appreciated.\\nYours faithfully,\\nNeil Foster\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.77 (15 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nLetter to office manager\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
