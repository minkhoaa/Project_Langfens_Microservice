BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-education-philosophy-1495'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-education-philosophy-1495';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-education-philosophy-1495';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-education-philosophy-1495';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('13687c78-17c5-5345-850b-208c10955311', 'ielts-reading-education-philosophy-1495', $t$Education Philosophy$t$, $md$## Education Philosophy

Nguồn:
- Test: https://mini-ielts.com/1495/reading/education-philosophy
- Solution: https://mini-ielts.com/1495/view-solution/reading/education-philosophy$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('28527048-541f-5d7e-a2f5-d43b3746fac9', '13687c78-17c5-5345-850b-208c10955311', 1, $t$Reading — Education Philosophy$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Education Philosophy

A

Although we lack accurate statistics about child mortality in the pre-industrial period, we do have evidence that in the 1660s, the mortality rate for children who died within 14 days of birth was as much as 30 per cent. Nearly all families suffered some premature death. Since all parents expected to bury some of their children, they found it difficult to invest in their newborn children. Moreover, to protect themselves from the emotional consequences of children’s death, parents avoided making any emotional commitment to an infant. It is no wonder that we find mothers leave their babies in gutters or refer to the death in the same paragraph with reference to pickles.

B

The 18th century witnessed the transformation from an agrarian economy to an industrial one, one of the vital social changes taking place in the Western world. An increasing number of people moved from their villages and small towns to big cities where life was quite different. Social supports which had previously existed in smaller communities were replaced by ruthless problems such as poverty, crime, substandard housing and disease. Due to the need for additional income to support the family, young children from the poorest families were forced into early employment and thus their childhood became painfully short. Children as young as 7 might be required to work full-time, subjected to unpleasant and unhealthy circumstances, from factories to prostitution. Although such a role has disappeared in most wealthy countries, the practice of childhood employment still remains a staple in underdeveloped countries and rarely disappeared entirely.

C

The lives of children underwent a drastic change during the 1800s in the United States. Previously, children from both rural and urban families were expected to participate in everyday labour due to the bulk of manual hard working. Nevertheless, thanks to the technological advances of the mid-1800s, coupled with the rise of the middle class and redefinition of roles of family members, work and home became less synonymous over time. People began to purchase toys and books for their children. When the country depended more upon machines, children in rural and urban areas, were less likely to be required to work at home. Beginning from the Industrial Revolution and rising slowly over the course of the 19th century, this trend increased exponentially after civil war. John Locke, one of the most influential writers of his period, created the first clear and comprehensive statement of the ‘environmental position’ that family education determines a child’s life, and via this, he became the father of modem learning theory. During the colonial period, his teachings about child care gained a lot of recognition in America.

D

According to Jean Jacques Rousseau, who lived in an era of the American and French Revolution, people were ‘noble savages’ in the original state of nature, meaning they are innocent, free and uncorrupted. In 1762, Rousseau wrote a famous novel Emile to convey his educational philosophy through a story of a boy’s education from infancy to adult-hood. This work was based on his extensive observation of children and adolescents, their individuality, his developmental theory and on the memories of his own childhood. He contrasts children with adults and describes their age-specific characteristics in terms of historical perspective and developmental psychology. Johan Heinrich Pestalozzi, living during the early stages of the Industrial Revolution, sought to develop schools to nurture children’s all-round development. He agreed with Rousseau that humans are naturally good but were spoiled by a corrupt society. His approach to teaching consists of the general and special methods, and his theory was based upon establishing an emotionally healthy homelike learning environment, which had to be in place before more specific instructions occurred.

E

One of the best-documented cases of Pestalozzi’s theory concerned a so-called feral child named Victor, who was captured in a small town in the south of France in 1800. Prepubescent, mute, naked, and perhaps 11 or 12 years old, Victor had been seen foraging for food in the gardens of the locals in the area and sometimes accepted people’s direct offers of food before his final capture. Eventually, he was brought to Paris and expected to answer some profound questions about the nature of human, but that goal was quashed very soon. A young physician Jean Marc Gaspard Itard was optimistic about the future of Victor and initiated a five-year education plan to civilise him and teach him to speak. With a subsidy from the government, Itard recruited a local woman Madame Guerin to assist him to provide a semblance of a home for Victor, and he spent an enormous amount of time and effort working with Victor. Itard’s goal to teach Victor the basics of speech could never be fully achieved, but Victor had learnt some elementary forms of communication.

F

Although other educators were beginning to recognise the simple truth embedded in Rousseau’s philosophy, it is not enough to identify the stages of children’s development alone. There must be certain education which had to be geared towards those stages. One of the early examples was the invention of kindergarten, which was a word and a movement created by a German-born educator, Friedrich Froebel in 1840. Froebel placed a high value on the importance of play in children’s learning. His invention would spread around the world eventually in a verity of forms. Froebel’s ideas were inspired through his cooperation with Johann Heinrich Pestalozzi. Froebel didn’t introduce the notion of kindergarten until 58 years old, and he had been a teacher for four decades. The notion was a haven and a preparation for children who were about to enter the regimented educational system. The use of guided or structured play was a cornerstone of his kindergarten education because he believed that play was the most significant aspect of development at this time of life. Play served as a mechanism for a child to grow emotionally and to achieve a sense of self-worth. Meanwhile, teachers served to organise materials and a structured environment in which each child, as an individual, could achieve these goals. When Froebel died in 1852, dozens of kindergartens had been created in Germany. Kindergartens began to increase in Europe, and the movement eventually reached and flourished in the United States in the 20th century.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3b5e0901-135f-5b89-9d44-9b1a769b6a52', '28527048-541f-5d7e-a2f5-d43b3746fac9', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Reading Passage 1 has six paragraphs,
A-F
.
Choose the correct heading for paragraphs
A
and
C-E
from the list of headings below.
Write the correct number,
i-vii
, in boxes
1-4
on your answer sheet.
List of Headings
i
The inheritance and development of educational concepts of different thinkers
ii
Why children had to work to alleviate the burden on family
iii
Why children are not highly valued
iv
The explanation for children dying in hospital at their early age
v
The first appearance of modem educational philosophy
vi
The application of a creative learning method on a wild kid
vii
The emergence and spread of the notion of kindergarten
1
Paragraph A
Example Answer
Paragraph B ii
2
Paragraph C
3
Paragraph D
4
Paragraph E

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('464b7c68-5b97-5593-9b45-fbf96ef0f0e1', '3b5e0901-135f-5b89-9d44-9b1a769b6a52', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4204986a-fee4-51eb-a9fc-acf69fc68c39', '3b5e0901-135f-5b89-9d44-9b1a769b6a52', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07460c19-5f1e-5020-a32f-1fc9f66cf709', '3b5e0901-135f-5b89-9d44-9b1a769b6a52', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b01588d-00ec-5e39-96ff-cd0b2e3a5dc9', '3b5e0901-135f-5b89-9d44-9b1a769b6a52', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aea83d0c-bf5b-5985-b34a-0a868fed1478', '3b5e0901-135f-5b89-9d44-9b1a769b6a52', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cd8a6fb-0d5d-54ac-b142-1844278fb89c', '3b5e0901-135f-5b89-9d44-9b1a769b6a52', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4bcb9c7-e61f-525e-a3d4-16b5140db02d', '3b5e0901-135f-5b89-9d44-9b1a769b6a52', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('68b6b3ee-6ee1-55c5-8afd-569ee9884f68', '28527048-541f-5d7e-a2f5-d43b3746fac9', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Reading Passage 1 has six paragraphs,
A-F
.
Choose the correct heading for paragraphs
A
and
C-E
from the list of headings below.
Write the correct number,
i-vii
, in boxes
1-4
on your answer sheet.
List of Headings
i
The inheritance and development of educational concepts of different thinkers
ii
Why children had to work to alleviate the burden on family
iii
Why children are not highly valued
iv
The explanation for children dying in hospital at their early age
v
The first appearance of modem educational philosophy
vi
The application of a creative learning method on a wild kid
vii
The emergence and spread of the notion of kindergarten
1
Paragraph A
Example Answer
Paragraph B ii
2
Paragraph C
3
Paragraph D
4
Paragraph E

2 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af6f0069-3ad4-56ab-be2a-11fd3dd5cf7d', '68b6b3ee-6ee1-55c5-8afd-569ee9884f68', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5236bc8d-97cc-5c84-ae30-d68210b46c37', '68b6b3ee-6ee1-55c5-8afd-569ee9884f68', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94ffa2fa-e4f3-5f9d-84ce-57e737598903', '68b6b3ee-6ee1-55c5-8afd-569ee9884f68', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93692ba2-82a6-53a4-a941-31c2093af1d6', '68b6b3ee-6ee1-55c5-8afd-569ee9884f68', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b15678e-04d5-54f3-ba67-486eba1c1275', '68b6b3ee-6ee1-55c5-8afd-569ee9884f68', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5e79137-8e7f-59d3-8b5a-aad555fb1f54', '68b6b3ee-6ee1-55c5-8afd-569ee9884f68', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34b35333-70f0-5c4d-b6b6-fadb2b545065', '68b6b3ee-6ee1-55c5-8afd-569ee9884f68', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2703117e-daee-56b7-b2c2-b955438689be', '28527048-541f-5d7e-a2f5-d43b3746fac9', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Reading Passage 1 has six paragraphs,
A-F
.
Choose the correct heading for paragraphs
A
and
C-E
from the list of headings below.
Write the correct number,
i-vii
, in boxes
1-4
on your answer sheet.
List of Headings
i
The inheritance and development of educational concepts of different thinkers
ii
Why children had to work to alleviate the burden on family
iii
Why children are not highly valued
iv
The explanation for children dying in hospital at their early age
v
The first appearance of modem educational philosophy
vi
The application of a creative learning method on a wild kid
vii
The emergence and spread of the notion of kindergarten
1
Paragraph A
Example Answer
Paragraph B ii
2
Paragraph C
3
Paragraph D
4
Paragraph E

3 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f0edf06-0a98-54cd-b3d7-272098583917', '2703117e-daee-56b7-b2c2-b955438689be', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54ea40ee-06bb-52b9-8323-6eeb6f14b62a', '2703117e-daee-56b7-b2c2-b955438689be', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebb412cd-747d-53f9-b54b-e74395d91acf', '2703117e-daee-56b7-b2c2-b955438689be', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bfa8952-49ff-5b36-aa0a-7ddf7a5a2b8c', '2703117e-daee-56b7-b2c2-b955438689be', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea65fb8f-433b-54bb-b62b-d93108df8f9b', '2703117e-daee-56b7-b2c2-b955438689be', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a726db55-aaf9-526d-a5d7-c16aa268bc24', '2703117e-daee-56b7-b2c2-b955438689be', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4a0741d-d2c4-53f0-8651-a6d4ed13fca6', '2703117e-daee-56b7-b2c2-b955438689be', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d7c6641f-8b5f-5365-8850-1f8aa26648d4', '28527048-541f-5d7e-a2f5-d43b3746fac9', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Reading Passage 1 has six paragraphs,
A-F
.
Choose the correct heading for paragraphs
A
and
C-E
from the list of headings below.
Write the correct number,
i-vii
, in boxes
1-4
on your answer sheet.
List of Headings
i
The inheritance and development of educational concepts of different thinkers
ii
Why children had to work to alleviate the burden on family
iii
Why children are not highly valued
iv
The explanation for children dying in hospital at their early age
v
The first appearance of modem educational philosophy
vi
The application of a creative learning method on a wild kid
vii
The emergence and spread of the notion of kindergarten
1
Paragraph A
Example Answer
Paragraph B ii
2
Paragraph C
3
Paragraph D
4
Paragraph E

4 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c944528c-8738-57bd-9d4b-380530c8cfaf', 'd7c6641f-8b5f-5365-8850-1f8aa26648d4', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b888b09-e4d6-5671-a864-1441d42ff8b6', 'd7c6641f-8b5f-5365-8850-1f8aa26648d4', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7ec7c29-09c1-5cf7-9169-5df5015009ca', 'd7c6641f-8b5f-5365-8850-1f8aa26648d4', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c2e71b9-960f-56ae-85d2-5a3aa1e8ff42', 'd7c6641f-8b5f-5365-8850-1f8aa26648d4', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('344c659d-8d6f-57b4-80fa-720f1f4c7c45', 'd7c6641f-8b5f-5365-8850-1f8aa26648d4', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfa7e040-038c-5074-82eb-ec8c82bbc4c9', 'd7c6641f-8b5f-5365-8850-1f8aa26648d4', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd07150e-aa2d-5525-a9df-13cfceeee0e9', 'd7c6641f-8b5f-5365-8850-1f8aa26648d4', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d7de20a6-2441-58f0-aec4-f74ef9a51bc6', '28527048-541f-5d7e-a2f5-d43b3746fac9', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Look at the following events (Questions
5-8
) and the list of dates below.
Match each event with the correct date,
A
,
B
or
C
.
Write the correct letter,
A
,
B
or
C
, in boxes
5-8
on your answer sheet.
NB
You may use any letter more than once.
List of Dates
A
the 18th century (1700-1799)
B
the 19th century (1800-1899)
C
the 20th century (1900-1999)
5
the need for children to work
6
the rise of the middle class
7
the emergence of a kindergarten
8
the spread of kindergartens around the U.S.

5 ____ the need for children to work$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('653395ad-dc75-5d56-89fe-4480dd15638e', 'd7de20a6-2441-58f0-aec4-f74ef9a51bc6', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63defcc5-f417-5627-a0ee-b050736c557a', 'd7de20a6-2441-58f0-aec4-f74ef9a51bc6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('711e0198-f363-5f57-a11f-633d7a8dceef', 'd7de20a6-2441-58f0-aec4-f74ef9a51bc6', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ec865898-f299-5425-9777-6f4e610375af', '28527048-541f-5d7e-a2f5-d43b3746fac9', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Look at the following events (Questions
5-8
) and the list of dates below.
Match each event with the correct date,
A
,
B
or
C
.
Write the correct letter,
A
,
B
or
C
, in boxes
5-8
on your answer sheet.
NB
You may use any letter more than once.
List of Dates
A
the 18th century (1700-1799)
B
the 19th century (1800-1899)
C
the 20th century (1900-1999)
5
the need for children to work
6
the rise of the middle class
7
the emergence of a kindergarten
8
the spread of kindergartens around the U.S.

6 ____ the rise of the middle class$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('983f0f14-303c-56de-8738-ea00f1dc823b', 'ec865898-f299-5425-9777-6f4e610375af', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52487d63-e82d-593e-9564-cb79e690d957', 'ec865898-f299-5425-9777-6f4e610375af', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08227814-76cf-5feb-a018-3d9031238a40', 'ec865898-f299-5425-9777-6f4e610375af', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8329f7d-e153-50b1-b1dc-d802b28d394a', '28527048-541f-5d7e-a2f5-d43b3746fac9', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Look at the following events (Questions
5-8
) and the list of dates below.
Match each event with the correct date,
A
,
B
or
C
.
Write the correct letter,
A
,
B
or
C
, in boxes
5-8
on your answer sheet.
NB
You may use any letter more than once.
List of Dates
A
the 18th century (1700-1799)
B
the 19th century (1800-1899)
C
the 20th century (1900-1999)
5
the need for children to work
6
the rise of the middle class
7
the emergence of a kindergarten
8
the spread of kindergartens around the U.S.

7 ____ the emergence of a kindergarten$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5c2c1ac-f4cb-5956-8821-40aae8a98dca', 'd8329f7d-e153-50b1-b1dc-d802b28d394a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0be2ec98-f6ca-5512-844d-d2c7ea312f64', 'd8329f7d-e153-50b1-b1dc-d802b28d394a', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97f20b47-da6d-5206-b89b-a65840997b44', 'd8329f7d-e153-50b1-b1dc-d802b28d394a', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('53ded6b3-a45b-58b8-ab64-b500673e8d58', '28527048-541f-5d7e-a2f5-d43b3746fac9', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Look at the following events (Questions
5-8
) and the list of dates below.
Match each event with the correct date,
A
,
B
or
C
.
Write the correct letter,
A
,
B
or
C
, in boxes
5-8
on your answer sheet.
NB
You may use any letter more than once.
List of Dates
A
the 18th century (1700-1799)
B
the 19th century (1800-1899)
C
the 20th century (1900-1999)
5
the need for children to work
6
the rise of the middle class
7
the emergence of a kindergarten
8
the spread of kindergartens around the U.S.

8 ____ the spread of kindergartens around the U.S.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e86ce7df-c3c0-587e-aa74-732562c24b03', '53ded6b3-a45b-58b8-ab64-b500673e8d58', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76f4d5be-b873-5ded-89b7-c612d3159252', '53ded6b3-a45b-58b8-ab64-b500673e8d58', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85fa3756-bece-58bd-8a98-c52e94aa1e58', '53ded6b3-a45b-58b8-ab64-b500673e8d58', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7af64998-3ff7-56a8-85a7-a9276f0eca7f', '28527048-541f-5d7e-a2f5-d43b3746fac9', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Look at the following opinions or deeds (Questions
9-13
) and the list of people below.
Match each opinion or deed with the correct person,
A
,
B
,
C
or
D
.
Write the correct letter,
A
,
B
,
C
or
D
, in boxes
9-13
on your answer sheet.
NB
You may use any letter more than once.
List of People
A
Jean Jacques Rousseau
B
Johan Heinrich Pestalozzi
C
Jean Marc Gaspard Itard
D
Friedrich Froebel
9
was not successful to prove the theory
10
observed a child’s record
11
requested a study setting with emotional comfort firstly
12
proposed that corruption was not a characteristic in people’s nature
13
was responsible for an increase in the number of a type of school

9 ____ was not successful to prove the theory$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff38201d-5bd1-56c4-8e40-4cdc5d6ba8a3', '7af64998-3ff7-56a8-85a7-a9276f0eca7f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd7631db-3764-51ff-9ad3-1bab454e803c', '7af64998-3ff7-56a8-85a7-a9276f0eca7f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e23d927-e925-51d0-b098-2cd01c805fb4', '7af64998-3ff7-56a8-85a7-a9276f0eca7f', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('67ff005f-c38e-5fd3-a240-811e0692b731', '28527048-541f-5d7e-a2f5-d43b3746fac9', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Look at the following opinions or deeds (Questions
9-13
) and the list of people below.
Match each opinion or deed with the correct person,
A
,
B
,
C
or
D
.
Write the correct letter,
A
,
B
,
C
or
D
, in boxes
9-13
on your answer sheet.
NB
You may use any letter more than once.
List of People
A
Jean Jacques Rousseau
B
Johan Heinrich Pestalozzi
C
Jean Marc Gaspard Itard
D
Friedrich Froebel
9
was not successful to prove the theory
10
observed a child’s record
11
requested a study setting with emotional comfort firstly
12
proposed that corruption was not a characteristic in people’s nature
13
was responsible for an increase in the number of a type of school

10 ____ observed a child’s record$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('950be8be-9566-585a-bb1e-5936ba6260d5', '67ff005f-c38e-5fd3-a240-811e0692b731', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da728ee7-b142-57ec-94bc-86b123cd9ddd', '67ff005f-c38e-5fd3-a240-811e0692b731', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a929c62-47b4-52bf-a25d-23c40769e7cd', '67ff005f-c38e-5fd3-a240-811e0692b731', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('43469490-863d-57e6-a334-a06c0a6ad678', '28527048-541f-5d7e-a2f5-d43b3746fac9', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Look at the following opinions or deeds (Questions
9-13
) and the list of people below.
Match each opinion or deed with the correct person,
A
,
B
,
C
or
D
.
Write the correct letter,
A
,
B
,
C
or
D
, in boxes
9-13
on your answer sheet.
NB
You may use any letter more than once.
List of People
A
Jean Jacques Rousseau
B
Johan Heinrich Pestalozzi
C
Jean Marc Gaspard Itard
D
Friedrich Froebel
9
was not successful to prove the theory
10
observed a child’s record
11
requested a study setting with emotional comfort firstly
12
proposed that corruption was not a characteristic in people’s nature
13
was responsible for an increase in the number of a type of school

11 ____ requested a study setting with emotional comfort firstly$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8cfc6da8-f304-545b-95bf-9395bec95dba', '43469490-863d-57e6-a334-a06c0a6ad678', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2ae6b35-4f99-5766-ad3b-ebf1659bd441', '43469490-863d-57e6-a334-a06c0a6ad678', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e803ed22-85bd-530a-aae8-98eb5ac56307', '43469490-863d-57e6-a334-a06c0a6ad678', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('852c1e3a-3f86-52dc-ad57-13ca211afa41', '28527048-541f-5d7e-a2f5-d43b3746fac9', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Look at the following opinions or deeds (Questions
9-13
) and the list of people below.
Match each opinion or deed with the correct person,
A
,
B
,
C
or
D
.
Write the correct letter,
A
,
B
,
C
or
D
, in boxes
9-13
on your answer sheet.
NB
You may use any letter more than once.
List of People
A
Jean Jacques Rousseau
B
Johan Heinrich Pestalozzi
C
Jean Marc Gaspard Itard
D
Friedrich Froebel
9
was not successful to prove the theory
10
observed a child’s record
11
requested a study setting with emotional comfort firstly
12
proposed that corruption was not a characteristic in people’s nature
13
was responsible for an increase in the number of a type of school

12 ____ proposed that corruption was not a characteristic in people’s nature$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c009cdca-b66e-53ff-8990-63d004e307cc', '852c1e3a-3f86-52dc-ad57-13ca211afa41', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a93df60-53d7-5b75-9cd8-18668a716fe9', '852c1e3a-3f86-52dc-ad57-13ca211afa41', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5d475a8-fa07-5583-a1bf-bbc970a56c09', '852c1e3a-3f86-52dc-ad57-13ca211afa41', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a94537ad-bc78-50c9-9ed6-28e76f35a12e', '28527048-541f-5d7e-a2f5-d43b3746fac9', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Look at the following opinions or deeds (Questions
9-13
) and the list of people below.
Match each opinion or deed with the correct person,
A
,
B
,
C
or
D
.
Write the correct letter,
A
,
B
,
C
or
D
, in boxes
9-13
on your answer sheet.
NB
You may use any letter more than once.
List of People
A
Jean Jacques Rousseau
B
Johan Heinrich Pestalozzi
C
Jean Marc Gaspard Itard
D
Friedrich Froebel
9
was not successful to prove the theory
10
observed a child’s record
11
requested a study setting with emotional comfort firstly
12
proposed that corruption was not a characteristic in people’s nature
13
was responsible for an increase in the number of a type of school

13 ____ was responsible for an increase in the number of a type of school$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('568358ee-f44d-5a78-b9dc-e6822073b488', 'a94537ad-bc78-50c9-9ed6-28e76f35a12e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5365d52-7d04-585c-8a81-032353febd78', 'a94537ad-bc78-50c9-9ed6-28e76f35a12e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae43c5a2-e6f1-5d7f-b41c-9a8fc93a2e74', 'a94537ad-bc78-50c9-9ed6-28e76f35a12e', 3, $md$C$md$, false);

COMMIT;
