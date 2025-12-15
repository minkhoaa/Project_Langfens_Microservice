BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-2003-heatwave-1028'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-2003-heatwave-1028';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-2003-heatwave-1028';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-2003-heatwave-1028';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('8b5697a0-0741-561f-9fbd-78abc0a46ef5', 'ielts-reading-the-2003-heatwave-1028', $t$The 2003 Heatwave$t$, $md$## The 2003 Heatwave

Nguồn:
- Test: https://mini-ielts.com/1028/reading/the-2003-heatwave
- Solution: https://mini-ielts.com/1028/view-solution/reading/the-2003-heatwave$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('aa5a8c43-3d95-5d30-8e2a-bfb702efce92', '8b5697a0-0741-561f-9fbd-78abc0a46ef5', 1, $t$Reading — The 2003 Heatwave$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The 2003 Heatwave

| | The 2003 Heatwave It was the summer, scientists now realise, when global warming at last made itself unmistakably felt. We knew that summer 2003 was remarkable: Britain experienced its record high temperature and continental Europe saw forest fires raging out of control, great rivers drying to a trickle and thousands of heat-related deaths. But just how remarkable is only now becoming clear. The three months of June, July and August were the warmest ever recorded in western and central Europe, with record national highs in Portugal, Germany and Switzerland as well as in Britain. And they were the warmest by a very long way. Over a great rectangular block of the earth stretching from west of Paris to northern Italy, taking in Switzerland and southern Germany, the average temperature for the summer months was 3.78°C above the long-term norm , said the Climatic Research Unit (CRU) of the University of East Anglia in Norwich, which is one of the world's leading institutions for the monitoring and analysis of temperature records. That excess might not seem a lot until you are aware of the context - but then you realise it is enormous. There is nothing like this in previous data, anywhere. It is considered so exceptional that Professor Phil Jones, the CRU's director, is prepared to say openly - in a way few scientists have done before - that the 2003 extreme may be directly attributed, not to natural climate variability, but to global warming caused by human actions. Meteorologists have hitherto contented themselves with the formula that recent high temperatures are “consistent with predictions” of climate change. For the great block of the map - that stretching between 35-50N and 0-20E - the CRU has reliable temperature records dating back to 1781. Using as a baseline the average summer temperature recorded between 1961 and 1990, departures from the temperature norm, or “anomalies”, over the area as a whole can easily be plotted. As the graph shows, such is the variability of our climate that over the past 200 years, there have been at least half a dozen anomalies, in terms of excess temperature - the peaks on the graph denoting very hot years - approaching, or even exceeding, 2°C. But there has been nothing remotely like 2003, when the anomaly is nearly four degrees. “This is quite remarkable,’ Professor Jones told The Independent . “It’s very unusual in a statistical sense. If this series had a normal statistical distribution, you wouldn’t get this number. The return period [how often it could be expected to recur] would be something like one in a thousand years. If we look at an excess above the average of nearly four degrees, then perhaps nearly three degrees of that is natural variability, because we’ve seen that in past summers. But the final degree of it is likely to be due to global warming, caused by human actions .” The summer of 2003 has, in a sense, been one that climate scientists have long been expecting. Until now, the warming has been manifesting itself mainly in winters that have been less cold than in summers that have been much hotter. Last week, the United Nations predicted that winters were warming so quickly that winter sports would die out in Europe’s lower-level ski resorts. But sooner or later, the unprecedented hot summer was bound to come, and this year it did. One of the most dramatic features of the summer was the hot nights, especially in the first half of August. In Paris, the temperature never dropped below 23°C (73.4°F) at all between 7 and 14 August, and the city recorded its warmest-ever night on 11-12 August, when the mercury did not drop below 25.5°C (77.9°F). Germany recorded its warmest-ever night at Weinbiet in the Rhine Valley with a lowest figure of 27.6°C (80.6°F) on 13 August, and similar record-breaking nighttime temperatures were recorded in Switzerland and Italy. The 15,000 excess deaths in France during August, compared with previous years, have been related to the high night-time temperatures. The number gradually increased during the first 12 days of the month, peaking at about 2,000 per day on the night of 12-13 August, then fell off dramatically after 14 August when the minimum temperatures fell by about 5°C. The elderly were most affected, with a 70 per cent increase in mortality rate in those aged 75-94. For Britain, the year as a whole is likely to be the warmest ever recorded, but despite the high temperature record on 10 August, the summer itself - defined as the June, July and August period - still comes behind 1976 and 1995 , when there were longer periods of intense heat. “At the moment, the year is on course to be the third hottest ever in the global temperature record, which goes back to 1856 , behind 1998 and 2002 , but when all the records for October, November and December are collated, it might move into second place,' Professor Jones said. The ten hottest years in the record have all now occurred since 1990 . Professor Jones is in no doubt about the astonishing nature of European summer of 2003. “The temperatures recorded were out of all proportion to the previous record," he said. “It was the warmest summer in the past 500 years and probably way beyond that. It was enormously exceptional." His colleagues at the University of East Anglia's Tyndall Centre for Climate Change Research are now planning a special study of it. “It was a summer that has not been experienced before, either in terms of the temperature extremes that were reached, or the range and diversity of the impacts of the extreme heat," said the centre's executive director, Professor Mike Hulme. “It will certainly have left its mark on a number of countries, as to how they think and plan for climate change in the future, much as the 2000 floods have revolutionised the way the Government is thinking about flooding in the UK. The 2003 heatwave will have similar repercussions across Europe ."$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7b71249f-c025-503e-ba35-be13f8c853cb', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 1, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage? In boxes
1-6
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The average summer temperature in 2003 is almost 4 degrees higher than the average temperature of the past.
Locate
2
Global warming is caused by human activities.
Locate
3
Jones believes the temperature variation is within the normal range.
Locate
4
The temperature is measured twice a day in major cities.
5
There were milder winters rather than hotter summers before 2003.
Locate
6
Governments are building new high-altitude ski resorts.

1 ____ The average summer temperature in 2003 is almost 4 degrees higher than the average temperature of the past. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b0ed749-d2be-58d0-817f-e634af6873ff', '7b71249f-c025-503e-ba35-be13f8c853cb', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4c9882d-781a-580d-9992-b277e6801767', '7b71249f-c025-503e-ba35-be13f8c853cb', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('461a7498-4e5c-5669-931f-881120cedcc7', '7b71249f-c025-503e-ba35-be13f8c853cb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('18803a67-a454-5c48-9352-410a48c24a20', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 2, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage? In boxes
1-6
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The average summer temperature in 2003 is almost 4 degrees higher than the average temperature of the past.
Locate
2
Global warming is caused by human activities.
Locate
3
Jones believes the temperature variation is within the normal range.
Locate
4
The temperature is measured twice a day in major cities.
5
There were milder winters rather than hotter summers before 2003.
Locate
6
Governments are building new high-altitude ski resorts.

2 ____ Global warming is caused by human activities. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86ebcb05-1128-5920-a5e3-b81e5b5e3c41', '18803a67-a454-5c48-9352-410a48c24a20', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6d28287-d7bb-5b09-97b2-8e63ea1c655e', '18803a67-a454-5c48-9352-410a48c24a20', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb7fbf7b-9125-5e71-bad4-8d785a33ddc6', '18803a67-a454-5c48-9352-410a48c24a20', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('707f8631-f179-5f7b-87b0-9fc26e7ef194', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 3, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage? In boxes
1-6
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The average summer temperature in 2003 is almost 4 degrees higher than the average temperature of the past.
Locate
2
Global warming is caused by human activities.
Locate
3
Jones believes the temperature variation is within the normal range.
Locate
4
The temperature is measured twice a day in major cities.
5
There were milder winters rather than hotter summers before 2003.
Locate
6
Governments are building new high-altitude ski resorts.

3 ____ Jones believes the temperature variation is within the normal range. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('827b97e4-1992-5855-9fbd-6bbe08a67f93', '707f8631-f179-5f7b-87b0-9fc26e7ef194', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74fd76f8-1625-5b64-b59a-cca9fc525fa5', '707f8631-f179-5f7b-87b0-9fc26e7ef194', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7027317c-6f1d-5d38-a9d1-e7857f1d594c', '707f8631-f179-5f7b-87b0-9fc26e7ef194', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1f410ddf-65ae-53a2-a849-39ad5fb0ac0d', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage? In boxes
1-6
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The average summer temperature in 2003 is almost 4 degrees higher than the average temperature of the past.
Locate
2
Global warming is caused by human activities.
Locate
3
Jones believes the temperature variation is within the normal range.
Locate
4
The temperature is measured twice a day in major cities.
5
There were milder winters rather than hotter summers before 2003.
Locate
6
Governments are building new high-altitude ski resorts.

4 ____ The temperature is measured twice a day in major cities.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dc498cf-37e7-5161-b877-62a7ca440235', '1f410ddf-65ae-53a2-a849-39ad5fb0ac0d', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1576d075-9556-5237-a421-a0a8dea70e6c', '1f410ddf-65ae-53a2-a849-39ad5fb0ac0d', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b55901d-9940-51f6-9e24-d1d5632873aa', '1f410ddf-65ae-53a2-a849-39ad5fb0ac0d', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5f95c202-d49b-59a1-a2b6-bac34d9c6d98', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage? In boxes
1-6
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The average summer temperature in 2003 is almost 4 degrees higher than the average temperature of the past.
Locate
2
Global warming is caused by human activities.
Locate
3
Jones believes the temperature variation is within the normal range.
Locate
4
The temperature is measured twice a day in major cities.
5
There were milder winters rather than hotter summers before 2003.
Locate
6
Governments are building new high-altitude ski resorts.

5 ____ There were milder winters rather than hotter summers before 2003. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd535d88-c671-5a6a-b405-0d8213896bf1', '5f95c202-d49b-59a1-a2b6-bac34d9c6d98', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2885763f-b3d5-5700-a3e9-df95c6bac14c', '5f95c202-d49b-59a1-a2b6-bac34d9c6d98', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('995b1fe5-d4af-5fd1-8816-cdf9bc5c80e7', '5f95c202-d49b-59a1-a2b6-bac34d9c6d98', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e0940417-81d4-5836-8c74-365440a089ec', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage? In boxes
1-6
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The average summer temperature in 2003 is almost 4 degrees higher than the average temperature of the past.
Locate
2
Global warming is caused by human activities.
Locate
3
Jones believes the temperature variation is within the normal range.
Locate
4
The temperature is measured twice a day in major cities.
5
There were milder winters rather than hotter summers before 2003.
Locate
6
Governments are building new high-altitude ski resorts.

6 ____ Governments are building new high-altitude ski resorts.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73fc0f75-bcd8-5196-9d0c-d5e2d11dbb1e', 'e0940417-81d4-5836-8c74-365440a089ec', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e57bed1-7a16-51e8-a660-a68e60e132a7', 'e0940417-81d4-5836-8c74-365440a089ec', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22ace2e9-aaff-541b-aa18-a8f657c983ef', 'e0940417-81d4-5836-8c74-365440a089ec', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('45b19130-42c2-54a4-9cb8-421095b1e724', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 7-8
Questions 7-8
Answer the questions below using
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-8
on your answer sheet.
7.
What are the other two hottest years in Britain besides 2003?
Locate
8.
What will also influence government policies in the future like the hot summer in 2003?
Locate

7. What are the other two hottest years in Britain besides 2003? ____ Locate$md$, NULL, ARRAY['.*1976.*1995.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7ef6639e-2bdb-5c6a-92dc-099b83f0755a', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 7-8
Questions 7-8
Answer the questions below using
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-8
on your answer sheet.
7.
What are the other two hottest years in Britain besides 2003?
Locate
8.
What will also influence government policies in the future like the hot summer in 2003?
Locate

8. What will also influence government policies in the future like the hot summer in 2003? ____ Locate$md$, NULL, ARRAY['.*2000.*floods.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cbc2a45d-14c4-5d16-9410-7fab49b0caa2', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-12
Questions 9-12
Complete the summary below using
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
9-12
on your answer sheet.
9.
The other two hottest years around the globe were
.
Locate
10.
The ten hottest years on record all come after the year
Locate
.
11.
This temperature data has been gathered since
Locate
.
12.
Thousands of people died in the country of
Locate
.

9. The other two hottest years around the globe were ____ . Locate$md$, NULL, ARRAY['.*1998.*and.*2002.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('860636ad-4749-5dd6-a159-f935a0b2d56f', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-12
Questions 9-12
Complete the summary below using
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
9-12
on your answer sheet.
9.
The other two hottest years around the globe were
.
Locate
10.
The ten hottest years on record all come after the year
Locate
.
11.
This temperature data has been gathered since
Locate
.
12.
Thousands of people died in the country of
Locate
.

10. The ten hottest years on record all come after the year ____ Locate .$md$, NULL, ARRAY['.*1990.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5dcf09e8-e524-5cae-adad-ddb5a7ed5354', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-12
Questions 9-12
Complete the summary below using
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
9-12
on your answer sheet.
9.
The other two hottest years around the globe were
.
Locate
10.
The ten hottest years on record all come after the year
Locate
.
11.
This temperature data has been gathered since
Locate
.
12.
Thousands of people died in the country of
Locate
.

11. This temperature data has been gathered since ____ Locate .$md$, NULL, ARRAY['.*1856.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('42f01808-631c-57c8-829f-4623d3ddce1d', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-12
Questions 9-12
Complete the summary below using
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
9-12
on your answer sheet.
9.
The other two hottest years around the globe were
.
Locate
10.
The ten hottest years on record all come after the year
Locate
.
11.
This temperature data has been gathered since
Locate
.
12.
Thousands of people died in the country of
Locate
.

12. Thousands of people died in the country of ____ Locate .$md$, NULL, ARRAY['.*france.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c053bccf-a792-52c1-a30d-38fd800c36c1', 'aa5a8c43-3d95-5d30-8e2a-bfb702efce92', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 13
Questions 13
Choose the correct letter
A, B, C
or
D
.
Write your answer in box
13
on your answer sheet.
13.
Which one of the following can be best used as the title of this passage?
A
Global Warming
B
What Caused Global Warming
C
The Effects of Global Warming
D
That Hot Year in Europe
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

COMMIT;
