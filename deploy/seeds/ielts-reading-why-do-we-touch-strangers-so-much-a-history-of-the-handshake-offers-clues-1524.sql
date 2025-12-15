BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-why-do-we-touch-strangers-so-much-a-history-of-the-handshake-offers-clues-1524'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-why-do-we-touch-strangers-so-much-a-history-of-the-handshake-offers-clues-1524';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-why-do-we-touch-strangers-so-much-a-history-of-the-handshake-offers-clues-1524';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-why-do-we-touch-strangers-so-much-a-history-of-the-handshake-offers-clues-1524';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('81b019bc-edd3-5f55-a3b1-250b17bf5819', 'ielts-reading-why-do-we-touch-strangers-so-much-a-history-of-the-handshake-offers-clues-1524', $t$Why Do We Touch Strangers So Much? A History Of The Handshake Offers Clues$t$, $md$## Why Do We Touch Strangers So Much? A History Of The Handshake Offers Clues

Nguồn:
- Test: https://mini-ielts.com/1524/reading/why-do-we-touch-strangers-so-much-a-history-of-the-handshake-offers-clues
- Solution: https://mini-ielts.com/1524/view-solution/reading/why-do-we-touch-strangers-so-much-a-history-of-the-handshake-offers-clues$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('4c7fc169-f6db-54d5-a728-57ffc1ca16f1', '81b019bc-edd3-5f55-a3b1-250b17bf5819', 1, $t$Reading — Why Do We Touch Strangers So Much? A History Of The Handshake Offers Clues$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Why Do We Touch Strangers So Much? A History Of The Handshake Offers Clues

For thousands of years, the handshake has been used for different purposes.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8d0a9044-d8be-5bf4-9e3d-c0d18dbd71e1', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Question 1-7
Question 1-7
Choose TRUE if the statement agrees with the information given in the text, choose FALSE if the statement contradicts the information, or choose NOT GIVEN if there is no information on this.
1
Shaking hands is an indicator of hospitality.
2
Evidence showed that the handshake started as a sign of peace.
3
When shaking hands, people often rolled up their sleeves.
4
The use of a handshake in different situations can be unpredictable.
5
In America, handshakes became prevalent because they represented equality and freedom.
6
A research conducted in 2015 showed that exactly 25% of participants smelled their hands after a handshake.
7
People often smell their hands to spot poisonous chemicals.

1 ____ Shaking hands is an indicator of hospitality.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b9e3fed-bfd0-5be3-be2c-1a46bda797fe', '8d0a9044-d8be-5bf4-9e3d-c0d18dbd71e1', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc611de8-6ac5-51b8-a810-e80be3049c00', '8d0a9044-d8be-5bf4-9e3d-c0d18dbd71e1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51f34437-033e-558c-b8c0-666e488b129f', '8d0a9044-d8be-5bf4-9e3d-c0d18dbd71e1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('14bd6d41-a5d8-5f05-817e-692fa0059357', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Question 1-7
Question 1-7
Choose TRUE if the statement agrees with the information given in the text, choose FALSE if the statement contradicts the information, or choose NOT GIVEN if there is no information on this.
1
Shaking hands is an indicator of hospitality.
2
Evidence showed that the handshake started as a sign of peace.
3
When shaking hands, people often rolled up their sleeves.
4
The use of a handshake in different situations can be unpredictable.
5
In America, handshakes became prevalent because they represented equality and freedom.
6
A research conducted in 2015 showed that exactly 25% of participants smelled their hands after a handshake.
7
People often smell their hands to spot poisonous chemicals.

2 ____ Evidence showed that the handshake started as a sign of peace.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a1a281d-cb83-57a5-8b73-ddf04432314a', '14bd6d41-a5d8-5f05-817e-692fa0059357', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba76f4ee-64df-5b1d-8383-c5747f47a24e', '14bd6d41-a5d8-5f05-817e-692fa0059357', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5649c6f-386d-5157-8cb8-9f13645a53f0', '14bd6d41-a5d8-5f05-817e-692fa0059357', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f43557db-d549-577d-83c2-929288e20b1c', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Question 1-7
Question 1-7
Choose TRUE if the statement agrees with the information given in the text, choose FALSE if the statement contradicts the information, or choose NOT GIVEN if there is no information on this.
1
Shaking hands is an indicator of hospitality.
2
Evidence showed that the handshake started as a sign of peace.
3
When shaking hands, people often rolled up their sleeves.
4
The use of a handshake in different situations can be unpredictable.
5
In America, handshakes became prevalent because they represented equality and freedom.
6
A research conducted in 2015 showed that exactly 25% of participants smelled their hands after a handshake.
7
People often smell their hands to spot poisonous chemicals.

3 ____ When shaking hands, people often rolled up their sleeves.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce7abd14-2022-55c0-b7d2-759344462c91', 'f43557db-d549-577d-83c2-929288e20b1c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('396147ac-52e5-5e53-b48d-4fd2230e41fb', 'f43557db-d549-577d-83c2-929288e20b1c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e518da4d-a9eb-52ef-93f6-ddac629893d5', 'f43557db-d549-577d-83c2-929288e20b1c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bca2b540-a886-5582-8f8b-f10e6807f343', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Question 1-7
Question 1-7
Choose TRUE if the statement agrees with the information given in the text, choose FALSE if the statement contradicts the information, or choose NOT GIVEN if there is no information on this.
1
Shaking hands is an indicator of hospitality.
2
Evidence showed that the handshake started as a sign of peace.
3
When shaking hands, people often rolled up their sleeves.
4
The use of a handshake in different situations can be unpredictable.
5
In America, handshakes became prevalent because they represented equality and freedom.
6
A research conducted in 2015 showed that exactly 25% of participants smelled their hands after a handshake.
7
People often smell their hands to spot poisonous chemicals.

4 ____ The use of a handshake in different situations can be unpredictable.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f78d181-727c-5d99-bae4-6283224741ca', 'bca2b540-a886-5582-8f8b-f10e6807f343', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e6b4e89-3e07-5477-bd26-31fd5e59c3ba', 'bca2b540-a886-5582-8f8b-f10e6807f343', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96465bfe-6b0d-5e6d-8014-af9ea3feddaa', 'bca2b540-a886-5582-8f8b-f10e6807f343', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c39b24e0-e2f8-5927-9db0-fdca2154a49e', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Question 1-7
Question 1-7
Choose TRUE if the statement agrees with the information given in the text, choose FALSE if the statement contradicts the information, or choose NOT GIVEN if there is no information on this.
1
Shaking hands is an indicator of hospitality.
2
Evidence showed that the handshake started as a sign of peace.
3
When shaking hands, people often rolled up their sleeves.
4
The use of a handshake in different situations can be unpredictable.
5
In America, handshakes became prevalent because they represented equality and freedom.
6
A research conducted in 2015 showed that exactly 25% of participants smelled their hands after a handshake.
7
People often smell their hands to spot poisonous chemicals.

5 ____ In America, handshakes became prevalent because they represented equality and freedom.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('966d4649-39c9-5089-b935-8e387f032393', 'c39b24e0-e2f8-5927-9db0-fdca2154a49e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d27b7a3-8eae-5b14-a943-b4701469f474', 'c39b24e0-e2f8-5927-9db0-fdca2154a49e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a756876d-5baf-5bdd-b249-dacfedbaaeee', 'c39b24e0-e2f8-5927-9db0-fdca2154a49e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('64a6c3dd-a2bc-51a2-aaf7-16f66ea0dbd5', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Question 1-7
Question 1-7
Choose TRUE if the statement agrees with the information given in the text, choose FALSE if the statement contradicts the information, or choose NOT GIVEN if there is no information on this.
1
Shaking hands is an indicator of hospitality.
2
Evidence showed that the handshake started as a sign of peace.
3
When shaking hands, people often rolled up their sleeves.
4
The use of a handshake in different situations can be unpredictable.
5
In America, handshakes became prevalent because they represented equality and freedom.
6
A research conducted in 2015 showed that exactly 25% of participants smelled their hands after a handshake.
7
People often smell their hands to spot poisonous chemicals.

6 ____ A research conducted in 2015 showed that exactly 25% of participants smelled their hands after a handshake.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('425557f5-0aca-5e64-9673-52642558dac9', '64a6c3dd-a2bc-51a2-aaf7-16f66ea0dbd5', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1109cad-1f9a-57dc-80e7-0835ecd4e7bf', '64a6c3dd-a2bc-51a2-aaf7-16f66ea0dbd5', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('763f1545-b13e-563b-94f4-1b650677293a', '64a6c3dd-a2bc-51a2-aaf7-16f66ea0dbd5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c30c46a5-cd60-5f63-8aec-c4d6b3908ffd', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Question 1-7
Question 1-7
Choose TRUE if the statement agrees with the information given in the text, choose FALSE if the statement contradicts the information, or choose NOT GIVEN if there is no information on this.
1
Shaking hands is an indicator of hospitality.
2
Evidence showed that the handshake started as a sign of peace.
3
When shaking hands, people often rolled up their sleeves.
4
The use of a handshake in different situations can be unpredictable.
5
In America, handshakes became prevalent because they represented equality and freedom.
6
A research conducted in 2015 showed that exactly 25% of participants smelled their hands after a handshake.
7
People often smell their hands to spot poisonous chemicals.

7 ____ People often smell their hands to spot poisonous chemicals.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eeb7de94-c95a-5a9a-9653-1f9ceed80c6b', 'c30c46a5-cd60-5f63-8aec-c4d6b3908ffd', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd809ee1-4537-5a04-8a17-7dfb50200d94', 'c30c46a5-cd60-5f63-8aec-c4d6b3908ffd', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a527e0e3-97f8-5160-8456-c0dcbcfb4769', 'c30c46a5-cd60-5f63-8aec-c4d6b3908ffd', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7b8397b4-1d43-5af5-b9fa-746faa622dfa', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Question 8-12
Question 8-12
Complete the summary below.
Choose no more than
THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answer in boxes.
The history of cheek kissing
In the past, Christian used cheek kisses in
8
. In the Middle Age, the kiss-as-greeting was used to show
9
or used in making agreements. At present, it is a norm for people almost all over the world to greet each other. In Rome, people named different types of kisses in different ways. It is common for people in Paris to exchange
10
. The standard is three in Provence and four in the Lore Valley. A kiss on the cheek is also popular among people of Egypt, Latin America and the Philippines. People believe that in the 14th century, the cheek kiss might have been paused and it remained so for
11
. In 2009, due to
12
, cheek kisses were also stopped for a while.

In the past, Christian used cheek kisses in 8 ____ . In the Middle Age, the kiss-as-greeting was used to show 9 ____ or used in making agreements. At present, it is a norm for people almost all over the world to greet each other. In Rome, people named different types of kisses in different ways. It is common for people in Paris to exchange 10 ____ . The standard is three in Provence and four in the Lore Valley. A kiss on the cheek is also popular among people of Egypt, Latin America and the Philippines. People believe that in the 14th century, the cheek kiss might have been paused and it remained so for 11 ____ . In 2009, due to 12 ____ , cheek kisses were also stopped for a while.$md$, NULL, ARRAY['.*religious.*ceremonies.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('74a5403b-f386-5f7b-aae3-a0bf12a2c03d', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Question 8-12
Question 8-12
Complete the summary below.
Choose no more than
THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answer in boxes.
The history of cheek kissing
In the past, Christian used cheek kisses in
8
. In the Middle Age, the kiss-as-greeting was used to show
9
or used in making agreements. At present, it is a norm for people almost all over the world to greet each other. In Rome, people named different types of kisses in different ways. It is common for people in Paris to exchange
10
. The standard is three in Provence and four in the Lore Valley. A kiss on the cheek is also popular among people of Egypt, Latin America and the Philippines. People believe that in the 14th century, the cheek kiss might have been paused and it remained so for
11
. In 2009, due to
12
, cheek kisses were also stopped for a while.

In the past, Christian used cheek kisses in 8 ____ . In the Middle Age, the kiss-as-greeting was used to show 9 ____ or used in making agreements. At present, it is a norm for people almost all over the world to greet each other. In Rome, people named different types of kisses in different ways. It is common for people in Paris to exchange 10 ____ . The standard is three in Provence and four in the Lore Valley. A kiss on the cheek is also popular among people of Egypt, Latin America and the Philippines. People believe that in the 14th century, the cheek kiss might have been paused and it remained so for 11 ____ . In 2009, due to 12 ____ , cheek kisses were also stopped for a while.$md$, NULL, ARRAY['.*religious.*ceremonies.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8e3758a8-0ea9-5706-8a68-c26cbc54fbae', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Question 8-12
Question 8-12
Complete the summary below.
Choose no more than
THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answer in boxes.
The history of cheek kissing
In the past, Christian used cheek kisses in
8
. In the Middle Age, the kiss-as-greeting was used to show
9
or used in making agreements. At present, it is a norm for people almost all over the world to greet each other. In Rome, people named different types of kisses in different ways. It is common for people in Paris to exchange
10
. The standard is three in Provence and four in the Lore Valley. A kiss on the cheek is also popular among people of Egypt, Latin America and the Philippines. People believe that in the 14th century, the cheek kiss might have been paused and it remained so for
11
. In 2009, due to
12
, cheek kisses were also stopped for a while.

In the past, Christian used cheek kisses in 8 ____ . In the Middle Age, the kiss-as-greeting was used to show 9 ____ or used in making agreements. At present, it is a norm for people almost all over the world to greet each other. In Rome, people named different types of kisses in different ways. It is common for people in Paris to exchange 10 ____ . The standard is three in Provence and four in the Lore Valley. A kiss on the cheek is also popular among people of Egypt, Latin America and the Philippines. People believe that in the 14th century, the cheek kiss might have been paused and it remained so for 11 ____ . In 2009, due to 12 ____ , cheek kisses were also stopped for a while.$md$, NULL, ARRAY['.*religious.*ceremonies.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1b75977c-7588-53f0-a99b-bea5baff2463', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Question 8-12
Question 8-12
Complete the summary below.
Choose no more than
THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answer in boxes.
The history of cheek kissing
In the past, Christian used cheek kisses in
8
. In the Middle Age, the kiss-as-greeting was used to show
9
or used in making agreements. At present, it is a norm for people almost all over the world to greet each other. In Rome, people named different types of kisses in different ways. It is common for people in Paris to exchange
10
. The standard is three in Provence and four in the Lore Valley. A kiss on the cheek is also popular among people of Egypt, Latin America and the Philippines. People believe that in the 14th century, the cheek kiss might have been paused and it remained so for
11
. In 2009, due to
12
, cheek kisses were also stopped for a while.

In the past, Christian used cheek kisses in 8 ____ . In the Middle Age, the kiss-as-greeting was used to show 9 ____ or used in making agreements. At present, it is a norm for people almost all over the world to greet each other. In Rome, people named different types of kisses in different ways. It is common for people in Paris to exchange 10 ____ . The standard is three in Provence and four in the Lore Valley. A kiss on the cheek is also popular among people of Egypt, Latin America and the Philippines. People believe that in the 14th century, the cheek kiss might have been paused and it remained so for 11 ____ . In 2009, due to 12 ____ , cheek kisses were also stopped for a while.$md$, NULL, ARRAY['.*religious.*ceremonies.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('800ce709-fea3-5826-8bc6-5802af41e311', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Question 8-12
Question 8-12
Complete the summary below.
Choose no more than
THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answer in boxes.
The history of cheek kissing
In the past, Christian used cheek kisses in
8
. In the Middle Age, the kiss-as-greeting was used to show
9
or used in making agreements. At present, it is a norm for people almost all over the world to greet each other. In Rome, people named different types of kisses in different ways. It is common for people in Paris to exchange
10
. The standard is three in Provence and four in the Lore Valley. A kiss on the cheek is also popular among people of Egypt, Latin America and the Philippines. People believe that in the 14th century, the cheek kiss might have been paused and it remained so for
11
. In 2009, due to
12
, cheek kisses were also stopped for a while.

In the past, Christian used cheek kisses in 8 ____ . In the Middle Age, the kiss-as-greeting was used to show 9 ____ or used in making agreements. At present, it is a norm for people almost all over the world to greet each other. In Rome, people named different types of kisses in different ways. It is common for people in Paris to exchange 10 ____ . The standard is three in Provence and four in the Lore Valley. A kiss on the cheek is also popular among people of Egypt, Latin America and the Philippines. People believe that in the 14th century, the cheek kiss might have been paused and it remained so for 11 ____ . In 2009, due to 12 ____ , cheek kisses were also stopped for a while.$md$, NULL, ARRAY['.*religious.*ceremonies.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a1256a7b-50c5-5b4f-9af0-8bbfa2e6c57a', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Question 13-14
Question 13-14
Answer the question below.
Choose NO MORE THAN TWO WORDS from the passage for each answer.
Write your answers in boxes.
13 What did French Health Minister advise people to avoid to prevent the spread of coronavirus?
13
14 What can be transferred from a handshake?
14

13 What did French Health Minister advise people to avoid to prevent the spread of coronavirus? 13 ____$md$, NULL, ARRAY['.*social.*contacts.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('29095ac1-71d2-50af-882e-0e38b2100055', '4c7fc169-f6db-54d5-a728-57ffc1ca16f1', 14, 'SHORT_ANSWER', 'READING', 4, $md$### Question 14

Question 13-14
Question 13-14
Answer the question below.
Choose NO MORE THAN TWO WORDS from the passage for each answer.
Write your answers in boxes.
13 What did French Health Minister advise people to avoid to prevent the spread of coronavirus?
13
14 What can be transferred from a handshake?
14

14 What can be transferred from a handshake? 14 ____$md$, NULL, ARRAY['.*germs.*or.*bacteria.*']);

COMMIT;
