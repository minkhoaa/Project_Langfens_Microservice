-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:31.682718
-- Source: ielts-mentor.com
-- Title: Your Best Friend Just Had Her First Baby
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Your Best Friend Just Had Her First Baby';

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
  E'Your Best Friend Just Had Her First Baby',
  E'You should spend about\n20\nminutes on this task.\nYour best friend just had her first baby. You are currently overseas but will be returning to your hometown in a week.\nWrite to your friend. In your letter,\ncongratulate your friend\ntell her when you will be returning home\nask when you could drop in to meet her and the baby\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................\n,\nModel\nAnswer 1:\nDear Emma,\nI cannot believe I am an aunt now! You have become the mother of a sweet baby girl to make me the happiest person in the world. Many congratulations and my love and blessing for both of you.\nI regret that I am far away from you. As a matter of fact, I came to Tokyo to attend an official meeting last Monday. My tasks here will occupy me for another week or so I will return to Manhattan on 27th October. I want to see you and your baby as soon as I land. I will probably visit you first and then get back to my apartment.\nPlease do not hesitate to text or call me if you want me to bring anything for you. I will do some shopping for the baby and any suggestion from you is much welcomed.\nI cannot wait to see you both. I have not heard such thrilling news in decades. My best wished to you all once again.\nWarm wishes,\nEugene',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Jessica,\\nHope this letter finds you in great health and spirit after going through a critical but one of the most wonderful moments of your life. Well, you wanted your firstborn to be a girl, and you have indeed been blessed with a baby girl! So, many congratulations to you, and your first baby who has just arrived in this world!\\nBy the way, I am really sorry that I couldn’t be by your side to witness this wonderful but critical moment of your life since I needed to get out of town for a week to address an urgent matter in my office. Besides, I was told that you were not due until after another two weeks or so. But, whatever is the case, please know that you have always been in my prayer and you will always be.\\nAnyway, I am trying to finish my work as soon as I can and return to the city in the next couple of days, and I just can’t wait to put my eyes on your little angel. So, please let me know when it is a good time to visit you.\\nWarm wishes,\\nLinda Grace\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.50 (13 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nInformal Letter\\nPersonal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nSimmi\\n8 years\\nGT Writing Task Topic 1: Your best friend just had her first baby. You are currently overseas but will be returning to your hometown in a week.Write to your friend. In your letter: - congratulate your friend - tell her when you will be returning home - ask when you could drop in to meet her and the babyYou should write at least 150 words.Begin your letter as follows: Dear __, Letter Answer: Dear Riya,I''ve got to know the great news from your uncle who emailed me last night. I am so thrilled to hear the news that I cannot stop myself from writing a letter to you. Many many congratulations to you and the entire Singh family for a healthy baby girl as the newest member of the family. I hope you are in good health. I''m super excited to meet you both. Sadly, I have to stay here in Singapore for 5 more days as I have a project to deliver to the client in next two days. It is an urgent enhancement requirement which came up a week ago, and I couldn''t refuse it. I am travelling back to India at the end of this week. Let me know, when can I drop at your place next week to have a glimpse of the baby girl. Meanwhile, keep posting me the pictures of the darling girl. Lots of loveDelnaz.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
