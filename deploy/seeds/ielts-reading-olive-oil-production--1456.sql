BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-olive-oil-production--1456'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-olive-oil-production--1456';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-olive-oil-production--1456';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-olive-oil-production--1456';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('cfeeacce-fba1-5698-b758-136d5a5ff8f1', 'ielts-reading-olive-oil-production--1456', $t$Olive Oil Production$t$, $md$## Olive Oil Production

Nguồn:
- Test: https://mini-ielts.com/1456/reading/olive-oil-production-
- Solution: https://mini-ielts.com/1456/view-solution/reading/olive-oil-production-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('4f2e4216-e785-59fd-9c34-75b703684d3a', 'cfeeacce-fba1-5698-b758-136d5a5ff8f1', 1, $t$Reading — Olive Oil Production$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Olive Oil Production

Olive oil has been one of the staples of the Mediterranean diet for thousands of years and its popularity is growing rapidly in other parts of the world. It is one of the most versatile oils for cooking and it enhances the taste of many foods. Olive oil is the only type of vegetable/fruit oil that can be obtained from just pressing. Most other types of popular oils (corn, canola, etc.) must be processed in other ways to obtain the oil. Another important bonus is that olive oil has proven health benefits. Three basic grades of olive oil are most often available to the consumer: extra Virgin, Virgin and Olive Oil. In addition to the basic grades, olive oil differs from one country or region to another because of the types of olives that are grown, the harvesting methods, the time of the harvest, and the pressing techniques. These factors all contribute to the individual characteristics of the olive oil.

Olive trees must be properly cared for in order to achieve good economic yields. Care includes regular irrigation, pruning, fertilizing, and killing pests. Olives will survive on very poor sites with shallow soils but will grow very slowly and yield poorly. Deep soils tend to produce excessively vigorous trees, also with lower yields. The ideal site for olive oil production is a clay loam soil with good internal and surface drainage. Irrigation is necessary to produce heavy crops and avoid alternate bearing. The site must be free of hard winter frosts because wood damage will occur at temperatures below 15°F and a lengthy spell of freezing weather can ruin any chances for a decent crop. The growing season also must be warm enough so fruits mature before even light fall frosts (usually by early November) because of potential damage to the fruit and oil quality. Fortunately, olive trees are very hardy in hot summer temperatures and they are drought tolerant.

The best olive oils hold a certificate by an independent organization that authenticates the stone ground and cold pressed extraction process. In this process, olives are first harvested by hand at the proper stage of ripeness and maturity. Experts feel that hand harvesting, as opposed to mechanical harvesting, eliminates bruising of the fruit which causes tartness and oil acidity. The olives harvested are transferred daily to the mill. This is very important because this daily transfer minimizes the time spent between picking and pressing. Some extra virgin olive oil producers are known to transfer the olives by multi-ton trucks over long distances that expose the fragile fruit to crushing weight and the hot sun, which causes the olives to begin oxidizing and thus becoming acidic. In addition to the time lapse between harvesting and pressing, olive oil must be obtained using mechanical processes only to be considered virgin or extra virgin. If heat and/or chemical processes are used to produce the olive oil or if the time lapse is too long, it cannot be called virgin or extra virgin.

Once at the mill, the leaves are sucked away with air fans and the olives are washed with circulating potable water to remove all impurities. The first step of extraction is mashing the olives to create a paste. The oil, comprising 20% to 30% of the olive, is nestled in pockets within the fruit’s cells. The olives are crushed in a mill with two granite millstones rolling within a metal basin. Crushing and mixing the olives releases the oil from the cells of the olive without heating the paste. A side shutter on the mill’s basin allows the mixed olive paste to be discharged and applied to round mats. The mats are stacked and placed under the head of a hydraulic press frame that applies downward pressure and extracts the oil. The first pressing yields the superior quality oil, and the second and third pressings produce inferior quality oil. Some single estate producers collect the oil that results from just the initial crushing while many other producers use an additional step to extract more oil. The olive pulp is placed on mats constructed with hemp or polypropylene that are stacked and then pressed to squeeze the pulp. Oil and water filter through the mats to a collection tank below. The water and oil are then separated in a centrifuge.

Regardless of the method used for the first pressing, the temperature of the oil during production is extremely important in order to maintain the distinct characteristics of the oil. If the temperature of the oil climbs above 86ºF, it will be damaged and cannot be considered cold-pressed.

The first pressing oil contains the most “polyphenols”, substances that have been found to be powerful antioxidants capable of protecting against certain types of disease. The polyphenols are not the only substances in the olive with health-promoting effects, but they are quite unique when compared to other commonly used culinary oils such as sunflower and soy. It is these polyphenols that really set extra virgin olive oils apart from any other oil and any other form of olive oil. The more refined the olive oil is, the smaller the quantity of polyphenols.

The result of the producers’ efforts is a cold pressed extra virgin olive oil with high quality standards and organoleptic characteristics, which give the oil its health-protective and aromatic properties.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8be67937-b6d5-5b60-9bcc-d963a45df522', '4f2e4216-e785-59fd-9c34-75b703684d3a', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

QUESTIONS 1-4
QUESTIONS 1-4
Choose the correct letters
A
,
B
,
C
or
D
.
Write the correct letters in boxes 28 – 31 on your answer sheet.
1.
According to the text, which of the following does
NOT
affect the individual features of olive oils from different regions?
A
Olive varieties
B
Access to water
C
The date of the picking
D
Picking techniques28##qa
2.
According to the text, which of the following is
NOT
part of olive tree management?
A
Feeding
B
Careful watering
C
Replanting
D
Killing parasites
3.
According to the text, what is the main danger of frost?
A
The olives produced will be small in size
B
It kills the olive trees
C
The fruit won’t mature
D
Not enough fruit will be produced
4.
According to the text, which of the following does NOT affect the “extra virgin” olive oil certification?
A
Using water in the extraction process
B
Which pressing the oil is taken from
C
The time gap between tree and bottle
D
The temperature of the extraction process

Choose the correct letters A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2b83c634-d544-524b-937a-09f49a97272f', '4f2e4216-e785-59fd-9c34-75b703684d3a', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

QUESTIONS 1-4
QUESTIONS 1-4
Choose the correct letters
A
,
B
,
C
or
D
.
Write the correct letters in boxes 28 – 31 on your answer sheet.
1.
According to the text, which of the following does
NOT
affect the individual features of olive oils from different regions?
A
Olive varieties
B
Access to water
C
The date of the picking
D
Picking techniques28##qa
2.
According to the text, which of the following is
NOT
part of olive tree management?
A
Feeding
B
Careful watering
C
Replanting
D
Killing parasites
3.
According to the text, what is the main danger of frost?
A
The olives produced will be small in size
B
It kills the olive trees
C
The fruit won’t mature
D
Not enough fruit will be produced
4.
According to the text, which of the following does NOT affect the “extra virgin” olive oil certification?
A
Using water in the extraction process
B
Which pressing the oil is taken from
C
The time gap between tree and bottle
D
The temperature of the extraction process

Choose the correct letters A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('673938d4-9a49-5691-b2e3-98933c1e3882', '4f2e4216-e785-59fd-9c34-75b703684d3a', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

QUESTIONS 1-4
QUESTIONS 1-4
Choose the correct letters
A
,
B
,
C
or
D
.
Write the correct letters in boxes 28 – 31 on your answer sheet.
1.
According to the text, which of the following does
NOT
affect the individual features of olive oils from different regions?
A
Olive varieties
B
Access to water
C
The date of the picking
D
Picking techniques28##qa
2.
According to the text, which of the following is
NOT
part of olive tree management?
A
Feeding
B
Careful watering
C
Replanting
D
Killing parasites
3.
According to the text, what is the main danger of frost?
A
The olives produced will be small in size
B
It kills the olive trees
C
The fruit won’t mature
D
Not enough fruit will be produced
4.
According to the text, which of the following does NOT affect the “extra virgin” olive oil certification?
A
Using water in the extraction process
B
Which pressing the oil is taken from
C
The time gap between tree and bottle
D
The temperature of the extraction process

Choose the correct letters A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7dab0ceb-8d98-54b1-912a-b968c6d38506', '4f2e4216-e785-59fd-9c34-75b703684d3a', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

QUESTIONS 1-4
QUESTIONS 1-4
Choose the correct letters
A
,
B
,
C
or
D
.
Write the correct letters in boxes 28 – 31 on your answer sheet.
1.
According to the text, which of the following does
NOT
affect the individual features of olive oils from different regions?
A
Olive varieties
B
Access to water
C
The date of the picking
D
Picking techniques28##qa
2.
According to the text, which of the following is
NOT
part of olive tree management?
A
Feeding
B
Careful watering
C
Replanting
D
Killing parasites
3.
According to the text, what is the main danger of frost?
A
The olives produced will be small in size
B
It kills the olive trees
C
The fruit won’t mature
D
Not enough fruit will be produced
4.
According to the text, which of the following does NOT affect the “extra virgin” olive oil certification?
A
Using water in the extraction process
B
Which pressing the oil is taken from
C
The time gap between tree and bottle
D
The temperature of the extraction process

Choose the correct letters A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('412cae4c-e35c-516e-8208-fd2380df7a29', '4f2e4216-e785-59fd-9c34-75b703684d3a', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

QUESTIONS 5-7
QUESTIONS 5-7
Do the following statements agree with the information given in Reading Passage?
In boxes 5-7 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Olive trees don’t need a regular supply of water to survive.
6
No other cooking oils apart from olive oil contain polyphenols.
7
Damage to olives before they are pressed can affect the taste of the oil.

5 ____ Olive trees don’t need a regular supply of water to survive.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95d2e500-bd97-5847-9821-0c9686a3a17b', '412cae4c-e35c-516e-8208-fd2380df7a29', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae40e19d-3277-5e72-a027-aabf6768f4fb', '412cae4c-e35c-516e-8208-fd2380df7a29', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a5f7c6a-23d8-594d-bec0-6a7e78494ab8', '412cae4c-e35c-516e-8208-fd2380df7a29', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ffe8e229-6af2-5ee3-ba00-e5aba408f130', '4f2e4216-e785-59fd-9c34-75b703684d3a', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

QUESTIONS 5-7
QUESTIONS 5-7
Do the following statements agree with the information given in Reading Passage?
In boxes 5-7 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Olive trees don’t need a regular supply of water to survive.
6
No other cooking oils apart from olive oil contain polyphenols.
7
Damage to olives before they are pressed can affect the taste of the oil.

6 ____ No other cooking oils apart from olive oil contain polyphenols.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f782dcd-9e84-57bc-8d83-762071e80426', 'ffe8e229-6af2-5ee3-ba00-e5aba408f130', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ea35c70-2526-58e2-a6dd-26261e1ea4b5', 'ffe8e229-6af2-5ee3-ba00-e5aba408f130', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b660c4f3-a5e2-5b12-89cf-6b12c99a3b4e', 'ffe8e229-6af2-5ee3-ba00-e5aba408f130', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('470de1a6-fe15-5321-80e9-1928a9e77f1f', '4f2e4216-e785-59fd-9c34-75b703684d3a', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

QUESTIONS 5-7
QUESTIONS 5-7
Do the following statements agree with the information given in Reading Passage?
In boxes 5-7 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Olive trees don’t need a regular supply of water to survive.
6
No other cooking oils apart from olive oil contain polyphenols.
7
Damage to olives before they are pressed can affect the taste of the oil.

7 ____ Damage to olives before they are pressed can affect the taste of the oil.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bb4610f-9422-5d64-aa2a-4da7de1ae4c3', '470de1a6-fe15-5321-80e9-1928a9e77f1f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cac2f0d6-85b1-503e-baf3-10772b6283f9', '470de1a6-fe15-5321-80e9-1928a9e77f1f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bc59652-6747-5f92-9009-d343256b716e', '470de1a6-fe15-5321-80e9-1928a9e77f1f', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('499babd0-1d9c-58ec-b03d-a5bbc4ef4ca4', '4f2e4216-e785-59fd-9c34-75b703684d3a', 8, 'FORM_COMPLETION', 'READING', 3, $md$### Question 8

QUESTIONS 8-13
QUESTIONS 8-13
Complete the flow chart below.
Write your answers in boxes 8-13 on your answer sheet.
Use
NO MORE THAN THREE WORDS
from Passage for each answer.
The Olive Oil Production Process
Stage 1:
Olive trees should be planted in
8
earth with good drainage in a year round warm climate.
Stage 2:
Trees must be carefully irrigated and fertilized and
9
must be controlled
if you want to get
10
that will make you profit.
Stage 3:
Olives are crushed to form a
11
Stage 4:
The paste is put on round mats inside a
12
. Water is blended in with the paste as it’s pressed and a water/oil mixture escapes.
Stage 5:
Water is removed by a
13
process. The Oil is then bottled and distributed.

Stage 1: Olive trees should be planted in 8 ____ earth with good drainage in a year round warm climate.$md$, NULL, ARRAY['.*clay.*loam.*soil.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3afffd14-29f0-5765-a48a-9f5d14928088', '4f2e4216-e785-59fd-9c34-75b703684d3a', 9, 'FORM_COMPLETION', 'READING', 3, $md$### Question 9

QUESTIONS 8-13
QUESTIONS 8-13
Complete the flow chart below.
Write your answers in boxes 8-13 on your answer sheet.
Use
NO MORE THAN THREE WORDS
from Passage for each answer.
The Olive Oil Production Process
Stage 1:
Olive trees should be planted in
8
earth with good drainage in a year round warm climate.
Stage 2:
Trees must be carefully irrigated and fertilized and
9
must be controlled
if you want to get
10
that will make you profit.
Stage 3:
Olives are crushed to form a
11
Stage 4:
The paste is put on round mats inside a
12
. Water is blended in with the paste as it’s pressed and a water/oil mixture escapes.
Stage 5:
Water is removed by a
13
process. The Oil is then bottled and distributed.

Stage 2: Trees must be carefully irrigated and fertilized and 9 ____ must be controlled$md$, NULL, ARRAY['.*pests.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c0aff772-913a-5766-895c-02bcef4ab6fa', '4f2e4216-e785-59fd-9c34-75b703684d3a', 10, 'FORM_COMPLETION', 'READING', 4, $md$### Question 10

QUESTIONS 8-13
QUESTIONS 8-13
Complete the flow chart below.
Write your answers in boxes 8-13 on your answer sheet.
Use
NO MORE THAN THREE WORDS
from Passage for each answer.
The Olive Oil Production Process
Stage 1:
Olive trees should be planted in
8
earth with good drainage in a year round warm climate.
Stage 2:
Trees must be carefully irrigated and fertilized and
9
must be controlled
if you want to get
10
that will make you profit.
Stage 3:
Olives are crushed to form a
11
Stage 4:
The paste is put on round mats inside a
12
. Water is blended in with the paste as it’s pressed and a water/oil mixture escapes.
Stage 5:
Water is removed by a
13
process. The Oil is then bottled and distributed.

if you want to get 10 ____ that will make you profit.$md$, NULL, ARRAY['.*good.*economic.*yield.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7a06f87e-03f5-59ca-a99b-1792eea85466', '4f2e4216-e785-59fd-9c34-75b703684d3a', 11, 'FORM_COMPLETION', 'READING', 4, $md$### Question 11

QUESTIONS 8-13
QUESTIONS 8-13
Complete the flow chart below.
Write your answers in boxes 8-13 on your answer sheet.
Use
NO MORE THAN THREE WORDS
from Passage for each answer.
The Olive Oil Production Process
Stage 1:
Olive trees should be planted in
8
earth with good drainage in a year round warm climate.
Stage 2:
Trees must be carefully irrigated and fertilized and
9
must be controlled
if you want to get
10
that will make you profit.
Stage 3:
Olives are crushed to form a
11
Stage 4:
The paste is put on round mats inside a
12
. Water is blended in with the paste as it’s pressed and a water/oil mixture escapes.
Stage 5:
Water is removed by a
13
process. The Oil is then bottled and distributed.

Stage 3: Olives are crushed to form a 11 ____$md$, NULL, ARRAY['.*paste.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('56a75e28-f9aa-5d4c-9e8b-d6d15458cd85', '4f2e4216-e785-59fd-9c34-75b703684d3a', 12, 'FORM_COMPLETION', 'READING', 4, $md$### Question 12

QUESTIONS 8-13
QUESTIONS 8-13
Complete the flow chart below.
Write your answers in boxes 8-13 on your answer sheet.
Use
NO MORE THAN THREE WORDS
from Passage for each answer.
The Olive Oil Production Process
Stage 1:
Olive trees should be planted in
8
earth with good drainage in a year round warm climate.
Stage 2:
Trees must be carefully irrigated and fertilized and
9
must be controlled
if you want to get
10
that will make you profit.
Stage 3:
Olives are crushed to form a
11
Stage 4:
The paste is put on round mats inside a
12
. Water is blended in with the paste as it’s pressed and a water/oil mixture escapes.
Stage 5:
Water is removed by a
13
process. The Oil is then bottled and distributed.

Stage 4: The paste is put on round mats inside a 12 ____ . Water is blended in with the paste as it’s pressed and a water/oil mixture escapes.$md$, NULL, ARRAY['.*hydraulic.*press.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('77495123-d23e-5b91-a288-222110326dbc', '4f2e4216-e785-59fd-9c34-75b703684d3a', 13, 'FORM_COMPLETION', 'READING', 4, $md$### Question 13

QUESTIONS 8-13
QUESTIONS 8-13
Complete the flow chart below.
Write your answers in boxes 8-13 on your answer sheet.
Use
NO MORE THAN THREE WORDS
from Passage for each answer.
The Olive Oil Production Process
Stage 1:
Olive trees should be planted in
8
earth with good drainage in a year round warm climate.
Stage 2:
Trees must be carefully irrigated and fertilized and
9
must be controlled
if you want to get
10
that will make you profit.
Stage 3:
Olives are crushed to form a
11
Stage 4:
The paste is put on round mats inside a
12
. Water is blended in with the paste as it’s pressed and a water/oil mixture escapes.
Stage 5:
Water is removed by a
13
process. The Oil is then bottled and distributed.

Stage 5: Water is removed by a 13 ____ process. The Oil is then bottled and distributed.$md$, NULL, ARRAY['.*centrifuge.*']);

COMMIT;
