BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-motor-car-131'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-motor-car-131';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-motor-car-131';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-motor-car-131';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('94751c9d-f63b-54ce-a2c7-5f646e33bed4', 'ielts-reading-the-motor-car-131', $t$The Motor Car$t$, $md$## The Motor Car

Nguồn:
- Test: https://mini-ielts.com/131/reading/the-motor-car
- Solution: https://mini-ielts.com/131/view-solution/reading/the-motor-car$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', '94751c9d-f63b-54ce-a2c7-5f646e33bed4', 1, $t$Reading — The Motor Car$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Motor Car

A

There are now over 700 million motor vehicles in the world - and the number is rising by more than 40 million each year. The average distance driven by car users is growing too - from 8 km a day per person in western Europe in 1965 to 25 km a day in 1995. This dependence on motor vehicles has given rise to major problems, including environmental pollution, depletion of oil resources, traffic congestion and safety.

B

While emissions from new cars are far less harmful than they used to be, city streets and motorways are becoming more crowded than ever, often with older trucks, buses and taxis, which emit excessive levels of smoke and fumes. This concentration of vehicles makes air quality in urban areas unpleasant and sometimes dangerous to breathe. Even Moscow has joined the list of capitals afflicted by congestion and traffic fumes. In Mexico City, vehicle pollution is a major health hazard.

C

Until a hundred years ago, most journeys were in the 20 km range, the distance conveniently accessible by horse. Heavy freight could only be carried by water or rail. The invention of the motor vehicle brought personal mobility to the masses and made rapid freight delivery possible over a much wider area. Today about 90 per cent of inland freight in the United Kingdom is carried by road. Clearly the world cannot revert to the horse-drawn wagon . Can it avoid being locked into congested and polluting ways of transporting people and goods?

D

In Europe most cities are still designed for the old modes of transport . Adaptation to the motor car has involved adding ring roads, one-way systems and parking lots . In the United States, more land is assigned to car use than to housing. Urban sprawl means that life without a car is next to impossible. Mass use of motor vehicles has also killed or injured millions of people. Other social effects have been blamed on the car such as alienation and aggressive human behaviour.

E

A 1993 study by the European Federation for Transport and Environment found that car transport is seven times as costly as rail travel in terms of the external social costs it entails such as congestion, accidents, pollution, loss of cropland and natural habitats, depletion of oil resources, and so on. Yet cars easily surpass trains or buses as a flexible and convenient mode of personal transport . It is unrealistic to expect people to give up private cars in favour of mass transit.

F

Technical solutions can reduce the pollution problem and increase the fuel efficiency of engines. But fuel consumption and exhaust emissions depend on which cars are preferred by customers and how they are driven. Many people buy larger cars than they need for daily purposes or waste fuel by driving aggressively . Besides, global car use is increasing at a faster rate than the improvement in emissions and fuel efficiency which technology is now making possible.

G

One solution that has been put forward is the long-term solution of designing cities and neighbourhoods so that car journeys are not necessary - all essential services being located within walking distance or easily accessible by public transport. Not only would this save energy and cut carbon dioxide emissions, it would also enhance the quality of community life, putting the emphasis on people instead of cars. Good local government is already bringing this about in some places. But few democratic communities are blessed with the vision - and the capital - to make such profound changes in modern lifestyles.

H

A more likely scenario seems to be a combination of mass transit systems for travel into and around cities, with small 'low emission' cars for urban use and larger hybrid or lean burn cars for use elsewhere. Electronically tolled highways might be used to ensure that drivers pay charges geared to actual road use. Better integration of transport systems is also highly desirable - and made more feasible by modern computers . But these are solutions for countries which can afford them. In most developing countries, old cars and old technologies continue to predominate.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a8d59d21-780d-56c9-a9b9-02027217fe37', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage 2 has eight paragraphs
(A-H)
. Which paragraphs concentrate on the following information?
Write the appropriate letters
(A-H)
in boxes
1-6
on your answer sheet.
NB
You need only write
ONE
letter for each answer.
1
a comparison of past and present transportation methods
2
how driving habits contribute to road problems
3
the relative merits of cars and public transport
4
the writer's own prediction of future solutions
5
the increasing use of motor vehicles
6
the impact of the car on city development

1 ____ a comparison of past and present transportation methods$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9622f751-e839-530b-acfa-ac3f6e576f04', 'a8d59d21-780d-56c9-a9b9-02027217fe37', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('765545bf-6476-5d8d-911c-1288312f68b9', 'a8d59d21-780d-56c9-a9b9-02027217fe37', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('897fff71-423d-539b-83e0-40456061aad6', 'a8d59d21-780d-56c9-a9b9-02027217fe37', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1aa06fc7-4229-5ad2-90a4-551a8b97a1bb', 'a8d59d21-780d-56c9-a9b9-02027217fe37', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49520ece-75ab-5ec9-bde7-030903a9991a', 'a8d59d21-780d-56c9-a9b9-02027217fe37', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9c9de7e-b5bd-50a2-83c8-ee3a6613eb01', 'a8d59d21-780d-56c9-a9b9-02027217fe37', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('996bfe2b-bdf4-5c18-a445-1960af4d5710', 'a8d59d21-780d-56c9-a9b9-02027217fe37', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c681c46f-592f-52db-90d9-726ee1508ea8', 'a8d59d21-780d-56c9-a9b9-02027217fe37', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0a999b2a-cc14-5e22-b680-d01616fdb4a3', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage 2 has eight paragraphs
(A-H)
. Which paragraphs concentrate on the following information?
Write the appropriate letters
(A-H)
in boxes
1-6
on your answer sheet.
NB
You need only write
ONE
letter for each answer.
1
a comparison of past and present transportation methods
2
how driving habits contribute to road problems
3
the relative merits of cars and public transport
4
the writer's own prediction of future solutions
5
the increasing use of motor vehicles
6
the impact of the car on city development

2 ____ how driving habits contribute to road problems$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb195072-9bf5-5285-be14-4af5e6db0b5b', '0a999b2a-cc14-5e22-b680-d01616fdb4a3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08537792-a567-51db-8c03-142acf1f6a1d', '0a999b2a-cc14-5e22-b680-d01616fdb4a3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c36bb09f-f08b-5a49-87b3-0628e667137d', '0a999b2a-cc14-5e22-b680-d01616fdb4a3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7764bbf1-1db4-54e4-b546-7791714bbb05', '0a999b2a-cc14-5e22-b680-d01616fdb4a3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c21dfb8f-7e7b-5b0e-9db9-b9f2789c57d9', '0a999b2a-cc14-5e22-b680-d01616fdb4a3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16254bdc-3bb2-576e-ac8b-eba42cb1831a', '0a999b2a-cc14-5e22-b680-d01616fdb4a3', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('906ff64a-d7bd-5479-bfc4-5216a6a070e5', '0a999b2a-cc14-5e22-b680-d01616fdb4a3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d68e455-d21f-51a3-8cb4-dd2a62b623eb', '0a999b2a-cc14-5e22-b680-d01616fdb4a3', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cbaab4fc-77b3-5c19-83c6-d9e660e2c5e6', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage 2 has eight paragraphs
(A-H)
. Which paragraphs concentrate on the following information?
Write the appropriate letters
(A-H)
in boxes
1-6
on your answer sheet.
NB
You need only write
ONE
letter for each answer.
1
a comparison of past and present transportation methods
2
how driving habits contribute to road problems
3
the relative merits of cars and public transport
4
the writer's own prediction of future solutions
5
the increasing use of motor vehicles
6
the impact of the car on city development

3 ____ the relative merits of cars and public transport$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b712020a-c35d-592e-9ad0-6253c2170783', 'cbaab4fc-77b3-5c19-83c6-d9e660e2c5e6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfd3842e-7261-56f9-95f5-6a03f8a2fff7', 'cbaab4fc-77b3-5c19-83c6-d9e660e2c5e6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb279d14-6c07-5b13-9628-27866e9e0b87', 'cbaab4fc-77b3-5c19-83c6-d9e660e2c5e6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('332c3545-f084-5847-9a07-e1c30fe4d547', 'cbaab4fc-77b3-5c19-83c6-d9e660e2c5e6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('419945be-b80d-5320-b006-07e2ed61f485', 'cbaab4fc-77b3-5c19-83c6-d9e660e2c5e6', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08dc7f8e-8796-50a7-bb84-fc35fd2c3785', 'cbaab4fc-77b3-5c19-83c6-d9e660e2c5e6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c80cbb6a-1b2e-5f7b-9289-74eed525441d', 'cbaab4fc-77b3-5c19-83c6-d9e660e2c5e6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c66c9e04-f793-581d-bd9f-b1d89a26d47c', 'cbaab4fc-77b3-5c19-83c6-d9e660e2c5e6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e03650a0-2a47-50ef-b3dc-8a30e56e845f', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage 2 has eight paragraphs
(A-H)
. Which paragraphs concentrate on the following information?
Write the appropriate letters
(A-H)
in boxes
1-6
on your answer sheet.
NB
You need only write
ONE
letter for each answer.
1
a comparison of past and present transportation methods
2
how driving habits contribute to road problems
3
the relative merits of cars and public transport
4
the writer's own prediction of future solutions
5
the increasing use of motor vehicles
6
the impact of the car on city development

4 ____ the writer's own prediction of future solutions$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab34baee-fdc0-5052-8cfa-c302160db93e', 'e03650a0-2a47-50ef-b3dc-8a30e56e845f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3bb784d-d907-5bf1-a0b1-9744efa77d9c', 'e03650a0-2a47-50ef-b3dc-8a30e56e845f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('573b88ed-2377-5303-8f95-1d215f1ed87f', 'e03650a0-2a47-50ef-b3dc-8a30e56e845f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c8382a8-3777-5231-b555-0b25358a9d15', 'e03650a0-2a47-50ef-b3dc-8a30e56e845f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6fd96f50-3bb7-5d4f-b9e5-e4ac456c4e72', 'e03650a0-2a47-50ef-b3dc-8a30e56e845f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe5e2573-03b8-5b7e-bbcc-fe7d463ef730', 'e03650a0-2a47-50ef-b3dc-8a30e56e845f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7220490-6c79-5e25-ac6c-ce315526be44', 'e03650a0-2a47-50ef-b3dc-8a30e56e845f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c88d9fb-505b-52c5-b9b9-2fcb869c63be', 'e03650a0-2a47-50ef-b3dc-8a30e56e845f', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8fcd08f4-d201-5592-bd74-8e971d31c1c3', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage 2 has eight paragraphs
(A-H)
. Which paragraphs concentrate on the following information?
Write the appropriate letters
(A-H)
in boxes
1-6
on your answer sheet.
NB
You need only write
ONE
letter for each answer.
1
a comparison of past and present transportation methods
2
how driving habits contribute to road problems
3
the relative merits of cars and public transport
4
the writer's own prediction of future solutions
5
the increasing use of motor vehicles
6
the impact of the car on city development

5 ____ the increasing use of motor vehicles$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e63078c-8d8e-546e-aa6b-491f8bc086e2', '8fcd08f4-d201-5592-bd74-8e971d31c1c3', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('193d07e7-a29e-5e0c-9ea4-1f828d825b64', '8fcd08f4-d201-5592-bd74-8e971d31c1c3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ad29468-d5a2-5a86-a1b1-41cd3876fadb', '8fcd08f4-d201-5592-bd74-8e971d31c1c3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d619fcaa-bd75-574a-a7c0-08cd7f295bbe', '8fcd08f4-d201-5592-bd74-8e971d31c1c3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86052b99-85fc-5869-a824-62a9e77bf98a', '8fcd08f4-d201-5592-bd74-8e971d31c1c3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a167de3-14a9-5514-bdb7-53c72a028d63', '8fcd08f4-d201-5592-bd74-8e971d31c1c3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f83325f7-f6de-5e32-b3a2-6f4c4e918d54', '8fcd08f4-d201-5592-bd74-8e971d31c1c3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cca51814-8f45-5047-a50d-c7c32d73a1c7', '8fcd08f4-d201-5592-bd74-8e971d31c1c3', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7a59fada-988a-5197-954c-41da18380d3d', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage 2 has eight paragraphs
(A-H)
. Which paragraphs concentrate on the following information?
Write the appropriate letters
(A-H)
in boxes
1-6
on your answer sheet.
NB
You need only write
ONE
letter for each answer.
1
a comparison of past and present transportation methods
2
how driving habits contribute to road problems
3
the relative merits of cars and public transport
4
the writer's own prediction of future solutions
5
the increasing use of motor vehicles
6
the impact of the car on city development

6 ____ the impact of the car on city development$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c3064cd-b4e4-5971-b4bf-84e21afb8cdd', '7a59fada-988a-5197-954c-41da18380d3d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d5ace85-637d-5543-91e5-587da1dd18ec', '7a59fada-988a-5197-954c-41da18380d3d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bf257bd-df73-50a7-a583-21d12d3e6b2c', '7a59fada-988a-5197-954c-41da18380d3d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e346686-ea44-5b26-9aff-48676c98ac29', '7a59fada-988a-5197-954c-41da18380d3d', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a488390-7621-5c94-b9b0-2afc760af2e8', '7a59fada-988a-5197-954c-41da18380d3d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3514b549-f3fa-525f-94d7-257300890b44', '7a59fada-988a-5197-954c-41da18380d3d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f968248d-8e92-5229-811b-4b2f862b83d0', '7a59fada-988a-5197-954c-41da18380d3d', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91057084-cb87-5505-850f-26039cb16d41', '7a59fada-988a-5197-954c-41da18380d3d', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ec47aefd-ba6a-5bd0-9ed5-b56ddfdcb93b', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 2?
In boxes
7-13
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this in the passage
7
Vehicle pollution is worse in European cities than anywhere else.
8
Transport by horse would be a useful alternative to motor vehicles.
9
Nowadays freight is not carried by water in the United Kingdom.
10
Most European cities were not designed for motor vehicles.
11
Technology alone cannot solve the problem of vehicle pollution.
12
People's choice of car and attitude to driving is a factor in the pollution problem.
13
Redesigning cities would be a short-term solution.

7 ____ Vehicle pollution is worse in European cities than anywhere else.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8df4ef67-67b2-53ba-9eee-1bdb0811d75e', 'ec47aefd-ba6a-5bd0-9ed5-b56ddfdcb93b', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6cff14e-471e-5ffd-9246-c4e78cd022d3', 'ec47aefd-ba6a-5bd0-9ed5-b56ddfdcb93b', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('039c2515-36b5-518b-a175-3031c47c9e72', 'ec47aefd-ba6a-5bd0-9ed5-b56ddfdcb93b', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72a36639-8055-5c74-8231-22aff645b5e5', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 2?
In boxes
7-13
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this in the passage
7
Vehicle pollution is worse in European cities than anywhere else.
8
Transport by horse would be a useful alternative to motor vehicles.
9
Nowadays freight is not carried by water in the United Kingdom.
10
Most European cities were not designed for motor vehicles.
11
Technology alone cannot solve the problem of vehicle pollution.
12
People's choice of car and attitude to driving is a factor in the pollution problem.
13
Redesigning cities would be a short-term solution.

8 ____ Transport by horse would be a useful alternative to motor vehicles.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d7caf9d-9482-5943-b87e-5ebfbef11ad7', '72a36639-8055-5c74-8231-22aff645b5e5', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a23860bd-e292-555e-9d6b-63c1f53e8af9', '72a36639-8055-5c74-8231-22aff645b5e5', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('474839df-f2e6-55c3-b6c0-df88fff59c1b', '72a36639-8055-5c74-8231-22aff645b5e5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('524b9f74-81ac-5c6d-8393-32b30a687392', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 2?
In boxes
7-13
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this in the passage
7
Vehicle pollution is worse in European cities than anywhere else.
8
Transport by horse would be a useful alternative to motor vehicles.
9
Nowadays freight is not carried by water in the United Kingdom.
10
Most European cities were not designed for motor vehicles.
11
Technology alone cannot solve the problem of vehicle pollution.
12
People's choice of car and attitude to driving is a factor in the pollution problem.
13
Redesigning cities would be a short-term solution.

9 ____ Nowadays freight is not carried by water in the United Kingdom.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce08fcd6-2f88-54f0-b4ed-12a67200943e', '524b9f74-81ac-5c6d-8393-32b30a687392', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80c5cf15-c207-5f4b-b22d-aa38f8608165', '524b9f74-81ac-5c6d-8393-32b30a687392', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d17f802-d737-5274-b1ba-e7ab023897bc', '524b9f74-81ac-5c6d-8393-32b30a687392', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b6ef5f7e-37d4-5dce-937c-88ab10cc5e59', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 2?
In boxes
7-13
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this in the passage
7
Vehicle pollution is worse in European cities than anywhere else.
8
Transport by horse would be a useful alternative to motor vehicles.
9
Nowadays freight is not carried by water in the United Kingdom.
10
Most European cities were not designed for motor vehicles.
11
Technology alone cannot solve the problem of vehicle pollution.
12
People's choice of car and attitude to driving is a factor in the pollution problem.
13
Redesigning cities would be a short-term solution.

10 ____ Most European cities were not designed for motor vehicles.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b3651de-404b-57be-84cb-c7ffae207a69', 'b6ef5f7e-37d4-5dce-937c-88ab10cc5e59', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e5e12f5-09c4-53fd-a058-304210f25117', 'b6ef5f7e-37d4-5dce-937c-88ab10cc5e59', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2d56976-0d40-5a42-aaac-8f88de9ea9f9', 'b6ef5f7e-37d4-5dce-937c-88ab10cc5e59', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('24289d56-5303-5f86-a528-e43c90eca2c6', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 2?
In boxes
7-13
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this in the passage
7
Vehicle pollution is worse in European cities than anywhere else.
8
Transport by horse would be a useful alternative to motor vehicles.
9
Nowadays freight is not carried by water in the United Kingdom.
10
Most European cities were not designed for motor vehicles.
11
Technology alone cannot solve the problem of vehicle pollution.
12
People's choice of car and attitude to driving is a factor in the pollution problem.
13
Redesigning cities would be a short-term solution.

11 ____ Technology alone cannot solve the problem of vehicle pollution.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b07d982-48e6-5456-9c5e-1a74abcfdcdb', '24289d56-5303-5f86-a528-e43c90eca2c6', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44cb6483-54c3-509d-a795-2227c51db3dd', '24289d56-5303-5f86-a528-e43c90eca2c6', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19793e4d-2e77-5766-80cc-aff7c63983cc', '24289d56-5303-5f86-a528-e43c90eca2c6', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('497bf688-b92b-5c1f-a6d5-d95e59d81c4d', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 2?
In boxes
7-13
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this in the passage
7
Vehicle pollution is worse in European cities than anywhere else.
8
Transport by horse would be a useful alternative to motor vehicles.
9
Nowadays freight is not carried by water in the United Kingdom.
10
Most European cities were not designed for motor vehicles.
11
Technology alone cannot solve the problem of vehicle pollution.
12
People's choice of car and attitude to driving is a factor in the pollution problem.
13
Redesigning cities would be a short-term solution.

12 ____ People's choice of car and attitude to driving is a factor in the pollution problem.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b227cee4-fc5c-5f15-ae24-fb66714915f5', '497bf688-b92b-5c1f-a6d5-d95e59d81c4d', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d6d3d1e-1b08-5bfb-9990-a49fe0db9372', '497bf688-b92b-5c1f-a6d5-d95e59d81c4d', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38361f78-0222-5b79-960e-65486bd99fb8', '497bf688-b92b-5c1f-a6d5-d95e59d81c4d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('69d32cac-d48e-5d48-bc50-99776c35c531', 'fbe02d37-7049-5dfb-ac4b-e4a30b4ffde3', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 2?
In boxes
7-13
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this in the passage
7
Vehicle pollution is worse in European cities than anywhere else.
8
Transport by horse would be a useful alternative to motor vehicles.
9
Nowadays freight is not carried by water in the United Kingdom.
10
Most European cities were not designed for motor vehicles.
11
Technology alone cannot solve the problem of vehicle pollution.
12
People's choice of car and attitude to driving is a factor in the pollution problem.
13
Redesigning cities would be a short-term solution.

13 ____ Redesigning cities would be a short-term solution.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('debc8548-48bb-5514-befd-6e2fa74eca7a', '69d32cac-d48e-5d48-bc50-99776c35c531', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f2669cd-60a5-5530-83be-999f119cd359', '69d32cac-d48e-5d48-bc50-99776c35c531', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f750776d-508a-5f25-abc9-a85398b11881', '69d32cac-d48e-5d48-bc50-99776c35c531', 3, $md$NOT GIVEN$md$, false);

COMMIT;
