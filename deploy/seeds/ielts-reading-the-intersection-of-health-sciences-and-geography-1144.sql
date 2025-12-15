BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-intersection-of-health-sciences-and-geography-1144'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-intersection-of-health-sciences-and-geography-1144';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-intersection-of-health-sciences-and-geography-1144';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-intersection-of-health-sciences-and-geography-1144';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('85f26d78-a26a-5967-938f-be847e247b4b', 'ielts-reading-the-intersection-of-health-sciences-and-geography-1144', $t$The Intersection of Health Sciences and Geography$t$, $md$## The Intersection of Health Sciences and Geography

Nguồn:
- Test: https://mini-ielts.com/1144/reading/the-intersection-of-health-sciences-and-geography
- Solution: https://mini-ielts.com/1144/view-solution/reading/the-intersection-of-health-sciences-and-geography$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('13e305b6-0817-5b1d-8c2c-74ab04bc69ee', '85f26d78-a26a-5967-938f-be847e247b4b', 1, $t$Reading — The Intersection of Health Sciences and Geography$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Intersection of Health Sciences and Geography

A While many diseases that affect humans have been eradicated due to improvements in vaccinations and the availability of healthcare, there are still areas around the world where certain health issues are more prevalent. In a world that is far more globalised than ever before, people come into contact with one another through travel and living closer and closer to each other. As a result, super-viruses and other infections resistant to antibiotics are becoming more and more common.

B Geography can often play a very large role in the health concerns of certain populations. For instance, depending on where you live, you will not have the same health concerns as someone who lives in a different geographical region. Perhaps one of the most obvious examples of this idea is malaria-prone areas, which are usually tropical regions that foster a warm and damp environment in which the mosquitos that can give people this disease can grew. Malaria is much less of a problem in high-altitude deserts, for instance .

C In some countries, geographical factors influence the health and well-being of the population in very obvious ways. In many large cities, the wind is not strong enough to clear the air of the massive amounts of smog and pollution that cause asthma, lung problems, eyesight issues and more in the people who live there. Part of the problem is, of course, the massive number of cars being driven , in addition to factories that run on coal power. The rapid industrialisation of some countries in recent years has also led to the cutting down of forests to allow for the expansion of big cities, which makes it even harder to fight the pollution with the fresh air that is produced by plants.

D It is in situations like these that the field of health geography comes into its own. It is an increasingly important area of study in a world where diseases like polio are re-emerging, respiratory diseases continue to spread, and malaria-prone areas are still fighting to find a better cure. Health geography is the combination of, on the one hand, knowledge regarding geography and methods used to analyse and interpret geographical information, and on the other, the study of health, diseases and healthcare practices around the world. The aim of this hybrid science is to create solutions for common geography-based health problems. While people will always be prone to illness, the study of how geography affects our health could lead to the eradication of certain illnesses, and the prevention of others in the future. By understanding why and how we get sick, we can change the way we treat illness and disease specific to certain geographical locations.

E The geography of disease and ill health analyses the frequency with which certain diseases appear in different parts of the world, and overlays the data with the geography of the region, to see if there could be a correlation between the two. Health geographers also study factors that could make certain individuals or a population more likely to be taken ill with a specific health concern or disease, as compared with the population of another area. Health geographers in this field are usually trained as healthcare workers, and have an understanding of basic epidemiology as it relates to the spread of diseases among the population.

F Researchers study the interactions between humans and their environment that could lead to illness (such as asthma in places with high levels of pollution) and work to create a clear way of categorising illnesses, diseases and epidemics into local and global scales. Health geographers can map the spread of illnesses and attempt to identify the reasons behind an increase or decrease in illnesses, as they work to find a way to halt the further spread or re-emergence of diseases in vulnerable populations.

G The second subcategory of health geography is the geography of healthcare provision. This group studies the availability (of lack thereof) of healthcare resources to individuals and populations around the world. In both developed and developing nations there is often a very large discrepancy between the options available to people in different social classes, income brackets, and levels of education . Individuals working in the area of the geography of healthcare provision attempt to assess the levels of healthcare in the area (for instance, it may be very difficult for people to get medical attention because there is a mountain between their village and the nearest hospital). These researchers are on the frontline of making recommendations regarding policy to international organisations, local government bodies and others.

H The field of health geography is often overlooked, but it constitutes a huge area of need in the fields of geography and healthcare. If we can understand how geography affects our health no matter where in the world we are located, we can better treat disease, prevent illness, and keep people safe and well.

----------------------------------------------------

Great thanks to volunteer Chenxu Zhao has contributed these explanations markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d5b5186b-1dcf-5b1e-ae97-722ce3c3dbca', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage has eight sections,
A-H
.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes
1-6
on your answer sheet
NB
You may use any letter
more than once
.
1
an acceptance that not all diseases can be totally eliminated
Locate
2
examples of physical conditions caused by human behaviour
Locate
3
a reference to classifying diseases on the basis of how far they extend geographically
Locate
4
reasons why the level of access to healthcare can vary within a country
Locate
5
a description of health geography as a mixture of different academic fields
Locate
6
a description of the type of area where a particular illness is rare
Locate

1 ____ an acceptance that not all diseases can be totally eliminated Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67a75b30-b410-516a-a445-9ef4e6f09a6c', 'd5b5186b-1dcf-5b1e-ae97-722ce3c3dbca', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dc6b22f-6f2e-51c4-aa26-e67aeb2a438f', 'd5b5186b-1dcf-5b1e-ae97-722ce3c3dbca', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b20ddb75-4932-59e7-bf88-7493bdae8493', 'd5b5186b-1dcf-5b1e-ae97-722ce3c3dbca', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d770b328-3f87-5683-a86e-e0acc7037859', 'd5b5186b-1dcf-5b1e-ae97-722ce3c3dbca', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d7aca3d-3e89-54e6-bdf3-efc75e2add55', 'd5b5186b-1dcf-5b1e-ae97-722ce3c3dbca', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92c65f28-97f1-5d66-ab3a-fd130613d893', 'd5b5186b-1dcf-5b1e-ae97-722ce3c3dbca', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05f61999-5974-5315-9a56-c087f2b67276', 'd5b5186b-1dcf-5b1e-ae97-722ce3c3dbca', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('657b7c3d-bb31-5585-8fbf-8e6ef22cb7c1', 'd5b5186b-1dcf-5b1e-ae97-722ce3c3dbca', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72e82ee8-69bd-516e-a019-a0aeab53c44a', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage has eight sections,
A-H
.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes
1-6
on your answer sheet
NB
You may use any letter
more than once
.
1
an acceptance that not all diseases can be totally eliminated
Locate
2
examples of physical conditions caused by human behaviour
Locate
3
a reference to classifying diseases on the basis of how far they extend geographically
Locate
4
reasons why the level of access to healthcare can vary within a country
Locate
5
a description of health geography as a mixture of different academic fields
Locate
6
a description of the type of area where a particular illness is rare
Locate

2 ____ examples of physical conditions caused by human behaviour Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('785b482e-21d1-5e6b-a4ec-7e270ee470f0', '72e82ee8-69bd-516e-a019-a0aeab53c44a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a30cbec8-b3c9-5056-a8a7-0b2af59723c3', '72e82ee8-69bd-516e-a019-a0aeab53c44a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('146ce7cd-278c-5b6b-b5f4-b5f2018ddb74', '72e82ee8-69bd-516e-a019-a0aeab53c44a', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54439ce4-c9aa-5ca1-9ab0-c9c4a3f54b6b', '72e82ee8-69bd-516e-a019-a0aeab53c44a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad4088f9-ae47-54e5-8ed0-2d1ea57fd027', '72e82ee8-69bd-516e-a019-a0aeab53c44a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66a4b148-bb33-515d-b1e7-7a2dcb85d37a', '72e82ee8-69bd-516e-a019-a0aeab53c44a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15bb3018-57af-525a-8cc2-7775ffea56de', '72e82ee8-69bd-516e-a019-a0aeab53c44a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c59dcf59-d6c1-546e-a7c2-a006aa155418', '72e82ee8-69bd-516e-a019-a0aeab53c44a', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b15b5c10-fc9e-5962-918d-bd0975cf7557', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage has eight sections,
A-H
.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes
1-6
on your answer sheet
NB
You may use any letter
more than once
.
1
an acceptance that not all diseases can be totally eliminated
Locate
2
examples of physical conditions caused by human behaviour
Locate
3
a reference to classifying diseases on the basis of how far they extend geographically
Locate
4
reasons why the level of access to healthcare can vary within a country
Locate
5
a description of health geography as a mixture of different academic fields
Locate
6
a description of the type of area where a particular illness is rare
Locate

3 ____ a reference to classifying diseases on the basis of how far they extend geographically Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47f79ee2-6f96-57a7-9776-8fb3d1a5ee4b', 'b15b5c10-fc9e-5962-918d-bd0975cf7557', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('526f999c-2178-5978-98dd-e61bc24885e5', 'b15b5c10-fc9e-5962-918d-bd0975cf7557', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58011a84-eeb3-50cf-a4d1-b7a5206d56a7', 'b15b5c10-fc9e-5962-918d-bd0975cf7557', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23476860-7db1-5f1c-aa8e-3c537f46cac5', 'b15b5c10-fc9e-5962-918d-bd0975cf7557', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dae512f8-1a2d-572e-8ac3-1a8b1b3e1053', 'b15b5c10-fc9e-5962-918d-bd0975cf7557', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bef15bdc-2a1b-5b2d-ac85-d0c4397caf18', 'b15b5c10-fc9e-5962-918d-bd0975cf7557', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2810759f-35f2-5c23-96eb-b401e23e0b52', 'b15b5c10-fc9e-5962-918d-bd0975cf7557', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('056402cb-a6a8-524f-8dad-2d65d101c083', 'b15b5c10-fc9e-5962-918d-bd0975cf7557', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('18893614-9353-5e59-b879-46d3c0804fe4', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage has eight sections,
A-H
.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes
1-6
on your answer sheet
NB
You may use any letter
more than once
.
1
an acceptance that not all diseases can be totally eliminated
Locate
2
examples of physical conditions caused by human behaviour
Locate
3
a reference to classifying diseases on the basis of how far they extend geographically
Locate
4
reasons why the level of access to healthcare can vary within a country
Locate
5
a description of health geography as a mixture of different academic fields
Locate
6
a description of the type of area where a particular illness is rare
Locate

4 ____ reasons why the level of access to healthcare can vary within a country Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82bcde14-4264-5385-acf9-16a20b5703f9', '18893614-9353-5e59-b879-46d3c0804fe4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19c9c15b-ace1-5235-a257-10ac06854cfc', '18893614-9353-5e59-b879-46d3c0804fe4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5584f8e9-7713-557c-a792-f0c9ae3a705b', '18893614-9353-5e59-b879-46d3c0804fe4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('993c9427-00f6-5cae-bf17-b7932012db4d', '18893614-9353-5e59-b879-46d3c0804fe4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19cca70f-4080-5f82-9d04-ca725f18be8f', '18893614-9353-5e59-b879-46d3c0804fe4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd1cb2de-0491-5981-be00-0b9bd52b8e14', '18893614-9353-5e59-b879-46d3c0804fe4', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd392bc7-03aa-538c-a540-d7eaaf1c0158', '18893614-9353-5e59-b879-46d3c0804fe4', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11016e78-3450-507d-a62d-b4eb9a2d7c62', '18893614-9353-5e59-b879-46d3c0804fe4', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f1abdee5-0656-5bae-88f6-a967826a8f4d', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage has eight sections,
A-H
.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes
1-6
on your answer sheet
NB
You may use any letter
more than once
.
1
an acceptance that not all diseases can be totally eliminated
Locate
2
examples of physical conditions caused by human behaviour
Locate
3
a reference to classifying diseases on the basis of how far they extend geographically
Locate
4
reasons why the level of access to healthcare can vary within a country
Locate
5
a description of health geography as a mixture of different academic fields
Locate
6
a description of the type of area where a particular illness is rare
Locate

5 ____ a description of health geography as a mixture of different academic fields Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6b045d5-222d-5577-8689-626826c73403', 'f1abdee5-0656-5bae-88f6-a967826a8f4d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a6eaa85-072c-5baa-980f-6991a1fafc5e', 'f1abdee5-0656-5bae-88f6-a967826a8f4d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ce73634-6278-5955-829f-83c0efcfeb16', 'f1abdee5-0656-5bae-88f6-a967826a8f4d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19b3b799-3c4e-50ba-b4a7-9c74f54198c2', 'f1abdee5-0656-5bae-88f6-a967826a8f4d', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23614017-cba1-50b0-9a07-a458232e4531', 'f1abdee5-0656-5bae-88f6-a967826a8f4d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8576350-1cbc-5b6d-83f6-ae782edf2e65', 'f1abdee5-0656-5bae-88f6-a967826a8f4d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e031d6d4-7229-5835-b9ed-8315f44c1749', 'f1abdee5-0656-5bae-88f6-a967826a8f4d', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e60ad070-02cb-59d5-8f0c-b27dc3e98431', 'f1abdee5-0656-5bae-88f6-a967826a8f4d', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2993abe4-65de-58b0-be72-e9517ee0b89e', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage has eight sections,
A-H
.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes
1-6
on your answer sheet
NB
You may use any letter
more than once
.
1
an acceptance that not all diseases can be totally eliminated
Locate
2
examples of physical conditions caused by human behaviour
Locate
3
a reference to classifying diseases on the basis of how far they extend geographically
Locate
4
reasons why the level of access to healthcare can vary within a country
Locate
5
a description of health geography as a mixture of different academic fields
Locate
6
a description of the type of area where a particular illness is rare
Locate

6 ____ a description of the type of area where a particular illness is rare Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e579d67b-2dd1-5040-9390-6b00178fc8ee', '2993abe4-65de-58b0-be72-e9517ee0b89e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('979a9484-883d-5305-9db6-8c06e9db5571', '2993abe4-65de-58b0-be72-e9517ee0b89e', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a37be99e-9b62-534f-af3b-b7b05cf575ac', '2993abe4-65de-58b0-be72-e9517ee0b89e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('174e3cc6-0545-59af-bbbc-250d8988c1ec', '2993abe4-65de-58b0-be72-e9517ee0b89e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15e38e6c-fc19-59af-bfd1-9feefcc54a5e', '2993abe4-65de-58b0-be72-e9517ee0b89e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a131a3d5-729c-5881-b0df-c7f6d0e9f71b', '2993abe4-65de-58b0-be72-e9517ee0b89e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1228c74b-e0a0-5d99-8155-686d56d8bd73', '2993abe4-65de-58b0-be72-e9517ee0b89e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcbc2874-9b3e-5536-8c7d-9b0e59e80f60', '2993abe4-65de-58b0-be72-e9517ee0b89e', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9a18ab02-8a9a-5947-8307-a815073959f8', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 7, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
7
Certain diseases have disappeared, thanks to better
and healthcare.
Locate
8
Because there is more contact between people,
are losing their usefulness.
Locate
9
Disease-causing
are most likely to be found in hot, damp regions.
Locate
10
One cause of pollution is
that burn a particular fuel.
Locate
11
The growth of cities often has an impact on nearby
Locate
12
is one disease that is growing after having been eradicated.
Locate
13
A physical barrier such as a
can prevent people from reaching a hospital.
Locate

7 Certain diseases have disappeared, thanks to better ____ and healthcare. Locate$md$, NULL, ARRAY['.*vaccinations.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('63311f45-1dd0-5fb6-a76c-4ff78d641d4f', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 8, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
7
Certain diseases have disappeared, thanks to better
and healthcare.
Locate
8
Because there is more contact between people,
are losing their usefulness.
Locate
9
Disease-causing
are most likely to be found in hot, damp regions.
Locate
10
One cause of pollution is
that burn a particular fuel.
Locate
11
The growth of cities often has an impact on nearby
Locate
12
is one disease that is growing after having been eradicated.
Locate
13
A physical barrier such as a
can prevent people from reaching a hospital.
Locate

8 Because there is more contact between people, ____ are losing their usefulness. Locate$md$, NULL, ARRAY['.*antibiotics.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8d3fe0be-5a34-5423-a12a-64620db93513', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 9, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
7
Certain diseases have disappeared, thanks to better
and healthcare.
Locate
8
Because there is more contact between people,
are losing their usefulness.
Locate
9
Disease-causing
are most likely to be found in hot, damp regions.
Locate
10
One cause of pollution is
that burn a particular fuel.
Locate
11
The growth of cities often has an impact on nearby
Locate
12
is one disease that is growing after having been eradicated.
Locate
13
A physical barrier such as a
can prevent people from reaching a hospital.
Locate

9 Disease-causing ____ are most likely to be found in hot, damp regions. Locate$md$, NULL, ARRAY['.*mosquitos.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f01bc635-9167-5bad-bba6-3d4e9f069b6f', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 10, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
7
Certain diseases have disappeared, thanks to better
and healthcare.
Locate
8
Because there is more contact between people,
are losing their usefulness.
Locate
9
Disease-causing
are most likely to be found in hot, damp regions.
Locate
10
One cause of pollution is
that burn a particular fuel.
Locate
11
The growth of cities often has an impact on nearby
Locate
12
is one disease that is growing after having been eradicated.
Locate
13
A physical barrier such as a
can prevent people from reaching a hospital.
Locate

10 One cause of pollution is ____ that burn a particular fuel. Locate$md$, NULL, ARRAY['.*factories.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('839f653b-054c-5e91-9940-7a45467fc4e9', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
7
Certain diseases have disappeared, thanks to better
and healthcare.
Locate
8
Because there is more contact between people,
are losing their usefulness.
Locate
9
Disease-causing
are most likely to be found in hot, damp regions.
Locate
10
One cause of pollution is
that burn a particular fuel.
Locate
11
The growth of cities often has an impact on nearby
Locate
12
is one disease that is growing after having been eradicated.
Locate
13
A physical barrier such as a
can prevent people from reaching a hospital.
Locate

11 The growth of cities often has an impact on nearby ____ Locate$md$, NULL, ARRAY['.*forests.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5bcf1856-e95e-52c7-a2c9-7299fb9ddd1e', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
7
Certain diseases have disappeared, thanks to better
and healthcare.
Locate
8
Because there is more contact between people,
are losing their usefulness.
Locate
9
Disease-causing
are most likely to be found in hot, damp regions.
Locate
10
One cause of pollution is
that burn a particular fuel.
Locate
11
The growth of cities often has an impact on nearby
Locate
12
is one disease that is growing after having been eradicated.
Locate
13
A physical barrier such as a
can prevent people from reaching a hospital.
Locate

12 ____ is one disease that is growing after having been eradicated. Locate$md$, NULL, ARRAY['.*polio.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8fb552cb-3f5a-50d6-b51d-465a4751efd4', '13e305b6-0817-5b1d-8c2c-74ab04bc69ee', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
7
Certain diseases have disappeared, thanks to better
and healthcare.
Locate
8
Because there is more contact between people,
are losing their usefulness.
Locate
9
Disease-causing
are most likely to be found in hot, damp regions.
Locate
10
One cause of pollution is
that burn a particular fuel.
Locate
11
The growth of cities often has an impact on nearby
Locate
12
is one disease that is growing after having been eradicated.
Locate
13
A physical barrier such as a
can prevent people from reaching a hospital.
Locate

13 A physical barrier such as a ____ can prevent people from reaching a hospital. Locate$md$, NULL, ARRAY['.*mountain.*']);

COMMIT;
