BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-problem-of-climate-change--1213'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-problem-of-climate-change--1213';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-problem-of-climate-change--1213';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-problem-of-climate-change--1213';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('e2e50ecd-3baa-5fb4-9dfb-0b0326409010', 'ielts-reading-the-problem-of-climate-change--1213', $t$The problem of climate change$t$, $md$## The problem of climate change

Nguồn:
- Test: https://mini-ielts.com/1213/reading/the-problem-of-climate-change-
- Solution: https://mini-ielts.com/1213/view-solution/reading/the-problem-of-climate-change-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 'e2e50ecd-3baa-5fb4-9dfb-0b0326409010', 1, $t$Reading — The problem of climate change$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The problem of climate change

A

The climate of the Earth is always changing. In the past it has altered as a result of nat­ural causes. Nowadays, however, the term ‘climate change’ is generally used when referring to changes in our climate which have been identified since the early part of the twentieth century . The changes we’ve seen over recent years and those which are predicted to occur over the next 100 years are thought by many to be largely a result of human behavior rather than due to natural changes in the atmosphere. And this is what is so significant about current climactic trends; never before has man played such a significant role in determining long-term weather patterns – we are entering the unknown and there is no precedent for what might happen next.

B

The greenhouse effect is very important when we talk about climate change as it relates to the gases which keep the Earth warm. Although the greenhouse effect is a naturally occurring phenomenon , it is believed that the effect could be intensified by human activity and the emission of gases into the atmosphere . It is the extra green­house gases which humans have released which are thought to pose the strongest threat. Certain researchers, such as Dr Michael Crawley, argue: ‘even though this nat­ural phenomenon does exist it is without a doubt human activity that has worsened its effect ; this is evident when comparing data regarding the earth’s temperature in the last one hundred years with the one hundred years prior to that.’ Some scientists, however, dispute this as Dr Ray Ellis suggests: ‘human activity may be contributing a small amount to climate change but this increase in temperature is an unavoidable fact based on the research data we have compiled.

C

Scientists around the globe are look­ing at all the evidence surrounding climate change and using advanced technology have come up with pre­dictions for our future environment and weather. The next stage of that work, which is just as important, is looking at the knock-on effects of potential changes. For example, are we likely to see an increase in precip­itation and sea levels ? Does this mean there will be an increase in flooding and what can we do to protect ourselves from that? How will our health be affected by climate change, how will agricultural practices change and how will wildlife cope? What will the effects on coral be? Professor Max Leonard has suggested, ‘while it may be controversial some would argue that climate change could bring with it positive effects as well as negative ones ’.

D

There are many institutions around the world whose sole priority is to take action against these environmental problems . Green Peace is the organisation that is probably the most well-known. It is an international organisation that campaigns in favour of researching and promoting solutions to climate change, exposes the companies and governments that are blocking action , lobbies to change national and international policy, and bears witness to the impacts of unnecessary destruction and detrimental human activity.

E

The problem of climate change is without a doubt something that this generation and the generations to come need to deal with. Fortunately, the use of renewable energy is becoming increasingly popular , which means that less energy is consumed as renewable energy is generated from natural resources—such as sunlight, wind, rain, tides, and geo­thermal heat—which can be naturally replenished. Another way to help the environment, in terms of climate change, is by travelling light. Walking or riding a bike instead of driv­ing a car uses fewer fossil fuels which release carbon dioxide into the atmosphere. In addi­tion, using products that are made from recycled paper, glass, metal and plastic reduces carbon emissions because they use less energy to manufacture than products made from completely new materials. Recycling paper also saves trees and lets them continue to limit climate change naturally as they remain in the forest, where they remove carbon from the atmosphere. Professor Mark Halton, who has completed various studies in this field, has stated: ‘ with all this information and the possible action that we can take, it isn’t too late to save our planet from over-heating and the even worse side-effects of our own activity$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f20c0130-5765-58c4-b8f8-35cd21dfb438', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Question 1–5
Question 1–5
Reading Passage has 5 paragraphs,
A–E
.
Which paragraph contains the following information? Write the correct letter
A–E
in the boxes below.
NB
You may use any letter
more than once
.
1
A natural phenomenon that could also affect climate change.
Locate
2
Steps we can take to help reverse the situation.
3
An explanation of what climate change is.
Locate
4
Organisations that want to help.
Locate
5
Possible effects of climate change.
Locate

1 ____ A natural phenomenon that could also affect climate change. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d6b9258-c64d-56ef-95f9-50b43987f144', 'f20c0130-5765-58c4-b8f8-35cd21dfb438', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b08b5072-913b-5462-b14e-670550158fe9', 'f20c0130-5765-58c4-b8f8-35cd21dfb438', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('522dea29-ffc4-56bd-a718-be7d64bdde8e', 'f20c0130-5765-58c4-b8f8-35cd21dfb438', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b381acde-4672-516c-bcd5-b00eb9eecec5', 'f20c0130-5765-58c4-b8f8-35cd21dfb438', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d102b7e-e7f3-5d9f-ba9f-f48d96dafaf6', 'f20c0130-5765-58c4-b8f8-35cd21dfb438', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('beb3c329-c59a-5f68-8260-8992c95442de', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Question 1–5
Question 1–5
Reading Passage has 5 paragraphs,
A–E
.
Which paragraph contains the following information? Write the correct letter
A–E
in the boxes below.
NB
You may use any letter
more than once
.
1
A natural phenomenon that could also affect climate change.
Locate
2
Steps we can take to help reverse the situation.
3
An explanation of what climate change is.
Locate
4
Organisations that want to help.
Locate
5
Possible effects of climate change.
Locate

2 ____ Steps we can take to help reverse the situation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d06b29cc-dc2d-5a4b-86c9-d5855aed9d79', 'beb3c329-c59a-5f68-8260-8992c95442de', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71f68eb6-144b-5806-9b1b-fc4f8eabe2d6', 'beb3c329-c59a-5f68-8260-8992c95442de', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b93ce5bf-fdfa-56e1-908a-0cd2b2e13c6c', 'beb3c329-c59a-5f68-8260-8992c95442de', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2265b45-261b-51d2-8386-2faeec3368fb', 'beb3c329-c59a-5f68-8260-8992c95442de', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6673d47d-9bb4-56bf-97c3-d9bc8cf62a70', 'beb3c329-c59a-5f68-8260-8992c95442de', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a708ee7c-f8f2-568e-b2b2-7c09c1591c14', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Question 1–5
Question 1–5
Reading Passage has 5 paragraphs,
A–E
.
Which paragraph contains the following information? Write the correct letter
A–E
in the boxes below.
NB
You may use any letter
more than once
.
1
A natural phenomenon that could also affect climate change.
Locate
2
Steps we can take to help reverse the situation.
3
An explanation of what climate change is.
Locate
4
Organisations that want to help.
Locate
5
Possible effects of climate change.
Locate

3 ____ An explanation of what climate change is. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2366ec94-ed8c-57c0-82fa-c0e43f55dc94', 'a708ee7c-f8f2-568e-b2b2-7c09c1591c14', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b708e45d-d6a3-5871-81ed-f59563f3a930', 'a708ee7c-f8f2-568e-b2b2-7c09c1591c14', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14fc3c9e-bc30-562e-8e63-1bc4c4668adf', 'a708ee7c-f8f2-568e-b2b2-7c09c1591c14', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efa874dc-c840-570a-ad4a-a009c2b115ac', 'a708ee7c-f8f2-568e-b2b2-7c09c1591c14', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10939942-8763-5c42-94c8-2ce9d1690e99', 'a708ee7c-f8f2-568e-b2b2-7c09c1591c14', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f0c8ae74-51f4-53eb-8eda-dd895a1f964f', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Question 1–5
Question 1–5
Reading Passage has 5 paragraphs,
A–E
.
Which paragraph contains the following information? Write the correct letter
A–E
in the boxes below.
NB
You may use any letter
more than once
.
1
A natural phenomenon that could also affect climate change.
Locate
2
Steps we can take to help reverse the situation.
3
An explanation of what climate change is.
Locate
4
Organisations that want to help.
Locate
5
Possible effects of climate change.
Locate

4 ____ Organisations that want to help. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24f279bf-9709-5c09-b72b-3feed482e460', 'f0c8ae74-51f4-53eb-8eda-dd895a1f964f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffe3dd64-1ddb-52ea-91cc-28ffffddba52', 'f0c8ae74-51f4-53eb-8eda-dd895a1f964f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e67be79-33ae-58af-b479-4327b33fd471', 'f0c8ae74-51f4-53eb-8eda-dd895a1f964f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed8db98d-4952-52d4-befd-b4d495e16265', 'f0c8ae74-51f4-53eb-8eda-dd895a1f964f', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf661d21-d963-58e5-8b67-cf1f3b11b83c', 'f0c8ae74-51f4-53eb-8eda-dd895a1f964f', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1b69f09-54ca-5e54-899c-682c671de7b9', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Question 1–5
Question 1–5
Reading Passage has 5 paragraphs,
A–E
.
Which paragraph contains the following information? Write the correct letter
A–E
in the boxes below.
NB
You may use any letter
more than once
.
1
A natural phenomenon that could also affect climate change.
Locate
2
Steps we can take to help reverse the situation.
3
An explanation of what climate change is.
Locate
4
Organisations that want to help.
Locate
5
Possible effects of climate change.
Locate

5 ____ Possible effects of climate change. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c4564b6-9da2-5de1-84f8-974f40cfcfae', 'e1b69f09-54ca-5e54-899c-682c671de7b9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4e26b47-e8ea-59eb-8fa3-6cf5d455ecd4', 'e1b69f09-54ca-5e54-899c-682c671de7b9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8049fda-3fc3-5741-8016-01988f1ff31a', 'e1b69f09-54ca-5e54-899c-682c671de7b9', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49e17242-3d27-5328-9c1e-596ba763c694', 'e1b69f09-54ca-5e54-899c-682c671de7b9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef8c3e96-0c47-5972-b01d-8c2b1ca744d0', 'e1b69f09-54ca-5e54-899c-682c671de7b9', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bb1afed2-8598-534d-92d2-a2b7c2534424', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Question 6-9
Question 6-9
Look at the following people (Questions
6-9
) and the list of statements below.
Match each person with the correct statement,
A-F
.
A.
We have the ability to change the situation
B
. Climate Change is Inevitable
C
. Humans have made the situation much worse
D.
Climate Change might not be all bad
E.
Human activity and natural weather phenomena
F.
While we may not be too late to save our planet, there are bound to be some extreme side-effects of past human activity one way or the other
6
Professor Max Leonard
Locate
7
Dr Michael Crawley
Locate
8
Professor Mark Halton
Locate
9
Dr Ray Ellis
Locate

6 ____ Professor Max Leonard Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('207ad5a4-8a7c-5f14-89db-ee3022f84483', 'bb1afed2-8598-534d-92d2-a2b7c2534424', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7748fe0-7c12-5a2e-b55e-5d90016fcd47', 'bb1afed2-8598-534d-92d2-a2b7c2534424', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efad7426-1e46-5058-a922-852337f7e2c5', 'bb1afed2-8598-534d-92d2-a2b7c2534424', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f9783f0-1466-52da-ab7a-1b2898beb6a0', 'bb1afed2-8598-534d-92d2-a2b7c2534424', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('685000eb-b274-516c-8717-976b1b611aa2', 'bb1afed2-8598-534d-92d2-a2b7c2534424', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('174b1d4f-cc0b-57fc-9817-63052fa1f614', 'bb1afed2-8598-534d-92d2-a2b7c2534424', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0a94786d-bd08-562e-a5a8-9a41bb69f7e2', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Question 6-9
Question 6-9
Look at the following people (Questions
6-9
) and the list of statements below.
Match each person with the correct statement,
A-F
.
A.
We have the ability to change the situation
B
. Climate Change is Inevitable
C
. Humans have made the situation much worse
D.
Climate Change might not be all bad
E.
Human activity and natural weather phenomena
F.
While we may not be too late to save our planet, there are bound to be some extreme side-effects of past human activity one way or the other
6
Professor Max Leonard
Locate
7
Dr Michael Crawley
Locate
8
Professor Mark Halton
Locate
9
Dr Ray Ellis
Locate

7 ____ Dr Michael Crawley Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22c18a7a-9bf1-5447-affd-3d56fb04e2ad', '0a94786d-bd08-562e-a5a8-9a41bb69f7e2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab62b34d-2a16-5f42-ab5a-4152b3ce9aba', '0a94786d-bd08-562e-a5a8-9a41bb69f7e2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ba2510a-320d-58c4-bd5f-e6f6960789ac', '0a94786d-bd08-562e-a5a8-9a41bb69f7e2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96647a0b-60e1-5641-a674-09638e92217e', '0a94786d-bd08-562e-a5a8-9a41bb69f7e2', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66983ba6-66ed-5f72-a59b-81ef5147de10', '0a94786d-bd08-562e-a5a8-9a41bb69f7e2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07a9d840-e9ed-53d0-a247-26d17ad11d95', '0a94786d-bd08-562e-a5a8-9a41bb69f7e2', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('83bf2c0f-9671-5c07-a34c-2ac4cf067696', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Question 6-9
Question 6-9
Look at the following people (Questions
6-9
) and the list of statements below.
Match each person with the correct statement,
A-F
.
A.
We have the ability to change the situation
B
. Climate Change is Inevitable
C
. Humans have made the situation much worse
D.
Climate Change might not be all bad
E.
Human activity and natural weather phenomena
F.
While we may not be too late to save our planet, there are bound to be some extreme side-effects of past human activity one way or the other
6
Professor Max Leonard
Locate
7
Dr Michael Crawley
Locate
8
Professor Mark Halton
Locate
9
Dr Ray Ellis
Locate

8 ____ Professor Mark Halton Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eed98f6c-e7b4-5aa7-a164-64d3141dfbfa', '83bf2c0f-9671-5c07-a34c-2ac4cf067696', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('863bbb8e-dc76-5109-b6f9-40e61b60960a', '83bf2c0f-9671-5c07-a34c-2ac4cf067696', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f33a8633-21e0-5ff5-9670-d28fddbdc9ee', '83bf2c0f-9671-5c07-a34c-2ac4cf067696', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29f4a930-0f00-54d1-a542-4f06b9573800', '83bf2c0f-9671-5c07-a34c-2ac4cf067696', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf49b57b-0c08-535e-85a6-eec35cd6f13f', '83bf2c0f-9671-5c07-a34c-2ac4cf067696', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab5226d0-031e-5c5a-9c75-fbb8b1d569b8', '83bf2c0f-9671-5c07-a34c-2ac4cf067696', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a967815-503b-52b7-b3a2-a4f4773cf147', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Question 6-9
Question 6-9
Look at the following people (Questions
6-9
) and the list of statements below.
Match each person with the correct statement,
A-F
.
A.
We have the ability to change the situation
B
. Climate Change is Inevitable
C
. Humans have made the situation much worse
D.
Climate Change might not be all bad
E.
Human activity and natural weather phenomena
F.
While we may not be too late to save our planet, there are bound to be some extreme side-effects of past human activity one way or the other
6
Professor Max Leonard
Locate
7
Dr Michael Crawley
Locate
8
Professor Mark Halton
Locate
9
Dr Ray Ellis
Locate

9 ____ Dr Ray Ellis Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7d93ebf-8d2d-5af5-9d1a-9bd0768dc675', '9a967815-503b-52b7-b3a2-a4f4773cf147', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e070bc9-849f-58ec-8aac-a1208aab5e4d', '9a967815-503b-52b7-b3a2-a4f4773cf147', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e64cd5c-7ec2-5849-8b78-4086e7b23f56', '9a967815-503b-52b7-b3a2-a4f4773cf147', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22ecfb80-d871-5c34-9e12-64dd982c4a70', '9a967815-503b-52b7-b3a2-a4f4773cf147', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01800716-4c53-5559-8d5a-ee1eb5d9f16e', '9a967815-503b-52b7-b3a2-a4f4773cf147', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af7057e9-ce2a-5e51-acef-7b806d791498', '9a967815-503b-52b7-b3a2-a4f4773cf147', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('57ef4b9c-7f80-5d1a-abe4-ea9a246e9bdc', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage? In spaces
10-13
below, write
TRUE
if the statements agrees with the information
FALSE
if the statements contradicts the information
NOT GIVEN
if there is no information on this
10
Man is not entirely responsible for global warming.
Locate
11
Scientists have come up with new evidence about the negative effects of carbon-free sources of energy such as nuclear power
12
One of the purposes of Green Peace is to find out which companies and governments are doing things which don’t help the actions of environmentalists.
Locate
13
Most people aren’t willing to start using renewable energy.
Locate

10 ____ Man is not entirely responsible for global warming. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54085aed-45c2-5569-9aa2-14c74bfb8b31', '57ef4b9c-7f80-5d1a-abe4-ea9a246e9bdc', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d3df6b3-1ca9-59e5-bcc4-6a79a0e4a9b3', '57ef4b9c-7f80-5d1a-abe4-ea9a246e9bdc', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('890fad12-c1df-5405-afdb-1c1635c75058', '57ef4b9c-7f80-5d1a-abe4-ea9a246e9bdc', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f3047740-83bc-5edc-9ab7-02692577416d', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage? In spaces
10-13
below, write
TRUE
if the statements agrees with the information
FALSE
if the statements contradicts the information
NOT GIVEN
if there is no information on this
10
Man is not entirely responsible for global warming.
Locate
11
Scientists have come up with new evidence about the negative effects of carbon-free sources of energy such as nuclear power
12
One of the purposes of Green Peace is to find out which companies and governments are doing things which don’t help the actions of environmentalists.
Locate
13
Most people aren’t willing to start using renewable energy.
Locate

11 ____ Scientists have come up with new evidence about the negative effects of carbon-free sources of energy such as nuclear power$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80affaea-b8b6-5bab-8262-97e37db9ee2c', 'f3047740-83bc-5edc-9ab7-02692577416d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c4c3433-9253-5142-860d-d20e27bf5414', 'f3047740-83bc-5edc-9ab7-02692577416d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c98b027-39db-57cc-b119-b05201bf19b8', 'f3047740-83bc-5edc-9ab7-02692577416d', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3aaaed2e-9af7-5d18-84cc-d0d471005102', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage? In spaces
10-13
below, write
TRUE
if the statements agrees with the information
FALSE
if the statements contradicts the information
NOT GIVEN
if there is no information on this
10
Man is not entirely responsible for global warming.
Locate
11
Scientists have come up with new evidence about the negative effects of carbon-free sources of energy such as nuclear power
12
One of the purposes of Green Peace is to find out which companies and governments are doing things which don’t help the actions of environmentalists.
Locate
13
Most people aren’t willing to start using renewable energy.
Locate

12 ____ One of the purposes of Green Peace is to find out which companies and governments are doing things which don’t help the actions of environmentalists. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87d7ef80-49a9-5fa6-8759-34f2a6f57fbf', '3aaaed2e-9af7-5d18-84cc-d0d471005102', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69116916-f063-5af9-b5c6-f66ff3e1e914', '3aaaed2e-9af7-5d18-84cc-d0d471005102', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b92af39-bbda-57f3-95e5-3e33f52d612b', '3aaaed2e-9af7-5d18-84cc-d0d471005102', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('93f3ce1e-8eff-5492-b617-f785bb7c592d', 'c40a2b2a-42ad-5dc6-8029-5ab3841bb3f1', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage? In spaces
10-13
below, write
TRUE
if the statements agrees with the information
FALSE
if the statements contradicts the information
NOT GIVEN
if there is no information on this
10
Man is not entirely responsible for global warming.
Locate
11
Scientists have come up with new evidence about the negative effects of carbon-free sources of energy such as nuclear power
12
One of the purposes of Green Peace is to find out which companies and governments are doing things which don’t help the actions of environmentalists.
Locate
13
Most people aren’t willing to start using renewable energy.
Locate

13 ____ Most people aren’t willing to start using renewable energy. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('935384fb-158b-596d-8b66-6264c23dad46', '93f3ce1e-8eff-5492-b617-f785bb7c592d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db9b8cec-aa79-54e1-952d-f8084d48ca71', '93f3ce1e-8eff-5492-b617-f785bb7c592d', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66f355a1-f3a8-5d4d-8179-17ed4326aadf', '93f3ce1e-8eff-5492-b617-f785bb7c592d', 3, $md$NOT GIVEN$md$, false);

COMMIT;
