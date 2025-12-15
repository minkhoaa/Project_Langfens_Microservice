BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-antarctic-research--1414'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-antarctic-research--1414';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-antarctic-research--1414';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-antarctic-research--1414';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('b163cac6-c736-5eee-b08d-ecd30cee9ac1', 'ielts-reading-antarctic-research--1414', $t$Antarctic Research$t$, $md$## Antarctic Research

Nguồn:
- Test: https://mini-ielts.com/1414/reading/antarctic-research-
- Solution: https://mini-ielts.com/1414/view-solution/reading/antarctic-research-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('414a7bf7-8d8b-529d-b211-6f3034129c4e', 'b163cac6-c736-5eee-b08d-ecd30cee9ac1', 1, $t$Reading — Antarctic Research$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Antarctic Research

A A little over a century ago, men of the ilk of Scott, Shackleton and Mawson battled against Antarctica’s blizzards, cold and deprivation. In the name of Empire and in an age of heroic deeds they created an image of Antarctica that was to last well into the 20th century – an image of remoteness, hardship, bleakness and isolation that was the province of only the most courageous of men. The image was one of a place removed from everyday reality, of a place with no apparent value to anyone.

B As we enter the 21st century, our perception of Antarctica has changed. Although physically Antarctica is no closer and probably no warmer, and to spend time there still demands a dedication not seen in ordinary life, the continent and its surrounding ocean are increasingly seen to an integral part of Planet Earth, and a key component in the Earth System. Is this because the world seems a little smaller these days, shrunk by TV and tourism, or is it because Antarctica really does occupy a central spot on Earth’s mantle? Scientific research during the past half-century has revealed – and continues to reveal – that Antarctica’s great mass and low temperature exert a major influence on climate and ocean circulation, factors which influence the lives of millions of people all over the globe.

C Antarctica was not always cold. The slow break-up of the super-continent Gondwana with the northward movements of Africa, South America, India and Australia eventually created enough space around Antarctica for the development of an Antarctic Circumpolar Current (ACC), that flowed from west to east under the influence of the prevailing westerly winds. Antarctica cooled, its vegetation perished, glaciation began and the continent took on its present-day appearance. Today the ice that overlies the bedrock is up to 4km thick, and surface temperatures as low as – 89.2deg C have been recorded. The icy blast that howls over the ice cap and out to sea – the so-called katabatic wind – can reach 300 km/hr, creating fearsome wind-chill effects.

D Out of this extreme environment come some powerful forces that reverberate around the world. The Earth’s rotation, coupled to the generation of cells of low pressure off the Antarctic coast, would allow Astronauts a view of Antarctica that is as beautiful as it is awesome. Spinning away to the northeast, the cells grow and deepen, whipping up the Southern Ocean into the mountainous seas so respected by mariners. Recent work is showing that the temperature of the ocean may be a better predictor of rainfall in Australia than is the pressure difference between Darwin and Tahiti – the Southern Oscillation Index. By receiving more accurate predictions, graziers in northern Queensland are able to avoid overstocking in years when rainfall will be poor. Not only does this limit their losses but it prevents serious pasture degradation that may take decades to repair. CSIRO is developing this as a prototype forecasting system, but we can confidently predict that as we know more about the Antarctic and the Southern Ocean we will be able to enhance and extend our predictive ability.

E The ocean’s surface temperature results from the interplay between deep-water temperature, air temperature and ice. Each winter between 4 and 19 million square km of sea ice form, locking up huge quantities of heat close to the continent. Only now can we start to unravel the influence of sea ice on the weather that is experienced in southern Australia. But in another way, the extent of sea ice extends its influence far beyond Antarctica. Antarctic krill – the small shrimp-like crustaceans that are the staple diet for baleen whales, penguins, some seals, flighted sea birds and many fish – breed well in years when sea ice is extensive and poorly when it is not. Many species of baleen whales and flighted sea birds migrate between the hemispheres and when the krill are less abundant they do not thrive.

F The circulatory system of the world’s oceans is like a huge conveyor belt, moving water and dissolved minerals and nutrients from one hemisphere to the other, and from the ocean’s abyssal depths to the surface. The ACC is the longest current in the world and has the largest flow. Through it, the deep flows of the Atlantic, Indian and Pacific Oceans are joined to form part of single global thermohaline circulation. During winter, the howling katabatics sometimes scour the ice off patches of the sea’s surface leaving large ice-locked lagoons, or ‘polynyas’. Recent research has shown that as fresh sea ice forms, it is continuously stripped away by the wind and maybe blown up to 90km in a single day. Since only freshwater freezes into ice, the water that remains becomes increasingly salty and dense, sinking until it spills over the continental shelf. Coldwater carries more oxygen than warm water, so when it rises, well into the northern hemisphere, it reoxygenates and revitalises the ocean. The state of the northern oceans and their biological productivity owe much to what happens in the Antarctic.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a076b4d8-cf42-583b-852d-04a7be99f642', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs A-F
Which paragraph contains the following information?
Write the correct letter A-F, in boxes 1-5 on your answer sheet.
1
The example of research on weather prediction on agriculture
2
Antarctic sea ice brings life back to the world oceans’ vitality.
3
A food chain that influences the animals living pattern based on Antarctic fresh sea ice
4
The explanation of how atmosphere pressure above Antarctica can impose an effect on global climate change
5
Antarctica was once thought to be a forgotten and insignificant continent

1 ____ The example of research on weather prediction on agriculture 2 ____ Antarctic sea ice brings life back to the world oceans’ vitality. 3 ____ A food chain that influences the animals living pattern based on Antarctic fresh sea ice 4 ____ The explanation of how atmosphere pressure above Antarctica can impose an effect on global climate change 5 ____ Antarctica was once thought to be a forgotten and insignificant continent$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba191f83-a955-5a50-ac87-0d43785566c6', 'a076b4d8-cf42-583b-852d-04a7be99f642', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee679219-f799-5b76-863f-70405c8ed8c4', 'a076b4d8-cf42-583b-852d-04a7be99f642', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('755b3b40-e501-5815-aace-e734d9e2d3af', 'a076b4d8-cf42-583b-852d-04a7be99f642', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb818ae9-a9fc-5971-98eb-c22f309bab1d', 'a076b4d8-cf42-583b-852d-04a7be99f642', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e516e6b-306d-5dc3-a0fd-58505a0953db', 'a076b4d8-cf42-583b-852d-04a7be99f642', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bba620d-ee56-5982-9e0f-b896b9fa32cc', 'a076b4d8-cf42-583b-852d-04a7be99f642', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('956a69b0-139f-55a6-9b1e-cc5330e251b8', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs A-F
Which paragraph contains the following information?
Write the correct letter A-F, in boxes 1-5 on your answer sheet.
1
The example of research on weather prediction on agriculture
2
Antarctic sea ice brings life back to the world oceans’ vitality.
3
A food chain that influences the animals living pattern based on Antarctic fresh sea ice
4
The explanation of how atmosphere pressure above Antarctica can impose an effect on global climate change
5
Antarctica was once thought to be a forgotten and insignificant continent

1 ____ The example of research on weather prediction on agriculture 2 ____ Antarctic sea ice brings life back to the world oceans’ vitality. 3 ____ A food chain that influences the animals living pattern based on Antarctic fresh sea ice 4 ____ The explanation of how atmosphere pressure above Antarctica can impose an effect on global climate change 5 ____ Antarctica was once thought to be a forgotten and insignificant continent$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48d9ec05-f2ec-53bb-b772-a6bdc11b2d8c', '956a69b0-139f-55a6-9b1e-cc5330e251b8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5da29ba9-da88-5bc3-8928-adeadf0ec912', '956a69b0-139f-55a6-9b1e-cc5330e251b8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9cb174a-7e15-5071-9db0-99092351ebe1', '956a69b0-139f-55a6-9b1e-cc5330e251b8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7733541a-4e62-5d6a-aa79-ce5d79b29fbd', '956a69b0-139f-55a6-9b1e-cc5330e251b8', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a18b0e7-fe20-5de1-bb96-82eee659c70e', '956a69b0-139f-55a6-9b1e-cc5330e251b8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ed2f503-0612-5766-a3cd-c72d0a5c440f', '956a69b0-139f-55a6-9b1e-cc5330e251b8', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8366d5b6-a0d9-5632-9cb5-04d568553c3b', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs A-F
Which paragraph contains the following information?
Write the correct letter A-F, in boxes 1-5 on your answer sheet.
1
The example of research on weather prediction on agriculture
2
Antarctic sea ice brings life back to the world oceans’ vitality.
3
A food chain that influences the animals living pattern based on Antarctic fresh sea ice
4
The explanation of how atmosphere pressure above Antarctica can impose an effect on global climate change
5
Antarctica was once thought to be a forgotten and insignificant continent

1 ____ The example of research on weather prediction on agriculture 2 ____ Antarctic sea ice brings life back to the world oceans’ vitality. 3 ____ A food chain that influences the animals living pattern based on Antarctic fresh sea ice 4 ____ The explanation of how atmosphere pressure above Antarctica can impose an effect on global climate change 5 ____ Antarctica was once thought to be a forgotten and insignificant continent$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bac14297-34d7-5000-9e28-2140418b3435', '8366d5b6-a0d9-5632-9cb5-04d568553c3b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9326cb05-fe15-583f-8748-4565684cc18d', '8366d5b6-a0d9-5632-9cb5-04d568553c3b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1b090da-9414-5d01-be2d-c011a0edab37', '8366d5b6-a0d9-5632-9cb5-04d568553c3b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48c433c5-d125-5b2a-ab67-a5f4b628e3a3', '8366d5b6-a0d9-5632-9cb5-04d568553c3b', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c6ca7cb-45ed-517d-af14-f56c6dc17a3c', '8366d5b6-a0d9-5632-9cb5-04d568553c3b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99f2a0d6-6625-5ac4-b650-916079645821', '8366d5b6-a0d9-5632-9cb5-04d568553c3b', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c9394260-15e4-59e5-a34f-af08ae555e06', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs A-F
Which paragraph contains the following information?
Write the correct letter A-F, in boxes 1-5 on your answer sheet.
1
The example of research on weather prediction on agriculture
2
Antarctic sea ice brings life back to the world oceans’ vitality.
3
A food chain that influences the animals living pattern based on Antarctic fresh sea ice
4
The explanation of how atmosphere pressure above Antarctica can impose an effect on global climate change
5
Antarctica was once thought to be a forgotten and insignificant continent

1 ____ The example of research on weather prediction on agriculture 2 ____ Antarctic sea ice brings life back to the world oceans’ vitality. 3 ____ A food chain that influences the animals living pattern based on Antarctic fresh sea ice 4 ____ The explanation of how atmosphere pressure above Antarctica can impose an effect on global climate change 5 ____ Antarctica was once thought to be a forgotten and insignificant continent$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96caba28-8bc9-594d-860a-9c4a12e21a2c', 'c9394260-15e4-59e5-a34f-af08ae555e06', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00cbe30e-c2ca-57a7-80af-4d098382d5ad', 'c9394260-15e4-59e5-a34f-af08ae555e06', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('792bf13e-b271-56a6-85ec-510153d39be5', 'c9394260-15e4-59e5-a34f-af08ae555e06', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85d1d0a2-51dd-58cf-92ca-5fb06d0760fa', 'c9394260-15e4-59e5-a34f-af08ae555e06', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee096497-ae10-57f2-bcab-4e115b82d38d', 'c9394260-15e4-59e5-a34f-af08ae555e06', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41b4282d-aff3-56ed-b8cf-44262e9580d9', 'c9394260-15e4-59e5-a34f-af08ae555e06', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ff255ec1-6675-57ab-9be2-11b9b028ee32', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs A-F
Which paragraph contains the following information?
Write the correct letter A-F, in boxes 1-5 on your answer sheet.
1
The example of research on weather prediction on agriculture
2
Antarctic sea ice brings life back to the world oceans’ vitality.
3
A food chain that influences the animals living pattern based on Antarctic fresh sea ice
4
The explanation of how atmosphere pressure above Antarctica can impose an effect on global climate change
5
Antarctica was once thought to be a forgotten and insignificant continent

1 ____ The example of research on weather prediction on agriculture 2 ____ Antarctic sea ice brings life back to the world oceans’ vitality. 3 ____ A food chain that influences the animals living pattern based on Antarctic fresh sea ice 4 ____ The explanation of how atmosphere pressure above Antarctica can impose an effect on global climate change 5 ____ Antarctica was once thought to be a forgotten and insignificant continent$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1009e484-b575-5280-9239-d4b297e1a566', 'ff255ec1-6675-57ab-9be2-11b9b028ee32', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1de9c989-1bd3-5787-95f0-bf897a4541ce', 'ff255ec1-6675-57ab-9be2-11b9b028ee32', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e0563f4-6196-5b8d-8d5b-9a51c96b37ae', 'ff255ec1-6675-57ab-9be2-11b9b028ee32', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc234b02-fe87-56de-8a1a-80d97441059e', 'ff255ec1-6675-57ab-9be2-11b9b028ee32', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('604f2fa7-016e-5092-861a-4f4c81039bdf', 'ff255ec1-6675-57ab-9be2-11b9b028ee32', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65ba45a0-9bcf-5e00-a48c-ed51f999e263', 'ff255ec1-6675-57ab-9be2-11b9b028ee32', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e2b1c6ca-ce5d-5ebc-905f-84de964fd6d2', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Question 6-8
Question 6-8
Summary
Please match the natural phenomenon with correct determined factor
Choose the correct answer from the box;
Write the correct letter A-F, in boxes 6-8 on your answer sheet.
6. Globally, mass Antarctica’s size and
6
influence climate change
7.
7
contributory to western wind
8. Southern Oscillation Index based on air pressure can predict
8
in Australia
A
Antarctic Circumpolar Current (ACC)
B
katabatic winds
C
rainfall
D
temperature
E
glaciers
F
pressure

6. Globally, mass Antarctica’s size and 6 ____ influence climate change 7. 7 ____ contributory to western wind 8. Southern Oscillation Index based on air pressure can predict 8 ____ in Australia$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d762087e-c5aa-5c37-a283-1464347e82ca', 'e2b1c6ca-ce5d-5ebc-905f-84de964fd6d2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fe4bf83-9f55-56de-8fbe-93e037a742a6', 'e2b1c6ca-ce5d-5ebc-905f-84de964fd6d2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c26fdbc-5d4c-52cb-b5e1-1fbadbbc8e45', 'e2b1c6ca-ce5d-5ebc-905f-84de964fd6d2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47270b1e-f89b-5519-b545-52d5a8207c74', 'e2b1c6ca-ce5d-5ebc-905f-84de964fd6d2', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3930292c-476e-514a-b469-6b9baa8d92fd', 'e2b1c6ca-ce5d-5ebc-905f-84de964fd6d2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22b43efb-9d46-5513-b0b8-0bebd77ef6f0', 'e2b1c6ca-ce5d-5ebc-905f-84de964fd6d2', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bf2dda0b-20f7-5416-a3e9-8da9808a80a7', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Question 6-8
Question 6-8
Summary
Please match the natural phenomenon with correct determined factor
Choose the correct answer from the box;
Write the correct letter A-F, in boxes 6-8 on your answer sheet.
6. Globally, mass Antarctica’s size and
6
influence climate change
7.
7
contributory to western wind
8. Southern Oscillation Index based on air pressure can predict
8
in Australia
A
Antarctic Circumpolar Current (ACC)
B
katabatic winds
C
rainfall
D
temperature
E
glaciers
F
pressure

6. Globally, mass Antarctica’s size and 6 ____ influence climate change 7. 7 ____ contributory to western wind 8. Southern Oscillation Index based on air pressure can predict 8 ____ in Australia$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f742f9b7-ba42-5947-8822-2a01308d1c7e', 'bf2dda0b-20f7-5416-a3e9-8da9808a80a7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33a37701-c6b4-5b74-b538-916d47b7c3ec', 'bf2dda0b-20f7-5416-a3e9-8da9808a80a7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af8b50e8-df44-5457-9b4b-eb8f64062a9b', 'bf2dda0b-20f7-5416-a3e9-8da9808a80a7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8907a46b-6751-5f02-84bd-619be7dfb143', 'bf2dda0b-20f7-5416-a3e9-8da9808a80a7', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51fb7701-a266-53b9-ac1e-d482c79989dd', 'bf2dda0b-20f7-5416-a3e9-8da9808a80a7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a270aede-06bf-51aa-ba9e-96d8fb6c8e73', 'bf2dda0b-20f7-5416-a3e9-8da9808a80a7', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d0ddbae-97b6-5067-bfe4-c2892013160e', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Question 6-8
Question 6-8
Summary
Please match the natural phenomenon with correct determined factor
Choose the correct answer from the box;
Write the correct letter A-F, in boxes 6-8 on your answer sheet.
6. Globally, mass Antarctica’s size and
6
influence climate change
7.
7
contributory to western wind
8. Southern Oscillation Index based on air pressure can predict
8
in Australia
A
Antarctic Circumpolar Current (ACC)
B
katabatic winds
C
rainfall
D
temperature
E
glaciers
F
pressure

6. Globally, mass Antarctica’s size and 6 ____ influence climate change 7. 7 ____ contributory to western wind 8. Southern Oscillation Index based on air pressure can predict 8 ____ in Australia$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b12b2ba-487c-558d-8cc3-3d45323d1d17', '5d0ddbae-97b6-5067-bfe4-c2892013160e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76647d80-5fd9-5829-90a1-9df96afe52ab', '5d0ddbae-97b6-5067-bfe4-c2892013160e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf42f3d2-602b-51fb-a500-a47d05a4596e', '5d0ddbae-97b6-5067-bfe4-c2892013160e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('612c8c0f-7ae1-5b97-b3f6-9a9fe0ac08e7', '5d0ddbae-97b6-5067-bfe4-c2892013160e', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40f8ab4d-ba90-5ec1-870d-396ec91a330c', '5d0ddbae-97b6-5067-bfe4-c2892013160e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('321bbdb5-2bcd-5c1d-aec9-89891b590e6c', '5d0ddbae-97b6-5067-bfe4-c2892013160e', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bc4d116e-dcb2-5221-a81d-cf2119f3befe', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Choose the correct letter A, B, C or D.
Write your answer in box 22-26 on your answer sheet.
9. In paragraph B, the author wants to tell which of the following truth about the Antarctic?
A
To show Antarctica has been a central topic of global warming in Mass media
B
To illustrate its huge sea ice brings food to million lives to places in the world
C
To show it is the heart and its significance to the global climate and current
D
To illustrate it locates in the central spot on Earth geographically
10. Why do Australian farmers keep an eye on the Antarctic ocean temperature?
A
Help farmers reduce their economic or ecological losses
B
Retrieve grassland decreased in the overgrazing process
C
Prevent animal from dying
D
A cell provides fertilizer for the grassland
11. What is the final effect of katabatic winds?
A
Increase the moving speed of ocean current
B
Increase salt level near the ocean surface
C
Bring fresh ice into southern oceans
D
Pile up the mountainous ice cap respected by mariners
12. The break of the continental shelf is due to the
A
Salt and density increase
B
Salt and density decrease
C
global warming resulting in a rising temperature
D
fresh ice melting into ocean water
13. The decrease in the number of Whales and seabirds is due to
A
killers whales are more active around
B
Sea birds are affected by high sea level salty
C
less sea ice reduces the productivity of food source
D
seals fail to reproduce babies

Choose the correct letter A, B, C or D. Write your answer in box 22-26 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('55a16f7b-4640-5840-8084-ef10fb3d26a5', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Choose the correct letter A, B, C or D.
Write your answer in box 22-26 on your answer sheet.
9. In paragraph B, the author wants to tell which of the following truth about the Antarctic?
A
To show Antarctica has been a central topic of global warming in Mass media
B
To illustrate its huge sea ice brings food to million lives to places in the world
C
To show it is the heart and its significance to the global climate and current
D
To illustrate it locates in the central spot on Earth geographically
10. Why do Australian farmers keep an eye on the Antarctic ocean temperature?
A
Help farmers reduce their economic or ecological losses
B
Retrieve grassland decreased in the overgrazing process
C
Prevent animal from dying
D
A cell provides fertilizer for the grassland
11. What is the final effect of katabatic winds?
A
Increase the moving speed of ocean current
B
Increase salt level near the ocean surface
C
Bring fresh ice into southern oceans
D
Pile up the mountainous ice cap respected by mariners
12. The break of the continental shelf is due to the
A
Salt and density increase
B
Salt and density decrease
C
global warming resulting in a rising temperature
D
fresh ice melting into ocean water
13. The decrease in the number of Whales and seabirds is due to
A
killers whales are more active around
B
Sea birds are affected by high sea level salty
C
less sea ice reduces the productivity of food source
D
seals fail to reproduce babies

Choose the correct letter A, B, C or D. Write your answer in box 22-26 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6d6250fc-e97b-5bbc-9551-57bbc6ed8ed9', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Choose the correct letter A, B, C or D.
Write your answer in box 22-26 on your answer sheet.
9. In paragraph B, the author wants to tell which of the following truth about the Antarctic?
A
To show Antarctica has been a central topic of global warming in Mass media
B
To illustrate its huge sea ice brings food to million lives to places in the world
C
To show it is the heart and its significance to the global climate and current
D
To illustrate it locates in the central spot on Earth geographically
10. Why do Australian farmers keep an eye on the Antarctic ocean temperature?
A
Help farmers reduce their economic or ecological losses
B
Retrieve grassland decreased in the overgrazing process
C
Prevent animal from dying
D
A cell provides fertilizer for the grassland
11. What is the final effect of katabatic winds?
A
Increase the moving speed of ocean current
B
Increase salt level near the ocean surface
C
Bring fresh ice into southern oceans
D
Pile up the mountainous ice cap respected by mariners
12. The break of the continental shelf is due to the
A
Salt and density increase
B
Salt and density decrease
C
global warming resulting in a rising temperature
D
fresh ice melting into ocean water
13. The decrease in the number of Whales and seabirds is due to
A
killers whales are more active around
B
Sea birds are affected by high sea level salty
C
less sea ice reduces the productivity of food source
D
seals fail to reproduce babies

Choose the correct letter A, B, C or D. Write your answer in box 22-26 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d268d018-c671-5ada-a2d1-0005892d09e9', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Choose the correct letter A, B, C or D.
Write your answer in box 22-26 on your answer sheet.
9. In paragraph B, the author wants to tell which of the following truth about the Antarctic?
A
To show Antarctica has been a central topic of global warming in Mass media
B
To illustrate its huge sea ice brings food to million lives to places in the world
C
To show it is the heart and its significance to the global climate and current
D
To illustrate it locates in the central spot on Earth geographically
10. Why do Australian farmers keep an eye on the Antarctic ocean temperature?
A
Help farmers reduce their economic or ecological losses
B
Retrieve grassland decreased in the overgrazing process
C
Prevent animal from dying
D
A cell provides fertilizer for the grassland
11. What is the final effect of katabatic winds?
A
Increase the moving speed of ocean current
B
Increase salt level near the ocean surface
C
Bring fresh ice into southern oceans
D
Pile up the mountainous ice cap respected by mariners
12. The break of the continental shelf is due to the
A
Salt and density increase
B
Salt and density decrease
C
global warming resulting in a rising temperature
D
fresh ice melting into ocean water
13. The decrease in the number of Whales and seabirds is due to
A
killers whales are more active around
B
Sea birds are affected by high sea level salty
C
less sea ice reduces the productivity of food source
D
seals fail to reproduce babies

Choose the correct letter A, B, C or D. Write your answer in box 22-26 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('466386e7-36be-524d-b0f5-fdb7b4ecb7e7', '414a7bf7-8d8b-529d-b211-6f3034129c4e', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Choose the correct letter A, B, C or D.
Write your answer in box 22-26 on your answer sheet.
9. In paragraph B, the author wants to tell which of the following truth about the Antarctic?
A
To show Antarctica has been a central topic of global warming in Mass media
B
To illustrate its huge sea ice brings food to million lives to places in the world
C
To show it is the heart and its significance to the global climate and current
D
To illustrate it locates in the central spot on Earth geographically
10. Why do Australian farmers keep an eye on the Antarctic ocean temperature?
A
Help farmers reduce their economic or ecological losses
B
Retrieve grassland decreased in the overgrazing process
C
Prevent animal from dying
D
A cell provides fertilizer for the grassland
11. What is the final effect of katabatic winds?
A
Increase the moving speed of ocean current
B
Increase salt level near the ocean surface
C
Bring fresh ice into southern oceans
D
Pile up the mountainous ice cap respected by mariners
12. The break of the continental shelf is due to the
A
Salt and density increase
B
Salt and density decrease
C
global warming resulting in a rising temperature
D
fresh ice melting into ocean water
13. The decrease in the number of Whales and seabirds is due to
A
killers whales are more active around
B
Sea birds are affected by high sea level salty
C
less sea ice reduces the productivity of food source
D
seals fail to reproduce babies

Choose the correct letter A, B, C or D. Write your answer in box 22-26 on your answer sheet.$md$, NULL);

COMMIT;
