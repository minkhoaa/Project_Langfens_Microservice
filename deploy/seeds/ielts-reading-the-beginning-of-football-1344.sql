BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-beginning-of-football-1344'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-beginning-of-football-1344';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-beginning-of-football-1344';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-beginning-of-football-1344';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('af8945e2-c06b-53ad-be45-96594446a875', 'ielts-reading-the-beginning-of-football-1344', $t$The Beginning of Football$t$, $md$## The Beginning of Football

Nguồn:
- Test: https://mini-ielts.com/1344/reading/the-beginning-of-football
- Solution: https://mini-ielts.com/1344/view-solution/reading/the-beginning-of-football$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('a1869acb-4409-5eed-b8f1-4469bb777898', 'af8945e2-c06b-53ad-be45-96594446a875', 1, $t$Reading — The Beginning of Football$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Beginning of Football

A

Football as we now know it developed in Britain in the 19th century, but the game is far older than this. In fact, the term has historically been applied to games played on foot, as opposed to those played on horseback, so ‘football’ hasn’t always involved kicking a ball. It has generally been played by men, though at the end of the 17th century, games were played between married and single women in a town in Scotland. The married women regularly won.

B

C

Another form of the game, also originating from the Far East, was the Japanese ‘kemari’ which dates from about the fifth century and is still played today. This is a type of circular football game, a more dignified and ceremonious experience requiring certain skills, but not competitive in the way the Chinese game was, nor is there the slightest sign of struggle for possession of the ball. The players had to pass the ball to each other, in a relatively small space, trying not to let it touch the ground.

D

The Romans had a much livelier game, ‘harpastum’. Each team member had his own specific tactical assignment took a noisy interest in the proceedings and the score. The role of the feet was so small as scarcely to be of consequence. The game remained popular for 700 or 800 years, but, although it was taken to England, it is doubtful whether it can be considered as a forerunner of contemporary football.

E

The game that flourished in Britain from the 8th to the 19th centuries was substantially different from all the previously known forms – more disorganised, more violent, more spontaneous and usually played by an indefinite number of players. Frequently, the games took the form of a heated contest between whole villages. Kicking opponents were allowed, as in fact was almost everything else.

F

There was tremendous enthusiasm for football, even though the authorities repeatedly intervened to restrict it, as a public nuisance. In the 14th and 15th centuries, England, Scotland and France all made football punishable by law, because of the disorder that commonly accompanied it, or because the well-loved recreation prevented subjects from practicing more useful military disciplines. None of these efforts had much effect.

G

The English passion for football was particularly strong in the 16th century, influenced by the popularity of the rather better organised Italian game of ‘calcio’. English football was as rough as ever, but it found a prominent supporter in the school headmaster Richard Mulcaster. He pointed out that it had positive educational value and promoted health and strength. Mulcaster claimed that all that was needed was to refine it a little, limit the number of participants in each team and, more importantly, have a referee to oversee the game.

H

The game persisted in a disorganised form until the early 19th century, when a number of influential English schools developed their own adaptations. In some, including Rugby School, the ball could be touched with the hands or carried; opponents could be tripped up and even kicked. It was recognised in educational circles that, as a team game, football helped to develop such fine qualities as loyalty, selflessness, cooperation, subordination and deference to the team spirit. A ‘games cult’ developed in schools and some form of football became an obligatory part of the curriculum.

I

In 1863, developments reached a climax. At Cambridge University, an initiative began to establish some uniform standards and rules that would be accepted by everyone, but there were essentially two camps: the minority – Rugby School and some others – wished to continue with their own form of the game, in particular allowing players to carry the ball. In October of the same year, eleven London clubs and schools sent representatives to establish a set of fundamental rules to govern the matches played amongst them. This meeting marked the birth of the Football Association.

J

The dispute concerning kicking and tripping opponents and carrying the ball was discussed thoroughly at this and subsequent meetings, until eventually, on 8 December, the die-hard exponents of the Rugby style withdrew, marking a final split between rugby and football. Within eight years, the Football Association already had 50 member clubs, and the first football competition in the world was started – the FA Cup.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c72bb9b-59d6-5d70-a6dc-b5af28cbd019', 'a1869acb-4409-5eed-b8f1-4469bb777898', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage 1 has ten paragraphs
A-J
.
Choose the correct headings for paragraphs
D-J
from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of Headings
i
Limited success in suppressing the game
ii
Opposition to the role of football in schools
iii
A way of developing moral values
iv
Football matches between countries
v
A game that has survived
vi
Separation into two sports
vii
Proposals for minor improvements
viii
Attempts to standardize the game
ix
Probably not an early version of football
x
A chaotic activity with virtually no rules
Example
Paragraph
C
Answer v
1
Paragraph D
2
Paragraph E
3
Paragraph F
4
Paragraph G
5
Paragraph H
6
Paragraph I
7
Paragraph J

1 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b426c936-7a34-54d3-93e7-fa0ca96698ed', '4c72bb9b-59d6-5d70-a6dc-b5af28cbd019', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc631a02-3503-58f5-9f0b-0fd308e2f873', '4c72bb9b-59d6-5d70-a6dc-b5af28cbd019', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a36f876-e9e5-5bc7-807a-3a6f9e64ea69', '4c72bb9b-59d6-5d70-a6dc-b5af28cbd019', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3c73e98-4adf-5e8f-ba88-08926cf7e846', '4c72bb9b-59d6-5d70-a6dc-b5af28cbd019', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c7074cd-dad5-5ae9-9fd2-27cffa611a16', '4c72bb9b-59d6-5d70-a6dc-b5af28cbd019', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d75497fa-1242-5153-b400-17f805741e74', '4c72bb9b-59d6-5d70-a6dc-b5af28cbd019', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3501e8d0-a06b-5c5e-87c2-ac945391c5cf', '4c72bb9b-59d6-5d70-a6dc-b5af28cbd019', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c50fc2f4-0ba4-5db2-916d-5b9b52e6273d', '4c72bb9b-59d6-5d70-a6dc-b5af28cbd019', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c8b10c7-4019-534c-ac45-b363c25c7fbb', '4c72bb9b-59d6-5d70-a6dc-b5af28cbd019', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3701347-5fec-5192-b317-aa3699b5b6f3', '4c72bb9b-59d6-5d70-a6dc-b5af28cbd019', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('108dc9f5-48b2-552c-95a5-9413d000539f', 'a1869acb-4409-5eed-b8f1-4469bb777898', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage 1 has ten paragraphs
A-J
.
Choose the correct headings for paragraphs
D-J
from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of Headings
i
Limited success in suppressing the game
ii
Opposition to the role of football in schools
iii
A way of developing moral values
iv
Football matches between countries
v
A game that has survived
vi
Separation into two sports
vii
Proposals for minor improvements
viii
Attempts to standardize the game
ix
Probably not an early version of football
x
A chaotic activity with virtually no rules
Example
Paragraph
C
Answer v
1
Paragraph D
2
Paragraph E
3
Paragraph F
4
Paragraph G
5
Paragraph H
6
Paragraph I
7
Paragraph J

2 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a79a76f-2df1-53e5-a789-38276c781581', '108dc9f5-48b2-552c-95a5-9413d000539f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ac67fdc-b10c-54e8-a285-35d51d418b05', '108dc9f5-48b2-552c-95a5-9413d000539f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ed04fd3-7890-5a62-870e-76ed1cdb2faa', '108dc9f5-48b2-552c-95a5-9413d000539f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6ee05f3-be58-5a0e-9d32-19f2469cf866', '108dc9f5-48b2-552c-95a5-9413d000539f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95cc4de2-2d1b-54cc-b804-4638e8b2ab87', '108dc9f5-48b2-552c-95a5-9413d000539f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3fe97225-f8c4-5010-8589-445a46e0666d', '108dc9f5-48b2-552c-95a5-9413d000539f', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9070e081-cee8-5a55-a8d7-6ec16f1c4833', '108dc9f5-48b2-552c-95a5-9413d000539f', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a31326a4-bd8e-5308-95d9-6f3a0b397a02', '108dc9f5-48b2-552c-95a5-9413d000539f', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc49f2d8-4c70-5d59-9d89-edd3db5bc34a', '108dc9f5-48b2-552c-95a5-9413d000539f', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bef2d6c3-c494-5093-83fe-d5597fea3589', '108dc9f5-48b2-552c-95a5-9413d000539f', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('010884ba-0f10-5e5a-acd8-f66228543f3e', 'a1869acb-4409-5eed-b8f1-4469bb777898', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage 1 has ten paragraphs
A-J
.
Choose the correct headings for paragraphs
D-J
from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of Headings
i
Limited success in suppressing the game
ii
Opposition to the role of football in schools
iii
A way of developing moral values
iv
Football matches between countries
v
A game that has survived
vi
Separation into two sports
vii
Proposals for minor improvements
viii
Attempts to standardize the game
ix
Probably not an early version of football
x
A chaotic activity with virtually no rules
Example
Paragraph
C
Answer v
1
Paragraph D
2
Paragraph E
3
Paragraph F
4
Paragraph G
5
Paragraph H
6
Paragraph I
7
Paragraph J

3 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4625ff71-1f5a-5b68-8e12-686f33544281', '010884ba-0f10-5e5a-acd8-f66228543f3e', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b32390e-57ce-5ff0-9b71-4c1f029dfdda', '010884ba-0f10-5e5a-acd8-f66228543f3e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('964b43e0-4a8b-5344-92c1-8c9ea18f3a85', '010884ba-0f10-5e5a-acd8-f66228543f3e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2183186-29e5-552c-9275-93c7d1052187', '010884ba-0f10-5e5a-acd8-f66228543f3e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e735e7c5-c07a-5e91-83d3-f49be34c956b', '010884ba-0f10-5e5a-acd8-f66228543f3e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75bc41a8-af6a-546d-9233-eb38fa405b7f', '010884ba-0f10-5e5a-acd8-f66228543f3e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61d71985-2c04-5e28-8ff9-0df95f0b0404', '010884ba-0f10-5e5a-acd8-f66228543f3e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75aad47e-9ace-5b4a-a810-bd8d3cdff418', '010884ba-0f10-5e5a-acd8-f66228543f3e', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf9b80db-e453-59b3-b7f4-05370b52475b', '010884ba-0f10-5e5a-acd8-f66228543f3e', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e3bb3db-49e2-5e1f-a27b-224a1a78b017', '010884ba-0f10-5e5a-acd8-f66228543f3e', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('80b748fe-28b6-53c4-86e8-fa2c04794085', 'a1869acb-4409-5eed-b8f1-4469bb777898', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage 1 has ten paragraphs
A-J
.
Choose the correct headings for paragraphs
D-J
from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of Headings
i
Limited success in suppressing the game
ii
Opposition to the role of football in schools
iii
A way of developing moral values
iv
Football matches between countries
v
A game that has survived
vi
Separation into two sports
vii
Proposals for minor improvements
viii
Attempts to standardize the game
ix
Probably not an early version of football
x
A chaotic activity with virtually no rules
Example
Paragraph
C
Answer v
1
Paragraph D
2
Paragraph E
3
Paragraph F
4
Paragraph G
5
Paragraph H
6
Paragraph I
7
Paragraph J

4 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b2e16bc-ab06-55dc-a46c-54629c0f60f7', '80b748fe-28b6-53c4-86e8-fa2c04794085', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77123c2f-a3c8-59f1-ab75-a393177505ff', '80b748fe-28b6-53c4-86e8-fa2c04794085', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c38676f5-06f3-5934-b490-2215e8f98c38', '80b748fe-28b6-53c4-86e8-fa2c04794085', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c80f35a-c5e7-552b-b156-8d4bab676cd1', '80b748fe-28b6-53c4-86e8-fa2c04794085', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa6784a2-cb33-5686-b123-3ea99e155b7b', '80b748fe-28b6-53c4-86e8-fa2c04794085', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01655d42-7b4a-5a7c-9977-21016931e0f2', '80b748fe-28b6-53c4-86e8-fa2c04794085', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4703d07b-b14e-5d33-b89a-f663a154c64a', '80b748fe-28b6-53c4-86e8-fa2c04794085', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98b6c93d-291f-5d5b-82b2-76b2e8fd5687', '80b748fe-28b6-53c4-86e8-fa2c04794085', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5f4d0e0-fe97-5013-a258-e1d680759418', '80b748fe-28b6-53c4-86e8-fa2c04794085', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a4a67b5-d04f-5cf9-a708-fd87804485d7', '80b748fe-28b6-53c4-86e8-fa2c04794085', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df5bce33-7939-553e-af3d-6104e7015602', 'a1869acb-4409-5eed-b8f1-4469bb777898', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage 1 has ten paragraphs
A-J
.
Choose the correct headings for paragraphs
D-J
from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of Headings
i
Limited success in suppressing the game
ii
Opposition to the role of football in schools
iii
A way of developing moral values
iv
Football matches between countries
v
A game that has survived
vi
Separation into two sports
vii
Proposals for minor improvements
viii
Attempts to standardize the game
ix
Probably not an early version of football
x
A chaotic activity with virtually no rules
Example
Paragraph
C
Answer v
1
Paragraph D
2
Paragraph E
3
Paragraph F
4
Paragraph G
5
Paragraph H
6
Paragraph I
7
Paragraph J

5 ____ Paragraph H$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad846a20-8caf-5a59-b644-516e0d657a82', 'df5bce33-7939-553e-af3d-6104e7015602', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('baab8495-08b2-5a17-b86a-f00d755090e2', 'df5bce33-7939-553e-af3d-6104e7015602', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a1d7998-b634-5855-b90c-981d5e88cd58', 'df5bce33-7939-553e-af3d-6104e7015602', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2abc05c-621b-5bc5-9d86-a5b96396ddb9', 'df5bce33-7939-553e-af3d-6104e7015602', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('054d99dd-d6d0-5105-8b37-2b17f512d1b5', 'df5bce33-7939-553e-af3d-6104e7015602', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3767a45d-171f-5e2a-8634-e78d763ffba1', 'df5bce33-7939-553e-af3d-6104e7015602', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3215ede1-9442-5854-80e1-a438789e9af4', 'df5bce33-7939-553e-af3d-6104e7015602', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc95c9fa-4636-5d70-86d0-1c86d6b2d587', 'df5bce33-7939-553e-af3d-6104e7015602', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57d6d2dc-4d72-5ae6-944d-ad2927d74d8f', 'df5bce33-7939-553e-af3d-6104e7015602', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a38a4cc7-8ec6-5201-872c-def96010f104', 'df5bce33-7939-553e-af3d-6104e7015602', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('06033a4d-620c-53f1-9d35-8be1a405f661', 'a1869acb-4409-5eed-b8f1-4469bb777898', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage 1 has ten paragraphs
A-J
.
Choose the correct headings for paragraphs
D-J
from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of Headings
i
Limited success in suppressing the game
ii
Opposition to the role of football in schools
iii
A way of developing moral values
iv
Football matches between countries
v
A game that has survived
vi
Separation into two sports
vii
Proposals for minor improvements
viii
Attempts to standardize the game
ix
Probably not an early version of football
x
A chaotic activity with virtually no rules
Example
Paragraph
C
Answer v
1
Paragraph D
2
Paragraph E
3
Paragraph F
4
Paragraph G
5
Paragraph H
6
Paragraph I
7
Paragraph J

6 ____ Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39d2f535-daa6-5b4b-9c67-77e8cf8c5b4f', '06033a4d-620c-53f1-9d35-8be1a405f661', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4744b4c4-1971-5da2-986c-1659d93f45ee', '06033a4d-620c-53f1-9d35-8be1a405f661', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84804cb7-c879-50b1-8528-9fc2db0948fe', '06033a4d-620c-53f1-9d35-8be1a405f661', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1fec90a-8ec7-5c9d-8d36-6d1d9d9e7ce1', '06033a4d-620c-53f1-9d35-8be1a405f661', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('376eb2ac-c3a3-5252-ab2b-67a7c3b24048', '06033a4d-620c-53f1-9d35-8be1a405f661', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0c44a99-f3f9-5739-8bf6-f72c8c38829f', '06033a4d-620c-53f1-9d35-8be1a405f661', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aecd9c1e-3989-53c5-bb12-866aeffca1eb', '06033a4d-620c-53f1-9d35-8be1a405f661', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5562d7da-e909-5f3d-bc1e-ea0732e598d2', '06033a4d-620c-53f1-9d35-8be1a405f661', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f527d429-876f-5cdd-a1f0-14f7664b6ac5', '06033a4d-620c-53f1-9d35-8be1a405f661', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d4f9c50-a6aa-5088-a502-5ba417c1d30b', '06033a4d-620c-53f1-9d35-8be1a405f661', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eb4af5fa-9e3f-5e87-a28b-86e6cbfd7f27', 'a1869acb-4409-5eed-b8f1-4469bb777898', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage 1 has ten paragraphs
A-J
.
Choose the correct headings for paragraphs
D-J
from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of Headings
i
Limited success in suppressing the game
ii
Opposition to the role of football in schools
iii
A way of developing moral values
iv
Football matches between countries
v
A game that has survived
vi
Separation into two sports
vii
Proposals for minor improvements
viii
Attempts to standardize the game
ix
Probably not an early version of football
x
A chaotic activity with virtually no rules
Example
Paragraph
C
Answer v
1
Paragraph D
2
Paragraph E
3
Paragraph F
4
Paragraph G
5
Paragraph H
6
Paragraph I
7
Paragraph J

7 ____ Paragraph J$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8274af9-2348-5b61-b3d6-1ff50a0c603b', 'eb4af5fa-9e3f-5e87-a28b-86e6cbfd7f27', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2b3341f-b766-5ecf-a3d3-308804fa0d39', 'eb4af5fa-9e3f-5e87-a28b-86e6cbfd7f27', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fc1bfb7-34da-5084-a1c7-bd5882f84d60', 'eb4af5fa-9e3f-5e87-a28b-86e6cbfd7f27', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d1fcd58-956d-5ada-8dea-29fa72d1843e', 'eb4af5fa-9e3f-5e87-a28b-86e6cbfd7f27', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3a922bb-8abc-5433-9ad8-ae521323f4cb', 'eb4af5fa-9e3f-5e87-a28b-86e6cbfd7f27', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9e188fd-c6d1-502e-af3d-e60310c5ac90', 'eb4af5fa-9e3f-5e87-a28b-86e6cbfd7f27', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('627f9bfb-38dd-5535-afa1-916eca7a1eaa', 'eb4af5fa-9e3f-5e87-a28b-86e6cbfd7f27', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01380f25-b56d-5b77-a20d-6ef37261900d', 'eb4af5fa-9e3f-5e87-a28b-86e6cbfd7f27', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d4449ed-06d9-5c8c-8497-12636c7db23e', 'eb4af5fa-9e3f-5e87-a28b-86e6cbfd7f27', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('685eedad-4e1c-5f09-837e-d96725872494', 'eb4af5fa-9e3f-5e87-a28b-86e6cbfd7f27', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d6c26055-5259-5c7d-a338-6dec6603da54', 'a1869acb-4409-5eed-b8f1-4469bb777898', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Complete each sentence with the correct ending
A-I
from the box below.
Write the correct letter
A-I
in boxes
8-13
on your answer sheet.
8
Tsu’chu
9
Kemari
10
Harpastum
11
From the 8th centuries, football in the British Isles
12
In the past, the authorities legitimately despised the football and acted on the belief that football.
13
When it was accepted in academic settings, football.
A
was seen as something to be encouraged in the young.
B
involved individual players having different responsibilities.
C
was influenced by a game from another country.
D
was a cooperative effort by all the players.
E
distracted people from more important activities.
F
was played by teams of a fixed size.
G
was less popular than it later became.
H
was often played by one community against another.
I
formed part of a celebration.

8 ____ Tsu’chu$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05d8785b-8397-56c3-aa0b-57fb36eb82a6', 'd6c26055-5259-5c7d-a338-6dec6603da54', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d543b66-935c-5ed6-9b9e-e252fb30ebb3', 'd6c26055-5259-5c7d-a338-6dec6603da54', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f76de5b-cf4e-5283-8d90-44a8809b59c4', 'd6c26055-5259-5c7d-a338-6dec6603da54', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c46070fd-e382-5485-a96e-63de1100aaae', 'd6c26055-5259-5c7d-a338-6dec6603da54', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abd8a6a4-fe1d-5ee4-b610-c085d8e99a63', 'd6c26055-5259-5c7d-a338-6dec6603da54', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2dcd6f2-494f-5702-bbf4-0e549417af37', 'd6c26055-5259-5c7d-a338-6dec6603da54', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5877cd3-4b5a-55d8-b71f-df848968a81a', 'd6c26055-5259-5c7d-a338-6dec6603da54', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49fa02f4-aded-5d2e-b3ba-1802c7bddb89', 'd6c26055-5259-5c7d-a338-6dec6603da54', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('505fe82f-cbfa-5ebe-b0d7-9b4d99dd5db4', 'd6c26055-5259-5c7d-a338-6dec6603da54', 9, $md$I$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('de0c9df1-be38-57dc-8003-a2201e4a0c19', 'a1869acb-4409-5eed-b8f1-4469bb777898', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Complete each sentence with the correct ending
A-I
from the box below.
Write the correct letter
A-I
in boxes
8-13
on your answer sheet.
8
Tsu’chu
9
Kemari
10
Harpastum
11
From the 8th centuries, football in the British Isles
12
In the past, the authorities legitimately despised the football and acted on the belief that football.
13
When it was accepted in academic settings, football.
A
was seen as something to be encouraged in the young.
B
involved individual players having different responsibilities.
C
was influenced by a game from another country.
D
was a cooperative effort by all the players.
E
distracted people from more important activities.
F
was played by teams of a fixed size.
G
was less popular than it later became.
H
was often played by one community against another.
I
formed part of a celebration.

9 ____ Kemari$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dec5a103-97c2-5f6f-bf36-64f42260b962', 'de0c9df1-be38-57dc-8003-a2201e4a0c19', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6263b95a-90eb-5971-ba66-cb135583e88b', 'de0c9df1-be38-57dc-8003-a2201e4a0c19', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01e5219d-0497-5cd2-ae90-e24a9ceee7b3', 'de0c9df1-be38-57dc-8003-a2201e4a0c19', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5286eeb-84bb-542c-88e3-0133533af87d', 'de0c9df1-be38-57dc-8003-a2201e4a0c19', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42d51520-458c-5a0a-b673-80152b73fae5', 'de0c9df1-be38-57dc-8003-a2201e4a0c19', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54dba3c2-573a-5a8c-a356-fa7ddd5fc93e', 'de0c9df1-be38-57dc-8003-a2201e4a0c19', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85567a29-b9d3-5eb6-b169-6a56e70c0a72', 'de0c9df1-be38-57dc-8003-a2201e4a0c19', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a3e61b3-4d31-5fb4-a995-444e37e0545b', 'de0c9df1-be38-57dc-8003-a2201e4a0c19', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1df09f4-4f09-51ed-b752-e0b311a08a96', 'de0c9df1-be38-57dc-8003-a2201e4a0c19', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7a191539-e2cc-5bb5-bdf4-b0a16c51b21e', 'a1869acb-4409-5eed-b8f1-4469bb777898', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Complete each sentence with the correct ending
A-I
from the box below.
Write the correct letter
A-I
in boxes
8-13
on your answer sheet.
8
Tsu’chu
9
Kemari
10
Harpastum
11
From the 8th centuries, football in the British Isles
12
In the past, the authorities legitimately despised the football and acted on the belief that football.
13
When it was accepted in academic settings, football.
A
was seen as something to be encouraged in the young.
B
involved individual players having different responsibilities.
C
was influenced by a game from another country.
D
was a cooperative effort by all the players.
E
distracted people from more important activities.
F
was played by teams of a fixed size.
G
was less popular than it later became.
H
was often played by one community against another.
I
formed part of a celebration.

10 ____ Harpastum$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a35aced5-858a-59da-9e18-e146645b1521', '7a191539-e2cc-5bb5-bdf4-b0a16c51b21e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6505a2fe-c9ff-58c4-bce4-0d5b7da54d96', '7a191539-e2cc-5bb5-bdf4-b0a16c51b21e', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7544a905-a5af-508e-8227-383b0e37ff7c', '7a191539-e2cc-5bb5-bdf4-b0a16c51b21e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17f1d554-5bd1-50e6-b2d9-b8ab2c230598', '7a191539-e2cc-5bb5-bdf4-b0a16c51b21e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae9c0ff2-4436-5339-be32-83b519194e33', '7a191539-e2cc-5bb5-bdf4-b0a16c51b21e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7434ca62-560c-5fd4-a197-2314c8279ce8', '7a191539-e2cc-5bb5-bdf4-b0a16c51b21e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e09dc17-c1dd-5f47-bf97-0946ec1231d0', '7a191539-e2cc-5bb5-bdf4-b0a16c51b21e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ef3f80a-72e8-51f0-b438-4596caa155b5', '7a191539-e2cc-5bb5-bdf4-b0a16c51b21e', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ff1b5f5-6aaf-5235-be1f-eedc288b52ab', '7a191539-e2cc-5bb5-bdf4-b0a16c51b21e', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d19bc856-ea76-5c5b-b80e-58487d0a007e', 'a1869acb-4409-5eed-b8f1-4469bb777898', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Complete each sentence with the correct ending
A-I
from the box below.
Write the correct letter
A-I
in boxes
8-13
on your answer sheet.
8
Tsu’chu
9
Kemari
10
Harpastum
11
From the 8th centuries, football in the British Isles
12
In the past, the authorities legitimately despised the football and acted on the belief that football.
13
When it was accepted in academic settings, football.
A
was seen as something to be encouraged in the young.
B
involved individual players having different responsibilities.
C
was influenced by a game from another country.
D
was a cooperative effort by all the players.
E
distracted people from more important activities.
F
was played by teams of a fixed size.
G
was less popular than it later became.
H
was often played by one community against another.
I
formed part of a celebration.

11 ____ From the 8th centuries, football in the British Isles$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b36cda42-8386-5f1c-8883-ad84618b8c7e', 'd19bc856-ea76-5c5b-b80e-58487d0a007e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e1db815-9bb1-5931-9828-c07315cea99c', 'd19bc856-ea76-5c5b-b80e-58487d0a007e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01e15e86-d7bc-5bec-ba13-0f3730e771cc', 'd19bc856-ea76-5c5b-b80e-58487d0a007e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6718da96-95ed-5aec-83c0-6734774ef78c', 'd19bc856-ea76-5c5b-b80e-58487d0a007e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b407868-847e-5957-89a1-79dc4a5be8b1', 'd19bc856-ea76-5c5b-b80e-58487d0a007e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5261c2a8-4933-5e95-a318-11b3d1cfafd7', 'd19bc856-ea76-5c5b-b80e-58487d0a007e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d828a33c-d510-5629-b231-3c81bf260047', 'd19bc856-ea76-5c5b-b80e-58487d0a007e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f00e47a4-c471-524f-b608-c2453ef770cb', 'd19bc856-ea76-5c5b-b80e-58487d0a007e', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1be21409-2292-598d-aa6a-23e10f914ff3', 'd19bc856-ea76-5c5b-b80e-58487d0a007e', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0d4019c7-d76a-5085-beb2-47ee4ae33314', 'a1869acb-4409-5eed-b8f1-4469bb777898', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Complete each sentence with the correct ending
A-I
from the box below.
Write the correct letter
A-I
in boxes
8-13
on your answer sheet.
8
Tsu’chu
9
Kemari
10
Harpastum
11
From the 8th centuries, football in the British Isles
12
In the past, the authorities legitimately despised the football and acted on the belief that football.
13
When it was accepted in academic settings, football.
A
was seen as something to be encouraged in the young.
B
involved individual players having different responsibilities.
C
was influenced by a game from another country.
D
was a cooperative effort by all the players.
E
distracted people from more important activities.
F
was played by teams of a fixed size.
G
was less popular than it later became.
H
was often played by one community against another.
I
formed part of a celebration.

12 ____ In the past, the authorities legitimately despised the football and acted on the belief that football.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b7cafab-b340-56ba-bcdf-9ebe412fc8dc', '0d4019c7-d76a-5085-beb2-47ee4ae33314', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a72900d8-29aa-5c3e-b744-19d4abc25ba5', '0d4019c7-d76a-5085-beb2-47ee4ae33314', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6832732d-8ccd-523f-b9f9-90967d83aaa4', '0d4019c7-d76a-5085-beb2-47ee4ae33314', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('323c8e49-21bf-5f90-8a78-a9ab5b58ab4d', '0d4019c7-d76a-5085-beb2-47ee4ae33314', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ffb5e6e-d2a8-5490-bc2e-d8f04dfb3c50', '0d4019c7-d76a-5085-beb2-47ee4ae33314', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad680249-10ac-590d-b298-3f9aa5166487', '0d4019c7-d76a-5085-beb2-47ee4ae33314', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1773625e-0de6-5e25-b805-f78b83002912', '0d4019c7-d76a-5085-beb2-47ee4ae33314', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0829b907-402f-5f57-aef0-b1fa40653f8d', '0d4019c7-d76a-5085-beb2-47ee4ae33314', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7cde7c0-69b9-5327-a787-fc7167f08bd3', '0d4019c7-d76a-5085-beb2-47ee4ae33314', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ba59d1c3-1cdf-5f38-96c2-aeef8a7113a2', 'a1869acb-4409-5eed-b8f1-4469bb777898', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Complete each sentence with the correct ending
A-I
from the box below.
Write the correct letter
A-I
in boxes
8-13
on your answer sheet.
8
Tsu’chu
9
Kemari
10
Harpastum
11
From the 8th centuries, football in the British Isles
12
In the past, the authorities legitimately despised the football and acted on the belief that football.
13
When it was accepted in academic settings, football.
A
was seen as something to be encouraged in the young.
B
involved individual players having different responsibilities.
C
was influenced by a game from another country.
D
was a cooperative effort by all the players.
E
distracted people from more important activities.
F
was played by teams of a fixed size.
G
was less popular than it later became.
H
was often played by one community against another.
I
formed part of a celebration.

13 ____ When it was accepted in academic settings, football.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc7bf3d6-d24d-5ca2-9dcb-dc7794a49221', 'ba59d1c3-1cdf-5f38-96c2-aeef8a7113a2', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81d0a43e-cfa2-5bc4-965d-7e21a0eaa088', 'ba59d1c3-1cdf-5f38-96c2-aeef8a7113a2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46bfc285-b8d2-50c4-94cd-168a24c7bf96', 'ba59d1c3-1cdf-5f38-96c2-aeef8a7113a2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbe06f7f-3b2b-5103-bcab-250ac377b45d', 'ba59d1c3-1cdf-5f38-96c2-aeef8a7113a2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('121938ba-e1b7-56be-b77d-7e83eea70af3', 'ba59d1c3-1cdf-5f38-96c2-aeef8a7113a2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('776d3f65-64f1-54dd-add1-1381b8a55e9f', 'ba59d1c3-1cdf-5f38-96c2-aeef8a7113a2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9cdaa8ef-70a3-54bf-a2c8-c6ad362d2758', 'ba59d1c3-1cdf-5f38-96c2-aeef8a7113a2', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa9f3d1c-8a44-5fdf-ac10-a35226cb99a4', 'ba59d1c3-1cdf-5f38-96c2-aeef8a7113a2', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99b37526-585f-52d3-885a-09feb9311dcc', 'ba59d1c3-1cdf-5f38-96c2-aeef8a7113a2', 9, $md$I$md$, false);

COMMIT;
