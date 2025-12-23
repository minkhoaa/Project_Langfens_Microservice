-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:51.592660
-- Source: ielts-mentor.com
-- Title: Room In Office Can Be Used As Relaxation Room
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'Room In Office Can Be Used As Relaxation Room';

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
  E'Room In Office Can Be Used As Relaxation Room',
  E'You should spend about\n20\nminutes on this task.\nYou have noticed a room at your company office that can be used as a relaxation room. Write a letter to your manager and ask to use the room for this purpose.\nIn your letter,\nexplain why you are suggesting this\nwhich room it is\nwhat changes in the room will need to be done\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear ..................\n,',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Mr Bradley,\\nI am a junior executive in your organisation and have been working here for the last 2 years. I believe a few more recreational facilities would refresh us to produce better output and for that, we can convert a spare room into the relaxation and sports room in our office. I am hoping you would consider my idea and take steps to make it happen.\\nThe idea popped into my head when I attended a meeting at the H&G group''s head office. They have a large room for recreation and relaxation and their HR mentioned that it actually increased their employee satisfaction and overall performance. I would like to have a recreation room in our office as well. As a matter of fact, I have talked to some of my colleagues and all of them welcomed the idea.\\nThe meeting room on the third floor is no longer used and could be an ideal room for our staff to rest, socialise and enjoy their time and unlax their pressure. This room already has a large table and a few chairs. It needs a large table tennis board, a few more chairs, a sofa set and a couple of exercise machines.\\nI hope you would consider converting the room into a relaxation room and allow us to have an even better office environment.\\nYours sincerely,\\nRohan Maxim", "Dear Mr Oscar,\\nHope all is well at your end. I work in the same department as yours under your supervision. Anyway, I am writing this letter to suggest that a room, which is occasionally used as a storage facility in the western corner of our office, can be used as an additional relaxation room for our staff.\\nI am especially keen to use this room as an additional relaxation room because the room we already use for the same purpose seems to be rather small. As a result, a number of our staff is always seen to be roaming outside of our office which certainly doesn’t go well with the reputation and professionalism of our office staff.\\nOn the other hand, the unused room seems to be larger than the existing relaxation room, and all it needs is some good paint works, some nice furniture and a TV before it can be a fully functional relaxation room. We will also move the existing furniture to this room.\\nSo, if you like my suggestion, please let me know, and I would be more than happy to go ahead and turn this unused room into a nice recreational room for our valuable staff.\\nYours sincerely,\\nJoseph Emanuel\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\n1\\nRating 4.90 (10 Votes)\\nIELTS Letter Writing\\nGT Writing Task 1\\nSemi-formal Letter\\nPrev\\nNext\\nName\\nPreview\\nSend\\nReset\\nCancel\\nRSS\\nJanaka Senevirathne\\n7 years 10 months\\nDear Mr John,I have noticed an unused room in our office which I think would be a great place for our employees to relax and revive for a better performance. I would like you to permit to transform this empty office room into a recreation room. In fact, we had a relaxation room in the past but after we moved to a new workplace, the management did not dedicate a room for this purpose. In addition, our previous recreation room had some exercise equipment and many colleagues used those after the office hours. This was quite beneficial as most of us spend too much time in front of a computer and do little physical exertion. I have seen a vacant room next to the cafeteria which is left unused for quite a long. I would appreciate it if you could look at this room and convert it to a useful place for us. It would be a good idea to keep a sofa set and a large HD television with international news and sports channels. If you manage to fix some of the exercise machines, that would be excellent. I appreciate your kind consideration and look forward to hearing your positive response.Yours sincerely,Janak a Senevirathne\\nReply\\nQuote\\n×\\nReport\\nReport\\nClose"]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
