BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-story-of-coffee-1520'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-story-of-coffee-1520';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-story-of-coffee-1520';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-story-of-coffee-1520';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('88a53253-7988-5235-a1eb-3cbd4d3ab797', 'ielts-reading-the-story-of-coffee-1520', $t$THE STORY OF COFFEE$t$, $md$## THE STORY OF COFFEE

Nguồn:
- Test: https://mini-ielts.com/1520/reading/the-story-of-coffee
- Solution: https://mini-ielts.com/1520/view-solution/reading/the-story-of-coffee$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('91408c76-2a52-57d7-8213-aa808c278d88', '88a53253-7988-5235-a1eb-3cbd4d3ab797', 1, $t$Reading — THE STORY OF COFFEE$t$, $md$Read the passage and answer questions **1–13**.

### Passage: THE STORY OF COFFEE

A

Coffee was first discovered in Eastern Africa in an area we know today as Ethiopia. A popular legend refers to a goat herder by the name of Kaldi, who observed his goats acting unusually friskily after eating berries from a bush. Curious about this phenomenon, Kaldi tried eating the berries himself. He found that these berries gave him renewed energy.

B

The news of this energy laden fruit quickly moved throughout the region. Coffee berries were transported from Ethiopia to the Arabian Peninsula, and were first cultivated in what today is the country of Yemen. Coffee remained a secret in Arabia before spreading to Turkey and then to the European continent by means of Venetian trade merchants.

C

Coffee was first eaten as a food though later people in Arabia would make a drink out of boiling the beans for its narcotic effects and medicinal value. Coffee for a time was known as Arabian wine to Muslims who were banned from alcohol by Islam. It was not until after coffee had been eaten as a food product, a wine and a medicine that it was discovered, probably by complete accident in Turkey, that by roasting the beans a delicious drink could be made. The roasted beans were first crushed and then boiled in water, creating a crude version of the beverage we enjoy today. The first coffee houses were opened in Europe in the 17th Century and in 1675, the Viennese established the habit of refining the brew by filtering out the grounds, sweetening it, and adding a dash of milk.

D

If you were to explore the planet for coffee, you would find about 60 species of coffee plants growing wild in Africa, Malaysia, and other regions. But only about ten of them are actually cultivated. Of these ten, two species are responsible for almost all the coffee produced in the world: Coffea Arabica and Coffea Canephora (usually known as Robusta). Because of ecological differences existing among the various coffee producing countries, both types have undergone many mutations and now exist in many sub-species.

E

Although wild plants can reach 10 - 12 metres in height, the plantation one reaches a height of around four metres. This makes the harvest and flowering easier, and cultivation more economical. The flowers are white and sweet-scented like the Spanish jasmine. Flowers give way to a red, darkish berry. At first sight, the fruit is like a big cherry both in size and in colour. The berry is coated with a thin, red film (epicarp) containing a white, sugary mucilaginous flesh (mesocarp). Inside the pulp there are the seeds in the form of two beans coupled at their flat surface. Beans are in turn coated with a kind of resistant, golden yellow parchment, (called endocarp). When peeled, the real bean appears with another very thin silvery film. The bean is bluish green verging on bronze, and is at the most 11 millimetres long and 8 millimetres wide.

F

Coffee plants need special conditions to give a satisfactory crop. The climate needs to be hot-wet or hot temperate, between the Tropic of Cancer and the Tropic of Capricorn, with frequent rains and temperatures varying from 15 to 25 Degrees C. The soil should be deep, hard, permeable, well irrigated, with well-drained subsoil. The best lands are the hilly ones or from just-tilled woods. The perfect altitude is between 600 and 1200 metres, though some varieties thrive at 2000-2200 metres. Cultivation aimed at protecting the plants at every stage of growth is needed. Sowing should be in sheltered nurseries from which, after about six months, the seedlings should be moved to plantations in the rainy season where they are usually alternated with other plants to shield them from wind and excessive sunlight. Only when the plant is five years old can it be counted upon to give a regular yield. This is between 400 grams and two kilos of arabica beans for each plant, and 600 grams and two kilos for robusta beans.

G

Harvesting time depends on the geographic situation and it can vary greatly therefore according to the various producing countries. First, the ripe beans are picked from the branches. Pickers can selectively pick approximately 250 to 300 pounds of coffee cherry a day. At the end of the day, the pickers bring their heavy burlap bags to pulping mills where the cherry coffee can be pulped (or wet milled). The pulped beans then rest, covered in pure rainwater to ferment overnight. The next day the wet beans are hand-distributed upon the drying floor to be sun dried. This drying process takes from one to two weeks depending on the amount of sunny days available. To make sure they dry evenly, the beans need to be raked many times during this drying time. Two weeks later the sun dried beans, now called parchment, are scooped up, bagged and taken to be milled. Huge milling machines then remove the parchment and silver skin, which renders a green bean suitable for roasting. The green beans are roasted according to the customers’ specifications and, after cooling, the beans are then packaged and mailed to customers.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('275ac54e-6216-5ca0-bc40-0daf7425adef', '91408c76-2a52-57d7-8213-aa808c278d88', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading passage on The Story of Coffee has
7
paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (
i – xi
) in boxes
1-6
on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
I.
Growing Coffee
ii
. Problems with Manufacture
iii
. Processing the Bean
iv
. First Contact
v.
Arabian Coffee
vi.
Coffee Varieties
vii.
Modern Coffee
viii.
The Spread of Coffee
ix
. Consuming Coffee
x
. Climates for Coffee
xi
. The Coffee Plant
Example
Answer
Paragraph A iv
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

1 ____ Paragraph B 2 ____ Paragraph C 3 ____ Paragraph D 4 ____ Paragraph E 5 ____ Paragraph F 6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e21ef56-5404-5fcd-8a18-cd0d931d663f', '275ac54e-6216-5ca0-bc40-0daf7425adef', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45da1bde-c3f2-538c-b259-1dad668fb70d', '275ac54e-6216-5ca0-bc40-0daf7425adef', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0add6d6-79e3-5c18-832f-e62951496ec7', '275ac54e-6216-5ca0-bc40-0daf7425adef', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc4fe8d0-a9a4-5d44-a7ab-88b8f7689bcc', '275ac54e-6216-5ca0-bc40-0daf7425adef', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dcadf39-fe8a-51f8-9d31-e97a817246c6', '275ac54e-6216-5ca0-bc40-0daf7425adef', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0c7ab2b-6a7b-55d6-aab8-3f043e6822fd', '275ac54e-6216-5ca0-bc40-0daf7425adef', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc961153-6b25-5cc2-98c0-dd9c9d60ddf4', '275ac54e-6216-5ca0-bc40-0daf7425adef', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38ff3836-3b6a-5562-a160-ff2aa90f2acf', '275ac54e-6216-5ca0-bc40-0daf7425adef', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8634fbe6-e955-52f0-8475-c44adbdff048', '275ac54e-6216-5ca0-bc40-0daf7425adef', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c216e541-f7f3-596f-91f2-c6bd487d31fb', '275ac54e-6216-5ca0-bc40-0daf7425adef', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81e47929-45bd-5ee7-bd49-136bb2b770f9', '275ac54e-6216-5ca0-bc40-0daf7425adef', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9805f40a-600b-5844-8319-2f9c21145b54', '91408c76-2a52-57d7-8213-aa808c278d88', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading passage on The Story of Coffee has
7
paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (
i – xi
) in boxes
1-6
on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
I.
Growing Coffee
ii
. Problems with Manufacture
iii
. Processing the Bean
iv
. First Contact
v.
Arabian Coffee
vi.
Coffee Varieties
vii.
Modern Coffee
viii.
The Spread of Coffee
ix
. Consuming Coffee
x
. Climates for Coffee
xi
. The Coffee Plant
Example
Answer
Paragraph A iv
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

1 ____ Paragraph B 2 ____ Paragraph C 3 ____ Paragraph D 4 ____ Paragraph E 5 ____ Paragraph F 6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71fa61b8-f4cc-5475-b532-517a2a2bc258', '9805f40a-600b-5844-8319-2f9c21145b54', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7fb20d7-aab0-5bd1-a492-9c085a1d4fa5', '9805f40a-600b-5844-8319-2f9c21145b54', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6f7a4b9-f08a-54e4-bd02-ece3d9ac5a78', '9805f40a-600b-5844-8319-2f9c21145b54', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f61d96e-e066-5cd5-896b-b6c8ba936496', '9805f40a-600b-5844-8319-2f9c21145b54', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7cb2f02-a9f1-547d-a8b6-53bcab355566', '9805f40a-600b-5844-8319-2f9c21145b54', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76b5c5f2-db68-5dce-8336-802b192b5324', '9805f40a-600b-5844-8319-2f9c21145b54', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff747164-a85c-5a53-a1c2-32dbe7fcbf25', '9805f40a-600b-5844-8319-2f9c21145b54', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('300e382a-8af1-5dd2-8781-c5b5be97650a', '9805f40a-600b-5844-8319-2f9c21145b54', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c3ea1c5-c3b7-5a27-b41e-3e66e036f14a', '9805f40a-600b-5844-8319-2f9c21145b54', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a592abee-4345-53b1-bbf3-fb443138619d', '9805f40a-600b-5844-8319-2f9c21145b54', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f804cbe-e269-5ce6-972c-6d7f320ed305', '9805f40a-600b-5844-8319-2f9c21145b54', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('260d6d54-3559-5995-bb5e-5fafd0546b44', '91408c76-2a52-57d7-8213-aa808c278d88', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading passage on The Story of Coffee has
7
paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (
i – xi
) in boxes
1-6
on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
I.
Growing Coffee
ii
. Problems with Manufacture
iii
. Processing the Bean
iv
. First Contact
v.
Arabian Coffee
vi.
Coffee Varieties
vii.
Modern Coffee
viii.
The Spread of Coffee
ix
. Consuming Coffee
x
. Climates for Coffee
xi
. The Coffee Plant
Example
Answer
Paragraph A iv
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

1 ____ Paragraph B 2 ____ Paragraph C 3 ____ Paragraph D 4 ____ Paragraph E 5 ____ Paragraph F 6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a67a8f08-1594-5d65-a1f9-30c572994902', '260d6d54-3559-5995-bb5e-5fafd0546b44', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca05fe7c-6483-59fb-ac40-8ff829e913c2', '260d6d54-3559-5995-bb5e-5fafd0546b44', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8292a47-ee93-52a3-8c8b-507d07e35f16', '260d6d54-3559-5995-bb5e-5fafd0546b44', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c44a4683-2ebb-5b2c-9c7f-1da341779763', '260d6d54-3559-5995-bb5e-5fafd0546b44', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5a805d2-cf44-513f-9633-1e7371433779', '260d6d54-3559-5995-bb5e-5fafd0546b44', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03881ae5-cd87-51fb-a2ae-3ef1e04fe823', '260d6d54-3559-5995-bb5e-5fafd0546b44', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7bd14e9-4b03-5b0c-aff1-82e0a86d6df4', '260d6d54-3559-5995-bb5e-5fafd0546b44', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d4f0bb6-2545-5232-87fd-f73941ca1633', '260d6d54-3559-5995-bb5e-5fafd0546b44', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19d0a9b0-ca7d-573a-8118-7cd279eaee0b', '260d6d54-3559-5995-bb5e-5fafd0546b44', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f48ce4be-ee64-5042-bafd-ad50a611a302', '260d6d54-3559-5995-bb5e-5fafd0546b44', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2bf5b46-cd12-53e6-9cb4-cefb9e0d7311', '260d6d54-3559-5995-bb5e-5fafd0546b44', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d096f186-b6c9-56d5-8afc-8997c9eb4b90', '91408c76-2a52-57d7-8213-aa808c278d88', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading passage on The Story of Coffee has
7
paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (
i – xi
) in boxes
1-6
on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
I.
Growing Coffee
ii
. Problems with Manufacture
iii
. Processing the Bean
iv
. First Contact
v.
Arabian Coffee
vi.
Coffee Varieties
vii.
Modern Coffee
viii.
The Spread of Coffee
ix
. Consuming Coffee
x
. Climates for Coffee
xi
. The Coffee Plant
Example
Answer
Paragraph A iv
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

1 ____ Paragraph B 2 ____ Paragraph C 3 ____ Paragraph D 4 ____ Paragraph E 5 ____ Paragraph F 6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31cd82af-4bd1-5a7c-a18b-fe5ba13e8ff8', 'd096f186-b6c9-56d5-8afc-8997c9eb4b90', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4038722-9ca1-5cf4-9afa-8d8182a75efa', 'd096f186-b6c9-56d5-8afc-8997c9eb4b90', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ddd441e-7f5a-53f1-a592-7fbcfb73f3af', 'd096f186-b6c9-56d5-8afc-8997c9eb4b90', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('680acf38-dc54-562f-a0c5-e99e1c99714a', 'd096f186-b6c9-56d5-8afc-8997c9eb4b90', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('475f6453-048c-5bee-aef2-31b8abf1a610', 'd096f186-b6c9-56d5-8afc-8997c9eb4b90', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69cf52b3-54c2-50dd-b08c-e26e6c0c9e8c', 'd096f186-b6c9-56d5-8afc-8997c9eb4b90', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c61418c8-5e51-554f-af54-4443ea89f152', 'd096f186-b6c9-56d5-8afc-8997c9eb4b90', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03f1968b-9a66-5ada-9455-e3fe6d5b350b', 'd096f186-b6c9-56d5-8afc-8997c9eb4b90', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8dd2127-aef7-54cd-b7e7-b90c1c11aa81', 'd096f186-b6c9-56d5-8afc-8997c9eb4b90', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3619d356-1ca7-529a-9fd2-4281788542d0', 'd096f186-b6c9-56d5-8afc-8997c9eb4b90', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72886599-0a03-55ce-b86b-52e8b2b6677e', 'd096f186-b6c9-56d5-8afc-8997c9eb4b90', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6d5fd78c-e0c7-57b7-a854-d0222daccd9e', '91408c76-2a52-57d7-8213-aa808c278d88', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading passage on The Story of Coffee has
7
paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (
i – xi
) in boxes
1-6
on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
I.
Growing Coffee
ii
. Problems with Manufacture
iii
. Processing the Bean
iv
. First Contact
v.
Arabian Coffee
vi.
Coffee Varieties
vii.
Modern Coffee
viii.
The Spread of Coffee
ix
. Consuming Coffee
x
. Climates for Coffee
xi
. The Coffee Plant
Example
Answer
Paragraph A iv
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

1 ____ Paragraph B 2 ____ Paragraph C 3 ____ Paragraph D 4 ____ Paragraph E 5 ____ Paragraph F 6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb5be1d8-4ef1-56cf-9d54-728a860afe6b', '6d5fd78c-e0c7-57b7-a854-d0222daccd9e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f15ca645-19a0-5c09-b309-789127863e7d', '6d5fd78c-e0c7-57b7-a854-d0222daccd9e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e173f3fb-5bb0-516c-87e9-08b9337525d6', '6d5fd78c-e0c7-57b7-a854-d0222daccd9e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ea26c40-4dc0-54e6-a417-5307b08bf825', '6d5fd78c-e0c7-57b7-a854-d0222daccd9e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db7da390-138b-55ed-8fd2-0e6fd5f41b58', '6d5fd78c-e0c7-57b7-a854-d0222daccd9e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3220402f-cd35-514e-91ff-b1450642aed8', '6d5fd78c-e0c7-57b7-a854-d0222daccd9e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b751a996-fdf0-5c0b-b1e9-78e130df30a2', '6d5fd78c-e0c7-57b7-a854-d0222daccd9e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f94d785-7f4a-5cf3-b9f5-ff7471e19242', '6d5fd78c-e0c7-57b7-a854-d0222daccd9e', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae84ddca-af97-5098-9648-20b8215204af', '6d5fd78c-e0c7-57b7-a854-d0222daccd9e', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('590690a7-5fdc-5824-aa76-74e8b8394fcb', '6d5fd78c-e0c7-57b7-a854-d0222daccd9e', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d45d3bf8-8061-53fb-9247-6fb8fcb2b8a6', '6d5fd78c-e0c7-57b7-a854-d0222daccd9e', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0ec70afb-2e48-521b-9026-113444ec8b0f', '91408c76-2a52-57d7-8213-aa808c278d88', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading passage on The Story of Coffee has
7
paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (
i – xi
) in boxes
1-6
on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
I.
Growing Coffee
ii
. Problems with Manufacture
iii
. Processing the Bean
iv
. First Contact
v.
Arabian Coffee
vi.
Coffee Varieties
vii.
Modern Coffee
viii.
The Spread of Coffee
ix
. Consuming Coffee
x
. Climates for Coffee
xi
. The Coffee Plant
Example
Answer
Paragraph A iv
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

1 ____ Paragraph B 2 ____ Paragraph C 3 ____ Paragraph D 4 ____ Paragraph E 5 ____ Paragraph F 6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ed9f557-e80a-54f3-a0ed-62b027163e2c', '0ec70afb-2e48-521b-9026-113444ec8b0f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffbc1d30-6c88-5ffe-90d6-4668b634e67d', '0ec70afb-2e48-521b-9026-113444ec8b0f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c28adfab-97af-590a-bf76-95d60a6fda17', '0ec70afb-2e48-521b-9026-113444ec8b0f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38a3bfbd-2865-5571-83fc-80d2f0cdab01', '0ec70afb-2e48-521b-9026-113444ec8b0f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9a09e45-3dbb-55cd-9a4c-2b73db7a79c4', '0ec70afb-2e48-521b-9026-113444ec8b0f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d71962ea-a12f-5a21-ab06-70a75306ec3a', '0ec70afb-2e48-521b-9026-113444ec8b0f', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('055ccdbe-f40c-5bc3-b1e1-1714afdfb59c', '0ec70afb-2e48-521b-9026-113444ec8b0f', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5904a795-903d-543b-adcf-edcd6324226b', '0ec70afb-2e48-521b-9026-113444ec8b0f', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa7a77eb-06a5-5459-ad1b-53f069629f5a', '0ec70afb-2e48-521b-9026-113444ec8b0f', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6adefe09-3f0c-5aa8-b652-3d448692795a', '0ec70afb-2e48-521b-9026-113444ec8b0f', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51002eee-1c4b-53b2-9496-643b417e44c2', '0ec70afb-2e48-521b-9026-113444ec8b0f', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('91c169e0-8ab7-511d-97c3-3c4d5153ba07', '91408c76-2a52-57d7-8213-aa808c278d88', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Complete the labels on the diagram of a coffee bean below.
Choose your answers from the text and write them in boxes
7-9
on your answer sheet.
7
8
9

7 ____$md$, NULL, ARRAY['.*epicarp.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8fe10ef5-a8f0-57b2-aa8c-104d62a382b1', '91408c76-2a52-57d7-8213-aa808c278d88', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Complete the labels on the diagram of a coffee bean below.
Choose your answers from the text and write them in boxes
7-9
on your answer sheet.
7
8
9

8 ____$md$, NULL, ARRAY['.*mesocarp.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('697a8052-ae50-587c-9512-6e08e4772086', '91408c76-2a52-57d7-8213-aa808c278d88', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Complete the labels on the diagram of a coffee bean below.
Choose your answers from the text and write them in boxes
7-9
on your answer sheet.
7
8
9

9 ____$md$, NULL, ARRAY['.*endocarp.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('af6261b8-f732-5cbc-9669-23b2c32b6ea3', '91408c76-2a52-57d7-8213-aa808c278d88', 10, 'FORM_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Using the information in the passage, complete the flowchart below.
Write your answers in boxes
10-13
on your answer sheet.
Use
NO MORE THAN THREE WORDS
from the passage for each answer.
Coffee Production Process
10
11
12
13

10 ____$md$, NULL, ARRAY['.*wet.*milled.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1c62bbe6-f7f4-57b4-a2f0-797a9b1ee8fd', '91408c76-2a52-57d7-8213-aa808c278d88', 11, 'FORM_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Using the information in the passage, complete the flowchart below.
Write your answers in boxes
10-13
on your answer sheet.
Use
NO MORE THAN THREE WORDS
from the passage for each answer.
Coffee Production Process
10
11
12
13

11 ____$md$, NULL, ARRAY['.*overnight.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f0f13e50-d1b4-55ca-bc36-aa3741357c6a', '91408c76-2a52-57d7-8213-aa808c278d88', 12, 'FORM_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Using the information in the passage, complete the flowchart below.
Write your answers in boxes
10-13
on your answer sheet.
Use
NO MORE THAN THREE WORDS
from the passage for each answer.
Coffee Production Process
10
11
12
13

12 ____$md$, NULL, ARRAY['.*raked.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('88b771f7-9f5e-516a-9ca2-10fb030ad9da', '91408c76-2a52-57d7-8213-aa808c278d88', 13, 'FORM_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Using the information in the passage, complete the flowchart below.
Write your answers in boxes
10-13
on your answer sheet.
Use
NO MORE THAN THREE WORDS
from the passage for each answer.
Coffee Production Process
10
11
12
13

13 ____$md$, NULL, ARRAY['.*customers.*specifications.*']);

COMMIT;
