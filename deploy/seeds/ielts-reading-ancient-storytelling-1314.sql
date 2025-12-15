BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ancient-storytelling-1314'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ancient-storytelling-1314';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ancient-storytelling-1314';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-ancient-storytelling-1314';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('7312e400-b0e8-593f-807f-e221bf8c293f', 'ielts-reading-ancient-storytelling-1314', $t$Ancient Storytelling$t$, $md$## Ancient Storytelling

Nguồn:
- Test: https://mini-ielts.com/1314/reading/ancient-storytelling
- Solution: https://mini-ielts.com/1314/view-solution/reading/ancient-storytelling$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('32ffc5e3-3fdc-5977-b853-64f54c9124e5', '7312e400-b0e8-593f-807f-e221bf8c293f', 1, $t$Reading — Ancient Storytelling$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Ancient Storytelling

A

It was told, we suppose, to people crouched around a fire: a tale of adventure, most likely-relating some close encounter with death; a remarkable hunt, an escape from mortal danger; a vision, or something else out of the ordinary. Whatever its thread, the weaving of this story was done with a prime purpose. The listeners must be kept listening. They must not fall asleep. So, as the story went on, its audience should be sustained by one question above all. What happens next?

B

The first fireside stories in human history can never be known. They were kept in the heads of those who told them. This method of storage is not necessarily inefficient. From documented oral traditions in Australia, the Balkans and other parts of the world we know that specialised storytellers and poets can recite from memory literally thousands of lines, in verse or prose, verbatim-word for word. But while memory is rightly considered an art in itself, it is clear that a primary purpose of making symbols is to have a system of reminders or mnemonic cues – signs that assist us to recall certain information in the mind’s eye.

C

In some Polynesian communities, a notched memory stick may help to guide a storyteller through successive stages of recitation. But in other parts of the world, the activity of storytelling historically resulted in the development or even the invention of writing systems. One theory about the arrival of literacy in ancient Greece, for example, argues that the epic tales about the Trojan War and the wanderings of Odysseus – traditionally attributed to Homer – were just so enchanting to hear that they had to be preserved. So the Greeks, c.750-700BC, borrowed an alphabet from their neighbors in the eastern Mediterranean, the Phoenicians.

D

The custom of recording stories on parchment and other materials can be traced in many manifestations around the world, from the priestly papyrus archives of ancient Egypt to the birch-bark scrolls on which the North American Ojibway Indians set down their creation-myth. It is a well-tried and universal practice: so much so that to this day storytime is probably most often associated with words on paper. The formal practice of narrating a story aloud would seem-so we assume to have given way to newspapers, novels and comic strips. This, however, is not the case. Statistically, it is doubtful that the majority of humans currently rely upon the written word to get access to stories. So what is the alternative source?

E

Each year, over 7 billion people will go to watch the latest offering from Hollywood, Bollywood and beyond. The supreme storyteller of today is cinema. The movies, as distinct from still photography, seem to be an essential modem phenomenon. This is an illusion, for there are, as we shall see, certain ways in which the medium of film is indebted to very old precedents of arranging ‘sequences’ of images. But any account of visual storytelling must be with the recognition that all storytelling beats with a deeply atavistic pulse: that is, a ‘good story’ relies upon formal patterns of plot and characterisation that have been embedded in the practice of storytelling over many generations.

F

Thousands of scripts arrive every week at the offices of the major film studios. But aspiring screenwriters really need to look no further for essential advice then the fourth-century BC Greek Philosopher Aristotle. He left some incomplete lecture notes on the art of telling stories in various literary and dramatic modes, a slim volume known as The Poetics. Though he can never have envisaged the popcorn-fuelled actuality of a multiplex cinema, Aristotle is almost prescient about the key elements required to get the crowds flocking to such a cultural hub. He analyzed the process with cool rationalism. When a story enchants us, we lose the sense of where we are; we are drawn into the story so thoroughly that we forget it is a story being told. This is, in Aristotle’s phrase, ‘the suspension of disbelief.

G

We know the feeling. If ever we have stayed in our seats, stunned with grief, as the credits roll by, or for days after seeing that vivid evocation of horror have been nervous about taking a shower at home, then we have suspended disbelief. We have been caught, or captivated, in the storyteller’s web. Did it all really happen? We really thought so for a while. Aristotle must have witnessed often enough this suspension of disbelief. He taught at Athens, the city where theater developed as a primary form of civic ritual and recreation. Two theatrical types of storytelling, tragedy and comedy, caused Athenian audiences to lose themselves in sadness and laughter respectively. Tragedy, for Aristotle, was particularly potent in its capacity to enlist and then purge the emotions of those watching the story unfold on the stage, so he tried to identify those factors in the storyteller’s art that brought about such engagement. He had, as an obvious sample for analysis, not only the fifth-century BC masterpieces of Classical Greek tragedy written by Aeschylus, Sophocles and Euripides. Beyond them stood Homer, whose stories even then had canonical status: The Iliad and The Odyssey were already considered literary landmarks-stories by which all other stories should be measured. So what was the secret of Homer’s narrative art?

H

It was not hard to find. Homer created credible heroes. His heroes belonged to the past, they were mighty and magnificent, yet they were not, in the end, fantasy figures. He made his heroes sulk, bicker, cheat and cry. They were, in short, characters – protagonists of a story that an audience would care about, would want to follow, would want to know what happens next. As Aristotle saw, the hero who shows a human side-some flaw or weakness to which mortals are prone-is intrinsically dramatic.d by logging.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ce1b16f4-74f7-5278-9b0c-626ff78d88e1', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The Reading Passage has eight paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-5
on your answer sheet.
1
A misunderstanding of a modern way for telling stories
2
The typical forms mentioned for telling stories
3
The fundamental aim of storytelling
4
A description of reciting stories without any assistance
5
How to make story characters attractive

1 ____ A misunderstanding of a modern way for telling stories$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15100141-c814-585d-a9c9-a30d39eacdce', 'ce1b16f4-74f7-5278-9b0c-626ff78d88e1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcd5c64d-45bf-5fcf-a979-caa6934ccf05', 'ce1b16f4-74f7-5278-9b0c-626ff78d88e1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4dbb292-eaec-5a7c-ac07-1d8ca0e93a33', 'ce1b16f4-74f7-5278-9b0c-626ff78d88e1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1dd9cb7-1d57-5b76-b316-0bab641aa743', 'ce1b16f4-74f7-5278-9b0c-626ff78d88e1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba68026f-c3d7-5cd6-83c8-3099ecc8ab60', 'ce1b16f4-74f7-5278-9b0c-626ff78d88e1', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b5f7409-6d11-5d67-9a07-c25a5145987e', 'ce1b16f4-74f7-5278-9b0c-626ff78d88e1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d51f810a-9d02-5d9f-9315-2b11f98aeee1', 'ce1b16f4-74f7-5278-9b0c-626ff78d88e1', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37ee4620-b925-58ef-b0c0-34020b82aa67', 'ce1b16f4-74f7-5278-9b0c-626ff78d88e1', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bfe2317b-d7b2-5662-b59b-412fb2cbe300', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The Reading Passage has eight paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-5
on your answer sheet.
1
A misunderstanding of a modern way for telling stories
2
The typical forms mentioned for telling stories
3
The fundamental aim of storytelling
4
A description of reciting stories without any assistance
5
How to make story characters attractive

2 ____ The typical forms mentioned for telling stories$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43169003-827c-551e-87aa-bdd8e1eb4412', 'bfe2317b-d7b2-5662-b59b-412fb2cbe300', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cabfb5f-f61d-5848-a5cd-98ff0ff832d7', 'bfe2317b-d7b2-5662-b59b-412fb2cbe300', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92269c9f-d00e-52d0-ac04-05cfee81fcfc', 'bfe2317b-d7b2-5662-b59b-412fb2cbe300', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8331ef26-7322-501a-b5d7-0a274281364f', 'bfe2317b-d7b2-5662-b59b-412fb2cbe300', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bbe3a21-233b-5f3a-8213-7f9b3fd93de0', 'bfe2317b-d7b2-5662-b59b-412fb2cbe300', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2e5ad69-888b-5e15-aa24-9151356f81f3', 'bfe2317b-d7b2-5662-b59b-412fb2cbe300', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5ec3288-ef2f-5dfd-9c0b-57919fc8b451', 'bfe2317b-d7b2-5662-b59b-412fb2cbe300', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35ae63e5-ca66-58d1-ad73-25cdf22d99b0', 'bfe2317b-d7b2-5662-b59b-412fb2cbe300', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2a696e0b-9bc0-5a34-b099-460a7983bb8c', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The Reading Passage has eight paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-5
on your answer sheet.
1
A misunderstanding of a modern way for telling stories
2
The typical forms mentioned for telling stories
3
The fundamental aim of storytelling
4
A description of reciting stories without any assistance
5
How to make story characters attractive

3 ____ The fundamental aim of storytelling$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f18b2ad-3715-5c60-b5d9-ed48a7b807b3', '2a696e0b-9bc0-5a34-b099-460a7983bb8c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd8acd76-4060-5b9c-afbd-8cc77e2f797a', '2a696e0b-9bc0-5a34-b099-460a7983bb8c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f66db7b7-a287-5b07-a164-ba85e43c86a5', '2a696e0b-9bc0-5a34-b099-460a7983bb8c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4602c2c-606e-5d30-8d42-67c06dbc8c7d', '2a696e0b-9bc0-5a34-b099-460a7983bb8c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78abc692-b5d3-5668-9482-3da477d3aeaa', '2a696e0b-9bc0-5a34-b099-460a7983bb8c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44e86c32-0bfc-5b44-b59e-87ebed960def', '2a696e0b-9bc0-5a34-b099-460a7983bb8c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('778570e7-f34f-5e8e-995a-0c3d3e3d08c4', '2a696e0b-9bc0-5a34-b099-460a7983bb8c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43cd1e34-4f27-5070-9b60-25f7acb1a02b', '2a696e0b-9bc0-5a34-b099-460a7983bb8c', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a2bcb701-db2d-5059-a767-dea76421cd55', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The Reading Passage has eight paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-5
on your answer sheet.
1
A misunderstanding of a modern way for telling stories
2
The typical forms mentioned for telling stories
3
The fundamental aim of storytelling
4
A description of reciting stories without any assistance
5
How to make story characters attractive

4 ____ A description of reciting stories without any assistance$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d7ba27f-4edc-5a6d-a961-ee8585f6cc5c', 'a2bcb701-db2d-5059-a767-dea76421cd55', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7312796-0b4c-57dd-a5cd-ad5a1ef434a7', 'a2bcb701-db2d-5059-a767-dea76421cd55', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad656c86-c889-52c4-8d23-05061a5d5343', 'a2bcb701-db2d-5059-a767-dea76421cd55', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce414b65-a203-508c-9fea-dd28a731b190', 'a2bcb701-db2d-5059-a767-dea76421cd55', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c26a9968-76b9-5699-8a40-308066b99fa5', 'a2bcb701-db2d-5059-a767-dea76421cd55', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('953d7a19-8be9-5515-ae15-7cb70dbfbe12', 'a2bcb701-db2d-5059-a767-dea76421cd55', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7885adbc-f676-547c-a957-f8321f5ba1ea', 'a2bcb701-db2d-5059-a767-dea76421cd55', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be1fe192-f9a8-5ca0-bf9c-a7f3acf3dc0d', 'a2bcb701-db2d-5059-a767-dea76421cd55', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5fea5c0b-9ef0-5e6c-a45f-8ed06d50fded', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The Reading Passage has eight paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-5
on your answer sheet.
1
A misunderstanding of a modern way for telling stories
2
The typical forms mentioned for telling stories
3
The fundamental aim of storytelling
4
A description of reciting stories without any assistance
5
How to make story characters attractive

5 ____ How to make story characters attractive$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ea61cd0-37d6-571a-9577-d439dde2353a', '5fea5c0b-9ef0-5e6c-a45f-8ed06d50fded', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79be1a81-c367-5d8b-a1ba-b646f4ca18b7', '5fea5c0b-9ef0-5e6c-a45f-8ed06d50fded', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9596b428-dfdb-59d4-a197-c5a82c272fb8', '5fea5c0b-9ef0-5e6c-a45f-8ed06d50fded', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba90e024-b92b-5f58-b72c-75b7c6f4821f', '5fea5c0b-9ef0-5e6c-a45f-8ed06d50fded', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('431e96c3-0836-5edc-a46f-5fa0445d81ac', '5fea5c0b-9ef0-5e6c-a45f-8ed06d50fded', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf986438-4a6e-5045-8b3c-579721ef313c', '5fea5c0b-9ef0-5e6c-a45f-8ed06d50fded', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5882649-6bf3-51a6-ac1c-9877415ac5e7', '5fea5c0b-9ef0-5e6c-a45f-8ed06d50fded', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7a34edb-aaa5-5193-8f44-c5882805f278', '5fea5c0b-9ef0-5e6c-a45f-8ed06d50fded', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('35f72988-821c-59ef-b066-affdeaf288ea', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Classify the following information as referring to
A
adopted the writing system from another country
B
used organic materials to record stories
C
used tools to help to tell stories
Write the correct letter,
A
,
B
or
C
in boxes
6-9
on your answer sheet.
6
Egyptians
7
Ojibway
8
Polynesians
9
Greek

6 ____ Egyptians$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f5ee7d1-1747-5518-b3c5-8b64371b8d38', '35f72988-821c-59ef-b066-affdeaf288ea', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8354c1ae-5c96-5ada-963f-474876d62ec2', '35f72988-821c-59ef-b066-affdeaf288ea', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77df5247-56a6-5450-88f7-c558909d25ca', '35f72988-821c-59ef-b066-affdeaf288ea', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('90b4f964-2068-5635-897c-29c174cb9a6d', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Classify the following information as referring to
A
adopted the writing system from another country
B
used organic materials to record stories
C
used tools to help to tell stories
Write the correct letter,
A
,
B
or
C
in boxes
6-9
on your answer sheet.
6
Egyptians
7
Ojibway
8
Polynesians
9
Greek

7 ____ Ojibway$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea2938e0-f08e-5742-b78b-fc2011cda565', '90b4f964-2068-5635-897c-29c174cb9a6d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfbd316e-9fa6-5adb-a95c-3d53a25fd606', '90b4f964-2068-5635-897c-29c174cb9a6d', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6873f07e-4fd3-5a48-862b-89445ec9a611', '90b4f964-2068-5635-897c-29c174cb9a6d', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9124c206-9ef9-554e-b8c2-fb41f33e2ca0', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Classify the following information as referring to
A
adopted the writing system from another country
B
used organic materials to record stories
C
used tools to help to tell stories
Write the correct letter,
A
,
B
or
C
in boxes
6-9
on your answer sheet.
6
Egyptians
7
Ojibway
8
Polynesians
9
Greek

8 ____ Polynesians$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa682c2b-fc89-5c0e-8984-6672d8dbade1', '9124c206-9ef9-554e-b8c2-fb41f33e2ca0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('073b5a4e-0189-50c8-987d-4486c682ffa3', '9124c206-9ef9-554e-b8c2-fb41f33e2ca0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de922e5a-f77c-577f-8a19-2d320e7473bd', '9124c206-9ef9-554e-b8c2-fb41f33e2ca0', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('80d4aee1-06f7-5497-9f29-85a9ffc082af', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Classify the following information as referring to
A
adopted the writing system from another country
B
used organic materials to record stories
C
used tools to help to tell stories
Write the correct letter,
A
,
B
or
C
in boxes
6-9
on your answer sheet.
6
Egyptians
7
Ojibway
8
Polynesians
9
Greek

9 ____ Greek$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c258d04-9c41-541f-8430-521e6f3aaee5', '80d4aee1-06f7-5497-9f29-85a9ffc082af', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06c308fc-7ee5-5e85-b222-c12996cbb505', '80d4aee1-06f7-5497-9f29-85a9ffc082af', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa36d165-f46c-56be-8a91-dbc75b82a91a', '80d4aee1-06f7-5497-9f29-85a9ffc082af', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e646302c-ef90-5e3f-bf3c-b12e7b29abd1', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 10, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the sentences below with
ONE WORD ONLY
from the passage.
Write your answer in boxes
10-13
on your answer sheet.
10
Aristotle wrote a book on the art of storytelling called
10
11
Aristotle believed the most powerful type of story to move listeners is
11
12
Aristotle viewed Homers works as
12
13
Aristotle believed attractive heroes should have some
13

10 Aristotle wrote a book on the art of storytelling called 10 ____$md$, NULL, ARRAY['.*poetics.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4e360197-c726-511d-8769-e6c4f024de3b', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the sentences below with
ONE WORD ONLY
from the passage.
Write your answer in boxes
10-13
on your answer sheet.
10
Aristotle wrote a book on the art of storytelling called
10
11
Aristotle believed the most powerful type of story to move listeners is
11
12
Aristotle viewed Homers works as
12
13
Aristotle believed attractive heroes should have some
13

11 Aristotle believed the most powerful type of story to move listeners is 11 ____$md$, NULL, ARRAY['.*tragedy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c70789f8-af06-5c6d-85ff-cb07e9b81728', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the sentences below with
ONE WORD ONLY
from the passage.
Write your answer in boxes
10-13
on your answer sheet.
10
Aristotle wrote a book on the art of storytelling called
10
11
Aristotle believed the most powerful type of story to move listeners is
11
12
Aristotle viewed Homers works as
12
13
Aristotle believed attractive heroes should have some
13

12 Aristotle viewed Homers works as 12 ____$md$, NULL, ARRAY['.*landmarks.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('34baee03-d07c-58a3-8809-783505e58ddb', '32ffc5e3-3fdc-5977-b853-64f54c9124e5', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the sentences below with
ONE WORD ONLY
from the passage.
Write your answer in boxes
10-13
on your answer sheet.
10
Aristotle wrote a book on the art of storytelling called
10
11
Aristotle believed the most powerful type of story to move listeners is
11
12
Aristotle viewed Homers works as
12
13
Aristotle believed attractive heroes should have some
13

13 Aristotle believed attractive heroes should have some 13 ____$md$, NULL, ARRAY['.*flaw.*']);

COMMIT;
