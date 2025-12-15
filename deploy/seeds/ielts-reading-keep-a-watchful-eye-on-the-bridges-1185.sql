BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-keep-a-watchful-eye-on-the-bridges-1185'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-keep-a-watchful-eye-on-the-bridges-1185';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-keep-a-watchful-eye-on-the-bridges-1185';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-keep-a-watchful-eye-on-the-bridges-1185';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('fd4fc336-edfa-5d6c-970e-f13f3cf967f2', 'ielts-reading-keep-a-watchful-eye-on-the-bridges-1185', $t$Keep a Watchful Eye on the Bridges$t$, $md$## Keep a Watchful Eye on the Bridges

Nguồn:
- Test: https://mini-ielts.com/1185/reading/keep-a-watchful-eye-on-the-bridges
- Solution: https://mini-ielts.com/1185/view-solution/reading/keep-a-watchful-eye-on-the-bridges$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 'fd4fc336-edfa-5d6c-970e-f13f3cf967f2', 1, $t$Reading — Keep a Watchful Eye on the Bridges$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Keep a Watchful Eye on the Bridges

A Most road and rail bridges are only inspected visually, if at all . Every few months, engineers have to clamber over the structure in an attempt to find problems before the bridge shows obvious signs of damage. Technologies developed at Los Alamos National Laboratory, New Mexico, and Texas A&M University may replace these surveys with microwave sensors that constantly monitor the condition of bridges.

B “ The device uses microwaves to measure the distance between the sensor and the bridge, much like radar does ,” says Albert Migliori, a Los Alamos physicist “ Any load on the bridge – such as traffic induces displacements , which change that distance as the bridge moves up and down.” By monitoring these movements over several minutes, the researchers can find out how the bridge resonates. Changes in its behaviour can give an early warning of damage.

C The Interstate 40 bridge over the Rio Grande river in Albuquerque provided the researchers with a rare opportunity to text their ideas. Chuck Farrar, an engineer at Los Alamos, explains: “The New Mexico authorities decided to raze this bridge and replace it. We were able to mount instruments on it, test it under various load conditions and even inflict damage just before it was demolished.” In the 1960s and 1970s, 2500 similar bridges were built in the US. They have two steel girders supporting the load in each section. Highway experts know that this design is “fracture critical” because a failure in either girder would cause the bridge to fail .

D After setting up the microwave dish on the ground below the bridge, the Los Alamos team installed conventional accelerometers at several points along the span to measure its motion. They then tested the bridge while traffic roared across it and while subjecting it to pounding from a “shaker”, which delivered precise punches to a specific point on the road.

E “We then created damage that we hoped would simulate fatigue cracks that can occur in steel girders,” says Farrar. They first cut a slot about 60 centimetres long in the middle of one girder . They then extended the cut until it reached the bottom of the girder and finally they cut across the flange – the bottom of the girder’s “I” shape.

F The initial, crude analysis of the bridge’s behaviour, based on the frequency at which the bridge resonates, did not indicate that anything was wrong until the flange was damaged . But later the data were reanalysed with algorithms that took into account changes in the mode shapes of the structure – shapes that the structure takes on when excited at a particular frequency. These more sophisticated algorithms, which were developed by Norris Stubbs at Texas A&M University, successfully identified and located the damage caused by the initial cut.

G “When any structure vibrates, the energy is distributed throughout with some points not moving, while others vibrate strongly at various frequencies,” says Stubbs. “My algorithms use pattern recognition to detect changes in the distribution of this energy.” NASA already uses Stubbs ’ method to check the behaviour of the body flap that slows space shuttles down after they land.

H A commercial system based on the Los Alamos hardware is now available, complete with the Stubbs algorithms, from the Quatro Corporation in Albuquerque for about $100,000. Tim Darling, another Los Alamos physicist working on the microwave interferometer with Migliori, says that as the electronics become cheaper, a microwave inspection system will eventually be applied to most large bridges in the US . “In a decade I would like to see a battery or solar-powered package mounted under each bridge, scanning it every day to detect changes,” he says.

-------------------

Great thanks to volunteer Minh Ngoc has contributed these explanations markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('479d81a3-1571-5efe-8137-fb9d2d02dfea', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1
How did the traditional way to prevent damage of the bridges before the invention of new monitoring system
A
Bridges has to be tested in every movement on two points.
B
Bridges has to be closely monitored by microwave devices.
C
Bridges has already been monitored by sensors.
D
Bridges has to be frequently inspected by professional workers with naked eyes.
Locate
2
How does the new microwave monitors find out the problems of bridges
A
by changeling the distance between the positions of devices
B
by controlling the traffic flow on the bridges
C
by monitoring the distance caused by traffic between two points
D
by displacement of the several critical parts in the bridges
Locate
3
Why did the expert believe there is a problem for the design called “fracture critical”
A
Engineers failed to apply the newly developed construction materials.
B
There was not enough finance to repair the bridges.
C
The supporting parts of the bridges may crack and cause the bridge to fail.
D
There was bigger traffic load conditions than the designers had anticipated.
Locate
4
Defect was not recognized by a basic method in the beginning
A
until the mid of faces of bridges has fractures.
B
until the damage appears along and down to the flanges.
C
until the points on the road have been punched.
D
until the frequency of resonates appears disordered.
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7b43617c-dca3-5069-94c4-606b089cf2f6', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1
How did the traditional way to prevent damage of the bridges before the invention of new monitoring system
A
Bridges has to be tested in every movement on two points.
B
Bridges has to be closely monitored by microwave devices.
C
Bridges has already been monitored by sensors.
D
Bridges has to be frequently inspected by professional workers with naked eyes.
Locate
2
How does the new microwave monitors find out the problems of bridges
A
by changeling the distance between the positions of devices
B
by controlling the traffic flow on the bridges
C
by monitoring the distance caused by traffic between two points
D
by displacement of the several critical parts in the bridges
Locate
3
Why did the expert believe there is a problem for the design called “fracture critical”
A
Engineers failed to apply the newly developed construction materials.
B
There was not enough finance to repair the bridges.
C
The supporting parts of the bridges may crack and cause the bridge to fail.
D
There was bigger traffic load conditions than the designers had anticipated.
Locate
4
Defect was not recognized by a basic method in the beginning
A
until the mid of faces of bridges has fractures.
B
until the damage appears along and down to the flanges.
C
until the points on the road have been punched.
D
until the frequency of resonates appears disordered.
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1dde037e-cf1e-5e9f-8bb3-628e1a58ac1d', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1
How did the traditional way to prevent damage of the bridges before the invention of new monitoring system
A
Bridges has to be tested in every movement on two points.
B
Bridges has to be closely monitored by microwave devices.
C
Bridges has already been monitored by sensors.
D
Bridges has to be frequently inspected by professional workers with naked eyes.
Locate
2
How does the new microwave monitors find out the problems of bridges
A
by changeling the distance between the positions of devices
B
by controlling the traffic flow on the bridges
C
by monitoring the distance caused by traffic between two points
D
by displacement of the several critical parts in the bridges
Locate
3
Why did the expert believe there is a problem for the design called “fracture critical”
A
Engineers failed to apply the newly developed construction materials.
B
There was not enough finance to repair the bridges.
C
The supporting parts of the bridges may crack and cause the bridge to fail.
D
There was bigger traffic load conditions than the designers had anticipated.
Locate
4
Defect was not recognized by a basic method in the beginning
A
until the mid of faces of bridges has fractures.
B
until the damage appears along and down to the flanges.
C
until the points on the road have been punched.
D
until the frequency of resonates appears disordered.
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('daab0e25-8d21-5b9b-890e-69519b58fdbf', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1
How did the traditional way to prevent damage of the bridges before the invention of new monitoring system
A
Bridges has to be tested in every movement on two points.
B
Bridges has to be closely monitored by microwave devices.
C
Bridges has already been monitored by sensors.
D
Bridges has to be frequently inspected by professional workers with naked eyes.
Locate
2
How does the new microwave monitors find out the problems of bridges
A
by changeling the distance between the positions of devices
B
by controlling the traffic flow on the bridges
C
by monitoring the distance caused by traffic between two points
D
by displacement of the several critical parts in the bridges
Locate
3
Why did the expert believe there is a problem for the design called “fracture critical”
A
Engineers failed to apply the newly developed construction materials.
B
There was not enough finance to repair the bridges.
C
The supporting parts of the bridges may crack and cause the bridge to fail.
D
There was bigger traffic load conditions than the designers had anticipated.
Locate
4
Defect was not recognized by a basic method in the beginning
A
until the mid of faces of bridges has fractures.
B
until the damage appears along and down to the flanges.
C
until the points on the road have been punched.
D
until the frequency of resonates appears disordered.
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('02a2147e-58ca-5f5d-9d67-6cd3f2a3d466', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 5, 'SHORT_ANSWER', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Filling the blanks in the diagram labels.
Write the correct answer in boxes
5-8
on your answer sheet.
5
Locate
6
Locate
7
Locate
8
Locate

5 ____ Locate$md$, NULL, ARRAY['.*microwave.*dish.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b27ec84a-944a-5db6-a096-4dec1b1e343c', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Filling the blanks in the diagram labels.
Write the correct answer in boxes
5-8
on your answer sheet.
5
Locate
6
Locate
7
Locate
8
Locate

6 ____ Locate$md$, NULL, ARRAY['.*accelerometers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4326a1fd-0461-5bf6-875a-ff2d98067b57', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Filling the blanks in the diagram labels.
Write the correct answer in boxes
5-8
on your answer sheet.
5
Locate
6
Locate
7
Locate
8
Locate

7 ____ Locate$md$, NULL, ARRAY['.*steel.*girders.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a4cd7699-a680-5b12-9adb-8772fd52aef7', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Filling the blanks in the diagram labels.
Write the correct answer in boxes
5-8
on your answer sheet.
5
Locate
6
Locate
7
Locate
8
Locate

8 ____ Locate$md$, NULL, ARRAY['.*flange.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('37f3a771-92f7-5090-9cdd-53d390f753aa', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
The reading Passage has eight paragraphs,
A
–
H
.
Which paragraph contains the following information?
Write the correct letter,
A
–
H
, in boxes
9
–
13
on your answer sheet.
9
how is the pressure that they have many a great chance to test bridges
Locate
10
a ten-year positive change for microwave device
Locate
11
the chance they get a honorable contract
Locate
12
explanation of the mechanism for the new microwave monitoring to work
Locate
13
how is the damage deliberately created by the researchers
Locate

9 ____ how is the pressure that they have many a great chance to test bridges Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee4e0286-ff72-519c-b6f3-f4b034930b47', '37f3a771-92f7-5090-9cdd-53d390f753aa', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32dd4bb2-9e4a-58b2-bf50-78f63209a09b', '37f3a771-92f7-5090-9cdd-53d390f753aa', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec707874-d28d-5963-a449-27d13c56be60', '37f3a771-92f7-5090-9cdd-53d390f753aa', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a246967-4339-59d6-972c-1abd76830a45', '37f3a771-92f7-5090-9cdd-53d390f753aa', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1b90a42-4d62-5dcc-a738-5201aa0664e9', '37f3a771-92f7-5090-9cdd-53d390f753aa', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7af2ccfd-51f1-5626-bb92-b2c0eda1b684', '37f3a771-92f7-5090-9cdd-53d390f753aa', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('063acf2b-27bb-52ac-8fa5-351a0eedd055', '37f3a771-92f7-5090-9cdd-53d390f753aa', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe50cf96-7202-57ab-a4f5-fee433000f05', '37f3a771-92f7-5090-9cdd-53d390f753aa', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('985fb2bb-6904-59d8-902e-7354cac3069e', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
The reading Passage has eight paragraphs,
A
–
H
.
Which paragraph contains the following information?
Write the correct letter,
A
–
H
, in boxes
9
–
13
on your answer sheet.
9
how is the pressure that they have many a great chance to test bridges
Locate
10
a ten-year positive change for microwave device
Locate
11
the chance they get a honorable contract
Locate
12
explanation of the mechanism for the new microwave monitoring to work
Locate
13
how is the damage deliberately created by the researchers
Locate

10 ____ a ten-year positive change for microwave device Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a00841f6-d10a-5991-be01-fdbbae68271a', '985fb2bb-6904-59d8-902e-7354cac3069e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4462e638-b6da-531b-a63b-f44168f2e658', '985fb2bb-6904-59d8-902e-7354cac3069e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c58cda51-0d96-538e-9d25-7bf045f22ada', '985fb2bb-6904-59d8-902e-7354cac3069e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17a8c80b-8d54-5a69-ac0a-9d7514d595c4', '985fb2bb-6904-59d8-902e-7354cac3069e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1074084-47fd-54bb-8375-7b6d08cd66a0', '985fb2bb-6904-59d8-902e-7354cac3069e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cf5c424-6bb7-57e5-969f-19593e762041', '985fb2bb-6904-59d8-902e-7354cac3069e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8ad50b7-dc0d-5482-b9f8-58a226d9ed1c', '985fb2bb-6904-59d8-902e-7354cac3069e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a40276fc-2b10-5b31-b225-90a27142f627', '985fb2bb-6904-59d8-902e-7354cac3069e', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9d7db619-c904-5a5c-810a-e8e33382791f', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 11, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
The reading Passage has eight paragraphs,
A
–
H
.
Which paragraph contains the following information?
Write the correct letter,
A
–
H
, in boxes
9
–
13
on your answer sheet.
9
how is the pressure that they have many a great chance to test bridges
Locate
10
a ten-year positive change for microwave device
Locate
11
the chance they get a honorable contract
Locate
12
explanation of the mechanism for the new microwave monitoring to work
Locate
13
how is the damage deliberately created by the researchers
Locate

11 ____ the chance they get a honorable contract Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90fb1f77-cdb6-599e-9aee-82f1bf898553', '9d7db619-c904-5a5c-810a-e8e33382791f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cff30108-a1d0-5e38-b75b-8f82ad4003bb', '9d7db619-c904-5a5c-810a-e8e33382791f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a090dde-caaf-573b-b9b3-3144ece0e9cf', '9d7db619-c904-5a5c-810a-e8e33382791f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('218a73bf-7531-5c50-9eac-c4d494568ac4', '9d7db619-c904-5a5c-810a-e8e33382791f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55a27e4e-6a57-553d-b528-8853bdca60c8', '9d7db619-c904-5a5c-810a-e8e33382791f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96c7cbe6-bfed-50f4-91d8-125b06affc40', '9d7db619-c904-5a5c-810a-e8e33382791f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b6ad91f-7ced-50fe-8021-3dd344c35a0b', '9d7db619-c904-5a5c-810a-e8e33382791f', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a956a3f6-8e4b-5348-ad54-52fc0cad62f0', '9d7db619-c904-5a5c-810a-e8e33382791f', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f3375e1b-107e-54cb-be69-b8cd09085b9c', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 12, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
The reading Passage has eight paragraphs,
A
–
H
.
Which paragraph contains the following information?
Write the correct letter,
A
–
H
, in boxes
9
–
13
on your answer sheet.
9
how is the pressure that they have many a great chance to test bridges
Locate
10
a ten-year positive change for microwave device
Locate
11
the chance they get a honorable contract
Locate
12
explanation of the mechanism for the new microwave monitoring to work
Locate
13
how is the damage deliberately created by the researchers
Locate

12 ____ explanation of the mechanism for the new microwave monitoring to work Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1f3ab11-a1ba-5fc2-b87c-7705c1d95544', 'f3375e1b-107e-54cb-be69-b8cd09085b9c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d76812a5-a086-53d5-bcdf-46893a4323f6', 'f3375e1b-107e-54cb-be69-b8cd09085b9c', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e2273b6-f8a9-5f20-8a31-33ac68d6ef38', 'f3375e1b-107e-54cb-be69-b8cd09085b9c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d0c2a8d-b728-5a5e-b69b-1df1a0573768', 'f3375e1b-107e-54cb-be69-b8cd09085b9c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27e3dac0-f4f0-5a67-9a1c-fda6fbbbec36', 'f3375e1b-107e-54cb-be69-b8cd09085b9c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48c5ffc8-53f7-595f-be36-1e22354d4427', 'f3375e1b-107e-54cb-be69-b8cd09085b9c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49d29df1-30a4-57e6-8bbe-f1c362a664e4', 'f3375e1b-107e-54cb-be69-b8cd09085b9c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ba07a11-c6e0-58ce-b578-512227c07d7f', 'f3375e1b-107e-54cb-be69-b8cd09085b9c', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5fc4b13d-11cf-5da1-b912-bb29d4a4b7b0', 'da4beabb-62d4-5dc5-9d90-9dbf67cfe6bd', 13, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
The reading Passage has eight paragraphs,
A
–
H
.
Which paragraph contains the following information?
Write the correct letter,
A
–
H
, in boxes
9
–
13
on your answer sheet.
9
how is the pressure that they have many a great chance to test bridges
Locate
10
a ten-year positive change for microwave device
Locate
11
the chance they get a honorable contract
Locate
12
explanation of the mechanism for the new microwave monitoring to work
Locate
13
how is the damage deliberately created by the researchers
Locate

13 ____ how is the damage deliberately created by the researchers Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b66540a-28a3-5d4b-98fe-2ecf3f6e203d', '5fc4b13d-11cf-5da1-b912-bb29d4a4b7b0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3251317e-cb5a-53ab-b793-9bd760f5e334', '5fc4b13d-11cf-5da1-b912-bb29d4a4b7b0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91c021af-f846-56f3-8066-a232e100ab1c', '5fc4b13d-11cf-5da1-b912-bb29d4a4b7b0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2140610b-8679-5f99-b489-de498595ea7c', '5fc4b13d-11cf-5da1-b912-bb29d4a4b7b0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90bf1535-2359-5711-800e-36a1edaa43b0', '5fc4b13d-11cf-5da1-b912-bb29d4a4b7b0', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b53b02e4-5ce6-54c9-ab28-1cab7d05f307', '5fc4b13d-11cf-5da1-b912-bb29d4a4b7b0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d9f8d07-8da8-55cb-a3f0-cc9874a3eb13', '5fc4b13d-11cf-5da1-b912-bb29d4a4b7b0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65579502-882b-57b1-a2ae-8229a3983ca3', '5fc4b13d-11cf-5da1-b912-bb29d4a4b7b0', 8, $md$H$md$, false);

COMMIT;
