BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-organic-farming-and-chemical-fertilisers-1331'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-organic-farming-and-chemical-fertilisers-1331';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-organic-farming-and-chemical-fertilisers-1331';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-organic-farming-and-chemical-fertilisers-1331';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('a63cb274-7351-59b4-b762-27650e4fa562', 'ielts-reading-organic-farming-and-chemical-fertilisers-1331', $t$Organic Farming and chemical fertilisers$t$, $md$## Organic Farming and chemical fertilisers

Nguồn:
- Test: https://mini-ielts.com/1331/reading/organic-farming-and-chemical-fertilisers
- Solution: https://mini-ielts.com/1331/view-solution/reading/organic-farming-and-chemical-fertilisers$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('92b2a610-29ce-52ff-a85f-ac4af9365fff', 'a63cb274-7351-59b4-b762-27650e4fa562', 1, $t$Reading — Organic Farming and chemical fertilisers$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Organic Farming and chemical fertilisers

A

The world’s population continues to climb. And despite the rise of high-tech agriculture, 800 million people don’t get enough to eat. Clearly, it’s time to rethink the food we eat and where it comes from. Feeding 9 billion people will take more than the same old farming practices, especially if we want to do it without felling rainforests and planting every last scrap of prairie. Finding food for all those people will tax farmers’ – and researchers’ – ingenuity to the limit. Yet already, precious aquifers that provide irrigation water for some of the world’s most productive farmlands are drying up or filling with seawater, and arable land in China is eroding to create vast dust storms that redden sunsets as far away as North America. “Agriculture must become the solution to environmental problems in 50 years. If we don’t have systems that make the environment better – not just hold the fort-then we’re in trouble,” says Kenneth Cassman, an agronomist at the University of Nebraska at Lincoln. That view was echoed in January by the Curry report, a government panel that surveyed the future of farming and food in Britain.

B

It’s easy to say agriculture has to do better, but what should this friendly farming of the future look like? Concerned consumers come up short at this point, facing what appears to be an ever-widening ideological divide. In one corner are the techno-optimists who put their faith in genetically modified crops, improved agrochemicals and computer-enhanced machinery; in the other are advocates of organic farming, who reject artificial chemicals and embrace back-to-nature techniques such as composting. Both sides cite plausible science to back their claims to the moral high ground, and both bring enough passion to the debate for many people to come away thinking we’re faced with a stark choice between two mutually incompatible options.

C

Not so. If you take off the ideological blinkers and simply ask how the world can produce the food it needs with the least environmental cost, a new middle way opens. The key is sustainability: whatever we do must not destroy the capital of soil and water we need to keep on producing. Like today’s organic farming, the intelligent farming of the future should pay much more attention to the health of its soil and the ecosystem it’s part of. But intelligent farming should also make shrewd and locally appropriate use of chemical fertilisers and pesticides. The most crucial ingredient in this new style of agriculture is not chemicals but information about what’s happening in each field and how to respond. Yet ironically, this key element may be the most neglected today.

D

Clearly, organic farming has all the warm, fuzzy sentiment on its side. An approach that eschews synthetic chemicals surely runs no risk of poisoning land and water. And its emphasis on building up natural ecosystems seems to be good for everyone. Perhaps these easy assumptions explain why sales of organic food across Europe are increasing by at least 50 per cent per year.

E

Going organic sounds idyllic – but it’s native, too. Organic agriculture has its own suite of environmental costs, which can be worse than those of conventional farming, especially if it were to become the world norm. But more fundamentally, the organic versus-chemical debate focuses on the wrong question. The issue isn’t what you put into a farm, but what you get out of it, both in terms of crop yields and pollutants, and what condition the farm is in when you’re done.

F

Take chemical fertilisers, which deliver nitrogen, an essential plant nutrient, to crops along with some phosphorus and potassium. It is a mantra of organic farming that these fertilisers are unwholesome, and plant nutrients must come from natural sources. But in fact, the main environmental damage done by chemical fertilisers as opposed to any other kind is through greenhouse gases-carbon dioxide from the fossil fuels used in their synthesis and nitrogen oxides released by their degradation. Excess nitrogen from chemical fertilisers can pollute groundwater, but so can excess nitrogen from organic manures.

G

On the other hand, relying solely on chemical fertilisers to provide soil nutrients without doing other things to build healthy soil is damaging. Organic farmers don’t use chemical fertilisers, so they are very good at building soil fertility by working crop residues and manure into the soil, rotating grain with legumes that fix atmospheric nitrogen, and other techniques.

H

This generates vital soil nutrients and also creates a soil that is richer in organic matter, so it retains better and is hospitable to the crop’s roots and creatures such as earthworms that help maintain soil fertility. Such soil also holds water better and therefore make more efficient use of both rainfall and irrigation water. And organic matter ties up CO2 in the soil, helping to offset emissions from burning fossil fuels and reduce global warming.

I

Advocates of organic farming like to point out that fields managed in this way can produce yields just as high as fields juiced up with synthetic fertilisers. For example, Bill Liebhardt, research manager at the Rodale Institute in Kutztown, Pennsylvania, recently compiled the results of such comparisons for corn, wheat, soybeans and tomatoes in the US and found that the organic fields averaged between 94 and 100 per cent of the yields of nearby conventional crops.

J

But this optimistic picture tells only half the story. Farmers can’t grow such crops every year if they want to maintain or build soil nutrients without synthetic fertilisers. They need to alternate with soil-building crops such as pasture grasses and legumes such as alfalfa. So in the long term, the yield of staple grains such as wheat, rice and corn must go down. This is the biggest cost of organic farming. Vaclav Smil of the University of Manitoba in Winnipeg, Canada, estimates that if farmers worldwide gave up the 80 million tonnes of synthetic fertiliser they now use each year, total grain production would fall by at least half. Either farmers would have to double the amount of land they cultivate – at catastrophic cost to natural habitats – or billions of people would starve.

K

That doesn’t mean farmers couldn’t get by with less fertiliser. Technologically advanced farmers in wealthy countries, for instance, can now monitor their yields hectare by hectare, or even more finely, throughout a huge field. They can then target their fertiliser to the parts of the field where it will do the most good, instead of responding to average conditions. This increases yield and decreases fertiliser use. Eventually, farmers may incorporate long-term weather forecasts into their planning as well, so that they can cut back on fertiliser use when the weather is likely to make harvests poor anyway, says Ron Olson, an agronomist with Cargill Fertilizer in Tampa, Florida.

L

Organic techniques certainly have their benefits, especially for poor farmers. But strict “organic agriculture”, which prohibits certain technologies and allows others, isn’t always better for the environment. Take herbicides, for example. These can leach into waterways and poison both wildlife and people. Just last month, researchers led by Tyrone Hayes at the University of California at Berkeley found that even low concentrations of atrazine, the most commonly used weedkiller in the US, can prevent frog tadpoles from developing properly.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bccbdefb-f701-5c27-b687-5180c73dd310', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
1-4
on your answer sheet.
A
Vaclav Smil
B
Bill Liebhardt
C
Kenneth Cassman
D
Ron Olson
1
Use of chemical fertilizer can be optimised by combining weather information.
2
Organic framing yield is nearly equal to traditional ones.
3
Better agricultural setting is a significant key to solve environmental tough nut.
4
Substantial production loss would happen in case all farmers shifted from using synthetic fertiliser.

1 ____ Use of chemical fertilizer can be optimised by combining weather information.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88184f17-462c-58a0-9e90-d4c0e19b047c', 'bccbdefb-f701-5c27-b687-5180c73dd310', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ab5130c-87f9-53c0-b8e4-2c5bad3b24d3', 'bccbdefb-f701-5c27-b687-5180c73dd310', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('724f620c-8261-58f1-95d5-6531548584a6', 'bccbdefb-f701-5c27-b687-5180c73dd310', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03056c97-6ed6-5aaa-b37e-edb4802f3951', 'bccbdefb-f701-5c27-b687-5180c73dd310', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d2f8e79-3419-5848-85a6-22a10ca7582b', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
1-4
on your answer sheet.
A
Vaclav Smil
B
Bill Liebhardt
C
Kenneth Cassman
D
Ron Olson
1
Use of chemical fertilizer can be optimised by combining weather information.
2
Organic framing yield is nearly equal to traditional ones.
3
Better agricultural setting is a significant key to solve environmental tough nut.
4
Substantial production loss would happen in case all farmers shifted from using synthetic fertiliser.

2 ____ Organic framing yield is nearly equal to traditional ones.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd071dd2-e6bd-5a29-9e09-1a6e48167fbd', '3d2f8e79-3419-5848-85a6-22a10ca7582b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46065220-f701-556c-8dde-0efc729d5a1e', '3d2f8e79-3419-5848-85a6-22a10ca7582b', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3a91cd1-fc25-5d80-a197-a749d51e2cc0', '3d2f8e79-3419-5848-85a6-22a10ca7582b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('259464a5-6d54-5e57-91e6-2c2fa8d87da5', '3d2f8e79-3419-5848-85a6-22a10ca7582b', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('93b6f497-8144-55a9-af04-136bfee3f94c', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
1-4
on your answer sheet.
A
Vaclav Smil
B
Bill Liebhardt
C
Kenneth Cassman
D
Ron Olson
1
Use of chemical fertilizer can be optimised by combining weather information.
2
Organic framing yield is nearly equal to traditional ones.
3
Better agricultural setting is a significant key to solve environmental tough nut.
4
Substantial production loss would happen in case all farmers shifted from using synthetic fertiliser.

3 ____ Better agricultural setting is a significant key to solve environmental tough nut.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc362cc3-c23e-52ca-ad75-8ba67252a434', '93b6f497-8144-55a9-af04-136bfee3f94c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afc1a68f-d4cd-5084-bd82-156055cc660a', '93b6f497-8144-55a9-af04-136bfee3f94c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('556e42ac-52b3-5355-84e0-ff33caa360b8', '93b6f497-8144-55a9-af04-136bfee3f94c', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e667c1c-525e-5d04-88ac-fca02d1147ab', '93b6f497-8144-55a9-af04-136bfee3f94c', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6ebe0f30-b6ff-54d9-9284-76d047530d9d', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
1-4
on your answer sheet.
A
Vaclav Smil
B
Bill Liebhardt
C
Kenneth Cassman
D
Ron Olson
1
Use of chemical fertilizer can be optimised by combining weather information.
2
Organic framing yield is nearly equal to traditional ones.
3
Better agricultural setting is a significant key to solve environmental tough nut.
4
Substantial production loss would happen in case all farmers shifted from using synthetic fertiliser.

4 ____ Substantial production loss would happen in case all farmers shifted from using synthetic fertiliser.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('363fa3c6-3f74-50c3-b674-54bfda3c6cbf', '6ebe0f30-b6ff-54d9-9284-76d047530d9d', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('019e6a18-eb39-511c-8cef-480d46ab199b', '6ebe0f30-b6ff-54d9-9284-76d047530d9d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df127ab8-7901-59ae-8b31-e55cd2194a18', '6ebe0f30-b6ff-54d9-9284-76d047530d9d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5efbc306-ced5-5bb3-a0ef-1617270286c0', '6ebe0f30-b6ff-54d9-9284-76d047530d9d', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('180bbdcd-e6ea-5a18-ab4d-4aa3c89c7f91', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage 1?
In boxes
5-9
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
5
Increasing population, draining irrigation, eroding farmland push agricultural industry to extremity.
6
There are only two options for farmers; they use chemical fertiliser or natural approach.
7
Chemical fertilizer currently is more expensive than the natural fertilisers.
8
In order to keep nutrients in the soil, organic farmers need to rotate planting method.
9
“organic agriculture” is the way that environment-damaging technologies are all strictly forbidden.

5 ____ Increasing population, draining irrigation, eroding farmland push agricultural industry to extremity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca86f18c-b48e-5362-8488-80b283f217de', '180bbdcd-e6ea-5a18-ab4d-4aa3c89c7f91', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bae526a-727e-5128-877a-27fbfda41f50', '180bbdcd-e6ea-5a18-ab4d-4aa3c89c7f91', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('254c2e6f-dfb4-5abe-a667-d810063f7b4f', '180bbdcd-e6ea-5a18-ab4d-4aa3c89c7f91', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dc70b5b9-f86d-5ac7-852b-f4c25fa3346d', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage 1?
In boxes
5-9
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
5
Increasing population, draining irrigation, eroding farmland push agricultural industry to extremity.
6
There are only two options for farmers; they use chemical fertiliser or natural approach.
7
Chemical fertilizer currently is more expensive than the natural fertilisers.
8
In order to keep nutrients in the soil, organic farmers need to rotate planting method.
9
“organic agriculture” is the way that environment-damaging technologies are all strictly forbidden.

6 ____ There are only two options for farmers; they use chemical fertiliser or natural approach.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf204483-53f2-5903-8291-3e2aab2577d2', 'dc70b5b9-f86d-5ac7-852b-f4c25fa3346d', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3648c005-22de-5060-80e3-b6cd5bf98453', 'dc70b5b9-f86d-5ac7-852b-f4c25fa3346d', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('579c5f8a-1b3e-5cd7-a6a6-bbe25d630ee7', 'dc70b5b9-f86d-5ac7-852b-f4c25fa3346d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c6cae06-4760-5900-a790-2f708675d9a8', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage 1?
In boxes
5-9
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
5
Increasing population, draining irrigation, eroding farmland push agricultural industry to extremity.
6
There are only two options for farmers; they use chemical fertiliser or natural approach.
7
Chemical fertilizer currently is more expensive than the natural fertilisers.
8
In order to keep nutrients in the soil, organic farmers need to rotate planting method.
9
“organic agriculture” is the way that environment-damaging technologies are all strictly forbidden.

7 ____ Chemical fertilizer currently is more expensive than the natural fertilisers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ef9c8c6-a016-59db-a2dc-ccf57e6baf84', '1c6cae06-4760-5900-a790-2f708675d9a8', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28dad307-8e2a-5a46-810b-7a063891b54f', '1c6cae06-4760-5900-a790-2f708675d9a8', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d65e94a6-7028-5eb9-b4f4-eeab27f22384', '1c6cae06-4760-5900-a790-2f708675d9a8', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5074a80d-0e86-59b0-8316-e8262f4f5124', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage 1?
In boxes
5-9
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
5
Increasing population, draining irrigation, eroding farmland push agricultural industry to extremity.
6
There are only two options for farmers; they use chemical fertiliser or natural approach.
7
Chemical fertilizer currently is more expensive than the natural fertilisers.
8
In order to keep nutrients in the soil, organic farmers need to rotate planting method.
9
“organic agriculture” is the way that environment-damaging technologies are all strictly forbidden.

8 ____ In order to keep nutrients in the soil, organic farmers need to rotate planting method.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a70d8dbb-823b-5ee0-a464-09e447a67c07', '5074a80d-0e86-59b0-8316-e8262f4f5124', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6f5567f-1593-5235-bd95-3ae9858b79c2', '5074a80d-0e86-59b0-8316-e8262f4f5124', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45d18e18-417f-5efd-bb6e-6097c25a3e18', '5074a80d-0e86-59b0-8316-e8262f4f5124', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e00b3639-257a-5362-a61b-145f76d26d42', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage 1?
In boxes
5-9
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
5
Increasing population, draining irrigation, eroding farmland push agricultural industry to extremity.
6
There are only two options for farmers; they use chemical fertiliser or natural approach.
7
Chemical fertilizer currently is more expensive than the natural fertilisers.
8
In order to keep nutrients in the soil, organic farmers need to rotate planting method.
9
“organic agriculture” is the way that environment-damaging technologies are all strictly forbidden.

9 ____ “organic agriculture” is the way that environment-damaging technologies are all strictly forbidden.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17a5cd01-f8f7-5539-967c-2ae3e437642d', 'e00b3639-257a-5362-a61b-145f76d26d42', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3381936c-3098-512f-bdcd-161c4998248c', 'e00b3639-257a-5362-a61b-145f76d26d42', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b7505cf-187a-5957-a7e4-49e11a5542de', 'e00b3639-257a-5362-a61b-145f76d26d42', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b9149050-6310-5bdf-a5f0-7017753aafe4', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the following summary of the paragraph of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Several
10
approaches need to be applied in order that global population wouldn’t go starved. A team called
11
repeated the viewpoint of a scholar by a survey in British farming. More and more European farmers believe in
12
farming these years. The argument of organic against
13
seems in an inaccurate direction.

Several 10 ____ approaches need to be applied in order that global population wouldn’t go starved. A team called 11 ____ repeated the viewpoint of a scholar by a survey in British farming. More and more European farmers believe in 12 ____ farming these years. The argument of organic against 13 ____ seems in an inaccurate direction.$md$, NULL, ARRAY['.*farming.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9a96a4cb-788c-5a80-8291-962555cb2a1a', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the following summary of the paragraph of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Several
10
approaches need to be applied in order that global population wouldn’t go starved. A team called
11
repeated the viewpoint of a scholar by a survey in British farming. More and more European farmers believe in
12
farming these years. The argument of organic against
13
seems in an inaccurate direction.

Several 10 ____ approaches need to be applied in order that global population wouldn’t go starved. A team called 11 ____ repeated the viewpoint of a scholar by a survey in British farming. More and more European farmers believe in 12 ____ farming these years. The argument of organic against 13 ____ seems in an inaccurate direction.$md$, NULL, ARRAY['.*farming.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cd8ba5b9-7a70-5216-b3a4-c8a704889186', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the following summary of the paragraph of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Several
10
approaches need to be applied in order that global population wouldn’t go starved. A team called
11
repeated the viewpoint of a scholar by a survey in British farming. More and more European farmers believe in
12
farming these years. The argument of organic against
13
seems in an inaccurate direction.

Several 10 ____ approaches need to be applied in order that global population wouldn’t go starved. A team called 11 ____ repeated the viewpoint of a scholar by a survey in British farming. More and more European farmers believe in 12 ____ farming these years. The argument of organic against 13 ____ seems in an inaccurate direction.$md$, NULL, ARRAY['.*farming.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cafaa5c6-fe6b-5088-b0f0-9ffac4b40757', '92b2a610-29ce-52ff-a85f-ac4af9365fff', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the following summary of the paragraph of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Several
10
approaches need to be applied in order that global population wouldn’t go starved. A team called
11
repeated the viewpoint of a scholar by a survey in British farming. More and more European farmers believe in
12
farming these years. The argument of organic against
13
seems in an inaccurate direction.

Several 10 ____ approaches need to be applied in order that global population wouldn’t go starved. A team called 11 ____ repeated the viewpoint of a scholar by a survey in British farming. More and more European farmers believe in 12 ____ farming these years. The argument of organic against 13 ____ seems in an inaccurate direction.$md$, NULL, ARRAY['.*farming.*']);

COMMIT;
