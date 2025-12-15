BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-a-theory-of-shopping-1229'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-theory-of-shopping-1229';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-theory-of-shopping-1229';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-a-theory-of-shopping-1229';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2bbae442-829d-57dd-b5de-b5834de8e080', 'ielts-reading-a-theory-of-shopping-1229', $t$A Theory of Shopping$t$, $md$## A Theory of Shopping

Nguồn:
- Test: https://mini-ielts.com/1229/reading/a-theory-of-shopping
- Solution: https://mini-ielts.com/1229/view-solution/reading/a-theory-of-shopping$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('216f4c58-796a-5236-9b9f-ea7dcc590f8d', '2bbae442-829d-57dd-b5de-b5834de8e080', 1, $t$Reading — A Theory of Shopping$t$, $md$Read the passage and answer questions **1–11**.

### Passage: A Theory of Shopping

For a one-year period I attempted to conduct an ethnography of shopping on and around a street in North London. This was carried out in association with Alison Clarke. I say ‘attempted’ because, given the absence of community and the intensely private nature of London households, this could not be an ethnography in the conventional sense. Nevertheless, through conversation, being present in the home and accompanying householders during their shopping, I tried to reach an understanding of the nature of shopping through greater or lesser exposure to 76 households.

My part of the ethnography concentrated upon shopping itself. Alison Clarke has since been working with the same households, but focusing upon other forms of provisioning such as the use of catalogues (see Clarke 1997). We generally first met these households together, but most of the material that is used within this particular essay derived from my own subsequent fieldwork. Following the completion of this essay, and a study of some related shopping centres, we hope to write a more general ethnography of provisioning. This will also examine other issues, such as the nature of community and the implications for retail and for the wider political economy. None of this, however, forms part of the present essay, which is primarily concerned with establishing the cosmological foundations of shopping.

To state that a household has been included within the study is to gloss over a wide diversity of degrees of involvement. The minimum requirement is simply that a householder has agreed to be interviewed about their shopping, which would include the local shopping parade, shopping centres and supermarkets. At the other extreme are families that we have come to know well during the course of the year. Interaction would include formal interviews, and a less formal presence within their homes, usually with a cup of tea. It also meant accompanying them on one or several ‘events’, which might comprise shopping trips or participation in activities associated with the area of Clarke’s study, such as the meeting of a group supplying products for the home.

In analysing and writing up the experience of an ethnography of shopping in North London, I am led in two opposed directions. The tradition of anthropological relativism leads to an emphasis upon difference, and there are many ways in which shopping can help us elucidate differences. For example, there are differences in the experience of shopping based on gender, age, ethnicity and class. There are also differences based on the various genres of shopping experience, from a mall to a corner shop. By contrast, there is the tradition of anthropological generalisation about ‘peoples’ and comparative theory. This leads to the question as to whether there are any fundamental aspects of shopping which suggest a robust normativity that comes through the research and is not entirely dissipated by relativism. In this essay I want to emphasize the latter approach and argue that if not all, then most acts of shopping on this street exhibit a normative form which needs to be addressed. In the later discussion of the discourse of shopping I will defend the possibility that such a heterogenous group of households could be fairly represented by a series of homogenous cultural practices.

The theory that I will propose is certainly at odds with most of the literature on this topic. My premise, unlike that of most studies of consumption, whether they arise from economists, business studies or cultural studies, is that for most households in this street the act of shopping was hardly ever directed towards the person who was doing the shopping. Shopping is therefore not best understood as an individualistic or individualising act related to the subjectivity of the shopper. Rather, the act of buying goods is mainly directed at two forms of ‘otherness’. The first of these expresses a relationship between the shopper and a particular other individual such as a child or partner, either present in the household, desired or imagined. The second of these is a relationship to a more general goal which transcends any immediate utility and is best understood as cosmological in that it takes the form of neither subject nor object but of the values to which people wish to dedicate themselves.

It never occurred to me at any stage when carrying out the ethnography that I should consider the topic of sacrifice as relevant to this research. In no sense then could the ethnography be regarded as a testing of the ideas presented here. The Literature that seemed most relevant in the initial anaLysis of the London material was that on thrift discussed in chapter 3. The crucial element in opening up the potential of sacrifice for understanding shopping came through reading Bataiile. Bataille, however, was merely the catalyst, since I will argue that it is the classic works on sacrifice and, in particular, the foundation to its modern study by Hubert and Mauss (1964) that has become the primary grounds for my interpretation. It is important, however, when reading the following account to note that when I use the word ‘sacrifice’, I only rarely refer to the colLoquial sense of the term as used in the concept of the ‘self-sacrificial’ housewife. Mostly the allusion is to this Literature on ancient sacrifice and the detailed analysis of the complex ritual sequence involved in traditional sacrifice. The metaphorical use of the term may have its place within the subsequent discussion but this is secondary to an argument at the level of structure.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('46f5fcb3-86d8-5bbf-b67f-74c6c9a17ddb', '216f4c58-796a-5236-9b9f-ea7dcc590f8d', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 4-11
Questions 4-11
Do the following statements agree with the views of the writer in Reading Passage 3?
In boxes
4-11
on your answer sheet write
YES
if the statement agrees with the news of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Anthropological relativism is more widely applied than anthropological generalisation.
5
Shopping lends itself to analysis based on anthropological relativism.
6
Generalisations about shopping are possible.
7
Tire conclusions drawn from this study will confirm some of the findings of other research.
8
Shopping should be regarded as a basically unselfish activity.
9
People sometimes analyse their own motives when they are shopping.
10
The actual goods bought are the primary concern in the activity of shopping.
11
It was possible to predict the outcome of the study before embarking on it.

4 ____ Anthropological relativism is more widely applied than anthropological generalisation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc626a7d-fc40-55bf-aa7f-d066972ca2fe', '46f5fcb3-86d8-5bbf-b67f-74c6c9a17ddb', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3013cea4-365d-5bef-a2b0-84f3239f560c', '46f5fcb3-86d8-5bbf-b67f-74c6c9a17ddb', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a216e9f6-c7ea-5d04-8b2c-92eb117ab968', '46f5fcb3-86d8-5bbf-b67f-74c6c9a17ddb', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fa31d6b8-945a-5597-a7a4-867b50e89afe', '216f4c58-796a-5236-9b9f-ea7dcc590f8d', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 4-11
Questions 4-11
Do the following statements agree with the views of the writer in Reading Passage 3?
In boxes
4-11
on your answer sheet write
YES
if the statement agrees with the news of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Anthropological relativism is more widely applied than anthropological generalisation.
5
Shopping lends itself to analysis based on anthropological relativism.
6
Generalisations about shopping are possible.
7
Tire conclusions drawn from this study will confirm some of the findings of other research.
8
Shopping should be regarded as a basically unselfish activity.
9
People sometimes analyse their own motives when they are shopping.
10
The actual goods bought are the primary concern in the activity of shopping.
11
It was possible to predict the outcome of the study before embarking on it.

5 ____ Shopping lends itself to analysis based on anthropological relativism.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42531338-e2c9-5cbd-bf56-66a8967bbcd4', 'fa31d6b8-945a-5597-a7a4-867b50e89afe', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2eff7a1a-e0cf-5cd3-a8b6-1a2e034a6046', 'fa31d6b8-945a-5597-a7a4-867b50e89afe', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0760a856-5b28-5417-a4c0-e6a133b4009c', 'fa31d6b8-945a-5597-a7a4-867b50e89afe', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('23e18876-1926-55b3-8f1a-104a1c8c1bc4', '216f4c58-796a-5236-9b9f-ea7dcc590f8d', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 4-11
Questions 4-11
Do the following statements agree with the views of the writer in Reading Passage 3?
In boxes
4-11
on your answer sheet write
YES
if the statement agrees with the news of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Anthropological relativism is more widely applied than anthropological generalisation.
5
Shopping lends itself to analysis based on anthropological relativism.
6
Generalisations about shopping are possible.
7
Tire conclusions drawn from this study will confirm some of the findings of other research.
8
Shopping should be regarded as a basically unselfish activity.
9
People sometimes analyse their own motives when they are shopping.
10
The actual goods bought are the primary concern in the activity of shopping.
11
It was possible to predict the outcome of the study before embarking on it.

6 ____ Generalisations about shopping are possible.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e54baad-2b1e-52c8-a445-2bd0f9a3d903', '23e18876-1926-55b3-8f1a-104a1c8c1bc4', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca627e3f-2c98-5ea4-8571-665ebda1ea98', '23e18876-1926-55b3-8f1a-104a1c8c1bc4', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('075e84a9-bb19-5757-898d-e3d387eca17a', '23e18876-1926-55b3-8f1a-104a1c8c1bc4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a4cc68be-db23-58fb-8b8a-26a2ec7a8ce4', '216f4c58-796a-5236-9b9f-ea7dcc590f8d', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 4-11
Questions 4-11
Do the following statements agree with the views of the writer in Reading Passage 3?
In boxes
4-11
on your answer sheet write
YES
if the statement agrees with the news of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Anthropological relativism is more widely applied than anthropological generalisation.
5
Shopping lends itself to analysis based on anthropological relativism.
6
Generalisations about shopping are possible.
7
Tire conclusions drawn from this study will confirm some of the findings of other research.
8
Shopping should be regarded as a basically unselfish activity.
9
People sometimes analyse their own motives when they are shopping.
10
The actual goods bought are the primary concern in the activity of shopping.
11
It was possible to predict the outcome of the study before embarking on it.

7 ____ Tire conclusions drawn from this study will confirm some of the findings of other research.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d690bc11-cf1a-5b40-af8b-b0b975461c86', 'a4cc68be-db23-58fb-8b8a-26a2ec7a8ce4', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb2fb38e-8443-56bc-8a02-3d3ffcbf6fd5', 'a4cc68be-db23-58fb-8b8a-26a2ec7a8ce4', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1739346-75a0-5115-8fe3-5a6c5a08825f', 'a4cc68be-db23-58fb-8b8a-26a2ec7a8ce4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d4f28f5a-ef90-5bac-a885-bdd387ca9df6', '216f4c58-796a-5236-9b9f-ea7dcc590f8d', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 4-11
Questions 4-11
Do the following statements agree with the views of the writer in Reading Passage 3?
In boxes
4-11
on your answer sheet write
YES
if the statement agrees with the news of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Anthropological relativism is more widely applied than anthropological generalisation.
5
Shopping lends itself to analysis based on anthropological relativism.
6
Generalisations about shopping are possible.
7
Tire conclusions drawn from this study will confirm some of the findings of other research.
8
Shopping should be regarded as a basically unselfish activity.
9
People sometimes analyse their own motives when they are shopping.
10
The actual goods bought are the primary concern in the activity of shopping.
11
It was possible to predict the outcome of the study before embarking on it.

8 ____ Shopping should be regarded as a basically unselfish activity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5007d88b-be14-5060-b21b-b7147d29c622', 'd4f28f5a-ef90-5bac-a885-bdd387ca9df6', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd357386-fa78-5ab4-831b-a550ca89e282', 'd4f28f5a-ef90-5bac-a885-bdd387ca9df6', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('843bf476-9936-5730-9971-89291b4e9882', 'd4f28f5a-ef90-5bac-a885-bdd387ca9df6', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('56435575-0c1f-57b7-a10a-ebf6874ec1ad', '216f4c58-796a-5236-9b9f-ea7dcc590f8d', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 4-11
Questions 4-11
Do the following statements agree with the views of the writer in Reading Passage 3?
In boxes
4-11
on your answer sheet write
YES
if the statement agrees with the news of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Anthropological relativism is more widely applied than anthropological generalisation.
5
Shopping lends itself to analysis based on anthropological relativism.
6
Generalisations about shopping are possible.
7
Tire conclusions drawn from this study will confirm some of the findings of other research.
8
Shopping should be regarded as a basically unselfish activity.
9
People sometimes analyse their own motives when they are shopping.
10
The actual goods bought are the primary concern in the activity of shopping.
11
It was possible to predict the outcome of the study before embarking on it.

9 ____ People sometimes analyse their own motives when they are shopping.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e117ca6a-a24a-5869-a168-fac00087e5e7', '56435575-0c1f-57b7-a10a-ebf6874ec1ad', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90f1bff7-20f5-5ad6-9d71-95ac08768955', '56435575-0c1f-57b7-a10a-ebf6874ec1ad', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d5c1132-4e26-5c8f-8032-65b3c26a00c3', '56435575-0c1f-57b7-a10a-ebf6874ec1ad', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aac532c4-ee36-52fd-ba71-35e8661ffdb7', '216f4c58-796a-5236-9b9f-ea7dcc590f8d', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 4-11
Questions 4-11
Do the following statements agree with the views of the writer in Reading Passage 3?
In boxes
4-11
on your answer sheet write
YES
if the statement agrees with the news of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Anthropological relativism is more widely applied than anthropological generalisation.
5
Shopping lends itself to analysis based on anthropological relativism.
6
Generalisations about shopping are possible.
7
Tire conclusions drawn from this study will confirm some of the findings of other research.
8
Shopping should be regarded as a basically unselfish activity.
9
People sometimes analyse their own motives when they are shopping.
10
The actual goods bought are the primary concern in the activity of shopping.
11
It was possible to predict the outcome of the study before embarking on it.

10 ____ The actual goods bought are the primary concern in the activity of shopping.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3072b529-47fa-5416-9749-ac7a20301483', 'aac532c4-ee36-52fd-ba71-35e8661ffdb7', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cae8aca6-76a0-5821-9abe-23bf87ce60f4', 'aac532c4-ee36-52fd-ba71-35e8661ffdb7', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('512696c5-7b5c-55dc-a188-7902c10ac515', 'aac532c4-ee36-52fd-ba71-35e8661ffdb7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6136b42a-a72c-5a93-8ad8-4a89c4f395c6', '216f4c58-796a-5236-9b9f-ea7dcc590f8d', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 4-11
Questions 4-11
Do the following statements agree with the views of the writer in Reading Passage 3?
In boxes
4-11
on your answer sheet write
YES
if the statement agrees with the news of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Anthropological relativism is more widely applied than anthropological generalisation.
5
Shopping lends itself to analysis based on anthropological relativism.
6
Generalisations about shopping are possible.
7
Tire conclusions drawn from this study will confirm some of the findings of other research.
8
Shopping should be regarded as a basically unselfish activity.
9
People sometimes analyse their own motives when they are shopping.
10
The actual goods bought are the primary concern in the activity of shopping.
11
It was possible to predict the outcome of the study before embarking on it.

11 ____ It was possible to predict the outcome of the study before embarking on it.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a68b353-8af6-5608-85a6-f4f233457b84', '6136b42a-a72c-5a93-8ad8-4a89c4f395c6', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98fb44ea-364d-500b-9e95-3ee0ed9301ab', '6136b42a-a72c-5a93-8ad8-4a89c4f395c6', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51532136-b5e0-54a1-bc1d-fb22c495809b', '6136b42a-a72c-5a93-8ad8-4a89c4f395c6', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0421c8be-e265-539c-b217-7d902e5fac2b', '216f4c58-796a-5236-9b9f-ea7dcc590f8d', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 12-14
Questions 12-14
Complete the sentences below with words taken from Reading Passage 3.
Use
NO MORE THAN THREE WORDS
for each answer.
Write your answer in boxes
12-13
on your answer sheet.
12
The subject of written research the writer first thought was directly connected with his study was
13
The research the writer has been most inspired by was carried out by
14
The writer mostly does not use the meaning of ‘sacrifice’ that he regards as

12 The subject of written research the writer first thought was directly connected with his study was ____$md$, NULL, ARRAY['.*thrift.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1b512c1c-46be-533b-987f-2de643800685', '216f4c58-796a-5236-9b9f-ea7dcc590f8d', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 12-14
Questions 12-14
Complete the sentences below with words taken from Reading Passage 3.
Use
NO MORE THAN THREE WORDS
for each answer.
Write your answer in boxes
12-13
on your answer sheet.
12
The subject of written research the writer first thought was directly connected with his study was
13
The research the writer has been most inspired by was carried out by
14
The writer mostly does not use the meaning of ‘sacrifice’ that he regards as

13 The research the writer has been most inspired by was carried out by ____$md$, NULL, ARRAY['.*hubert.*and.*mauss.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4c4b86ce-d3a3-599c-b482-2c403180bb5c', '216f4c58-796a-5236-9b9f-ea7dcc590f8d', 14, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 14

Questions 12-14
Questions 12-14
Complete the sentences below with words taken from Reading Passage 3.
Use
NO MORE THAN THREE WORDS
for each answer.
Write your answer in boxes
12-13
on your answer sheet.
12
The subject of written research the writer first thought was directly connected with his study was
13
The research the writer has been most inspired by was carried out by
14
The writer mostly does not use the meaning of ‘sacrifice’ that he regards as

14 The writer mostly does not use the meaning of ‘sacrifice’ that he regards as ____$md$, NULL, ARRAY['.*colloquial.*','.*metaphorical.*']);

COMMIT;
