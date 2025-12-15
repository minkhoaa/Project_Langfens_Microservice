BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-global-warming-in-new-zealand-2-1510'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-global-warming-in-new-zealand-2-1510';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-global-warming-in-new-zealand-2-1510';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-global-warming-in-new-zealand-2-1510';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('09e798de-39eb-50a3-817c-11427caab29c', 'ielts-reading-global-warming-in-new-zealand-2-1510', $t$Global Warming in New Zealand 2$t$, $md$## Global Warming in New Zealand 2

Nguồn:
- Test: https://mini-ielts.com/1510/reading/global-warming-in-new-zealand-2
- Solution: https://mini-ielts.com/1510/view-solution/reading/global-warming-in-new-zealand-2$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2e8f54ef-9b06-506b-8212-d58b9c9e82f1', '09e798de-39eb-50a3-817c-11427caab29c', 1, $t$Reading — Global Warming in New Zealand 2$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Global Warming in New Zealand 2

A

New Zealand is expected to warm by about 3°C over the next century. The northern polar regions will be more than 6°C warmer, while the large continents – also the largest centres of population – will be 4°C or warmer. In contrast, the Southern Ocean, which surrounds New Zealand, may warm by only 2°C. The sea will act as an air conditioner and in this aspect, New Zealand’s location is comparatively fortunate.

B

Any predictions are complicated by the variability of New Zealand’s climate. The annual temperature can fluctuate as much as 1°C above or below the long-term average. The early summer of 2006-7, for instance, was notably cool, thanks in part to the iceberg that drifted up the east coast. A few months later, warm water from the Tasman Sea helped make May 2007 unusually hot. These variables will continue unaffected so that, although the general pattern will be for rising temperatures, the warming trend may not be uniform.

C

The Ocean to the south of New Zealand will have one important effect. As the world warms, the great bank of west winds that circle Antarctica will become stronger. This has already been observed, and its impact on New Zealand is likely to be profound, stronger, more frequent west winds will bring increased, sometimes catastrophic rainfall to the west coast of the country and create drier conditions in some eastern regions that are already drought-prone. At the same time, the general warming will spread south.

D

Furthermore, in the drier regions, the average moisture deficit – that is, the difference between the amount of water in soils available to plants and the amount plants need for optimum growth – will increase. Soils could go into moisture deficit earlier in the growing season and the deficits could last longer into autumn that at present. What we think of today as a medium-severity drought could be an almost annual occurrence by the end of the century. One direct consequence of warmer – and shorter – winters will be a reduction in snow cover. The permanent snow line in the mountains will rise, while snow cover below this will be shorter-lived. The amount of snow that falls may actually increase, however, even in some northern centres, owing to the intensification of precipitation, Ski-field base station may eventually have to be moved upwards to be within reach of the new snow line but there could still be plenty of the white stuff up there.

E

There will also be a marked impact on New Zealand’s glaciers. Over the last 100 years, the glaciers have been reduced by 35%, although since 1978 increase snowfall has offset the effect of warming. The latest studies conducted by the National Institute for Water and Atmospheric. Research (NIWA), however, suggest that by the end of the century, warming over the Southern Alps could be significantly greater than over the rest of the country.

F

Sea levels around New Zealand have risen by 25cm since the middle of the 9th century and by 7 cm since 1990. Predictions for the coming years cover a wide range, however, partly because of unknown rises resulting from the melting of the ice in the Arctic, Greenland and Antarctica. In addition, sea level at any given time is affected by many different factors, one of which is called storm surge. When a Coincides with a high tide along low lying coastal areas, this bulge raises the tide higher than normal, creating. Surge not unlike a slow-motion tsunami. Not only does a rise in sea level increase the potential for his sort damage, but it also has less immediate impacts. The one potentially grave outcome is that groundwater systems may become contaminated with saltwater, spoiling them for the irrigation of farmland, which in turn could diminish crop harvests. Similarly, over time, estuaries may be enlarged by erosion as tidal influences reach further upstream, altering the contours of whole shorelines and initiating further unforeseen consequences.

G

The impacts these changes will have on New Zealand are difficult to generalize. Human systems are better able to adapt to change than natural ecosystems because humans can see a problem coming and plan a response. Farmers and horticulturalists have made considerable advances, replacing crops they grow to better suit the new conditions. However, plant breeders will need to show considerable ingenuity if they can overcome the acute water shortages that are forecast.

H

For natural ecosystems the rate of change is crucial. If it is low, the plants and animals and fish will be able to ‘keep up’; if it is high, only the most adaptable species-those that can survive in the widest range of ecological niches-are likely to survive. Species adapted to only a narrow range of conditions or food sources will find adaptation much more difficult. Take tuatara, for instance. Their sex is determined by the temperature at which the eggs are incubated in warm (currently above 22 °C) condition become predominately male – and now males already outnumber females by nearly two to one in some island refuges. In the mountains, as the permanent snow line moves upwards, the tolerance zones of some alpine plants and animals may simply disappear. It should also be remembered that global warming is just that – a global phenomenon. ‘New Zealand’s own greenhouse emissions are tiny – around 0.5% of the global total. Even if New Zealanders were to achieve the government’s target of carbon neutrality, this would have no discernable impact on global climate change.

I

The changes that global warming is going to bring to New Zealand during the 21st century are going to be significant, but where the country is likely to be most vulnerable is with respect to climate change elsewhere. New Zealand may warm more slowly than most places, but if its major export markets undergo damaging change, the economic impact will be severe.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('970fbc83-cd3d-518d-87c3-71c6c8f3a523', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-6 on your answer sheet.
1. What is the main idea of the first paragraph?
A
The air condition in New Zealand will maintain a high quality because of the ocean
B
The Southern Ocean will remain at a constant strength
C
The continents will warm more than the point
D
New Zealand will not warm as much as other countries in the next century because it is surrounded by sea.
2. What does the writer say about New Zealand’s variable weather?
A
Temperature changes of 1°C will not be seem important in future
B
Variable weather will continue, unchanged by global warming
C
There was an unusually small amount of variation in 2006-2007
D
Summer temperatures will vary but winter ones will be consistent
3. What is the predicted impact of conditions in the ocean to the south of New Zealand?
A
New Zealand will be more affected by floods and droughts
B
Antarctica will not be adversely affected by warming.
C
The band of west winds will move further to the south.
D
The usual west wind will no longer be reliable
4. The writer mentions ‘moisture deficit’ to show?
A
The droughts will be shorter but more severe
B
How the growing season will become longer.
C
How growing conditions will deteriorate
D
That farmers should alter the make-up of soils
5. What are the implications of global warming for New Zealand’s
A
Skiing may move to lower the altitude in future.
B
The ski season will be later in the year than at present.
C
The northern ski field will have to move to the south
D
Warming may provide more snow for some ski locations
6. The writer refers to NIWA’s latest studies in the 3rd paragraph to show
A
how a particular place could be affected by warming
B
that the warming trend has been intensifying since 1978
C
that freezing levels will rise throughout the century
D
how the growth of glaciers is likely to cause damage

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ffc526fe-c526-57b0-946d-303af7df27ba', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-6 on your answer sheet.
1. What is the main idea of the first paragraph?
A
The air condition in New Zealand will maintain a high quality because of the ocean
B
The Southern Ocean will remain at a constant strength
C
The continents will warm more than the point
D
New Zealand will not warm as much as other countries in the next century because it is surrounded by sea.
2. What does the writer say about New Zealand’s variable weather?
A
Temperature changes of 1°C will not be seem important in future
B
Variable weather will continue, unchanged by global warming
C
There was an unusually small amount of variation in 2006-2007
D
Summer temperatures will vary but winter ones will be consistent
3. What is the predicted impact of conditions in the ocean to the south of New Zealand?
A
New Zealand will be more affected by floods and droughts
B
Antarctica will not be adversely affected by warming.
C
The band of west winds will move further to the south.
D
The usual west wind will no longer be reliable
4. The writer mentions ‘moisture deficit’ to show?
A
The droughts will be shorter but more severe
B
How the growing season will become longer.
C
How growing conditions will deteriorate
D
That farmers should alter the make-up of soils
5. What are the implications of global warming for New Zealand’s
A
Skiing may move to lower the altitude in future.
B
The ski season will be later in the year than at present.
C
The northern ski field will have to move to the south
D
Warming may provide more snow for some ski locations
6. The writer refers to NIWA’s latest studies in the 3rd paragraph to show
A
how a particular place could be affected by warming
B
that the warming trend has been intensifying since 1978
C
that freezing levels will rise throughout the century
D
how the growth of glaciers is likely to cause damage

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6a4b7e81-f073-55e3-8a6f-c62aa609cb7a', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-6 on your answer sheet.
1. What is the main idea of the first paragraph?
A
The air condition in New Zealand will maintain a high quality because of the ocean
B
The Southern Ocean will remain at a constant strength
C
The continents will warm more than the point
D
New Zealand will not warm as much as other countries in the next century because it is surrounded by sea.
2. What does the writer say about New Zealand’s variable weather?
A
Temperature changes of 1°C will not be seem important in future
B
Variable weather will continue, unchanged by global warming
C
There was an unusually small amount of variation in 2006-2007
D
Summer temperatures will vary but winter ones will be consistent
3. What is the predicted impact of conditions in the ocean to the south of New Zealand?
A
New Zealand will be more affected by floods and droughts
B
Antarctica will not be adversely affected by warming.
C
The band of west winds will move further to the south.
D
The usual west wind will no longer be reliable
4. The writer mentions ‘moisture deficit’ to show?
A
The droughts will be shorter but more severe
B
How the growing season will become longer.
C
How growing conditions will deteriorate
D
That farmers should alter the make-up of soils
5. What are the implications of global warming for New Zealand’s
A
Skiing may move to lower the altitude in future.
B
The ski season will be later in the year than at present.
C
The northern ski field will have to move to the south
D
Warming may provide more snow for some ski locations
6. The writer refers to NIWA’s latest studies in the 3rd paragraph to show
A
how a particular place could be affected by warming
B
that the warming trend has been intensifying since 1978
C
that freezing levels will rise throughout the century
D
how the growth of glaciers is likely to cause damage

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('637c8bc6-4070-506c-9273-ee436aa36399', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-6 on your answer sheet.
1. What is the main idea of the first paragraph?
A
The air condition in New Zealand will maintain a high quality because of the ocean
B
The Southern Ocean will remain at a constant strength
C
The continents will warm more than the point
D
New Zealand will not warm as much as other countries in the next century because it is surrounded by sea.
2. What does the writer say about New Zealand’s variable weather?
A
Temperature changes of 1°C will not be seem important in future
B
Variable weather will continue, unchanged by global warming
C
There was an unusually small amount of variation in 2006-2007
D
Summer temperatures will vary but winter ones will be consistent
3. What is the predicted impact of conditions in the ocean to the south of New Zealand?
A
New Zealand will be more affected by floods and droughts
B
Antarctica will not be adversely affected by warming.
C
The band of west winds will move further to the south.
D
The usual west wind will no longer be reliable
4. The writer mentions ‘moisture deficit’ to show?
A
The droughts will be shorter but more severe
B
How the growing season will become longer.
C
How growing conditions will deteriorate
D
That farmers should alter the make-up of soils
5. What are the implications of global warming for New Zealand’s
A
Skiing may move to lower the altitude in future.
B
The ski season will be later in the year than at present.
C
The northern ski field will have to move to the south
D
Warming may provide more snow for some ski locations
6. The writer refers to NIWA’s latest studies in the 3rd paragraph to show
A
how a particular place could be affected by warming
B
that the warming trend has been intensifying since 1978
C
that freezing levels will rise throughout the century
D
how the growth of glaciers is likely to cause damage

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1045a46b-b550-5e64-9b7d-5100d82299fe', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-6 on your answer sheet.
1. What is the main idea of the first paragraph?
A
The air condition in New Zealand will maintain a high quality because of the ocean
B
The Southern Ocean will remain at a constant strength
C
The continents will warm more than the point
D
New Zealand will not warm as much as other countries in the next century because it is surrounded by sea.
2. What does the writer say about New Zealand’s variable weather?
A
Temperature changes of 1°C will not be seem important in future
B
Variable weather will continue, unchanged by global warming
C
There was an unusually small amount of variation in 2006-2007
D
Summer temperatures will vary but winter ones will be consistent
3. What is the predicted impact of conditions in the ocean to the south of New Zealand?
A
New Zealand will be more affected by floods and droughts
B
Antarctica will not be adversely affected by warming.
C
The band of west winds will move further to the south.
D
The usual west wind will no longer be reliable
4. The writer mentions ‘moisture deficit’ to show?
A
The droughts will be shorter but more severe
B
How the growing season will become longer.
C
How growing conditions will deteriorate
D
That farmers should alter the make-up of soils
5. What are the implications of global warming for New Zealand’s
A
Skiing may move to lower the altitude in future.
B
The ski season will be later in the year than at present.
C
The northern ski field will have to move to the south
D
Warming may provide more snow for some ski locations
6. The writer refers to NIWA’s latest studies in the 3rd paragraph to show
A
how a particular place could be affected by warming
B
that the warming trend has been intensifying since 1978
C
that freezing levels will rise throughout the century
D
how the growth of glaciers is likely to cause damage

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d194dc79-9a9c-58b5-9c14-85a7b23cd0fc', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-6 on your answer sheet.
1. What is the main idea of the first paragraph?
A
The air condition in New Zealand will maintain a high quality because of the ocean
B
The Southern Ocean will remain at a constant strength
C
The continents will warm more than the point
D
New Zealand will not warm as much as other countries in the next century because it is surrounded by sea.
2. What does the writer say about New Zealand’s variable weather?
A
Temperature changes of 1°C will not be seem important in future
B
Variable weather will continue, unchanged by global warming
C
There was an unusually small amount of variation in 2006-2007
D
Summer temperatures will vary but winter ones will be consistent
3. What is the predicted impact of conditions in the ocean to the south of New Zealand?
A
New Zealand will be more affected by floods and droughts
B
Antarctica will not be adversely affected by warming.
C
The band of west winds will move further to the south.
D
The usual west wind will no longer be reliable
4. The writer mentions ‘moisture deficit’ to show?
A
The droughts will be shorter but more severe
B
How the growing season will become longer.
C
How growing conditions will deteriorate
D
That farmers should alter the make-up of soils
5. What are the implications of global warming for New Zealand’s
A
Skiing may move to lower the altitude in future.
B
The ski season will be later in the year than at present.
C
The northern ski field will have to move to the south
D
Warming may provide more snow for some ski locations
6. The writer refers to NIWA’s latest studies in the 3rd paragraph to show
A
how a particular place could be affected by warming
B
that the warming trend has been intensifying since 1978
C
that freezing levels will rise throughout the century
D
how the growth of glaciers is likely to cause damage

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('282b18da-752b-51b5-aa16-c6aef8b6b8a3', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-9
on your answer sheet.
Rising sea levels
The extent of future sea level rises around New Zealand is uncertain and may be determined in the
7
. Another variable is sudden rises in sea level caused by bad weather. Higher sea levels can lead to reduced
8
and result in changes to the shape of
9
.
A
agriculture production
B
tropical waters
C
tidal waves
D
polar regions
E
global warming
F
coastal land
G
high tides

The extent of future sea level rises around New Zealand is uncertain and may be determined in the 7 ____ . Another variable is sudden rises in sea level caused by bad weather. Higher sea levels can lead to reduced 8 ____ and result in changes to the shape of 9 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f815c8b3-e5cb-5488-af80-0e218e8f9c2c', '282b18da-752b-51b5-aa16-c6aef8b6b8a3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32ebf500-6be2-504a-8724-bcf6006a8973', '282b18da-752b-51b5-aa16-c6aef8b6b8a3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7649c55-1c97-5164-bab4-1b9923b03b92', '282b18da-752b-51b5-aa16-c6aef8b6b8a3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03284269-3d69-54c0-ac87-23f76af0df05', '282b18da-752b-51b5-aa16-c6aef8b6b8a3', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b825393e-f243-5d48-96a6-e8d8b73c64f6', '282b18da-752b-51b5-aa16-c6aef8b6b8a3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e6b5fa0-b055-5544-a675-feac64dc35f4', '282b18da-752b-51b5-aa16-c6aef8b6b8a3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3241c0d6-63db-5e25-9087-24cb5a6a900c', '282b18da-752b-51b5-aa16-c6aef8b6b8a3', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('27759d00-b030-5885-802e-a1578a8ee4d9', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-9
on your answer sheet.
Rising sea levels
The extent of future sea level rises around New Zealand is uncertain and may be determined in the
7
. Another variable is sudden rises in sea level caused by bad weather. Higher sea levels can lead to reduced
8
and result in changes to the shape of
9
.
A
agriculture production
B
tropical waters
C
tidal waves
D
polar regions
E
global warming
F
coastal land
G
high tides

The extent of future sea level rises around New Zealand is uncertain and may be determined in the 7 ____ . Another variable is sudden rises in sea level caused by bad weather. Higher sea levels can lead to reduced 8 ____ and result in changes to the shape of 9 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f5852cb-ffb1-5581-b594-f153634394c7', '27759d00-b030-5885-802e-a1578a8ee4d9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c7cc21d-5b42-5140-89bc-0333a27bdda3', '27759d00-b030-5885-802e-a1578a8ee4d9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4679da2-0f51-59b3-82ff-b4684ff954dc', '27759d00-b030-5885-802e-a1578a8ee4d9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9bb0388-f8f9-5064-880e-9f0cfe5057d2', '27759d00-b030-5885-802e-a1578a8ee4d9', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b2f10dc-97e6-54d0-81c0-56c295fcbf99', '27759d00-b030-5885-802e-a1578a8ee4d9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f0559ba-4871-5274-b80a-d7cdbcb08151', '27759d00-b030-5885-802e-a1578a8ee4d9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('283cb3e4-16f8-54c1-ad77-4a1bea3ab53e', '27759d00-b030-5885-802e-a1578a8ee4d9', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('97d2fc41-2a12-5c67-bfd4-b10abcbbc4a7', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-9
on your answer sheet.
Rising sea levels
The extent of future sea level rises around New Zealand is uncertain and may be determined in the
7
. Another variable is sudden rises in sea level caused by bad weather. Higher sea levels can lead to reduced
8
and result in changes to the shape of
9
.
A
agriculture production
B
tropical waters
C
tidal waves
D
polar regions
E
global warming
F
coastal land
G
high tides

The extent of future sea level rises around New Zealand is uncertain and may be determined in the 7 ____ . Another variable is sudden rises in sea level caused by bad weather. Higher sea levels can lead to reduced 8 ____ and result in changes to the shape of 9 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a2f400c-91c4-56c9-b76b-349cc1b5e8d4', '97d2fc41-2a12-5c67-bfd4-b10abcbbc4a7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65d8b4ae-2edf-5271-8416-9d54b9dc485c', '97d2fc41-2a12-5c67-bfd4-b10abcbbc4a7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64bbe98e-b734-5558-8150-546e3a7d0a2f', '97d2fc41-2a12-5c67-bfd4-b10abcbbc4a7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f48c12c8-394d-5bfb-8aaa-0209c5e76fef', '97d2fc41-2a12-5c67-bfd4-b10abcbbc4a7', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('236ac6a5-da5b-5962-a0e8-b2b752923d68', '97d2fc41-2a12-5c67-bfd4-b10abcbbc4a7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf13d653-d89e-5d08-993d-e2cd65ea0834', '97d2fc41-2a12-5c67-bfd4-b10abcbbc4a7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9cfe994-9bf7-5c54-8bff-aeba0559c79c', '97d2fc41-2a12-5c67-bfd4-b10abcbbc4a7', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('43e6246a-c0d9-5f5d-bcbb-785665805799', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The natural world is less responsive to challenges than humans.
11
The agricultural sector is being too conservative and resistant to innovation.
12
The global warming is slow; it will affect different regions in different ways.
13
The tuatara is vulnerable to changes in climate conditions.
14
New Zealand must reduce carbon emission if global warming is to be slowed.

10 ____ The natural world is less responsive to challenges than humans.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('746b8013-5e11-5d93-8dc3-36564ec64dce', '43e6246a-c0d9-5f5d-bcbb-785665805799', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b8ce869-5ea9-5db0-be6a-5ec4b5235135', '43e6246a-c0d9-5f5d-bcbb-785665805799', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3c4bbcc-ade1-5a52-b9c0-63bd4c129bf3', '43e6246a-c0d9-5f5d-bcbb-785665805799', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('82a516f8-859b-5d91-b84f-63a1ed87eb0e', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The natural world is less responsive to challenges than humans.
11
The agricultural sector is being too conservative and resistant to innovation.
12
The global warming is slow; it will affect different regions in different ways.
13
The tuatara is vulnerable to changes in climate conditions.
14
New Zealand must reduce carbon emission if global warming is to be slowed.

11 ____ The agricultural sector is being too conservative and resistant to innovation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e9c172f-5da0-5a23-9eda-e98f9076f151', '82a516f8-859b-5d91-b84f-63a1ed87eb0e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34514997-7be3-5653-b17e-c2bbdc97397d', '82a516f8-859b-5d91-b84f-63a1ed87eb0e', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cdf1212-3fc3-55fe-8767-6750f25e33b9', '82a516f8-859b-5d91-b84f-63a1ed87eb0e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5f6ffaa6-8a06-5717-af4b-bac08d0ad05e', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The natural world is less responsive to challenges than humans.
11
The agricultural sector is being too conservative and resistant to innovation.
12
The global warming is slow; it will affect different regions in different ways.
13
The tuatara is vulnerable to changes in climate conditions.
14
New Zealand must reduce carbon emission if global warming is to be slowed.

12 ____ The global warming is slow; it will affect different regions in different ways.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11d74a76-114a-5c27-9e65-0a3f43eb0113', '5f6ffaa6-8a06-5717-af4b-bac08d0ad05e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fc1a5e6-2f28-5d82-b3c5-c168f8a5eabf', '5f6ffaa6-8a06-5717-af4b-bac08d0ad05e', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8327100c-9d8f-5ec0-ac7b-2381ab2051fb', '5f6ffaa6-8a06-5717-af4b-bac08d0ad05e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e9fe2b60-313d-53f6-9e56-46a8343258b4', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The natural world is less responsive to challenges than humans.
11
The agricultural sector is being too conservative and resistant to innovation.
12
The global warming is slow; it will affect different regions in different ways.
13
The tuatara is vulnerable to changes in climate conditions.
14
New Zealand must reduce carbon emission if global warming is to be slowed.

13 ____ The tuatara is vulnerable to changes in climate conditions.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25124329-ce5e-5289-8aa4-09083ee882c7', 'e9fe2b60-313d-53f6-9e56-46a8343258b4', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05c1e09e-3ca3-589e-92aa-25c965bd4ea6', 'e9fe2b60-313d-53f6-9e56-46a8343258b4', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a5c06e3-7fc8-5543-a94f-4800d6eb4dbf', 'e9fe2b60-313d-53f6-9e56-46a8343258b4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('98065d75-2199-5b9e-bf69-f2e3d164adec', '2e8f54ef-9b06-506b-8212-d58b9c9e82f1', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The natural world is less responsive to challenges than humans.
11
The agricultural sector is being too conservative and resistant to innovation.
12
The global warming is slow; it will affect different regions in different ways.
13
The tuatara is vulnerable to changes in climate conditions.
14
New Zealand must reduce carbon emission if global warming is to be slowed.

14 ____ New Zealand must reduce carbon emission if global warming is to be slowed.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a5b783c-e520-5312-9add-9a60b02364ed', '98065d75-2199-5b9e-bf69-f2e3d164adec', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03abad9d-5aba-52e0-9d36-2e3453909076', '98065d75-2199-5b9e-bf69-f2e3d164adec', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e49daeac-e56f-5197-b107-3d267aa204a8', '98065d75-2199-5b9e-bf69-f2e3d164adec', 3, $md$NOT GIVEN$md$, false);

COMMIT;
