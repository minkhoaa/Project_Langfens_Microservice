BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-a-wonder-plant-1062'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-wonder-plant-1062';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-wonder-plant-1062';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-a-wonder-plant-1062';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('7ca41443-4888-50f7-a383-f2bb685f64de', 'ielts-reading-a-wonder-plant-1062', $t$A Wonder Plant$t$, $md$## A Wonder Plant

Nguồn:
- Test: https://mini-ielts.com/1062/reading/a-wonder-plant
- Solution: https://mini-ielts.com/1062/view-solution/reading/a-wonder-plant$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', '7ca41443-4888-50f7-a383-f2bb685f64de', 1, $t$Reading — A Wonder Plant$t$, $md$Read the passage and answer questions **1–13**.

### Passage: A Wonder Plant

The wonder plant with an uncertain future: more than a billion people rely on bamboo for either their shelter or income, while many endangered species depend on it for their survival. Despite its apparent abundance, a new report says that species of bamboo may be under serious threat.

A

Every year, during the rainy season, the mountain gorillas of Central Africa migrate to the foothills and lower slopes of the Virunga Mountains to graze on bamboo. For the 650 or so that remain in the wild, it’s a vital food source. Although there are at almost 150 types of plant, as well as various insects and other invertebrates, bamboo accounts for up to 90 percent of their diet at this time of year. Without it, says Ian Redmond, chairman of the Ape Alliance, their chances of survival would be reduced significantly. Gorillas aren’t the only locals keen on bamboo. For the people who live close to the Virungas, it’s a valuable and versatile raw material used for building houses and making household items such as mats and baskets. But in the past 100 years or so, resources have come under increasing pressure as populations have exploded and large areas of bamboo forest have been cleared to make way for farms and commercial plantations.

B

Sadly, this isn’t an isolated story. All over the world, the ranges of many bamboo species appear to be shrinking, endangering the people and animals that depend upon them. But despite bamboo’s importance, we know surprisingly little about it. A recent report published by the UN Environment Programme (UNEP) and the Inter-national Network for Bamboo and Rattan (INBAR) has revealed just how profound is our ignorance of global bamboo resources, particularly in relation to conservation. There are almost 1,600 recognized species of bamboo, but the report concentrated on the 1,200 or so woody varieties distinguished by the strong stems, or culms, that most people associate with this versatile plant. Of these, only 38 ‘priority species’ identified for their commercial value have been the subject of any real scientific research , and this has focused mostly on matters relating to their viability as a commodity. This problem isn’t confined to bamboo . Compared to the work carried out on animals, the science of assessing the conservation status of plants is still in its infancy. “People have only started looking hard at this during the past 10-15 years, and only now are they getting a handle on how to go about it systematically,” says Dr. Valerie Kapos, one of the report’s authors and a senior adviser in forest ecology and conservation to the UNEP.

C

Bamboo is a type of grass. It comes in a wide variety of forms, ranging in height from 30 centimeters to more than 40 meters. It is also the world’s fastest-growing woody plant; some species can grow more than a meter in a day. Bamboo’s ecological role extends beyond providing food and habitat for animals. Bamboo tends to grow in stands made up of groups of individual plants that grow from root systems known as rhizomes. Its extensive rhizome systems, which tie in the top layers of the soil, are crucial in preventing soil erosion . And there is growing evidence that bamboo plays an important part in determining forest structure and dynamics . “Bamboo’s pattern of mass flowering and mass death leaves behind large areas of dry biomass that attract wildfire,” says Kapos. “When these burn, they create patches of open ground within the forest far bigger than would be left by a fallen tree.”Patchiness helps to preserve diversity because certain plant species do better during the early stages of regeneration when there are gaps in the canopy.

D

However, bamboo’s most immediate significance lies in its economic value . Modern processing techniques mean that it can be used in a variety of ways, for example, as flooring and laminates. One of the fastest growing bamboo products is paper -25 percent of paper produced in India is made from bamboo fiber, and in Brazil, 100,000 hectares of bamboo are grown for its production. Of course, bamboo’s main function has always been in domestic applications, and as a locally traded commodity it’s worth about $4.5billion annually. Because of its versatility, flexibility and strength (its tensile strength compares to that of some steel), it has traditionally been used in construction . Today, more than one billion people worldwide live in bamboo houses. Bamboo is often the only readily available raw material for people in many developing countries, says Chris Stapleton, a research associate at the Royal Botanic Gardens. “Bamboo can be harvested from forest areas or grown quickly elsewhere, and then converted simply without expensive machinery or facilities,” he says. “In this way, it contributes substantially to poverty alleviation and wealth creation .”

E

Given bamboo’s value in economic and ecological terms, the picture painted by theUNEP report is all the more worrying. But keen horticulturists will spot an apparent contradiction here. Those who’ve followed the recent vogue for cultivating exotic species in their gardens will point out that if it isn’t kept in check, bamboo can cause real problems. “In a lot of places, the people who live with bamboo don’t perceive it as being endangered in any way ,” says Kapos. “In fact, a lot of bamboo species are actually very invasive if they’ve been introduced.”So why are so many species endangered? There are two separate issues here, says Ray Townsend, vice president of the British Bamboo Society and arboretum manager at the Royal Botanic Gardens. “ Some plants are threatened because they can’t survive in the habitat-they aren’t strong enough or there aren’t enough of them, perhaps. But bamboo can take care of itself-it is strong enough to survive if left alone. What is under threat is its habitat.”It is the physical disturbance that is the threat to bamboo, says Kapos. “When forest goes, it is converted into something else: there isn’t anywhere for forest plants such as bamboo to grow if you create a cattle pasture.”

F

Around the world, bamboo species are routinely protected as part of forest eco-systems in national parks and reserves, but there is next to nothing that protects bamboo in the wild for its own sake. However, some small steps are being taken to address this situation. The UNEP-INBAR report will help conservationists to establish effective measures aimed at protecting valuable wild bamboo species. Townsend, too, sees the UNEP report as an important step forward in promoting the cause of bamboo conservation. “Until now, bamboo has been perceived as a second-class plant. When you talk about places such as the Amazon, everyone always thinks about the hardwoods. Of course these are significant, but there is a tendency to overlook the plants they are associated with, which are often bamboo species. In many ways, it is the most important plant known to man. I can’t think of another plant that is used so much and is so commercially important in so many countries.”He believes that the most important first step is to get scientists into the field. “We need to go out there, look at these plants and see how they survive and then use that information to conserve them for the future.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('edd88444-a150-5dc4-ae0b-dace344595b7', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage has six sections
A-F
.
Which section contains the following information ?
Write the correct letter
A-F
in boxes
1-7
on your answer sheet
NB
You may use any letter
more than once
1
Comparison of bamboo with other plant species
Locate
2
Commercial products of bamboo
Locate
3
Limited extent of existing research
4
A human development that destroyed large areas of bamboo
Locate
5
How bamboos are put to a variety of uses
Locate
6
An explanation of how bamboo can help the survival of a range of plants
Locate
7
The methods used to study bamboo
Locate

1 ____ Comparison of bamboo with other plant species Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5abe0e1f-f662-550d-a1aa-1d216d5fa07a', 'edd88444-a150-5dc4-ae0b-dace344595b7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acd166a1-224b-53bd-a97e-3b7e68d744fe', 'edd88444-a150-5dc4-ae0b-dace344595b7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1fcaf26-f94a-5e57-b5d2-5eebda36a883', 'edd88444-a150-5dc4-ae0b-dace344595b7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f21e33cf-4be7-5f96-b35f-f0bbfb897c19', 'edd88444-a150-5dc4-ae0b-dace344595b7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a39131f2-1c3c-57af-a502-f6a5c926f454', 'edd88444-a150-5dc4-ae0b-dace344595b7', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcf55771-040e-5459-977d-a61f7be577a6', 'edd88444-a150-5dc4-ae0b-dace344595b7', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4714f817-d8d5-571e-8e3e-4abc95b3717f', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage has six sections
A-F
.
Which section contains the following information ?
Write the correct letter
A-F
in boxes
1-7
on your answer sheet
NB
You may use any letter
more than once
1
Comparison of bamboo with other plant species
Locate
2
Commercial products of bamboo
Locate
3
Limited extent of existing research
4
A human development that destroyed large areas of bamboo
Locate
5
How bamboos are put to a variety of uses
Locate
6
An explanation of how bamboo can help the survival of a range of plants
Locate
7
The methods used to study bamboo
Locate

2 ____ Commercial products of bamboo Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38d994b2-fc55-589d-80ff-341735355bf9', '4714f817-d8d5-571e-8e3e-4abc95b3717f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ccc1f4b-b0f5-58ea-a80a-b66fa5d21fa6', '4714f817-d8d5-571e-8e3e-4abc95b3717f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ecfdb90-f308-50ac-ba26-a3790529f1ca', '4714f817-d8d5-571e-8e3e-4abc95b3717f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8baaf433-e80e-585f-b142-fbeb185f32ba', '4714f817-d8d5-571e-8e3e-4abc95b3717f', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79c9ca1c-92b8-5652-bcd7-b810bc1ba4e1', '4714f817-d8d5-571e-8e3e-4abc95b3717f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42102d7e-1014-56cb-bdfb-667c3e4ff571', '4714f817-d8d5-571e-8e3e-4abc95b3717f', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('852dbc7a-5988-5be2-a479-b7615f3db82a', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage has six sections
A-F
.
Which section contains the following information ?
Write the correct letter
A-F
in boxes
1-7
on your answer sheet
NB
You may use any letter
more than once
1
Comparison of bamboo with other plant species
Locate
2
Commercial products of bamboo
Locate
3
Limited extent of existing research
4
A human development that destroyed large areas of bamboo
Locate
5
How bamboos are put to a variety of uses
Locate
6
An explanation of how bamboo can help the survival of a range of plants
Locate
7
The methods used to study bamboo
Locate

3 ____ Limited extent of existing research$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c95736ff-e024-5c83-b1ba-8d7288204abb', '852dbc7a-5988-5be2-a479-b7615f3db82a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6c39cf4-ba74-5be0-8a02-5c506b289206', '852dbc7a-5988-5be2-a479-b7615f3db82a', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba5674e5-f300-5923-b720-014cdcc01706', '852dbc7a-5988-5be2-a479-b7615f3db82a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc3f84e7-797f-5e7d-90af-3ef4abbb41e5', '852dbc7a-5988-5be2-a479-b7615f3db82a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b43b9b6c-9043-5ee4-ad7c-f7754a0eff8d', '852dbc7a-5988-5be2-a479-b7615f3db82a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2889b260-9e54-5fcb-a663-fcae5674810a', '852dbc7a-5988-5be2-a479-b7615f3db82a', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('71e441a4-88a3-5adf-803e-14330e92ba5f', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage has six sections
A-F
.
Which section contains the following information ?
Write the correct letter
A-F
in boxes
1-7
on your answer sheet
NB
You may use any letter
more than once
1
Comparison of bamboo with other plant species
Locate
2
Commercial products of bamboo
Locate
3
Limited extent of existing research
4
A human development that destroyed large areas of bamboo
Locate
5
How bamboos are put to a variety of uses
Locate
6
An explanation of how bamboo can help the survival of a range of plants
Locate
7
The methods used to study bamboo
Locate

4 ____ A human development that destroyed large areas of bamboo Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('457ab869-d0ac-5dac-90a7-a01f4e10d7f8', '71e441a4-88a3-5adf-803e-14330e92ba5f', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38eee398-ed6c-5236-b1c3-a39ecfb14397', '71e441a4-88a3-5adf-803e-14330e92ba5f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5c2fc38-cf49-5df2-be97-2fb34a05093f', '71e441a4-88a3-5adf-803e-14330e92ba5f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad8bed39-889d-585b-8f3b-f4a8953f872c', '71e441a4-88a3-5adf-803e-14330e92ba5f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9adcec1c-d1b7-57f5-8cd6-170f64790d68', '71e441a4-88a3-5adf-803e-14330e92ba5f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3022e5a-c8c9-50fe-96db-ff9cf50c67f7', '71e441a4-88a3-5adf-803e-14330e92ba5f', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d740045-8481-56cc-86f8-e9d23658a564', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage has six sections
A-F
.
Which section contains the following information ?
Write the correct letter
A-F
in boxes
1-7
on your answer sheet
NB
You may use any letter
more than once
1
Comparison of bamboo with other plant species
Locate
2
Commercial products of bamboo
Locate
3
Limited extent of existing research
4
A human development that destroyed large areas of bamboo
Locate
5
How bamboos are put to a variety of uses
Locate
6
An explanation of how bamboo can help the survival of a range of plants
Locate
7
The methods used to study bamboo
Locate

5 ____ How bamboos are put to a variety of uses Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5da54e2a-b570-5768-937d-cf39b9610904', '5d740045-8481-56cc-86f8-e9d23658a564', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('530de409-f8df-59ca-b5ac-a9b1511e4f55', '5d740045-8481-56cc-86f8-e9d23658a564', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be7f17e6-47b1-583f-9cc5-ed7eeaa90e69', '5d740045-8481-56cc-86f8-e9d23658a564', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5569b82-bcbd-5af7-a194-00d43a30b551', '5d740045-8481-56cc-86f8-e9d23658a564', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e624b98-7e0f-50a9-bf82-b88026a5f47c', '5d740045-8481-56cc-86f8-e9d23658a564', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0adaa72-ad08-5fd8-89f9-6b7c83638cdf', '5d740045-8481-56cc-86f8-e9d23658a564', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b71be859-6d16-523f-a258-69a20945dce6', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage has six sections
A-F
.
Which section contains the following information ?
Write the correct letter
A-F
in boxes
1-7
on your answer sheet
NB
You may use any letter
more than once
1
Comparison of bamboo with other plant species
Locate
2
Commercial products of bamboo
Locate
3
Limited extent of existing research
4
A human development that destroyed large areas of bamboo
Locate
5
How bamboos are put to a variety of uses
Locate
6
An explanation of how bamboo can help the survival of a range of plants
Locate
7
The methods used to study bamboo
Locate

6 ____ An explanation of how bamboo can help the survival of a range of plants Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74d90f36-e201-5781-a5b0-fa85b9bcc0d8', 'b71be859-6d16-523f-a258-69a20945dce6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b343be6-93d9-550a-b155-82c2430e7ea3', 'b71be859-6d16-523f-a258-69a20945dce6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ba72865-5bb5-5b54-9ad9-0522ee0cd0da', 'b71be859-6d16-523f-a258-69a20945dce6', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77f40c23-5977-5cc8-9e34-7bc50d5ba40f', 'b71be859-6d16-523f-a258-69a20945dce6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cd58e99-827f-5e2a-8360-6f3624bbb261', 'b71be859-6d16-523f-a258-69a20945dce6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4213d18b-c331-552e-8590-9ea67d965f16', 'b71be859-6d16-523f-a258-69a20945dce6', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c4d50d10-f960-5595-b987-61e8dd1985f3', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage has six sections
A-F
.
Which section contains the following information ?
Write the correct letter
A-F
in boxes
1-7
on your answer sheet
NB
You may use any letter
more than once
1
Comparison of bamboo with other plant species
Locate
2
Commercial products of bamboo
Locate
3
Limited extent of existing research
4
A human development that destroyed large areas of bamboo
Locate
5
How bamboos are put to a variety of uses
Locate
6
An explanation of how bamboo can help the survival of a range of plants
Locate
7
The methods used to study bamboo
Locate

7 ____ The methods used to study bamboo Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f787b95-ee4d-5f90-9675-8663670a9959', 'c4d50d10-f960-5595-b987-61e8dd1985f3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b6a2ca9-b574-5372-ae2c-bafcf87c4b9b', 'c4d50d10-f960-5595-b987-61e8dd1985f3', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b30beff-4ff8-5379-bb05-8b95767d76f4', 'c4d50d10-f960-5595-b987-61e8dd1985f3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1130ddb-6dbf-5a5d-8403-bedb230da187', 'c4d50d10-f960-5595-b987-61e8dd1985f3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2894cd8d-aa7e-5f43-83b1-63b18843571b', 'c4d50d10-f960-5595-b987-61e8dd1985f3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e450137-6743-5da4-958c-e054e6cc2404', 'c4d50d10-f960-5595-b987-61e8dd1985f3', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1bd44024-0453-53e0-a7d0-069a0cc9d2ab', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-11
Questions 8-11
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
8-11
on your answer sheet.
NB
you may use any letter
more than once
A
Ian Redmond
B
Valerie Kapos
C
Ray Townsend
D
Chris Stapleton
8
Destroying bamboo jeopardizes to wildlife.
Locate
9
People have very confined knowledge of bamboo.
Locate
10
Some people do not think that bamboo is endangered.
Locate
11
Bamboo has loads of commercial potentials.
Locate

8 ____ Destroying bamboo jeopardizes to wildlife. Locate 9 ____ People have very confined knowledge of bamboo. Locate 10 ____ Some people do not think that bamboo is endangered. Locate 11 ____ Bamboo has loads of commercial potentials. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e4a6e4e-2d70-5b1e-a19a-f0f790c69e6a', '1bd44024-0453-53e0-a7d0-069a0cc9d2ab', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6455b68-98ce-5350-b6c7-dcd1e4b26d30', '1bd44024-0453-53e0-a7d0-069a0cc9d2ab', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3090a5e3-343d-5603-ad6e-244c42d5bde7', '1bd44024-0453-53e0-a7d0-069a0cc9d2ab', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a95f024f-bc6f-56a7-86ca-131560598646', '1bd44024-0453-53e0-a7d0-069a0cc9d2ab', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0d54f564-ae48-5268-b87d-c6184f523599', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-11
Questions 8-11
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
8-11
on your answer sheet.
NB
you may use any letter
more than once
A
Ian Redmond
B
Valerie Kapos
C
Ray Townsend
D
Chris Stapleton
8
Destroying bamboo jeopardizes to wildlife.
Locate
9
People have very confined knowledge of bamboo.
Locate
10
Some people do not think that bamboo is endangered.
Locate
11
Bamboo has loads of commercial potentials.
Locate

8 ____ Destroying bamboo jeopardizes to wildlife. Locate 9 ____ People have very confined knowledge of bamboo. Locate 10 ____ Some people do not think that bamboo is endangered. Locate 11 ____ Bamboo has loads of commercial potentials. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('774fe5f5-d431-5d5e-b73c-ca5df548d855', '0d54f564-ae48-5268-b87d-c6184f523599', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4f12af7-b973-5395-af3c-6800bf8606ab', '0d54f564-ae48-5268-b87d-c6184f523599', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3c4d40c-20bc-5611-b616-c8946cc55fc0', '0d54f564-ae48-5268-b87d-c6184f523599', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d898f18-8e17-589d-8a95-a4ab0be9d379', '0d54f564-ae48-5268-b87d-c6184f523599', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a97258e2-02d3-5192-a3f0-7f2c57420095', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-11
Questions 8-11
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
8-11
on your answer sheet.
NB
you may use any letter
more than once
A
Ian Redmond
B
Valerie Kapos
C
Ray Townsend
D
Chris Stapleton
8
Destroying bamboo jeopardizes to wildlife.
Locate
9
People have very confined knowledge of bamboo.
Locate
10
Some people do not think that bamboo is endangered.
Locate
11
Bamboo has loads of commercial potentials.
Locate

8 ____ Destroying bamboo jeopardizes to wildlife. Locate 9 ____ People have very confined knowledge of bamboo. Locate 10 ____ Some people do not think that bamboo is endangered. Locate 11 ____ Bamboo has loads of commercial potentials. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5eb42a0c-2bc5-5886-ae42-f95fd9767d2d', 'a97258e2-02d3-5192-a3f0-7f2c57420095', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8dde726-3696-5192-8e0d-d19fb4a065fc', 'a97258e2-02d3-5192-a3f0-7f2c57420095', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e756028f-2583-572d-a0e6-cfaae6f4126e', 'a97258e2-02d3-5192-a3f0-7f2c57420095', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('490be826-0440-5cb5-b746-e24026dfd16b', 'a97258e2-02d3-5192-a3f0-7f2c57420095', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c56d89a9-19cd-5a68-a658-063b00f86c6c', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-11
Questions 8-11
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
8-11
on your answer sheet.
NB
you may use any letter
more than once
A
Ian Redmond
B
Valerie Kapos
C
Ray Townsend
D
Chris Stapleton
8
Destroying bamboo jeopardizes to wildlife.
Locate
9
People have very confined knowledge of bamboo.
Locate
10
Some people do not think that bamboo is endangered.
Locate
11
Bamboo has loads of commercial potentials.
Locate

8 ____ Destroying bamboo jeopardizes to wildlife. Locate 9 ____ People have very confined knowledge of bamboo. Locate 10 ____ Some people do not think that bamboo is endangered. Locate 11 ____ Bamboo has loads of commercial potentials. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef100e28-5913-5c67-8c14-ba6ee9580edd', 'c56d89a9-19cd-5a68-a658-063b00f86c6c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f09b9e39-5b05-5a13-93b0-3b2229ba1b18', 'c56d89a9-19cd-5a68-a658-063b00f86c6c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('361c70ee-12fe-5f78-8154-de5492c92dbe', 'c56d89a9-19cd-5a68-a658-063b00f86c6c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c9b3e0a-a84e-5192-8564-5672e6f55c78', 'c56d89a9-19cd-5a68-a658-063b00f86c6c', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('44151c3a-65fb-56d1-a211-06f66c217a17', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 12-13
Questions 12-13
Answer the questions below using
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
12-13
on your answer sheet
12.
What environmental problem does the unique root system of bamboo prevent?
12
Locate
13.
Which bamboo product is experiencing market expansion?
13
Locate

12. What environmental problem does the unique root system of bamboo prevent? 12 ____ Locate 13. Which bamboo product is experiencing market expansion? 13 ____ Locate$md$, NULL, ARRAY['.*soil.*erosion.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2a78b6b1-39e7-51b2-bd6d-fee1ce7012e8', 'ff1f9b94-a3ee-5adc-9601-a2a5cd857be2', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 12-13
Questions 12-13
Answer the questions below using
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
12-13
on your answer sheet
12.
What environmental problem does the unique root system of bamboo prevent?
12
Locate
13.
Which bamboo product is experiencing market expansion?
13
Locate

12. What environmental problem does the unique root system of bamboo prevent? 12 ____ Locate 13. Which bamboo product is experiencing market expansion? 13 ____ Locate$md$, NULL, ARRAY['.*soil.*erosion.*']);

COMMIT;
