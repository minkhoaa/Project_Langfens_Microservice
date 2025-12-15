BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-dirty-river-but-clean-water-1072'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-dirty-river-but-clean-water-1072';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-dirty-river-but-clean-water-1072';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-dirty-river-but-clean-water-1072';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9fcb8d52-430c-5196-819c-8373f0b09a66', 'ielts-reading-dirty-river-but-clean-water-1072', $t$Dirty River But Clean Water$t$, $md$## Dirty River But Clean Water

Nguồn:
- Test: https://mini-ielts.com/1072/reading/dirty-river-but-clean-water
- Solution: https://mini-ielts.com/1072/view-solution/reading/dirty-river-but-clean-water$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2056abe1-5f75-5fa5-a4da-784fdf4fd683', '9fcb8d52-430c-5196-819c-8373f0b09a66', 1, $t$Reading — Dirty River But Clean Water$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Dirty River But Clean Water

Floods can occur in rivers when the flow rate exceeds the capacity of the river channel, particularly at bends or meanders in the waterway. Floods often cause damage to homes and businesses if they are in the natural flood plains of rivers. While riverine flood damage can be eliminated by moving away from rivers and other bodies of water, people have traditionally lived and worked by rivers because the land is usually flat and fertile and because rivers provide easy travel and access to commerce and industry.

A Fire and flood are two of humanity’s worst nightmares. People have,therefore,always sought to control them. Forest fires are snuffed out quickly. The flow of rivers is regulated by weirs and dams. At least, that is how it used to be. But foresters have learned that forests need fires to clear out the brash and even to get seeds to germinate. And a similar revelation is now – dawning on hydrologists. Rivers – and the ecosystems they support – need floods. That is why a man-made torrent has been surging down the Grand Canyon. By Thursday March 6th it was running at full throttle, which was expected to be sustained for 60 hours.

B Floods once raged through the canyon every year. Spring Snow from as far away as Wyoming would melt and swell the Colorado river to a flow that averaged around 1,500 cubic metres (50,000 cubic feet) a second. Every eight years or so, that figure rose to almost 3,000 cubic metres . These floods infused the river with sediment , carved its beaches and built its sandbars.

C However, in the four decades since the building of the Glen Canyon dam, just upstream of the Grand Canyon, the only sediment that it has collected has come from tiny, undammed tributaries. Even that has not been much use as those tributaries are not powerful enough to distribute the sediment in an ecologically valuable way .

D This lack of flooding has harmed local wildlife. The humpback chub,for example, thrived in the rust-redwaters of the Colorado. Recently, though, its population has crashed. At first sight, it looked as if the reason was that the chub were being eaten by trout introduced for sport fishing in the mid-20th century. But trout and chub co-existed until the Glen Canyon dam was built, so something else is going on. Steve Gloss, of the United States’ Geological Survey (USGS), reckons that the chub’s decline is the result of their losing their most valuable natural defense, the Colorado’s rusty sediment. The chub were well adapted to the poor visibility created by the thick, red water which gave the river its name, and depended on it to hide from predators. Without the cloudy water the chub became vulnerable.

E And the chub are not alone. In the years since the Glen Canyon dam was built, several species have vanished altogether. These include the Colorado pike-minnow, the razorback sucker and the round-tail chub. Meanwhile, aliens including fathead minnows, channel catfish and common carp , which would have been hard, put to survive in the savage waters of the undammed canyon, have move din.

F So flooding is the obvious answer. Unfortunately, it is easier said than done. Floods were sent down the Grand Canyon in 1996 and 2004 and the results were mixed. In 1996 the flood was allowed to go on too long. To start with,all seemed well. The built up sandbanks and infused the river with sediment. Eventually, however, the continued flow washed most of the sediment out of the canyon. This problem was avoided in 2004, but unfortunately, on that occasion, the volume of sand available behind the dam was too low to rebuild the sandbanks. This time, the USGS is convinced that things will be better. The amount of sediment available is three times greater than it was in 2004. So if a flood is going to do some good, this is the time to unleash one.

G Even so, it may turn out to be an empty gesture. At less than 1,200 cubic metres a second, this flood is smaller than even an average spring flood , let alone one of the mightier deluges of the past. Those glorious inundations moved massive quantities of sediment through the Grand Canyon,wiping the slate dirty, and making a muddy mess of silt and muck that would make modern river rafters cringe.

--------

Great thanks to volunteer Lan Nguyen has contributed these explanations and question markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b76fc476-3df6-5f6b-89b1-07df5b8ec877', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Damage caused by fire is worse than that caused by flood.
2
The flood peaks at almost 1500 cubic meters every eight years.
Locate
3
Contribution of sediments delivered by tributaries has little impact.
Locate
4
Decreasing number of chubs is always caused by introducing of trout since mid 20th century.
Locate
5
It seemed that the artificial flood in 1996 had achieved success partly at the very beginning.
Locate
6
In fact, the yield of artificial flood water is smaller than an average natural flood at present.
Locate
7
Mighty floods drove fast moving flows with clean and high quality water.

1 ____ Damage caused by fire is worse than that caused by flood.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72510c2b-cc04-5bfa-8cb9-8709b3adfb1a', 'b76fc476-3df6-5f6b-89b1-07df5b8ec877', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69f4bdec-36b3-5015-b836-491ebff4ae98', 'b76fc476-3df6-5f6b-89b1-07df5b8ec877', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c0b019c-aef8-5df7-ace3-6236dbeecd61', 'b76fc476-3df6-5f6b-89b1-07df5b8ec877', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a42b1e8b-19ab-5442-a8e7-74d1df45677f', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Damage caused by fire is worse than that caused by flood.
2
The flood peaks at almost 1500 cubic meters every eight years.
Locate
3
Contribution of sediments delivered by tributaries has little impact.
Locate
4
Decreasing number of chubs is always caused by introducing of trout since mid 20th century.
Locate
5
It seemed that the artificial flood in 1996 had achieved success partly at the very beginning.
Locate
6
In fact, the yield of artificial flood water is smaller than an average natural flood at present.
Locate
7
Mighty floods drove fast moving flows with clean and high quality water.

2 ____ The flood peaks at almost 1500 cubic meters every eight years. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24795e51-79e0-59b2-821d-b483fab3e5e2', 'a42b1e8b-19ab-5442-a8e7-74d1df45677f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be6e38ce-3a34-5852-802a-3329d373830d', 'a42b1e8b-19ab-5442-a8e7-74d1df45677f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39c0241e-3c01-5708-bfeb-18784224f808', 'a42b1e8b-19ab-5442-a8e7-74d1df45677f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2b9eff43-3c6e-5248-a2df-224933357d07', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Damage caused by fire is worse than that caused by flood.
2
The flood peaks at almost 1500 cubic meters every eight years.
Locate
3
Contribution of sediments delivered by tributaries has little impact.
Locate
4
Decreasing number of chubs is always caused by introducing of trout since mid 20th century.
Locate
5
It seemed that the artificial flood in 1996 had achieved success partly at the very beginning.
Locate
6
In fact, the yield of artificial flood water is smaller than an average natural flood at present.
Locate
7
Mighty floods drove fast moving flows with clean and high quality water.

3 ____ Contribution of sediments delivered by tributaries has little impact. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7dce7082-49e8-5c94-af0c-cf9fcc4edb20', '2b9eff43-3c6e-5248-a2df-224933357d07', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d94ebb2f-ddc9-53ca-a5ac-ec0e3b36dea2', '2b9eff43-3c6e-5248-a2df-224933357d07', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7592b0a8-5056-53f9-ada3-a1849073b589', '2b9eff43-3c6e-5248-a2df-224933357d07', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac3719ae-9059-5f33-b07d-fe8b466b205f', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Damage caused by fire is worse than that caused by flood.
2
The flood peaks at almost 1500 cubic meters every eight years.
Locate
3
Contribution of sediments delivered by tributaries has little impact.
Locate
4
Decreasing number of chubs is always caused by introducing of trout since mid 20th century.
Locate
5
It seemed that the artificial flood in 1996 had achieved success partly at the very beginning.
Locate
6
In fact, the yield of artificial flood water is smaller than an average natural flood at present.
Locate
7
Mighty floods drove fast moving flows with clean and high quality water.

4 ____ Decreasing number of chubs is always caused by introducing of trout since mid 20th century. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24c25ab6-5b21-5d04-80db-275c57808edc', 'ac3719ae-9059-5f33-b07d-fe8b466b205f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70cf85a0-df9a-5387-87f4-7f4cfb64ec7e', 'ac3719ae-9059-5f33-b07d-fe8b466b205f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('533ef390-34af-5117-b8cc-d7fbc817be62', 'ac3719ae-9059-5f33-b07d-fe8b466b205f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('51ba0445-e68b-58b2-9a06-d90f01539c07', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Damage caused by fire is worse than that caused by flood.
2
The flood peaks at almost 1500 cubic meters every eight years.
Locate
3
Contribution of sediments delivered by tributaries has little impact.
Locate
4
Decreasing number of chubs is always caused by introducing of trout since mid 20th century.
Locate
5
It seemed that the artificial flood in 1996 had achieved success partly at the very beginning.
Locate
6
In fact, the yield of artificial flood water is smaller than an average natural flood at present.
Locate
7
Mighty floods drove fast moving flows with clean and high quality water.

5 ____ It seemed that the artificial flood in 1996 had achieved success partly at the very beginning. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d3af90c-b286-579c-9f1a-f0d5fb2ca59f', '51ba0445-e68b-58b2-9a06-d90f01539c07', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d9e31d8-008d-5612-a182-6a92f798d290', '51ba0445-e68b-58b2-9a06-d90f01539c07', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21b41a0e-66f6-5cff-981d-4bb17a0cbee2', '51ba0445-e68b-58b2-9a06-d90f01539c07', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3442a727-c22f-58b0-a6c9-6aaf28cc2ed8', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Damage caused by fire is worse than that caused by flood.
2
The flood peaks at almost 1500 cubic meters every eight years.
Locate
3
Contribution of sediments delivered by tributaries has little impact.
Locate
4
Decreasing number of chubs is always caused by introducing of trout since mid 20th century.
Locate
5
It seemed that the artificial flood in 1996 had achieved success partly at the very beginning.
Locate
6
In fact, the yield of artificial flood water is smaller than an average natural flood at present.
Locate
7
Mighty floods drove fast moving flows with clean and high quality water.

6 ____ In fact, the yield of artificial flood water is smaller than an average natural flood at present. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d722839-80cf-5c55-a62a-e5c2a8ca8bbe', '3442a727-c22f-58b0-a6c9-6aaf28cc2ed8', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92644e86-e4f8-5a29-8a96-1dd10ca329a2', '3442a727-c22f-58b0-a6c9-6aaf28cc2ed8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8e57f9d-89ce-5856-a730-2493276764e1', '3442a727-c22f-58b0-a6c9-6aaf28cc2ed8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7482f100-6937-54c3-a4a8-6f88cf42a288', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Damage caused by fire is worse than that caused by flood.
2
The flood peaks at almost 1500 cubic meters every eight years.
Locate
3
Contribution of sediments delivered by tributaries has little impact.
Locate
4
Decreasing number of chubs is always caused by introducing of trout since mid 20th century.
Locate
5
It seemed that the artificial flood in 1996 had achieved success partly at the very beginning.
Locate
6
In fact, the yield of artificial flood water is smaller than an average natural flood at present.
Locate
7
Mighty floods drove fast moving flows with clean and high quality water.

7 ____ Mighty floods drove fast moving flows with clean and high quality water.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd0ae258-1e6b-5fa9-8266-e5763554c691', '7482f100-6937-54c3-a4a8-6f88cf42a288', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('820c3922-02b5-54b0-8d0c-855713e5bcac', '7482f100-6937-54c3-a4a8-6f88cf42a288', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64cdce0d-65db-56b2-ac44-45baa178906b', '7482f100-6937-54c3-a4a8-6f88cf42a288', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bc4db848-ec20-566b-aab3-f1f4ae4d9e5a', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The eco-impact of the Canyon Dam
Floods are people’s nightmare. In the past, canyon was raged by flood every year. The snow from far Wyoming would melt in the season of
8
Locate
and caused a flood flow peak in Colorado river. In the four decades after people built the Glen Canyon dam, it only could gather
9
Locate
together from tiny, undammed tributaries.
Humpback chub population on reduced, why?
Then, several species disappeared including Colorado pike-minnow,
10
Locate
and the round-tail chub. Meanwhile, some moved in such as fathead minnows, channel catfish and
11
Locate
. The non-stopped flow leaded to the washing away of the sediment out of the canyon, which poses great threat to the chubs because it has poor
12
Locate
away from predators. In addition, the volume of
13
Locate
available behind the dam was too low to rebuild the bars and flooding became more serious.

Floods are people’s nightmare. In the past, canyon was raged by flood every year. The snow from far Wyoming would melt in the season of 8 ____ Locate and caused a flood flow peak in Colorado river. In the four decades after people built the Glen Canyon dam, it only could gather 9 ____ Locate together from tiny, undammed tributaries.$md$, NULL, ARRAY['.*spring.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ec552d86-2859-5963-8c91-b145ca30afe2', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The eco-impact of the Canyon Dam
Floods are people’s nightmare. In the past, canyon was raged by flood every year. The snow from far Wyoming would melt in the season of
8
Locate
and caused a flood flow peak in Colorado river. In the four decades after people built the Glen Canyon dam, it only could gather
9
Locate
together from tiny, undammed tributaries.
Humpback chub population on reduced, why?
Then, several species disappeared including Colorado pike-minnow,
10
Locate
and the round-tail chub. Meanwhile, some moved in such as fathead minnows, channel catfish and
11
Locate
. The non-stopped flow leaded to the washing away of the sediment out of the canyon, which poses great threat to the chubs because it has poor
12
Locate
away from predators. In addition, the volume of
13
Locate
available behind the dam was too low to rebuild the bars and flooding became more serious.

Floods are people’s nightmare. In the past, canyon was raged by flood every year. The snow from far Wyoming would melt in the season of 8 ____ Locate and caused a flood flow peak in Colorado river. In the four decades after people built the Glen Canyon dam, it only could gather 9 ____ Locate together from tiny, undammed tributaries.$md$, NULL, ARRAY['.*spring.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('781bf44b-0d03-5460-8cc0-9e102af9c275', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The eco-impact of the Canyon Dam
Floods are people’s nightmare. In the past, canyon was raged by flood every year. The snow from far Wyoming would melt in the season of
8
Locate
and caused a flood flow peak in Colorado river. In the four decades after people built the Glen Canyon dam, it only could gather
9
Locate
together from tiny, undammed tributaries.
Humpback chub population on reduced, why?
Then, several species disappeared including Colorado pike-minnow,
10
Locate
and the round-tail chub. Meanwhile, some moved in such as fathead minnows, channel catfish and
11
Locate
. The non-stopped flow leaded to the washing away of the sediment out of the canyon, which poses great threat to the chubs because it has poor
12
Locate
away from predators. In addition, the volume of
13
Locate
available behind the dam was too low to rebuild the bars and flooding became more serious.

Then, several species disappeared including Colorado pike-minnow, 10 ____ Locate and the round-tail chub. Meanwhile, some moved in such as fathead minnows, channel catfish and 11 ____ Locate . The non-stopped flow leaded to the washing away of the sediment out of the canyon, which poses great threat to the chubs because it has poor 12 ____ Locate away from predators. In addition, the volume of 13 ____ Locate available behind the dam was too low to rebuild the bars and flooding became more serious.$md$, NULL, ARRAY['.*razorback.*sucker.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('67d138ae-c02c-557a-a2c8-636bb4d028fc', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The eco-impact of the Canyon Dam
Floods are people’s nightmare. In the past, canyon was raged by flood every year. The snow from far Wyoming would melt in the season of
8
Locate
and caused a flood flow peak in Colorado river. In the four decades after people built the Glen Canyon dam, it only could gather
9
Locate
together from tiny, undammed tributaries.
Humpback chub population on reduced, why?
Then, several species disappeared including Colorado pike-minnow,
10
Locate
and the round-tail chub. Meanwhile, some moved in such as fathead minnows, channel catfish and
11
Locate
. The non-stopped flow leaded to the washing away of the sediment out of the canyon, which poses great threat to the chubs because it has poor
12
Locate
away from predators. In addition, the volume of
13
Locate
available behind the dam was too low to rebuild the bars and flooding became more serious.

Then, several species disappeared including Colorado pike-minnow, 10 ____ Locate and the round-tail chub. Meanwhile, some moved in such as fathead minnows, channel catfish and 11 ____ Locate . The non-stopped flow leaded to the washing away of the sediment out of the canyon, which poses great threat to the chubs because it has poor 12 ____ Locate away from predators. In addition, the volume of 13 ____ Locate available behind the dam was too low to rebuild the bars and flooding became more serious.$md$, NULL, ARRAY['.*razorback.*sucker.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2c131890-6952-52d2-9bc3-2871357b2638', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The eco-impact of the Canyon Dam
Floods are people’s nightmare. In the past, canyon was raged by flood every year. The snow from far Wyoming would melt in the season of
8
Locate
and caused a flood flow peak in Colorado river. In the four decades after people built the Glen Canyon dam, it only could gather
9
Locate
together from tiny, undammed tributaries.
Humpback chub population on reduced, why?
Then, several species disappeared including Colorado pike-minnow,
10
Locate
and the round-tail chub. Meanwhile, some moved in such as fathead minnows, channel catfish and
11
Locate
. The non-stopped flow leaded to the washing away of the sediment out of the canyon, which poses great threat to the chubs because it has poor
12
Locate
away from predators. In addition, the volume of
13
Locate
available behind the dam was too low to rebuild the bars and flooding became more serious.

Then, several species disappeared including Colorado pike-minnow, 10 ____ Locate and the round-tail chub. Meanwhile, some moved in such as fathead minnows, channel catfish and 11 ____ Locate . The non-stopped flow leaded to the washing away of the sediment out of the canyon, which poses great threat to the chubs because it has poor 12 ____ Locate away from predators. In addition, the volume of 13 ____ Locate available behind the dam was too low to rebuild the bars and flooding became more serious.$md$, NULL, ARRAY['.*razorback.*sucker.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('523b85fd-afb0-50c6-b032-8007df31f3f0', '2056abe1-5f75-5fa5-a4da-784fdf4fd683', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The eco-impact of the Canyon Dam
Floods are people’s nightmare. In the past, canyon was raged by flood every year. The snow from far Wyoming would melt in the season of
8
Locate
and caused a flood flow peak in Colorado river. In the four decades after people built the Glen Canyon dam, it only could gather
9
Locate
together from tiny, undammed tributaries.
Humpback chub population on reduced, why?
Then, several species disappeared including Colorado pike-minnow,
10
Locate
and the round-tail chub. Meanwhile, some moved in such as fathead minnows, channel catfish and
11
Locate
. The non-stopped flow leaded to the washing away of the sediment out of the canyon, which poses great threat to the chubs because it has poor
12
Locate
away from predators. In addition, the volume of
13
Locate
available behind the dam was too low to rebuild the bars and flooding became more serious.

Then, several species disappeared including Colorado pike-minnow, 10 ____ Locate and the round-tail chub. Meanwhile, some moved in such as fathead minnows, channel catfish and 11 ____ Locate . The non-stopped flow leaded to the washing away of the sediment out of the canyon, which poses great threat to the chubs because it has poor 12 ____ Locate away from predators. In addition, the volume of 13 ____ Locate available behind the dam was too low to rebuild the bars and flooding became more serious.$md$, NULL, ARRAY['.*razorback.*sucker.*']);

COMMIT;
