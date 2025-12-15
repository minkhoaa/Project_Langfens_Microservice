BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-going-nowhere-fast-1359'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-going-nowhere-fast-1359';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-going-nowhere-fast-1359';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-going-nowhere-fast-1359';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d337de07-473b-5e90-8aa7-d3d958bdd435', 'ielts-reading-going-nowhere-fast-1359', $t$Going nowhere fast$t$, $md$## Going nowhere fast

Nguồn:
- Test: https://mini-ielts.com/1359/reading/going-nowhere-fast
- Solution: https://mini-ielts.com/1359/view-solution/reading/going-nowhere-fast$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3fbb9560-2c9d-56e8-9342-daddef81983f', 'd337de07-473b-5e90-8aa7-d3d958bdd435', 1, $t$Reading — Going nowhere fast$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Going nowhere fast

New transport mode PRT RUF$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1e923275-1010-5d27-ab79-992de747a7c8', '3fbb9560-2c9d-56e8-9342-daddef81983f', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
In boxes 1-4 on your answer sheet, write
True
If the statement is true
False
If the statement is false
Not Given
If the information is not given in the passage
1
City transport developed slower than other means of communication
2
Many states in the US consider reducing cars growth
3
Car pollution has been a concern these days
4
Trains and buses are not suitable to drive on an uphill road

1 ____ City transport developed slower than other means of communication$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfad4f2e-f2c7-5568-aef0-d8970c45742b', '1e923275-1010-5d27-ab79-992de747a7c8', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d746bff9-52b5-506b-9ac3-b48e44d3165d', '1e923275-1010-5d27-ab79-992de747a7c8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3643e629-a5a1-5c30-a338-4e8bf6bc218c', '1e923275-1010-5d27-ab79-992de747a7c8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('083c7b0b-d3fa-525e-ac15-82246933ed7e', '3fbb9560-2c9d-56e8-9342-daddef81983f', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
In boxes 1-4 on your answer sheet, write
True
If the statement is true
False
If the statement is false
Not Given
If the information is not given in the passage
1
City transport developed slower than other means of communication
2
Many states in the US consider reducing cars growth
3
Car pollution has been a concern these days
4
Trains and buses are not suitable to drive on an uphill road

2 ____ Many states in the US consider reducing cars growth$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55eb17c3-07f2-568f-b2da-94cd5d5757ac', '083c7b0b-d3fa-525e-ac15-82246933ed7e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7b975c8-e80a-58ad-ac3c-eb14ab91dcd7', '083c7b0b-d3fa-525e-ac15-82246933ed7e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f682b374-7fb3-5e47-9afb-72ffea48493b', '083c7b0b-d3fa-525e-ac15-82246933ed7e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0a81eaf2-03ff-544d-bc5e-e2afb44aed51', '3fbb9560-2c9d-56e8-9342-daddef81983f', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
In boxes 1-4 on your answer sheet, write
True
If the statement is true
False
If the statement is false
Not Given
If the information is not given in the passage
1
City transport developed slower than other means of communication
2
Many states in the US consider reducing cars growth
3
Car pollution has been a concern these days
4
Trains and buses are not suitable to drive on an uphill road

3 ____ Car pollution has been a concern these days$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14c749b9-3eeb-5fff-b9ec-a955c2f30c84', '0a81eaf2-03ff-544d-bc5e-e2afb44aed51', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf4b7bb0-2503-53c9-87aa-e2e0a241a5b7', '0a81eaf2-03ff-544d-bc5e-e2afb44aed51', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68d05ad8-86f8-5bd4-bb2d-77093101d4ec', '0a81eaf2-03ff-544d-bc5e-e2afb44aed51', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c014e925-9445-5e3b-a20c-73792a4f7c9e', '3fbb9560-2c9d-56e8-9342-daddef81983f', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
In boxes 1-4 on your answer sheet, write
True
If the statement is true
False
If the statement is false
Not Given
If the information is not given in the passage
1
City transport developed slower than other means of communication
2
Many states in the US consider reducing cars growth
3
Car pollution has been a concern these days
4
Trains and buses are not suitable to drive on an uphill road

4 ____ Trains and buses are not suitable to drive on an uphill road$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4fb0950b-b215-54c2-88f8-d84d08da7351', 'c014e925-9445-5e3b-a20c-73792a4f7c9e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3012162d-17e8-5fd1-9771-d68c3b8e2012', 'c014e925-9445-5e3b-a20c-73792a4f7c9e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3159cc11-a875-51b9-9ca1-f2184132a33f', 'c014e925-9445-5e3b-a20c-73792a4f7c9e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c5791e97-9908-503d-9fec-a1c62cbbe8c5', '3fbb9560-2c9d-56e8-9342-daddef81983f', 5, 'CLASSIFICATION', 'READING', 3, $md$### Question 5

Questions 5-11
Questions 5-11
Use the information in the passage to match the category (listed A-C) with the description below. Write the appropriate letters A-C in boxes 5-11 on your answer sheet.
[A]
ONLY PRT
[B]
ONLY RUF
[C]
BOTH OF THEM
5
Totally apply computer system
6
Opposition to a system from companies
7
Reach destination fast
8
Not necessary to share with the public
9
Work on the existing road
10
Individuals can buy cars after all
11
Controlled both by computer and manual

5 ____ Totally apply computer system$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44d70b57-6a68-5ed6-855c-d9979681fc88', 'c5791e97-9908-503d-9fec-a1c62cbbe8c5', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9721a5f5-1b4d-59d2-bb00-cc2c9f764f39', 'c5791e97-9908-503d-9fec-a1c62cbbe8c5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69e8efc9-c01c-5ce1-9615-f60a1bb9f52e', 'c5791e97-9908-503d-9fec-a1c62cbbe8c5', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eef3a920-5364-5c08-b02a-e193fa6fe93d', '3fbb9560-2c9d-56e8-9342-daddef81983f', 6, 'CLASSIFICATION', 'READING', 3, $md$### Question 6

Questions 5-11
Questions 5-11
Use the information in the passage to match the category (listed A-C) with the description below. Write the appropriate letters A-C in boxes 5-11 on your answer sheet.
[A]
ONLY PRT
[B]
ONLY RUF
[C]
BOTH OF THEM
5
Totally apply computer system
6
Opposition to a system from companies
7
Reach destination fast
8
Not necessary to share with the public
9
Work on the existing road
10
Individuals can buy cars after all
11
Controlled both by computer and manual

6 ____ Opposition to a system from companies$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1649393-df6a-5864-9acb-f89a9b89bff9', 'eef3a920-5364-5c08-b02a-e193fa6fe93d', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e35aeb6-6ef9-5c3e-88bc-b9ed036dc12f', 'eef3a920-5364-5c08-b02a-e193fa6fe93d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d63b3009-fcb8-5751-b50d-f991f90ad22d', 'eef3a920-5364-5c08-b02a-e193fa6fe93d', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1cf4e7b-87a6-5f62-8fdc-4d325bd52f7e', '3fbb9560-2c9d-56e8-9342-daddef81983f', 7, 'CLASSIFICATION', 'READING', 3, $md$### Question 7

Questions 5-11
Questions 5-11
Use the information in the passage to match the category (listed A-C) with the description below. Write the appropriate letters A-C in boxes 5-11 on your answer sheet.
[A]
ONLY PRT
[B]
ONLY RUF
[C]
BOTH OF THEM
5
Totally apply computer system
6
Opposition to a system from companies
7
Reach destination fast
8
Not necessary to share with the public
9
Work on the existing road
10
Individuals can buy cars after all
11
Controlled both by computer and manual

7 ____ Reach destination fast$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4618fea5-a78a-5157-ad58-78e7639c1da1', 'e1cf4e7b-87a6-5f62-8fdc-4d325bd52f7e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4efc4a08-7b89-5823-a130-2ff326ef7705', 'e1cf4e7b-87a6-5f62-8fdc-4d325bd52f7e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0d11e7b-e118-50a4-bfd8-f426de276daa', 'e1cf4e7b-87a6-5f62-8fdc-4d325bd52f7e', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b78125de-ff1e-5680-a521-f8380cd91057', '3fbb9560-2c9d-56e8-9342-daddef81983f', 8, 'CLASSIFICATION', 'READING', 3, $md$### Question 8

Questions 5-11
Questions 5-11
Use the information in the passage to match the category (listed A-C) with the description below. Write the appropriate letters A-C in boxes 5-11 on your answer sheet.
[A]
ONLY PRT
[B]
ONLY RUF
[C]
BOTH OF THEM
5
Totally apply computer system
6
Opposition to a system from companies
7
Reach destination fast
8
Not necessary to share with the public
9
Work on the existing road
10
Individuals can buy cars after all
11
Controlled both by computer and manual

8 ____ Not necessary to share with the public$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('731cd965-82bb-54a0-88b9-2846291fbcfb', 'b78125de-ff1e-5680-a521-f8380cd91057', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('025b0ebe-5bd1-5d94-badf-1403e3155325', 'b78125de-ff1e-5680-a521-f8380cd91057', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82e30ab1-37ba-5ae8-a241-b8e2cb51e739', 'b78125de-ff1e-5680-a521-f8380cd91057', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b50ee556-5d6f-58c7-9e5f-597e6e07d8c6', '3fbb9560-2c9d-56e8-9342-daddef81983f', 9, 'CLASSIFICATION', 'READING', 3, $md$### Question 9

Questions 5-11
Questions 5-11
Use the information in the passage to match the category (listed A-C) with the description below. Write the appropriate letters A-C in boxes 5-11 on your answer sheet.
[A]
ONLY PRT
[B]
ONLY RUF
[C]
BOTH OF THEM
5
Totally apply computer system
6
Opposition to a system from companies
7
Reach destination fast
8
Not necessary to share with the public
9
Work on the existing road
10
Individuals can buy cars after all
11
Controlled both by computer and manual

9 ____ Work on the existing road$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5bef4823-32f4-5ce9-9a6c-ce95b3245e48', 'b50ee556-5d6f-58c7-9e5f-597e6e07d8c6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('146f4054-ab6b-59f2-995f-840a6368a627', 'b50ee556-5d6f-58c7-9e5f-597e6e07d8c6', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b4ecabb-3df9-5d13-b961-1104a189e7b2', 'b50ee556-5d6f-58c7-9e5f-597e6e07d8c6', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cb3614a6-6c00-5a1e-a768-626eb2ab0d20', '3fbb9560-2c9d-56e8-9342-daddef81983f', 10, 'CLASSIFICATION', 'READING', 4, $md$### Question 10

Questions 5-11
Questions 5-11
Use the information in the passage to match the category (listed A-C) with the description below. Write the appropriate letters A-C in boxes 5-11 on your answer sheet.
[A]
ONLY PRT
[B]
ONLY RUF
[C]
BOTH OF THEM
5
Totally apply computer system
6
Opposition to a system from companies
7
Reach destination fast
8
Not necessary to share with the public
9
Work on the existing road
10
Individuals can buy cars after all
11
Controlled both by computer and manual

10 ____ Individuals can buy cars after all$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dfb63d2-4f33-58c8-b2a2-633bdc1c1cea', 'cb3614a6-6c00-5a1e-a768-626eb2ab0d20', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20c11e7e-f076-5e12-b20d-424b64ea5ec3', 'cb3614a6-6c00-5a1e-a768-626eb2ab0d20', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2f7764e-d85b-58b6-b6aa-4332421d3288', 'cb3614a6-6c00-5a1e-a768-626eb2ab0d20', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b512f95e-c611-5f20-b185-255be883fe3e', '3fbb9560-2c9d-56e8-9342-daddef81983f', 11, 'CLASSIFICATION', 'READING', 4, $md$### Question 11

Questions 5-11
Questions 5-11
Use the information in the passage to match the category (listed A-C) with the description below. Write the appropriate letters A-C in boxes 5-11 on your answer sheet.
[A]
ONLY PRT
[B]
ONLY RUF
[C]
BOTH OF THEM
5
Totally apply computer system
6
Opposition to a system from companies
7
Reach destination fast
8
Not necessary to share with the public
9
Work on the existing road
10
Individuals can buy cars after all
11
Controlled both by computer and manual

11 ____ Controlled both by computer and manual$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d981fc2-99c2-51bb-80af-b985d5eea208', 'b512f95e-c611-5f20-b185-255be883fe3e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00f65ff1-cc98-505d-94c4-4b0b65b2c952', 'b512f95e-c611-5f20-b185-255be883fe3e', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52b8e3d9-1fed-5422-9d38-b6616911de5e', 'b512f95e-c611-5f20-b185-255be883fe3e', 3, $md$C$md$, false);

COMMIT;
