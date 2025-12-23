-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:47:32.807076
-- Source: ielts-mentor.com
-- Title: You Have Recently Started Work In A New Company
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Have Recently Started Work In A New Company';

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
  E'You Have Recently Started Work In A New Company',
  E'You should spend about\n20\nminutes on this task.\nYou have recently started work in a new company.\nWrite a letter to an English-speaking friend.\nIn your letter,\nexplain why you changed jobs\ndescribe your new job\ntell him/her your other news\nWrite at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear ...............,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Richard,\\nI hope you''re doing great. I wanted to share some exciting news with you - I have recently started a new job, and I''m really enjoying the change.\\nThe main reason I decided to switch my last job was for better career growth and work-life balance. My previous role was becoming quite monotonous, and the long hours left me with little personal time. When I came across this opportunity, I knew it was the right step forward.\\nIn relation to my new job, I have joined \\"Hanson''s IT Ltd.\\" as a Project Manager. My responsibilities include managing projects, working with clients, and developing software. The work environment is fantastic, and my colleagues are very supportive. What I particularly love is the flexibility and opportunities for professional development.\\nBeyond work, I''ve also moved to a new apartment closer to the office, making my daily commute much easier. Let’s catch up soon. I’d love to hear your news as well!\\nWarm wishes,\\nAshique", "Dear Angela,\\nI hope you and your family are doing fine, and I’m sorry I haven’t been in touch with you recently. I’m writing to let you know that I''ve resigned from my previous company and took a new job recently.\\nDo you remember that I was working for a consultancy firm, and I told you how much I was looking forward to changing my job? Well, I''ve joined a travel agency last month, and the new job is exciting. In my previous job, I was working really long hours and, to be honest, the pay wasn’t great. So basically I applied for a job at a new company that was looking for people enthusiastic about taking on challenges and are interested in travelling. I thought it is a good fit for my expectation and took the opportunity.\\nI was a bit nervous in the interview, but in the end, I got the job as a senior travel consultant. The remuneration in the new job is better, the working conditions are great and I don’t have to work long hours anymore. Besides, they offer performance bonuses, and I would be able to travel to different places and explore many places!\\nI''ve also enrolled in a diploma course at the University of Edinburgh and started a new travel blog. My parents have come to meet me this week, and I''ve plans to take them to show them around.\\nTake care.\\nWith love,\\nEmma", "Dear James,\\nI hope this letter finds you and your family well. I''m sorry that I couldn''t write to you for the last couple of months. I''m writing to let you know that I''ve recently changed my job, and I love the new job.\\nAs you know, I had been working for over a decade in the field of strategic planning for an after-sale automotive company. Unfortunately, my office shifted to another city last January. Afterwards, travelling to and from the office became quite tough due to the distance and notorious traffic congestion. I often had to spend more than 4 hours commuting, and I had barely any time for my family. Thus, I was forced to change my job.\\nI took a job with another company in the same industry, and so far I love my job. It has better remuneration, a more suitable environment and friendly management. I hardly need 20 minutes to reach the office. Moreover, my new duties, which include managing a support team of 18 employees, is something I enjoy a lot becasue the team members are very pleasant and talented.\\nBy the way, I almost forgot, my wife would be travelling to Canada to attend a seminar and she asked me to invite you to a family party next month. Please come and let''s enjoy our time together with fun and laughter.\\nTake care.\\nWarm wishes,\\nBehzad\\n[ by - Behzad Alibabaei ]\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.58 (18 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nletter to a friend\\nLetter Writing Sample\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
