BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-agriculture-and-tourism-1270'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-agriculture-and-tourism-1270';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-agriculture-and-tourism-1270';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-agriculture-and-tourism-1270';

-- Insert IELTS reading exam (single passage)
INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
VALUES ('c944d872-1140-43e7-8898-f687b78a1df3', 'ielts-reading-agriculture-and-tourism-1270', $t$Agriculture and Tourism$t$, $md$## Agriculture and Tourism

Nguồn:
- Test: https://mini-ielts.com/1270/reading/agriculture-and-tourism
- Solution: https://mini-ielts.com/1270/view-solution/reading/agriculture-and-tourism

*File seed SQL này được generate từ agriculture-and-tourism.exam.json theo format giống seed_exam_placement_a2_c1_sample.sql.*
$md$, 'IELTS', 'B2', 'DRAFT', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('465b0cea-d621-42fa-a997-c4a87e3caab8', 'c944d872-1140-43e7-8898-f687b78a1df3', 1, $t$Reading – Agriculture and Tourism$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Agriculture and Tourism

A . Linkages between the Agri-Food Sector and Tourism offer significant opportunities for the development of both sectors within the region. These linkages could lead to ensuring the sustainability of the region’s tourism product thus ensuring it preservation. Agriculture and tourism — two of Wisconsin’s most industries — are teaming up in southwestern Wisconsin has found that tourists, rural communities, and some farmers could benefit from stronger efforts to promote and market agricultural tourism there. In 1990, agricultural tourism project members surveyed 290 visitors to the annual Monroe Cheese Festival and 164 visitors to the Picnic on the Farm, a one-time event held in Platteville in conjunction with the Chicago Bears summer training camp. More than one-half of those surveyed responded favorably to a proposed tour, saying they would be interested in participating in some type of agricultural tour in southwestern Wisconsin. Survey respondents reported that they would prefer to visit cheese factories, sausage processing plants, dairy farms, and historical farm sites, as well as enjoy an old-fashioned picnic dinner. The study also found strong interest in visiting specialty farms (strawberries, cranberries, poultry, etc.). More than 75 percent of the Cheese Day visitors planned ahead for the trip, with 37 percent planning at least two months in advance.

B . More than 40 percent of the visitors came to Monroe for two- or three-day visits. Many stopped at other communities on their way to Cheese Days. Visitors at both events indicated that they were there to enjoy themselves and were willing to spend money on food and arts and crafts. They also wanted the opportunity to experience the “country” while there. The study found that planning around existing events should take into account what brought visitors to the area and provide additional attractions that will appeal to them. For example, visitors to Cheese Days said they were on a holiday and appeared to be more open to various tour proposals. Picnic visitors came specifically to see the Chicago Bears practice. They showed less interest in a proposed agricultural tour than Cheese Day visitors, but more interest in a picnic dinner.

C . The study identified three primary audiences for agricultural tourism: 1) elderly people who take bus tours to see the country; 2) families interested in tours that could be enjoyed by both parents and children; and 3) persons already involved in agriculture, including international visitors. Agricultural tourism can serve to educate urban tourists about the problems and challenges facing farmers, says Andy Lewis, Grant county community development agent. While agriculture is vital to Wisconsin, more and more urban folk are becoming isolated from the industry. In fact, Lewis notes, farmers are just as interested in the educational aspects of agricultural tours as they are in any financial returns.

D . “Farmers feel that urban consumers are out of touch with farming,” Lewis says. “If tourists can be educated on issues that concern farmers, those visits could lead to policies more favorable to agriculture.” Animal rights and the environment are examples of two issues that concern both urban consumers and farmers. Farm tours could help consumers get the farmer’s perspective on these issues, Lewis notes. Several Wisconsin farms already offer some type of learning experience for tourists. However, most agricultural tourism enterprises currently market their businesses independently, leading to a lack of a concerted effort to promote agricultural tourism as an industry.

E . Lewis is conducting the study with Jean Murphy, assistant community development agent. Other participants include UW-Platteville Agricultural Economist Bob Acton, the Center for Integrated Agricultural Systems, UW-Extension Recreation Resources Center, the Wisconsin Rural Development Center, and Hidden Valleys, a Southwestern Wisconsin regional tourism organization. This past fall, Murphy organized several workshops with some Green and Grant County farmers, local business leaders, and motor coach tour operators to discuss how best to organize and put on farm tours. Committees were formed to look at the following: tour site evaluations, inventory of the area’s resources, tour marketing, and familiarization of tours. The fourth committee is organizing tours for people such as tour bus guides and local reporters to help better educate them about agricultural tourism. Green County farmers already have experience hosting visitors during the annual Monroe Cheese Days. Green county Tourism Director Larry Lindgren says these farmers are set to go ahead with more formal agricultural tours next year. The tours will combine a farm visit with a visit to a local cheese factory and a picnic lunch.

F . Another farm interested in hosting an organized tour is Sinsinawa, a 200-acre Grant County farm devoted to sustainable agriculture and run by the Dominican Sisters. Education plays a major role at the farm, which has an orchard, dairy and beef cows, and hogs. Farm tours could be combined with other activities in the area such as trips to the Mississippi River and/or visits to historical towns orlandmarks, Lewis says. The project will help expose farmers to the tourism industry and farm vacations as a way to possibly supplement incomes, he adds. While farm families probably wouldn’t make a lot of money through farm tours, they would be compensated for their time, says Lewis. Farmers could earn additional income through the sale of farm products, crafts, and recreational activities.

Image (if applicable): /Images/highlight.png
Source: https://mini-ielts.com/1270/reading/agriculture-and-tourism
Solution: https://mini-ielts.com/1270/view-solution/reading/agriculture-and-tourism
$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('53036d4f-9539-4091-9624-5051d5b48461', '465b0cea-d621-42fa-a997-c4a87e3caab8', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
The reading Passage has six paragraphs
A-F
.
Which paragraph contains the following information?
Write the correct letter
A- F
, inboxes
1-4
on your answer sheet.
1
About half of all the tourists would spend several days in Monroe.
2
Most visitors responded positively to a survey project on farm tour.
3
Cooperation across organisations in research for agriculture tours has been carried out.
4
Agriculture tour assist tourists to understand more issues concerning animal and environment.

1 ____ About half of all the tourists would spend several days in Monroe.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5cae0ff8-bc06-41b7-a1a8-761fdabccb60', '53036d4f-9539-4091-9624-5051d5b48461', 1, 'A', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('565c8d81-ebfa-4ef3-bb2b-7e050d0d76c0', '53036d4f-9539-4091-9624-5051d5b48461', 2, 'B', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c180fb3-db38-42d5-95b3-7ff48ed555db', '53036d4f-9539-4091-9624-5051d5b48461', 3, 'C', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1087008a-4965-458b-85a9-9a45a6b2080c', '53036d4f-9539-4091-9624-5051d5b48461', 4, 'D', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6aa6d2d5-a53c-4ebf-8bda-60360c2fda43', '53036d4f-9539-4091-9624-5051d5b48461', 5, 'E', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6055cdec-0e23-4f8e-bf84-3575dc4343d8', '53036d4f-9539-4091-9624-5051d5b48461', 6, 'F', false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('257c0977-e7cc-4253-9705-01a56aeea568', '465b0cea-d621-42fa-a997-c4a87e3caab8', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
The reading Passage has six paragraphs
A-F
.
Which paragraph contains the following information?
Write the correct letter
A- F
, inboxes
1-4
on your answer sheet.
1
About half of all the tourists would spend several days in Monroe.
2
Most visitors responded positively to a survey project on farm tour.
3
Cooperation across organisations in research for agriculture tours has been carried out.
4
Agriculture tour assist tourists to understand more issues concerning animal and environment.

2 ____ Most visitors responded positively to a survey project on farm tour.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c7c2c46-7d39-4e1c-9175-c9d2ca0bbb07', '257c0977-e7cc-4253-9705-01a56aeea568', 1, 'A', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d6e3dc8-f441-406e-b05c-94da195ac3c8', '257c0977-e7cc-4253-9705-01a56aeea568', 2, 'B', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f76d319e-c229-42f8-8558-95b29ef76e65', '257c0977-e7cc-4253-9705-01a56aeea568', 3, 'C', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d7d1b20-4557-4400-a237-4d6dd675d75a', '257c0977-e7cc-4253-9705-01a56aeea568', 4, 'D', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5537e6c6-f50d-497c-8474-ec8bf4e248c7', '257c0977-e7cc-4253-9705-01a56aeea568', 5, 'E', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b227f6af-2963-40f6-b8a4-7de13663c871', '257c0977-e7cc-4253-9705-01a56aeea568', 6, 'F', false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1d79a87b-bf57-40ac-9b26-55ac4664bc88', '465b0cea-d621-42fa-a997-c4a87e3caab8', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
The reading Passage has six paragraphs
A-F
.
Which paragraph contains the following information?
Write the correct letter
A- F
, inboxes
1-4
on your answer sheet.
1
About half of all the tourists would spend several days in Monroe.
2
Most visitors responded positively to a survey project on farm tour.
3
Cooperation across organisations in research for agriculture tours has been carried out.
4
Agriculture tour assist tourists to understand more issues concerning animal and environment.

3 ____ Cooperation across organisations in research for agriculture tours has been carried out.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47bfe9aa-18e3-4de8-a629-d56e3900bcb6', '1d79a87b-bf57-40ac-9b26-55ac4664bc88', 1, 'A', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be77a38b-d12e-498e-b728-9513a8c774d1', '1d79a87b-bf57-40ac-9b26-55ac4664bc88', 2, 'B', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92c6fd08-1a3f-4571-ba8e-46405b5ebb05', '1d79a87b-bf57-40ac-9b26-55ac4664bc88', 3, 'C', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebd390a3-a516-4522-9fd6-e5c8178e814a', '1d79a87b-bf57-40ac-9b26-55ac4664bc88', 4, 'D', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3d58406-1490-4d00-9869-cdc039c885bc', '1d79a87b-bf57-40ac-9b26-55ac4664bc88', 5, 'E', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69505a7a-2ebe-4705-8172-7b70bf8d6e75', '1d79a87b-bf57-40ac-9b26-55ac4664bc88', 6, 'F', false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c625195-5864-4c91-91e2-43be386bf376', '465b0cea-d621-42fa-a997-c4a87e3caab8', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
The reading Passage has six paragraphs
A-F
.
Which paragraph contains the following information?
Write the correct letter
A- F
, inboxes
1-4
on your answer sheet.
1
About half of all the tourists would spend several days in Monroe.
2
Most visitors responded positively to a survey project on farm tour.
3
Cooperation across organisations in research for agriculture tours has been carried out.
4
Agriculture tour assist tourists to understand more issues concerning animal and environment.

4 ____ Agriculture tour assist tourists to understand more issues concerning animal and environment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62861f1f-e25e-40d6-8708-bcc578f6297e', '4c625195-5864-4c91-91e2-43be386bf376', 1, 'A', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf3a627e-4ea1-453b-8fb5-ae7c9b6f5a14', '4c625195-5864-4c91-91e2-43be386bf376', 2, 'B', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b09a69f-9a9e-40ac-9367-6b31aa3da8d9', '4c625195-5864-4c91-91e2-43be386bf376', 3, 'C', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e74109a6-f99e-4556-a936-e1ffef70b5f0', '4c625195-5864-4c91-91e2-43be386bf376', 4, 'D', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8c1df68-5135-4681-9229-6a335fb50ca0', '4c625195-5864-4c91-91e2-43be386bf376', 5, 'E', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c64a6eb-c9d2-4c4e-8c28-d6bbbc5c70f3', '4c625195-5864-4c91-91e2-43be386bf376', 6, 'F', false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6521b9d7-bd43-486d-87c2-bcdb3470db4a', '465b0cea-d621-42fa-a997-c4a87e3caab8', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-9
Which of following statements belongs to the visitor categories in the box
Please choose
A, B or C
for each question.
Write the correct letter
A, B or C,
in boxes
5-9
on your answer sheet.
NB: You may use any letter more than once.
A
. Cheese Festival visitors
B
. Picnic visitors
C
. Both of them
———————
5
have focused destination
6
majority prepare well before going beforehand.
7
are comparably less keen on picnic meal
8
show interest in activities such as visiting factory tour and fruit
9
are willing to accept a variety of tour recommendation.

5 ____ have focused destination$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e7253e8-9ac7-4398-91d4-5ab06537fb9d', '6521b9d7-bd43-486d-87c2-bcdb3470db4a', 1, 'A', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b39a02cd-2a64-45b5-a550-d61c3903a9fe', '6521b9d7-bd43-486d-87c2-bcdb3470db4a', 2, 'B', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03321cd9-a613-43f9-b939-aaf4611a7928', '6521b9d7-bd43-486d-87c2-bcdb3470db4a', 3, 'C', false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a3104047-07d5-4b5b-8468-e167b7a893fe', '465b0cea-d621-42fa-a997-c4a87e3caab8', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-9
Which of following statements belongs to the visitor categories in the box
Please choose
A, B or C
for each question.
Write the correct letter
A, B or C,
in boxes
5-9
on your answer sheet.
NB: You may use any letter more than once.
A
. Cheese Festival visitors
B
. Picnic visitors
C
. Both of them
———————
5
have focused destination
6
majority prepare well before going beforehand.
7
are comparably less keen on picnic meal
8
show interest in activities such as visiting factory tour and fruit
9
are willing to accept a variety of tour recommendation.

6 ____ majority prepare well before going beforehand.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70a4e29e-bd2a-4c5d-88d7-9b5d751f6c48', 'a3104047-07d5-4b5b-8468-e167b7a893fe', 1, 'A', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('540e980e-b678-436e-86f8-fa3c97eff95f', 'a3104047-07d5-4b5b-8468-e167b7a893fe', 2, 'B', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8290668c-8826-4016-b4c8-32f27b387d67', 'a3104047-07d5-4b5b-8468-e167b7a893fe', 3, 'C', false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0943d4bf-89f6-4eeb-a9af-a61dbc9c4b06', '465b0cea-d621-42fa-a997-c4a87e3caab8', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-9
Which of following statements belongs to the visitor categories in the box
Please choose
A, B or C
for each question.
Write the correct letter
A, B or C,
in boxes
5-9
on your answer sheet.
NB: You may use any letter more than once.
A
. Cheese Festival visitors
B
. Picnic visitors
C
. Both of them
———————
5
have focused destination
6
majority prepare well before going beforehand.
7
are comparably less keen on picnic meal
8
show interest in activities such as visiting factory tour and fruit
9
are willing to accept a variety of tour recommendation.

7 ____ are comparably less keen on picnic meal$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('180bc44e-abce-449e-a81b-6bd8b5515386', '0943d4bf-89f6-4eeb-a9af-a61dbc9c4b06', 1, 'A', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb909d1a-ee0e-4edd-bcf3-5aea3b3cf17d', '0943d4bf-89f6-4eeb-a9af-a61dbc9c4b06', 2, 'B', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1a1ea92-44e7-4073-a080-959c921a2459', '0943d4bf-89f6-4eeb-a9af-a61dbc9c4b06', 3, 'C', false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('569004e6-c41c-475c-9a2b-e9c05c562f75', '465b0cea-d621-42fa-a997-c4a87e3caab8', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-9
Which of following statements belongs to the visitor categories in the box
Please choose
A, B or C
for each question.
Write the correct letter
A, B or C,
in boxes
5-9
on your answer sheet.
NB: You may use any letter more than once.
A
. Cheese Festival visitors
B
. Picnic visitors
C
. Both of them
———————
5
have focused destination
6
majority prepare well before going beforehand.
7
are comparably less keen on picnic meal
8
show interest in activities such as visiting factory tour and fruit
9
are willing to accept a variety of tour recommendation.

8 ____ show interest in activities such as visiting factory tour and fruit$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7391575e-896a-467e-9da2-eeca647d2e88', '569004e6-c41c-475c-9a2b-e9c05c562f75', 1, 'A', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('feedf1c8-48cf-4e63-aab3-16f87508f772', '569004e6-c41c-475c-9a2b-e9c05c562f75', 2, 'B', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c837bb52-b287-418d-8396-76e0173d76e5', '569004e6-c41c-475c-9a2b-e9c05c562f75', 3, 'C', true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('536e0131-02d9-4d39-b245-67ea5598238c', '465b0cea-d621-42fa-a997-c4a87e3caab8', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 5-9
Which of following statements belongs to the visitor categories in the box
Please choose
A, B or C
for each question.
Write the correct letter
A, B or C,
in boxes
5-9
on your answer sheet.
NB: You may use any letter more than once.
A
. Cheese Festival visitors
B
. Picnic visitors
C
. Both of them
———————
5
have focused destination
6
majority prepare well before going beforehand.
7
are comparably less keen on picnic meal
8
show interest in activities such as visiting factory tour and fruit
9
are willing to accept a variety of tour recommendation.

9 ____ are willing to accept a variety of tour recommendation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4084dc94-3d7b-471d-9ed3-08853265bdfb', '536e0131-02d9-4d39-b245-67ea5598238c', 1, 'A', true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a8a4a9a-15e2-4c3a-b435-5d18177c0a69', '536e0131-02d9-4d39-b245-67ea5598238c', 2, 'B', false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e48202b6-9bed-44b2-b6eb-61bbe8c9918f', '536e0131-02d9-4d39-b245-67ea5598238c', 3, 'C', false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2e8c07eb-963c-49ec-a065-19e0fa97a056', '465b0cea-d621-42fa-a997-c4a87e3caab8', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 10-14
Summary
Complete the following summary of the paragraphs of
Reading Passage 1
, using no more than two words from the
Reading Passage 1
for each answer. Write your answers in boxes
10-14
on your answer sheet.
Through farm tour, visitors can better understand significant issues such as
10
and enviroment. In autumn, Murphy organised
11
and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a
12
. In
Sinsinawa,
a large area of the farmland contains an orchard, cow etc which is managed and operated by
13
; Lewis said the project will probably bring extra
14
for local farmers.

Fill in blank **10** (no more than two words):

Through farm tour, visitors can better understand significant issues such as 10 ____ and enviroment. In autumn, Murphy organised 11 ____ and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a 12 ____ . In Sinsinawa, a large area of the farmland contains an orchard, cow etc which is managed and operated by 13 ____ ; Lewis said the project will probably bring extra 14 ____ for local farmers.$md$, $md$Expected answer: animal rights$md$, ARRAY['.*animal.*rights.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('029c95da-213a-4577-89c9-ea3586cfa025', '465b0cea-d621-42fa-a997-c4a87e3caab8', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 10-14
Summary
Complete the following summary of the paragraphs of
Reading Passage 1
, using no more than two words from the
Reading Passage 1
for each answer. Write your answers in boxes
10-14
on your answer sheet.
Through farm tour, visitors can better understand significant issues such as
10
and enviroment. In autumn, Murphy organised
11
and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a
12
. In
Sinsinawa,
a large area of the farmland contains an orchard, cow etc which is managed and operated by
13
; Lewis said the project will probably bring extra
14
for local farmers.

Fill in blank **11** (no more than two words):

Through farm tour, visitors can better understand significant issues such as 10 ____ and enviroment. In autumn, Murphy organised 11 ____ and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a 12 ____ . In Sinsinawa, a large area of the farmland contains an orchard, cow etc which is managed and operated by 13 ____ ; Lewis said the project will probably bring extra 14 ____ for local farmers.$md$, $md$Expected answer: workshops$md$, ARRAY['.*workshop.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d878ae12-4511-4daa-8628-e022b8faa8ab', '465b0cea-d621-42fa-a997-c4a87e3caab8', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 10-14
Summary
Complete the following summary of the paragraphs of
Reading Passage 1
, using no more than two words from the
Reading Passage 1
for each answer. Write your answers in boxes
10-14
on your answer sheet.
Through farm tour, visitors can better understand significant issues such as
10
and enviroment. In autumn, Murphy organised
11
and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a
12
. In
Sinsinawa,
a large area of the farmland contains an orchard, cow etc which is managed and operated by
13
; Lewis said the project will probably bring extra
14
for local farmers.

Fill in blank **12** (no more than two words):

Through farm tour, visitors can better understand significant issues such as 10 ____ and enviroment. In autumn, Murphy organised 11 ____ and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a 12 ____ . In Sinsinawa, a large area of the farmland contains an orchard, cow etc which is managed and operated by 13 ____ ; Lewis said the project will probably bring extra 14 ____ for local farmers.$md$, $md$Expected answer: picnic lunch$md$, ARRAY['.*picnic.*lunch.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1b862d32-593e-4817-99fe-4bc11590d0d5', '465b0cea-d621-42fa-a997-c4a87e3caab8', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 10-14
Summary
Complete the following summary of the paragraphs of
Reading Passage 1
, using no more than two words from the
Reading Passage 1
for each answer. Write your answers in boxes
10-14
on your answer sheet.
Through farm tour, visitors can better understand significant issues such as
10
and enviroment. In autumn, Murphy organised
11
and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a
12
. In
Sinsinawa,
a large area of the farmland contains an orchard, cow etc which is managed and operated by
13
; Lewis said the project will probably bring extra
14
for local farmers.

Fill in blank **13** (no more than two words):

Through farm tour, visitors can better understand significant issues such as 10 ____ and enviroment. In autumn, Murphy organised 11 ____ and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a 12 ____ . In Sinsinawa, a large area of the farmland contains an orchard, cow etc which is managed and operated by 13 ____ ; Lewis said the project will probably bring extra 14 ____ for local farmers.$md$, $md$Expected answer: Dominican Sisters$md$, ARRAY['.*dominican.*sisters.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0dc6d9b9-25e2-4b7b-98c4-4166f2fce0c4', '465b0cea-d621-42fa-a997-c4a87e3caab8', 14, 'SHORT_ANSWER', 'READING', 4, $md$### Question 14

Questions 10-14
Summary
Complete the following summary of the paragraphs of
Reading Passage 1
, using no more than two words from the
Reading Passage 1
for each answer. Write your answers in boxes
10-14
on your answer sheet.
Through farm tour, visitors can better understand significant issues such as
10
and enviroment. In autumn, Murphy organised
11
and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a
12
. In
Sinsinawa,
a large area of the farmland contains an orchard, cow etc which is managed and operated by
13
; Lewis said the project will probably bring extra
14
for local farmers.

Fill in blank **14** (no more than two words):

Through farm tour, visitors can better understand significant issues such as 10 ____ and enviroment. In autumn, Murphy organised 11 ____ and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a 12 ____ . In Sinsinawa, a large area of the farmland contains an orchard, cow etc which is managed and operated by 13 ____ ; Lewis said the project will probably bring extra 14 ____ for local farmers.$md$, $md$Expected answer: income$md$, ARRAY['.*income.*','.*incomes.*']);

COMMIT;