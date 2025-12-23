-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:04.733512
-- Source: ielts-mentor.com
-- Title: You Are Studying A Short Course In Another Country
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Are Studying A Short Course In Another Country';

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
  E'You Are Studying A Short Course In Another Country',
  E'You should spend about\n20\nminutes on this task.\nYou are studying a short course in another country. Your accommodation was arranged by the course provider. But there is a major problem with the accommodation.\nWrite a letter to the course provider. In your letter,\nsay what the problem is\ndescribe the accommodation you thought you were getting\nask the provider to solve the problem\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am Graham Neelam, a participant in the Effective Recruiting Management Course that your university has organised. I am writing this letter to you to complain about some inconveniences that I am facing with the room that I was allotted to stay in during my course.\\nBefore I joined the course, I applied for single-room accommodation in writing. I also mentioned that I would prefer to stay near the university, not far away from it. Unfortunately, I was given a shared room that I have been sharing with another student for the last couple of weeks. Moreover, it is at least 35 minutes walking distance from the building where our classes are conducted.\\nThe room is not large enough to support the healthy living of two persons, and its ventilation system is dreadful. Fresh air and sunlight can hardly get in. The room is crowded with two beds, two desks, and it does not have adequate space. On top of that, my roommate has frequent visitors who often stay overnight. It interrupts my studies and privacy.\\nI thought I was getting a single room with enough sunlight and airflow and which would not be far away from the campus. Instead, a shared accommodation was arranged for me that has a poor ventilation system. So I would highly appreciate it if you could arrange for me a single and large room that has a proper ventilation system and enough airflow. The room I need should be conducive to healthy living and serious study.\\nI look forward to getting your support regarding this matter. Thank you in advance.\\nYours faithfully,\\nGraham Neelam\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.39 (19 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nFormal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nTanimu Ubah Sulaiman\\n3 years 9 months\\nThanks for your immediate response, sir. I am so happy.\\nReply\\nQuote\\nTanvi\\n4 years 4 months\\nDear Sir or Madam,\\nI am writing this letter to express my discontent about the allotment of the accommodation where I am currently staying at. The services provided do not even fulfil the basic requirements. Apart from that, the place is located near a train station, which is not at all a healthy and suitable atmosphere to pay attention to my studies.\\nI believed that my stay would be comfortable and peaceful where I would be able to pay more attention to my studies. But it is not! Furthermore, there is no adequate parking space for my personal vehicle, therefore I am struggling a lot with this parking issue.\\nI am requesting you to kindly resolve this matter as soon as possible as I have my assessment tests around the corner.\\nWaiting for your response.\\nYours faithfully,\\nCathy Brown\\nReply\\nQuote\\nAksat Parekh\\n4 years 7 months\\nDear Sir or Madam,\\nI am writing this letter to express my dissatisfaction with the allocated accommodation where I currently stay. Although I am here for just a three-month course, my difficulties are severe and intolerable.\\nTo begin with, I am a vegan, and this residential building is located beside a non-vegetarian market. Initially, the stink from the market made me feel embarrassed, but now I am suffering from acute headaches round the clock.\\nAlthough the stay is within the three-kilometre periphery of my institute, which is fine, I can''t live here anymore due to the problems that I have been facing. I assumed that my stay would be in a comfortable place which would also permit me to pursue my hobbies in my leisure time, but it is not. Furthermore, the market has a narrow road, and it''s quite challenging for me to drive through to attend lectures daily.\\nI request you to switch my boarding facility to somewhere else. I do not have any problem even if I need to share a room with a vegetarian friend.\\nYours faithfully,\\nAksat Parekh\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
