BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-honey-bees-in-trouble-1104'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-honey-bees-in-trouble-1104';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-honey-bees-in-trouble-1104';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-honey-bees-in-trouble-1104';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('ac235b03-3b3d-57db-a8f6-b030931b5b79', 'ielts-reading-honey-bees-in-trouble-1104', $t$Honey bees in trouble$t$, $md$## Honey bees in trouble

Nguồn:
- Test: https://mini-ielts.com/1104/reading/honey-bees-in-trouble
- Solution: https://mini-ielts.com/1104/view-solution/reading/honey-bees-in-trouble$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 'ac235b03-3b3d-57db-a8f6-b030931b5b79', 1, $t$Reading — Honey bees in trouble$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Honey bees in trouble

Can native pollinators fill the gap?

A Recently, ominous headlines have described a mysterious ailment, colony collapse disorder(CCD)，that is wiping out the honeybees that pollinate many crops. Without honeybees, the story goes, fields will be sterile, economies will collapse, and food will be scarce .

B But what few accounts acknowledge is that what’s at risk is not itself a natural state of affairs. For one thing, in the United States, where CCD was first reported and has had its greatest impacts, honeybees are not a native species. Pollination in modem agriculture isn’t alchemy, it’s industry. The total number of hives involved in the U.S. pollination industry has been somewhere between 2.5 million and 3 million in recent years . Meanwhile, American farmers began using large quantities of organophosphate insecticides, planted large-scale crop monocultures, and adopted “clean farming” practices that scrubbed native vegetation from field margins and roadsides. These practices killed many native bees outright—they’re as vulnerable to insecticides as any agricultural pest—and made the agricultural landscape inhospitable to those that remained. Concern about these practices and their effects on pollinators isn’t new—in her 1962 ecological alarm cry Silent Spring, Rachel Carson warned of a ‘Fruitless Fall’ that could result from the disappearance of insect pollinators .

C If that ‘Fruitless Fall, has not—yet—occurred, it may be largely thanks to the honeybee, which farmers turned to as the ability of wild pollinators to service crops declined. The honeybee has been semi-domesticated since the time of the ancient Egyptians, but it wasn’t just familiarity that determined this choice: the bees’ biology is in many ways suited to the kind of agricultural system that was emerging. For example, honeybee hives can be closed up and moved out of the way when pesticides are applied to a field . The bees are generalist pollinators, so they can be used to pollinate many different crops. And although they are not the most efficient pollinator of every crop, honeybees have strength in numbers, with 20,000 to 100,000 bees living in a single hive. “Without a doubt, if there was one bee you wanted for agriculture, it would be the honeybee, “says Jim Cane, of the U.S. Department of Agriculture. The honeybee, in other words, has become a crucial cog in the modem system of industrial agriculture. That system delivers more food, and more kinds of it, to more places, more cheaply than ever before. But that system is also vulnerable, because making a farm field into the photosynthetic equivalent of a factory floor, and pollination into a series of continent-long assembly lines, also leaches out some of the resilience characteristic of natural ecosystem s.

D Breno Freitas, an agronomist, pointed out that in nature such a high degree of specialization usually is a very dangerous game: it works well while all the rest is in equilibrium, but runs quickly to extinction at the least disbalance. In effect, by developing an agricultural system that is heavily reliant on a single pollinator species, we humans have become riskily overspecialized . And when the human-honeybee relationship is disrupted, as it has been by colony collapse disorder, the vulnerability of that agricultural system begins to become clear.

E In fact, a few wild bees are already being successfully managed for crop pollination. “The problem is trying to provide native bees in adequate numbers on a reliable basis in a fairly short number of years in order to service the crop，” Jim Cane says. “You’re talking millions of flowers per acre in a two-to three-week time frame, or less, for a lot of crops.” On the other hand, native bees can be much more efficient pollinators of certain crops than honeybees, so you don’t need as many to do the job . For example, about 750 blue orchard bees (Osmia lignaria) can pollinate a hectare of apples or almonds , a task that would require roughly 50,000 to 150,000 honeybees. There are bee tinkerers engaged in similar work in many comers of the world. In Brazil, Breno Freitas has found that Centris tarsata, the native pollinator of wild cashew, can survive in commercial cashew orchards if growers provide a source of floral oils, such as by interplanting their cashew trees with Caribbean cherry .

F In certain places, native bees may already be doing more than they’re getting credit for. Ecologist Rachael Winfree recently led a team that looked at pollination of four summer crops (tomato, watermelon, peppers, and muskmelon) at 29 farms in the region of New Jersey and Pennsylvania. Winfiree’s team identified 54 species of wild bees that visited these crops, and found that wild bees were the most important pollinators in the system: even though managed honeybees were present on many of the farms, wild bees were responsible for 62 percent of flower visits in the study. In another study focusing specifically on watermelon, Winfree and her colleagues calculated that native bees alone could provide sufficient pollination at 90 percent of the 23 farms studied. By contrast, honeybees alone could provide sufficient pollination at only 78 percent of farms.

G “The region I work in is not typical of the way most food is produced，” Winfree admits. In the Delaware Valley, most farms and farm fields are relatively small, each fanner typically grows a variety of crops, and farms are interspersed with suburbs and other types of land use which means there are opportunities for homeowners to get involved in bee conservation, too. The landscape is a bee-friendly patchwork that provides a variety of nesting habitat and floral resources distributed among different kinds of crops, weedy field margins, fallow fields, suburban neighborhoods, and semi natural habitat like old woodlots, all at a relatively small scale. In other words, ’’pollinator-friendly” farming practices would not only aid pollination of agricultural crops, but also serve as a key element in the over all conservation strategy for wild pollinators, and often aid other wild species as well .

H Of course, not all farmers will be able to implement all of these practices. And researchers are suggesting a shift to a kind of polyglot agricultural system. For some small-scale farms, native bees may indeed be all that’s needed. For larger operations, a suite of managed bees—with honeybees filling the generalist role and other, native bees pollinating specific crops—could be augmented by free pollination services from resurgent wild pollinators. In other words, they’re saying, we still have an opportunity to replace a risky monoculture with something diverse, resilient, and robust.

----------------------------------------------------

Great thanks to volunteer Ngoc Nguyen has contributed these explanations and question markings.

If you want to make a better world like this, please contact us$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0f63407c-129a-5eac-8183-582e75f923c5', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 1, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
1
In the United States, farmers use honeybees in a large scale over the past few years
Locate
2
Cleaning farming practices would be harmful to farmers’
3
The blue orchard bee is the most efficient pollinator among native bees for every crop
Locate
4
It is beneficial to other local creatures to protect native bees
Locate

1 ____ In the United States, farmers use honeybees in a large scale over the past few years Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a740ce52-1135-5b0a-b3e7-40df4b1d7312', '0f63407c-129a-5eac-8183-582e75f923c5', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5deed2ab-c400-5d53-b0d0-0b4222b9a5a2', '0f63407c-129a-5eac-8183-582e75f923c5', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef486ab1-c87e-5126-9099-ea732dab0303', '0f63407c-129a-5eac-8183-582e75f923c5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b1a4f400-df63-5d08-8bce-ba7a484b5a95', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 2, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
1
In the United States, farmers use honeybees in a large scale over the past few years
Locate
2
Cleaning farming practices would be harmful to farmers’
3
The blue orchard bee is the most efficient pollinator among native bees for every crop
Locate
4
It is beneficial to other local creatures to protect native bees
Locate

2 ____ Cleaning farming practices would be harmful to farmers’$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bc9a390-4c10-57ee-9c0b-9d50ec426ba5', 'b1a4f400-df63-5d08-8bce-ba7a484b5a95', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf4cc656-d39a-5bd1-9599-f61b28adbd85', 'b1a4f400-df63-5d08-8bce-ba7a484b5a95', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cc28eb2-8289-51f5-af75-04c0deaf5658', 'b1a4f400-df63-5d08-8bce-ba7a484b5a95', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('11aa50cc-e686-529e-a638-f4510789f803', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 3, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
1
In the United States, farmers use honeybees in a large scale over the past few years
Locate
2
Cleaning farming practices would be harmful to farmers’
3
The blue orchard bee is the most efficient pollinator among native bees for every crop
Locate
4
It is beneficial to other local creatures to protect native bees
Locate

3 ____ The blue orchard bee is the most efficient pollinator among native bees for every crop Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55a934c8-58a1-5a2c-8d2c-ab91b67392ca', '11aa50cc-e686-529e-a638-f4510789f803', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9b3fec7-efcc-5cde-abf6-b94c2fe27708', '11aa50cc-e686-529e-a638-f4510789f803', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ecc65c6c-2776-5850-a06f-04cbb4bcf8f6', '11aa50cc-e686-529e-a638-f4510789f803', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e39cfcc4-e158-556d-baad-3f8c93a5eb0f', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
1
In the United States, farmers use honeybees in a large scale over the past few years
Locate
2
Cleaning farming practices would be harmful to farmers’
3
The blue orchard bee is the most efficient pollinator among native bees for every crop
Locate
4
It is beneficial to other local creatures to protect native bees
Locate

4 ____ It is beneficial to other local creatures to protect native bees Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e7a4831-f204-5083-bade-6d1e2260f996', 'e39cfcc4-e158-556d-baad-3f8c93a5eb0f', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd1632d3-69ef-571f-a2ff-bbe97da3cf49', 'e39cfcc4-e158-556d-baad-3f8c93a5eb0f', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbcd2d8c-b0ef-501d-aebd-06f73d43789c', 'e39cfcc4-e158-556d-baad-3f8c93a5eb0f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('db431ab9-a800-51ad-93c1-02b3e8462224', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Choose the correct letter,
A,B,C
or
D
.
Write your answers in boxes
5-9
on your answer sheet.
5.
The example of the ‘Fruitless Fair underlines the writer’s point about
A
needs for using pesticides.
B
impacts of losing insect pollinators.
C
vulnerabilities of native bees.
D
benefits in building more pollination industries.
Locate
6.
Why can honeybees adapt to the modem agricultural system?
A
the honeybees can pollinated more crops efficiently
B
The bees are semi-domesticated since ancient times.
C
Honeybee hives can be protected away from pesticides.
D
The ability of wild pollinators using to serve crops declines.
Locate
7.
The writer mentions factories and assembly lines to illustrate
A
one drawback of the industrialised agricultural system.
B
a low cost in modem agriculture.
C
the role of honeybees in pollination.
D
what a high yield of industrial agriculture.
Locate
8.
In the 6th paragraph，Wlnfree’s experiment proves that
A
honeybee can pollinate various crops.
B
there are many types of wild bees as the pollinators.
C
the wild bees can increase the yield to a higher percentage
D
wild bees work more efficiently as a pollinator than honey bees in certain cases
Locate
9.
What does the writer want to suggest in the last paragraph?
A
the importance of honey bees in pollination
B
adoption of different bees in various sizes of agricultural system
C
the comparison between the intensive and the rarefied agricultural system
D
the reason why farmers can rely on native pollinators
Locate

Choose the correct letter, A,B,C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4ee25e7b-b856-5a9a-81d4-816b5d73516b', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Choose the correct letter,
A,B,C
or
D
.
Write your answers in boxes
5-9
on your answer sheet.
5.
The example of the ‘Fruitless Fair underlines the writer’s point about
A
needs for using pesticides.
B
impacts of losing insect pollinators.
C
vulnerabilities of native bees.
D
benefits in building more pollination industries.
Locate
6.
Why can honeybees adapt to the modem agricultural system?
A
the honeybees can pollinated more crops efficiently
B
The bees are semi-domesticated since ancient times.
C
Honeybee hives can be protected away from pesticides.
D
The ability of wild pollinators using to serve crops declines.
Locate
7.
The writer mentions factories and assembly lines to illustrate
A
one drawback of the industrialised agricultural system.
B
a low cost in modem agriculture.
C
the role of honeybees in pollination.
D
what a high yield of industrial agriculture.
Locate
8.
In the 6th paragraph，Wlnfree’s experiment proves that
A
honeybee can pollinate various crops.
B
there are many types of wild bees as the pollinators.
C
the wild bees can increase the yield to a higher percentage
D
wild bees work more efficiently as a pollinator than honey bees in certain cases
Locate
9.
What does the writer want to suggest in the last paragraph?
A
the importance of honey bees in pollination
B
adoption of different bees in various sizes of agricultural system
C
the comparison between the intensive and the rarefied agricultural system
D
the reason why farmers can rely on native pollinators
Locate

Choose the correct letter, A,B,C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3cf09e25-51c2-5c14-807e-2b2308cbbf7a', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Choose the correct letter,
A,B,C
or
D
.
Write your answers in boxes
5-9
on your answer sheet.
5.
The example of the ‘Fruitless Fair underlines the writer’s point about
A
needs for using pesticides.
B
impacts of losing insect pollinators.
C
vulnerabilities of native bees.
D
benefits in building more pollination industries.
Locate
6.
Why can honeybees adapt to the modem agricultural system?
A
the honeybees can pollinated more crops efficiently
B
The bees are semi-domesticated since ancient times.
C
Honeybee hives can be protected away from pesticides.
D
The ability of wild pollinators using to serve crops declines.
Locate
7.
The writer mentions factories and assembly lines to illustrate
A
one drawback of the industrialised agricultural system.
B
a low cost in modem agriculture.
C
the role of honeybees in pollination.
D
what a high yield of industrial agriculture.
Locate
8.
In the 6th paragraph，Wlnfree’s experiment proves that
A
honeybee can pollinate various crops.
B
there are many types of wild bees as the pollinators.
C
the wild bees can increase the yield to a higher percentage
D
wild bees work more efficiently as a pollinator than honey bees in certain cases
Locate
9.
What does the writer want to suggest in the last paragraph?
A
the importance of honey bees in pollination
B
adoption of different bees in various sizes of agricultural system
C
the comparison between the intensive and the rarefied agricultural system
D
the reason why farmers can rely on native pollinators
Locate

Choose the correct letter, A,B,C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('30c65450-2fc0-51d3-a65a-fd34f99182df', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Choose the correct letter,
A,B,C
or
D
.
Write your answers in boxes
5-9
on your answer sheet.
5.
The example of the ‘Fruitless Fair underlines the writer’s point about
A
needs for using pesticides.
B
impacts of losing insect pollinators.
C
vulnerabilities of native bees.
D
benefits in building more pollination industries.
Locate
6.
Why can honeybees adapt to the modem agricultural system?
A
the honeybees can pollinated more crops efficiently
B
The bees are semi-domesticated since ancient times.
C
Honeybee hives can be protected away from pesticides.
D
The ability of wild pollinators using to serve crops declines.
Locate
7.
The writer mentions factories and assembly lines to illustrate
A
one drawback of the industrialised agricultural system.
B
a low cost in modem agriculture.
C
the role of honeybees in pollination.
D
what a high yield of industrial agriculture.
Locate
8.
In the 6th paragraph，Wlnfree’s experiment proves that
A
honeybee can pollinate various crops.
B
there are many types of wild bees as the pollinators.
C
the wild bees can increase the yield to a higher percentage
D
wild bees work more efficiently as a pollinator than honey bees in certain cases
Locate
9.
What does the writer want to suggest in the last paragraph?
A
the importance of honey bees in pollination
B
adoption of different bees in various sizes of agricultural system
C
the comparison between the intensive and the rarefied agricultural system
D
the reason why farmers can rely on native pollinators
Locate

Choose the correct letter, A,B,C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('47592600-ae50-5f68-b4bc-2a100a19f023', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Choose the correct letter,
A,B,C
or
D
.
Write your answers in boxes
5-9
on your answer sheet.
5.
The example of the ‘Fruitless Fair underlines the writer’s point about
A
needs for using pesticides.
B
impacts of losing insect pollinators.
C
vulnerabilities of native bees.
D
benefits in building more pollination industries.
Locate
6.
Why can honeybees adapt to the modem agricultural system?
A
the honeybees can pollinated more crops efficiently
B
The bees are semi-domesticated since ancient times.
C
Honeybee hives can be protected away from pesticides.
D
The ability of wild pollinators using to serve crops declines.
Locate
7.
The writer mentions factories and assembly lines to illustrate
A
one drawback of the industrialised agricultural system.
B
a low cost in modem agriculture.
C
the role of honeybees in pollination.
D
what a high yield of industrial agriculture.
Locate
8.
In the 6th paragraph，Wlnfree’s experiment proves that
A
honeybee can pollinate various crops.
B
there are many types of wild bees as the pollinators.
C
the wild bees can increase the yield to a higher percentage
D
wild bees work more efficiently as a pollinator than honey bees in certain cases
Locate
9.
What does the writer want to suggest in the last paragraph?
A
the importance of honey bees in pollination
B
adoption of different bees in various sizes of agricultural system
C
the comparison between the intensive and the rarefied agricultural system
D
the reason why farmers can rely on native pollinators
Locate

Choose the correct letter, A,B,C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c16faf0-dc64-55ec-9d8e-28995175430c', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
10-14
on your answer sheet
10
Headline of colony collapse disorder states that
Locate
11
Viewpoints of Freitas manifest that
Locate
12
Examples of blue orchard bees have shown that
Locate
13
Centris tarsata is mentioned to exemplify that
Locate
14
One finding of the research in Delaware Valley is that
Locate
A.
native pollinators can survive when a specific plant is supplied.
B.
it would cause severe consequences both to commerce and agriculture.
C.
honey bees cannot be bred.
D.
some agricultural landscapes are favorable in supporting wild bees.
E.
a large scale of honey bees are needed to pollinate.
F.
an agricultural system is fragile when relying on a single pollinator

10 ____ Headline of colony collapse disorder states that Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6576d95b-742c-5c1d-b57e-001aa105431b', '1c16faf0-dc64-55ec-9d8e-28995175430c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9da93ae8-813e-5d26-b284-dbc250d9302b', '1c16faf0-dc64-55ec-9d8e-28995175430c', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbe77f0c-a79f-5a48-b4a2-b8a5d33902e5', '1c16faf0-dc64-55ec-9d8e-28995175430c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a94f089-9362-50da-b105-d4fdbb82513a', '1c16faf0-dc64-55ec-9d8e-28995175430c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2a043fc-1ba9-5afb-bbe0-de467da9b004', '1c16faf0-dc64-55ec-9d8e-28995175430c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c802eb52-6a72-5e90-9a12-4e14ace05351', '1c16faf0-dc64-55ec-9d8e-28995175430c', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6088081e-d501-5a1a-985c-6e026a52a932', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
10-14
on your answer sheet
10
Headline of colony collapse disorder states that
Locate
11
Viewpoints of Freitas manifest that
Locate
12
Examples of blue orchard bees have shown that
Locate
13
Centris tarsata is mentioned to exemplify that
Locate
14
One finding of the research in Delaware Valley is that
Locate
A.
native pollinators can survive when a specific plant is supplied.
B.
it would cause severe consequences both to commerce and agriculture.
C.
honey bees cannot be bred.
D.
some agricultural landscapes are favorable in supporting wild bees.
E.
a large scale of honey bees are needed to pollinate.
F.
an agricultural system is fragile when relying on a single pollinator

11 ____ Viewpoints of Freitas manifest that Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2e80f8c-c801-5c32-8ae4-edddb1f532a8', '6088081e-d501-5a1a-985c-6e026a52a932', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55272829-a1b4-5e00-ab48-5bf756951e16', '6088081e-d501-5a1a-985c-6e026a52a932', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02ea7ebb-2fcc-5084-a98d-04fe1752f81f', '6088081e-d501-5a1a-985c-6e026a52a932', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5f904c2-40d8-5cef-9ff5-8102fb0e95bc', '6088081e-d501-5a1a-985c-6e026a52a932', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('719ed985-3b76-5a0d-97ac-a328b92aa89d', '6088081e-d501-5a1a-985c-6e026a52a932', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7de9b8a3-f6c0-5489-a29c-09204eb7e119', '6088081e-d501-5a1a-985c-6e026a52a932', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('123ded45-5889-583b-a6b4-a8db4325e044', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
10-14
on your answer sheet
10
Headline of colony collapse disorder states that
Locate
11
Viewpoints of Freitas manifest that
Locate
12
Examples of blue orchard bees have shown that
Locate
13
Centris tarsata is mentioned to exemplify that
Locate
14
One finding of the research in Delaware Valley is that
Locate
A.
native pollinators can survive when a specific plant is supplied.
B.
it would cause severe consequences both to commerce and agriculture.
C.
honey bees cannot be bred.
D.
some agricultural landscapes are favorable in supporting wild bees.
E.
a large scale of honey bees are needed to pollinate.
F.
an agricultural system is fragile when relying on a single pollinator

12 ____ Examples of blue orchard bees have shown that Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19c18a64-7a0f-576a-bb4a-ad236fb76509', '123ded45-5889-583b-a6b4-a8db4325e044', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd3628ba-ea74-5fca-ba07-307f1f956867', '123ded45-5889-583b-a6b4-a8db4325e044', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbcf9ba4-bc9b-51bb-ac1f-10016fe4c69a', '123ded45-5889-583b-a6b4-a8db4325e044', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8efd075f-cbdd-54a0-a9d7-e7b1fe2172bf', '123ded45-5889-583b-a6b4-a8db4325e044', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30b9ffc8-f9a2-5c28-b4a9-5f2e8e44c3ab', '123ded45-5889-583b-a6b4-a8db4325e044', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('008d2a69-db94-538a-860d-daa86a5232a1', '123ded45-5889-583b-a6b4-a8db4325e044', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ceb182a5-9778-504e-bf4f-f1d7f528e975', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
10-14
on your answer sheet
10
Headline of colony collapse disorder states that
Locate
11
Viewpoints of Freitas manifest that
Locate
12
Examples of blue orchard bees have shown that
Locate
13
Centris tarsata is mentioned to exemplify that
Locate
14
One finding of the research in Delaware Valley is that
Locate
A.
native pollinators can survive when a specific plant is supplied.
B.
it would cause severe consequences both to commerce and agriculture.
C.
honey bees cannot be bred.
D.
some agricultural landscapes are favorable in supporting wild bees.
E.
a large scale of honey bees are needed to pollinate.
F.
an agricultural system is fragile when relying on a single pollinator

13 ____ Centris tarsata is mentioned to exemplify that Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1d04ce9-bd6b-5c32-ad9a-9c3f0394ceea', 'ceb182a5-9778-504e-bf4f-f1d7f528e975', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09cd9f1a-40bf-5ab6-a496-4251710a4206', 'ceb182a5-9778-504e-bf4f-f1d7f528e975', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2afabdaa-cc76-5f4a-b7c0-535fa68ce7db', 'ceb182a5-9778-504e-bf4f-f1d7f528e975', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68de2ec2-374c-506c-b989-60c3c7c35d93', 'ceb182a5-9778-504e-bf4f-f1d7f528e975', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48e28cf3-b041-517c-9ff6-6e7a3cfd6398', 'ceb182a5-9778-504e-bf4f-f1d7f528e975', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e22dbc66-3169-5aab-9bca-6df163282ecb', 'ceb182a5-9778-504e-bf4f-f1d7f528e975', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ecd73e92-e2cb-546d-8394-03fbe8922a45', 'b6d3eb0e-87e1-5b22-a9b8-116efb87c9b7', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
10-14
on your answer sheet
10
Headline of colony collapse disorder states that
Locate
11
Viewpoints of Freitas manifest that
Locate
12
Examples of blue orchard bees have shown that
Locate
13
Centris tarsata is mentioned to exemplify that
Locate
14
One finding of the research in Delaware Valley is that
Locate
A.
native pollinators can survive when a specific plant is supplied.
B.
it would cause severe consequences both to commerce and agriculture.
C.
honey bees cannot be bred.
D.
some agricultural landscapes are favorable in supporting wild bees.
E.
a large scale of honey bees are needed to pollinate.
F.
an agricultural system is fragile when relying on a single pollinator

14 ____ One finding of the research in Delaware Valley is that Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b32a95ba-b49b-53a5-8a55-2c324c93ae1b', 'ecd73e92-e2cb-546d-8394-03fbe8922a45', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76ebddc6-431d-526f-a73b-4c368748a99b', 'ecd73e92-e2cb-546d-8394-03fbe8922a45', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('228af235-5e82-55e5-b12c-dcd4e476877b', 'ecd73e92-e2cb-546d-8394-03fbe8922a45', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cfb1120-e7e2-578b-9b78-ef67d40ead7f', 'ecd73e92-e2cb-546d-8394-03fbe8922a45', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf629111-6b75-5506-bb9e-730aa1d3a1ab', 'ecd73e92-e2cb-546d-8394-03fbe8922a45', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60c3e678-a0dd-5266-994e-9a95bd5ac6bd', 'ecd73e92-e2cb-546d-8394-03fbe8922a45', 6, $md$F$md$, false);

COMMIT;
