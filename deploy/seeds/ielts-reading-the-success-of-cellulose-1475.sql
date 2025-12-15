BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-success-of-cellulose-1475'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-success-of-cellulose-1475';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-success-of-cellulose-1475';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-success-of-cellulose-1475';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('8f03afa7-6c0f-59f2-9ed6-cbcf16fae42d', 'ielts-reading-the-success-of-cellulose-1475', $t$The success of cellulose$t$, $md$## The success of cellulose

Nguồn:
- Test: https://mini-ielts.com/1475/reading/the-success-of-cellulose
- Solution: https://mini-ielts.com/1475/view-solution/reading/the-success-of-cellulose$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1176d471-e878-5de3-a1ab-85aad6a53f61', '8f03afa7-6c0f-59f2-9ed6-cbcf16fae42d', 1, $t$Reading — The success of cellulose$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The success of cellulose

{A} Not too long ago many investors made the bet that renewable fuels from bio-mass would be the next big thing in energy. Converting corn, sugarcane, and soybeans into ethanol or diesel-type fuels lessens our nation’s dependence on oil imports while cutting carbon dioxide emissions. But already the nascent industry faces challenges. Escalating demand is hiking food prices while farmers clear rainforest habitats to grow fuel crops. And several recent studies say that certain biofuel-production processes either fail to yield net energy gains or release more carbon dioxide than they use.

{B} A successor tier of start-up ventures aims to avoid those problems. Rather than focusing on the starches, sugars, and fats of food crops, many of the prototype bioethanol processes work with lignocellulose, the “woody” tissue that strengthens the cell walls of plants, says University of Massachusetts Amherst chemical engineer George W. Huber. Although cellulose breaks down less easily than sugars and starches and thus requires a complex series of enzyme-driven chemical reactions, its use opens the industry to nonfood plant feedstocks such as agricultural wastes, wood chips, and switchgrass. But no company has yet demonstrated a cost-competitive industrial process for making cellulosic biofuels.

{C} So scientists and engineers are working on dozens of possible biofuel-processing routes, reports Charles Wyman, a chemical engineer at the University of California, Riverside, who is a founder of Mascoma Corporation in Cambridge, Mass., a leading developer of cellulosic ethanol processing.” There’s no miracle process out there,” he remarks. And fine-tuning a process involves considerable money and time. “The oil companies say that it takes 10 years to fully commercialize an industrial processing route,” warns Huber, who has contributed some thermochemical techniques to another biomass start-up, Virent Energy Systems in Madison, Wis.

{D} One promising biofuel procedure that avoids the complex enzymatic chemistry to break down cellulose is now being explored by Coskata in Warrenville, Ill., a firm launched in 2006 by high-profile investors and entrepreneurs (General Motors recently took a minority stake in it as well). In the Coskata operation, a conventional gasification system will use heat to turn various feedstocks into a mixture of carbon monoxide and hydrogen called syngas, says Richard Tobey, vice president of Engineering and R&D. The ability to handle multiple plant feedstocks would boost the flexibility of the overall process because each region in the country has access to certain feedstocks but not others.

{E} Instead of using thermochemical methods to convert the syngas to fuel- a process that can be significantly more costly because of the added expense of pressurizing gases, according to Tobey – the Coskata group chose a biochemical route. The group focused on five promising strains of ethanol-excreting bacteria that Ralph Tanner, a microbiologist at the University of Oklahoma, had discovered years before in the oxygen-free sediments of a swamp. These anaerobic bugs make ethanol by voraciously consuming syngas.

{F} The “heart and soul of the Coskata process,” as Tobey puts it, is the bioreactor in which the bacteria live. “Rather than searching for food in the fermentation mash in a large tank, our bacteria wait for the gas to be delivered to them,” he explains. The firm relies on plastic tubes, the filter-fabric straws as thin as human hair. The syngas flows through the straws, and water is pumped across their exteriors. The gases diffuse across the selective membrane to the bacteria embedded in the outer surface of the tubes, which permits no water inside. “We get an efficient mass transfer with the tubes, which is not easy,” Tobey says. “Our data suggest that in an optimal setting we could get 90 percent of the energy value of the gases into our fuel.” After the bugs eat the gases, they release ethanol into the surrounding water. Standard distillation or filtration techniques could extract the alcohol from the water.

{G} Coskata researchers estimate that their commercialized process could deliver ethanol at under $1 per gallon-less than half of today’s $2-per-gallon wholesale price, Tobey claims. Outside evaluators of Argonne National Laboratory measured the input-output “energy balance” of the Coskata process and found that, optimally, it can produce 7.7 times as much energy in the end product as it takes to make it.

{H} The company plans to construct a 40,000-gallon-a-year pilot plant near the GM test track in Milford, Mich., by the end of this year and hopes to build a full-scale, 100-million-gallon-a-year plant by 2011. Coskata may have some company by then; Bioengineering Resources in Fayetteville, Ark., is already developing what seems to be a similar three-step pathway in which syngas is consumed by bacteria isolated by James Gaddy, a retired chemical engineer at the University of Arkansas. Considering the advances in these and other methods, plant cellulose could provide the greener ethanol everyone wants.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af5fdd22-58e7-5525-a639-cf5ab858b398', '1176d471-e878-5de3-a1ab-85aad6a53f61', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-6 on your answer sheet.
NB you may use any letter more than once
(A)
George W. Huber
(B)
James Gaddy
(C)
Richard Tobey
(D)
Charles Wyman
1
A key component to gain success lies in the place where the organisms survive.
2
Engaged in separating fixed procedures to produce ethanol in the homologous biochemical way.
3
Assists to develop certain skills.
4
It needs arduous efforts to achieve highly efficient transfer.
5
There is no shortcut to expedite the production process.
6
A combination of chemistry and biology can considerably lower the cost needed for the production company.

1 ____ A key component to gain success lies in the place where the organisms survive.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7506235-5ae7-5694-9b21-d38ac987b58b', 'af5fdd22-58e7-5525-a639-cf5ab858b398', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ade7aa5-5d2e-599b-9ebf-3a8d7822db13', 'af5fdd22-58e7-5525-a639-cf5ab858b398', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac69f9d0-8a2f-5679-8865-6eb44809d5e1', 'af5fdd22-58e7-5525-a639-cf5ab858b398', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('085b9cf4-8152-5bd3-8cbb-4e8c689bafd4', 'af5fdd22-58e7-5525-a639-cf5ab858b398', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('62025ccf-dae3-55ce-8394-06f794d12f57', '1176d471-e878-5de3-a1ab-85aad6a53f61', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-6 on your answer sheet.
NB you may use any letter more than once
(A)
George W. Huber
(B)
James Gaddy
(C)
Richard Tobey
(D)
Charles Wyman
1
A key component to gain success lies in the place where the organisms survive.
2
Engaged in separating fixed procedures to produce ethanol in the homologous biochemical way.
3
Assists to develop certain skills.
4
It needs arduous efforts to achieve highly efficient transfer.
5
There is no shortcut to expedite the production process.
6
A combination of chemistry and biology can considerably lower the cost needed for the production company.

2 ____ Engaged in separating fixed procedures to produce ethanol in the homologous biochemical way.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c702f1ee-ceb5-562f-b817-a2c848caa1cd', '62025ccf-dae3-55ce-8394-06f794d12f57', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23d7dd60-33cd-5526-95c0-927f3a9bb138', '62025ccf-dae3-55ce-8394-06f794d12f57', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d83abd46-1671-56d5-967f-baf1c52f6374', '62025ccf-dae3-55ce-8394-06f794d12f57', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99342aaa-00ec-51bd-8760-6a1d5dfd1e8b', '62025ccf-dae3-55ce-8394-06f794d12f57', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('97d7aa11-3a83-5d5b-8e2f-1d4c086c529b', '1176d471-e878-5de3-a1ab-85aad6a53f61', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-6 on your answer sheet.
NB you may use any letter more than once
(A)
George W. Huber
(B)
James Gaddy
(C)
Richard Tobey
(D)
Charles Wyman
1
A key component to gain success lies in the place where the organisms survive.
2
Engaged in separating fixed procedures to produce ethanol in the homologous biochemical way.
3
Assists to develop certain skills.
4
It needs arduous efforts to achieve highly efficient transfer.
5
There is no shortcut to expedite the production process.
6
A combination of chemistry and biology can considerably lower the cost needed for the production company.

3 ____ Assists to develop certain skills.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f6639d4-7882-5892-b601-c80c807b9730', '97d7aa11-3a83-5d5b-8e2f-1d4c086c529b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56575dcc-a999-5fe0-a577-d00232a84c3d', '97d7aa11-3a83-5d5b-8e2f-1d4c086c529b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb25ec92-aa22-560b-ad52-f450baa22e43', '97d7aa11-3a83-5d5b-8e2f-1d4c086c529b', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a5e2fb5-2288-58b4-bae7-57eca9a3e9d3', '97d7aa11-3a83-5d5b-8e2f-1d4c086c529b', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b3851fa8-896f-5a9b-9f96-0f26a8181e48', '1176d471-e878-5de3-a1ab-85aad6a53f61', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-6 on your answer sheet.
NB you may use any letter more than once
(A)
George W. Huber
(B)
James Gaddy
(C)
Richard Tobey
(D)
Charles Wyman
1
A key component to gain success lies in the place where the organisms survive.
2
Engaged in separating fixed procedures to produce ethanol in the homologous biochemical way.
3
Assists to develop certain skills.
4
It needs arduous efforts to achieve highly efficient transfer.
5
There is no shortcut to expedite the production process.
6
A combination of chemistry and biology can considerably lower the cost needed for the production company.

4 ____ It needs arduous efforts to achieve highly efficient transfer.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02b5d192-9d85-5024-b6f0-018c457961a7', 'b3851fa8-896f-5a9b-9f96-0f26a8181e48', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2640bc69-6ac6-5df0-9ef1-a88b7ecaecba', 'b3851fa8-896f-5a9b-9f96-0f26a8181e48', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e28cef54-b863-57dd-8c0c-b339f55b030b', 'b3851fa8-896f-5a9b-9f96-0f26a8181e48', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74fcec5c-6029-5e7c-9f84-766faef79590', 'b3851fa8-896f-5a9b-9f96-0f26a8181e48', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('911cbb72-5636-500b-8cb7-a9d357733a2d', '1176d471-e878-5de3-a1ab-85aad6a53f61', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-6 on your answer sheet.
NB you may use any letter more than once
(A)
George W. Huber
(B)
James Gaddy
(C)
Richard Tobey
(D)
Charles Wyman
1
A key component to gain success lies in the place where the organisms survive.
2
Engaged in separating fixed procedures to produce ethanol in the homologous biochemical way.
3
Assists to develop certain skills.
4
It needs arduous efforts to achieve highly efficient transfer.
5
There is no shortcut to expedite the production process.
6
A combination of chemistry and biology can considerably lower the cost needed for the production company.

5 ____ There is no shortcut to expedite the production process.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c255257c-345a-5ff8-a8e4-1b574371d901', '911cbb72-5636-500b-8cb7-a9d357733a2d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f87e2ae0-773f-50e1-8051-43794e00b689', '911cbb72-5636-500b-8cb7-a9d357733a2d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a2eb9d5-392b-5c0f-92f9-e3f13e456c1b', '911cbb72-5636-500b-8cb7-a9d357733a2d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd06439c-f2c5-5e1c-8d25-9e4d656f0204', '911cbb72-5636-500b-8cb7-a9d357733a2d', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2158248c-f3a0-5112-9d47-fa2337b82bbc', '1176d471-e878-5de3-a1ab-85aad6a53f61', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Use the information in the passage to match the people (listed A-D) with opinions or deeds below. Write the appropriate letters A-D in boxes 1-6 on your answer sheet.
NB you may use any letter more than once
(A)
George W. Huber
(B)
James Gaddy
(C)
Richard Tobey
(D)
Charles Wyman
1
A key component to gain success lies in the place where the organisms survive.
2
Engaged in separating fixed procedures to produce ethanol in the homologous biochemical way.
3
Assists to develop certain skills.
4
It needs arduous efforts to achieve highly efficient transfer.
5
There is no shortcut to expedite the production process.
6
A combination of chemistry and biology can considerably lower the cost needed for the production company.

6 ____ A combination of chemistry and biology can considerably lower the cost needed for the production company.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bad1e61-d149-51a4-a03b-022d0954be3a', '2158248c-f3a0-5112-9d47-fa2337b82bbc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('421bddd8-4b0d-529a-bfee-847452ce57d8', '2158248c-f3a0-5112-9d47-fa2337b82bbc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef88b5d8-df5f-5252-b1aa-4591b6414e74', '2158248c-f3a0-5112-9d47-fa2337b82bbc', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7191aa9a-1984-589a-bb47-7f2a773a2da6', '2158248c-f3a0-5112-9d47-fa2337b82bbc', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6685b163-96fb-500d-b466-e5a50640cbfd', '1176d471-e878-5de3-a1ab-85aad6a53f61', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage 1? In boxes 7-10 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
7
A shift from conventionally targeted areas of the vegetation to get ethanol takes place.
8
It takes a considerably long way before a completely mature process is reached.
9
The Coskata group sees no bright future for the cost advantage available in the production of greener ethanol.
10
Some enterprises are trying to buy the shares of Coskata group.

7 ____ A shift from conventionally targeted areas of the vegetation to get ethanol takes place.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7f9f80d-ab87-5985-9ade-df4981af593a', '6685b163-96fb-500d-b466-e5a50640cbfd', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90b3100c-e683-52e3-b233-8ec8a29d9dfb', '6685b163-96fb-500d-b466-e5a50640cbfd', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c8dc8fc-acab-5e89-89a0-cd2745b5bf03', '6685b163-96fb-500d-b466-e5a50640cbfd', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('30393303-2940-5826-b8fe-63af46eb0ae8', '1176d471-e878-5de3-a1ab-85aad6a53f61', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage 1? In boxes 7-10 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
7
A shift from conventionally targeted areas of the vegetation to get ethanol takes place.
8
It takes a considerably long way before a completely mature process is reached.
9
The Coskata group sees no bright future for the cost advantage available in the production of greener ethanol.
10
Some enterprises are trying to buy the shares of Coskata group.

8 ____ It takes a considerably long way before a completely mature process is reached.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d23d8dca-60bf-5628-839a-422fb727d03b', '30393303-2940-5826-b8fe-63af46eb0ae8', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e73a6803-ad65-53e2-9952-2c10c58a0df7', '30393303-2940-5826-b8fe-63af46eb0ae8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd3cea41-b4b9-5ed0-8d3c-cc7029a8d5b4', '30393303-2940-5826-b8fe-63af46eb0ae8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('376e4df4-2c06-5a2a-8c55-81c1463ee8fe', '1176d471-e878-5de3-a1ab-85aad6a53f61', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage 1? In boxes 7-10 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
7
A shift from conventionally targeted areas of the vegetation to get ethanol takes place.
8
It takes a considerably long way before a completely mature process is reached.
9
The Coskata group sees no bright future for the cost advantage available in the production of greener ethanol.
10
Some enterprises are trying to buy the shares of Coskata group.

9 ____ The Coskata group sees no bright future for the cost advantage available in the production of greener ethanol.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('274e770f-d6c6-580a-81fd-bf802391ee1e', '376e4df4-2c06-5a2a-8c55-81c1463ee8fe', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6c8709e-a6c4-5b97-9f86-68e93c3c9e84', '376e4df4-2c06-5a2a-8c55-81c1463ee8fe', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6712737-e51e-53de-91d9-99ec266a980c', '376e4df4-2c06-5a2a-8c55-81c1463ee8fe', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6766ac8d-f8ee-5b6c-a08a-54cc88823be5', '1176d471-e878-5de3-a1ab-85aad6a53f61', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage 1? In boxes 7-10 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
7
A shift from conventionally targeted areas of the vegetation to get ethanol takes place.
8
It takes a considerably long way before a completely mature process is reached.
9
The Coskata group sees no bright future for the cost advantage available in the production of greener ethanol.
10
Some enterprises are trying to buy the shares of Coskata group.

10 ____ Some enterprises are trying to buy the shares of Coskata group.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7c2a797-14f6-5b52-9331-121a775d7bf0', '6766ac8d-f8ee-5b6c-a08a-54cc88823be5', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d07daa4-b1fd-520c-9a3d-1b524657d173', '6766ac8d-f8ee-5b6c-a08a-54cc88823be5', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('574a0f5b-2f7a-5c90-8fcd-0f3eee201bb7', '6766ac8d-f8ee-5b6c-a08a-54cc88823be5', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('67f7f12f-04b1-5d1f-bc01-c7ec2112a341', '1176d471-e878-5de3-a1ab-85aad6a53f61', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Summary
Complete the following summary of the paragraphs of Reading Passage,
using
No More than Three words
from the Reading Passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
Tobey has noticed that the Coskata process can achieve huge success because it utilizes
11
as the bioreactor on whose exterior surface the bacteria take the syngas going through the coated
12
. To produce the ethanol into the water outside which researchers will later
13
by certain techniques. The figures show a pretty high percentage of energy can be transferred into fuel which is actually very difficult to achieve.

Tobey has noticed that the Coskata process can achieve huge success because it utilizes 11 ____ as the bioreactor on whose exterior surface the bacteria take the syngas going through the coated 12 ____ . To produce the ethanol into the water outside which researchers will later 13 ____ by certain techniques. The figures show a pretty high percentage of energy can be transferred into fuel which is actually very difficult to achieve.$md$, NULL, ARRAY['.*plastic.*tubes.*the.*filter.*fabric.*straws.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ebeacd90-a71c-591b-999e-76e54e4b81e3', '1176d471-e878-5de3-a1ab-85aad6a53f61', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Summary
Complete the following summary of the paragraphs of Reading Passage,
using
No More than Three words
from the Reading Passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
Tobey has noticed that the Coskata process can achieve huge success because it utilizes
11
as the bioreactor on whose exterior surface the bacteria take the syngas going through the coated
12
. To produce the ethanol into the water outside which researchers will later
13
by certain techniques. The figures show a pretty high percentage of energy can be transferred into fuel which is actually very difficult to achieve.

Tobey has noticed that the Coskata process can achieve huge success because it utilizes 11 ____ as the bioreactor on whose exterior surface the bacteria take the syngas going through the coated 12 ____ . To produce the ethanol into the water outside which researchers will later 13 ____ by certain techniques. The figures show a pretty high percentage of energy can be transferred into fuel which is actually very difficult to achieve.$md$, NULL, ARRAY['.*plastic.*tubes.*the.*filter.*fabric.*straws.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9e044532-ac40-5445-a4c0-703d3be07d66', '1176d471-e878-5de3-a1ab-85aad6a53f61', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Summary
Complete the following summary of the paragraphs of Reading Passage,
using
No More than Three words
from the Reading Passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
Tobey has noticed that the Coskata process can achieve huge success because it utilizes
11
as the bioreactor on whose exterior surface the bacteria take the syngas going through the coated
12
. To produce the ethanol into the water outside which researchers will later
13
by certain techniques. The figures show a pretty high percentage of energy can be transferred into fuel which is actually very difficult to achieve.

Tobey has noticed that the Coskata process can achieve huge success because it utilizes 11 ____ as the bioreactor on whose exterior surface the bacteria take the syngas going through the coated 12 ____ . To produce the ethanol into the water outside which researchers will later 13 ____ by certain techniques. The figures show a pretty high percentage of energy can be transferred into fuel which is actually very difficult to achieve.$md$, NULL, ARRAY['.*plastic.*tubes.*the.*filter.*fabric.*straws.*']);

COMMIT;
