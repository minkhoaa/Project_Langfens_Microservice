BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-design-the-mat-and-foot-health-1382'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-design-the-mat-and-foot-health-1382';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-design-the-mat-and-foot-health-1382';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-design-the-mat-and-foot-health-1382';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('bb331499-b191-5a96-965a-7712c41cea1c', 'ielts-reading-design-the-mat-and-foot-health-1382', $t$Design the mat and Foot health$t$, $md$## Design the mat and Foot health

Nguồn:
- Test: https://mini-ielts.com/1382/reading/design-the-mat-and-foot-health
- Solution: https://mini-ielts.com/1382/view-solution/reading/design-the-mat-and-foot-health$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('0b8d415a-b18e-5567-9534-f98025524c88', 'bb331499-b191-5a96-965a-7712c41cea1c', 1, $t$Reading — Design the mat and Foot health$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Design the mat and Foot health

A

Indoor types will appreciate the cobblestone walkway, a knobbly textured plastic mat that they can wobble along in the comfort of their own homes. And for the more adventurous, there are shoes designed to throw you off balance.

B

The technology may be cutting edge, but its origins are deep and exotic. Research into the idea that flat floors could be detrimental to our health was pioneered back in the late 1960s. While others in Long Beach, California, contemplated peace and love, podiatrist Charles Brantingham and physiologist Bruce Beekman were concerned with more pedestrian matters. They reckoned that the growing epidemic of high blood pressure, varicose veins and deep-vein thromboses might be linked to the uniformity of the surfaces that we tend to stand and walk on.

C

The trouble, as they saw it, was that walking continuously on flat floors, sidewalks and streets concentrate forces on just a few areas of the foot. As a result, these surfaces are likely to be far more conducive to chronic stress syndromes than natural ones, where the foot meets the ground in a wide variety of orientations. The anatomy of the foot parallels that of the human hand – each having 26 bones, 33 joints and more than 100 muscles, tendons and ligaments. Modem lifestyles waste all this flexibility in your socks. Brantingham and Beekman became convinced that damage was being done simply by people standing on even surfaces and that this could be rectified by introducing a wobble.

D

“In Beijing and Shanghai city dwellers take daily walks on cobbled paths to improve their health.” To test their ideas, they got 65 clerks and factory workers to try standing on a variable terrain floor – spongy mats with amounts of giving across the surface. This modest irregularity allowed the soles of the volunteers’ feet to deviate slightly from the horizontal each time they shifted position. As the researchers hoped, this simple intervention turned out to make a huge difference over just a few weeks. Just a slight wobble from the floor activated a host of muscles in people’s legs, which in turn helped to pump blood back to their hearts. The muscle action prevented the pooling of blood in their feet and legs, reducing the stress on the entire cardiovascular system. And two-thirds of the volunteers reported feeling much less tired. Yet decades later, the flooring of the world’s workplaces remains relentlessly smooth.

E

Earlier this year, however, the idea was given a new lease of life when researchers in Oregon announced findings from a similar experiment with people over 60. John Fisher and colleagues at the Oregon Research Institute in Eugene designed a mat intended to replicate the effect of walking on cobblestones. In tests funded by the National Institute of Aging, they got some 50 adults to walk on the mats in their stockinged feet for less than an hour three times a week. After 16 weeks, these people showed marked improvements in balance and mobility, and even a significant reduction in blood pressure. People in a control group who walked on ordinary floors also improved but not as dramatically.

F

The mats are now on sale at $35. “Our first 1000 cobblestone mats sold in three weeks,” Fisher says. Production is now being scaled up. Even so, demand could exceed supply if this foot-stimulating activity really is a “useful non-pharmacological approach for preventing or controlling hypertension of older adults”, as the researchers believe. They are not alone in extolling the revitalizing powers of cobblestones. Reflexologists have long advocated walking on textured surfaces to stimulate so-called “acupoints” on the soles of the feet. Practitioners of this unorthodox therapy believe that pressure applied to particular spots on the foot connects directly to corresponding organs and somehow enhances their function. In China, spas, hotels, apartment blocks and even factories promote their cobblestone paths as healthful amenities. Fisher admits he got the idea from regular visits to the country. In Beijing and Shanghai city dwellers take daily walks along cobbled paths to improve their health. “In the big cities, people take off their shoes and walk on these paths for 5 or 10 minutes, perhaps several times a day,” Fisher says.

G

The idea is now taking off in Europe too. People in Germany, Austria and Switzerland can visit “barefoot parks” and walk along “paths of the senses” – with mud, logs, stone and moss underfoot – to receive what’s known there as reflexzon-massage. And it is not difficult to construct your own “health pathway”. American reflexologists Barbara and Kevin Kunz, based in Albuquerque, New Mexico, advise that you cobble together a walkway using broom handles, bamboo poles, hosepipes, gravel, pebbles, dried peas, driftwood, fallen logs, sand, door mats and strips of turf.

H

If your enthusiasm for DIY doesn’t stretch to this, and Fisher’s cobblestone mats are all sold out, there is another option. A new shoe on the market claims to transform flat, hard, artificial surfaces into something like natural uneven ground. “These shoes have an unbelievable effect,” says Benno Nigg, an exercise scientist at the human performance laboratory of Calgary University in Canada, which has done contract research for the shoe’s manufacturers. “They are one of the best things to have happened to humankind for years.” Known as Masai Barefoot Technology, or MBTs, the shoes have rounded soles that cause you to rock slightly when you stand still, exercising the small muscles around the ankle that are responsible for fore-aft stability. Forces in the joint are reduced, putting less strain on the system, Nigg claims.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a839fb46-5f8f-5b61-b09e-e6f8d9a33fe8', '0b8d415a-b18e-5567-9534-f98025524c88', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Charles Brantingham and Bruce Beekman are the pioneers to research the connection between hyper illness and conditions of road.
2
John Fisher and his colleagues found that those who walked on cobble-stones suffered a worsening physical condition.
3
Manufacture of Fisher’s cobblestone mats booms due to high demand of this product.
4
The research works such as customized pathway from Barbara and Kevin Kunz were inspired from an oversea trip.
5
Benno Nigg suggests that shoes of Masai Barefoot Technology have a specific age limitation.

1 ____ Charles Brantingham and Bruce Beekman are the pioneers to research the connection between hyper illness and conditions of road.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8c4dcdb-0e79-5744-ac5e-0ee3c526731e', 'a839fb46-5f8f-5b61-b09e-e6f8d9a33fe8', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f31d8e08-6aca-5bb5-951f-46a19ade18ff', 'a839fb46-5f8f-5b61-b09e-e6f8d9a33fe8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61f8003a-89d5-5587-883c-789b44e4b60c', 'a839fb46-5f8f-5b61-b09e-e6f8d9a33fe8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2e03a33d-d5c2-5ec1-9dfe-6644e66fa718', '0b8d415a-b18e-5567-9534-f98025524c88', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Charles Brantingham and Bruce Beekman are the pioneers to research the connection between hyper illness and conditions of road.
2
John Fisher and his colleagues found that those who walked on cobble-stones suffered a worsening physical condition.
3
Manufacture of Fisher’s cobblestone mats booms due to high demand of this product.
4
The research works such as customized pathway from Barbara and Kevin Kunz were inspired from an oversea trip.
5
Benno Nigg suggests that shoes of Masai Barefoot Technology have a specific age limitation.

2 ____ John Fisher and his colleagues found that those who walked on cobble-stones suffered a worsening physical condition.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96947a99-963a-5d96-90a2-06cce299be5a', '2e03a33d-d5c2-5ec1-9dfe-6644e66fa718', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ca35b62-610c-5730-9559-5698ca763986', '2e03a33d-d5c2-5ec1-9dfe-6644e66fa718', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33dcd0eb-2e20-5071-91bc-1eb79b4dd368', '2e03a33d-d5c2-5ec1-9dfe-6644e66fa718', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3cc5ad67-e705-5535-8086-c2a45b4f3c9c', '0b8d415a-b18e-5567-9534-f98025524c88', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Charles Brantingham and Bruce Beekman are the pioneers to research the connection between hyper illness and conditions of road.
2
John Fisher and his colleagues found that those who walked on cobble-stones suffered a worsening physical condition.
3
Manufacture of Fisher’s cobblestone mats booms due to high demand of this product.
4
The research works such as customized pathway from Barbara and Kevin Kunz were inspired from an oversea trip.
5
Benno Nigg suggests that shoes of Masai Barefoot Technology have a specific age limitation.

3 ____ Manufacture of Fisher’s cobblestone mats booms due to high demand of this product.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d752c18d-1615-5dfd-a146-e9a14b4087c4', '3cc5ad67-e705-5535-8086-c2a45b4f3c9c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3abd6c51-f477-52e7-94bf-2b3da2fc5966', '3cc5ad67-e705-5535-8086-c2a45b4f3c9c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13a18516-be36-5062-ba7f-2d3d5e0948e6', '3cc5ad67-e705-5535-8086-c2a45b4f3c9c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bb7860ba-5ce3-5cab-b5fd-5b3ba92f649d', '0b8d415a-b18e-5567-9534-f98025524c88', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Charles Brantingham and Bruce Beekman are the pioneers to research the connection between hyper illness and conditions of road.
2
John Fisher and his colleagues found that those who walked on cobble-stones suffered a worsening physical condition.
3
Manufacture of Fisher’s cobblestone mats booms due to high demand of this product.
4
The research works such as customized pathway from Barbara and Kevin Kunz were inspired from an oversea trip.
5
Benno Nigg suggests that shoes of Masai Barefoot Technology have a specific age limitation.

4 ____ The research works such as customized pathway from Barbara and Kevin Kunz were inspired from an oversea trip.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8cc89c2-66d2-5ffc-b974-6f4557aa81f6', 'bb7860ba-5ce3-5cab-b5fd-5b3ba92f649d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5340e913-f48b-5579-a73b-6436d235ef4b', 'bb7860ba-5ce3-5cab-b5fd-5b3ba92f649d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c9871f5-d319-532e-b9e1-caca2b719926', 'bb7860ba-5ce3-5cab-b5fd-5b3ba92f649d', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e2aba49-0bcc-5967-88e4-8cc4714160fd', '0b8d415a-b18e-5567-9534-f98025524c88', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Charles Brantingham and Bruce Beekman are the pioneers to research the connection between hyper illness and conditions of road.
2
John Fisher and his colleagues found that those who walked on cobble-stones suffered a worsening physical condition.
3
Manufacture of Fisher’s cobblestone mats booms due to high demand of this product.
4
The research works such as customized pathway from Barbara and Kevin Kunz were inspired from an oversea trip.
5
Benno Nigg suggests that shoes of Masai Barefoot Technology have a specific age limitation.

5 ____ Benno Nigg suggests that shoes of Masai Barefoot Technology have a specific age limitation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88646aff-738e-579e-9aaa-ca432b4ed9a0', '4e2aba49-0bcc-5967-88e4-8cc4714160fd', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62db74cf-0ca0-5be6-a15b-1c2f104f09da', '4e2aba49-0bcc-5967-88e4-8cc4714160fd', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bd5196c-4b5f-54f4-b167-7b1bd55f0f30', '4e2aba49-0bcc-5967-88e4-8cc4714160fd', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('84df4cab-00f7-5bd8-add9-99f1efd37b78', '0b8d415a-b18e-5567-9534-f98025524c88', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-8
Questions 6-8
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
33-35
on your answer sheet.
6.
Which of the followings is true according to
J Fisher’s experiment
cobbled paths in paragraph D
A
Spongy mats make the volunteer feel unbalance.
B
Chinese special culture makes it only applicable in a certain area.
C
More than half of participants reported a positive response.
D
This method could cure cardiovascular disease unexpectedly.
7.
John Fisher and colleagues from the
Oregon Research Institute
has found the followings:
A
People walk on special designed mat only have improvements in blood pressure.
B
Blood pressure of control group improves not as much as the other one.
C
Elder people improve more dramatically than youngsters.
D
Testing time of 16 weeks is a significant factor in this experiment.
8.
Shoes from
MBT
are also beneficial for your health as which of the following reasons:
A
Special designed soles on the bottom make your feet stabled
B
Researcher has previous experience in this field.
C
African style shoes were very successful in store sales.
D
They can protect the ankle and muscles around feet.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e1c9ce9-2279-52ad-a68b-aaeaf7164cc8', '0b8d415a-b18e-5567-9534-f98025524c88', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-8
Questions 6-8
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
33-35
on your answer sheet.
6.
Which of the followings is true according to
J Fisher’s experiment
cobbled paths in paragraph D
A
Spongy mats make the volunteer feel unbalance.
B
Chinese special culture makes it only applicable in a certain area.
C
More than half of participants reported a positive response.
D
This method could cure cardiovascular disease unexpectedly.
7.
John Fisher and colleagues from the
Oregon Research Institute
has found the followings:
A
People walk on special designed mat only have improvements in blood pressure.
B
Blood pressure of control group improves not as much as the other one.
C
Elder people improve more dramatically than youngsters.
D
Testing time of 16 weeks is a significant factor in this experiment.
8.
Shoes from
MBT
are also beneficial for your health as which of the following reasons:
A
Special designed soles on the bottom make your feet stabled
B
Researcher has previous experience in this field.
C
African style shoes were very successful in store sales.
D
They can protect the ankle and muscles around feet.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a082b660-9f95-5872-b9d4-b0832f81d7e1', '0b8d415a-b18e-5567-9534-f98025524c88', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-8
Questions 6-8
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
33-35
on your answer sheet.
6.
Which of the followings is true according to
J Fisher’s experiment
cobbled paths in paragraph D
A
Spongy mats make the volunteer feel unbalance.
B
Chinese special culture makes it only applicable in a certain area.
C
More than half of participants reported a positive response.
D
This method could cure cardiovascular disease unexpectedly.
7.
John Fisher and colleagues from the
Oregon Research Institute
has found the followings:
A
People walk on special designed mat only have improvements in blood pressure.
B
Blood pressure of control group improves not as much as the other one.
C
Elder people improve more dramatically than youngsters.
D
Testing time of 16 weeks is a significant factor in this experiment.
8.
Shoes from
MBT
are also beneficial for your health as which of the following reasons:
A
Special designed soles on the bottom make your feet stabled
B
Researcher has previous experience in this field.
C
African style shoes were very successful in store sales.
D
They can protect the ankle and muscles around feet.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('57440baa-192f-5c8d-8e4b-f46f08320f98', '0b8d415a-b18e-5567-9534-f98025524c88', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
The anatomy of human’s foot is complex; which
9
human hand. The experiment, conducted on employees, showed that body movement on surface of different condition can lower the
10
on heart. Similarity was also found in another experiment conducted by a researcher from the Oregon Research Institute. The test also showed there was a substantial
11
. in hypertension. Reflexologists advise people to work on a road with resistance to stimulate certain points of body via standing on the
12
In the end, the author of the passage also advocates that people can build their own health
13
. except for buying the special mats and shoes.

The anatomy of human’s foot is complex; which 9 ____ human hand. The experiment, conducted on employees, showed that body movement on surface of different condition can lower the 10 ____ on heart. Similarity was also found in another experiment conducted by a researcher from the Oregon Research Institute. The test also showed there was a substantial 11 ____ . in hypertension. Reflexologists advise people to work on a road with resistance to stimulate certain points of body via standing on the 12 ____ In the end, the author of the passage also advocates that people can build their own health 13 ____ . except for buying the special mats and shoes.$md$, NULL, ARRAY['.*parallel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4b400a47-85cd-56cc-84d4-ec7bbe04dd43', '0b8d415a-b18e-5567-9534-f98025524c88', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
The anatomy of human’s foot is complex; which
9
human hand. The experiment, conducted on employees, showed that body movement on surface of different condition can lower the
10
on heart. Similarity was also found in another experiment conducted by a researcher from the Oregon Research Institute. The test also showed there was a substantial
11
. in hypertension. Reflexologists advise people to work on a road with resistance to stimulate certain points of body via standing on the
12
In the end, the author of the passage also advocates that people can build their own health
13
. except for buying the special mats and shoes.

The anatomy of human’s foot is complex; which 9 ____ human hand. The experiment, conducted on employees, showed that body movement on surface of different condition can lower the 10 ____ on heart. Similarity was also found in another experiment conducted by a researcher from the Oregon Research Institute. The test also showed there was a substantial 11 ____ . in hypertension. Reflexologists advise people to work on a road with resistance to stimulate certain points of body via standing on the 12 ____ In the end, the author of the passage also advocates that people can build their own health 13 ____ . except for buying the special mats and shoes.$md$, NULL, ARRAY['.*parallel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('faa1060a-df1c-528f-8ebd-e90847dd610c', '0b8d415a-b18e-5567-9534-f98025524c88', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
The anatomy of human’s foot is complex; which
9
human hand. The experiment, conducted on employees, showed that body movement on surface of different condition can lower the
10
on heart. Similarity was also found in another experiment conducted by a researcher from the Oregon Research Institute. The test also showed there was a substantial
11
. in hypertension. Reflexologists advise people to work on a road with resistance to stimulate certain points of body via standing on the
12
In the end, the author of the passage also advocates that people can build their own health
13
. except for buying the special mats and shoes.

The anatomy of human’s foot is complex; which 9 ____ human hand. The experiment, conducted on employees, showed that body movement on surface of different condition can lower the 10 ____ on heart. Similarity was also found in another experiment conducted by a researcher from the Oregon Research Institute. The test also showed there was a substantial 11 ____ . in hypertension. Reflexologists advise people to work on a road with resistance to stimulate certain points of body via standing on the 12 ____ In the end, the author of the passage also advocates that people can build their own health 13 ____ . except for buying the special mats and shoes.$md$, NULL, ARRAY['.*parallel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c31f8679-8800-52d1-8964-1372e6658d00', '0b8d415a-b18e-5567-9534-f98025524c88', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
The anatomy of human’s foot is complex; which
9
human hand. The experiment, conducted on employees, showed that body movement on surface of different condition can lower the
10
on heart. Similarity was also found in another experiment conducted by a researcher from the Oregon Research Institute. The test also showed there was a substantial
11
. in hypertension. Reflexologists advise people to work on a road with resistance to stimulate certain points of body via standing on the
12
In the end, the author of the passage also advocates that people can build their own health
13
. except for buying the special mats and shoes.

The anatomy of human’s foot is complex; which 9 ____ human hand. The experiment, conducted on employees, showed that body movement on surface of different condition can lower the 10 ____ on heart. Similarity was also found in another experiment conducted by a researcher from the Oregon Research Institute. The test also showed there was a substantial 11 ____ . in hypertension. Reflexologists advise people to work on a road with resistance to stimulate certain points of body via standing on the 12 ____ In the end, the author of the passage also advocates that people can build their own health 13 ____ . except for buying the special mats and shoes.$md$, NULL, ARRAY['.*parallel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('33a63307-01fb-5f10-9649-e5176feb1b53', '0b8d415a-b18e-5567-9534-f98025524c88', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
The anatomy of human’s foot is complex; which
9
human hand. The experiment, conducted on employees, showed that body movement on surface of different condition can lower the
10
on heart. Similarity was also found in another experiment conducted by a researcher from the Oregon Research Institute. The test also showed there was a substantial
11
. in hypertension. Reflexologists advise people to work on a road with resistance to stimulate certain points of body via standing on the
12
In the end, the author of the passage also advocates that people can build their own health
13
. except for buying the special mats and shoes.

The anatomy of human’s foot is complex; which 9 ____ human hand. The experiment, conducted on employees, showed that body movement on surface of different condition can lower the 10 ____ on heart. Similarity was also found in another experiment conducted by a researcher from the Oregon Research Institute. The test also showed there was a substantial 11 ____ . in hypertension. Reflexologists advise people to work on a road with resistance to stimulate certain points of body via standing on the 12 ____ In the end, the author of the passage also advocates that people can build their own health 13 ____ . except for buying the special mats and shoes.$md$, NULL, ARRAY['.*parallel.*']);

COMMIT;
