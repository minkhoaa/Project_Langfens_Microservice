BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-life-casting-and-art-1103'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-life-casting-and-art-1103';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-life-casting-and-art-1103';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-life-casting-and-art-1103';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4acaef19-e368-5496-bd4e-544d4e997f11', 'ielts-reading-life-casting-and-art-1103', $t$Life-Casting and Art$t$, $md$## Life-Casting and Art

Nguồn:
- Test: https://mini-ielts.com/1103/reading/life-casting-and-art
- Solution: https://mini-ielts.com/1103/view-solution/reading/life-casting-and-art$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('78962dbc-f3eb-5f12-90e4-10a2071e461f', '4acaef19-e368-5496-bd4e-544d4e997f11', 1, $t$Reading — Life-Casting and Art$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Life-Casting and Art

Julian Bames explores the questions posed by Life-Casts, an exhibition of plaster moulds of living people and objects which were originally used for scientific purposes

A Art changes over time and our idea of what art is changes too. For example, objects originally intended for devotional, ritualistic or re-creational purposes may be recategorised as art by members of other later civilisations, such as our own, which no longer respond to these purposes.

B What also happens is that techniques and crafts which would have been judged inartistic at the time they were used are reassessed. Life-casting is an interesting example of this. It involved making a plaster mould of a living person or thing. This was complex, technical work, as Benjamin Robert Haydon discovered when he poured 250 litres of plaster over his human model and nearly killed him. At the time, the casts were used for medical research and, consequently, in the nineteenth century life-casting was considered inferior to sculpture in the same way that, more recently, photography was thought to be a lesser art than painting. Both were viewed as unacceptable shortcuts by the ’senior 1 arts. Their virtues of speed and unwavering realism also implied their limitations; they left little or no room for the imagination.

C For many, life-casting was an insult to the sculptor’s creative genius. In an infamous lawsuit of 1834, a moulder whose mask of the dying French emperor Napoleon had been reproduced and sold without his permission was judged to have no rights to the image . In other words, he was specifically held not to be an artist. This judgement reflect the view of established members of the nineteenth-century art world such as Rodin, who commented that life-casting ‘happens fast but it doesn’t make Art’ . Some even feared that ‘if too much nature was allowed in, it would lead Art away from its proper course of the Ideal.

D The painter Gauguin, at the end of the nineteenth century, worried about future developments in photography. If ever the process went into colour, what painter would labour away at a likeness with a brush made from squirrel-tail? But painting has proved robust . Photography has changed it, of course, just as the novel had to reassess narrative after the arrival of the cinema. But the gap between the senior and junior arts was always narrower than the traditionalists implied. Painters have always used technical back-up such as studio assistants to do the boring bits , while apparently lesser crafts involve great skill, thought, preparation and, depending on how we define it， imagination.

E Time changes our view in another way, too. Each new movement implies a reassessment of what has gone before. What is done now alters what was done before. In some cases this is merely self-serving, with the new art using the old to justify itself . It seems to be saying, look at how all of that points to this! Aren’t we clever to be the culmination of all that has gone before? But usually it is a matter of re-alerting the sensibility, reminding us not to take things for granted. Take, for example, the cast of the hand of a giant from a circus, made by an anonymous artist around 1889, an item that would now sit happily in any commercial or public gallery . The most significant impact of this piece is on the eye, in the contradiction between unexpected size and verisimilitude . Next, the human element kicks in. you note that the nails are dirt-encrusted, unless this is the caster’s decorative addition, and the fingertips extend far beyond them. Then you take in the element of choice, arrangement, art if you like, in the neat, pleated, buttoned sleeve-end that gives the item balance and variation of texture. This is just a moulded hand, yet the part stands utterly for the whole. It reminds us slyly, poignantly, of the full-size original

F But is it art? And, if so, why? These are old tediously repeated questions to which artists have often responded, ‘It is art because I am an artist and therefore what I do is art. However, what doesn’t work for literature works much better for art – works of art do float free of their creators’ intentions . Over time the “reader” does become more powerful. Few of us can look at a medieval altarpiece as its painter intended. We believe too little and aesthetically know too much, so we recreate and find new fields of pleasure in the work. Equally, the lack of artistic intention of Paul Richer and other forgotten craftsmen who brushed oil onto flesh, who moulded, cast and decorated in the nineteenth century is now irrelevant. What counts is the surviving object and our response to it. The tests are simple: does it interest the eye, excite the brain, move the mind to reflection and involve the heart. It may, to use the old dichotomy, be beautiful but it is rarely true to any significant depth. One of the constant pleasures of art is its ability to come at us from an unexpected angle and stop us short in wonder.

----------------------------------------------------

Great thanks to volunteer Ngoc Nguyen has contributed these explanations and question markings.

If you want to make a better world like this, please contact us$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c7816b52-a597-5d37-8e60-03c4de9cd08d', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-5
on your answer sheet.
1
an example of a craftsman’s unsuccessful claim to ownership of his work
Locate
2
an example of how trends in art can change attitudes to an earlier work
Locate
3
the original function of a particular type of art
Locate
4
ways of assessing whether or not an object is art
Locate
5
how artists deal with the less interesting aspects of their work
Locate

1 ____ an example of a craftsman’s unsuccessful claim to ownership of his work Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e51745d8-b27c-54f1-8003-dadf311cf876', 'c7816b52-a597-5d37-8e60-03c4de9cd08d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e7ad2b1-522e-5422-ab8c-bc315ba1e535', 'c7816b52-a597-5d37-8e60-03c4de9cd08d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('512020fa-147c-5a5d-a43a-c7c34b3df94e', 'c7816b52-a597-5d37-8e60-03c4de9cd08d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4833b887-20bf-5a09-a8a4-0eab7a80cbb7', 'c7816b52-a597-5d37-8e60-03c4de9cd08d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2eeded7-0494-5cda-86a9-750b0f6bdfa2', 'c7816b52-a597-5d37-8e60-03c4de9cd08d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2d0900f-3a63-53e4-9911-5a7742c23ead', 'c7816b52-a597-5d37-8e60-03c4de9cd08d', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('997f0863-4f4c-5437-8016-6af58618a109', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-5
on your answer sheet.
1
an example of a craftsman’s unsuccessful claim to ownership of his work
Locate
2
an example of how trends in art can change attitudes to an earlier work
Locate
3
the original function of a particular type of art
Locate
4
ways of assessing whether or not an object is art
Locate
5
how artists deal with the less interesting aspects of their work
Locate

2 ____ an example of how trends in art can change attitudes to an earlier work Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a022f000-2cf9-5bdc-833b-4094dd2052d5', '997f0863-4f4c-5437-8016-6af58618a109', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e232b037-e6c5-5920-8823-f6428bba878b', '997f0863-4f4c-5437-8016-6af58618a109', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f92ba50d-a6f6-520c-a659-628b92af1fc9', '997f0863-4f4c-5437-8016-6af58618a109', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f57e2c01-66e9-50de-84d3-06022dbb78af', '997f0863-4f4c-5437-8016-6af58618a109', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('780bb63d-2ae4-5333-ab36-83a3675d8e70', '997f0863-4f4c-5437-8016-6af58618a109', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5df072f0-b881-515a-b6b3-90c4621d8d49', '997f0863-4f4c-5437-8016-6af58618a109', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('637ecb3d-7030-5639-82c5-bee1e612ebe3', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-5
on your answer sheet.
1
an example of a craftsman’s unsuccessful claim to ownership of his work
Locate
2
an example of how trends in art can change attitudes to an earlier work
Locate
3
the original function of a particular type of art
Locate
4
ways of assessing whether or not an object is art
Locate
5
how artists deal with the less interesting aspects of their work
Locate

3 ____ the original function of a particular type of art Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aedde781-6b92-519d-8b49-6493592326e1', '637ecb3d-7030-5639-82c5-bee1e612ebe3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82adf297-ef45-59ac-8445-dc3047745787', '637ecb3d-7030-5639-82c5-bee1e612ebe3', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b33360f6-1954-5067-a291-50730ba305f7', '637ecb3d-7030-5639-82c5-bee1e612ebe3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('809040cc-6c12-5460-aeb2-64868cf599e4', '637ecb3d-7030-5639-82c5-bee1e612ebe3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08e719f3-9b63-5069-bb73-950c3b6abff9', '637ecb3d-7030-5639-82c5-bee1e612ebe3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('471a7bdc-7888-526e-afae-9e92fa7dcc57', '637ecb3d-7030-5639-82c5-bee1e612ebe3', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('52a80704-84aa-5063-b695-800e9289f855', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-5
on your answer sheet.
1
an example of a craftsman’s unsuccessful claim to ownership of his work
Locate
2
an example of how trends in art can change attitudes to an earlier work
Locate
3
the original function of a particular type of art
Locate
4
ways of assessing whether or not an object is art
Locate
5
how artists deal with the less interesting aspects of their work
Locate

4 ____ ways of assessing whether or not an object is art Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c60f2db-3501-5f75-b377-11c318854781', '52a80704-84aa-5063-b695-800e9289f855', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('286933d7-a0dd-5d97-8557-db701a51abf1', '52a80704-84aa-5063-b695-800e9289f855', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29f02df1-a6d8-5e63-9d36-26f9c7f25da2', '52a80704-84aa-5063-b695-800e9289f855', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a094e221-f9be-59b0-88cc-66129a206bde', '52a80704-84aa-5063-b695-800e9289f855', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad8d27e7-9cb5-5122-950c-68c0881227c1', '52a80704-84aa-5063-b695-800e9289f855', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53e5e2f3-2698-58e0-b2d3-fcd27eeeec0f', '52a80704-84aa-5063-b695-800e9289f855', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('61a65cf0-08cf-588c-bab5-d25e43165c78', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-5
on your answer sheet.
1
an example of a craftsman’s unsuccessful claim to ownership of his work
Locate
2
an example of how trends in art can change attitudes to an earlier work
Locate
3
the original function of a particular type of art
Locate
4
ways of assessing whether or not an object is art
Locate
5
how artists deal with the less interesting aspects of their work
Locate

5 ____ how artists deal with the less interesting aspects of their work Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16561f1c-d4d1-58c3-ac9a-81d98915d9cc', '61a65cf0-08cf-588c-bab5-d25e43165c78', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4585a6fe-0ee6-59a3-a5e3-83866c72e1d6', '61a65cf0-08cf-588c-bab5-d25e43165c78', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81b7af0a-7e5f-5be7-8495-c6448e0c1cbc', '61a65cf0-08cf-588c-bab5-d25e43165c78', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eae6662c-b438-5153-b4a1-503fd82acb40', '61a65cf0-08cf-588c-bab5-d25e43165c78', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2114381c-6ba5-5fba-9bdc-f511972eba2e', '61a65cf0-08cf-588c-bab5-d25e43165c78', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02d19050-4f4b-52f6-a33c-e8f329a0f562', '61a65cf0-08cf-588c-bab5-d25e43165c78', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d21c0f82-0cf8-5cb3-a861-b8eb760f5f9d', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-11
Questions 6-11
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
6-11
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
6
Nineteenth-century sculptors admired the speed and realism of life-casting
Locate
7
Rodin believed the quality of the life-casting would improve if a slower process were used
Locate
8
The importance of painting has decreased with the development of colour photography
Locate
9
Life-casting requires more skill than sculpture does
10
New art encourages us to look at earlier work in a fresh way
Locate
11
The intended meaning of a work of art can get lost over time
Locate

6 ____ Nineteenth-century sculptors admired the speed and realism of life-casting Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a858937-cd2d-55a7-bbbf-abb9c3f7b14c', 'd21c0f82-0cf8-5cb3-a861-b8eb760f5f9d', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5dc9727f-402a-5583-9215-481f418608c9', 'd21c0f82-0cf8-5cb3-a861-b8eb760f5f9d', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35d33516-b63e-518e-928e-60b1ab3e04c4', 'd21c0f82-0cf8-5cb3-a861-b8eb760f5f9d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fd705ec7-dd54-58d9-b428-d61e692aeba1', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-11
Questions 6-11
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
6-11
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
6
Nineteenth-century sculptors admired the speed and realism of life-casting
Locate
7
Rodin believed the quality of the life-casting would improve if a slower process were used
Locate
8
The importance of painting has decreased with the development of colour photography
Locate
9
Life-casting requires more skill than sculpture does
10
New art encourages us to look at earlier work in a fresh way
Locate
11
The intended meaning of a work of art can get lost over time
Locate

7 ____ Rodin believed the quality of the life-casting would improve if a slower process were used Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16d98806-499d-5919-ada1-b9a3236c7e9a', 'fd705ec7-dd54-58d9-b428-d61e692aeba1', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81a0fec9-5de9-5244-8091-6dff4b4cef98', 'fd705ec7-dd54-58d9-b428-d61e692aeba1', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a21c9f93-ba42-50c2-822e-c67c9b11d392', 'fd705ec7-dd54-58d9-b428-d61e692aeba1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('64b2dc4e-24a4-5f1d-8f34-1062dbf6796d', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-11
Questions 6-11
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
6-11
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
6
Nineteenth-century sculptors admired the speed and realism of life-casting
Locate
7
Rodin believed the quality of the life-casting would improve if a slower process were used
Locate
8
The importance of painting has decreased with the development of colour photography
Locate
9
Life-casting requires more skill than sculpture does
10
New art encourages us to look at earlier work in a fresh way
Locate
11
The intended meaning of a work of art can get lost over time
Locate

8 ____ The importance of painting has decreased with the development of colour photography Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a153709-8300-5483-94d9-3488b7d2a152', '64b2dc4e-24a4-5f1d-8f34-1062dbf6796d', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('712b24d4-10ff-552e-8edd-4c005f48f2ef', '64b2dc4e-24a4-5f1d-8f34-1062dbf6796d', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('988606b0-a1aa-50b1-babb-086f696f3310', '64b2dc4e-24a4-5f1d-8f34-1062dbf6796d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a55d4cf8-5af3-5735-8258-b8dcb378a446', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-11
Questions 6-11
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
6-11
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
6
Nineteenth-century sculptors admired the speed and realism of life-casting
Locate
7
Rodin believed the quality of the life-casting would improve if a slower process were used
Locate
8
The importance of painting has decreased with the development of colour photography
Locate
9
Life-casting requires more skill than sculpture does
10
New art encourages us to look at earlier work in a fresh way
Locate
11
The intended meaning of a work of art can get lost over time
Locate

9 ____ Life-casting requires more skill than sculpture does$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b074fd0-ab0d-5b81-a362-6b7e82c42d55', 'a55d4cf8-5af3-5735-8258-b8dcb378a446', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5ecb1af-d277-59d2-9ac9-662c3387e054', 'a55d4cf8-5af3-5735-8258-b8dcb378a446', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f54a970-376f-54ea-9540-92a0e5ffa0c3', 'a55d4cf8-5af3-5735-8258-b8dcb378a446', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('65e3a302-ce23-55e3-89db-d19a4451660e', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-11
Questions 6-11
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
6-11
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
6
Nineteenth-century sculptors admired the speed and realism of life-casting
Locate
7
Rodin believed the quality of the life-casting would improve if a slower process were used
Locate
8
The importance of painting has decreased with the development of colour photography
Locate
9
Life-casting requires more skill than sculpture does
10
New art encourages us to look at earlier work in a fresh way
Locate
11
The intended meaning of a work of art can get lost over time
Locate

10 ____ New art encourages us to look at earlier work in a fresh way Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03a12e7e-6d40-5cd1-9225-ff71d6c8415d', '65e3a302-ce23-55e3-89db-d19a4451660e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca9e2d26-c583-53cf-bda3-15b539c0bb40', '65e3a302-ce23-55e3-89db-d19a4451660e', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('624e9c5d-3f66-54cc-9bfe-14c71b2f3111', '65e3a302-ce23-55e3-89db-d19a4451660e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fe43f69c-bc4d-5f5b-8e30-71c765222099', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 6-11
Questions 6-11
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
6-11
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
6
Nineteenth-century sculptors admired the speed and realism of life-casting
Locate
7
Rodin believed the quality of the life-casting would improve if a slower process were used
Locate
8
The importance of painting has decreased with the development of colour photography
Locate
9
Life-casting requires more skill than sculpture does
10
New art encourages us to look at earlier work in a fresh way
Locate
11
The intended meaning of a work of art can get lost over time
Locate

11 ____ The intended meaning of a work of art can get lost over time Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a974e4bc-6962-5632-b4a9-bdccb21727ca', 'fe43f69c-bc4d-5f5b-8e30-71c765222099', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3db1d929-1409-50ea-b65d-d35a98c18819', 'fe43f69c-bc4d-5f5b-8e30-71c765222099', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93ecf6b0-5908-5e42-ab82-c4e3750532f7', 'fe43f69c-bc4d-5f5b-8e30-71c765222099', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('be26003e-15b6-5f06-a282-34ea5e2a95de', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 12-13
Questions 12-13
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
12-13
on your answer sheet.
12.
The most noticeable contrast in the cast of the giants hand is between the
A
dirt and decoration
B
size and realism
C
choice and arrangement
D
balance and texture
Locate
13.
According to the writer, the importance of any artistic object lies in
A
the artist’s intentions
B
the artist’s beliefs
C
the relevance it has to modem life
D
the way we respond to it
Locate

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('18a6d0ab-1911-5415-8dff-f0a88a455404', '78962dbc-f3eb-5f12-90e4-10a2071e461f', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 12-13
Questions 12-13
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
12-13
on your answer sheet.
12.
The most noticeable contrast in the cast of the giants hand is between the
A
dirt and decoration
B
size and realism
C
choice and arrangement
D
balance and texture
Locate
13.
According to the writer, the importance of any artistic object lies in
A
the artist’s intentions
B
the artist’s beliefs
C
the relevance it has to modem life
D
the way we respond to it
Locate

Choose the correct letter, A, B, C or D .$md$, NULL);

COMMIT;
