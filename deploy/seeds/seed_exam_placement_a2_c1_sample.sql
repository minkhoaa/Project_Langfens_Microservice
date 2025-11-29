BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'english-placement-a2-c1-sample-01'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'english-placement-a2-c1-sample-01';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'english-placement-a2-c1-sample-01';
DELETE FROM exams WHERE "Slug" = 'english-placement-a2-c1-sample-01';

-- Insert placement exam
INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
VALUES ('c69a3e54-a7f1-40eb-ab69-1f50ca798267', 'english-placement-a2-c1-sample-01', 'English Placement Test A2–C1 – Sample 01', '## English Placement Test (A2–C1)

This exam is designed to help estimate a learner''s level on the CEFR scale from **A2 to C1**.

**Sections**
1. Reading – 15 multiple-choice questions  
2. Listening – 8 multiple-choice questions  
3. Writing – 1 short essay task (optional)

Difficulty increases gradually so you can separate lower-level and higher-level learners.', 'PLACEMENT', 'B1', 'DRAFT', 60, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7fb25cae-8211-4baa-a93c-e14ec55160e7', 'c69a3e54-a7f1-40eb-ab69-1f50ca798267', 1, 'Reading – Multiple Choice', 'Read the texts and choose the best answer **A, B, C or D**.
The questions become more difficult as you progress. Try to answer all 15 questions.', NULL, NULL);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e781d97a-2e93-4268-9961-1d8c5ca8bc30', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 1, '### Question 1
You see this notice at your school:

> Library closed on Friday for maintenance.

Why is the library closed?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f99378b3-4e7f-4a4f-81e2-90c7df62eab0', 'e781d97a-2e93-4268-9961-1d8c5ca8bc30', 1, 'Because of an exam', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d88c25e-6fb2-407b-9797-b0030673d719', 'e781d97a-2e93-4268-9961-1d8c5ca8bc30', 2, 'For cleaning and repairs', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87ca33cc-d969-4c9f-b667-1c34b3c3f491', 'e781d97a-2e93-4268-9961-1d8c5ca8bc30', 3, 'For a school party', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52c8c8b0-bbdd-447d-a868-e58ae8993741', 'e781d97a-2e93-4268-9961-1d8c5ca8bc30', 4, 'Because it is a holiday', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('27a35c33-9de6-4e0e-83b7-df156760d719', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 1, '### Question 2
You receive this text message from a friend:

> I''m stuck in traffic. I''ll be 20 minutes late for the movie.

What does your friend mean?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbd6413f-5e04-4097-914b-6bdfdb8f55af', '27a35c33-9de6-4e0e-83b7-df156760d719', 1, 'The movie is cancelled.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be8bd1de-f33c-4289-aec8-74113f8e1d59', '27a35c33-9de6-4e0e-83b7-df156760d719', 2, 'They will arrive earlier than planned.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c07d5e6-3027-4bcf-8a17-bde83f9ff0f0', '27a35c33-9de6-4e0e-83b7-df156760d719', 3, 'They will not come to the cinema.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9c8ca6b-314b-4d79-a4e3-20addb34b1dc', '27a35c33-9de6-4e0e-83b7-df156760d719', 4, 'They will arrive later than planned.', true);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1f49473-49e1-4fcb-937c-f9ab8a5b364f', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 1, '### Question 3
You read this sign in a hotel:

> Please leave your key at reception when you go out.

What should guests do?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72a8881b-ca9a-4e3e-9f8a-4dd147a074a0', 'e1f49473-49e1-4fcb-937c-f9ab8a5b364f', 1, 'Keep the key with them all day.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('590ee1d6-71c1-45f4-9ae5-975ef96a8cc8', 'e1f49473-49e1-4fcb-937c-f9ab8a5b364f', 2, 'Give the key to reception when they leave the hotel.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f19b26ab-3d82-48c6-8f2d-547e51b34457', 'e1f49473-49e1-4fcb-937c-f9ab8a5b364f', 3, 'Give the key to another guest.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ac228e5-870c-4614-86b8-aee29a193b1c', 'e1f49473-49e1-4fcb-937c-f9ab8a5b364f', 4, 'Leave the key in their room.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f0bc525f-76ed-4141-9071-21005b38855c', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 1, '### Question 4
You see this message on a website:

> Free delivery on all orders over $50.

What does this mean?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9353ceae-15e7-4e7a-bbfa-a43f3c2da4a2', 'f0bc525f-76ed-4141-9071-21005b38855c', 1, 'You never pay for delivery.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af64de4a-98bd-4a35-a209-7bf9878df877', 'f0bc525f-76ed-4141-9071-21005b38855c', 2, 'Delivery is free if you spend more than $50.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4f1d630-4d34-486c-ba44-2f85a6ab151f', 'f0bc525f-76ed-4141-9071-21005b38855c', 3, 'You must pay $50 for delivery.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f43bbd9-a3a9-4c98-a000-eb0d6ef3528f', 'f0bc525f-76ed-4141-9071-21005b38855c', 4, 'Delivery costs $50 for all orders.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('355c57e7-3f38-4947-aa21-e5eaad8a4d67', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, '### Question 5
You read a short review of a mobile app:

> The app is easy to use and helps me track my daily exercise. The free version is enough for most people, but the paid version gives more detailed statistics.

What is the writer''s opinion of the app?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfb5e318-981e-4ab1-9b1b-094dddee722e', '355c57e7-3f38-4947-aa21-e5eaad8a4d67', 1, 'It is too expensive.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90d575c2-3468-4666-815c-56bcda371ff0', '355c57e7-3f38-4947-aa21-e5eaad8a4d67', 2, 'It is useful for following exercise habits.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('706fd7ce-17a2-480c-8081-334930779a2c', '355c57e7-3f38-4947-aa21-e5eaad8a4d67', 3, 'It is difficult to understand.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3fce457-136f-4767-8c54-d80fe1fc6a11', '355c57e7-3f38-4947-aa21-e5eaad8a4d67', 4, 'It is only good if you pay for it.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7c5343b4-dc7e-4e9c-9f24-c10597931551', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, '### Question 6
You read part of an email from a colleague:

> I won''t be in the office on Thursday. If the client calls, please tell her I''ll reply to her email as soon as I get back.

What does the writer ask you to do?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c226045-062a-4d6b-a3f0-8b7521d64838', '7c5343b4-dc7e-4e9c-9f24-c10597931551', 1, 'Call the client on Thursday.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d795ef3-1a7a-4768-aeb7-7fa7d7a9f505', '7c5343b4-dc7e-4e9c-9f24-c10597931551', 2, 'Answer the client''s questions yourself.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b7c6d92-d65e-4e1b-bc74-f24b35b4f28e', '7c5343b4-dc7e-4e9c-9f24-c10597931551', 3, 'Explain to the client that the writer will answer later.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29bf05f7-793f-44bf-bc7f-3e3f50372985', '7c5343b4-dc7e-4e9c-9f24-c10597931551', 4, 'Tell the client not to send emails.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5929ff9-7bf8-4b3f-9b18-6e61434117e5', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, '### Question 7
You read this information on a museum website:

> Tickets are cheaper if you book online at least 24 hours before your visit.

How can you pay less for your ticket?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7773b4be-5a0e-4474-9f0a-a79dbd95057c', 'a5929ff9-7bf8-4b3f-9b18-6e61434117e5', 1, 'Buy your ticket at the museum entrance.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02b74df2-692c-4ba8-9c38-f1204b1b3105', 'a5929ff9-7bf8-4b3f-9b18-6e61434117e5', 2, 'Book your ticket one day before you go.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25ac221d-5379-4558-acc3-11ae0dfdcc43', 'a5929ff9-7bf8-4b3f-9b18-6e61434117e5', 3, 'Book your ticket on the same day online.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6dffc5d3-413b-4550-b5ea-cedd546047fa', 'a5929ff9-7bf8-4b3f-9b18-6e61434117e5', 4, 'Visit the museum after 6 p.m.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5002728b-8c6d-4eb2-aa21-81a4086ee130', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, '### Question 8
You read this notice in an office:

> Please do not print large documents after 5 p.m. The printer is needed for daily reports.

Why is this notice there?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('543362c5-7396-4f34-ba97-d99a744e7651', '5002728b-8c6d-4eb2-aa21-81a4086ee130', 1, 'The printer is broken after 5 p.m.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c08a615a-1fc8-4ca0-a463-c021fef4f1bb', '5002728b-8c6d-4eb2-aa21-81a4086ee130', 2, 'People should use another printer.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e326d135-9f35-43ac-a3f4-ae5da5f158f1', '5002728b-8c6d-4eb2-aa21-81a4086ee130', 3, 'Reports are printed in the morning.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85b1f369-3645-470f-8caa-4c99630d29d0', '5002728b-8c6d-4eb2-aa21-81a4086ee130', 4, 'Printing big files late can cause problems for reports.', true);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e77ae559-60bf-42a3-bf1b-c21c1661608c', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, '### Question 9
You read part of an article about sleep:

> Many adults sleep less than seven hours a night. In the short term they may feel productive, but over time, lack of sleep can reduce concentration and increase stress levels.

What is the main point of the article?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74edf8cb-c151-4b80-87ae-460a5dc042da', 'e77ae559-60bf-42a3-bf1b-c21c1661608c', 1, 'Sleeping less always makes people more productive.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab472037-d544-4d5c-8a5b-5f7ddc26b237', 'e77ae559-60bf-42a3-bf1b-c21c1661608c', 2, 'Short sleep can seem fine, but it has negative effects later.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7b8bbc7-5da8-491b-a63f-7a42ee01ba07', 'e77ae559-60bf-42a3-bf1b-c21c1661608c', 3, 'Adults should never sleep more than seven hours.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07751602-5f14-4a47-898f-a98b9c156814', 'e77ae559-60bf-42a3-bf1b-c21c1661608c', 4, 'Stress is not connected to sleep.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5b24bdf9-241d-4e9f-8ee5-3b65a2ad02a3', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, '### Question 10
You read a message from your manager:

> The deadline for the marketing report has been moved forward to Monday. This means we have two fewer days, so please focus only on the most important data.

What does the manager want the team to do?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f4d048f-5ccd-432d-813a-308cd1d62e06', '5b24bdf9-241d-4e9f-8ee5-3b65a2ad02a3', 1, 'Add more information to the report.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('470720b3-17d1-4936-aeca-3e47ddbd314f', '5b24bdf9-241d-4e9f-8ee5-3b65a2ad02a3', 2, 'Finish the report earlier and include only key data.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c731da1a-ae51-489f-9a51-10dd30af3dbd', '5b24bdf9-241d-4e9f-8ee5-3b65a2ad02a3', 3, 'Delay the report until Wednesday.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c9394a3-f625-4f2d-8572-ca11fcefcbad', '5b24bdf9-241d-4e9f-8ee5-3b65a2ad02a3', 4, 'Cancel the marketing report.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('73c59e05-b6a4-4d5a-93a1-3ef9f1db16c9', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, '### Question 11
You read a short blog post:

> When I started working from home, I thought I would have more free time. Instead, my workday became longer, because I answered emails late at night and checked messages during lunch.

What problem does the writer describe?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5fb8b69-635c-4f47-8980-89032afc342d', '73c59e05-b6a4-4d5a-93a1-3ef9f1db16c9', 1, 'They cannot connect to the internet.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bc3fcf8-4e2b-4af9-9967-29a697c2f0eb', '73c59e05-b6a4-4d5a-93a1-3ef9f1db16c9', 2, 'They do not like their colleagues.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1be7d34-786f-4cb3-8272-61d85f542d8d', '73c59e05-b6a4-4d5a-93a1-3ef9f1db16c9', 3, 'Worktime and free time are no longer separated.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f48eb4c-734d-42b7-b4e1-b1b3003d2d63', '73c59e05-b6a4-4d5a-93a1-3ef9f1db16c9', 4, 'They earn less money than before.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('11446642-d245-4e1a-9d4d-1fbd35640542', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, '### Question 12
You read this comment on a product website:

> The headphones are comfortable and the sound quality is excellent. However, the battery life is disappointing; I have to charge them every few hours.

What is the writer''s opinion?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b3a5406-8141-4754-b2f1-16c7d4ebb85c', '11446642-d245-4e1a-9d4d-1fbd35640542', 1, 'The headphones are perfect.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc3c77e8-d210-4d1e-933b-171a92774fad', '11446642-d245-4e1a-9d4d-1fbd35640542', 2, 'The sound is bad but the battery is good.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a9feca6-a54a-4b8c-83a6-b932a30a58e4', '11446642-d245-4e1a-9d4d-1fbd35640542', 3, 'The headphones have good sound but weak battery life.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fd84121-65b9-4b55-b0ce-c7f9026b872c', '11446642-d245-4e1a-9d4d-1fbd35640542', 4, 'The headphones are too heavy.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('02cbfb9a-7d56-4efd-9922-e84144bc4933', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, '### Question 13
You read part of a report about remote work:

> Companies that allow flexible working hours often see higher employee satisfaction. Yet, without clear expectations, flexibility can lead to confusion about when colleagues are available, which may slow down decision-making.

What is the writer suggesting?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('972d8ea0-3191-4a6b-af3d-2981df5d2655', '02cbfb9a-7d56-4efd-9922-e84144bc4933', 1, 'Flexible hours are always a bad idea.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d5c46a0-2934-4cb4-9b82-20189064b552', '02cbfb9a-7d56-4efd-9922-e84144bc4933', 2, 'Flexible hours can be positive but require clear rules.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3fa17cd-be03-4b53-a5e8-b77fc44fb910', '02cbfb9a-7d56-4efd-9922-e84144bc4933', 3, 'Employees should never work from home.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fe3a54d-1e8d-4a0d-a970-cbb0976f2136', '02cbfb9a-7d56-4efd-9922-e84144bc4933', 4, 'Decisions are faster when people work at night.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7968560f-38ca-4ec7-8ad2-b5a81ea2b9d4', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, '### Question 14
You read this paragraph in a magazine:

> For many city residents, owning a car once symbolised success. Today, however, a growing number of young professionals prefer sharing services and public transport. They value experiences over possessions, and see constant car expenses as a limitation rather than a sign of status.

What trend does the writer describe?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('348d4c55-84c2-4b98-98cd-ce9ecbcda809', '7968560f-38ca-4ec7-8ad2-b5a81ea2b9d4', 1, 'Young people do not know how to drive.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('615a0721-e89f-4ac0-b3b1-ec3eb26e1f9e', '7968560f-38ca-4ec7-8ad2-b5a81ea2b9d4', 2, 'Cars are becoming cheaper for young professionals.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c9f587a-bbde-4069-9e3f-89ed9eca5a40', '7968560f-38ca-4ec7-8ad2-b5a81ea2b9d4', 3, 'More young people see car ownership as less attractive than in the past.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2bd7457-4bd0-4e5d-9f1a-82f2eda0d81d', '7968560f-38ca-4ec7-8ad2-b5a81ea2b9d4', 4, 'Public transport is more dangerous than cars.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9720f702-8261-40a2-880c-21c512b85ac5', '7fb25cae-8211-4baa-a93c-e14ec55160e7', 15, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, '### Question 15
You read an online comment about study habits:

> Doing several things at the same time feels efficient, but research shows that frequent switching between tasks makes it harder to remember information. Deep concentration on a single task, even for a short period, is usually more productive.

What advice would the writer probably give?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e4169f9-54f4-42fd-bf0b-29282f35104f', '9720f702-8261-40a2-880c-21c512b85ac5', 1, 'Try to focus on one task instead of multitasking.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b7bf445-8bbe-4f9b-81ab-a08de62099e9', '9720f702-8261-40a2-880c-21c512b85ac5', 2, 'Change tasks often so you don''t get bored.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aad9773c-78b2-4ff5-9e5b-4fd88e44f6b5', '9720f702-8261-40a2-880c-21c512b85ac5', 3, 'Avoid deep concentration because it is stressful.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('def6f9b1-32f4-4941-a4c5-f96c59b26ced', '9720f702-8261-40a2-880c-21c512b85ac5', 4, 'Do not study for more than ten minutes.', false);

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3a7d0a01-5bf7-4d86-8faa-d1e7864fd86d', 'c69a3e54-a7f1-40eb-ab69-1f50ca798267', 2, 'Listening – Multiple Choice', 'You will listen to a short conversation about choosing an online English course.
Answer questions 1–8. For each question, choose the best answer **A, B, C or D**.
You can read the questions before listening.', 'https://cdn.langfens.dev/audio/sample-placement-listening-01.mp3', 'Advisor: Good morning, LanguageHub support, this is Maria. How can I help you?
Student: Hi, I''m interested in your online English course. I work full-time, so I need something flexible.
Advisor: Sure. Our standard course has three video lessons per week. Each video is about ten minutes long, and you can watch them whenever you like.
Student: That sounds good. How long does the whole course last?
Advisor: It''s a twelve-week programme. Most students study around four to five hours per week.
Student: Okay. And what level is it? I''m somewhere between B1 and B2, I think.
Advisor: We recommend the upper-intermediate group for you. It focuses on speaking in meetings and writing emails.
Student: Great. Do I have to pay the full fee at once?
Advisor: No, you can pay monthly. There''s also a discount if you pay for the whole course in advance.
Student: Last question: will I have a teacher I can ask questions?
Advisor: Yes. You''ll have a small group class on Zoom every Thursday evening, and you can message your teacher through the app.');
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5cf4f347-5f6a-4f77-8ef1-6bd243a1c029', '3a7d0a01-5bf7-4d86-8faa-d1e7864fd86d', 1, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 1, '### Question 1
Why does the student call LanguageHub?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e241b5ed-0e6c-45b0-94fa-b70b580d74fb', '5cf4f347-5f6a-4f77-8ef1-6bd243a1c029', 1, 'To ask about an online English course', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e78dca2f-fdf9-4da5-9b61-92a7817ece91', '5cf4f347-5f6a-4f77-8ef1-6bd243a1c029', 2, 'To complain about a late payment', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de546063-5b9f-4ac2-8cff-66865c3c6404', '5cf4f347-5f6a-4f77-8ef1-6bd243a1c029', 3, 'To cancel a face-to-face class', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a772c09-18ba-4519-99fd-66b46c0b5fc4', '5cf4f347-5f6a-4f77-8ef1-6bd243a1c029', 4, 'To change the time of an exam', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e4ef191-f12b-4e16-a338-36988ae149af', '3a7d0a01-5bf7-4d86-8faa-d1e7864fd86d', 2, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 1, '### Question 2
How long is each video lesson in the standard course?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d68ea3d-49ec-4d19-8f9b-3bd8196b0407', '6e4ef191-f12b-4e16-a338-36988ae149af', 1, 'About five minutes', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f012f6e9-8a45-4f33-9e4d-bfb77dc5a197', '6e4ef191-f12b-4e16-a338-36988ae149af', 2, 'About ten minutes', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7573902-0cb1-4bfb-9c59-f74caed7ddb0', '6e4ef191-f12b-4e16-a338-36988ae149af', 3, 'About thirty minutes', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf1a6079-49ad-4ecf-bef6-8e3f12c6d3b6', '6e4ef191-f12b-4e16-a338-36988ae149af', 4, 'About one hour', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b6ff5dff-d336-49b7-ba3f-11e4fd15b6b7', '3a7d0a01-5bf7-4d86-8faa-d1e7864fd86d', 3, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 2, '### Question 3
How many weeks does the whole course last?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f3cd8fb-e229-41b5-b761-a6f736bf75b0', 'b6ff5dff-d336-49b7-ba3f-11e4fd15b6b7', 1, 'Eight weeks', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ae26733-2aac-4f13-b06f-27e98355a4e0', 'b6ff5dff-d336-49b7-ba3f-11e4fd15b6b7', 2, 'Ten weeks', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('569cede0-a8cc-4ec3-9df8-f7f2dfc24fb9', 'b6ff5dff-d336-49b7-ba3f-11e4fd15b6b7', 3, 'Twelve weeks', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6f5425b-a932-4c0e-a547-e429179fca0b', 'b6ff5dff-d336-49b7-ba3f-11e4fd15b6b7', 4, 'Sixteen weeks', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e7739a0-a2ad-4d3c-9f7a-9dd63a96ecf7', '3a7d0a01-5bf7-4d86-8faa-d1e7864fd86d', 4, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 2, '### Question 4
How many hours per week do most students study?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5f6509a-d931-4e3e-9ab5-74b66c49d130', '4e7739a0-a2ad-4d3c-9f7a-9dd63a96ecf7', 1, 'Around one to two hours', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef0173ac-504b-4930-987c-69b6f4b4b8af', '4e7739a0-a2ad-4d3c-9f7a-9dd63a96ecf7', 2, 'Around two to three hours', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d8a7c78-1d49-402a-a2e3-904759ba28c6', '4e7739a0-a2ad-4d3c-9f7a-9dd63a96ecf7', 3, 'Around four to five hours', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f885d9f-041f-4be0-88e7-18992b78887f', '4e7739a0-a2ad-4d3c-9f7a-9dd63a96ecf7', 4, 'Around eight to ten hours', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cdc75916-12b9-4dc9-8143-9ad7bd3bb223', '3a7d0a01-5bf7-4d86-8faa-d1e7864fd86d', 5, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 3, '### Question 5
What does the upper-intermediate group mainly focus on?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e43fd2eb-d593-4f39-973c-909dd1f16bde', 'cdc75916-12b9-4dc9-8143-9ad7bd3bb223', 1, 'Grammar for academic essays', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1456c3ac-0d4a-4a36-b0f2-c9e9897828c9', 'cdc75916-12b9-4dc9-8143-9ad7bd3bb223', 2, 'Speaking in meetings and writing emails', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07c584e3-174c-4d26-bffd-5daec997409b', 'cdc75916-12b9-4dc9-8143-9ad7bd3bb223', 3, 'Pronunciation for beginners', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef68051c-c5e1-49c6-bf33-52d170eeaef3', 'cdc75916-12b9-4dc9-8143-9ad7bd3bb223', 4, 'Preparation for a driving test', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ba2b1c0e-2db0-4c86-b3f6-155c89aeb2ad', '3a7d0a01-5bf7-4d86-8faa-d1e7864fd86d', 6, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 3, '### Question 6
What does the advisor say about payment?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d80f652a-71a8-4d83-9d51-e72274a8245b', 'ba2b1c0e-2db0-4c86-b3f6-155c89aeb2ad', 1, 'Students must pay the full fee at once.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ba16ecc-8596-4e8b-8a5a-677d3522db98', 'ba2b1c0e-2db0-4c86-b3f6-155c89aeb2ad', 2, 'Students can only pay in cash at the office.', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('435cba62-e96b-4b10-9944-568907ef960e', 'ba2b1c0e-2db0-4c86-b3f6-155c89aeb2ad', 3, 'Students can pay monthly or pay in advance for a discount.', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1143fb1-94d8-4f32-9474-f5e1859bed4e', 'ba2b1c0e-2db0-4c86-b3f6-155c89aeb2ad', 4, 'The course is free for the first month.', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6ed2b20a-8628-4bbc-9117-de6e9ec53f25', '3a7d0a01-5bf7-4d86-8faa-d1e7864fd86d', 7, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 4, '### Question 7
When does the small group class on Zoom take place?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5c7d639-1178-46e9-ab6d-702f5f98929d', '6ed2b20a-8628-4bbc-9117-de6e9ec53f25', 1, 'Every Monday morning', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb088609-e777-4f83-a57c-d7754eb305dc', '6ed2b20a-8628-4bbc-9117-de6e9ec53f25', 2, 'Every Wednesday afternoon', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e49fdaf-0a4c-4f16-a48a-0e67f0412188', '6ed2b20a-8628-4bbc-9117-de6e9ec53f25', 3, 'Every Thursday evening', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5af2abbb-2747-4f7a-a8b6-fbfd4635db7d', '6ed2b20a-8628-4bbc-9117-de6e9ec53f25', 4, 'Every Saturday afternoon', false);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f1a9675b-9386-4f2d-9bfb-9f7dd6e6c8cb', '3a7d0a01-5bf7-4d86-8faa-d1e7864fd86d', 8, 'MULTIPLE_CHOICE_SINGLE', 'LISTENING', 4, '### Question 8
How can students contact their teacher outside the class?', NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3839165b-aa95-4ae5-b12a-987d3272e4e2', 'f1a9675b-9386-4f2d-9bfb-9f7dd6e6c8cb', 1, 'By sending letters to the school', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8170dca-a2a8-420b-bd20-034ae7b7a77c', 'f1a9675b-9386-4f2d-9bfb-9f7dd6e6c8cb', 2, 'By messaging through the app', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01a3cd79-14bb-4f44-90eb-57c975080ea2', 'f1a9675b-9386-4f2d-9bfb-9f7dd6e6c8cb', 3, 'By calling the teacher''s home number', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e645a06-72c3-42b4-ae6d-8e2bd9ade1c6', 'f1a9675b-9386-4f2d-9bfb-9f7dd6e6c8cb', 4, 'By visiting the office without an appointment', false);

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('b1a5f019-d676-4a64-9a01-a2a504b110e0', 'c69a3e54-a7f1-40eb-ab69-1f50ca798267', 3, 'Writing – Short Essay (Optional)', 'This writing task is optional and can be used to check productive skills.
Write your answer in the text box. Recommended time: **15–20 minutes**.', NULL, NULL);
INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4f7c3559-b77e-4d61-8b08-b9c5f8f769c3', 'b1a5f019-d676-4a64-9a01-a2a504b110e0', 1, 'SHORT_ANSWER', 'WRITING', 4, '### Writing Task

In many cities and towns, more people are buying things online instead of in traditional shops.

Write **120–150 words** describing:
- two advantages of shopping online, and  
- two disadvantages of shopping online.

Give reasons for your ideas and include examples from your own experience.', NULL, ARRAY['.*']);

COMMIT;