BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-exploring-british-village-2-1477'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-exploring-british-village-2-1477';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-exploring-british-village-2-1477';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-exploring-british-village-2-1477';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('5b889642-8adc-5c33-aedf-a379baf5cb48', 'ielts-reading-exploring-british-village-2-1477', $t$Exploring british village 2$t$, $md$## Exploring british village 2

Nguồn:
- Test: https://mini-ielts.com/1477/reading/exploring-british-village-2
- Solution: https://mini-ielts.com/1477/view-solution/reading/exploring-british-village-2$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('d87aff84-3897-5414-b655-75b4df12f3ea', '5b889642-8adc-5c33-aedf-a379baf5cb48', 1, $t$Reading — Exploring british village 2$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Exploring british village 2

{A} The Neolithic longhouse was a long, narrow timber dwelling built by the first farmers in Europe beginning at least as early as the period 5000 to 6000 BC. The origin of the name blackhouse is of some debate. It could be less than 150 years old and may have been synonymous with inferior. On Lewis, in particular, it seems to have been used to distinguish the older blackhouses from some of the newer white-houses (Scottish Gaelic: taigh-geal, Irish: tí geal, tí bán), with their mortared stone walls. There may also be some confusion arising from the phonetic similarity between the ‘dubh’ , meaning black and taghadh meaning thatch. The houses in Scotland were built high rather than wide; however, some were built small and wide.

{B} The buildings were generally built with double-wall dry-stone walls packed with earth and wooden rafters covered with a thatch of turf with cereal straw or reed. The floor was generally flagstones or packed earth and there was a central hearth for the fire. There was no chimney for the smoke to escape through. Instead, the smoke made its way through the roof. The blackhouse was used to accommodate livestock as well as people. People lived at one end and the animals lived at the other with a partition between them.

{C} It is estimated that there are over ten thousand villages in Britain, yet defining the term ‘village’ isn’t as simple as it may at first sound. When does a hamlet become a village? And when does a village become a town?

{D} Strictly speaking the term ‘village’ comes from the Latin ‘villaticus’, which roughly translates as ‘a group of houses outside a villa farmstead’. Today a village is understood as a collection of buildings (usually at least 20) that is larger than a hamlet, yet smaller than a town, and which contains at least one communal or public building. This is most commonly the parish church, though it can be a chapel, school, public house, shop, post office, smithy or mill. Villagers will share communal resources such as access roads, a water supply, and usually a place of worship

{E} A hamlet is a smaller grouping of buildings that don’t necessarily have any public or service buildings to support it. A significant difference is that it won’t have a parish church like a village does, and most hamlets contain only between three and twenty buildings.

{F} The point at which a village becomes a town is difficult to determine and is probably best defined by those who live there. However, since the Middle Ages, the term ‘town’ has been a legal term that refers to the fact that the community has a borough charter. The situation is confused by the fact that there are many town-like suburban communities calling themselves villages (for example, Oxton Village in Birkenhead), as well as designed suburban ‘villages’ such as those built under the Garden Village Movement.

{G} The 2001 census shows us that approx 80% of people in England live in an urban environment, with under 7% living in rural villages (the remainder live in rural towns or outside concentrated settlements). This is the exact opposite of the situation two centuries ago, when under 20% of the population lived in the town, and the majority lived in rural villages. As late as 1851 agriculture remained the largest single source of employment in Britain, yet today under 3% of us work on the land.

{H} It is essential to remember that villages were created and have evolved because of particular combinations of geographical, commercial, economic and social factors. They expand, decline, move and fluctuate with the times. This article introduces some of the common forms of the village to be found in Britain.

The Medieval Village

{I} When we think of a British village we probably imagine a settlement of traditional cottages around a village green with a church and ancient manor house as a backdrop. This common form of the village has its roots in the medieval period when many villages started out as a cluster of agricultural dwellings

{J} Today farmsteads tend to be scattered about the landscape, but back in the medieval period those working on the land tended to live in small nucleated settlements (villages) and worked ‘open-field’ agriculture where land wasn’t enclosed. In fact, over much of Britain in the period up to 1800, it would have been unusual to have seen a farm or cottage outside of a settlement boundary.

{K} By the time that the Domesday Book was written in 1086 most of the good agricultural land in Britain was already under cultivation, and England was a densely populated country. Two centuries later nucleated settlements were to be found over much of Britain, typically consisting of well-organised village settlements sitting within open fields.

{L} Over lowland Britain on good soil you would typically find a settlement every couple of miles, and the communities would use the open agricultural land around where they lived. The average village would have its church, manor house, and cottage tenements all clustered together, and the open land around would usually be divided into thin strips. In some villages, you can still see the remnants of medieval strip field systems around the periphery of the settlement. There would often be meadows, pasture and woodland held ‘in common, and only the lord of the manor would have his own, private land or ‘demesne’. In the medieval village, virtually everyone would have earned their living on the territory, hence the community had to be relatively self-sufficient.

{M} ‘Green Villages’ were a common village form, where houses clustered around a central green of common land. They are often the remnants of planned settlements introduced after the Norman Conquest in the 19th century. It is suggested that this arrangement allowed for easier defence, especially compared to the village form most common before the Normans, which was simple clusters of farms. However there is also evidence of ‘village’ greens in Anglo-Saxon settlements, and even at Romano-British sites.

{N} The village green was soon adopted as the main social space within a village, as well as its focal point alongside the church or chapel. Village greens often take a triangular form, usually reflecting the fact that the village was at the meeting of three roads. The continuing importance of the village green to modern-day communities is reflected in the fact that this is usually where the war memorial is seen, as well as village notice boards, where local cricket matches are played, and where public benches are placed. The Open Spaces Society states that in 2005 there were about 3,650 registered greens in England and about 220 in Wales.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e6fb11cd-c4f0-505b-942c-9df58648608c', 'd87aff84-3897-5414-b655-75b4df12f3ea', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A and C-G from the list below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of heading
(i)
. Questions arise to be answered.
(ii)
. Contrast data between present and past.
(iii)
. Initial response of association on the village.
(iv)
. Origin of a certain ancient building.
(v)
. Inner structure of the building.
(vi)
. Layout of the village to persist in micro-environment.
(vii)
. Terms of the village explained.
(viii)
. Definition of village type.
(ix)
. Difference between village and town.
(X)
. Elements need to be considered in terms of the village.
1
paragraph A
2
paragraph B
3
paragraph C
4
paragraph D
5
paragraph E
6
paragraph F
7
paragraph G

1 ____ paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6579a2e4-7057-5125-b43d-30bd9adb7aa2', 'e6fb11cd-c4f0-505b-942c-9df58648608c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8980c56-54a0-5cc2-97b7-f79c7a3cd179', 'e6fb11cd-c4f0-505b-942c-9df58648608c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63aaeadb-c976-5021-890b-96456bff8880', 'e6fb11cd-c4f0-505b-942c-9df58648608c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('412800e7-8766-50e0-83d8-9e3322d4e4e2', 'e6fb11cd-c4f0-505b-942c-9df58648608c', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e607b9d-0b77-5e24-a804-6709052fb8ef', 'e6fb11cd-c4f0-505b-942c-9df58648608c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f940df58-3a64-527c-bad4-5dede2f2fb4b', 'e6fb11cd-c4f0-505b-942c-9df58648608c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de8fede3-2105-54f6-b1fb-5c0648db3bb5', 'e6fb11cd-c4f0-505b-942c-9df58648608c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13d8febf-49b2-50ca-9cac-9d3366dd903c', 'e6fb11cd-c4f0-505b-942c-9df58648608c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c9783d3-7703-5a00-ae41-25f160e127f2', 'e6fb11cd-c4f0-505b-942c-9df58648608c', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b12d5d8d-a473-5972-bbe6-d1899b300655', 'e6fb11cd-c4f0-505b-942c-9df58648608c', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d85b500a-12fd-5d86-b8a3-b0f537f730c0', 'd87aff84-3897-5414-b655-75b4df12f3ea', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A and C-G from the list below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of heading
(i)
. Questions arise to be answered.
(ii)
. Contrast data between present and past.
(iii)
. Initial response of association on the village.
(iv)
. Origin of a certain ancient building.
(v)
. Inner structure of the building.
(vi)
. Layout of the village to persist in micro-environment.
(vii)
. Terms of the village explained.
(viii)
. Definition of village type.
(ix)
. Difference between village and town.
(X)
. Elements need to be considered in terms of the village.
1
paragraph A
2
paragraph B
3
paragraph C
4
paragraph D
5
paragraph E
6
paragraph F
7
paragraph G

2 ____ paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6953616-5c10-5188-8b19-2f176699947c', 'd85b500a-12fd-5d86-b8a3-b0f537f730c0', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51663562-d2dd-59d8-89e6-98cc0f783872', 'd85b500a-12fd-5d86-b8a3-b0f537f730c0', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cc5b370-525a-5f7a-a80d-cf1fecc97d3d', 'd85b500a-12fd-5d86-b8a3-b0f537f730c0', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2e4387c-7b25-59bb-b943-3551741d1c75', 'd85b500a-12fd-5d86-b8a3-b0f537f730c0', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3985bcf0-f3c2-5041-8969-f185c4cede7e', 'd85b500a-12fd-5d86-b8a3-b0f537f730c0', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('319666b1-6328-58cb-aab9-66434d1cecb8', 'd85b500a-12fd-5d86-b8a3-b0f537f730c0', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55b2adfc-840e-5cf8-8709-971e5fa2bdf1', 'd85b500a-12fd-5d86-b8a3-b0f537f730c0', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dc4bc00-4ad3-5cfa-aa62-7239f43aadf1', 'd85b500a-12fd-5d86-b8a3-b0f537f730c0', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca30297e-d851-524f-850d-a72b2665d94c', 'd85b500a-12fd-5d86-b8a3-b0f537f730c0', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('077e28a8-8b1e-5a13-8e5b-082c23c20d72', 'd85b500a-12fd-5d86-b8a3-b0f537f730c0', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('181c9930-ad8c-5c92-ba75-c4c2ffcaa9e5', 'd87aff84-3897-5414-b655-75b4df12f3ea', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A and C-G from the list below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of heading
(i)
. Questions arise to be answered.
(ii)
. Contrast data between present and past.
(iii)
. Initial response of association on the village.
(iv)
. Origin of a certain ancient building.
(v)
. Inner structure of the building.
(vi)
. Layout of the village to persist in micro-environment.
(vii)
. Terms of the village explained.
(viii)
. Definition of village type.
(ix)
. Difference between village and town.
(X)
. Elements need to be considered in terms of the village.
1
paragraph A
2
paragraph B
3
paragraph C
4
paragraph D
5
paragraph E
6
paragraph F
7
paragraph G

3 ____ paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bf931fc-bc19-5edd-86bc-63f2dc950f63', '181c9930-ad8c-5c92-ba75-c4c2ffcaa9e5', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6eb6bd8c-fe29-5d13-98a4-b7f9c9424f5e', '181c9930-ad8c-5c92-ba75-c4c2ffcaa9e5', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ae99ed5-573a-5da9-939e-fe76cb3070ab', '181c9930-ad8c-5c92-ba75-c4c2ffcaa9e5', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eba2728e-83e0-5755-8529-25ef9804b7c3', '181c9930-ad8c-5c92-ba75-c4c2ffcaa9e5', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('464c7a1d-83fc-5cd9-8621-7a10445e239c', '181c9930-ad8c-5c92-ba75-c4c2ffcaa9e5', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7921f06c-fddf-553e-92cc-e2ef4690a123', '181c9930-ad8c-5c92-ba75-c4c2ffcaa9e5', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a20962cb-b9f9-5469-9fed-6db4a44c39ac', '181c9930-ad8c-5c92-ba75-c4c2ffcaa9e5', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf898505-13d4-5c1c-8912-ec055149ee2c', '181c9930-ad8c-5c92-ba75-c4c2ffcaa9e5', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da7cd82e-e703-569c-b344-837b2de10df4', '181c9930-ad8c-5c92-ba75-c4c2ffcaa9e5', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('107cdc6c-7d16-5061-8caf-55fd87bfa596', '181c9930-ad8c-5c92-ba75-c4c2ffcaa9e5', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1b3fdb2d-c350-5058-9b52-0649f84a982a', 'd87aff84-3897-5414-b655-75b4df12f3ea', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A and C-G from the list below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of heading
(i)
. Questions arise to be answered.
(ii)
. Contrast data between present and past.
(iii)
. Initial response of association on the village.
(iv)
. Origin of a certain ancient building.
(v)
. Inner structure of the building.
(vi)
. Layout of the village to persist in micro-environment.
(vii)
. Terms of the village explained.
(viii)
. Definition of village type.
(ix)
. Difference between village and town.
(X)
. Elements need to be considered in terms of the village.
1
paragraph A
2
paragraph B
3
paragraph C
4
paragraph D
5
paragraph E
6
paragraph F
7
paragraph G

4 ____ paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0766cdaf-4e28-594c-b117-665a4446084c', '1b3fdb2d-c350-5058-9b52-0649f84a982a', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d56df438-f0ad-5a19-b081-6deda8cdb834', '1b3fdb2d-c350-5058-9b52-0649f84a982a', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73d205e9-328b-5f08-ae2d-710f61f8457c', '1b3fdb2d-c350-5058-9b52-0649f84a982a', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5eace5c-b660-5359-83fb-50a0b88a9599', '1b3fdb2d-c350-5058-9b52-0649f84a982a', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51259972-7b19-53e2-bda5-58facdb27bac', '1b3fdb2d-c350-5058-9b52-0649f84a982a', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('541b29c7-b4e2-5b1d-a421-f59a8b0a6f6a', '1b3fdb2d-c350-5058-9b52-0649f84a982a', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13529550-5e32-5bcb-a3bc-2231c3cdb861', '1b3fdb2d-c350-5058-9b52-0649f84a982a', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0023638a-8890-5ee5-9ebc-a7f33083bff4', '1b3fdb2d-c350-5058-9b52-0649f84a982a', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ead8963-e79c-54ce-aa4d-8edd19bf327e', '1b3fdb2d-c350-5058-9b52-0649f84a982a', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a39c1fcd-c6d0-596a-aa35-c8908a81c3af', '1b3fdb2d-c350-5058-9b52-0649f84a982a', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f1f9532c-2e0e-5d88-9bd5-1412f9660933', 'd87aff84-3897-5414-b655-75b4df12f3ea', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A and C-G from the list below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of heading
(i)
. Questions arise to be answered.
(ii)
. Contrast data between present and past.
(iii)
. Initial response of association on the village.
(iv)
. Origin of a certain ancient building.
(v)
. Inner structure of the building.
(vi)
. Layout of the village to persist in micro-environment.
(vii)
. Terms of the village explained.
(viii)
. Definition of village type.
(ix)
. Difference between village and town.
(X)
. Elements need to be considered in terms of the village.
1
paragraph A
2
paragraph B
3
paragraph C
4
paragraph D
5
paragraph E
6
paragraph F
7
paragraph G

5 ____ paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f5ba7ff-528c-5fc8-9dc4-77c6faecd0a3', 'f1f9532c-2e0e-5d88-9bd5-1412f9660933', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adcf4031-e636-5a4c-9c84-226c11aa6c81', 'f1f9532c-2e0e-5d88-9bd5-1412f9660933', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89cc19e5-d0fc-5fee-973f-8a84db2cdd8f', 'f1f9532c-2e0e-5d88-9bd5-1412f9660933', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('890b902e-3305-59bc-ae06-660747b19f43', 'f1f9532c-2e0e-5d88-9bd5-1412f9660933', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d92a238c-a44d-5dba-866c-a1c2e970b9b6', 'f1f9532c-2e0e-5d88-9bd5-1412f9660933', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fed0e51-72bc-50b8-b207-cba6ba5d9fff', 'f1f9532c-2e0e-5d88-9bd5-1412f9660933', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d8c9bbc-c37a-5989-88f7-153092463bc9', 'f1f9532c-2e0e-5d88-9bd5-1412f9660933', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5dd3821-110b-514e-8466-aeae8088644b', 'f1f9532c-2e0e-5d88-9bd5-1412f9660933', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('894469c2-c32b-59d8-b964-e6c1453c53f9', 'f1f9532c-2e0e-5d88-9bd5-1412f9660933', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f916d1e-04a8-5b7e-bb5c-a69f4611ceb2', 'f1f9532c-2e0e-5d88-9bd5-1412f9660933', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7dd28811-a097-57a2-a39d-56de0ee32ee2', 'd87aff84-3897-5414-b655-75b4df12f3ea', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A and C-G from the list below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of heading
(i)
. Questions arise to be answered.
(ii)
. Contrast data between present and past.
(iii)
. Initial response of association on the village.
(iv)
. Origin of a certain ancient building.
(v)
. Inner structure of the building.
(vi)
. Layout of the village to persist in micro-environment.
(vii)
. Terms of the village explained.
(viii)
. Definition of village type.
(ix)
. Difference between village and town.
(X)
. Elements need to be considered in terms of the village.
1
paragraph A
2
paragraph B
3
paragraph C
4
paragraph D
5
paragraph E
6
paragraph F
7
paragraph G

6 ____ paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b71391ef-8ce0-5d61-920f-c4faf898573c', '7dd28811-a097-57a2-a39d-56de0ee32ee2', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfcf2b56-23b4-5310-9d73-05cdc5d85624', '7dd28811-a097-57a2-a39d-56de0ee32ee2', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('def7e27d-bcd4-5590-8115-01cce1da8853', '7dd28811-a097-57a2-a39d-56de0ee32ee2', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b4b137b-0d2d-5a72-bafb-a6b98523bde4', '7dd28811-a097-57a2-a39d-56de0ee32ee2', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bcbe993-e7f0-51dd-bb71-92c6956822d0', '7dd28811-a097-57a2-a39d-56de0ee32ee2', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18595055-15ad-57de-be0c-88353db5ecd3', '7dd28811-a097-57a2-a39d-56de0ee32ee2', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b73856e-7540-5792-8d74-f1b064afe566', '7dd28811-a097-57a2-a39d-56de0ee32ee2', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb86d641-12a5-5dfa-8323-fb59446d12a1', '7dd28811-a097-57a2-a39d-56de0ee32ee2', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a0d0f5e-db36-5774-94e7-efbfbe5e090b', '7dd28811-a097-57a2-a39d-56de0ee32ee2', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5dbad0a8-69cc-5293-a490-5f7ca3773da4', '7dd28811-a097-57a2-a39d-56de0ee32ee2', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a71c1408-1ba0-5005-ae94-2aa2b2939b0d', 'd87aff84-3897-5414-b655-75b4df12f3ea', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A and C-G from the list below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of heading
(i)
. Questions arise to be answered.
(ii)
. Contrast data between present and past.
(iii)
. Initial response of association on the village.
(iv)
. Origin of a certain ancient building.
(v)
. Inner structure of the building.
(vi)
. Layout of the village to persist in micro-environment.
(vii)
. Terms of the village explained.
(viii)
. Definition of village type.
(ix)
. Difference between village and town.
(X)
. Elements need to be considered in terms of the village.
1
paragraph A
2
paragraph B
3
paragraph C
4
paragraph D
5
paragraph E
6
paragraph F
7
paragraph G

7 ____ paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47a4b061-dfa4-5937-9789-d25123343032', 'a71c1408-1ba0-5005-ae94-2aa2b2939b0d', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e236bd87-bcf0-5d52-9d6f-80c54ba70511', 'a71c1408-1ba0-5005-ae94-2aa2b2939b0d', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a176b730-e81d-54e9-aeab-37af6e4b7b26', 'a71c1408-1ba0-5005-ae94-2aa2b2939b0d', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3c4b39e-f4a4-5fc6-8ba5-e25ed404d910', 'a71c1408-1ba0-5005-ae94-2aa2b2939b0d', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ab43379-d8d7-5bbc-b3f7-d478d0e784a6', 'a71c1408-1ba0-5005-ae94-2aa2b2939b0d', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65d13515-9e9a-5ec0-b13a-b7a903c34a25', 'a71c1408-1ba0-5005-ae94-2aa2b2939b0d', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18d7fadb-9ae5-546e-96ea-481f68a389de', 'a71c1408-1ba0-5005-ae94-2aa2b2939b0d', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab42681a-7d94-54e3-afde-3a7ad077e837', 'a71c1408-1ba0-5005-ae94-2aa2b2939b0d', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0428ac9d-b4b3-53af-b428-d31e7caa3562', 'a71c1408-1ba0-5005-ae94-2aa2b2939b0d', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('361b571b-a368-534d-a36b-4faa8a06de4a', 'a71c1408-1ba0-5005-ae94-2aa2b2939b0d', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7237612d-4cc5-50a5-8dde-c96b34f23192', 'd87aff84-3897-5414-b655-75b4df12f3ea', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than one word
from the Reading Passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
Village Green layout and
Extending
Impression of British Village usually takes forms of old-styled
8
with church and manor house. However, records in
9
indicated that England was already a cultivated and populated country in the 11th century. During medieval times, farmers literally could support themselves and the community, therefore, needed to be
10
in general.
Green village was usually
11
of dwellings after the invasion from Norman, and it was gathered mainly for the purpose of
12
Village Green’s
13
shape had a connection with its location among the roads, and nowadays it still can be seen in some public venues such as memorial and sports sites.

Impression of British Village usually takes forms of old-styled 8 ____ with church and manor house. However, records in 9 ____ indicated that England was already a cultivated and populated country in the 11th century. During medieval times, farmers literally could support themselves and the community, therefore, needed to be 10 ____ in general.$md$, NULL, ARRAY['.*cottages.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e1665c49-a14e-5fa1-833b-27c9e348cbc0', 'd87aff84-3897-5414-b655-75b4df12f3ea', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than one word
from the Reading Passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
Village Green layout and
Extending
Impression of British Village usually takes forms of old-styled
8
with church and manor house. However, records in
9
indicated that England was already a cultivated and populated country in the 11th century. During medieval times, farmers literally could support themselves and the community, therefore, needed to be
10
in general.
Green village was usually
11
of dwellings after the invasion from Norman, and it was gathered mainly for the purpose of
12
Village Green’s
13
shape had a connection with its location among the roads, and nowadays it still can be seen in some public venues such as memorial and sports sites.

Impression of British Village usually takes forms of old-styled 8 ____ with church and manor house. However, records in 9 ____ indicated that England was already a cultivated and populated country in the 11th century. During medieval times, farmers literally could support themselves and the community, therefore, needed to be 10 ____ in general.$md$, NULL, ARRAY['.*cottages.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('eb3dd4a6-8803-5a76-8241-e2809e1035b5', 'd87aff84-3897-5414-b655-75b4df12f3ea', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than one word
from the Reading Passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
Village Green layout and
Extending
Impression of British Village usually takes forms of old-styled
8
with church and manor house. However, records in
9
indicated that England was already a cultivated and populated country in the 11th century. During medieval times, farmers literally could support themselves and the community, therefore, needed to be
10
in general.
Green village was usually
11
of dwellings after the invasion from Norman, and it was gathered mainly for the purpose of
12
Village Green’s
13
shape had a connection with its location among the roads, and nowadays it still can be seen in some public venues such as memorial and sports sites.

Impression of British Village usually takes forms of old-styled 8 ____ with church and manor house. However, records in 9 ____ indicated that England was already a cultivated and populated country in the 11th century. During medieval times, farmers literally could support themselves and the community, therefore, needed to be 10 ____ in general.$md$, NULL, ARRAY['.*cottages.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f30adddd-e68f-5a99-bf51-654eeea6679d', 'd87aff84-3897-5414-b655-75b4df12f3ea', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than one word
from the Reading Passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
Village Green layout and
Extending
Impression of British Village usually takes forms of old-styled
8
with church and manor house. However, records in
9
indicated that England was already a cultivated and populated country in the 11th century. During medieval times, farmers literally could support themselves and the community, therefore, needed to be
10
in general.
Green village was usually
11
of dwellings after the invasion from Norman, and it was gathered mainly for the purpose of
12
Village Green’s
13
shape had a connection with its location among the roads, and nowadays it still can be seen in some public venues such as memorial and sports sites.

Green village was usually 11 ____ of dwellings after the invasion from Norman, and it was gathered mainly for the purpose of 12 ____ Village Green’s 13 ____ shape had a connection with its location among the roads, and nowadays it still can be seen in some public venues such as memorial and sports sites.$md$, NULL, ARRAY['.*remnants.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2b536639-dece-5ebc-8460-9feee2c4efb6', 'd87aff84-3897-5414-b655-75b4df12f3ea', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than one word
from the Reading Passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
Village Green layout and
Extending
Impression of British Village usually takes forms of old-styled
8
with church and manor house. However, records in
9
indicated that England was already a cultivated and populated country in the 11th century. During medieval times, farmers literally could support themselves and the community, therefore, needed to be
10
in general.
Green village was usually
11
of dwellings after the invasion from Norman, and it was gathered mainly for the purpose of
12
Village Green’s
13
shape had a connection with its location among the roads, and nowadays it still can be seen in some public venues such as memorial and sports sites.

Green village was usually 11 ____ of dwellings after the invasion from Norman, and it was gathered mainly for the purpose of 12 ____ Village Green’s 13 ____ shape had a connection with its location among the roads, and nowadays it still can be seen in some public venues such as memorial and sports sites.$md$, NULL, ARRAY['.*remnants.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('365029ba-0d25-5bec-8f70-4cd28e21bd16', 'd87aff84-3897-5414-b655-75b4df12f3ea', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than one word
from the Reading Passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
Village Green layout and
Extending
Impression of British Village usually takes forms of old-styled
8
with church and manor house. However, records in
9
indicated that England was already a cultivated and populated country in the 11th century. During medieval times, farmers literally could support themselves and the community, therefore, needed to be
10
in general.
Green village was usually
11
of dwellings after the invasion from Norman, and it was gathered mainly for the purpose of
12
Village Green’s
13
shape had a connection with its location among the roads, and nowadays it still can be seen in some public venues such as memorial and sports sites.

Green village was usually 11 ____ of dwellings after the invasion from Norman, and it was gathered mainly for the purpose of 12 ____ Village Green’s 13 ____ shape had a connection with its location among the roads, and nowadays it still can be seen in some public venues such as memorial and sports sites.$md$, NULL, ARRAY['.*remnants.*']);

COMMIT;
