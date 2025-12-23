-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:12.622322
-- Source: ielts-mentor.com
-- Title: Write A Letter To The Manager Of The Museum
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write A Letter To The Manager Of The Museum';

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
  E'Write A Letter To The Manager Of The Museum',
  E'You should spend about\n20\nminutes on this task.\nYou took an elderly member of your family, who was not able to walk properly, to a museum and he/she faced a few problems.\nWrite a letter to the manager of the museum. In your letter,\nsay why you visited the museum\ndescribe the problems you faced\nsuggest what can be done to avoid those problems\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI have recently visited your museum with my elderly aunt who is about 80 years old, and the main purpose of the visit was to see some of the rare artefacts from medieval Europe. Besides, we visited the museum also because my aunt wanted to see the wartime uniform from the 2nd World War. By the way, seeing those wartime uniforms was especially important for my aunt because it is in those uniforms that she saw her father for the last time before his death on the battlefield.\\nAnyway, while everything was great at your museum, my elderly aunt had some problems moving around your museum on foot because of its rather large size. After all, she is about 80 years old and can not walk properly. Besides, the steps in the stairs that visitors use to see the items that were stacked up high above the ground were a bit too steep for my elderly aunt to walk.\\nSo, to deal with these movement issues, providing wheelchairs and a separate wooden staircase that is not too steep for the elderly people would go a long way to help elderly people like my aunt.\\nThank you in advance.\\nYours faithfully,\\nJamie Goldsmith\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.81 (8 Votes)\\nIELTS Letter Writing\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nTrishan Chatterjee\\n2 years 7 months\\nThank you.\\nReply\\nQuote\\nVijay Kumar\\n3 years 11 months\\nSuper but the letter should be short.\\nReply\\nQuote\\nSabrina Qamar\\n4 years 11 months\\nDear Sir or Madam,\\nI am writing this letter to express my dissatisfaction regarding the facilities for the elderly in your museum. I hope you would address the issues and make it more elderly-friendly.\\nLast Saturday I visited your museum with my family, including my mother and children. We all were excited to spend our weekend learning about the history and culture of our country. But as soon as reached the Museum, I found there was no ramp provided for the wheelchair visitors. My mother is in her 80s who needs in a wheelchair to move. Furthermore, upon reaching inside, a lady at the reception told us that we could not take the wheelchair in the main hall due to safety reasons. It was utterly disappointing and frustrating. There was no option left for us but to return home immediately! We already paid for the tickets and that could not be refunded as well.\\nBased on my experience at your museum, I would like to suggest you, provide a ramp at the entrance for the wheelchair visitors and please allow wheelchairs at the main building as it too large and it is difficult for elderly people to walk around and learn about the artefacts at your museum.\\nI hope you will take notice of these issues I am bringing to you and take initiatives to improve the experience of visitors to your museum.\\nYours faithfully,\\nJohn Mark\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
