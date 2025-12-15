BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-volatility-kills-1488'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-volatility-kills-1488';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-volatility-kills-1488';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-volatility-kills-1488';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d05765e7-e890-56ee-a0c5-5c0c65c48e2b', 'ielts-reading-volatility-kills-1488', $t$Volatility Kills$t$, $md$## Volatility Kills

Nguồn:
- Test: https://mini-ielts.com/1488/reading/volatility-kills
- Solution: https://mini-ielts.com/1488/view-solution/reading/volatility-kills$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('27922804-6588-5a0d-99e4-53f5dded966d', 'd05765e7-e890-56ee-a0c5-5c0c65c48e2b', 1, $t$Reading — Volatility Kills$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Volatility Kills

A . Despite gun battles in the capital of Chad, rioting in Kenya, and Galloping inflation in Zimbabwe, the economies of sub-Saharan Africa are, as a whole, in better shape than they were a few years ago. The World Bank has reported recently that this part of the continent experienced a respectable growth rate of 5.6 percent in 2006 and a higher rate from 1995 to 2005 than in previous decades. The bank has given a cautions assessment that the region may have reached a turning point. An overriding question for developmental economists remains whether the upswing will continue so Africans can grow their way out of poverty that relegates some 40 percent of the nearly 744 million in that region to living on less than a dollar a day. The optimism, when inspected more closely, maybe short-lived because of the persistence of a devastating pattern of economic volatility that has lingered for decades.

B. “In reality, African countries grow as fast as Asian countries and other developing countries during the good times, but afterward they see growth collapses,” comments Jorge Arbache, a senior World Bank economist. “How to prevent collapses may be as important as promoting growth.” If these collapses had not occurred, he observes, the level of gross domestic product for each citizen of the 48 nations of sub -Saharan Africa would have been third higher.

C . the prerequisites to prevent the next crash are not in place, according to a World Bank study issued in January, Is Africa’s Recent Growth Robust? The growth period that began in 1995, driven by a commodities boom spurred in particular by demand from China, may not be sustainable, because the economic fundamentals- new investment and the ability to stave off inflation, among other factors-are absent. The region lacks the necessary infrastructure that would encourage investors to look to Africa to find the next Bengaluru ( Bangalore ) or Shenzhen, a November report from the bank concludes. For sub–Saharan countries rich in oil and other resources, a boom period may even undermine efforts to institute sound economic practices.. From 1996 to 2005, with growth accelerating, measures of governance – factors such as political stability, rule of law, and control of corruption- actually worsened, especially for countries endowed with abundant mineral resources, the January report notes.

D . Perhaps the most incisive analysis of the volatility question comes from Paul Collier, a longtime specialist in African economics at the University of Oxford and author of the recent book The Bottom Billion. He advocates a range of options that the U.S. and other nations could adopt when formulating policy toward African countries. They include revamped trade measures, better-apportioned aid, and sustained military intervention in certain instances, to avert what he sees as a rapidly accelerating divergence of the world’s poorest, primarily in Africa, from the rest of the world, even other developing nations such India and China.

E. Collier finds that bad governance is the main reason countries fail to take advantage of the revenue bonanza that results from a boom. moreover, a democratic government, he adds, often makes the aftermath of a boom worse. “Instead of democracy disciplining governments to manage these resource booms well, what happens is that the resource revenues corrupt the normal functioning of democracy-unless you stop ( them from) corrupting the normal function of democracy with sufficient checks and balances”, he said at a talk ion January at the Carnegie Council in New York City.

F . Collier advocates that African nations institute an array of standards and codes to bolster governments, one of which would substitute auctions for bribes in apportioning mineral rights and another of which would tax export revenues adequately. He cites the Democratic Republic of the Congo, which took in $ 200 million from mineral exports in 2006 yet collected only $86000 in royalties for its treasury. “If a nation gets these points right, ” he argues, “It’s going to develop. If it gets them wrong, it won’t.”

G . To encourage reform, Collier recommends that the G8 nations agree to accept these measures as voluntary guidelines for multinationals doing business in Africa- companies, for instance, would only enter new contracts through auctions monitored by an international verification group. Such an agreement would follow the examples of the so-called Kimberley Process, which has effectively undercut the trade in blood diamonds, and the Extractive Industries Transparency Initiative, in which a government must report to its citizens the revenues it receives from sales of natural resources.

H . These measures, he says, are more important than elevating aid levels, an approach emphasized by economist Jeffrey D. Sachs of Columbia University and celebrity activists such as Bono. Collier insists that first Angola receives tens of billions of dollars in oil revenue and whether it gets a few hundred million more or less in aid is really second-order.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0152f7c4-25be-59da-a01e-9e8050efe5e8', '27922804-6588-5a0d-99e4-53f5dded966d', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed A-C) with opinions or deeds below. Write the appropriate letters
A-C
in boxes
1-4
on your answer sheet.
NB
you may use any letter more than once
A
. Jeffrey D. Dachs
B .
Paul Collier
C .
Jorge Arbache
1
An unexpectedly opposite result
2
Estimated more productive outcomes if it were not for sudden economic downturns
3
A proposal for a range of recommended instructions for certain countries to narrow the widening economic gap
4
An advocate for a method used for a specific assessment

1 ____ An unexpectedly opposite result$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d025d564-1a50-5d94-9d5d-f50405d865f2', '0152f7c4-25be-59da-a01e-9e8050efe5e8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97618c51-7500-5c73-9eb6-ea4df7d26620', '0152f7c4-25be-59da-a01e-9e8050efe5e8', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1aef239-75c9-56a5-a61e-794cb72220b1', '0152f7c4-25be-59da-a01e-9e8050efe5e8', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('911c66a5-f3d9-5dcc-9f7a-b072c78a5df9', '27922804-6588-5a0d-99e4-53f5dded966d', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed A-C) with opinions or deeds below. Write the appropriate letters
A-C
in boxes
1-4
on your answer sheet.
NB
you may use any letter more than once
A
. Jeffrey D. Dachs
B .
Paul Collier
C .
Jorge Arbache
1
An unexpectedly opposite result
2
Estimated more productive outcomes if it were not for sudden economic downturns
3
A proposal for a range of recommended instructions for certain countries to narrow the widening economic gap
4
An advocate for a method used for a specific assessment

2 ____ Estimated more productive outcomes if it were not for sudden economic downturns$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('772df70b-f3c2-55d9-8901-e8cb883b808c', '911c66a5-f3d9-5dcc-9f7a-b072c78a5df9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa7f2514-e35d-59a7-8cea-105f89ca75d2', '911c66a5-f3d9-5dcc-9f7a-b072c78a5df9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68be09f6-ecfd-5573-ab11-791d572ab668', '911c66a5-f3d9-5dcc-9f7a-b072c78a5df9', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bfeab580-a1aa-55cf-9b4b-0ef83840a1ba', '27922804-6588-5a0d-99e4-53f5dded966d', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed A-C) with opinions or deeds below. Write the appropriate letters
A-C
in boxes
1-4
on your answer sheet.
NB
you may use any letter more than once
A
. Jeffrey D. Dachs
B .
Paul Collier
C .
Jorge Arbache
1
An unexpectedly opposite result
2
Estimated more productive outcomes if it were not for sudden economic downturns
3
A proposal for a range of recommended instructions for certain countries to narrow the widening economic gap
4
An advocate for a method used for a specific assessment

3 ____ A proposal for a range of recommended instructions for certain countries to narrow the widening economic gap$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a79f082d-8b7c-5ac6-b3e5-f5c56c60ca6a', 'bfeab580-a1aa-55cf-9b4b-0ef83840a1ba', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f0f5b8d-e5b7-545b-93a7-eeffce8b8727', 'bfeab580-a1aa-55cf-9b4b-0ef83840a1ba', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a388561-f3a2-5e30-9e79-2830c9744197', 'bfeab580-a1aa-55cf-9b4b-0ef83840a1ba', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8e6478db-ae19-5828-8601-4a8d3f41526f', '27922804-6588-5a0d-99e4-53f5dded966d', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed A-C) with opinions or deeds below. Write the appropriate letters
A-C
in boxes
1-4
on your answer sheet.
NB
you may use any letter more than once
A
. Jeffrey D. Dachs
B .
Paul Collier
C .
Jorge Arbache
1
An unexpectedly opposite result
2
Estimated more productive outcomes if it were not for sudden economic downturns
3
A proposal for a range of recommended instructions for certain countries to narrow the widening economic gap
4
An advocate for a method used for a specific assessment

4 ____ An advocate for a method used for a specific assessment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97b9fafc-eba1-5951-a075-7b986126301d', '8e6478db-ae19-5828-8601-4a8d3f41526f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7969b2c1-7e0c-53d9-bfe4-5943c843ff5d', '8e6478db-ae19-5828-8601-4a8d3f41526f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3e21a01-b261-5893-af8f-9b65a739f633', '8e6478db-ae19-5828-8601-4a8d3f41526f', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bb6d9be2-330c-5778-bcb5-28f6a5c15c17', '27922804-6588-5a0d-99e4-53f5dded966d', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage ? In boxes 5-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The instability in an economy in some African countries might negatively impact their continuing growth after a certain level has been reached.
6
Collier is the most influential scholar in the study of the volatility problem.
7
Certain African governments levy considerable taxes on people profiting greatly from exportation.
8
Some African nation’s decisions on addressing specific existing problems are directly related to the future of their economic trends.
9
Collier regards Jeffrey D. Sachs recommended a way of evaluating of title importance.

5 ____ The instability in an economy in some African countries might negatively impact their continuing growth after a certain level has been reached.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afb09551-c195-55e0-b93a-df818bb7408b', 'bb6d9be2-330c-5778-bcb5-28f6a5c15c17', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc83e7fd-5864-57b8-941e-3e87d39ed9f1', 'bb6d9be2-330c-5778-bcb5-28f6a5c15c17', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('242bfdcf-ae61-5567-a940-e34b5be20e96', 'bb6d9be2-330c-5778-bcb5-28f6a5c15c17', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('000fe15c-8c72-5054-a3ba-f098d0b7d036', '27922804-6588-5a0d-99e4-53f5dded966d', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage ? In boxes 5-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The instability in an economy in some African countries might negatively impact their continuing growth after a certain level has been reached.
6
Collier is the most influential scholar in the study of the volatility problem.
7
Certain African governments levy considerable taxes on people profiting greatly from exportation.
8
Some African nation’s decisions on addressing specific existing problems are directly related to the future of their economic trends.
9
Collier regards Jeffrey D. Sachs recommended a way of evaluating of title importance.

6 ____ Collier is the most influential scholar in the study of the volatility problem.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5878be25-6a60-55d0-9101-6cec8d3a099f', '000fe15c-8c72-5054-a3ba-f098d0b7d036', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbdea637-2478-58d1-98c7-c879b287a9fc', '000fe15c-8c72-5054-a3ba-f098d0b7d036', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26be8720-3eeb-5190-a1a6-4f1f490cdeb3', '000fe15c-8c72-5054-a3ba-f098d0b7d036', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8c44de40-0171-56d2-b4a8-7a05aa768dbf', '27922804-6588-5a0d-99e4-53f5dded966d', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage ? In boxes 5-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The instability in an economy in some African countries might negatively impact their continuing growth after a certain level has been reached.
6
Collier is the most influential scholar in the study of the volatility problem.
7
Certain African governments levy considerable taxes on people profiting greatly from exportation.
8
Some African nation’s decisions on addressing specific existing problems are directly related to the future of their economic trends.
9
Collier regards Jeffrey D. Sachs recommended a way of evaluating of title importance.

7 ____ Certain African governments levy considerable taxes on people profiting greatly from exportation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af99c3d3-d432-5a91-a96c-e1bf32057d11', '8c44de40-0171-56d2-b4a8-7a05aa768dbf', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cf790df-9667-56ac-90d8-0cb95d048466', '8c44de40-0171-56d2-b4a8-7a05aa768dbf', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61af9af1-61e8-5d46-9fea-cadf5141c6ab', '8c44de40-0171-56d2-b4a8-7a05aa768dbf', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('97cd2be5-b45d-5732-a17a-4aa1dedcb12a', '27922804-6588-5a0d-99e4-53f5dded966d', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage ? In boxes 5-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The instability in an economy in some African countries might negatively impact their continuing growth after a certain level has been reached.
6
Collier is the most influential scholar in the study of the volatility problem.
7
Certain African governments levy considerable taxes on people profiting greatly from exportation.
8
Some African nation’s decisions on addressing specific existing problems are directly related to the future of their economic trends.
9
Collier regards Jeffrey D. Sachs recommended a way of evaluating of title importance.

8 ____ Some African nation’s decisions on addressing specific existing problems are directly related to the future of their economic trends.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e52655e-7fe8-5508-89ca-fa27e8f1cb77', '97cd2be5-b45d-5732-a17a-4aa1dedcb12a', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a2ec987-7e81-5d36-b8ce-f6041d463cbd', '97cd2be5-b45d-5732-a17a-4aa1dedcb12a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('711b7efc-d4c9-5d35-b0e7-34025094becf', '97cd2be5-b45d-5732-a17a-4aa1dedcb12a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('497dd80f-b75d-5fdf-ab97-b6ee119d65f3', '27922804-6588-5a0d-99e4-53f5dded966d', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage ? In boxes 5-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The instability in an economy in some African countries might negatively impact their continuing growth after a certain level has been reached.
6
Collier is the most influential scholar in the study of the volatility problem.
7
Certain African governments levy considerable taxes on people profiting greatly from exportation.
8
Some African nation’s decisions on addressing specific existing problems are directly related to the future of their economic trends.
9
Collier regards Jeffrey D. Sachs recommended a way of evaluating of title importance.

9 ____ Collier regards Jeffrey D. Sachs recommended a way of evaluating of title importance.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8015fe97-a10d-5fd3-a403-5877b32d700d', '497dd80f-b75d-5fdf-ab97-b6ee119d65f3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('860b0177-1801-5376-ac09-830fdb3dca44', '497dd80f-b75d-5fdf-ab97-b6ee119d65f3', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4fd5d73e-3fb2-5f50-a601-d29ec5be7073', '497dd80f-b75d-5fdf-ab97-b6ee119d65f3', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('27441942-8bf2-5539-95fd-23fa41e1f24a', '27922804-6588-5a0d-99e4-53f5dded966d', 10, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage Volatility Kills, using No More than Three words from the Reading Passage Volatility Kills for each answer. Write your answers in boxes
10-13
on your answer sheet.
According to one research carried by the world bank, some countries in Africa may suffer from
10
due to the lack of according preconditions. they experienced a growth stimulated by
11
, but according to another study, they may not keep this trend stable because they don’t have
12
which would attract investors. to some countries with abundant resources, this fast-growth period might even mean something devastating to their endeavor. during one specific decade accompanied by
13
as a matter of fact, the governing saw a deterioration.

According to one research carried by the world bank, some countries in Africa may suffer from 10 ____ due to the lack of according preconditions. they experienced a growth stimulated by 11 ____ , but according to another study, they may not keep this trend stable because they don’t have 12 ____ which would attract investors. to some countries with abundant resources, this fast-growth period might even mean something devastating to their endeavor. during one specific decade accompanied by 13 ____ as a matter of fact, the governing saw a deterioration.$md$, NULL, ARRAY['.*the.*next.*crash.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('abd16ecd-ea46-528c-9dee-a7f41fbe3fab', '27922804-6588-5a0d-99e4-53f5dded966d', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage Volatility Kills, using No More than Three words from the Reading Passage Volatility Kills for each answer. Write your answers in boxes
10-13
on your answer sheet.
According to one research carried by the world bank, some countries in Africa may suffer from
10
due to the lack of according preconditions. they experienced a growth stimulated by
11
, but according to another study, they may not keep this trend stable because they don’t have
12
which would attract investors. to some countries with abundant resources, this fast-growth period might even mean something devastating to their endeavor. during one specific decade accompanied by
13
as a matter of fact, the governing saw a deterioration.

According to one research carried by the world bank, some countries in Africa may suffer from 10 ____ due to the lack of according preconditions. they experienced a growth stimulated by 11 ____ , but according to another study, they may not keep this trend stable because they don’t have 12 ____ which would attract investors. to some countries with abundant resources, this fast-growth period might even mean something devastating to their endeavor. during one specific decade accompanied by 13 ____ as a matter of fact, the governing saw a deterioration.$md$, NULL, ARRAY['.*the.*next.*crash.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c14d2d7e-da8d-5f97-bb20-5fd3f473f0ad', '27922804-6588-5a0d-99e4-53f5dded966d', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage Volatility Kills, using No More than Three words from the Reading Passage Volatility Kills for each answer. Write your answers in boxes
10-13
on your answer sheet.
According to one research carried by the world bank, some countries in Africa may suffer from
10
due to the lack of according preconditions. they experienced a growth stimulated by
11
, but according to another study, they may not keep this trend stable because they don’t have
12
which would attract investors. to some countries with abundant resources, this fast-growth period might even mean something devastating to their endeavor. during one specific decade accompanied by
13
as a matter of fact, the governing saw a deterioration.

According to one research carried by the world bank, some countries in Africa may suffer from 10 ____ due to the lack of according preconditions. they experienced a growth stimulated by 11 ____ , but according to another study, they may not keep this trend stable because they don’t have 12 ____ which would attract investors. to some countries with abundant resources, this fast-growth period might even mean something devastating to their endeavor. during one specific decade accompanied by 13 ____ as a matter of fact, the governing saw a deterioration.$md$, NULL, ARRAY['.*the.*next.*crash.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('23cadff6-f9cf-59f5-b33c-6d1873e8c50b', '27922804-6588-5a0d-99e4-53f5dded966d', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage Volatility Kills, using No More than Three words from the Reading Passage Volatility Kills for each answer. Write your answers in boxes
10-13
on your answer sheet.
According to one research carried by the world bank, some countries in Africa may suffer from
10
due to the lack of according preconditions. they experienced a growth stimulated by
11
, but according to another study, they may not keep this trend stable because they don’t have
12
which would attract investors. to some countries with abundant resources, this fast-growth period might even mean something devastating to their endeavor. during one specific decade accompanied by
13
as a matter of fact, the governing saw a deterioration.

According to one research carried by the world bank, some countries in Africa may suffer from 10 ____ due to the lack of according preconditions. they experienced a growth stimulated by 11 ____ , but according to another study, they may not keep this trend stable because they don’t have 12 ____ which would attract investors. to some countries with abundant resources, this fast-growth period might even mean something devastating to their endeavor. during one specific decade accompanied by 13 ____ as a matter of fact, the governing saw a deterioration.$md$, NULL, ARRAY['.*the.*next.*crash.*']);

COMMIT;
