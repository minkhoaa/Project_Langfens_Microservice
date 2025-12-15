BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-invention-of-television-1251'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-invention-of-television-1251';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-invention-of-television-1251';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-invention-of-television-1251';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4de7102f-3a3a-51cd-b79d-3b97e848d8f4', 'ielts-reading-the-invention-of-television-1251', $t$The Invention of Television$t$, $md$## The Invention of Television

Nguồn:
- Test: https://mini-ielts.com/1251/reading/the-invention-of-television
- Solution: https://mini-ielts.com/1251/view-solution/reading/the-invention-of-television$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', '4de7102f-3a3a-51cd-b79d-3b97e848d8f4', 1, $t$Reading — The Invention of Television$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Invention of Television

The question “Who invented television?” is simple enough, but the answer is surprisingly controversial. No one person was responsible for producing what we think of as television today and the credit is due to various inventors.

The Scotsman, John Logie Baird, is considered by many to be the inventor of television. He showed early signs of his inventing ingenuity by setting up a telephone exchange to connect his house to those of his friends near by. His first interest in television came in 1903, after he read a German book on the photoelectric properties of selenium. In 1873, this element was discovered to have the capacity to generate a current based on the amount of light applied to it. Working initially in Hastings, England, Baird famously created an apparatus using an old hatbox he bought in a used goods store, a pair of scissors, some needles, some bicycle light lenses and an old tea chest. Baird also used a Nipkow disk, created by German inventor, Paul Nipkow, and a lot of his work was based on the previous work by German, Arthur Korn. In February 1924, Baird demonstrated moving silhouette images on a ‘television’. Later that year, after nearly destroying the house and nearly killing himself with an electric shock, Baird moved to London, where he gave the first public display of his invention. On 2 October 1925, Baird used an office assistant, William Taynton, to move for his transmitted pictures, and Taynton became the first person to be televised moving and in full tonal range. Baird is also later credited with demonstrating the first images on colour television, on 3rd July 1928, although the credit for being the inventor of colour television is again disputed. Another first for Baird was transmitting the first television pictures across the Atlantic in 1928. Although Baird was well known for his invention, he also became famous for refusing an offer of £100,000 for the shares in his company, which was an enormous sum at that time. Baird famously said that he would not be able to sleep at night, knowing he had that much money.

Philo Farnsworth successfully demonstrated electronic television in San Francisco, in 1927, using a different system. Farnsworth realised that a picture could be dissected by a simple television camera into a series of lines of electricity. The lines would be transmitted so quickly that the eyes would merge the lines. Then, an image dissector, which Farnsworth created, would change those lines back into a picture. The Russian inventor, Vladimir Zworykin, built on this work and it was Zworykin’s designs that were eventually used by the BBC in the UK to replace Baird’s system.

Baird’s initial work would not have been successful without the previous work of Paul Nipkow. Nipkow came up with the idea of ‘scanning’ a television image by using a spinning disk with a spiral of small pinholes. When spun at a high rate of speed, each hole would allow light to fall on a selenium cell on the other side of the disk. The amount of voltage the cell generated would depend on the amount of light reflected from the object being photographed. One rotation of the disk equalled one frame of “video”. At the place where the signal was received, the process would be reversed. A similar disk spun in sync and a neon lamp reacted to the changes in voltage with the speed required to keep up with the spinning disk and projected the images onto a screen. Although Nipkow created the disk and acquired a patent for his invention, he did not create the apparatus to project images. The patent expired after 15 years, as no one was interested then in the work. Baird’s first practical television systems used an electro-mechanical picture scanning method, the method that Nipkow had helped create with his disk. Nipkow became a celebrated scientist in Germany for his work, but the mechanical nature of the Nipkow Disk caused the invention to fade to obscurity with the use of the cathode ray tube.

Arthur Korn was another German scientist working in the same field as Baird and Nipkow and it was his work that allowed the development of Nipkow’s work that in turn led to Baird’s breakthroughs. Korn’s early work was focused on the transmission of visual telegraphic transmission, using his developments in amplification tube technology. He sent a picture of the German Crown Prince 1800 kilometres in 1906 and sent a picture of the Pope across the Atlantic in 1923. Korn’s work was celebrated and, from 1928, the German police used his technology to send photographs and fingerprints.

Finally, another American, Charles Francis Jenkins, has a claim to be the inventor of television. Jenkins, who at the time was very well known for inventing the motion picture projector, first transmitted a silhouette picture from one room to another in 1922. Jenkins founded a broadcasting company in 1928, but the crash of 1929 forced him out of business. Most people agree that Baird gave his first public demonstration of television a couple years earlier than Jenkins, but this is disputed in some places.

It is plain to see why any claim to be the inventor of television is said to be controversial. In many cases, the answer to the question, “Who invented television?”, often just depends on from which country the person answering the question is.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d017964-c49b-5d3a-b598-0353dc936076', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Look at the different significant people in the process of the invention of the television
(questions
1 – 7
) and match them to their roles in this process (
A – G
).
Write your answers in boxes
1-7
on your answer sheet.
The Significant Person
Roles
1
John Logie Baird
A
His work was adopted by the BBC for their broadcasting business.
2
William Taynton
B
His work was used to help fight crime.
3
Philo Farnsworth
C
He was the first person to move on television.
4
Vladimir Zworykin
D
He used second hand parts in his invention.
5
Paul Nipkow
E
His business was destroyed by a
financial crisis
6
Arthur Korn
F
He invented the image dissector.
7
Charles Francis Jenkins
G
His work was initially of no interest to anyone.
1
2
3
4
5
6
7

1 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfd7857f-c533-58b2-9327-fed048c89aae', '3d017964-c49b-5d3a-b598-0353dc936076', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('366f9d2b-3b0e-5202-a035-0f5e4dd6d653', '3d017964-c49b-5d3a-b598-0353dc936076', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('134b1d60-18e2-5235-a4b6-8343abc7daa8', '3d017964-c49b-5d3a-b598-0353dc936076', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a347ba3e-e307-5918-8e3d-1302278e30aa', '3d017964-c49b-5d3a-b598-0353dc936076', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be2a1d20-47db-513a-8bad-f85537ae6d2a', '3d017964-c49b-5d3a-b598-0353dc936076', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38df2ce5-3358-50a7-91c1-122ade3e8e5c', '3d017964-c49b-5d3a-b598-0353dc936076', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a368093-2866-596e-9cff-782601f07131', '3d017964-c49b-5d3a-b598-0353dc936076', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9bd108f4-76d8-54d9-92af-15df2cce4ac8', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Look at the different significant people in the process of the invention of the television
(questions
1 – 7
) and match them to their roles in this process (
A – G
).
Write your answers in boxes
1-7
on your answer sheet.
The Significant Person
Roles
1
John Logie Baird
A
His work was adopted by the BBC for their broadcasting business.
2
William Taynton
B
His work was used to help fight crime.
3
Philo Farnsworth
C
He was the first person to move on television.
4
Vladimir Zworykin
D
He used second hand parts in his invention.
5
Paul Nipkow
E
His business was destroyed by a
financial crisis
6
Arthur Korn
F
He invented the image dissector.
7
Charles Francis Jenkins
G
His work was initially of no interest to anyone.
1
2
3
4
5
6
7

2 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('364682f7-2b37-542d-bc2f-34f66f0b3523', '9bd108f4-76d8-54d9-92af-15df2cce4ac8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37cfd512-f26f-5bf5-9652-d9b4882b9831', '9bd108f4-76d8-54d9-92af-15df2cce4ac8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9da5959e-2827-5e74-b964-fd9583bd7fb4', '9bd108f4-76d8-54d9-92af-15df2cce4ac8', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91c0e043-1a27-5804-ab44-540872c620f2', '9bd108f4-76d8-54d9-92af-15df2cce4ac8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc3259ca-9a33-5b0c-b89f-bb0fd059c292', '9bd108f4-76d8-54d9-92af-15df2cce4ac8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('445f17cf-ce99-596e-be15-af1d0d7ad415', '9bd108f4-76d8-54d9-92af-15df2cce4ac8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c59c3748-a59c-5afb-b3f2-8a2372847f80', '9bd108f4-76d8-54d9-92af-15df2cce4ac8', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2f9994d7-7d71-55e6-8d36-f74eef2c18d1', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Look at the different significant people in the process of the invention of the television
(questions
1 – 7
) and match them to their roles in this process (
A – G
).
Write your answers in boxes
1-7
on your answer sheet.
The Significant Person
Roles
1
John Logie Baird
A
His work was adopted by the BBC for their broadcasting business.
2
William Taynton
B
His work was used to help fight crime.
3
Philo Farnsworth
C
He was the first person to move on television.
4
Vladimir Zworykin
D
He used second hand parts in his invention.
5
Paul Nipkow
E
His business was destroyed by a
financial crisis
6
Arthur Korn
F
He invented the image dissector.
7
Charles Francis Jenkins
G
His work was initially of no interest to anyone.
1
2
3
4
5
6
7

3 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6badaefa-cc1c-5cb2-95d5-d4f74d2ce8f6', '2f9994d7-7d71-55e6-8d36-f74eef2c18d1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47e69b6a-0299-5ec4-bb50-7b9f5a0a4052', '2f9994d7-7d71-55e6-8d36-f74eef2c18d1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('549fd688-f7e5-50ea-b30b-49f4df94db0e', '2f9994d7-7d71-55e6-8d36-f74eef2c18d1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5b25010-1851-531f-8650-cd9de0f117e2', '2f9994d7-7d71-55e6-8d36-f74eef2c18d1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d155767-bb4a-5699-80d6-578921d8f002', '2f9994d7-7d71-55e6-8d36-f74eef2c18d1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3dd87d2e-a180-513f-961f-358b7fd7d838', '2f9994d7-7d71-55e6-8d36-f74eef2c18d1', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff61a74e-0994-5f33-b8ee-d77b0a4121be', '2f9994d7-7d71-55e6-8d36-f74eef2c18d1', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0fe85f24-6970-5d09-82b4-5706002fcd2b', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Look at the different significant people in the process of the invention of the television
(questions
1 – 7
) and match them to their roles in this process (
A – G
).
Write your answers in boxes
1-7
on your answer sheet.
The Significant Person
Roles
1
John Logie Baird
A
His work was adopted by the BBC for their broadcasting business.
2
William Taynton
B
His work was used to help fight crime.
3
Philo Farnsworth
C
He was the first person to move on television.
4
Vladimir Zworykin
D
He used second hand parts in his invention.
5
Paul Nipkow
E
His business was destroyed by a
financial crisis
6
Arthur Korn
F
He invented the image dissector.
7
Charles Francis Jenkins
G
His work was initially of no interest to anyone.
1
2
3
4
5
6
7

4 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('499a0ae7-a142-506e-87a9-27f71f84fa31', '0fe85f24-6970-5d09-82b4-5706002fcd2b', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d525a7ed-8860-588c-b6c6-113b01654765', '0fe85f24-6970-5d09-82b4-5706002fcd2b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c418743-7c10-50c7-8308-beabe7a61dd3', '0fe85f24-6970-5d09-82b4-5706002fcd2b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4124e494-910a-5ce7-a842-07f71c96c235', '0fe85f24-6970-5d09-82b4-5706002fcd2b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c42c206-3e2f-5ff2-bd25-20465ae728b7', '0fe85f24-6970-5d09-82b4-5706002fcd2b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cdab51b-5af1-5af3-a535-b3a0ad4aea08', '0fe85f24-6970-5d09-82b4-5706002fcd2b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5734109-91e0-5cf8-a042-8a3bdfe853ff', '0fe85f24-6970-5d09-82b4-5706002fcd2b', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('399c2610-4d86-55be-8a62-d7e5b1ebd5c7', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Look at the different significant people in the process of the invention of the television
(questions
1 – 7
) and match them to their roles in this process (
A – G
).
Write your answers in boxes
1-7
on your answer sheet.
The Significant Person
Roles
1
John Logie Baird
A
His work was adopted by the BBC for their broadcasting business.
2
William Taynton
B
His work was used to help fight crime.
3
Philo Farnsworth
C
He was the first person to move on television.
4
Vladimir Zworykin
D
He used second hand parts in his invention.
5
Paul Nipkow
E
His business was destroyed by a
financial crisis
6
Arthur Korn
F
He invented the image dissector.
7
Charles Francis Jenkins
G
His work was initially of no interest to anyone.
1
2
3
4
5
6
7

5 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0af19e97-23bc-504f-92aa-27ef6e9055ae', '399c2610-4d86-55be-8a62-d7e5b1ebd5c7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dc6876a-a9b1-5670-9f29-6b58eb29e6b1', '399c2610-4d86-55be-8a62-d7e5b1ebd5c7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d241e604-d640-5dab-b4ba-135dfac72c1d', '399c2610-4d86-55be-8a62-d7e5b1ebd5c7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('581aae09-da8a-52f6-aad1-5bc660eec420', '399c2610-4d86-55be-8a62-d7e5b1ebd5c7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7e0dc93-759b-5bfa-aad1-e3338074ff6f', '399c2610-4d86-55be-8a62-d7e5b1ebd5c7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b06838e-d23c-5e06-af0d-3476edcf6b66', '399c2610-4d86-55be-8a62-d7e5b1ebd5c7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bda0e7e4-38c9-5396-8d14-9b690f96b3c2', '399c2610-4d86-55be-8a62-d7e5b1ebd5c7', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0065f866-79bf-59e2-b04d-36e8cf492428', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Look at the different significant people in the process of the invention of the television
(questions
1 – 7
) and match them to their roles in this process (
A – G
).
Write your answers in boxes
1-7
on your answer sheet.
The Significant Person
Roles
1
John Logie Baird
A
His work was adopted by the BBC for their broadcasting business.
2
William Taynton
B
His work was used to help fight crime.
3
Philo Farnsworth
C
He was the first person to move on television.
4
Vladimir Zworykin
D
He used second hand parts in his invention.
5
Paul Nipkow
E
His business was destroyed by a
financial crisis
6
Arthur Korn
F
He invented the image dissector.
7
Charles Francis Jenkins
G
His work was initially of no interest to anyone.
1
2
3
4
5
6
7

6 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('382ffd32-a8e4-5e89-bd6d-dc38384216c6', '0065f866-79bf-59e2-b04d-36e8cf492428', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2da17571-83e9-5f3f-93db-42585dd8df34', '0065f866-79bf-59e2-b04d-36e8cf492428', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd7936aa-ef9e-5027-a2cb-6bab9d158a06', '0065f866-79bf-59e2-b04d-36e8cf492428', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fcd2518-6952-54ef-b733-771ae8cb89cc', '0065f866-79bf-59e2-b04d-36e8cf492428', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('793cbaa7-52a2-5b70-8cb3-0ba15c116377', '0065f866-79bf-59e2-b04d-36e8cf492428', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de4234e3-fdeb-58e2-a669-d50c5a347a47', '0065f866-79bf-59e2-b04d-36e8cf492428', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d83a8c4-43e9-5b17-b0a1-3ff24fcbb74d', '0065f866-79bf-59e2-b04d-36e8cf492428', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0fe8517e-b4a6-5cd9-8a28-b6ccd9c5e90a', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Look at the different significant people in the process of the invention of the television
(questions
1 – 7
) and match them to their roles in this process (
A – G
).
Write your answers in boxes
1-7
on your answer sheet.
The Significant Person
Roles
1
John Logie Baird
A
His work was adopted by the BBC for their broadcasting business.
2
William Taynton
B
His work was used to help fight crime.
3
Philo Farnsworth
C
He was the first person to move on television.
4
Vladimir Zworykin
D
He used second hand parts in his invention.
5
Paul Nipkow
E
His business was destroyed by a
financial crisis
6
Arthur Korn
F
He invented the image dissector.
7
Charles Francis Jenkins
G
His work was initially of no interest to anyone.
1
2
3
4
5
6
7

7 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8036c59e-1333-5dbb-8969-67be6f93fe81', '0fe8517e-b4a6-5cd9-8a28-b6ccd9c5e90a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a54b878-fcd8-5f70-8e80-7dd4cd58b882', '0fe8517e-b4a6-5cd9-8a28-b6ccd9c5e90a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2cddc61-a4f8-5abf-bc86-3124daa216ee', '0fe8517e-b4a6-5cd9-8a28-b6ccd9c5e90a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f171f3b-b92d-51a2-bad3-0b1bb16d8de2', '0fe8517e-b4a6-5cd9-8a28-b6ccd9c5e90a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58d28aa4-0097-593a-a77c-59ee1695035b', '0fe8517e-b4a6-5cd9-8a28-b6ccd9c5e90a', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1586d95-895b-56f0-ae92-b6257c58cef5', '0fe8517e-b4a6-5cd9-8a28-b6ccd9c5e90a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d09c5647-db7b-5c83-8c1f-c052f3ca2444', '0fe8517e-b4a6-5cd9-8a28-b6ccd9c5e90a', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d40ca147-6b56-51d6-ae0c-c7fc60ba0aa8', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 8 -10
Questions 8 -10
Label the diagram below.
Write
NO MORE THAN THREE WORDS
from the text for each answer.
Write your answers in boxes
8-10
on your answer sheet.
8
9
10

8 ____$md$, NULL, ARRAY['.*small.*pinholes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('91d5f10b-a874-5a1d-9095-69fa6b515790', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 8 -10
Questions 8 -10
Label the diagram below.
Write
NO MORE THAN THREE WORDS
from the text for each answer.
Write your answers in boxes
8-10
on your answer sheet.
8
9
10

9 ____$md$, NULL, ARRAY['.*a.*selenium.*cell.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('67388c45-48c0-59d7-99f6-cd6776ca0826', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 8 -10
Questions 8 -10
Label the diagram below.
Write
NO MORE THAN THREE WORDS
from the text for each answer.
Write your answers in boxes
8-10
on your answer sheet.
8
9
10

10 ____$md$, NULL, ARRAY['.*a.*neon.*lamp.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7cd33ce3-299e-5ab3-9cd6-6b453540ed64', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in the text?
In boxes
11-13
on your answer sheet write:
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
11
Nipkow died without any of his work being widely recognized.
12
Korn and Nipkow often met to discuss their work.
13
Charles Francis Jenkins was already famous when he experimented with television.

11 ____ Nipkow died without any of his work being widely recognized.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fec3ff75-744d-5343-b631-9ed039e88edf', '7cd33ce3-299e-5ab3-9cd6-6b453540ed64', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16ed4683-586e-5dc2-a0d9-74208f7d2f14', '7cd33ce3-299e-5ab3-9cd6-6b453540ed64', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1a90a43-de2d-51e4-90b1-990fed147d59', '7cd33ce3-299e-5ab3-9cd6-6b453540ed64', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('73e686da-5e56-58de-97a4-aad468002733', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in the text?
In boxes
11-13
on your answer sheet write:
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
11
Nipkow died without any of his work being widely recognized.
12
Korn and Nipkow often met to discuss their work.
13
Charles Francis Jenkins was already famous when he experimented with television.

12 ____ Korn and Nipkow often met to discuss their work.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce63cc2c-b9e5-5ba0-b196-d72997b4ff58', '73e686da-5e56-58de-97a4-aad468002733', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de7c7c2d-6415-5198-9883-4bb7fea8bc92', '73e686da-5e56-58de-97a4-aad468002733', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4c08356-75ec-5eda-92ab-cbd628ca3495', '73e686da-5e56-58de-97a4-aad468002733', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8882f9ef-f4dc-5e40-9a2c-04fd9244764e', '5af5ecf7-1c64-5d5c-aaa6-a859ee4f8db3', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in the text?
In boxes
11-13
on your answer sheet write:
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
11
Nipkow died without any of his work being widely recognized.
12
Korn and Nipkow often met to discuss their work.
13
Charles Francis Jenkins was already famous when he experimented with television.

13 ____ Charles Francis Jenkins was already famous when he experimented with television.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce0bb9f2-1289-550a-8221-070cc52e786f', '8882f9ef-f4dc-5e40-9a2c-04fd9244764e', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7ae8219-ecb3-5831-91a9-e1d95d437418', '8882f9ef-f4dc-5e40-9a2c-04fd9244764e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2e78115-4378-510e-97da-8afffb31712b', '8882f9ef-f4dc-5e40-9a2c-04fd9244764e', 3, $md$NOT GIVEN$md$, false);

COMMIT;
