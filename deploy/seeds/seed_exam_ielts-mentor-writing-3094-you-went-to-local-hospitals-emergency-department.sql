-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:46.127766
-- Source: ielts-mentor.com
-- Title: You Went To Local Hospitals Emergency Department
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Went To Local Hospitals Emergency Department';

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
  E'You Went To Local Hospitals Emergency Department',
  E'You should spend about\n20\nminutes on this task.\nYou went to the local hospital’s Emergency Department with your young child who had severe stomach pains. You had to wait for almost four hours before your daughter was treated by a doctor and, while you were waiting, you were constantly ignored by the other staff.\nWrite a letter to the Hospital Registrar, complaining about the service you received.\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nTwo days ago I took my younger daughter to your hospital due to her sudden and relentless stomach pains but was very disappointed with the service I received. When my daughter needed emergency care, she and I were continually neglected. I am hoping that you would take the necessary actions so that no other patient and their relatives suffer and feel humiliated the way we did.\\nIn relation to the specifics of the event, my daughter started complaining about a severe stomachache at around 2:30 pm on 24th June. After waiting for a couple of hours her condition worsened and I rushed to the hospital. I took her to the emergency department at your hospital and due to the negligence of the staff, I had to wait more than 4 hours before a doctor saw and treated her. Though the workers were gossiping, every time I requested them to call a doctor, they told me that they were busy. The type of service I was offered is an example of cruelty and no parent of an ill child deserves it. I have been constantly ignored when my child was crying in pain.\\nThis sort of staff in the emergency department of a hospital is not suitable at all. I request you to take this matter sincerely and try to take the required actions against those who are responsible.\\nI hope to get a reply from you regarding the action you have taken.\\nYours faithfully,\\nRebecca Smith", "Dear Sir or Madam,\\nI am writing to express my utter dissatisfaction with your hospital''s emergency service that I experienced last Monday when I took my six-year-old daughter to your hospital. I am hoping you will take this complaint seriously and take the necessary actions.\\nOn Monday evening, my daughter Angela, all of a sudden, complained about stomach pain, and it got severe every passing minute. In an hour, I rushed to your hospital''s emergency department expecting speedy treatment for my daughter. But on the contrary, I faced harsh negligence from the hospital staff.\\nAs my daughter''s condition was deteriorating and she was crying relentlessly, I requested them to make an urgent appointment with a doctor. But, after waiting for four long hours, a doctor treated her. He told me that it was a serious case of food poisoning and that my daughter needed urgent treatment as it could have been fatal. He immediately admitted her to the hospital. I was terrified after hearing it from the doctor. I continuously pleaded with the staff for an urgent appointment, but they completely ignored my request.\\nThis sort of negligence will hurt your hospital''s reputation and set bad examples. I request you to take this matter sincerely and try to improve your emergency department''s service as the term emergency does not suit it currently.\\nI hope to get a reply soon regarding the action you are likely to take.\\nYours faithfully,\\nJohn Louis\\n[Penned by - Sabrina Qamar]\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 5.00 (7 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
