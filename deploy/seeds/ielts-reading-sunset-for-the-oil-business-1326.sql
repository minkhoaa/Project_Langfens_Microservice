BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-sunset-for-the-oil-business-1326'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-sunset-for-the-oil-business-1326';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-sunset-for-the-oil-business-1326';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-sunset-for-the-oil-business-1326';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('59e50f50-e207-554c-8297-aa66f57c9b75', 'ielts-reading-sunset-for-the-oil-business-1326', $t$Sunset for the Oil Business$t$, $md$## Sunset for the Oil Business

Nguồn:
- Test: https://mini-ielts.com/1326/reading/sunset-for-the-oil-business
- Solution: https://mini-ielts.com/1326/view-solution/reading/sunset-for-the-oil-business$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('a11f7848-e734-534c-874f-ce645f3d90f7', '59e50f50-e207-554c-8297-aa66f57c9b75', 1, $t$Reading — Sunset for the Oil Business$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Sunset for the Oil Business

The world is about to run out of oil. Or perhaps not. It depends whom you believe…

A

Members of the Department Analysis Centre (ODAC) recently met in London and presented technical data that support their grim forecast that the world is perilously close to running out of oil. Leading lights of this moment, including the geologists Colin Campbell, rejected rival views presented by American geological survey and the international energy agency that contradicted their findings. Dr Campbell even decried the amazing display of ignorance, denial and obfuscation by government, industry and academics on this topic.

B

So is the oil really running out? The answer is easy: Yes. Nobody seriously disputes the notion that oil is, for all practical purposes, a non-renewable resource that will run out someday, be that years or decades away. The harder question is determining when precisely oil will begin to get scarce. And answering that question involves scaling Hubbert’s peak.

C

M. King Hubbert, a Shell geologist of legendary status among depletion experts, forecast in 1956 that oil production in the United States would peak in the early 1970s and then slowly decline, in something resembling a bell-shaped curve. At the time, his forecast was controversial, and many rubbished it. After 1970, however, empirical evidence proved him correct: oil production in America did indeed peak and has been in decline ever since.

D

Dr Hubbert’s analysis drew on the observation that oil production in a new area typically rises quickly at first, as the easiest and cheapest reserves are tapped. Over time, reservoirs age and go into decline, and so lifting oil becomes more expensive. Oil from that area then becomes less competitive in relation to other fuels, or to oil from other areas. As a result, production slows down and usually tapers off and declines. That, he argued, made for a bell-shaped curve.

E

His successful prediction has emboldened a new generation of geologists to apply his methodology on a global scale. Chief among them are the experts at ODAC, who worry that the global peak in production will come in the next decade. Dr Campbell used to argue that the peak should have come already; he now thinks it is just around the corner. A heavyweight has now joined this gloomy chorus. Kenneth Deffeyes of Princeton University argues in a lively new book (“The View from Hubbert’s Peak”) that global oil production could peak as soon as 2004.

F

That sharply contradicts mainstream thinking. America’s Geological Survey prepared an exhaustive study of oil depletion last year (in part to rebut Dr Campbell’s arguments) that put the peak of production some decades off. The IEA has just weighed in with its new “World Energy Outlook”, which foresees enough oil to comfortably meet the demand to 2020 from remaining reserves. René Dahan, one of ExxonMobil’s top managers, goes further: with an assurance characteristic of the world’s largest energy company, he insists that the world will be awash in oil for another 70 years.

G

Who is right? In making sense of these wildly opposing views, it is useful to look back at the pitiful history of oil forecasting. Doomsters have been predicting dry wells since the 1970s, but so far the oil is still gushing. Nearly all the predictions for 2000 made after the 1970s oil shocks were far too pessimistic. America’s Department of Energy thought that oil would reach $150 a barrel (at 2000 prices); even Exxon predicted a price of $100.

H

Michael Lynch of DRI-WEFA, an economic consultancy, is one of the few oil forecasters who has got things generally right. In a new paper, Dr Lynch analyses those historical forecasts. He finds evidence of both bias and recurring errors, which suggests that methodological mistakes (rather than just poor data) were the problem. In particular, he faults forecasters who used Hubbert-style analysis for relying on fixed estimates of how much “ultimately recoverable” oil there really is below ground, in the industry’s jargon: that figure, he insists, is actually a dynamic one, as improvements in infrastructure, knowledge and technology raise the amount of oil which is recoverable.

I

That points to what will probably determine whether the pessimists or the optimists are right: technological innovation. The first camp tends to be dismissive of claims of forthcoming technological revolutions in such areas as deep-water drilling and enhanced recovery. Dr Deffeyes captures this end-of-technology mindset well. He argues that because the industry has already spent billions on technology development, it makes it difficult to ask today for new technology, as most of the wheels have already been invented.

J

Yet techno-optimists argue that the technological revolution in oil has only just begun. Average recovery rates (how much of the known oil in a reservoir can actually be brought to the surface) are still only around 30-35%. Industry optimists believe that new techniques on the drawing board today could lift that figure to 50-60% within a decade.

K

Given the industry’s astonishing track record of innovation, it may be foolish to bet against it. That is the result of adversity: the nationalisations of the 1970s forced Big Oil to develop reserves in expensive, inaccessible places such as the North Sea and Alaska, undermining Dr Hubbert’s assumption that cheap reserves are developed first. The resulting upstream investments have driven down the cost of finding and developing wells over the last two decades from over $20 a barrel to around $6 a barrel. The cost of producing oil has fallen by half, to under $4 a barrel.

L

Such miracles will not come cheap, however, since much of the world’s oil is now produced in ageing fields that are rapidly declining. The IEA concludes that global oil production need not peak in the next two decades if the necessary investments are made. So how much is necessary? If oil companies are to replace the output lost at those ageing fields and meet the world’s ever-rising demand for oil, the agency reckons they must invest $1 trillion in non-OPEC countries over the next decade alone. That’s quite a figure.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f961365d-3bb1-5531-b885-4d2f6fb3e327', 'a11f7848-e734-534c-874f-ce645f3d90f7', 1, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage ?
In boxes 1-5
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Hubbert has a high-profile reputation amongst ODAC members.
2
Oil is likely to last longer than some other energy sources.
3
The majority of geologists believe that oil with start to run out sometime this decade.
4
Over 50 percent of the oil we know about is currently being recovered.
5
History has shown that some of Hubbert’s principles were mistaken.

1 ____ Hubbert has a high-profile reputation amongst ODAC members.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('390edcc4-be65-535e-8ff1-e9d172457243', 'f961365d-3bb1-5531-b885-4d2f6fb3e327', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63dbb0e6-446d-5fec-98cb-e77c29d51fb0', 'f961365d-3bb1-5531-b885-4d2f6fb3e327', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('582cdc83-e74d-5ed3-bdf9-e6dc2c74e187', 'f961365d-3bb1-5531-b885-4d2f6fb3e327', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c59a691-bc54-5b9e-8d5c-78587f983451', 'a11f7848-e734-534c-874f-ce645f3d90f7', 2, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage ?
In boxes 1-5
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Hubbert has a high-profile reputation amongst ODAC members.
2
Oil is likely to last longer than some other energy sources.
3
The majority of geologists believe that oil with start to run out sometime this decade.
4
Over 50 percent of the oil we know about is currently being recovered.
5
History has shown that some of Hubbert’s principles were mistaken.

2 ____ Oil is likely to last longer than some other energy sources.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ea4e997-e05c-5836-acd0-77f424247d10', '1c59a691-bc54-5b9e-8d5c-78587f983451', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e37775dc-676c-5215-bc2c-13a7817b8851', '1c59a691-bc54-5b9e-8d5c-78587f983451', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47340865-4d16-5a4e-970f-61c9308ee91c', '1c59a691-bc54-5b9e-8d5c-78587f983451', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8c83a7c9-18b0-5e99-bd29-154c76a58369', 'a11f7848-e734-534c-874f-ce645f3d90f7', 3, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage ?
In boxes 1-5
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Hubbert has a high-profile reputation amongst ODAC members.
2
Oil is likely to last longer than some other energy sources.
3
The majority of geologists believe that oil with start to run out sometime this decade.
4
Over 50 percent of the oil we know about is currently being recovered.
5
History has shown that some of Hubbert’s principles were mistaken.

3 ____ The majority of geologists believe that oil with start to run out sometime this decade.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4380d6fc-ddc9-5caa-b978-b0323154f2d3', '8c83a7c9-18b0-5e99-bd29-154c76a58369', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d64ba9b-5439-509f-b676-92a3f3beb1b7', '8c83a7c9-18b0-5e99-bd29-154c76a58369', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('397db050-45cc-5829-9584-94135bf4bc14', '8c83a7c9-18b0-5e99-bd29-154c76a58369', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('97b5fe9e-002d-5199-98da-4b1325a3d2cb', 'a11f7848-e734-534c-874f-ce645f3d90f7', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage ?
In boxes 1-5
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Hubbert has a high-profile reputation amongst ODAC members.
2
Oil is likely to last longer than some other energy sources.
3
The majority of geologists believe that oil with start to run out sometime this decade.
4
Over 50 percent of the oil we know about is currently being recovered.
5
History has shown that some of Hubbert’s principles were mistaken.

4 ____ Over 50 percent of the oil we know about is currently being recovered.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fb3bf35-753e-59a7-b243-09755b44fb09', '97b5fe9e-002d-5199-98da-4b1325a3d2cb', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2414268-29cc-5b74-831f-83ecdf2a1df5', '97b5fe9e-002d-5199-98da-4b1325a3d2cb', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d83461c8-2216-5fee-8011-8e519e0da809', '97b5fe9e-002d-5199-98da-4b1325a3d2cb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2dd54d4a-06a3-5bd3-b7b4-ac0232eb3f45', 'a11f7848-e734-534c-874f-ce645f3d90f7', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage ?
In boxes 1-5
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Hubbert has a high-profile reputation amongst ODAC members.
2
Oil is likely to last longer than some other energy sources.
3
The majority of geologists believe that oil with start to run out sometime this decade.
4
Over 50 percent of the oil we know about is currently being recovered.
5
History has shown that some of Hubbert’s principles were mistaken.

5 ____ History has shown that some of Hubbert’s principles were mistaken.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('256986bc-40e4-5a7c-970c-bfe1112b1260', '2dd54d4a-06a3-5bd3-b7b4-ac0232eb3f45', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa5b53b2-dbac-55c9-9050-a5f366e19d94', '2dd54d4a-06a3-5bd3-b7b4-ac0232eb3f45', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('278cde83-1240-563d-9f5b-ad469dbac431', '2dd54d4a-06a3-5bd3-b7b4-ac0232eb3f45', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d7997642-06c0-5902-8d21-e08aea557108', 'a11f7848-e734-534c-874f-ce645f3d90f7', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Complete the notes below
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
Many people believed Hubbert’s theory was
6
when it was originally presented.
(1) When an oilfield is
7
, it is easy to…
(2) The recovery of the oil gets more
8
as the reservoir gets older
(3) The oilfield can’t be as
9
as other areas.

Many people believed Hubbert’s theory was 6 ____ when it was originally presented.$md$, NULL, ARRAY['.*controversial.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('698f5058-9b51-59bb-afd0-aa170fd296c6', 'a11f7848-e734-534c-874f-ce645f3d90f7', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Complete the notes below
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
Many people believed Hubbert’s theory was
6
when it was originally presented.
(1) When an oilfield is
7
, it is easy to…
(2) The recovery of the oil gets more
8
as the reservoir gets older
(3) The oilfield can’t be as
9
as other areas.

(1) When an oilfield is 7 ____ , it is easy to…$md$, NULL, ARRAY['.*tapped.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('be775983-462f-58f9-bba6-8af17343da59', 'a11f7848-e734-534c-874f-ce645f3d90f7', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Complete the notes below
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
Many people believed Hubbert’s theory was
6
when it was originally presented.
(1) When an oilfield is
7
, it is easy to…
(2) The recovery of the oil gets more
8
as the reservoir gets older
(3) The oilfield can’t be as
9
as other areas.

(2) The recovery of the oil gets more 8 ____ as the reservoir gets older$md$, NULL, ARRAY['.*expensive.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('59c634b8-d8c0-5947-9e1d-e7e6ad545dcf', 'a11f7848-e734-534c-874f-ce645f3d90f7', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Complete the notes below
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
Many people believed Hubbert’s theory was
6
when it was originally presented.
(1) When an oilfield is
7
, it is easy to…
(2) The recovery of the oil gets more
8
as the reservoir gets older
(3) The oilfield can’t be as
9
as other areas.

(3) The oilfield can’t be as 9 ____ as other areas.$md$, NULL, ARRAY['.*competitive.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('59f4d483-c7d6-552d-ad39-898c4813ecc1', 'a11f7848-e734-534c-874f-ce645f3d90f7', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Look at the following statements (questions
10-14
) and the list of people below.
Match each statement with the correct person,
A-E
.
Write the correct letter,
A-E
in boxes
10-14
on your answer sheet.
NB
You may use any letter more than once
.
10
has found fault in the geological research procedure
11
has provided the longest-range forecast regarding oil supply
12
has convinced others that oil production will follow a particular model
13
has accused fellow scientists of refusing to see the truth
14
has expressed doubt over whether improved methods of extracting oil are possible.
List of People
A
Colin Campell
B
M. King Hubbert
C
Kenneth Deffeyes
D
Rene Dahan
E
Michael Lynch

10 ____ has found fault in the geological research procedure$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36eeafef-f0dd-5725-ad5c-1fc04c489ebd', '59f4d483-c7d6-552d-ad39-898c4813ecc1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e164de18-a839-5bb4-aab4-3866d9727b85', '59f4d483-c7d6-552d-ad39-898c4813ecc1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0b28daa-5104-555e-9e11-11024d1133e0', '59f4d483-c7d6-552d-ad39-898c4813ecc1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b702a64a-d71f-5256-b447-df1db79fb7a8', '59f4d483-c7d6-552d-ad39-898c4813ecc1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('537e7ede-5d1c-5979-955a-f68c083b10e0', '59f4d483-c7d6-552d-ad39-898c4813ecc1', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('991e4142-ea0c-52ec-b9a2-95a75fa5de4c', 'a11f7848-e734-534c-874f-ce645f3d90f7', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Look at the following statements (questions
10-14
) and the list of people below.
Match each statement with the correct person,
A-E
.
Write the correct letter,
A-E
in boxes
10-14
on your answer sheet.
NB
You may use any letter more than once
.
10
has found fault in the geological research procedure
11
has provided the longest-range forecast regarding oil supply
12
has convinced others that oil production will follow a particular model
13
has accused fellow scientists of refusing to see the truth
14
has expressed doubt over whether improved methods of extracting oil are possible.
List of People
A
Colin Campell
B
M. King Hubbert
C
Kenneth Deffeyes
D
Rene Dahan
E
Michael Lynch

11 ____ has provided the longest-range forecast regarding oil supply$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('842251ae-c708-57c9-9f6d-a65be4cd5a35', '991e4142-ea0c-52ec-b9a2-95a75fa5de4c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f0ce08e-ef4c-58f1-bcba-82e9e68e917f', '991e4142-ea0c-52ec-b9a2-95a75fa5de4c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eeff5400-7789-54ed-b5a6-17bfe7964690', '991e4142-ea0c-52ec-b9a2-95a75fa5de4c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cf93868-4b2c-527c-a305-e6722a3294ea', '991e4142-ea0c-52ec-b9a2-95a75fa5de4c', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a1414e9-4594-5cb0-b495-eb1670502ded', '991e4142-ea0c-52ec-b9a2-95a75fa5de4c', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e77105f8-0660-5133-8334-9cba6c6560db', 'a11f7848-e734-534c-874f-ce645f3d90f7', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Look at the following statements (questions
10-14
) and the list of people below.
Match each statement with the correct person,
A-E
.
Write the correct letter,
A-E
in boxes
10-14
on your answer sheet.
NB
You may use any letter more than once
.
10
has found fault in the geological research procedure
11
has provided the longest-range forecast regarding oil supply
12
has convinced others that oil production will follow a particular model
13
has accused fellow scientists of refusing to see the truth
14
has expressed doubt over whether improved methods of extracting oil are possible.
List of People
A
Colin Campell
B
M. King Hubbert
C
Kenneth Deffeyes
D
Rene Dahan
E
Michael Lynch

12 ____ has convinced others that oil production will follow a particular model$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0beb190b-65e3-5444-bf9f-45246be9ba7d', 'e77105f8-0660-5133-8334-9cba6c6560db', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc378b99-70a7-50b0-9ddd-6e8ae54dd4e9', 'e77105f8-0660-5133-8334-9cba6c6560db', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6de0d1bf-83f1-574d-ac4f-f0f135606798', 'e77105f8-0660-5133-8334-9cba6c6560db', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87f32094-752f-5794-954e-a38e2bbb9ddd', 'e77105f8-0660-5133-8334-9cba6c6560db', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c15fd21f-0394-520c-87d0-12b109229986', 'e77105f8-0660-5133-8334-9cba6c6560db', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('635fcc8b-55ce-5b31-9aee-451b53f22fca', 'a11f7848-e734-534c-874f-ce645f3d90f7', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Look at the following statements (questions
10-14
) and the list of people below.
Match each statement with the correct person,
A-E
.
Write the correct letter,
A-E
in boxes
10-14
on your answer sheet.
NB
You may use any letter more than once
.
10
has found fault in the geological research procedure
11
has provided the longest-range forecast regarding oil supply
12
has convinced others that oil production will follow a particular model
13
has accused fellow scientists of refusing to see the truth
14
has expressed doubt over whether improved methods of extracting oil are possible.
List of People
A
Colin Campell
B
M. King Hubbert
C
Kenneth Deffeyes
D
Rene Dahan
E
Michael Lynch

13 ____ has accused fellow scientists of refusing to see the truth$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06c3dd7b-448c-56d5-9bd1-a0967946f930', '635fcc8b-55ce-5b31-9aee-451b53f22fca', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20fef14e-04df-5517-aeaf-7847a4b04d25', '635fcc8b-55ce-5b31-9aee-451b53f22fca', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a0c4f73-8964-5545-914c-ebcca8cecd0d', '635fcc8b-55ce-5b31-9aee-451b53f22fca', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5f7c537-01ea-517f-b17d-839f1ecdb0c7', '635fcc8b-55ce-5b31-9aee-451b53f22fca', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('080c6db8-4a51-5a09-a125-a953e4e2af5d', '635fcc8b-55ce-5b31-9aee-451b53f22fca', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e713f3e-2195-5901-9242-89d6425ba796', 'a11f7848-e734-534c-874f-ce645f3d90f7', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Look at the following statements (questions
10-14
) and the list of people below.
Match each statement with the correct person,
A-E
.
Write the correct letter,
A-E
in boxes
10-14
on your answer sheet.
NB
You may use any letter more than once
.
10
has found fault in the geological research procedure
11
has provided the longest-range forecast regarding oil supply
12
has convinced others that oil production will follow a particular model
13
has accused fellow scientists of refusing to see the truth
14
has expressed doubt over whether improved methods of extracting oil are possible.
List of People
A
Colin Campell
B
M. King Hubbert
C
Kenneth Deffeyes
D
Rene Dahan
E
Michael Lynch

14 ____ has expressed doubt over whether improved methods of extracting oil are possible.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1011ab26-1b15-5a21-b974-d6862e2308f1', '6e713f3e-2195-5901-9242-89d6425ba796', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfb54ef4-5d2f-5bd8-a910-d047cf147276', '6e713f3e-2195-5901-9242-89d6425ba796', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('105be06c-c3a0-51dc-bbae-a8729795bfec', '6e713f3e-2195-5901-9242-89d6425ba796', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3670e0e-b6d4-5b5d-abbe-106a85cee2e1', '6e713f3e-2195-5901-9242-89d6425ba796', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42e9eb86-5663-53c3-bf8a-7555df3354dc', '6e713f3e-2195-5901-9242-89d6425ba796', 5, $md$E$md$, false);

COMMIT;
