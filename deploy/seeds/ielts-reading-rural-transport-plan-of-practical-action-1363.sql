BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-rural-transport-plan-of-practical-action-1363'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-rural-transport-plan-of-practical-action-1363';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-rural-transport-plan-of-practical-action-1363';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-rural-transport-plan-of-practical-action-1363';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('e84f9f06-90e2-52c8-a846-59f751330644', 'ielts-reading-rural-transport-plan-of-practical-action-1363', $t$Rural transport plan of “Practical action”$t$, $md$## Rural transport plan of “Practical action”

Nguồn:
- Test: https://mini-ielts.com/1363/reading/rural-transport-plan-of-practical-action
- Solution: https://mini-ielts.com/1363/view-solution/reading/rural-transport-plan-of-practical-action$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6c970d53-026b-57d3-87c4-1a2e996439c1', 'e84f9f06-90e2-52c8-a846-59f751330644', 1, $t$Reading — Rural transport plan of “Practical action”$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Rural transport plan of “Practical action”

For more than 40 years, Practical Action has worked with poor communities to identify the types of transport that work best, taking into consideration culture, needs and skills. With our technical and practical support, isolated rural communities can design, build and maintain their own solutions.

A

Whilst the focus of National Development Plans in the transport sector lies heavily in the areas of extending road networks and bridges, there are still major gaps identified in addressing the needs of poorer communities. There is a need to develop and promote the sustainable use of alternative transport systems and intermediate means of transportation (IMTs) that complement the linkages of poor people with road networks and other socio-economic infrastructures to improve their livelihoods.

B

On the other hand, the development of all weathered roads (only 30 percent of the rural population have access to this so far) and motorable bridges are very costly for a country with a small and stagnant economy. In addition, these interventions are not always favourable in all geographical contexts environmentally, socially and economically. More than 60 percent of the network is concentrated in the lowland areas of the country. Although there are a number of alternative ways by which transportation and mobility needs of rural communities in the hills can be addressed, a lack of clear government focus and policies, lack of fiscal and economic incentives, lack of adequate technical knowledge and manufacturing capacities have led to under-development of this alternative transport sub-sector including the provision of IMTs.

C

One of the major causes of poverty is isolation. Improving the access and mobility of the isolated poor paves the way for access to markets, services and opportunities. By improving transport poorer people are able to access markets where they can buy or sell goods for income, and make better use of essential services such as health and education. No proper roads or vehicles mean women and children are forced to spend many hours each day attending to their most basic needs, such as collecting water and firewood. This valuable time could be used to tend crops, care for the family, study or develop small business ideas to generate much-needed income.

Road building

D

Without roads, rural communities are extremely restricted. Collecting water and firewood, and going to local markets is a huge task, therefore it is understandable that the construction of roads is a major priority for many rural communities. Practical Action is helping to improve rural access/transport infrastructures through the construction and rehabilitation of short rural roads, small bridges, culverts and other transport-related functions. The aim is to use methods that encourage community-driven development. This means villagers can improve their own lives through better access to markets, health care, education and other economic and social opportunities, as well as bringing improved services and supplies to the now-accessible villages.

Driving forward new ideas

E

Practical Action and the communities we work with are constantly crafting and honing new ideas to help poor people. Cycle trailers have practical business use too, helping people carry their goods, such as vegetables and charcoal, to markets for sale. Not only that, but those on the poverty-line can earn a decent income by making, maintaining and operating bicycle taxis. With Practical Action’s know-how, Sri Lanka communities have been able to start a bus service and maintain the roads along which it travels. The impact has been remarkable. This service has put an end to rural people’s social isolation. Quick and affordable, it gives them a reliable way to travel to the nearest town; and now their children can get an education, making it far more likely they’ll find a path out of poverty. Practical Action is also an active member of many national and regional networks through which exchange of knowledge and advocating based on action research are carried out and one conspicuous example is the Lanka Organic Agriculture Movement.

Sky-scraping transport system

F

For people who live in remote, mountainous areas, getting food to market in order to earn enough money to survive is a serious issue. The hills are so steep that travelling down them is dangerous. A porter can help but they are expensive, and it would still take hours or even a day. The journey can take so long that their goods start to perish and become worthless and less. Practical Action has developed an ingenious solution called an aerial ropeway. It can either operate by gravitation force or with the use of external power. The ropeway consists of two trolleys rolling over support tracks connected to a control cable in the middle which moves in a traditional flywheel system. The trolley at the top is loaded with goods and can take up to 120kg. This is pulled down to the station at the bottom, either by the force of gravity or by an external power. The other trolley at the bottom is, therefore, pulled upwards automatically. The external power can be produced by a micro-hydro system if access to an electricity grid is not an option.

Bringing people on board

G

Practical Action developed a two-wheeled iron trailer that can be attached (via a hitch behind the seat) to a bicycle and be used to carry heavy loads (up to around 200 kgs) of food, water or even passengers. People can now carry three times as much as before and still pedal the bicycle. The cycle trailers are used for transporting goods by local producers, as ambulances, as mobile shops, and even as mobile libraries. They are made in small village workshops from iron tubing, which is cut, bent, welded and drilled to make the frame and wheels. Modifications are also carried out to the trailers in these workshops at the request of the buyers. The two-wheeled ‘ambulance’ is made from moulded metal, with standard rubber-tyred wheels. The “bed” section can be padded with cushions to make the patient comfortable, while the “seat” section allows a family member to attend to the patient during transit. A dedicated bicycle is needed to pull the ambulance trailer, so that other community members do not need to go without the bicycles they depend on in their daily lives. A joining mechanism allows for easy removal and attachment. In response to user comments, a cover has been designed that can be added to give protection to the patient and attendant in poor weather. Made of treated cotton, the cover is durable and waterproof.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac069306-ab80-522c-9c80-44f4188cbd42', '6c970d53-026b-57d3-87c4-1a2e996439c1', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage ?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
A slow-developing economy often can not afford some road networks, especially for those used regardless of weather conditions.
2
Rural communities’ officials know how to improve alternative transport technically.
3
The primary aim for Practical Action to improve rural transport infrastructures is meant to increase the trade among villages.
4
Lanka Organic Agriculture Movement
provided service that Practical Action highly involved in.

1 ____ A slow-developing economy often can not afford some road networks, especially for those used regardless of weather conditions.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27e91895-194c-53f8-8c8e-b80d52cd2855', 'ac069306-ab80-522c-9c80-44f4188cbd42', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6157d87-60c3-5a97-b070-fbd22a2ce66d', 'ac069306-ab80-522c-9c80-44f4188cbd42', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3f4be16-9203-5d5a-8bce-509f20f1af66', 'ac069306-ab80-522c-9c80-44f4188cbd42', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d1c52ddd-a9d7-59fd-866e-4712f7773de0', '6c970d53-026b-57d3-87c4-1a2e996439c1', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage ?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
A slow-developing economy often can not afford some road networks, especially for those used regardless of weather conditions.
2
Rural communities’ officials know how to improve alternative transport technically.
3
The primary aim for Practical Action to improve rural transport infrastructures is meant to increase the trade among villages.
4
Lanka Organic Agriculture Movement
provided service that Practical Action highly involved in.

2 ____ Rural communities’ officials know how to improve alternative transport technically.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec0e28d2-4aba-577f-ae14-74e68b075c6f', 'd1c52ddd-a9d7-59fd-866e-4712f7773de0', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('296928e5-872c-5bb1-825e-8f4e73ab0b14', 'd1c52ddd-a9d7-59fd-866e-4712f7773de0', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('657ebb67-4f37-5d65-886b-d7c5d0a1607d', 'd1c52ddd-a9d7-59fd-866e-4712f7773de0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('488e19e6-e49f-51c7-b5ad-7801ef526390', '6c970d53-026b-57d3-87c4-1a2e996439c1', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage ?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
A slow-developing economy often can not afford some road networks, especially for those used regardless of weather conditions.
2
Rural communities’ officials know how to improve alternative transport technically.
3
The primary aim for Practical Action to improve rural transport infrastructures is meant to increase the trade among villages.
4
Lanka Organic Agriculture Movement
provided service that Practical Action highly involved in.

3 ____ The primary aim for Practical Action to improve rural transport infrastructures is meant to increase the trade among villages.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0801ba58-95af-55e2-b608-72c6bda43d06', '488e19e6-e49f-51c7-b5ad-7801ef526390', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd0edaca-6c21-5089-92a4-36057d7a16d7', '488e19e6-e49f-51c7-b5ad-7801ef526390', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcfcadc7-c679-5bb2-9ce3-d02f82597dfe', '488e19e6-e49f-51c7-b5ad-7801ef526390', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f3aa6bd6-5814-5aef-889b-e2067fc4d776', '6c970d53-026b-57d3-87c4-1a2e996439c1', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage ?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
A slow-developing economy often can not afford some road networks, especially for those used regardless of weather conditions.
2
Rural communities’ officials know how to improve alternative transport technically.
3
The primary aim for Practical Action to improve rural transport infrastructures is meant to increase the trade among villages.
4
Lanka Organic Agriculture Movement
provided service that Practical Action highly involved in.

4 ____ Lanka Organic Agriculture Movement provided service that Practical Action highly involved in.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22e683eb-e924-595f-a339-45d272de9e8c', 'f3aa6bd6-5814-5aef-889b-e2067fc4d776', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e3b81ce-9dd7-55cc-a13c-bd470790517a', 'f3aa6bd6-5814-5aef-889b-e2067fc4d776', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b222695-b98b-5f98-90a4-50e7a3b85d2e', 'f3aa6bd6-5814-5aef-889b-e2067fc4d776', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('420db2cc-208f-5732-8aa7-32f0d80eac3c', '6c970d53-026b-57d3-87c4-1a2e996439c1', 5, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
5
What is the first duty for many rural communities to reach unrestricted development?
5
6
What was one of the new ideas to help poor people carry their goods, such as vegetables and charcoal, to markets for sale?
6
7
What service has put an end to rural people’s social isolation in Sri Lanka?
7
8
What solution had been applied for people who live in remote mountainous areas getting food to market?
8

5 What is the first duty for many rural communities to reach unrestricted development? 5 ____$md$, NULL, ARRAY['.*construction.*of.*roads.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a1d85214-a373-539d-95ed-c4cd79249e04', '6c970d53-026b-57d3-87c4-1a2e996439c1', 6, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
5
What is the first duty for many rural communities to reach unrestricted development?
5
6
What was one of the new ideas to help poor people carry their goods, such as vegetables and charcoal, to markets for sale?
6
7
What service has put an end to rural people’s social isolation in Sri Lanka?
7
8
What solution had been applied for people who live in remote mountainous areas getting food to market?
8

6 What was one of the new ideas to help poor people carry their goods, such as vegetables and charcoal, to markets for sale? 6 ____$md$, NULL, ARRAY['.*cycle.*trailers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6872d831-503c-5026-b18e-8251d7da718a', '6c970d53-026b-57d3-87c4-1a2e996439c1', 7, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
5
What is the first duty for many rural communities to reach unrestricted development?
5
6
What was one of the new ideas to help poor people carry their goods, such as vegetables and charcoal, to markets for sale?
6
7
What service has put an end to rural people’s social isolation in Sri Lanka?
7
8
What solution had been applied for people who live in remote mountainous areas getting food to market?
8

7 What service has put an end to rural people’s social isolation in Sri Lanka? 7 ____$md$, NULL, ARRAY['.*a.*bus.*service.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('18ba3457-4399-5e5d-a21c-c6764270a6a5', '6c970d53-026b-57d3-87c4-1a2e996439c1', 8, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
5
What is the first duty for many rural communities to reach unrestricted development?
5
6
What was one of the new ideas to help poor people carry their goods, such as vegetables and charcoal, to markets for sale?
6
7
What service has put an end to rural people’s social isolation in Sri Lanka?
7
8
What solution had been applied for people who live in remote mountainous areas getting food to market?
8

8 What solution had been applied for people who live in remote mountainous areas getting food to market? 8 ____$md$, NULL, ARRAY['.*aerial.*ropeway.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bd45e8d1-a516-5469-903f-3fad4078d94a', '6c970d53-026b-57d3-87c4-1a2e996439c1', 9, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORD
S from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
Besides normal transport task, changes are also implemented to the trailers in these workshops at the request of the buyers when it was used on a medical emergency or a moveable
9
; ‘Ambulance’ is made from metal, with rubber wheels and drive-by another bicycle. When put with
10
in the two-wheeled ‘ambulance’, the patient can stay comfortable and which another
11
. can sit on caring for the patient in transport journey. In order to dismantle or attach other equipment, and assembling
12
is designed. Later, as users suggest,
13
has also been added to give protection to the patient.

Besides normal transport task, changes are also implemented to the trailers in these workshops at the request of the buyers when it was used on a medical emergency or a moveable 9 ____ ; ‘Ambulance’ is made from metal, with rubber wheels and drive-by another bicycle. When put with 10 ____ in the two-wheeled ‘ambulance’, the patient can stay comfortable and which another 11 ____ . can sit on caring for the patient in transport journey. In order to dismantle or attach other equipment, and assembling 12 ____ is designed. Later, as users suggest, 13 ____ has also been added to give protection to the patient.$md$, NULL, ARRAY['.*shops.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('27445f7a-8204-5035-8192-4d8123f68030', '6c970d53-026b-57d3-87c4-1a2e996439c1', 10, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORD
S from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
Besides normal transport task, changes are also implemented to the trailers in these workshops at the request of the buyers when it was used on a medical emergency or a moveable
9
; ‘Ambulance’ is made from metal, with rubber wheels and drive-by another bicycle. When put with
10
in the two-wheeled ‘ambulance’, the patient can stay comfortable and which another
11
. can sit on caring for the patient in transport journey. In order to dismantle or attach other equipment, and assembling
12
is designed. Later, as users suggest,
13
has also been added to give protection to the patient.

Besides normal transport task, changes are also implemented to the trailers in these workshops at the request of the buyers when it was used on a medical emergency or a moveable 9 ____ ; ‘Ambulance’ is made from metal, with rubber wheels and drive-by another bicycle. When put with 10 ____ in the two-wheeled ‘ambulance’, the patient can stay comfortable and which another 11 ____ . can sit on caring for the patient in transport journey. In order to dismantle or attach other equipment, and assembling 12 ____ is designed. Later, as users suggest, 13 ____ has also been added to give protection to the patient.$md$, NULL, ARRAY['.*shops.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4882c235-8c0b-5a97-b247-2d70619bfe9e', '6c970d53-026b-57d3-87c4-1a2e996439c1', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORD
S from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
Besides normal transport task, changes are also implemented to the trailers in these workshops at the request of the buyers when it was used on a medical emergency or a moveable
9
; ‘Ambulance’ is made from metal, with rubber wheels and drive-by another bicycle. When put with
10
in the two-wheeled ‘ambulance’, the patient can stay comfortable and which another
11
. can sit on caring for the patient in transport journey. In order to dismantle or attach other equipment, and assembling
12
is designed. Later, as users suggest,
13
has also been added to give protection to the patient.

Besides normal transport task, changes are also implemented to the trailers in these workshops at the request of the buyers when it was used on a medical emergency or a moveable 9 ____ ; ‘Ambulance’ is made from metal, with rubber wheels and drive-by another bicycle. When put with 10 ____ in the two-wheeled ‘ambulance’, the patient can stay comfortable and which another 11 ____ . can sit on caring for the patient in transport journey. In order to dismantle or attach other equipment, and assembling 12 ____ is designed. Later, as users suggest, 13 ____ has also been added to give protection to the patient.$md$, NULL, ARRAY['.*shops.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e740175b-38e1-53b2-a4cc-fa2db95bc48f', '6c970d53-026b-57d3-87c4-1a2e996439c1', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORD
S from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
Besides normal transport task, changes are also implemented to the trailers in these workshops at the request of the buyers when it was used on a medical emergency or a moveable
9
; ‘Ambulance’ is made from metal, with rubber wheels and drive-by another bicycle. When put with
10
in the two-wheeled ‘ambulance’, the patient can stay comfortable and which another
11
. can sit on caring for the patient in transport journey. In order to dismantle or attach other equipment, and assembling
12
is designed. Later, as users suggest,
13
has also been added to give protection to the patient.

Besides normal transport task, changes are also implemented to the trailers in these workshops at the request of the buyers when it was used on a medical emergency or a moveable 9 ____ ; ‘Ambulance’ is made from metal, with rubber wheels and drive-by another bicycle. When put with 10 ____ in the two-wheeled ‘ambulance’, the patient can stay comfortable and which another 11 ____ . can sit on caring for the patient in transport journey. In order to dismantle or attach other equipment, and assembling 12 ____ is designed. Later, as users suggest, 13 ____ has also been added to give protection to the patient.$md$, NULL, ARRAY['.*shops.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d581be2e-6495-5a42-abf2-8467d7356215', '6c970d53-026b-57d3-87c4-1a2e996439c1', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORD
S from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
Besides normal transport task, changes are also implemented to the trailers in these workshops at the request of the buyers when it was used on a medical emergency or a moveable
9
; ‘Ambulance’ is made from metal, with rubber wheels and drive-by another bicycle. When put with
10
in the two-wheeled ‘ambulance’, the patient can stay comfortable and which another
11
. can sit on caring for the patient in transport journey. In order to dismantle or attach other equipment, and assembling
12
is designed. Later, as users suggest,
13
has also been added to give protection to the patient.

Besides normal transport task, changes are also implemented to the trailers in these workshops at the request of the buyers when it was used on a medical emergency or a moveable 9 ____ ; ‘Ambulance’ is made from metal, with rubber wheels and drive-by another bicycle. When put with 10 ____ in the two-wheeled ‘ambulance’, the patient can stay comfortable and which another 11 ____ . can sit on caring for the patient in transport journey. In order to dismantle or attach other equipment, and assembling 12 ____ is designed. Later, as users suggest, 13 ____ has also been added to give protection to the patient.$md$, NULL, ARRAY['.*shops.*']);

COMMIT;
