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

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('a4314c8a-2c64-5843-b729-cb6d51a598b5', 'ielts-reading-agriculture-and-tourism-1270', $t$Agriculture and Tourism$t$, $md$## Agriculture and Tourism

Nguồn:
- Test: https://mini-ielts.com/1270/reading/agriculture-and-tourism
- Solution: https://mini-ielts.com/1270/view-solution/reading/agriculture-and-tourism$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('83faeb2c-215d-540f-91c5-3e8e3770dbd8', 'a4314c8a-2c64-5843-b729-cb6d51a598b5', 1, $t$Reading — Agriculture and Tourism$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Agriculture and Tourism

A . Linkages between the Agri-Food Sector and Tourism offer significant opportunities for the development of both sectors within the region. These linkages could lead to ensuring the sustainability of the region’s tourism product thus ensuring it preservation. Agriculture and tourism — two of Wisconsin’s most industries — are teaming up in southwestern Wisconsin has found that tourists, rural communities, and some farmers could benefit from stronger efforts to promote and market agricultural tourism there. In 1990, agricultural tourism project members surveyed 290 visitors to the annual Monroe Cheese Festival and 164 visitors to the Picnic on the Farm, a one-time event held in Platteville in conjunction with the Chicago Bears summer training camp. More than one-half of those surveyed responded favorably to a proposed tour, saying they would be interested in participating in some type of agricultural tour in southwestern Wisconsin. Survey respondents reported that they would prefer to visit cheese factories, sausage processing plants, dairy farms, and historical farm sites, as well as enjoy an old-fashioned picnic dinner. The study also found strong interest in visiting specialty farms (strawberries, cranberries, poultry, etc.). More than 75 percent of the Cheese Day visitors planned ahead for the trip, with 37 percent planning at least two months in advance.

B . More than 40 percent of the visitors came to Monroe for two- or three-day visits. Many stopped at other communities on their way to Cheese Days. Visitors at both events indicated that they were there to enjoy themselves and were willing to spend money on food and arts and crafts. They also wanted the opportunity to experience the “country” while there. The study found that planning around existing events should take into account what brought visitors to the area and provide additional attractions that will appeal to them. For example, visitors to Cheese Days said they were on a holiday and appeared to be more open to various tour proposals. Picnic visitors came specifically to see the Chicago Bears practice. They showed less interest in a proposed agricultural tour than Cheese Day visitors, but more interest in a picnic dinner.

C . The study identified three primary audiences for agricultural tourism: 1) elderly people who take bus tours to see the country; 2) families interested in tours that could be enjoyed by both parents and children; and 3) persons already involved in agriculture, including international visitors. Agricultural tourism can serve to educate urban tourists about the problems and challenges facing farmers, says Andy Lewis, Grant county community development agent. While agriculture is vital to Wisconsin, more and more urban folk are becoming isolated from the industry. In fact, Lewis notes, farmers are just as interested in the educational aspects of agricultural tours as they are in any financial returns.

D . “Farmers feel that urban consumers are out of touch with farming,” Lewis says. “If tourists can be educated on issues that concern farmers, those visits could lead to policies more favorable to agriculture.” Animal rights and the environment are examples of two issues that concern both urban consumers and farmers. Farm tours could help consumers get the farmer’s perspective on these issues, Lewis notes. Several Wisconsin farms already offer some type of learning experience for tourists. However, most agricultural tourism enterprises currently market their businesses independently, leading to a lack of a concerted effort to promote agricultural tourism as an industry.

E . Lewis is conducting the study with Jean Murphy, assistant community development agent. Other participants include UW-Platteville Agricultural Economist Bob Acton, the Center for Integrated Agricultural Systems, UW-Extension Recreation Resources Center, the Wisconsin Rural Development Center, and Hidden Valleys, a Southwestern Wisconsin regional tourism organization. This past fall, Murphy organized several workshops with some Green and Grant County farmers, local business leaders, and motor coach tour operators to discuss how best to organize and put on farm tours. Committees were formed to look at the following: tour site evaluations, inventory of the area’s resources, tour marketing, and familiarization of tours. The fourth committee is organizing tours for people such as tour bus guides and local reporters to help better educate them about agricultural tourism. Green County farmers already have experience hosting visitors during the annual Monroe Cheese Days. Green county Tourism Director Larry Lindgren says these farmers are set to go ahead with more formal agricultural tours next year. The tours will combine a farm visit with a visit to a local cheese factory and a picnic lunch.

F . Another farm interested in hosting an organized tour is Sinsinawa, a 200-acre Grant County farm devoted to sustainable agriculture and run by the Dominican Sisters. Education plays a major role at the farm, which has an orchard, dairy and beef cows, and hogs. Farm tours could be combined with other activities in the area such as trips to the Mississippi River and/or visits to historical towns orlandmarks, Lewis says. The project will help expose farmers to the tourism industry and farm vacations as a way to possibly supplement incomes, he adds. While farm families probably wouldn’t make a lot of money through farm tours, they would be compensated for their time, says Lewis. Farmers could earn additional income through the sale of farm products, crafts, and recreational activities.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('14b6b182-a6e6-538b-9268-42c7c360446f', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-4
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
VALUES ('efc925b6-1f86-5c4c-8b2f-694a942f41de', '14b6b182-a6e6-538b-9268-42c7c360446f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a05e216-0d83-5f44-b137-e9f38c175747', '14b6b182-a6e6-538b-9268-42c7c360446f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f9a69e6-9c45-5d26-ae60-b80bf9cc8039', '14b6b182-a6e6-538b-9268-42c7c360446f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7de46c4-3f4e-5eac-9b43-0ef50ea55482', '14b6b182-a6e6-538b-9268-42c7c360446f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d358a9a7-cdeb-5142-ab63-ff67570d9e45', '14b6b182-a6e6-538b-9268-42c7c360446f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf1545cf-2d23-55c5-a90b-a734c1dcd4ef', '14b6b182-a6e6-538b-9268-42c7c360446f', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('15b72e18-4db4-56db-806b-35f2d34c552c', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-4
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
VALUES ('5cca7d92-fdc1-5d19-a7f0-287532429feb', '15b72e18-4db4-56db-806b-35f2d34c552c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bef2e266-9363-5d1b-891f-6401a3c54a30', '15b72e18-4db4-56db-806b-35f2d34c552c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f67a0781-f0a7-53f7-9160-a66a9574102c', '15b72e18-4db4-56db-806b-35f2d34c552c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db8035b2-20c6-5772-ad7c-be0f4e72b936', '15b72e18-4db4-56db-806b-35f2d34c552c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1ad8ea6-c330-5d9b-9cce-f6c59126aed9', '15b72e18-4db4-56db-806b-35f2d34c552c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad2510d4-f06c-59a4-b9f7-889c8e1f89bd', '15b72e18-4db4-56db-806b-35f2d34c552c', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('69811ea3-a6f2-5f58-bc20-57ecd6af03cc', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-4
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
VALUES ('3c7fb0de-1f3b-5b03-bc38-32f6852f06b9', '69811ea3-a6f2-5f58-bc20-57ecd6af03cc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03171502-c74e-5784-b407-c952aaaa238e', '69811ea3-a6f2-5f58-bc20-57ecd6af03cc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d9e106b-ea41-5f61-828b-740b1a06744c', '69811ea3-a6f2-5f58-bc20-57ecd6af03cc', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb242e88-79bf-5a30-b059-57a4df127355', '69811ea3-a6f2-5f58-bc20-57ecd6af03cc', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf856ea1-ed2b-5617-8469-b7953a02b8fe', '69811ea3-a6f2-5f58-bc20-57ecd6af03cc', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('803fa122-6ddf-589b-b422-80275c8d49fe', '69811ea3-a6f2-5f58-bc20-57ecd6af03cc', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('974fe248-09de-5b7c-98a5-2606f1201239', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-4
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
VALUES ('55fde783-dc09-51ae-9b06-32d3164a482f', '974fe248-09de-5b7c-98a5-2606f1201239', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('200a8726-03b1-5405-8d01-54702173af93', '974fe248-09de-5b7c-98a5-2606f1201239', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1af1bd2e-f802-59cb-9787-667e7755e649', '974fe248-09de-5b7c-98a5-2606f1201239', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9a13ec4-dc64-50db-93ad-9f48ca90e9c5', '974fe248-09de-5b7c-98a5-2606f1201239', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef125c20-c86f-5479-821d-182fd5804d64', '974fe248-09de-5b7c-98a5-2606f1201239', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e48bd28c-425a-57c0-9358-8f0a937eae04', '974fe248-09de-5b7c-98a5-2606f1201239', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('22e69b9b-25ad-5552-8030-0cdd85369266', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 5, 'CLASSIFICATION', 'READING', 3, $md$### Question 5

Questions 5-9
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
VALUES ('13335cd8-298c-50cf-8f3c-7a5d6523f976', '22e69b9b-25ad-5552-8030-0cdd85369266', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12827536-afb3-5cf3-8366-2c85b0f4e7f2', '22e69b9b-25ad-5552-8030-0cdd85369266', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('433433c3-1672-5cf5-ba10-a4e270bf3041', '22e69b9b-25ad-5552-8030-0cdd85369266', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c08a210b-7f69-5ca1-914d-4f3fa15c659e', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 6, 'CLASSIFICATION', 'READING', 3, $md$### Question 6

Questions 5-9
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
VALUES ('6d190ec9-f6c8-54d7-bd02-547190506e9a', 'c08a210b-7f69-5ca1-914d-4f3fa15c659e', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ae355d4-2a5b-5d4d-adbc-d91f5c97290d', 'c08a210b-7f69-5ca1-914d-4f3fa15c659e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f712715b-cd99-5c3b-928c-4947fc2470b3', 'c08a210b-7f69-5ca1-914d-4f3fa15c659e', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eb5a35f3-c923-5f35-a176-9a5308250354', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 7, 'CLASSIFICATION', 'READING', 3, $md$### Question 7

Questions 5-9
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
VALUES ('63d08bc9-7cc8-50c0-90c5-9c2f21a1ec4b', 'eb5a35f3-c923-5f35-a176-9a5308250354', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfeeac09-f173-531f-9a48-f677505af796', 'eb5a35f3-c923-5f35-a176-9a5308250354', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15341110-7116-5703-8aca-2cce7334c606', 'eb5a35f3-c923-5f35-a176-9a5308250354', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0c9d4178-cc07-5242-964d-d7a5679ab294', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 8, 'CLASSIFICATION', 'READING', 3, $md$### Question 8

Questions 5-9
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
VALUES ('a69a797f-1f9b-50de-9cb2-85d36c949e40', '0c9d4178-cc07-5242-964d-d7a5679ab294', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f30a4d7-5c41-5889-b877-d802c7ed4001', '0c9d4178-cc07-5242-964d-d7a5679ab294', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01cfda00-093e-565b-be98-c1cab04db6a0', '0c9d4178-cc07-5242-964d-d7a5679ab294', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aca53e20-861a-5216-9c11-c8a6562eef5a', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 9, 'CLASSIFICATION', 'READING', 3, $md$### Question 9

Questions 5-9
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
VALUES ('354bc1b1-8c4b-5347-89cb-3376a319a546', 'aca53e20-861a-5216-9c11-c8a6562eef5a', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9111491e-9d70-5110-b311-aeb1f55bd942', 'aca53e20-861a-5216-9c11-c8a6562eef5a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15ee4d6e-e400-5d24-9c9f-135d6338cf34', 'aca53e20-861a-5216-9c11-c8a6562eef5a', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c238149d-e800-587a-8018-d16f711d9ecb', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-14
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

Through farm tour, visitors can better understand significant issues such as 10 ____ and enviroment. In autumn, Murphy organised 11 ____ and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a 12 ____ . In Sinsinawa, a large area of the farmland contains an orchard, cow etc which is managed and operated by 13 ____ ; Lewis said the project will probably bring extra 14 ____ for local farmers.$md$, NULL, ARRAY['.*animal.*rights.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('49a8c4ca-e4d5-5f74-91ac-2da89831e005', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-14
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

Through farm tour, visitors can better understand significant issues such as 10 ____ and enviroment. In autumn, Murphy organised 11 ____ and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a 12 ____ . In Sinsinawa, a large area of the farmland contains an orchard, cow etc which is managed and operated by 13 ____ ; Lewis said the project will probably bring extra 14 ____ for local farmers.$md$, NULL, ARRAY['.*animal.*rights.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('574ae903-6e91-5f0d-a85b-dd7a1343b5b4', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-14
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

Through farm tour, visitors can better understand significant issues such as 10 ____ and enviroment. In autumn, Murphy organised 11 ____ and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a 12 ____ . In Sinsinawa, a large area of the farmland contains an orchard, cow etc which is managed and operated by 13 ____ ; Lewis said the project will probably bring extra 14 ____ for local farmers.$md$, NULL, ARRAY['.*animal.*rights.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7a22b9a9-08c1-5318-a72b-529b77517605', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-14
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

Through farm tour, visitors can better understand significant issues such as 10 ____ and enviroment. In autumn, Murphy organised 11 ____ and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a 12 ____ . In Sinsinawa, a large area of the farmland contains an orchard, cow etc which is managed and operated by 13 ____ ; Lewis said the project will probably bring extra 14 ____ for local farmers.$md$, NULL, ARRAY['.*animal.*rights.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7aae9f6f-1b07-5825-bebe-58d7f7e64547', '83faeb2c-215d-540f-91c5-3e8e3770dbd8', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 10-14
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

Through farm tour, visitors can better understand significant issues such as 10 ____ and enviroment. In autumn, Murphy organised 11 ____ and bring other participants together to develop local tour market. Larry Lindgren said the farmers already had experience of farm tours with factory visiting and a 12 ____ . In Sinsinawa, a large area of the farmland contains an orchard, cow etc which is managed and operated by 13 ____ ; Lewis said the project will probably bring extra 14 ____ for local farmers.$md$, NULL, ARRAY['.*animal.*rights.*']);

COMMIT;
