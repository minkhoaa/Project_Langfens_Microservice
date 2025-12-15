BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-traditional-farming-system-in-africa-1288'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-traditional-farming-system-in-africa-1288';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-traditional-farming-system-in-africa-1288';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-traditional-farming-system-in-africa-1288';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('99be9f85-760e-5fed-bb8b-74d955bd50c1', 'ielts-reading-traditional-farming-system-in-africa-1288', $t$Traditional Farming System in Africa$t$, $md$## Traditional Farming System in Africa

Nguồn:
- Test: https://mini-ielts.com/1288/reading/traditional-farming-system-in-africa
- Solution: https://mini-ielts.com/1288/view-solution/reading/traditional-farming-system-in-africa$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3960a40a-5a59-563e-aa12-d07faf52db12', '99be9f85-760e-5fed-bb8b-74d955bd50c1', 1, $t$Reading — Traditional Farming System in Africa$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Traditional Farming System in Africa

A . By tradition land in Luapula is not owned by individuals, but as in many other parts of Africa is allocated by the headman or headwoman of a village to people of either sex, according to need. Since land is generally prepared by hand, one ulupwa cannot take on a very large area; in this sense land has not been a limiting resource over large parts of the province. The situation has already changed near the main townships, and there has long been a scarcity of land for cultivation in the Valley. In these areas registered ownership patterns are becoming prevalent.

B . Most of the traditional cropping in Luapula, as in the Bemba area to the east, is based on citemene, a system whereby crops are grown on the ashes of tree branches. As a rule, entire trees are not felled, but are pollarded so that they can regenerate. Branches are cut over an area of varying size early in the dry season, and stacked to dry over a rough circle about a fifth to a tenth of the pollarded area. The wood is fired before the rains and in the first year planted with the African cereal finger millet (Eleusine coracana).

C . During the second season, and possibly for a few seasons more the area is planted to variously mixed combinations of annuals such as maize, pumpkins (Telfiria occidentalis) and other cucurbits, sweet potatoes, groundnuts, Phaseolus beans and various leafy vegetables, grown with a certain amount of rotation. The diverse sequence ends with vegetable cassava, which is often planted into the developing last-but-one crop as a relay.

D . Richards (1969) observed that the practice of citemene entails a definite division of labour between men and women. A man stakes out a plot in an unobtrusive manner, since it is considered provocative towards one’s neighbours to mark boundaries in an explicit way. The dangerous work of felling branches is the men’s province, and involves much pride. Branches are stacke by the women, and fired by the men. Formerly women and men cooperated in the planting work, but the harvesting was always done by the women. At the beginning of the cycle little weeding is necessary, since the firing of the branches effectively destroys weeds. As the cycle progresses weeds increase and nutrients eventually become depleted to a point where further effort with annual crops is judged to be not worthwhile: at this point the cassava is planted, since it can produce a crop on nearly exhausted soil. Thereafter the plot is abandoned, and a new area pollarded for the next citemene cycle.

E . When forest is not available – this is increasingly the case nowadays – various ridging systems (ibala) are built on small areas, to be planted with combinations of maize, beans, groundnuts and sweet potatoes, usually relayed with cassava. These plots are usually tended by women, and provide subsistence. Where their roots have year-round access to water tables mango, guava and oil-palm trees often grow around houses, forming a traditional agroforestry system. In season some of the fruit is sold by the roadside or in local markets.

F . The margins of dambos are sometimes planted to local varieties of rice during the rainy season, and areas adjacent to vegetables irrigated with water from the dambo during the dry season. The extent of cultivation is very limited, no doubt because the growing of crops under dambo conditions calls for a great deal of skill. Near towns some of the vegetable produce is sold in local markets.

G . Fishing has long provided a much needed protein supplement to the diet of Luapulans, as well as being the one substantial source of cash. Much fish is dried for sale to areas away from the main waterways. The Mweru and Bangweulu Lake Basins are the main areas of year-round fishing, but the Luapula River is also exploited during the latter part of the dry season. Several previously abundant and desirable species, such as the Luapula salmon or mpumbu (Labeo altivelis) and pale (Sarotherodon machochir) have all but disappeared from Lake Mweru, apparently due to mismanagement.

H . Fishing has always been a far more remunerative activity in Luapula that crop husbandry. A fisherman may earn more in a week than a bean or maize grower in a whole season. I sometimes heard claims that the relatively high earnings to be obtained from fishing induced an ‘easy come, easy go’ outlook among Luapulan men. On the other hand, someone who secures good but erratic earnings may feel that their investment in an economically productive activity is not worthwhile because Luapulans fail to cooperate well in such activities. Besides, a fisherman with spare cash will find little in the way of working equipment to spend his money on. Better spend one’s money in the bars and have a good time!

I . Only small numbers of cattle or oxen are kept in the province owing to the prevalence of the tse-tse fly. For the few herds, the dambos provide subsistence grazing during the dry season. The absence of animal draft power greatly limits peoples’ ability to plough and cultivate land: a married couple can rarely manage to prepare by hand-hoeing. Most people keep freely roaming chickens and goats. These act as a reserve for bartering, but may also be occasionally slaughtered for ceremonies or for entertaining important visitors. These animals are not a regular part of most peoples’ diet.

J . Citemene has been an ingenious system for providing people with seasonal production of high quality cereals and vegetables in regions of acid, heavily leached soils. Nutritionally, the most serious deficiency was that of protein. This could at times be alleviated when fish was available, provided that cultivators lived near the Valley and could find the means of bartering for dried fish. The citemene/fishing system was well adapted to the ecology of the miombo regions and sustainable for long periods, but only as long as human population densities stayed at low levels. Although population densities are still much lower than in several countries of South-East Asia, neither the fisheries nor the forests and woodlands of Luapula are capable, with unmodified traditional practices, of supporting the people in a sustainable manner.

Overall, people must learn to intensify and diversify their productive systems while yet ensuring that these systems will remain productive in the future, when even more people will need food. Increasing overall production offood, though a vast challenge in itself, will not be enough, however. At the same time storage and distribution systems must allow everyone access to at least a moderate share of the total.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d10e9888-d0b9-5e99-a267-3dfab06b5511', '3960a40a-5a59-563e-aa12-d07faf52db12', 1, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Complete the sentences below with words taken from Reading Passage!.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes
1-4
on your answer sheet.
1
. In Luapula land allocation is in accordance with
1
2
. The citemene system provides the land with
2
where crops are planted.
3
. During the second season, the last planted crop is
3
4
. Under suitable conditions, fruit trees are planted near
4

1 . In Luapula land allocation is in accordance with 1 ____$md$, NULL, ARRAY['.*need.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7c61ac07-d14e-5e33-8ce0-0516534d0372', '3960a40a-5a59-563e-aa12-d07faf52db12', 2, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Complete the sentences below with words taken from Reading Passage!.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes
1-4
on your answer sheet.
1
. In Luapula land allocation is in accordance with
1
2
. The citemene system provides the land with
2
where crops are planted.
3
. During the second season, the last planted crop is
3
4
. Under suitable conditions, fruit trees are planted near
4

2 . The citemene system provides the land with 2 ____ where crops are planted.$md$, NULL, ARRAY['.*ashes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('913e9c18-3745-5e58-a87b-86df0d98f88e', '3960a40a-5a59-563e-aa12-d07faf52db12', 3, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Complete the sentences below with words taken from Reading Passage!.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes
1-4
on your answer sheet.
1
. In Luapula land allocation is in accordance with
1
2
. The citemene system provides the land with
2
where crops are planted.
3
. During the second season, the last planted crop is
3
4
. Under suitable conditions, fruit trees are planted near
4

3 . During the second season, the last planted crop is 3 ____$md$, NULL, ARRAY['.*cassava.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2115b61e-f7f3-582e-beba-b4128eb3ae57', '3960a40a-5a59-563e-aa12-d07faf52db12', 4, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Complete the sentences below with words taken from Reading Passage!.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes
1-4
on your answer sheet.
1
. In Luapula land allocation is in accordance with
1
2
. The citemene system provides the land with
2
where crops are planted.
3
. During the second season, the last planted crop is
3
4
. Under suitable conditions, fruit trees are planted near
4

4 . Under suitable conditions, fruit trees are planted near 4 ____$md$, NULL, ARRAY['.*houses.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e824afae-ed5e-549f-8a4d-69f3985e12b0', '3960a40a-5a59-563e-aa12-d07faf52db12', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Classify the following items with the correct description. Write your answers in boxes
5-8
on your answer sheet
A
. fish
B
. oxen
C.
goats
5
be used in some unusual occasions, such as celebrations
6
cannot thrive for being affected by the pests
7
be the largest part of creating profit
8
be sold beyond the local area

5 ____ be used in some unusual occasions, such as celebrations$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b712522-9fb0-5d4c-a191-698178de0b0f', 'e824afae-ed5e-549f-8a4d-69f3985e12b0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d9f8477-6214-51b9-ac0d-42ffe20aa5a0', 'e824afae-ed5e-549f-8a4d-69f3985e12b0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7d9e808-7a39-535e-9c37-63eb8abc80df', 'e824afae-ed5e-549f-8a4d-69f3985e12b0', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('21fac8dc-334b-564c-b1ec-9372d86b74f8', '3960a40a-5a59-563e-aa12-d07faf52db12', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Classify the following items with the correct description. Write your answers in boxes
5-8
on your answer sheet
A
. fish
B
. oxen
C.
goats
5
be used in some unusual occasions, such as celebrations
6
cannot thrive for being affected by the pests
7
be the largest part of creating profit
8
be sold beyond the local area

6 ____ cannot thrive for being affected by the pests$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c25da4e7-d7d9-5e5c-842a-31766afcd731', '21fac8dc-334b-564c-b1ec-9372d86b74f8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd37265b-cfec-56ff-9739-f2e8617684ac', '21fac8dc-334b-564c-b1ec-9372d86b74f8', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('820bd486-a724-5a20-bb38-fd344d6f1c75', '21fac8dc-334b-564c-b1ec-9372d86b74f8', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f8606b3b-1e2f-5501-836a-85a4ff83f5da', '3960a40a-5a59-563e-aa12-d07faf52db12', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Classify the following items with the correct description. Write your answers in boxes
5-8
on your answer sheet
A
. fish
B
. oxen
C.
goats
5
be used in some unusual occasions, such as celebrations
6
cannot thrive for being affected by the pests
7
be the largest part of creating profit
8
be sold beyond the local area

7 ____ be the largest part of creating profit$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('066ae985-cf2e-5a2a-b2f8-1e20bf332d9d', 'f8606b3b-1e2f-5501-836a-85a4ff83f5da', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8158002-033f-5adb-9724-84856ab15249', 'f8606b3b-1e2f-5501-836a-85a4ff83f5da', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c441b43-d3f7-52b9-b732-133cb59efe27', 'f8606b3b-1e2f-5501-836a-85a4ff83f5da', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a4baa5da-025b-5633-a698-d8fadcb0d290', '3960a40a-5a59-563e-aa12-d07faf52db12', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Classify the following items with the correct description. Write your answers in boxes
5-8
on your answer sheet
A
. fish
B
. oxen
C.
goats
5
be used in some unusual occasions, such as celebrations
6
cannot thrive for being affected by the pests
7
be the largest part of creating profit
8
be sold beyond the local area

8 ____ be sold beyond the local area$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ad21afc-fa7d-5fbe-9e73-75e100364005', 'a4baa5da-025b-5633-a698-d8fadcb0d290', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bccd408-5f31-5783-9409-21cf82e8f96e', 'a4baa5da-025b-5633-a698-d8fadcb0d290', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d28d329-e5a0-5bf6-b707-c67b066dab72', 'a4baa5da-025b-5633-a698-d8fadcb0d290', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('88987986-9548-5a0a-9aa4-8ae8470f7c54', '3960a40a-5a59-563e-aa12-d07faf52db12', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-12
Questions 9-12
Do the following statements agree with the information given in
Reading Passage 1
? In boxes
9-12
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
People rarely use animals to cultivate land
10
When it is a busy time, children usually took part in the labor force
11
The local residents eat goats on a regular time
12
Though citemene has been a sophisticated system, it could not provide enough protein

9 ____ People rarely use animals to cultivate land$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('298cc75f-5003-57d6-ad08-e42f75691860', '88987986-9548-5a0a-9aa4-8ae8470f7c54', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a55e6f71-bbd6-5a84-ac4e-a88f39a4800b', '88987986-9548-5a0a-9aa4-8ae8470f7c54', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78f227a1-ee41-56c6-8fd6-247856bbf2ac', '88987986-9548-5a0a-9aa4-8ae8470f7c54', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e37c3170-26e5-569d-a360-2e2553eda5b1', '3960a40a-5a59-563e-aa12-d07faf52db12', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-12
Questions 9-12
Do the following statements agree with the information given in
Reading Passage 1
? In boxes
9-12
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
People rarely use animals to cultivate land
10
When it is a busy time, children usually took part in the labor force
11
The local residents eat goats on a regular time
12
Though citemene has been a sophisticated system, it could not provide enough protein

10 ____ When it is a busy time, children usually took part in the labor force$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b78ee10-3e9e-5ccc-a498-bff8081882f4', 'e37c3170-26e5-569d-a360-2e2553eda5b1', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('976217e9-4bf6-5869-8808-9e741fe5db3e', 'e37c3170-26e5-569d-a360-2e2553eda5b1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8edd4f7b-8c1c-58c9-9fae-4cf1e4944976', 'e37c3170-26e5-569d-a360-2e2553eda5b1', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b426cea6-197b-58e0-a99a-671b2671131e', '3960a40a-5a59-563e-aa12-d07faf52db12', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-12
Questions 9-12
Do the following statements agree with the information given in
Reading Passage 1
? In boxes
9-12
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
People rarely use animals to cultivate land
10
When it is a busy time, children usually took part in the labor force
11
The local residents eat goats on a regular time
12
Though citemene has been a sophisticated system, it could not provide enough protein

11 ____ The local residents eat goats on a regular time$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84858f8f-e6a2-5aab-b381-06f0d467ef8d', 'b426cea6-197b-58e0-a99a-671b2671131e', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1526c278-b90e-5922-8b32-4df05784a93c', 'b426cea6-197b-58e0-a99a-671b2671131e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6df14069-59f7-551e-ae46-12000c442d47', 'b426cea6-197b-58e0-a99a-671b2671131e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fe5f2563-8072-5122-8148-8d7346ac0eb3', '3960a40a-5a59-563e-aa12-d07faf52db12', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-12
Questions 9-12
Do the following statements agree with the information given in
Reading Passage 1
? In boxes
9-12
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
People rarely use animals to cultivate land
10
When it is a busy time, children usually took part in the labor force
11
The local residents eat goats on a regular time
12
Though citemene has been a sophisticated system, it could not provide enough protein

12 ____ Though citemene has been a sophisticated system, it could not provide enough protein$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('664926d8-6771-5e22-a91a-ff23a9c682de', 'fe5f2563-8072-5122-8148-8d7346ac0eb3', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b10af278-b3ee-5a10-9f24-356e89fa6ced', 'fe5f2563-8072-5122-8148-8d7346ac0eb3', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbc3c839-052f-52a6-b98a-0b72e39a6539', 'fe5f2563-8072-5122-8148-8d7346ac0eb3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6a650b94-d904-5e4f-aa2f-6c80355d8864', '3960a40a-5a59-563e-aa12-d07faf52db12', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 13
Questions 13
Questions 13
Choose the correct letter.
A, B, C or D.
Write the correct letter in the box 13 on your answer sheet.
What is the writer’s opinion about the traditional ways of practices?
A
They can supply the nutrition that people need
B
They are not capable of providing adequate support to the population
C
They are productive systems that need no more
D
They will be easily modified in the future

Questions 13 Choose the correct letter. A, B, C or D. Write the correct letter in the box 13 on your answer sheet. What is the writer’s opinion about the traditional ways of practices?$md$, NULL);

COMMIT;
