BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-ingenuity-gap-1376'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-ingenuity-gap-1376';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-ingenuity-gap-1376';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-ingenuity-gap-1376';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2a27b387-1997-59a9-8f08-32da2385398a', 'ielts-reading-the-ingenuity-gap-1376', $t$The Ingenuity Gap$t$, $md$## The Ingenuity Gap

Nguồn:
- Test: https://mini-ielts.com/1376/reading/the-ingenuity-gap
- Solution: https://mini-ielts.com/1376/view-solution/reading/the-ingenuity-gap$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2f8ddcec-f438-5a85-b0d9-509de5b13730', '2a27b387-1997-59a9-8f08-32da2385398a', 1, $t$Reading — The Ingenuity Gap$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Ingenuity Gap

| | The Ingenuity Gap Ingenuity, as I define it here, consists not only of ideas for new technologies like computers or drought-resistant crops but, more fundamentally, of ideas for better institutions and social arrangements, like efficient markets and competent governments. How much and what kinds of ingenuity a society requires depends on a range of factors, including the society’s goals and the circumstances within which it must achieve those goals—whether it has a young population or an ageing one, an abundance of natural resources or a scarcity of them, an easy climate or a punishing one, whatever the case may be. How much and what kinds of ingenuity a society supplies also depends on many factors, such as the nature of human inventiveness and understanding, the rewards an economy gives to the producers of useful knowledge, and the strength of political opposition to social and institutional reforms. A good supply of the right kind of ingenuity is essential, but it isn’t, of course, enough by itself. We know that the creation of wealth, for example, depends not only on an adequate supply of useful ideas but also on the availability of other, more conventional factors of production, like capital and labor. Similarly, prosperity, stability and justice usually depend on the resolution, or at least the containment, of major political struggles over wealth and power. Yet within our economies ingenuity often supplants labor, and growth in the stock of physical plant is usually accompanied by growth in the stock of ingenuity. And in our political systems, we need great ingenuity to set up institutions that successfully manage struggles over wealth and power. Clearly, our economic and political processes are intimately entangled with the production and use of ingenuity. The past century’s countless incremental changes in our societies around the planet, in our technologies and our interactions with our surrounding natural environments, have accumulated to create a qualitatively new world. Because these changes have accumulated slowly, it’s often hard for us to recognize how profound and sweeping they’ve been. They include far larger and denser populations; much higher per capita consumption of natural resources; and far better and more widely available technologies for the movement of people, materials, and especially information. In combination, these changes have sharply increased the density, intensity, and pace of our interactions with each other; they have greatly increased the burden we place on our natural environment; and they have helped shift power from national and international institutions to individuals in subgroups, such as political special interests and ethnic factions. As a result, people in all walks of life—from our political and business leaders to all of us in our day-to-day—must cope with much more complex, urgent, and often unpredictable circumstances. The management of our relationship with this new world requires immense and ever-increasing amounts of social and technical ingenuity. As we strive to maintain or increase our prosperity and improve the quality of our lives, we must make far more sophisticated decisions, and in less time, than ever before. When we enhance the performance of any system, from our cars to the planet’s network of financial institutions, we tend to make it more complex. Many of the natural systems critical to our well-being, like the global climate and the oceans, are extraordinarily complex, to begin with. We often can’t predict or manage the behavior of complex systems with much precision, because they are often very sensitive to the smallest of changes and perturbations, and their behavior can flip from one mode to another suddenly and dramatically. In general, as the human-made and natural systems, we depend upon becoming more complex, and as our demands on them increase, the institutions and technologies we use to manage them must become more complex too, which further boosts our need for ingenuity. The good news, though, is that the last century’s stunning changes in our societies and technologies have not just increased our need for ingenuity; they have also produced a huge increase in its supply. The growth and urbanization of human populations have combined with astonishing new communication and transportation technologies to expand interactions among people and produce larger, more integrated, and more efficient markets. These changes have, in turn, vastly accelerated the generation and delivery of useful ideas. But—and this is the critical “but”—we should not jump to the conclusion that the supply of ingenuity always increases in lockstep with our ingenuity requirement: while it’s true that necessity is often the mother of invention, we can’t always rely on the right kind of ingenuity appearing when and where we need it. In many cases, the complexity and speed of operation of today’s vital economic, social, and ecological systems exceed the human brain’s grasp. Very few of us have more than a rudimentary understanding of how these systems work. They remain fraught with countless “unknown unknowns,” which makes it hard to supply the ingenuity we need to solve problems associated with these systems. In this book, I explore a wide range of other factors that will limit our ability to supply the ingenuity required in the coming century. For example, many people believe that new communication technologies strengthen democracy and will make it easier to find solutions to our societies’ collective problems, but the story is less clear than it seems. The crush of information in our everyday lives is shortening our attention span, limiting the time we have to reflect on critical matters of public policy, and making policy arguments more superficial. Modern markets and science are an important part of the story of how we supply ingenuity. Markets are critically important because they give entrepreneurs an incentive to produce knowledge. As for science, although it seems to face no theoretical limits, at least in the foreseeable future, practical constraints often slow its progress. The cost of scientific research tends to increase as it delves deeper into nature. And science’s rate of advance depends on the characteristic of the natural phenomena it investigates, simply because some phenomena are intrinsically harder to understand than others, so the production of useful new knowledge in these areas can be very slow. Consequently, there is often a critical time lag between the recognition between a problem and the delivery of sufficient ingenuity, in the form of technologies, to solve that problem. Progress in the social sciences is especially slow, for reasons we don’t yet understand; but we desperately need better social scientific knowledge to build the sophisticated institutions today’s world demands.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5e77b5f1-e427-557d-8334-f4e10d270b83', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Complete each sentence with the appropriate answer,
A, B, C,
or
D
.
Write the correct answer in boxes
1-4
on your answer sheet
1
The definition of ingenuity
2
The requirement for ingenuity
3
The creation of social wealth
4
The stability of society
A.
depends on many factors including climate.
B.
depends on the management and solution of disputes.
C.
is not only of technological advance but more of institutional renovation.
D.
also depends on the availability of some traditional resources.

1 ____ The definition of ingenuity$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ccca2ccc-a12b-5792-b19a-e45c59641571', '5e77b5f1-e427-557d-8334-f4e10d270b83', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57cd21a4-8c71-576c-b742-8f3946188df0', '5e77b5f1-e427-557d-8334-f4e10d270b83', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6d67e58-5e2d-598c-9b22-a96d19f2bc6e', '5e77b5f1-e427-557d-8334-f4e10d270b83', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb66b10a-69c7-5ae6-bffc-de33bbdb0217', '5e77b5f1-e427-557d-8334-f4e10d270b83', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eea20e8c-4c0c-590f-844a-de4ee410b2a6', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Complete each sentence with the appropriate answer,
A, B, C,
or
D
.
Write the correct answer in boxes
1-4
on your answer sheet
1
The definition of ingenuity
2
The requirement for ingenuity
3
The creation of social wealth
4
The stability of society
A.
depends on many factors including climate.
B.
depends on the management and solution of disputes.
C.
is not only of technological advance but more of institutional renovation.
D.
also depends on the availability of some traditional resources.

2 ____ The requirement for ingenuity$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f52ee997-0895-5ebe-9474-b692713e6e60', 'eea20e8c-4c0c-590f-844a-de4ee410b2a6', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b460c78c-0943-52d8-9dea-da1c128aab1e', 'eea20e8c-4c0c-590f-844a-de4ee410b2a6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a5eb486-806e-56ea-af1c-3c08d9c62994', 'eea20e8c-4c0c-590f-844a-de4ee410b2a6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('667630f0-aea2-5703-86d2-51adaeec495f', 'eea20e8c-4c0c-590f-844a-de4ee410b2a6', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('30bd3f16-b889-5c8f-ad50-2b51bcf6793a', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Complete each sentence with the appropriate answer,
A, B, C,
or
D
.
Write the correct answer in boxes
1-4
on your answer sheet
1
The definition of ingenuity
2
The requirement for ingenuity
3
The creation of social wealth
4
The stability of society
A.
depends on many factors including climate.
B.
depends on the management and solution of disputes.
C.
is not only of technological advance but more of institutional renovation.
D.
also depends on the availability of some traditional resources.

3 ____ The creation of social wealth$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a295d7ad-d0f5-51d8-a41e-3e84ddc44e9f', '30bd3f16-b889-5c8f-ad50-2b51bcf6793a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bd39369-2fe3-58ef-ad14-285716c72909', '30bd3f16-b889-5c8f-ad50-2b51bcf6793a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('565ef256-e4c9-599b-a7a5-7d519ed9b8de', '30bd3f16-b889-5c8f-ad50-2b51bcf6793a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5e1228d-4a57-518b-8514-bdc90563b308', '30bd3f16-b889-5c8f-ad50-2b51bcf6793a', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('efb685de-e8c0-53b1-8be0-7d365099661f', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Complete each sentence with the appropriate answer,
A, B, C,
or
D
.
Write the correct answer in boxes
1-4
on your answer sheet
1
The definition of ingenuity
2
The requirement for ingenuity
3
The creation of social wealth
4
The stability of society
A.
depends on many factors including climate.
B.
depends on the management and solution of disputes.
C.
is not only of technological advance but more of institutional renovation.
D.
also depends on the availability of some traditional resources.

4 ____ The stability of society$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7abca95f-a5b2-5d23-a827-90a44b619ac3', 'efb685de-e8c0-53b1-8be0-7d365099661f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('991cb90f-ff60-5bd3-883b-fed796437e92', 'efb685de-e8c0-53b1-8be0-7d365099661f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f07f290-ed0e-595a-b0fd-616cc078c061', 'efb685de-e8c0-53b1-8be0-7d365099661f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b532b69d-6c3b-529c-ad2f-be3be8c1ab6b', 'efb685de-e8c0-53b1-8be0-7d365099661f', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('27f7c53a-bc86-50b2-80b2-c366a7598d2d', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-7
Questions 5-7
Choose the correct letter,
A, B, C
or
D
.
Write your answers in boxes
5-7
on your answer sheet
5. What does the author say about the incremental change of the last 100 years?
A
It has become a hot scholastic discussion among environmentalists.
B
Its significance is often not noticed.
C
It has reshaped the natural environments we live in.
D
It benefited a much larger population than ever.
6. The combination of changes has made life:
A
easier
B
faster
C
slower
D
less sophisticated
7. What does the author say about
the natural
systems?
A
New technologies are being developed to predict change with precision.
B
Natural systems are often more sophisticated than other systems.
C
Minor alterations may cause natural systems to change dramatically.
D
Technological developments have rendered human being more independent of natural systems.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6a0005ff-a2d7-50cb-85e6-283938b907ca', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-7
Questions 5-7
Choose the correct letter,
A, B, C
or
D
.
Write your answers in boxes
5-7
on your answer sheet
5. What does the author say about the incremental change of the last 100 years?
A
It has become a hot scholastic discussion among environmentalists.
B
Its significance is often not noticed.
C
It has reshaped the natural environments we live in.
D
It benefited a much larger population than ever.
6. The combination of changes has made life:
A
easier
B
faster
C
slower
D
less sophisticated
7. What does the author say about
the natural
systems?
A
New technologies are being developed to predict change with precision.
B
Natural systems are often more sophisticated than other systems.
C
Minor alterations may cause natural systems to change dramatically.
D
Technological developments have rendered human being more independent of natural systems.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('02f4ab13-6824-5325-929e-f1e9fc6c5a25', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-7
Questions 5-7
Choose the correct letter,
A, B, C
or
D
.
Write your answers in boxes
5-7
on your answer sheet
5. What does the author say about the incremental change of the last 100 years?
A
It has become a hot scholastic discussion among environmentalists.
B
Its significance is often not noticed.
C
It has reshaped the natural environments we live in.
D
It benefited a much larger population than ever.
6. The combination of changes has made life:
A
easier
B
faster
C
slower
D
less sophisticated
7. What does the author say about
the natural
systems?
A
New technologies are being developed to predict change with precision.
B
Natural systems are often more sophisticated than other systems.
C
Minor alterations may cause natural systems to change dramatically.
D
Technological developments have rendered human being more independent of natural systems.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e2701f33-19d2-516b-ab31-8f4a20b0e6d2', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-14
Questions 8-14
Do the following statements agree with the information given in the Reading Passage?
In boxes
8-14
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
The demand for ingenuity has been growing during the past 100 years.
9
The ingenuity we have may be inappropriate for solving problems at hand.
10
There are very few who can understand the complex systems of the present world.
11
More information will help us to make better decisions.
12
The next generation will blame the current government for their conduct.
13
Science tends to develop faster in certain areas than others.
14
Social science develops especially slowly because it is not as important as natural science.

8 ____ The demand for ingenuity has been growing during the past 100 years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('761b1671-ca64-5443-bbf1-e9c4fbf5c769', 'e2701f33-19d2-516b-ab31-8f4a20b0e6d2', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('facee7dd-0de3-59c0-8b4a-01851aa15674', 'e2701f33-19d2-516b-ab31-8f4a20b0e6d2', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc480871-dfa8-5979-bc50-ae9b7c4c44c7', 'e2701f33-19d2-516b-ab31-8f4a20b0e6d2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7a8ce26e-2ce7-5290-9746-c65583158c88', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-14
Questions 8-14
Do the following statements agree with the information given in the Reading Passage?
In boxes
8-14
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
The demand for ingenuity has been growing during the past 100 years.
9
The ingenuity we have may be inappropriate for solving problems at hand.
10
There are very few who can understand the complex systems of the present world.
11
More information will help us to make better decisions.
12
The next generation will blame the current government for their conduct.
13
Science tends to develop faster in certain areas than others.
14
Social science develops especially slowly because it is not as important as natural science.

9 ____ The ingenuity we have may be inappropriate for solving problems at hand.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a527928a-7e64-51c0-bb45-01cee48b0842', '7a8ce26e-2ce7-5290-9746-c65583158c88', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54f78c88-6391-5b47-a201-e86cb80c5421', '7a8ce26e-2ce7-5290-9746-c65583158c88', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ab05364-1dbb-585e-a2aa-e4e6091be54f', '7a8ce26e-2ce7-5290-9746-c65583158c88', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6b705b7b-362f-5d75-9e9f-9bc5c8d83fbe', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-14
Questions 8-14
Do the following statements agree with the information given in the Reading Passage?
In boxes
8-14
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
The demand for ingenuity has been growing during the past 100 years.
9
The ingenuity we have may be inappropriate for solving problems at hand.
10
There are very few who can understand the complex systems of the present world.
11
More information will help us to make better decisions.
12
The next generation will blame the current government for their conduct.
13
Science tends to develop faster in certain areas than others.
14
Social science develops especially slowly because it is not as important as natural science.

10 ____ There are very few who can understand the complex systems of the present world.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f00fa3c6-7741-5957-bd61-0d7b0f691497', '6b705b7b-362f-5d75-9e9f-9bc5c8d83fbe', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41aab1ec-3fb8-5ad8-91b7-dcee9ff69f52', '6b705b7b-362f-5d75-9e9f-9bc5c8d83fbe', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d2000d8-1a18-5e4e-aaad-0c11cc91c444', '6b705b7b-362f-5d75-9e9f-9bc5c8d83fbe', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d0946c17-5dd9-5658-a594-9dbfaffedd94', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 8-14
Questions 8-14
Do the following statements agree with the information given in the Reading Passage?
In boxes
8-14
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
The demand for ingenuity has been growing during the past 100 years.
9
The ingenuity we have may be inappropriate for solving problems at hand.
10
There are very few who can understand the complex systems of the present world.
11
More information will help us to make better decisions.
12
The next generation will blame the current government for their conduct.
13
Science tends to develop faster in certain areas than others.
14
Social science develops especially slowly because it is not as important as natural science.

11 ____ More information will help us to make better decisions.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88a1eb3c-a6b3-5238-a6da-8de5bdfaa43f', 'd0946c17-5dd9-5658-a594-9dbfaffedd94', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02a818a0-85a9-5d84-af9c-78313b830a01', 'd0946c17-5dd9-5658-a594-9dbfaffedd94', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d64cf88f-8792-54fb-b5eb-3f559032408f', 'd0946c17-5dd9-5658-a594-9dbfaffedd94', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc231ddb-2b71-57a6-9db7-315cf2a3c362', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 8-14
Questions 8-14
Do the following statements agree with the information given in the Reading Passage?
In boxes
8-14
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
The demand for ingenuity has been growing during the past 100 years.
9
The ingenuity we have may be inappropriate for solving problems at hand.
10
There are very few who can understand the complex systems of the present world.
11
More information will help us to make better decisions.
12
The next generation will blame the current government for their conduct.
13
Science tends to develop faster in certain areas than others.
14
Social science develops especially slowly because it is not as important as natural science.

12 ____ The next generation will blame the current government for their conduct.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2cd8750-6203-58fa-a995-92691922bfd1', 'fc231ddb-2b71-57a6-9db7-315cf2a3c362', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85aad765-5318-55bc-a903-33442acc800d', 'fc231ddb-2b71-57a6-9db7-315cf2a3c362', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('faba6f6b-9762-5a4f-b74f-19460e1883f1', 'fc231ddb-2b71-57a6-9db7-315cf2a3c362', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('063bb0e0-1be4-5bea-8c1e-7ade26b22967', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 8-14
Questions 8-14
Do the following statements agree with the information given in the Reading Passage?
In boxes
8-14
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
The demand for ingenuity has been growing during the past 100 years.
9
The ingenuity we have may be inappropriate for solving problems at hand.
10
There are very few who can understand the complex systems of the present world.
11
More information will help us to make better decisions.
12
The next generation will blame the current government for their conduct.
13
Science tends to develop faster in certain areas than others.
14
Social science develops especially slowly because it is not as important as natural science.

13 ____ Science tends to develop faster in certain areas than others.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0ce8f6f-6eb2-59d1-b0fb-11c013fe727b', '063bb0e0-1be4-5bea-8c1e-7ade26b22967', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14428a6d-37f4-5373-a76b-56e94e5e8b8b', '063bb0e0-1be4-5bea-8c1e-7ade26b22967', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9edfe6b9-5367-5b8f-9ebd-c2a632da8d3b', '063bb0e0-1be4-5bea-8c1e-7ade26b22967', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d56012a3-bef6-5d52-8abf-b0384748779c', '2f8ddcec-f438-5a85-b0d9-509de5b13730', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 8-14
Questions 8-14
Do the following statements agree with the information given in the Reading Passage?
In boxes
8-14
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
The demand for ingenuity has been growing during the past 100 years.
9
The ingenuity we have may be inappropriate for solving problems at hand.
10
There are very few who can understand the complex systems of the present world.
11
More information will help us to make better decisions.
12
The next generation will blame the current government for their conduct.
13
Science tends to develop faster in certain areas than others.
14
Social science develops especially slowly because it is not as important as natural science.

14 ____ Social science develops especially slowly because it is not as important as natural science.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a4ba2f9-3868-5156-93f0-97cc326b7ef8', 'd56012a3-bef6-5d52-8abf-b0384748779c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7d03be0-cb06-50d2-8215-f819a92267f9', 'd56012a3-bef6-5d52-8abf-b0384748779c', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cddc8fe9-43f6-5e45-9c21-16ae683259f1', 'd56012a3-bef6-5d52-8abf-b0384748779c', 3, $md$NOT GIVEN$md$, false);

COMMIT;
