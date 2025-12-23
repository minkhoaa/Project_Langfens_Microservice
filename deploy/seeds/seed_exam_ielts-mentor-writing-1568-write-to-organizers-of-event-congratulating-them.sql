-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:55.920097
-- Source: ielts-mentor.com
-- Title: Write To Organizers Of Event Congratulating Them
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Write To Organizers Of Event Congratulating Them';

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
  E'Write To Organizers Of Event Congratulating Them',
  E'You should spend about\n20\nminutes on this task.\nAn annual event was recently held in your area. Now you want to write to the organizers of this event congratulating them on a successful production.\nWrite a letter to the organizers. In your letter,\ngive details of the event\nmention what you liked the most about the event\nmake a polite criticism of something you thought could be improved\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write your own addresses.\nBegin your letter as follows:\nDear Sir or Madam\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nI am Elizabeth Conor, a local resident of Essex, writing to congratulate you for arranging a successful community meet-up programme this year. Many other residents whom I have talked to lately, feel the same. Your organisation deserves applause from all of us.\\nTenth March is a special day for the citizens of Essex. This day witnesses the largest gathering of local residents and the vote to elect some key members of the community makes it even more significant. Arranging the morning meeting, administering the successful voting, serving lunch to everyone and then finally letting members talk about their complaints and express compliments require an exceptional team of people and their hard work. You made this programme memorable and meaningful.\\nI was quite amazed by the introduction of a software-based voting system that was instantaneous and flawless. Unlike the previous years, we did not have to wait for hours to learn the result. This was a great addition to the programme.\\nHaving said that, I would recommend some amusement facilities for children and volunteers to look after them so that parents can participate in the programme without looking over their shoulder.\\nThank you once again for a remarkable programme this year. We will remember this for many days to come.\\nYours faithfully,\\nElizabeth Conor", "Dear Sir or Madam,\\nAs a member of the Frederick community in the city of Munich, I am writing this letter to congratulate you on a very successful production of the Folk Music Festival on 27th March this year. This music festival is held every year in our area, and I am pretty sure that other members of our community also feel that you have done excellent work this time.\\nThis probably is the first time in its history that you managed to attract so many people, not only from our city but also from many other parts of our country, with your excellent advertising works. Besides, your flawless seating arrangement, top-class sound system, and the choices of music just could not be any better. However, what I really liked the most about the event was that you even allowed the audience to ask different kinds of questions to the music artists about their life and hobbies in a very friendly and casual environment.\\nOf course, you could perhaps arrange even a bigger venue with a more spacious parking area, but, again, other than that, the whole event was simply superb.\\nMany thanks once again.\\nYours faithfully,\\nMark Henry\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 3.96 (14 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nRicky\\n7 years 9 months\\nAn annual event was recently held in your area. Now you want to write to the organizers of this event congratulating them on a successful production.Write a letter to the organizers. In your letter, give - the details of the event what you most liked about the event a polite criticism of something you thought could be improvedDear Sir or Madam,I am writing this letter to congratulate you for organizing a successful annual event in our community. All of us, the community members, would be delighted and happy to invite you again to the next event.The people of Alpine heights community requested you for organizing the annual day event on 22 July 2017. We were so happy that you accepted our request even though it was a very short notice. You made all arrangements flawlessly including the sitting arrangements and music system - which was clear and audible to every single person at the event. And coming to the meal, the most sophisticated part of the event, you handled it perfectly. I probably should not mention it, but I thought it would be a good idea to share my feedback. We were little concerned about the lighting system - it could have been better if you had someone to check it while the event went on. Overall, the event went very very well.Once again many congratulations for conducting such a great event at our venue. We look forward to selecting you as our even organiser once again. Yours faithfully. Allen Brown.\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
