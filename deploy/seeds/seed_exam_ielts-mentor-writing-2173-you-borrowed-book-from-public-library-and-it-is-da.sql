-- ============================================
-- IELTS Writing Task 1 Data Import (writing-service)
-- Generated: 2025-12-23T15:48:18.045594
-- Source: ielts-mentor.com
-- Title: You Borrowed Book From Public Library And It Is Damaged
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data with same title
DELETE FROM "writing_exams" WHERE "Title" = E'You Borrowed Book From Public Library And It Is Damaged';

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
  E'You Borrowed Book From Public Library And It Is Damaged',
  E'You should spend about\n20\nminutes on this task.\nYou borrowed a book from a public library and the book is now damaged.\nWrite a letter to the librarian to explain the situation. In your letter, mention:\ndetails about the book\nhow it was damaged\nwhat you want to do about it\nYou should write at least\n150\nwords.\nYou do\nNOT\nneed to write any addresses.\nBegin your letter as follows:\nDear Sir or Madam,\nSample Answer 1:\nDear Sir or Madam,\nTwo weeks ago I borrowed a book from your library. I was excited to have read the book but very disappointed to recently find that it was damaged. I am hoping you will allow me to purchase a new book of the same title as compensation.\nIn relation to the specifics of the book, I borrowed ''Nineteen Eighty-Four'' a novel by George Orwell, on 17th July from your library using my library card BM-450124. I have been thoroughly enjoying the book and almost finished it until it got damaged.\nUnfortunately, On 25th July, three days before the due date to return the novel, I found that it was ruined due to the pouring rain that somehow reached my table placed near the window. I put the book on the table and had been outside the whole time it rained. All of the books on the table absorbed rainwater and the book I borrowed from the library is now unreadable due to the damage the water caused to it.\nAs a solution, and because I really want to express my apology for the incident, I seek your permission to purchase a new book with the same title for the library. I am also hoping that you would not impose any penalty for the incident.\nThank you in advance and I hope to hear your reply soon.\nYours faithfully,\nErica Jong',
  1,
  'B2',
  'ielts,letter,task1,gt',
  E'["Dear Sir or Madam,\\nTwo weeks ago I borrowed a book from your library. I was excited to have read the book but very disappointed to recently find that it was damaged. I am hoping you will allow me to purchase a new book of the same title as compensation.\\nIn relation to the specifics of the book, I borrowed ''Nineteen Eighty-Four'' a novel by George Orwell, on 17th July from your library using my library card BM-450124. I have been thoroughly enjoying the book and almost finished it until it got damaged.\\nUnfortunately, On 25th July, three days before the due date to return the novel, I found that it was ruined due to the pouring rain that somehow reached my table placed near the window. I put the book on the table and had been outside the whole time it rained. All of the books on the table absorbed rainwater and the book I borrowed from the library is now unreadable due to the damage the water caused to it.\\nAs a solution, and because I really want to express my apology for the incident, I seek your permission to purchase a new book with the same title for the library. I am also hoping that you would not impose any penalty for the incident.\\nThank you in advance and I hope to hear your reply soon.\\nYours faithfully,\\nErica Jong", "Dear Sir or Madam,\\nI am a member of your library- The Graham Public Library and have been enjoying my membership for the past three years. I would like to explain why I have been unable to return a book I borrowed two weeks ago. I am hoping that you would allow me to purchase a new book of the same title and do not impose any fine on my membership.\\nI am Shirley Beth and my library membership number is CA-GP 125401. I borrowed the book ''The Watsons'' - a novel by Jane Austen, on 24th July and the deadline to return the book was on 2nd August. Unfortunately, on 1st August, I found that the cover page of the book was gone and pages 10 to 24 were missing! It''s hard to read the rest of this book since there are tonnes of scratches on it. Off the top of my head, my dog damaged the book when I was out to attend a party with a few college friends.\\nI guess I forgot to feed my dog when I hurried out to attend a party. He was too hungry that thought the book was something he can eat. I must confess it was a mistake I should have been more careful about it.\\nI cannot deny that I should be responsible for the book of indemnity. However, as an old member and a regular visitor to your library, I would request you to allow me to compensate for that by purchasing the same book within the next week. I would also request you not to impose any late fee or penalty for the incident.\\nI am looking forward to hearing from you soon.\\nYours faithfully,\\nShirley Beth\\n["]'::jsonb,
  now(),
  '00000000-0000-0000-0000-000000000000'
);

COMMIT;
