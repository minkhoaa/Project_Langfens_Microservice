BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-fueling-the-future-1205'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-fueling-the-future-1205';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-fueling-the-future-1205';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-fueling-the-future-1205';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('a492f8c1-ec1f-51f4-9688-d5456b9c0d40', 'ielts-reading-fueling-the-future-1205', $t$FUELING THE FUTURE$t$, $md$## FUELING THE FUTURE

Nguồn:
- Test: https://mini-ielts.com/1205/reading/fueling-the-future
- Solution: https://mini-ielts.com/1205/view-solution/reading/fueling-the-future$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 'a492f8c1-ec1f-51f4-9688-d5456b9c0d40', 1, $t$Reading — FUELING THE FUTURE$t$, $md$Read the passage and answer questions **1–14**.

### Passage: FUELING THE FUTURE

The world’s 750 million motor vehicles emit well over 900 million metric tonnes of carbon dioxide each year. Traffic-related air pollution has been responsible for 6% of deaths per year and is associated with certain forms of leukaemia, inflammatory lung diseases, increased cardio-vascular disease, low birth-weight babies and male infertility. It stands to reason that tackling traffic- related air pollution should be high on any government’s list of priorities. Thus, in an attempt to minimise this situation many governments around the world have been looking at ways to implement alternative fuel sources. The most widely accepted way of doing this is to replace the crude oil that our vehicles currently run on with renewable, ‘environmentally friendly ’ One serious contender put forward as a solution to the pollution problem is ethanol.

Ethanol is a type of alcohol made by fermenting plant material. Water and organic matter from the plants including com, sorghum, sugar cane and wood are mixed together and fermented to make ethanol. After fermentation there are three layers remaining. The first is water and small particles of grain and alcohol. It takes on a syrup consistency. The second layer is the remaining grain, which is 17 per cent dry matter. The third layer is the actual ethanol – a colourless, volatile, flammable liquid. It is the only layer sold and accounts for exactly one-third of the total dry matter used for its production. There are three primary ways that it is used as a fuel for transportation: as a blend of 10 per cent ethanol with 90% unleaded fuel (E10); as a component of reformulated gasoline and; as a primary fuel with 85 parts of ethanol blended with 15 parts of unleaded fuel (E-85). In the 1800s in the USA, it was first used as lamp fuel. Later on , due to skyrocketing oil prices in the 1970s, E10 was produced as a type of ‘fuel-extender’ for vehicles with E-85 being produced in the 1990s. Brazil has also used ethanol-blended fuels. Like America, the high prices in the 1970s prompted a government mandate to produce vehicles which could be fuelled by pure ethanol Today there are more than 4,2 million ethanol- powered vehicles in Brazil (40 per cent passenger carrying) which consume 4 billion gallons of ethanol annually. Today, Brazil is the largest transportation ethanol fuel market in the world .

Given that Ethanol is made from a variety of plant substances when it is used in fuel production, it increases the monetary value of feed grains grown by farmers. In fact, in the USA, the largest ethanol consuming nation in the world, ethanol production adds £4.5 billion to the farm economy every year . According to the United States Department of Agriculture, ethanol production adds 30 cents to the value of a bushel of corn. Another of its benefits, according to Brian Keating, deputy chief of Australia’s Commonwealth Scientific and Industrial Research Organisation (CSIRO) is that a 10% ethanol blend (E10) would reduce greenhouse gas emissions by 2 to 5% over the full lifecycle of ethanol production and consumption. Said Keating, “The precise benefits depend on specific factors in the production cycle. An important component of which is the energy source used by the ethanol factory. If it’s being powered by coal or oil, there are obviously associated greenhouse gas emissions.” In America, The Clean Air Act of 1990 and the National Energy Policy Act of 1992 have both created new market opportunities for cleaner, more efficient fuels with many state governments in America’s Mid-west purchasing fleet vehicles capable of running on E-85 fuels.

Although it makes a good fuel, some drawbacks have been documented. The economics of ethanol production are improving as the technology improves but ethanol has two problems: It does not explode like gasoline, and it can absorb water, which can cause oxidation, rust and corrosion. The claims of possible damage to vehicles from the use of ethanol blends above 10% has therefore attracted considerable negative publicity. Compared to diesel – the standard fuel in the heavy moving industry – ethanol is known to have a lower energy content so ethanol trucks require larger fuel tanks to achieve the same range as a diesel-powered vehicle . In Australia, a government review’ into the impacts of a 20% ethanol blend on vehicles found the information to be insufficient or conflicting, but did identify a number of problems such as the possible perishing and swelling of elastomeric and plastic materials in fuel systems. Stakeholders in the motor vehicle industry have slated that warranties on motor vehicles and pump dispensing equipment could be at risk with the use of blends above 10% ethanol. Principle economist for the Australian Bureau of Agriculture Andrew Dickson points out that the money sugarcane growers get for their cane is not determined by the domestic consumption or domestic demand for ethanol , it is entirely determined by the world sugar market and the world trade in molasses He believes that the only way the sugar industry’ can benefit from the existence of an ethanol industry is if they invest in the ethanol industry. “The sugar producer does not get any more money for their molasses so what incentive do they have to produce any more?.” The cost of production also represents some challenges. In Australia, fuel ethanol costs around 70 cents per litre compared with around 35 cents per litre for unleaded petrol. In America, one report revealed that even with government assistance, ethanol is dose to 35 per cent more than the price of diesel. Consequently, production of ethanol requires government assistance to be competitive. A recent study by the Australian Bureau of Agricultural and Resource Economies found that without assistance, large-scale production of ethanol would not be commercially viable in Australia.

Regardless of whether the Australian sugar industry will benefit from a mandated 10% ethanol mix, the expansion of ethanol production would certainly lead to increased economic activity in farming areas. It is inevitable that some expansion would be at the expense of existing industry. If ethanol becomes more popular, there will soon be more plants producing it. This means there will be a need for workers for the plants. The American National Ethanol Vehicle Coalition (NBVC) projects that employment will be boosted by 200,000 jobs and the balance of trade will be improved by over $2 The future of ethanol looks promising, for better or worse ethanol looks to be a serious contender for tomorrow’s fuel.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('00f67a33-1efd-545e-bdbb-26257f992f93', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 1, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1
-5
on your answer sheet write
YES
if the statement reflects the claims of the
writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
The need to control air pollution is why ethanol came into use.
Locate
2
Brazil uses more ethanol for transportation than America.
Locate
3
Select food crops become more expensive due to ethanol production
Locate
4
The Australian sugar industry will benefit from the production of ethanol.
Locate
5
Primary ethanol (E-85) has been extensively tested in Australia.

1 ____ The need to control air pollution is why ethanol came into use. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb023729-aba3-5533-9dc2-05545e709fe3', '00f67a33-1efd-545e-bdbb-26257f992f93', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b864c538-2c80-512f-9b47-533824c402e2', '00f67a33-1efd-545e-bdbb-26257f992f93', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23239a51-bfd2-5a10-af37-01727dd06914', '00f67a33-1efd-545e-bdbb-26257f992f93', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('49e3484c-d631-535f-89b9-1f758dd7a233', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 2, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1
-5
on your answer sheet write
YES
if the statement reflects the claims of the
writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
The need to control air pollution is why ethanol came into use.
Locate
2
Brazil uses more ethanol for transportation than America.
Locate
3
Select food crops become more expensive due to ethanol production
Locate
4
The Australian sugar industry will benefit from the production of ethanol.
Locate
5
Primary ethanol (E-85) has been extensively tested in Australia.

2 ____ Brazil uses more ethanol for transportation than America. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b904420d-130c-5cfa-90a6-26a6c1d61392', '49e3484c-d631-535f-89b9-1f758dd7a233', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e448f16c-6ac5-55f8-9322-2336c6c5a149', '49e3484c-d631-535f-89b9-1f758dd7a233', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc9b13f6-5fb7-567a-bbb0-8b097f2d687c', '49e3484c-d631-535f-89b9-1f758dd7a233', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5c6d78c9-4ce4-5d2b-aa10-db1be15afd60', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 3, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1
-5
on your answer sheet write
YES
if the statement reflects the claims of the
writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
The need to control air pollution is why ethanol came into use.
Locate
2
Brazil uses more ethanol for transportation than America.
Locate
3
Select food crops become more expensive due to ethanol production
Locate
4
The Australian sugar industry will benefit from the production of ethanol.
Locate
5
Primary ethanol (E-85) has been extensively tested in Australia.

3 ____ Select food crops become more expensive due to ethanol production Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3271139-3a26-5987-93af-5f0c8392dc7e', '5c6d78c9-4ce4-5d2b-aa10-db1be15afd60', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c92ffcc-6de2-575f-bbd8-fb83ff118edf', '5c6d78c9-4ce4-5d2b-aa10-db1be15afd60', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('962fcb25-240b-52c0-9d6f-152449864f69', '5c6d78c9-4ce4-5d2b-aa10-db1be15afd60', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('353c30a7-5174-5174-9f78-df918b9d6e3b', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1
-5
on your answer sheet write
YES
if the statement reflects the claims of the
writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
The need to control air pollution is why ethanol came into use.
Locate
2
Brazil uses more ethanol for transportation than America.
Locate
3
Select food crops become more expensive due to ethanol production
Locate
4
The Australian sugar industry will benefit from the production of ethanol.
Locate
5
Primary ethanol (E-85) has been extensively tested in Australia.

4 ____ The Australian sugar industry will benefit from the production of ethanol. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85ee18a6-8dc4-57dd-9a5e-e42e749ec3e9', '353c30a7-5174-5174-9f78-df918b9d6e3b', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a28e6456-b1d5-5ad8-92ff-8197fa9e062d', '353c30a7-5174-5174-9f78-df918b9d6e3b', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b12301d7-bed9-5753-be90-516246fa6441', '353c30a7-5174-5174-9f78-df918b9d6e3b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('898b8926-d6ca-5c83-a208-4ea3e5a589a6', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1
-5
on your answer sheet write
YES
if the statement reflects the claims of the
writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
The need to control air pollution is why ethanol came into use.
Locate
2
Brazil uses more ethanol for transportation than America.
Locate
3
Select food crops become more expensive due to ethanol production
Locate
4
The Australian sugar industry will benefit from the production of ethanol.
Locate
5
Primary ethanol (E-85) has been extensively tested in Australia.

5 ____ Primary ethanol (E-85) has been extensively tested in Australia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebd8ce44-8d6b-54d6-8b16-851ffd9ec679', '898b8926-d6ca-5c83-a208-4ea3e5a589a6', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ef7731a-ad80-506b-8329-092ee48d53ba', '898b8926-d6ca-5c83-a208-4ea3e5a589a6', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79d5c96b-0fb5-58fa-828e-0a4bf8279953', '898b8926-d6ca-5c83-a208-4ea3e5a589a6', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0a7a5c09-c125-5f77-ba95-16ecb1bd7e1b', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Look at the following list of descriptions (Questions
6-9
) and the list of fuel
types
below.
Match each description to the fuel type.
Write the correct letter
A-D
in boxes
6-9
on your answer sheet.
NB
You
may use any letter
more than once
.
A
. regular gasoline
B
. unleaded gasoline
C
. ethanol
D
. diesel
6
.
costs about half the price of ethanol
Locate
7
. reacts poorly with some metals
Locate
8
. is the reason why trucks have been fitted with larger fuel tanks
Locate
9
. commonly used in the trucking industry
Locate

6 ____ . costs about half the price of ethanol Locate$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('39783830-569b-5a85-83fc-f9e2b085beb9', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Look at the following list of descriptions (Questions
6-9
) and the list of fuel
types
below.
Match each description to the fuel type.
Write the correct letter
A-D
in boxes
6-9
on your answer sheet.
NB
You
may use any letter
more than once
.
A
. regular gasoline
B
. unleaded gasoline
C
. ethanol
D
. diesel
6
.
costs about half the price of ethanol
Locate
7
. reacts poorly with some metals
Locate
8
. is the reason why trucks have been fitted with larger fuel tanks
Locate
9
. commonly used in the trucking industry
Locate

7 ____ . reacts poorly with some metals Locate$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3653814c-00a2-54ce-8113-1b84c3116d9e', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Look at the following list of descriptions (Questions
6-9
) and the list of fuel
types
below.
Match each description to the fuel type.
Write the correct letter
A-D
in boxes
6-9
on your answer sheet.
NB
You
may use any letter
more than once
.
A
. regular gasoline
B
. unleaded gasoline
C
. ethanol
D
. diesel
6
.
costs about half the price of ethanol
Locate
7
. reacts poorly with some metals
Locate
8
. is the reason why trucks have been fitted with larger fuel tanks
Locate
9
. commonly used in the trucking industry
Locate

8 ____ . is the reason why trucks have been fitted with larger fuel tanks Locate$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a1b89014-5046-5627-98c4-ebc86fe11e2d', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Look at the following list of descriptions (Questions
6-9
) and the list of fuel
types
below.
Match each description to the fuel type.
Write the correct letter
A-D
in boxes
6-9
on your answer sheet.
NB
You
may use any letter
more than once
.
A
. regular gasoline
B
. unleaded gasoline
C
. ethanol
D
. diesel
6
.
costs about half the price of ethanol
Locate
7
. reacts poorly with some metals
Locate
8
. is the reason why trucks have been fitted with larger fuel tanks
Locate
9
. commonly used in the trucking industry
Locate

9 ____ . commonly used in the trucking industry Locate$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('38a00436-339a-5f4e-ab11-de6d952e2557', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Question 10-14
Question 10-14
Classify the following statements according to which country they apply to.
Write the appropriate letters
A-D
in boxes
10-14
on your answer sheet.
A
. Australia only
B
. America only
C
. both Australia and America
D
. neither Australia nor America
10
. makes ethanol out of sugar cane
Locate
11
. uses more ethanol than any other country in the world
Locate
12
. receives government assistance for ethanol production
Locate
13
. proved ethanol production is costly
Locate
14
. their government bought ethanol-friendly cars
Locate

10 ____ . makes ethanol out of sugar cane Locate$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9ecf1f07-ccac-58c3-b59b-00820d1c426d', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Question 10-14
Question 10-14
Classify the following statements according to which country they apply to.
Write the appropriate letters
A-D
in boxes
10-14
on your answer sheet.
A
. Australia only
B
. America only
C
. both Australia and America
D
. neither Australia nor America
10
. makes ethanol out of sugar cane
Locate
11
. uses more ethanol than any other country in the world
Locate
12
. receives government assistance for ethanol production
Locate
13
. proved ethanol production is costly
Locate
14
. their government bought ethanol-friendly cars
Locate

11 ____ . uses more ethanol than any other country in the world Locate$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bab80aed-bbd1-5f32-9634-a12fe06a0587', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Question 10-14
Question 10-14
Classify the following statements according to which country they apply to.
Write the appropriate letters
A-D
in boxes
10-14
on your answer sheet.
A
. Australia only
B
. America only
C
. both Australia and America
D
. neither Australia nor America
10
. makes ethanol out of sugar cane
Locate
11
. uses more ethanol than any other country in the world
Locate
12
. receives government assistance for ethanol production
Locate
13
. proved ethanol production is costly
Locate
14
. their government bought ethanol-friendly cars
Locate

12 ____ . receives government assistance for ethanol production Locate$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('32db579b-4ce0-5e16-bdad-2586dcaec7dd', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Question 10-14
Question 10-14
Classify the following statements according to which country they apply to.
Write the appropriate letters
A-D
in boxes
10-14
on your answer sheet.
A
. Australia only
B
. America only
C
. both Australia and America
D
. neither Australia nor America
10
. makes ethanol out of sugar cane
Locate
11
. uses more ethanol than any other country in the world
Locate
12
. receives government assistance for ethanol production
Locate
13
. proved ethanol production is costly
Locate
14
. their government bought ethanol-friendly cars
Locate

13 ____ . proved ethanol production is costly Locate$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('011c896a-685c-53b6-97cb-eb64b83bcff7', '82d4155f-129b-5ae8-9b7e-aa2a3366fca1', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Question 10-14
Question 10-14
Classify the following statements according to which country they apply to.
Write the appropriate letters
A-D
in boxes
10-14
on your answer sheet.
A
. Australia only
B
. America only
C
. both Australia and America
D
. neither Australia nor America
10
. makes ethanol out of sugar cane
Locate
11
. uses more ethanol than any other country in the world
Locate
12
. receives government assistance for ethanol production
Locate
13
. proved ethanol production is costly
Locate
14
. their government bought ethanol-friendly cars
Locate

14 ____ . their government bought ethanol-friendly cars Locate$md$, NULL);

COMMIT;
