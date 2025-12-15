BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-bovids-1361'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-bovids-1361';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-bovids-1361';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-bovids-1361';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('7b3edb94-e32f-534d-9f2a-dfbb6264826e', 'ielts-reading-bovids-1361', $t$Bovids$t$, $md$## Bovids

Nguồn:
- Test: https://mini-ielts.com/1361/reading/bovids
- Solution: https://mini-ielts.com/1361/view-solution/reading/bovids$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6d09e01b-f691-5842-bfb5-164803a3045b', '7b3edb94-e32f-534d-9f2a-dfbb6264826e', 1, $t$Reading — Bovids$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Bovids

A

The family of mammals called bovids belongs to the Artiodactyl class, which also includes giraffes. Bovids are a highly diverse group consisting of 137 species, some of which are man’s most important domestic animals.

B

Bovids are well represented in most parts of Eurasia and Southeast Asian islands, but they are by far the most numerous and diverse in the latter Some species of bovid are solitary, but others live in large groups with complex social structures. Although bovids have adapted to a wide range of habitats, from arctic tundra to deep tropical forest, the majority of species favour open grassland, scrub or desert. This diversity of habitat is also matched by great diversity in size and form: at one extreme is the royal antelope of West Africa, which stands a mere 25 cm at the shoulder; at the other, the massively built bison of North America and Europe, growing to a shoulder height of 2.2m.

C

Despite differences in size and appearance, bovids are united by the possession of certain common features. All species are ruminants, which means that they retain undigested food in their stomachs, and regurgitate it as necessary. Bovids are almost exclusively herbivorous: plant-eating “incisors: front teeth herbivorous”.

D

Typically their teeth are highly modified for browsing and grazing: grass or foliage is cropped with the upper lip and lower incisors** (the upper incisors are usually absent), and then ground down by the cheek teeth. As well as having cloven, or split, hooves, the males of ail bovid species and the females of most carry horns. Bovid horns have bony cores covered in a sheath of horny material that is constantly renewed from within; they are unbranched and never shed. They vary in shape and size: the relatively simple horns of a large Indian buffalo may measure around 4 m from tip to tip along the outer curve, while the various gazelles have horns with a variety of elegant curves.

E

Five groups, or sub-families, may be distinguished: Bovinae, Antelope, Caprinae, Cephalophinae and Antilocapridae. The sub-family Bovinae comprises most of the larger bovids, including the African bongo, and nilgae, eland, bison and cattle. Unlike most other bovids they are all non-territorial. The ancestors of the various species of domestic cattle banteng, gaur, yak and water buffalo are generally rare and endangered in the wild, while the auroch (the ancestor of the domestic cattle of Europe) is extinct.

F

The term ‘antelope is not a very precise zoological name – it is used to loosely describe a number of bovids that have followed different lines of development. Antelopes are typically long-legged, fast-running species, often with long horns that may be laid along the back when the animal is in full flight. There are two main sub-groups of antelope: Hippotraginae, which includes the oryx and the addax, and Antilopinae, which generally contains slighter and more graceful animals such as gazelle and the springbok. Antelopes are mainly grassland species, but many have adapted to flooded grasslands: pukus, waterbucks and lechwes are all good at swimming, usually feeding in deep water, while the sitatunga has long, splayed hooves that enable it to walk freely on swampy ground.

G

The sub-family Caprinae includes the sheep and the goat, together with various relatives such as the goral and the tahr. Most are woolly or have long hair. Several species, such as wild goats, chamois and ibex, are agile cliff – and mountain-dwellers. Tolerance of extreme conditions is most marked in this group: Barbary and bighorn sheep have adapted to arid deserts, while Rocky Mountain sheep survive high up in mountains and musk oxen in arctic tundra.

H

The duiker of Africa belongs to the Cephalophinae sub-family. It is generally small and solitary, often living in thick forest. Although mainly feeding on grass and leaves, some duikers – unlike most other bovids – are believed to eat insects and feed on dead animal carcasses, and even to kill small animals.

I

The pronghorn is the sole survivor of a New World sub-family of herbivorous ruminants, the Antilocapridae in North America. It is similar in appearance and habits to the Old World antelope. Although greatly reduced in numbers since the arrival of Europeans, and the subsequent enclosure of grasslands, the pronghorn is still found in considerable numbers throughout North America, from Washington State to Mexico. When alarmed by the approach of wolves or other predators, hairs on the pronghorn’s rump stand erect, so showing and emphasizing the white patch there. At this signal, the whole herd gallops off at speed of over 60 km per hour.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1b6606ad-b83e-58f7-b348-679e4fff5bda', '6d09e01b-f691-5842-bfb5-164803a3045b', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-3
Questions 1-3
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
1-3
on your answer sheet.
1
In which region is the biggest range of bovids to be found?
A
Africa
B
Eurasia
C
North America
D
South-east Asia
2
Most bovids have a preference for living in
A
isolation
B
small groups
C
tropical forest
D
wide open spaces
3
Which of the following features do all bovids have in common?
A
Their horns are shot
B
They have upper incisors
C
They store food in the body
D
Their hooves are undivided

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('53b50aa9-ce8c-519a-a53b-fd12b746709f', '6d09e01b-f691-5842-bfb5-164803a3045b', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-3
Questions 1-3
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
1-3
on your answer sheet.
1
In which region is the biggest range of bovids to be found?
A
Africa
B
Eurasia
C
North America
D
South-east Asia
2
Most bovids have a preference for living in
A
isolation
B
small groups
C
tropical forest
D
wide open spaces
3
Which of the following features do all bovids have in common?
A
Their horns are shot
B
They have upper incisors
C
They store food in the body
D
Their hooves are undivided

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('32b5b924-a85d-5635-8802-72fe28129fb8', '6d09e01b-f691-5842-bfb5-164803a3045b', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-3
Questions 1-3
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
1-3
on your answer sheet.
1
In which region is the biggest range of bovids to be found?
A
Africa
B
Eurasia
C
North America
D
South-east Asia
2
Most bovids have a preference for living in
A
isolation
B
small groups
C
tropical forest
D
wide open spaces
3
Which of the following features do all bovids have in common?
A
Their horns are shot
B
They have upper incisors
C
They store food in the body
D
Their hooves are undivided

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a11d02bf-e302-5cef-b4a9-0089fca8a0b1', '6d09e01b-f691-5842-bfb5-164803a3045b', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 4-8
Questions 4-8
Look at the following characteristics (Questions
4-8
) and the list of sub-families below.
Match each characteristic with the correct sub-family,
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
4-8
on your answer sheet.
NB
You may use any letter more than once
4
can endure very harsh environments
5
includes the ox and the cow
6
may supplement its diet with meat
7
can usually move a speed
8
does not defend a particular area of land
List of sub-families
A
Antelope
B
Bovinae
C
Caprinae
D
Cephalophinae

4 ____ can endure very harsh environments$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00e8351b-b55a-546e-84b5-31bd8ea4a8d9', 'a11d02bf-e302-5cef-b4a9-0089fca8a0b1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21dc57a2-c9fc-5d5f-a551-8afcfcf2d681', 'a11d02bf-e302-5cef-b4a9-0089fca8a0b1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22b78b08-9b77-579d-93ab-71b8f0dcfd3e', 'a11d02bf-e302-5cef-b4a9-0089fca8a0b1', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1efaae7e-9b22-5a1d-891d-0fc41e00e686', 'a11d02bf-e302-5cef-b4a9-0089fca8a0b1', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e981f31-9fe7-5fd5-a588-9e552b9b8def', '6d09e01b-f691-5842-bfb5-164803a3045b', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 4-8
Questions 4-8
Look at the following characteristics (Questions
4-8
) and the list of sub-families below.
Match each characteristic with the correct sub-family,
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
4-8
on your answer sheet.
NB
You may use any letter more than once
4
can endure very harsh environments
5
includes the ox and the cow
6
may supplement its diet with meat
7
can usually move a speed
8
does not defend a particular area of land
List of sub-families
A
Antelope
B
Bovinae
C
Caprinae
D
Cephalophinae

5 ____ includes the ox and the cow$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53cdc2ce-e8be-5d23-824a-a74ffd4cb444', '4e981f31-9fe7-5fd5-a588-9e552b9b8def', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('865d17fa-2b02-5f8c-a1c0-81416d172f0e', '4e981f31-9fe7-5fd5-a588-9e552b9b8def', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('092b24d7-3c9b-5554-8890-4bdcb33c20db', '4e981f31-9fe7-5fd5-a588-9e552b9b8def', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b3e16d8-8be2-5ed6-856e-6d1f694457c8', '4e981f31-9fe7-5fd5-a588-9e552b9b8def', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1aa30a5-8539-5261-837e-f7a2cfe7d098', '6d09e01b-f691-5842-bfb5-164803a3045b', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 4-8
Questions 4-8
Look at the following characteristics (Questions
4-8
) and the list of sub-families below.
Match each characteristic with the correct sub-family,
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
4-8
on your answer sheet.
NB
You may use any letter more than once
4
can endure very harsh environments
5
includes the ox and the cow
6
may supplement its diet with meat
7
can usually move a speed
8
does not defend a particular area of land
List of sub-families
A
Antelope
B
Bovinae
C
Caprinae
D
Cephalophinae

6 ____ may supplement its diet with meat$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f862479c-16c9-5eb2-98ae-36a599c43239', 'e1aa30a5-8539-5261-837e-f7a2cfe7d098', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84bae2b0-526e-585a-b57c-b7af0a3d8234', 'e1aa30a5-8539-5261-837e-f7a2cfe7d098', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb7cd71a-b2f1-543c-9e00-8f5f5fa1a35e', 'e1aa30a5-8539-5261-837e-f7a2cfe7d098', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('455abf08-b16d-54ce-850b-982204d63ebf', 'e1aa30a5-8539-5261-837e-f7a2cfe7d098', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d67c3f5a-4bc7-5f9d-af63-281d417fa07f', '6d09e01b-f691-5842-bfb5-164803a3045b', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 4-8
Questions 4-8
Look at the following characteristics (Questions
4-8
) and the list of sub-families below.
Match each characteristic with the correct sub-family,
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
4-8
on your answer sheet.
NB
You may use any letter more than once
4
can endure very harsh environments
5
includes the ox and the cow
6
may supplement its diet with meat
7
can usually move a speed
8
does not defend a particular area of land
List of sub-families
A
Antelope
B
Bovinae
C
Caprinae
D
Cephalophinae

7 ____ can usually move a speed$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e99b362-07a9-5893-b446-ba2890993eb5', 'd67c3f5a-4bc7-5f9d-af63-281d417fa07f', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b69cbaab-6a26-5b2d-a691-f0005bb6f1ca', 'd67c3f5a-4bc7-5f9d-af63-281d417fa07f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55c4844a-4e4c-59df-aba7-ace3b5d05cf9', 'd67c3f5a-4bc7-5f9d-af63-281d417fa07f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('786d4499-e5b9-59ba-8f9c-4abf1ed38564', 'd67c3f5a-4bc7-5f9d-af63-281d417fa07f', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f28cde6d-06ee-5381-9efb-99f885cac599', '6d09e01b-f691-5842-bfb5-164803a3045b', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 4-8
Questions 4-8
Look at the following characteristics (Questions
4-8
) and the list of sub-families below.
Match each characteristic with the correct sub-family,
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
4-8
on your answer sheet.
NB
You may use any letter more than once
4
can endure very harsh environments
5
includes the ox and the cow
6
may supplement its diet with meat
7
can usually move a speed
8
does not defend a particular area of land
List of sub-families
A
Antelope
B
Bovinae
C
Caprinae
D
Cephalophinae

8 ____ does not defend a particular area of land$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('626be71b-aa91-5175-891a-706e0b735d61', 'f28cde6d-06ee-5381-9efb-99f885cac599', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84d1dc47-de1a-5b95-800c-d2b8f9ab5ae6', 'f28cde6d-06ee-5381-9efb-99f885cac599', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a5cc735-8859-57ce-accc-5ed57f8ea9f2', 'f28cde6d-06ee-5381-9efb-99f885cac599', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba41c807-72f5-54b5-873d-7c46d512166d', 'f28cde6d-06ee-5381-9efb-99f885cac599', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('91ddf1a2-865d-5439-bc50-0d2d34cd6cab', '6d09e01b-f691-5842-bfb5-164803a3045b', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
9 What is the smallest species of Bovid called?
9
10 Which species of Bovinae hos now died out?
10
11 What facilitates the movement of the sitatunga over wetland?
11
12 What sort of terrain do barbary sheep live in?
12
13 What is the only living member of the Antilocapridae sub-family?
13

9 What is the smallest species of Bovid called? 9 ____$md$, NULL, ARRAY['.*the.*royal.*antelope.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8dfdf9bc-36d4-5f3a-9aa4-1983897f0647', '6d09e01b-f691-5842-bfb5-164803a3045b', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
9 What is the smallest species of Bovid called?
9
10 Which species of Bovinae hos now died out?
10
11 What facilitates the movement of the sitatunga over wetland?
11
12 What sort of terrain do barbary sheep live in?
12
13 What is the only living member of the Antilocapridae sub-family?
13

10 Which species of Bovinae hos now died out? 10 ____$md$, NULL, ARRAY['.*the.*auroch.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f03292e0-94fb-56e6-9d9f-8f1b70b6b3f0', '6d09e01b-f691-5842-bfb5-164803a3045b', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
9 What is the smallest species of Bovid called?
9
10 Which species of Bovinae hos now died out?
10
11 What facilitates the movement of the sitatunga over wetland?
11
12 What sort of terrain do barbary sheep live in?
12
13 What is the only living member of the Antilocapridae sub-family?
13

11 What facilitates the movement of the sitatunga over wetland? 11 ____$md$, NULL, ARRAY['.*long.*splayed.*hooves.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0040a49e-c9d7-5d6f-b02a-1d1d063d5b62', '6d09e01b-f691-5842-bfb5-164803a3045b', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
9 What is the smallest species of Bovid called?
9
10 Which species of Bovinae hos now died out?
10
11 What facilitates the movement of the sitatunga over wetland?
11
12 What sort of terrain do barbary sheep live in?
12
13 What is the only living member of the Antilocapridae sub-family?
13

12 What sort of terrain do barbary sheep live in? 12 ____$md$, NULL, ARRAY['.*arid.*deserts.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0b183add-b807-5adf-b70c-915cb1ddd82a', '6d09e01b-f691-5842-bfb5-164803a3045b', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
9 What is the smallest species of Bovid called?
9
10 Which species of Bovinae hos now died out?
10
11 What facilitates the movement of the sitatunga over wetland?
11
12 What sort of terrain do barbary sheep live in?
12
13 What is the only living member of the Antilocapridae sub-family?
13

13 What is the only living member of the Antilocapridae sub-family? 13 ____$md$, NULL, ARRAY['.*the.*pronghorn.*']);

COMMIT;
