BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-mpemba-effect--1416'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-mpemba-effect--1416';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-mpemba-effect--1416';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-mpemba-effect--1416';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('0577d499-b5f6-5894-8452-82df9c6703b5', 'ielts-reading-the-mpemba-effect--1416', $t$THE MPEMBA EFFECT$t$, $md$## THE MPEMBA EFFECT

Nguồn:
- Test: https://mini-ielts.com/1416/reading/the-mpemba-effect-
- Solution: https://mini-ielts.com/1416/view-solution/reading/the-mpemba-effect-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', '0577d499-b5f6-5894-8452-82df9c6703b5', 1, $t$Reading — THE MPEMBA EFFECT$t$, $md$Read the passage and answer questions **1–14**.

### Passage: THE MPEMBA EFFECT

In 300 BC, the famous philosopher Aristotle wrote about a strange phenomenon that he had observed: “Many people, when they want to cool water quickly, begin by putting it in the sun.” Other philosophers over the ages noted the same result, but were unable to explain it.

In 1963, a young Tanzanian student named Erasto Mpemba noticed that the ice cream he was making froze faster if the mix was placed in the freezer while warm than if it were at room temperature. He persisted in questioning why this occurred, and eventually physicist Denis Osborne began a serious investigation into what is now known as the Mpemba Effect. He and Mpemba co-authored a paper in New Scientist in 1969, which produced scientific descriptions of some of the many factors at work in freezing water.

It was initially hypothesised that the warm bowl melted itself a place in the ice on the freezer shelf, thus embedding its base in a ‘nest’ of ice, which would accelerate freezing. The hypothesis was tested by comparing the result when bowls of warm water were placed on ice and on a dry wire shelf; this demonstrated that the ice nest actually had little effect. A second suggestion was that the warmer water would be evaporating at its surface, thus reducing the volume needing to be frozen, but this idea was also shown to be insignificant.

Thermometers placed in the water showed that the cooler water dropped to freezing temperature well before the warmer bowlful, and yet the latter always froze solid first. Experiments at different temperatures showed that water at 50C took longest to freeze in a conventional freezer, while water initially at 350C was quickest. On further examination, an explanation for this paradox began to emerge. Losing heat from the water occurs at the points where it is in touch with the colder atmosphere of the freezer, namely the sides of the bowl and the water surface.

A warm surface will lose heat faster than a cold one because of the contrast between the temperatures; but of course there is more heat to be lost from one bowl than the other! If the surface can be kept at a higher temperature, the higher rate of heat loss will continue. As long as the water remains liquid, the cooling portion on top will sink to the bottom of the bowl as the warmer water below rises to take its place. The early freezing that may occur on the sides and base of the container will amplify the effect.

The bowl that is more uniformly cold will have far less temperature difference so the water flow will be minimal. Another inhibiting factor for this container is that ice will also form quite quickly on the surface. This not only acts as insulation, but will virtually stop the helpful effects of the water circulating inside the bowl.

Ultimately, the rate of cooling the core of this body of water becomes so slow that the other warmer one is always fully frozen first. While there are limitations to this comparison (for example, we would not see such a result if one quantity were at 10C and another at 990C) this counter-intuitive result does hold true within the 5–350C range of temperatures indicated previously.

Since this paper was published, the validity of the research findings has been questioned by a number of reviewers. They point out that the initial experimental question was not clearly defined; for example, the researchers needed to decide on exactly what constituted freezing the water. They also state that the rate at which water freezes depends on a large number of variables.

Container size is one of these; for the Mpemba Effect to be noticed, the container must be large enough to allow a free circulation of water to take place, yet small enough for the freezing areas of the side and base to be effective at extracting heat too. Secondly, research at a University in St Louis, Missouri, suggests that the Mpemba Effect may be affected by water purity, or by dissolved gas in the water.

Distilled water is totally free of the particles that are common in normal drinking water or mineral water. When suspended in water, these particles may have a small effect on the speed of cooling, especially as ice molecules tend to expel them into the surrounding water, where they become more concentrated. Just as salt dissolved in water will raise the boiling point and lower the temperature at which it freezes, the researchers found that the final portion of ordinary water needed extra cooling, below zero, before all was frozen solid.

One more factor that can distort the effect is observed if the bowls are not placed simultaneously into the same freezer. In this case, the freezer thermostat is more likely to register the presence of a hotter bowl than a colder one, and therefore the change in internal temperature causes a boost of freezing power as the motor is activated.

The Mpemba Effect is still not fully understood, and researchers continue to delve into its underlying physics. Physicists cannot reach consensus. Some suggest that supercooling1 is involved; others that the molecular bonds in the water molecules affect the rate of cooling and freezing of water. A 2013 competition to explain the phenomenon run by the Royal Society of Chemistry attracted more than 22,000 entries, with the winning one suggesting supercooling as an important factor so it seems the question and its underlying explanation continue to fascinate.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7f7dfc1d-8499-5f42-abd6-a0b643192f5d', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Write the correct letter, A–O, in boxes 1-7 on your answer sheet.
For more than 2000 years people have wondered why raising the
1
of cold water before cooling it results in more rapid cooling. At first researchers thought that a warm container created its own icy
2
which made the water freeze faster, but comparisons with containers resting on a dry
3
indicated that this was inaccurate. Evaporation of water proved not to be a
4
.
Temperature measurements showed that, although the water in the cooler container reached 00C before the warmer one, it took longer to actually solidify. The water temperature drops the most at the top and sides of the container. Provided there is a temperature
5
, the water will continue to circulate and to cool down. Cooler water will have less water
6
, and thus a slower rate of freezing. If ice forms on the top of the water, this will further slow the
7
of freezing, but if it forms on the bottom and the sides of the container, this will increase the rate of cooling.
A. melt
B. element
C. process
D. centre
E. acceleration
F. surface
G. factor
H. hollow
I. matter
J. circulation
K. limit
L. significance
M. theory
N. difference
O. result
P. temperature

For more than 2000 years people have wondered why raising the 1 ____ of cold water before cooling it results in more rapid cooling. At first researchers thought that a warm container created its own icy 2 ____ which made the water freeze faster, but comparisons with containers resting on a dry 3 ____ indicated that this was inaccurate. Evaporation of water proved not to be a 4 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c2011e2-99b3-54c8-8997-7a3bd6d70f8f', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('696b3da9-f03b-5852-a603-b894d2cb6bd5', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3da20a92-5037-5171-92af-4265c527c875', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcf01064-d30c-579f-8063-d4ed23dbd991', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bac6e31-ad16-56c6-9cd6-86662f088eab', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4f78d9a-dde1-55bf-adda-955a557f9ea6', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53a5354e-d4ad-56fd-802d-93b157870c43', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66590b7e-2ad9-5bba-b2bd-234ea5ecef88', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c866d53-58bd-5166-9639-b800b1e8ce98', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af349b8c-856b-5581-a6c3-7bd0af28b1a6', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7a13e1e-d81b-5fad-9d7e-c0818602db17', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('878d7a61-ef4c-5a5d-a8fa-edfbdcd85749', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 12, $md$L$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfd4cee4-c43b-5df6-a0b8-d1b684c4bf83', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 13, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('693519f2-aaa0-5f6c-a75b-fddd846a004c', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 14, $md$N$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ea3fd83-e28f-5410-8693-044a6badae50', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 15, $md$O$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b518cb9-4a30-57a4-a12f-e4bfdf98492a', '7f7dfc1d-8499-5f42-abd6-a0b643192f5d', 16, $md$P$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('79540817-46b0-589e-b605-b63738acc9c2', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Write the correct letter, A–O, in boxes 1-7 on your answer sheet.
For more than 2000 years people have wondered why raising the
1
of cold water before cooling it results in more rapid cooling. At first researchers thought that a warm container created its own icy
2
which made the water freeze faster, but comparisons with containers resting on a dry
3
indicated that this was inaccurate. Evaporation of water proved not to be a
4
.
Temperature measurements showed that, although the water in the cooler container reached 00C before the warmer one, it took longer to actually solidify. The water temperature drops the most at the top and sides of the container. Provided there is a temperature
5
, the water will continue to circulate and to cool down. Cooler water will have less water
6
, and thus a slower rate of freezing. If ice forms on the top of the water, this will further slow the
7
of freezing, but if it forms on the bottom and the sides of the container, this will increase the rate of cooling.
A. melt
B. element
C. process
D. centre
E. acceleration
F. surface
G. factor
H. hollow
I. matter
J. circulation
K. limit
L. significance
M. theory
N. difference
O. result
P. temperature

For more than 2000 years people have wondered why raising the 1 ____ of cold water before cooling it results in more rapid cooling. At first researchers thought that a warm container created its own icy 2 ____ which made the water freeze faster, but comparisons with containers resting on a dry 3 ____ indicated that this was inaccurate. Evaporation of water proved not to be a 4 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03ce9bbb-cc2c-58d2-a582-662eda45c21c', '79540817-46b0-589e-b605-b63738acc9c2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c341d40-7743-51aa-b9a1-c2671f2d762a', '79540817-46b0-589e-b605-b63738acc9c2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a94bd45-de64-563b-9a19-3c96351717a6', '79540817-46b0-589e-b605-b63738acc9c2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3d848f2-e02e-529e-b726-b9250fe1f30e', '79540817-46b0-589e-b605-b63738acc9c2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f6b065b-ef1c-5c68-9e40-167b3ffd606f', '79540817-46b0-589e-b605-b63738acc9c2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bebdc99-b9fa-5eb0-9365-828d68682c93', '79540817-46b0-589e-b605-b63738acc9c2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('131c201e-9c29-5400-bcb1-32193cd31cd6', '79540817-46b0-589e-b605-b63738acc9c2', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef9ae968-6b2b-5ff1-a0de-edd14649fc8b', '79540817-46b0-589e-b605-b63738acc9c2', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4987e057-fe65-5841-8833-c3a3230f4bcb', '79540817-46b0-589e-b605-b63738acc9c2', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbf1f703-5314-58f9-bf19-be0c92258544', '79540817-46b0-589e-b605-b63738acc9c2', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5bc6925-9783-5302-9dae-f54ad517acc7', '79540817-46b0-589e-b605-b63738acc9c2', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6c4a320-75da-513c-8157-679f86590eb2', '79540817-46b0-589e-b605-b63738acc9c2', 12, $md$L$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac243eb7-d3a2-5522-867b-259908ace744', '79540817-46b0-589e-b605-b63738acc9c2', 13, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5cfb5d8-c1cf-53fa-84f6-1f0adf079b0b', '79540817-46b0-589e-b605-b63738acc9c2', 14, $md$N$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ed7925b-754b-5f53-a255-8395d17148ed', '79540817-46b0-589e-b605-b63738acc9c2', 15, $md$O$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0710f604-4b97-54bc-8ab0-ebf3c78269da', '79540817-46b0-589e-b605-b63738acc9c2', 16, $md$P$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a959cfbd-b78b-52db-8402-0400c2fb3775', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Write the correct letter, A–O, in boxes 1-7 on your answer sheet.
For more than 2000 years people have wondered why raising the
1
of cold water before cooling it results in more rapid cooling. At first researchers thought that a warm container created its own icy
2
which made the water freeze faster, but comparisons with containers resting on a dry
3
indicated that this was inaccurate. Evaporation of water proved not to be a
4
.
Temperature measurements showed that, although the water in the cooler container reached 00C before the warmer one, it took longer to actually solidify. The water temperature drops the most at the top and sides of the container. Provided there is a temperature
5
, the water will continue to circulate and to cool down. Cooler water will have less water
6
, and thus a slower rate of freezing. If ice forms on the top of the water, this will further slow the
7
of freezing, but if it forms on the bottom and the sides of the container, this will increase the rate of cooling.
A. melt
B. element
C. process
D. centre
E. acceleration
F. surface
G. factor
H. hollow
I. matter
J. circulation
K. limit
L. significance
M. theory
N. difference
O. result
P. temperature

For more than 2000 years people have wondered why raising the 1 ____ of cold water before cooling it results in more rapid cooling. At first researchers thought that a warm container created its own icy 2 ____ which made the water freeze faster, but comparisons with containers resting on a dry 3 ____ indicated that this was inaccurate. Evaporation of water proved not to be a 4 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d2b74b2-bf03-59d3-9780-76e8fefd3e3f', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52068696-fe72-586d-8bad-886323d90c7b', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9c2ebcb-40e7-5996-8cef-c47d7f7a31a8', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11782d5b-d2d8-5748-89e3-104c6cd67d97', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12b7fead-de35-5738-9bd6-b56565a1e53c', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d0320d7-fb18-5355-98e0-522e15579eda', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb21535a-edf8-5ce1-9465-e0c67da28b06', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82d2788f-8313-5f21-b4db-bf568a478176', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92f43ef6-cc29-5d1a-a0d4-84c2e269f7b7', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b471b311-79ca-557a-8dc7-d26a34529c04', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01ad3c75-5ab7-5f7f-ac0a-0d37c79b6853', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22f18c56-3695-5fab-aafc-7e9d60c0b2cd', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 12, $md$L$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2cc9e8c-af7c-5acd-a497-c8f9b412a842', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 13, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e5fb062-1fdb-584e-a83d-8152764e327b', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 14, $md$N$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a33b7f8c-ecf6-5e10-91c1-e0ef1af104d3', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 15, $md$O$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d673ee2f-e7ff-53a5-8eb5-bba6747d49b2', 'a959cfbd-b78b-52db-8402-0400c2fb3775', 16, $md$P$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7fe74355-d379-5fd5-809d-bee2421aeb31', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Write the correct letter, A–O, in boxes 1-7 on your answer sheet.
For more than 2000 years people have wondered why raising the
1
of cold water before cooling it results in more rapid cooling. At first researchers thought that a warm container created its own icy
2
which made the water freeze faster, but comparisons with containers resting on a dry
3
indicated that this was inaccurate. Evaporation of water proved not to be a
4
.
Temperature measurements showed that, although the water in the cooler container reached 00C before the warmer one, it took longer to actually solidify. The water temperature drops the most at the top and sides of the container. Provided there is a temperature
5
, the water will continue to circulate and to cool down. Cooler water will have less water
6
, and thus a slower rate of freezing. If ice forms on the top of the water, this will further slow the
7
of freezing, but if it forms on the bottom and the sides of the container, this will increase the rate of cooling.
A. melt
B. element
C. process
D. centre
E. acceleration
F. surface
G. factor
H. hollow
I. matter
J. circulation
K. limit
L. significance
M. theory
N. difference
O. result
P. temperature

For more than 2000 years people have wondered why raising the 1 ____ of cold water before cooling it results in more rapid cooling. At first researchers thought that a warm container created its own icy 2 ____ which made the water freeze faster, but comparisons with containers resting on a dry 3 ____ indicated that this was inaccurate. Evaporation of water proved not to be a 4 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67428c1c-eb55-5952-9bab-bbccf8a979ec', '7fe74355-d379-5fd5-809d-bee2421aeb31', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a86e9958-a5dc-58a3-bf2e-b439df887004', '7fe74355-d379-5fd5-809d-bee2421aeb31', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f5f9896-0e01-54b8-b261-b00ff277b9c4', '7fe74355-d379-5fd5-809d-bee2421aeb31', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2114d8d-6ed8-5610-9841-0a0594898d45', '7fe74355-d379-5fd5-809d-bee2421aeb31', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adab0073-b38c-576b-81ba-b3885a8aacc2', '7fe74355-d379-5fd5-809d-bee2421aeb31', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1fb9f37-89d2-58ca-9a26-41914a8f5acd', '7fe74355-d379-5fd5-809d-bee2421aeb31', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f279604-f123-5541-9521-4a9fb42d8d32', '7fe74355-d379-5fd5-809d-bee2421aeb31', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d8f09be-abf0-5e7a-9930-1e93181b3d44', '7fe74355-d379-5fd5-809d-bee2421aeb31', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad558ee2-fabf-53ab-8373-c225c02a88eb', '7fe74355-d379-5fd5-809d-bee2421aeb31', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dcb13c4-644a-5e3d-bbb3-b25c6dcf6953', '7fe74355-d379-5fd5-809d-bee2421aeb31', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c82cfad7-654b-5402-8b80-e77b0131f525', '7fe74355-d379-5fd5-809d-bee2421aeb31', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2db19dab-37be-5e42-9201-898e8f915705', '7fe74355-d379-5fd5-809d-bee2421aeb31', 12, $md$L$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44eb3b05-6945-5d04-a273-e0b65d008447', '7fe74355-d379-5fd5-809d-bee2421aeb31', 13, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68290b5f-8da5-57f7-9000-d1c358c2b797', '7fe74355-d379-5fd5-809d-bee2421aeb31', 14, $md$N$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b3536f6-6c9c-5813-a7e8-59af5b03fb05', '7fe74355-d379-5fd5-809d-bee2421aeb31', 15, $md$O$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95da14fd-aaf2-55d6-b55d-3853ada7dfc0', '7fe74355-d379-5fd5-809d-bee2421aeb31', 16, $md$P$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c4c6b552-ae6b-585b-9744-999eb8e52b5a', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Write the correct letter, A–O, in boxes 1-7 on your answer sheet.
For more than 2000 years people have wondered why raising the
1
of cold water before cooling it results in more rapid cooling. At first researchers thought that a warm container created its own icy
2
which made the water freeze faster, but comparisons with containers resting on a dry
3
indicated that this was inaccurate. Evaporation of water proved not to be a
4
.
Temperature measurements showed that, although the water in the cooler container reached 00C before the warmer one, it took longer to actually solidify. The water temperature drops the most at the top and sides of the container. Provided there is a temperature
5
, the water will continue to circulate and to cool down. Cooler water will have less water
6
, and thus a slower rate of freezing. If ice forms on the top of the water, this will further slow the
7
of freezing, but if it forms on the bottom and the sides of the container, this will increase the rate of cooling.
A. melt
B. element
C. process
D. centre
E. acceleration
F. surface
G. factor
H. hollow
I. matter
J. circulation
K. limit
L. significance
M. theory
N. difference
O. result
P. temperature

Temperature measurements showed that, although the water in the cooler container reached 00C before the warmer one, it took longer to actually solidify. The water temperature drops the most at the top and sides of the container. Provided there is a temperature 5 ____ , the water will continue to circulate and to cool down. Cooler water will have less water 6 ____ , and thus a slower rate of freezing. If ice forms on the top of the water, this will further slow the 7 ____ of freezing, but if it forms on the bottom and the sides of the container, this will increase the rate of cooling.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9c102df-1e3e-5451-a0a7-05ff7b1d353d', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5871415-5a12-5757-a510-9beb153cd224', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('539b8b2f-acb7-567c-aa8b-97c9389f49c2', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a998cc3e-5415-583b-83f3-b5c0c48b096f', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('122f49b1-c4a1-5044-a7f3-2ed00427b241', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd6f39d6-ae55-5397-8850-9ee9650cf780', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfbe4273-2a70-53ba-b9c9-43a5bdc77be1', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc07fba9-b47e-51fb-90ff-b56ebf33a59f', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('018f9064-5da0-552a-9e3f-d00389e88eb5', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27e8de49-c292-556d-87d7-86089fd9695a', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29aa4c1a-69d6-543c-9394-327fd2f3ca77', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11c53318-2ee6-5e84-860c-9f46130ce587', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 12, $md$L$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5148995-fd41-5f53-ba03-d834bf9db57c', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 13, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('249e3389-0746-591d-a45a-3ecd7e08301c', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 14, $md$N$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1fcac64-bee7-5b54-8044-0e38badfc860', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 15, $md$O$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84bb61e5-8087-5df2-9815-c21666283e52', 'c4c6b552-ae6b-585b-9744-999eb8e52b5a', 16, $md$P$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('221b2b9c-4cdf-54f9-b738-424516dc5a9f', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Write the correct letter, A–O, in boxes 1-7 on your answer sheet.
For more than 2000 years people have wondered why raising the
1
of cold water before cooling it results in more rapid cooling. At first researchers thought that a warm container created its own icy
2
which made the water freeze faster, but comparisons with containers resting on a dry
3
indicated that this was inaccurate. Evaporation of water proved not to be a
4
.
Temperature measurements showed that, although the water in the cooler container reached 00C before the warmer one, it took longer to actually solidify. The water temperature drops the most at the top and sides of the container. Provided there is a temperature
5
, the water will continue to circulate and to cool down. Cooler water will have less water
6
, and thus a slower rate of freezing. If ice forms on the top of the water, this will further slow the
7
of freezing, but if it forms on the bottom and the sides of the container, this will increase the rate of cooling.
A. melt
B. element
C. process
D. centre
E. acceleration
F. surface
G. factor
H. hollow
I. matter
J. circulation
K. limit
L. significance
M. theory
N. difference
O. result
P. temperature

Temperature measurements showed that, although the water in the cooler container reached 00C before the warmer one, it took longer to actually solidify. The water temperature drops the most at the top and sides of the container. Provided there is a temperature 5 ____ , the water will continue to circulate and to cool down. Cooler water will have less water 6 ____ , and thus a slower rate of freezing. If ice forms on the top of the water, this will further slow the 7 ____ of freezing, but if it forms on the bottom and the sides of the container, this will increase the rate of cooling.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e4b2994-5e53-585f-91c4-b89263d7e7d3', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16e978bf-f2c4-5ca8-a7b4-fa521e979e12', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf7dd71f-389d-5e8b-a5f4-88467f6d956e', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ecb359d-d92f-5f31-8a59-3da334aadd72', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc8029c6-4c88-50a3-baa9-008e12486d03', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('778cc313-7bd2-5700-8d2a-d7043b0f91ec', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('136947ea-d317-550e-a1d6-f28c5d6a2a98', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5c41b5c-4506-58c8-be1f-f046c7b27972', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ef3bf3b-57c4-55ef-ac3c-3ef69315f573', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19273d3a-b858-5630-924c-50e654ae16e8', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd07a1fb-748b-5ff4-87f1-f49aba524dfc', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18cb38b3-f903-5950-86dd-e40556771e41', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 12, $md$L$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('928124a2-5f55-5b8e-9795-44276a952653', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 13, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdc90223-c128-5cfb-9ac7-8282ba32b474', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 14, $md$N$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ffbc9f1-e5cf-5214-a40d-7a54f3fdfd59', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 15, $md$O$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c3c25a4-c095-5d48-b1e7-89fd473ab71f', '221b2b9c-4cdf-54f9-b738-424516dc5a9f', 16, $md$P$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('69e240c5-a27f-5753-87e5-efee93c7d06a', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Write the correct letter, A–O, in boxes 1-7 on your answer sheet.
For more than 2000 years people have wondered why raising the
1
of cold water before cooling it results in more rapid cooling. At first researchers thought that a warm container created its own icy
2
which made the water freeze faster, but comparisons with containers resting on a dry
3
indicated that this was inaccurate. Evaporation of water proved not to be a
4
.
Temperature measurements showed that, although the water in the cooler container reached 00C before the warmer one, it took longer to actually solidify. The water temperature drops the most at the top and sides of the container. Provided there is a temperature
5
, the water will continue to circulate and to cool down. Cooler water will have less water
6
, and thus a slower rate of freezing. If ice forms on the top of the water, this will further slow the
7
of freezing, but if it forms on the bottom and the sides of the container, this will increase the rate of cooling.
A. melt
B. element
C. process
D. centre
E. acceleration
F. surface
G. factor
H. hollow
I. matter
J. circulation
K. limit
L. significance
M. theory
N. difference
O. result
P. temperature

Temperature measurements showed that, although the water in the cooler container reached 00C before the warmer one, it took longer to actually solidify. The water temperature drops the most at the top and sides of the container. Provided there is a temperature 5 ____ , the water will continue to circulate and to cool down. Cooler water will have less water 6 ____ , and thus a slower rate of freezing. If ice forms on the top of the water, this will further slow the 7 ____ of freezing, but if it forms on the bottom and the sides of the container, this will increase the rate of cooling.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee3c3e93-c628-5770-9685-b163fa353a90', '69e240c5-a27f-5753-87e5-efee93c7d06a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5f1d948-d46c-559c-acb1-3ca1a6d69878', '69e240c5-a27f-5753-87e5-efee93c7d06a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2588a6f-5337-58b4-a8cd-980c764b9487', '69e240c5-a27f-5753-87e5-efee93c7d06a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8af10bef-7145-5f7d-9e35-f095e6524d19', '69e240c5-a27f-5753-87e5-efee93c7d06a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7aee7227-5ae4-5372-ab1c-03941ea68f4e', '69e240c5-a27f-5753-87e5-efee93c7d06a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3192f69-6f7e-5625-9708-53e8b2c4b85c', '69e240c5-a27f-5753-87e5-efee93c7d06a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9445cb8c-f5ed-5993-838f-fe668cbf9c3b', '69e240c5-a27f-5753-87e5-efee93c7d06a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30216922-c7c1-5730-ade4-aa2be30a3c07', '69e240c5-a27f-5753-87e5-efee93c7d06a', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4537046f-181d-5efd-b8d9-1c39f0815524', '69e240c5-a27f-5753-87e5-efee93c7d06a', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57d6d350-1892-5e0b-8be6-1ca4a983c43c', '69e240c5-a27f-5753-87e5-efee93c7d06a', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbbad88c-880e-5c7c-8ad0-7cf750c6af85', '69e240c5-a27f-5753-87e5-efee93c7d06a', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f0d5f6b-0baf-54d5-8af3-a674baa1592b', '69e240c5-a27f-5753-87e5-efee93c7d06a', 12, $md$L$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ca9f368-be8b-5132-add4-0abf0a63928d', '69e240c5-a27f-5753-87e5-efee93c7d06a', 13, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('020aaf8f-b659-5aeb-9b1e-8e060405ad23', '69e240c5-a27f-5753-87e5-efee93c7d06a', 14, $md$N$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48004081-18b0-518b-83ea-a97447c65e55', '69e240c5-a27f-5753-87e5-efee93c7d06a', 15, $md$O$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb79e9b9-eb07-5f2f-ad59-ad2e95d82cea', '69e240c5-a27f-5753-87e5-efee93c7d06a', 16, $md$P$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc0057dc-339d-5cd2-aa4c-0f41b60d57e0', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage ? In boxes 8-13 on your answer sheet, write
TRUE – if the statement agrees with the information
FALSE – if the statement contradicts the information
NOT GIVEN – if there is no information on this
8
The Mpemba Effect cannot be seen when comparing liquids with an extreme temperature difference.
9
Osborne and Mpemba’s results are still widely accepted today.
10
The size of the container does not alter the Mpemba Effect.
11
Osborne and Mpemba experimented on both pure and impure water.
12
One variable is the timing of containers in a freezer.
13
Physicists now agree that supercooling accounts for the Mpemba Effect.

8 ____ The Mpemba Effect cannot be seen when comparing liquids with an extreme temperature difference.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9443308e-fbf5-5b7f-870c-4eb1c1462938', 'fc0057dc-339d-5cd2-aa4c-0f41b60d57e0', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('caf0a151-c8a2-5790-9275-864031278981', 'fc0057dc-339d-5cd2-aa4c-0f41b60d57e0', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9367aa41-0032-54c7-b225-efe9917e61b3', 'fc0057dc-339d-5cd2-aa4c-0f41b60d57e0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('943e684a-1823-5268-8e62-df362d16c2b4', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage ? In boxes 8-13 on your answer sheet, write
TRUE – if the statement agrees with the information
FALSE – if the statement contradicts the information
NOT GIVEN – if there is no information on this
8
The Mpemba Effect cannot be seen when comparing liquids with an extreme temperature difference.
9
Osborne and Mpemba’s results are still widely accepted today.
10
The size of the container does not alter the Mpemba Effect.
11
Osborne and Mpemba experimented on both pure and impure water.
12
One variable is the timing of containers in a freezer.
13
Physicists now agree that supercooling accounts for the Mpemba Effect.

9 ____ Osborne and Mpemba’s results are still widely accepted today.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04d4d998-734f-50c4-8e48-cccf89def926', '943e684a-1823-5268-8e62-df362d16c2b4', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fd7c735-3c78-5f9c-882c-61a50511592a', '943e684a-1823-5268-8e62-df362d16c2b4', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('221e506c-51d3-5749-8e69-6eaac95ea39d', '943e684a-1823-5268-8e62-df362d16c2b4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fee44385-a1e9-5af8-8699-cce0e4214e5b', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage ? In boxes 8-13 on your answer sheet, write
TRUE – if the statement agrees with the information
FALSE – if the statement contradicts the information
NOT GIVEN – if there is no information on this
8
The Mpemba Effect cannot be seen when comparing liquids with an extreme temperature difference.
9
Osborne and Mpemba’s results are still widely accepted today.
10
The size of the container does not alter the Mpemba Effect.
11
Osborne and Mpemba experimented on both pure and impure water.
12
One variable is the timing of containers in a freezer.
13
Physicists now agree that supercooling accounts for the Mpemba Effect.

10 ____ The size of the container does not alter the Mpemba Effect.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78dc7bd9-95a1-523e-b00d-c94008f7e803', 'fee44385-a1e9-5af8-8699-cce0e4214e5b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20023e16-f613-59c1-87d5-46b11904fac8', 'fee44385-a1e9-5af8-8699-cce0e4214e5b', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3451f899-b98d-57ec-8504-67709b2ebc3e', 'fee44385-a1e9-5af8-8699-cce0e4214e5b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d9d2e3a-ba35-5183-b86d-08b0f2cf0351', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage ? In boxes 8-13 on your answer sheet, write
TRUE – if the statement agrees with the information
FALSE – if the statement contradicts the information
NOT GIVEN – if there is no information on this
8
The Mpemba Effect cannot be seen when comparing liquids with an extreme temperature difference.
9
Osborne and Mpemba’s results are still widely accepted today.
10
The size of the container does not alter the Mpemba Effect.
11
Osborne and Mpemba experimented on both pure and impure water.
12
One variable is the timing of containers in a freezer.
13
Physicists now agree that supercooling accounts for the Mpemba Effect.

11 ____ Osborne and Mpemba experimented on both pure and impure water.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7cd4b7c-d906-535d-ab20-dc820a61af75', '5d9d2e3a-ba35-5183-b86d-08b0f2cf0351', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94f1ff99-4a5e-5dc1-a030-ee546f0f5016', '5d9d2e3a-ba35-5183-b86d-08b0f2cf0351', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd178bf2-6204-5611-9764-4e3580a01206', '5d9d2e3a-ba35-5183-b86d-08b0f2cf0351', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d1747bdc-b1bc-5a15-a075-5a8555794a8d', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage ? In boxes 8-13 on your answer sheet, write
TRUE – if the statement agrees with the information
FALSE – if the statement contradicts the information
NOT GIVEN – if there is no information on this
8
The Mpemba Effect cannot be seen when comparing liquids with an extreme temperature difference.
9
Osborne and Mpemba’s results are still widely accepted today.
10
The size of the container does not alter the Mpemba Effect.
11
Osborne and Mpemba experimented on both pure and impure water.
12
One variable is the timing of containers in a freezer.
13
Physicists now agree that supercooling accounts for the Mpemba Effect.

12 ____ One variable is the timing of containers in a freezer.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1009c010-8c40-50c3-bdaa-5f52efec4655', 'd1747bdc-b1bc-5a15-a075-5a8555794a8d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cce8eda5-94da-58dd-aad2-3701816e85f9', 'd1747bdc-b1bc-5a15-a075-5a8555794a8d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93cc0da0-4a44-5e62-aacf-408bbbe901b6', 'd1747bdc-b1bc-5a15-a075-5a8555794a8d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cd373db5-444a-5b52-ab0d-9e46456ba958', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage ? In boxes 8-13 on your answer sheet, write
TRUE – if the statement agrees with the information
FALSE – if the statement contradicts the information
NOT GIVEN – if there is no information on this
8
The Mpemba Effect cannot be seen when comparing liquids with an extreme temperature difference.
9
Osborne and Mpemba’s results are still widely accepted today.
10
The size of the container does not alter the Mpemba Effect.
11
Osborne and Mpemba experimented on both pure and impure water.
12
One variable is the timing of containers in a freezer.
13
Physicists now agree that supercooling accounts for the Mpemba Effect.

13 ____ Physicists now agree that supercooling accounts for the Mpemba Effect.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56eabb6f-126f-5c3c-82a6-3a11aa0a1ea7', 'cd373db5-444a-5b52-ab0d-9e46456ba958', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e69eab13-32ea-52d9-b9ae-1b25e720ffda', 'cd373db5-444a-5b52-ab0d-9e46456ba958', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c9bf201-2ee8-5207-8c3b-beca294d40c4', 'cd373db5-444a-5b52-ab0d-9e46456ba958', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b4b84af9-1ac8-507c-9788-ba675837546a', '3e4dae29-fc60-58ae-90a8-c0c5bfb7c837', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Question 14
Question 14
Choose the correct letter, A, B, C or D.
The Mpemba Effect is best summed up as the observation that
A
ice cream freezes at different temperatures.
B
different sources of heat result in water cooling at different rates.
C
salt water freezes at a lower temperature than ordinary water.
D
warmer water can freeze faster than colder water.

Choose the correct letter, A, B, C or D.$md$, NULL);

COMMIT;
