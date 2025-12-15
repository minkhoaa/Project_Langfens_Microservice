BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-growing-up-in-new-zealand-1423'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-growing-up-in-new-zealand-1423';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-growing-up-in-new-zealand-1423';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-growing-up-in-new-zealand-1423';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c9d96d7e-f18f-5c1c-bffc-939fce17ce3f', 'ielts-reading-growing-up-in-new-zealand-1423', $t$Growing up in New Zealand$t$, $md$## Growing up in New Zealand

Nguồn:
- Test: https://mini-ielts.com/1423/reading/growing-up-in-new-zealand
- Solution: https://mini-ielts.com/1423/view-solution/reading/growing-up-in-new-zealand$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f1a89b4d-ab0b-5e98-b504-044d5dd68538', 'c9d96d7e-f18f-5c1c-bffc-939fce17ce3f', 1, $t$Reading — Growing up in New Zealand$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Growing up in New Zealand

It has long been known that the first one thousand days of life are the most critical in ensuring a person’s healthy future; precisely what happens during this period to any individual has been less well documented. To allocate resources appropriately, public health and education policies need to be based upon quantifiable data, so the New Zealand Ministry of Social Development began a longitudinal study of these early days, with the view to extending it for two decades. Born between March 2009 and May 20I0, the 6,846 babies recruited came from a densely populated area of New Zealand, and it is hoped they will be followed until they reach the age of 21.

By 2014, fur reports, collectively known as Growing Up in New Zealand ( GUiNZ ), had been published, showing New Zealand to be a complex, changing country, with the participants and their families’ being markedly diﬀerent from those of previous generations.

Of the 6,846 babies, the majority were identified as European New Zealanders, but one quarter was Maori (indigenous New Zealanders), 20% were Pacific (originating in islands in the Pacific), and one in six were Asian. Almost 50% of the children had more than one ethnicity.

The first three reports of GUiNZ ae descriptive, portraying the cohort before birth, at nine months, and at two years of age. Already, the first report, Before we are born , has made history as it contains interviews with the children’s mothers and fathers. The fourth report, which is more analytical, explores the definition of vulnerability for children in their first one thousand days.

Before we are born , published in 2010, describes the hopes, dreams, and realities that prospective parents have. It shows that the average age of both parents having a child was 30, and around two-thirds of parents were in legally binding relationships. However, one-third of the children were born to either a mother or a father who did not grow up in New Zealand – a significant diﬀerence from previous longitudinal studies in which a vast majority of parents were New Zealanders born and bred. Around 60% of the births in the cohort were planned, and most families hoped to have two or three children. During pregnancy, some women changed their behaviour, with regard to smoking, alcohol, and exercise, but many did not. Such information will be useful for public health campaigns.

Now we are born is the second report. Fifty-two percent of its babies were male and 48% female, with nearly a quarter delivered by caesarean section. The World Health Organisation and New Zealand guidelines recommend babies be breastfed exclusively for six months, but the median age for this in the GUiNZ cohort was fur months since almost one-third of mothers had returned to full-time work. By nine months, the babies were all eating solid food. While 54% of them were living in accommodation their families owned, their parents had almost all experienced a drop in income, sometimes a steep one, mostly due to mothers’ not working. Over 90% of the babies were immunised, and almost all were in very good health. Of the mothers, however, 11% had experienced post-natal depression – an alarming statistic, perhaps, but, once again, useful for mental health campaigns. Many of the babies were put in childcare while their mothers worked or studied, and the providers varied by ethnicity: children who were Maori or Pacific were more likely to be looked after by grandparents; European New Zealanders tended to be sent to daycare.

Now we are two , the third report, provides more insights into the children’s development – physically, emotionally, behaviourally, and cognitively. Major changes in home environments are documented, like the socio-economic situation, and childcare arrangements. Information was collected both from direct observations of the children and from parental interviews. Once again, a high proportion of New Zealand two-year-olds were in very good health. Two-thirds of the children knew their gender, and used their own name or expressed independence in some way. The most common first word was a variation on ‘Mum’, and the most common favourite first food was a banana. Bilingual or multi-lingual children were in a large minority of 40%. Digital exposure was high: one in seven two-year-olds had used a laptop or a children’s computer, and 80% watched TV or DVDs daily; by contrast, 66% had books read to them each day.

The fourth report evaluates twelve environmental risk factors that increase the likelihood of poor developmental outcomes for children and draws on experiences in Western Europe, where the specific factors were collated. This, however, was the first time for their use in a New Zealand context. The factors include: being born to an adolescent mother; having one or both parents on income-tested benefits; and, living in cramped conditions.

In addition to descriptive ones, future reports will focus on children who move in and out of vulnerability to see how these transitions aﬀect their later life.

To date, GUiNZ has been highly successful with only a very small dropout rate for participants – even those living abroad, predominantly in Australia, have continued to provide information. The portrait GUiNZ paints of a country and its people are indeed revealing.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3cb2ab58-48ba-5ea9-8322-d3f6a9afa192', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Passage?
In boxes
1-6
on your answer sheet, write:
TRUE
if the statement agrees with the information.
FALSE
if the statement contradicts the information.
NOT
GIVEN
if there is no information on this.
1
Findings from studies like
GUiNZ
will inform public policy.
2
Exactly 6,846 babies formed the
GUiNZ
cohort.
3
GUiNZ
will probably end when the children reach ten.
4
Eventually, there will be 21 reports in
GUiNZ
.
5
So far,
GUiNZ
has shown New Zealanders today to be rather similar to those of 25 years ago.
6
Parents who took part in
GUiNZ
believe New Zealand is a good place to raise children.

1 ____ Findings from studies like GUiNZ will inform public policy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb4e4ca5-33c7-5198-b36d-8df9e40951dc', '3cb2ab58-48ba-5ea9-8322-d3f6a9afa192', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b890d143-9be3-566b-a756-8a102b950948', '3cb2ab58-48ba-5ea9-8322-d3f6a9afa192', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('837213ee-d884-554b-bcbe-0e7a7fd551dc', '3cb2ab58-48ba-5ea9-8322-d3f6a9afa192', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a8b1bfc9-78b9-581c-bc22-45f61dc3cd98', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Passage?
In boxes
1-6
on your answer sheet, write:
TRUE
if the statement agrees with the information.
FALSE
if the statement contradicts the information.
NOT
GIVEN
if there is no information on this.
1
Findings from studies like
GUiNZ
will inform public policy.
2
Exactly 6,846 babies formed the
GUiNZ
cohort.
3
GUiNZ
will probably end when the children reach ten.
4
Eventually, there will be 21 reports in
GUiNZ
.
5
So far,
GUiNZ
has shown New Zealanders today to be rather similar to those of 25 years ago.
6
Parents who took part in
GUiNZ
believe New Zealand is a good place to raise children.

2 ____ Exactly 6,846 babies formed the GUiNZ cohort.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('716c84cd-a266-5e1a-918d-ebe58bca4c08', 'a8b1bfc9-78b9-581c-bc22-45f61dc3cd98', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ca733ef-5a88-59dc-b336-b33e704169f0', 'a8b1bfc9-78b9-581c-bc22-45f61dc3cd98', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a157d562-6b62-5204-93f9-803daf226fb1', 'a8b1bfc9-78b9-581c-bc22-45f61dc3cd98', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e6baff13-1f7b-5db5-8867-01132ef7c78e', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Passage?
In boxes
1-6
on your answer sheet, write:
TRUE
if the statement agrees with the information.
FALSE
if the statement contradicts the information.
NOT
GIVEN
if there is no information on this.
1
Findings from studies like
GUiNZ
will inform public policy.
2
Exactly 6,846 babies formed the
GUiNZ
cohort.
3
GUiNZ
will probably end when the children reach ten.
4
Eventually, there will be 21 reports in
GUiNZ
.
5
So far,
GUiNZ
has shown New Zealanders today to be rather similar to those of 25 years ago.
6
Parents who took part in
GUiNZ
believe New Zealand is a good place to raise children.

3 ____ GUiNZ will probably end when the children reach ten.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3df7202-ca23-5151-8335-e465d1a472ca', 'e6baff13-1f7b-5db5-8867-01132ef7c78e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66cbb65e-1fd3-5788-aa9e-7da7684b9d95', 'e6baff13-1f7b-5db5-8867-01132ef7c78e', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9e9208e-b12c-51ce-93a0-88c36630f663', 'e6baff13-1f7b-5db5-8867-01132ef7c78e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a902e750-6482-5f65-98fe-39e3c95b2b64', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Passage?
In boxes
1-6
on your answer sheet, write:
TRUE
if the statement agrees with the information.
FALSE
if the statement contradicts the information.
NOT
GIVEN
if there is no information on this.
1
Findings from studies like
GUiNZ
will inform public policy.
2
Exactly 6,846 babies formed the
GUiNZ
cohort.
3
GUiNZ
will probably end when the children reach ten.
4
Eventually, there will be 21 reports in
GUiNZ
.
5
So far,
GUiNZ
has shown New Zealanders today to be rather similar to those of 25 years ago.
6
Parents who took part in
GUiNZ
believe New Zealand is a good place to raise children.

4 ____ Eventually, there will be 21 reports in GUiNZ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4e07ad3-0ab2-54ef-b44b-c2acafa57fe5', 'a902e750-6482-5f65-98fe-39e3c95b2b64', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('569b22e5-add1-5119-a142-094836675c79', 'a902e750-6482-5f65-98fe-39e3c95b2b64', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59fb985e-f1f4-56d6-ae6e-7c158dfa683a', 'a902e750-6482-5f65-98fe-39e3c95b2b64', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bfaed3b4-59dd-5f47-8e6e-89726f008dc7', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Passage?
In boxes
1-6
on your answer sheet, write:
TRUE
if the statement agrees with the information.
FALSE
if the statement contradicts the information.
NOT
GIVEN
if there is no information on this.
1
Findings from studies like
GUiNZ
will inform public policy.
2
Exactly 6,846 babies formed the
GUiNZ
cohort.
3
GUiNZ
will probably end when the children reach ten.
4
Eventually, there will be 21 reports in
GUiNZ
.
5
So far,
GUiNZ
has shown New Zealanders today to be rather similar to those of 25 years ago.
6
Parents who took part in
GUiNZ
believe New Zealand is a good place to raise children.

5 ____ So far, GUiNZ has shown New Zealanders today to be rather similar to those of 25 years ago.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9986407-a4a0-5b9d-b52a-a134a45aad11', 'bfaed3b4-59dd-5f47-8e6e-89726f008dc7', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19fdce8f-4e57-59aa-9971-eea66cd4255c', 'bfaed3b4-59dd-5f47-8e6e-89726f008dc7', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31e24cdf-30ac-5f53-9d94-365d1381bd5f', 'bfaed3b4-59dd-5f47-8e6e-89726f008dc7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7548366e-1366-538e-afdc-aedc5022ba30', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Passage?
In boxes
1-6
on your answer sheet, write:
TRUE
if the statement agrees with the information.
FALSE
if the statement contradicts the information.
NOT
GIVEN
if there is no information on this.
1
Findings from studies like
GUiNZ
will inform public policy.
2
Exactly 6,846 babies formed the
GUiNZ
cohort.
3
GUiNZ
will probably end when the children reach ten.
4
Eventually, there will be 21 reports in
GUiNZ
.
5
So far,
GUiNZ
has shown New Zealanders today to be rather similar to those of 25 years ago.
6
Parents who took part in
GUiNZ
believe New Zealand is a good place to raise children.

6 ____ Parents who took part in GUiNZ believe New Zealand is a good place to raise children.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c321d6e7-35c3-5261-8db1-4ad3d3da72d2', '7548366e-1366-538e-afdc-aedc5022ba30', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fc4a06d-a3be-55e9-b114-0e817a967662', '7548366e-1366-538e-afdc-aedc5022ba30', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1c462bc-bfb5-5627-8546-4d292087e10a', '7548366e-1366-538e-afdc-aedc5022ba30', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0dafefba-e3ac-50aa-8b8d-7e7ce395f322', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Classify the following things that relate to:
A
Report 1.
B
Report 2.
C
Report 3.
D
Report 4.
Write the correct letter
A
,
B
,
C
, or
D
, in boxes
7-13
on your answer sheet.
7
This is unique because it contains interviews with both parents.
8
This looks at how children might be at risk.
9
This suggests having a child may lead to financial hardship.
10
Information for this came from direct observations of children.
11
This shows many children use electronic devices.
12
This was modelled on criteria used in Western Europe.
13
This suggests having a teenage mother could negatively aﬀect a child.

7 ____ This is unique because it contains interviews with both parents.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be33fa94-ed59-57f4-9df0-f291f67143fc', '0dafefba-e3ac-50aa-8b8d-7e7ce395f322', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f635b45b-07e1-5ea7-95b9-243b9a3dc07a', '0dafefba-e3ac-50aa-8b8d-7e7ce395f322', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79f52c6d-bffe-50e9-8a10-26401cb23abf', '0dafefba-e3ac-50aa-8b8d-7e7ce395f322', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e09a88b-33cc-5a8f-b969-96105221f31c', '0dafefba-e3ac-50aa-8b8d-7e7ce395f322', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b6928953-1712-5cbc-9a31-9a7822ce5655', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Classify the following things that relate to:
A
Report 1.
B
Report 2.
C
Report 3.
D
Report 4.
Write the correct letter
A
,
B
,
C
, or
D
, in boxes
7-13
on your answer sheet.
7
This is unique because it contains interviews with both parents.
8
This looks at how children might be at risk.
9
This suggests having a child may lead to financial hardship.
10
Information for this came from direct observations of children.
11
This shows many children use electronic devices.
12
This was modelled on criteria used in Western Europe.
13
This suggests having a teenage mother could negatively aﬀect a child.

8 ____ This looks at how children might be at risk.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e7b34b5-4916-5690-93d7-3669745e8b99', 'b6928953-1712-5cbc-9a31-9a7822ce5655', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1084e185-1287-5987-ba23-42601031c9ee', 'b6928953-1712-5cbc-9a31-9a7822ce5655', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acfb6581-aaee-5007-9e99-332a698f6fe3', 'b6928953-1712-5cbc-9a31-9a7822ce5655', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47519402-fafd-5bed-b7ef-1073d6f39faa', 'b6928953-1712-5cbc-9a31-9a7822ce5655', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e4b50ad-af8b-5650-9630-79d53556d9ff', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Classify the following things that relate to:
A
Report 1.
B
Report 2.
C
Report 3.
D
Report 4.
Write the correct letter
A
,
B
,
C
, or
D
, in boxes
7-13
on your answer sheet.
7
This is unique because it contains interviews with both parents.
8
This looks at how children might be at risk.
9
This suggests having a child may lead to financial hardship.
10
Information for this came from direct observations of children.
11
This shows many children use electronic devices.
12
This was modelled on criteria used in Western Europe.
13
This suggests having a teenage mother could negatively aﬀect a child.

9 ____ This suggests having a child may lead to financial hardship.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5082eb73-39ed-53b3-8f7f-287833daf790', '6e4b50ad-af8b-5650-9630-79d53556d9ff', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('392d4515-edb0-55e3-a275-d54efe936745', '6e4b50ad-af8b-5650-9630-79d53556d9ff', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b66e05ba-660a-5c9b-9498-338dc3a4da34', '6e4b50ad-af8b-5650-9630-79d53556d9ff', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87841e09-05e8-54e5-9901-d995234bddc6', '6e4b50ad-af8b-5650-9630-79d53556d9ff', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4f438d31-37a2-56e8-9538-c3d08161c652', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Classify the following things that relate to:
A
Report 1.
B
Report 2.
C
Report 3.
D
Report 4.
Write the correct letter
A
,
B
,
C
, or
D
, in boxes
7-13
on your answer sheet.
7
This is unique because it contains interviews with both parents.
8
This looks at how children might be at risk.
9
This suggests having a child may lead to financial hardship.
10
Information for this came from direct observations of children.
11
This shows many children use electronic devices.
12
This was modelled on criteria used in Western Europe.
13
This suggests having a teenage mother could negatively aﬀect a child.

10 ____ Information for this came from direct observations of children.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5a1d6bd-626f-5021-bffc-ab60edcb203b', '4f438d31-37a2-56e8-9538-c3d08161c652', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81d37ebc-14c3-5acc-b440-8974ff83ab0b', '4f438d31-37a2-56e8-9538-c3d08161c652', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('433e5740-cd95-57f2-88f5-d5d6cd2c4e39', '4f438d31-37a2-56e8-9538-c3d08161c652', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aadb8ef4-ecf4-5a48-a425-221d0bfc72d3', '4f438d31-37a2-56e8-9538-c3d08161c652', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0e9e84e0-12fd-5b94-b38a-7214865ae863', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Classify the following things that relate to:
A
Report 1.
B
Report 2.
C
Report 3.
D
Report 4.
Write the correct letter
A
,
B
,
C
, or
D
, in boxes
7-13
on your answer sheet.
7
This is unique because it contains interviews with both parents.
8
This looks at how children might be at risk.
9
This suggests having a child may lead to financial hardship.
10
Information for this came from direct observations of children.
11
This shows many children use electronic devices.
12
This was modelled on criteria used in Western Europe.
13
This suggests having a teenage mother could negatively aﬀect a child.

11 ____ This shows many children use electronic devices.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab1f75cf-379e-5e5b-bc82-e7d84cf52e0f', '0e9e84e0-12fd-5b94-b38a-7214865ae863', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38a02aba-fee9-5e92-b0fc-fcfe22cbeacf', '0e9e84e0-12fd-5b94-b38a-7214865ae863', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a618bec-460f-5edb-9042-7b7ffbf67778', '0e9e84e0-12fd-5b94-b38a-7214865ae863', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91b5333e-5812-5e65-96fe-143c6dba0b11', '0e9e84e0-12fd-5b94-b38a-7214865ae863', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7232abb4-3362-5290-91eb-ff3405977ecf', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Classify the following things that relate to:
A
Report 1.
B
Report 2.
C
Report 3.
D
Report 4.
Write the correct letter
A
,
B
,
C
, or
D
, in boxes
7-13
on your answer sheet.
7
This is unique because it contains interviews with both parents.
8
This looks at how children might be at risk.
9
This suggests having a child may lead to financial hardship.
10
Information for this came from direct observations of children.
11
This shows many children use electronic devices.
12
This was modelled on criteria used in Western Europe.
13
This suggests having a teenage mother could negatively aﬀect a child.

12 ____ This was modelled on criteria used in Western Europe.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da450fa1-837e-5438-8239-a284bb0f4cc9', '7232abb4-3362-5290-91eb-ff3405977ecf', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('490600e8-1ba4-50ac-a121-60af19e58474', '7232abb4-3362-5290-91eb-ff3405977ecf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('293bfb98-c05f-55f6-b3b4-3e40f2b057ee', '7232abb4-3362-5290-91eb-ff3405977ecf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5090a62f-192f-53ec-92ab-64ee44707162', '7232abb4-3362-5290-91eb-ff3405977ecf', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('62cfe726-5b0b-5dcd-8c7c-6c72004c3589', 'f1a89b4d-ab0b-5e98-b504-044d5dd68538', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Classify the following things that relate to:
A
Report 1.
B
Report 2.
C
Report 3.
D
Report 4.
Write the correct letter
A
,
B
,
C
, or
D
, in boxes
7-13
on your answer sheet.
7
This is unique because it contains interviews with both parents.
8
This looks at how children might be at risk.
9
This suggests having a child may lead to financial hardship.
10
Information for this came from direct observations of children.
11
This shows many children use electronic devices.
12
This was modelled on criteria used in Western Europe.
13
This suggests having a teenage mother could negatively aﬀect a child.

13 ____ This suggests having a teenage mother could negatively aﬀect a child.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0e4362f-4ef5-53b0-90d6-b743532b8259', '62cfe726-5b0b-5dcd-8c7c-6c72004c3589', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4221c64d-6a8f-5ad9-be94-24affb36f94a', '62cfe726-5b0b-5dcd-8c7c-6c72004c3589', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd083807-8c8b-56fc-9acc-3d771e190feb', '62cfe726-5b0b-5dcd-8c7c-6c72004c3589', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a976c329-0fb7-5548-92f1-73e1d8d555d9', '62cfe726-5b0b-5dcd-8c7c-6c72004c3589', 4, $md$D$md$, true);

COMMIT;
