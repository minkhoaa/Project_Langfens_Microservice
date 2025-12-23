-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:32.493158
-- Source: ielts-mentor.com
-- Title: Local Government Is Planning To Change Bus Timetable
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Local Government Is Planning To Change Bus Timetable';

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
  E'Local Government Is Planning To Change Bus Timetable',
  E'You should spend about\n20\nminutes on this task.\nThe local government is planning to change the bus timetable. You are not happy about the proposed changes. You have decided to write about it to the editor of a local newspaper.\nWrite a letter to the newspaper. In the letter,\ndescribe the changes\nexplain how that will affect you\nsay how you would like the service to be improved\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am a local resident of Bexley, London writing to express my concerns regarding the suggested changes in the bus timetable by the local government. I hope you would publish an editorial regarding the inconveniences these changes are going to cause to the local people.\\nIn relation to the proposed changes, the authority is planning to reduce the frequency of the bus on routes 25 and 28. The current frequency of the bus is every 20 minutes, however, the local administration plans to cut down the frequency to a bus to one in an hour. Moreover, the first bus will depart at 7.00 am rather than 6.00 am.\\nAs you can understand, such drastic changes to the schedule will adversely affect the commuters. Currently, I have to report to work at 7:00 am, therefore, I board the bus that arrives at 6.00 am. If the current timetable were to change, I will face great difficulties in getting to work on time.\\nIn my opinion, the bus frequency needs to be increased rather than decreased, so that the travellers who have to leave for work before sunrise can be accommodated in a better way. Further, I would suggest that the transport authority should also consider replacing the older buses to improve the overall travel experience.\\nI hope you will publish my concerns in your newspaper so that people can express their opinion on this and the proposed changes are reconsidered.\\nYours faithfully,\\nMuhammad Sameed", "Dear Sir or Madam,\\nI am a regular reader of your newspaper, and I also like how you and your newspaper take bold efforts to bring out many issues into the light, which our hometown faces from time to time. And I am writing this letter to you in order to express my dissatisfaction over a local government''s proposal to change the existing bus timetable.\\nIn fact, such changes in bus schedule would severely affect me personally as well as many others like me since we will not be able to catch our buses on time in order to arrive at our work. By the way, before the schedule changes, I could catch my bus at 8:00 am, but the same bus would pass by my house at 9:00 am now. Besides, according to the new bus timetable, I and many people in my community would not be able to commute to other places in any buses since they now stop at some other bus stoppages, which are quite far away from our neighbourhood.\\nSo, I would like to request to the local government through your newspaper not to change the bus schedule while actually improving the service by having more frequent bus services and comfortable seats.\\nYours faithfully,\\nPeter Cox\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.06 (9 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nComplaints-letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
