BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-renewable-energy-1330'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-renewable-energy-1330';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-renewable-energy-1330';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-renewable-energy-1330';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('7e35dcb0-b37a-57e6-b2c6-377045a35f63', 'ielts-reading-renewable-energy-1330', $t$Renewable Energy$t$, $md$## Renewable Energy

Nguồn:
- Test: https://mini-ielts.com/1330/reading/renewable-energy
- Solution: https://mini-ielts.com/1330/view-solution/reading/renewable-energy$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('0e6f6f37-2934-506b-a28c-a071b874f80d', '7e35dcb0-b37a-57e6-b2c6-377045a35f63', 1, $t$Reading — Renewable Energy$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Renewable Energy

An insight into the progress in renewable energy research

A

The race is on for the ultimate goal of renewable energy: electricity production at prices that are competitive with coal-fired power stations, but without coal’s pollution. Some new technologies are aiming to be the first to push coal from its position as Australia’s chief source of electricity.

B

At the moment the front-runner in renewable energy is wind technology. According to Peter Bergin of Australian Hydro, one of Australia’s leading wind energy companies, there have been no dramatic changes in windmill design for many years, but the cumulative effects of numerous small improvements have had a major impact on cost. ‘We’re reaping the benefits of 30 years of research in Europe, without have to make the same mistakes that they did,’ Mr Bergin says.

C

Electricity can be produced from coal at around 4 cents per kilowatt-hour, but only if the environmental costs are ignored. ‘Australia has the second cheapest electricity in the world, and this makes it difficult for renewable to compete,’ says Richard Hunter of the Australian Ecogeneration Association (AEA). Nevertheless, the AEA reports: ‘The production cost of a kilowatt-hour of wind power is one-fifth of what it was 20 years ago,’ or around 7 cents per kilowatt-hour.

D

Australian Hydro has dozens of wind monitoring stations across Australia as part of its aim to become Australia’s pre-eminent renewable energy company. Despite all these developments, wind power remains one of the few forms of alternative energy where Australia is nowhere near the global cutting edge, mostly just replicating European designs.

E

While wind may currently lead the way, some consider a number of technologies under development have more potential. In several cases, Australia is at the forefront of global research in the area. Some of them are very site-specific, ensuring that they may never become dominant market players. On the other hand, these newer developments are capable of providing more reliable power, avoiding the major criticism of windmills – the need for back-up on a calm day.

F

One such development uses hot, dry rocks. Deep beneath South Australia, radiation from elements contained in granite heats the rocks. Layers of insulating sedimentation raise the temperatures in some location to 250° centigrade. An Australian firm, Geoenergy, is proposing to pump water 3.5 kilometres into the earth, where it will travel through tiny fissures in the granite, heating up as it goes until it escapes as steam through another drilled hole.

G

No greenhouse gases are produced, but the system needs some additional features if it is to be environmentally friendly. Dr Prue Chopra, a geophysicist at the Australian National University and one of the founders of Geoenergy, note that the steam will bring with it radon gas, along through a heat exchanger and then sent back underground for another cycle. Technically speaking, hot dry rocks are not a renewable source of energy. However, the Australian source is so large it could supply the entire country’s needs for thousands of years at current rates of consumption.

H

Two other proposals for very different ways to harness sun and wind energy have surfaced recently. Progress continues with Australian company EnviroPower’s plans for Australia’s first solar chimney near Mildura, in Victoria. Under this scheme, a tall tower will draw hot air from a greenhouse built to cover the surrounding 5 km². As the air rises, it will drive a turbine* to produce electricity. The solar tower combines three very old technologies – the chimney, the turbine and the greenhouse – to produce something quite new. It is this reliance on proven engineering principles that led Enviropower’s CEO, Richard Davies, to state: There is no doubt this technology will work, none at all.’

I

This year, Enviropower recognized that the quality of sunlight in the Mildura district will require a substantially larger collecting area than was previously thought. However, spokesperson kay Firth says that a new location closer to Mildura will enable Enviropower to balance the increased costs with extra revenue. Besides saving in transmission costs, the new site ‘will mean increased revenue from tourism and use of power for telecommunications. We’ll also be able to use the outer 500 metres for agribusiness.’ Wind speeds closer to the tower will be too high for farming.

J

Another Australian company, Wavetech, is achieving success with ways of harvesting the energy in waves. Wavetech’s invention uses a curved surface to push waves into a chamber, where the flowing water column pushes air back and forth through a turbine. Wavetech was created when Dr Tim Devine offered the idea to the world leader in wave generator manufacturers, who rather surprisingly rejected it. Dr Devine responded by establishing Wavetech and making a number of other improvements to generator design. Wavetech claims that, at appropriate sites, ‘the cost of electricity produced with our technology should be below 4 cents per kilowatt-hour.

K

The diversity of forms of greenhouse – friendly energy under development in Australia is remarkable. However, support on a national level is disappointing. According to Richard Hunter of the AEA, ‘Australia has huge potential for wind, sun and wave technology. We should really be at the forefront, but the reality is we are a long way behind.’$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cdb5d55b-55d7-5c73-9e7c-4751878fabb9', '0e6f6f37-2934-506b-a28c-a071b874f80d', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In Australia, alternative energies are less expensive than conventional electricity.
2
Geoenergy needs to adapt its system to make it less harmful to the environment.
3
Dr Prue Chopra has studied the effects of radon gas on the environment.
4
Hot, dry rocks could provide enough power for the whole of Australia.
5
The new Enviropower facility will keep tourists away.
6
Wavetech was established when its founders were turned down by another company.
7
According to AEA, Australia is a world leader in developing renewable energy.

1 ____ In Australia, alternative energies are less expensive than conventional electricity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('671fd04b-9abd-58b1-bf72-7653d2e31104', 'cdb5d55b-55d7-5c73-9e7c-4751878fabb9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43f2a8ab-3871-54eb-9155-47e22602a137', 'cdb5d55b-55d7-5c73-9e7c-4751878fabb9', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96f97cce-b5a7-5066-88d3-bf613827d3b7', 'cdb5d55b-55d7-5c73-9e7c-4751878fabb9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('db92b584-e225-527a-a6e5-d6d84a79a21d', '0e6f6f37-2934-506b-a28c-a071b874f80d', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In Australia, alternative energies are less expensive than conventional electricity.
2
Geoenergy needs to adapt its system to make it less harmful to the environment.
3
Dr Prue Chopra has studied the effects of radon gas on the environment.
4
Hot, dry rocks could provide enough power for the whole of Australia.
5
The new Enviropower facility will keep tourists away.
6
Wavetech was established when its founders were turned down by another company.
7
According to AEA, Australia is a world leader in developing renewable energy.

2 ____ Geoenergy needs to adapt its system to make it less harmful to the environment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('633e79c4-d85e-53a7-9277-280f8ae4f4da', 'db92b584-e225-527a-a6e5-d6d84a79a21d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be4d5740-39f5-5552-998a-96c457ea3eba', 'db92b584-e225-527a-a6e5-d6d84a79a21d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('771b7163-8dc4-5276-a9a3-687f70fc58c5', 'db92b584-e225-527a-a6e5-d6d84a79a21d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('94f335ea-2ee7-5d6f-8bc3-21d5749d167e', '0e6f6f37-2934-506b-a28c-a071b874f80d', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In Australia, alternative energies are less expensive than conventional electricity.
2
Geoenergy needs to adapt its system to make it less harmful to the environment.
3
Dr Prue Chopra has studied the effects of radon gas on the environment.
4
Hot, dry rocks could provide enough power for the whole of Australia.
5
The new Enviropower facility will keep tourists away.
6
Wavetech was established when its founders were turned down by another company.
7
According to AEA, Australia is a world leader in developing renewable energy.

3 ____ Dr Prue Chopra has studied the effects of radon gas on the environment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b8e3771-a81b-54b4-898d-07d5626507cb', '94f335ea-2ee7-5d6f-8bc3-21d5749d167e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('531e693f-5b93-505d-a47b-f335df00b796', '94f335ea-2ee7-5d6f-8bc3-21d5749d167e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc7c6842-55be-56ca-a281-ca81e83b5742', '94f335ea-2ee7-5d6f-8bc3-21d5749d167e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a4a52d37-e6c9-515e-a009-5598ad2d51f6', '0e6f6f37-2934-506b-a28c-a071b874f80d', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In Australia, alternative energies are less expensive than conventional electricity.
2
Geoenergy needs to adapt its system to make it less harmful to the environment.
3
Dr Prue Chopra has studied the effects of radon gas on the environment.
4
Hot, dry rocks could provide enough power for the whole of Australia.
5
The new Enviropower facility will keep tourists away.
6
Wavetech was established when its founders were turned down by another company.
7
According to AEA, Australia is a world leader in developing renewable energy.

4 ____ Hot, dry rocks could provide enough power for the whole of Australia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4deec94d-2d0f-5198-9146-2ec2b2500f46', 'a4a52d37-e6c9-515e-a009-5598ad2d51f6', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63c518cd-0ab5-5f85-8a2c-5403a37a613e', 'a4a52d37-e6c9-515e-a009-5598ad2d51f6', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('441e6e81-3057-5c2e-bfea-38ec1402854c', 'a4a52d37-e6c9-515e-a009-5598ad2d51f6', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a572c760-142d-5c6a-923d-74829da8632c', '0e6f6f37-2934-506b-a28c-a071b874f80d', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In Australia, alternative energies are less expensive than conventional electricity.
2
Geoenergy needs to adapt its system to make it less harmful to the environment.
3
Dr Prue Chopra has studied the effects of radon gas on the environment.
4
Hot, dry rocks could provide enough power for the whole of Australia.
5
The new Enviropower facility will keep tourists away.
6
Wavetech was established when its founders were turned down by another company.
7
According to AEA, Australia is a world leader in developing renewable energy.

5 ____ The new Enviropower facility will keep tourists away.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1966ad8b-8625-58de-96e8-a8183e647640', 'a572c760-142d-5c6a-923d-74829da8632c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('764a5496-40ea-51dc-933b-546d09db7d3f', 'a572c760-142d-5c6a-923d-74829da8632c', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3463f6d4-4404-5b09-925c-1f8e87a76a35', 'a572c760-142d-5c6a-923d-74829da8632c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('88ca1d9a-d837-5239-9043-6e27a15d6fe8', '0e6f6f37-2934-506b-a28c-a071b874f80d', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In Australia, alternative energies are less expensive than conventional electricity.
2
Geoenergy needs to adapt its system to make it less harmful to the environment.
3
Dr Prue Chopra has studied the effects of radon gas on the environment.
4
Hot, dry rocks could provide enough power for the whole of Australia.
5
The new Enviropower facility will keep tourists away.
6
Wavetech was established when its founders were turned down by another company.
7
According to AEA, Australia is a world leader in developing renewable energy.

6 ____ Wavetech was established when its founders were turned down by another company.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f8380b8-ba68-5768-b4fe-a3e70dd741ae', '88ca1d9a-d837-5239-9043-6e27a15d6fe8', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c67f73ef-689c-53b6-80a5-e92e622f5149', '88ca1d9a-d837-5239-9043-6e27a15d6fe8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10824bb5-dd42-514f-83fb-beb8d50b0660', '88ca1d9a-d837-5239-9043-6e27a15d6fe8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9564701a-1e89-5241-a915-9b837e29dddc', '0e6f6f37-2934-506b-a28c-a071b874f80d', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In Australia, alternative energies are less expensive than conventional electricity.
2
Geoenergy needs to adapt its system to make it less harmful to the environment.
3
Dr Prue Chopra has studied the effects of radon gas on the environment.
4
Hot, dry rocks could provide enough power for the whole of Australia.
5
The new Enviropower facility will keep tourists away.
6
Wavetech was established when its founders were turned down by another company.
7
According to AEA, Australia is a world leader in developing renewable energy.

7 ____ According to AEA, Australia is a world leader in developing renewable energy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93bdadf3-b9a5-5724-a670-3b50b72682f6', '9564701a-1e89-5241-a915-9b837e29dddc', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92d8f383-edea-5688-883e-b6098a0a61c4', '9564701a-1e89-5241-a915-9b837e29dddc', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f513ab7-d6a7-5141-ad57-3094c87a8581', '9564701a-1e89-5241-a915-9b837e29dddc', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9eaca1b9-14fe-5df9-934f-23e40bdfb454', '0e6f6f37-2934-506b-a28c-a071b874f80d', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of companies below.
Match each statement with the correct company,
A-D
.
Write the correct letter,
A-D
, in boxes 8-13 on your answer sheet.
NB
You may use any letter more than once.
8
During the process, harmful substances are prevented from escaping.
9
Water is used to force air through a special device.
10
Techniques used by other countries are being copied.
11
The system can provide services other than energy production.
12
It is planned to force water deep under the ground.
13
Original estimates for part of the project have been revised.
List of Companies
A
Australian Hydro
B
Geoenergy
C
Enviropower
D
Wavetech

8 ____ During the process, harmful substances are prevented from escaping.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72c8adb6-d9f1-54e5-acc5-9c40f6f685e3', '9eaca1b9-14fe-5df9-934f-23e40bdfb454', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ecd4284e-2eac-5125-bce4-bfbc88b6f731', '9eaca1b9-14fe-5df9-934f-23e40bdfb454', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e5bee9a-3546-521d-b898-329896659f0f', '9eaca1b9-14fe-5df9-934f-23e40bdfb454', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ff5534a-21fd-5345-87e5-063f83dfb007', '9eaca1b9-14fe-5df9-934f-23e40bdfb454', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('51a5ff4b-93a8-5ac3-82a1-f1575df1f93e', '0e6f6f37-2934-506b-a28c-a071b874f80d', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of companies below.
Match each statement with the correct company,
A-D
.
Write the correct letter,
A-D
, in boxes 8-13 on your answer sheet.
NB
You may use any letter more than once.
8
During the process, harmful substances are prevented from escaping.
9
Water is used to force air through a special device.
10
Techniques used by other countries are being copied.
11
The system can provide services other than energy production.
12
It is planned to force water deep under the ground.
13
Original estimates for part of the project have been revised.
List of Companies
A
Australian Hydro
B
Geoenergy
C
Enviropower
D
Wavetech

9 ____ Water is used to force air through a special device.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b96f145-90d8-5727-942d-27423244ca23', '51a5ff4b-93a8-5ac3-82a1-f1575df1f93e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bc6d424-a6c6-5295-9b7c-5ad64c953250', '51a5ff4b-93a8-5ac3-82a1-f1575df1f93e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4303e57e-4794-5c33-a000-35b88e14acbf', '51a5ff4b-93a8-5ac3-82a1-f1575df1f93e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a660f5c-81da-5235-8adf-014b855be59d', '51a5ff4b-93a8-5ac3-82a1-f1575df1f93e', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('40e06a93-f669-5bc9-9dad-1d18791ad665', '0e6f6f37-2934-506b-a28c-a071b874f80d', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of companies below.
Match each statement with the correct company,
A-D
.
Write the correct letter,
A-D
, in boxes 8-13 on your answer sheet.
NB
You may use any letter more than once.
8
During the process, harmful substances are prevented from escaping.
9
Water is used to force air through a special device.
10
Techniques used by other countries are being copied.
11
The system can provide services other than energy production.
12
It is planned to force water deep under the ground.
13
Original estimates for part of the project have been revised.
List of Companies
A
Australian Hydro
B
Geoenergy
C
Enviropower
D
Wavetech

10 ____ Techniques used by other countries are being copied.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac9d9f52-88b5-540d-8501-6a754fff8fac', '40e06a93-f669-5bc9-9dad-1d18791ad665', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abbfbb07-9d0a-5382-87b9-b63a893f8f8f', '40e06a93-f669-5bc9-9dad-1d18791ad665', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e578558-fde8-56e6-823e-e82d95a79523', '40e06a93-f669-5bc9-9dad-1d18791ad665', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f4ecc7f-d097-5d2e-bcdc-d7df335ccff4', '40e06a93-f669-5bc9-9dad-1d18791ad665', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0b7db6d2-3cf8-5863-8cca-dd4010da1934', '0e6f6f37-2934-506b-a28c-a071b874f80d', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of companies below.
Match each statement with the correct company,
A-D
.
Write the correct letter,
A-D
, in boxes 8-13 on your answer sheet.
NB
You may use any letter more than once.
8
During the process, harmful substances are prevented from escaping.
9
Water is used to force air through a special device.
10
Techniques used by other countries are being copied.
11
The system can provide services other than energy production.
12
It is planned to force water deep under the ground.
13
Original estimates for part of the project have been revised.
List of Companies
A
Australian Hydro
B
Geoenergy
C
Enviropower
D
Wavetech

11 ____ The system can provide services other than energy production.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9e873af-6df0-5092-9ecf-17433636f2c1', '0b7db6d2-3cf8-5863-8cca-dd4010da1934', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c03462f-5025-5639-b75a-b0f749da67bd', '0b7db6d2-3cf8-5863-8cca-dd4010da1934', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55d85c6e-0f50-5b8d-97c1-08cb422c30d5', '0b7db6d2-3cf8-5863-8cca-dd4010da1934', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('505f458e-6515-5aae-873b-0004d1a24074', '0b7db6d2-3cf8-5863-8cca-dd4010da1934', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a36cc8e5-49c9-574c-b6eb-5216b107af1f', '0e6f6f37-2934-506b-a28c-a071b874f80d', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of companies below.
Match each statement with the correct company,
A-D
.
Write the correct letter,
A-D
, in boxes 8-13 on your answer sheet.
NB
You may use any letter more than once.
8
During the process, harmful substances are prevented from escaping.
9
Water is used to force air through a special device.
10
Techniques used by other countries are being copied.
11
The system can provide services other than energy production.
12
It is planned to force water deep under the ground.
13
Original estimates for part of the project have been revised.
List of Companies
A
Australian Hydro
B
Geoenergy
C
Enviropower
D
Wavetech

12 ____ It is planned to force water deep under the ground.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73d9168b-558a-5a59-9204-b3c2a5d4d8d9', 'a36cc8e5-49c9-574c-b6eb-5216b107af1f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('766df4ae-eeb1-52e0-ba08-50af3c304df6', 'a36cc8e5-49c9-574c-b6eb-5216b107af1f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cac610a3-12d9-50ac-836f-f8d0bf7aa63c', 'a36cc8e5-49c9-574c-b6eb-5216b107af1f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5190c6a-0a52-57ab-a630-62596912d04f', 'a36cc8e5-49c9-574c-b6eb-5216b107af1f', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('afc61103-973a-5577-8b07-d49d1255b489', '0e6f6f37-2934-506b-a28c-a071b874f80d', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of companies below.
Match each statement with the correct company,
A-D
.
Write the correct letter,
A-D
, in boxes 8-13 on your answer sheet.
NB
You may use any letter more than once.
8
During the process, harmful substances are prevented from escaping.
9
Water is used to force air through a special device.
10
Techniques used by other countries are being copied.
11
The system can provide services other than energy production.
12
It is planned to force water deep under the ground.
13
Original estimates for part of the project have been revised.
List of Companies
A
Australian Hydro
B
Geoenergy
C
Enviropower
D
Wavetech

13 ____ Original estimates for part of the project have been revised.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('832d21ef-92aa-5939-8acc-db0660160f19', 'afc61103-973a-5577-8b07-d49d1255b489', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8faef431-c16a-5cef-ace7-afe9f0519b62', 'afc61103-973a-5577-8b07-d49d1255b489', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('419839e7-1f6c-500c-9e9b-3e272b79df97', 'afc61103-973a-5577-8b07-d49d1255b489', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efd365a0-f629-5bde-8f43-eab23161a0ad', 'afc61103-973a-5577-8b07-d49d1255b489', 4, $md$D$md$, false);

COMMIT;
