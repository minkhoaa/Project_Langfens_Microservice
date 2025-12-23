-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:46:34.347886
-- Source: ielts-mentor.com
-- Title: A Real Estate Company Is Going To Build A Shopping Centre
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'A Real Estate Company Is Going To Build A Shopping Centre';

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
  E'A Real Estate Company Is Going To Build A Shopping Centre',
  E'You should spend about\n20\nminutes on this task.\nYou have learned from a news article that a real estate company is going to build a shopping centre near your home. However, you think that the shopping centre should not be built there.\nWrite a letter to the city counsellor. In your letter,\nsay how you have learned about the plan\nexplain how it is going to negatively affect the residential area where you live\nsay what you think the city council should do about it\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am a resident of Woodley in Berkshire, and I have decided to write this letter after reading a recent news article about the plan to build a shopping centre in our residential area. Needless to say, we do not really like this idea, and I hope that you would take the necessary initiatives to halt this project which would otherwise disrupt the peaceful lives of the residents.\\nOur residential area is already over-populated, with not enough streets and parking spaces. Of course, the shopping centre will have its own parking spaces, but sometimes, those parking spaces just might not be enough to accommodate all the cars. And if that is the case, the mall visitors most likely would park their cars in our streets and parking spaces, making our streets even more crowded. The commotions, businesses and people would make our peaceful residential area worse to live in.\\nAnother problem is that our residential area has a sizable, college and university-going, young population who, most likely, would start wasting their time in the shopping centre in the name of socializing and having fun, instead of focusing on their studies.\\nThese are just some of the possible negative effects, but they should be good enough to convince you to relocate this shopping centre to a commercial area, away from any residential areas.\\nThank you in advance.\\nYours faithfully,\\nKeith Marshall\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.05 (21 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
