BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-risks-agriculture-faces-in-developing-countries-1139'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-risks-agriculture-faces-in-developing-countries-1139';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-risks-agriculture-faces-in-developing-countries-1139';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-risks-agriculture-faces-in-developing-countries-1139';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d963a0bc-3369-566e-97ab-32a8036036b8', 'ielts-reading-the-risks-agriculture-faces-in-developing-countries-1139', $t$The risks agriculture faces in developing countries$t$, $md$## The risks agriculture faces in developing countries

Nguồn:
- Test: https://mini-ielts.com/1139/reading/the-risks-agriculture-faces-in-developing-countries
- Solution: https://mini-ielts.com/1139/view-solution/reading/the-risks-agriculture-faces-in-developing-countries$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f4b2140d-5ecc-5d49-a960-d4f7be46c944', 'd963a0bc-3369-566e-97ab-32a8036036b8', 1, $t$Reading — The risks agriculture faces in developing countries$t$, $md$Read the passage and answer questions **1–9**.

### Passage: The risks agriculture faces in developing countries

Synthesis of an online debate

----------------------------------------------------

Great thanks to volunteer Ngoc Nguyen has contributed these explanations and question markings.

If you want to make a better world like this, please contact us$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('86d4655c-b689-5188-bcf7-92a1c79d0404', 'f4b2140d-5ecc-5d49-a960-d4f7be46c944', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-3
Questions 1-3
Reading Passage has nine paragraphs,
A-l.
Which paragraph contains the following information?
Write the correct letter,
A-l
, in boxes
1-3
on your answer sheet.
1
a reference to characteristics that only apply to food production
Locate
2
a reference to challenges faced only by farmers in certain parts of the world
Locate
3
a reference to difficulties in bringing about co-operation between farmers
Locate

1 ____ a reference to characteristics that only apply to food production Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed794ee8-74e5-5f0a-9339-602a831ed72e', '86d4655c-b689-5188-bcf7-92a1c79d0404', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89255f50-cb1f-5ee5-8b34-dbbf67733802', '86d4655c-b689-5188-bcf7-92a1c79d0404', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b75083bc-7775-5b33-bbe0-25a93e8f5830', '86d4655c-b689-5188-bcf7-92a1c79d0404', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6174285d-6f4f-51f7-b54d-9e24538a40b5', '86d4655c-b689-5188-bcf7-92a1c79d0404', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('754020bd-9e36-53d1-9075-ee84caddc900', '86d4655c-b689-5188-bcf7-92a1c79d0404', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f633e05-684e-5904-86e8-6da3b09b509e', '86d4655c-b689-5188-bcf7-92a1c79d0404', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0146a545-c32d-53a8-b70f-67513e2bc5a3', '86d4655c-b689-5188-bcf7-92a1c79d0404', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff856fd6-f864-56ea-916b-eff5c4cf529e', '86d4655c-b689-5188-bcf7-92a1c79d0404', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5688b794-120d-5e1a-9fc5-e2a1d4457918', '86d4655c-b689-5188-bcf7-92a1c79d0404', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('308d5a2e-58aa-5ff4-b7db-7cf02a2fd51b', 'f4b2140d-5ecc-5d49-a960-d4f7be46c944', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-3
Questions 1-3
Reading Passage has nine paragraphs,
A-l.
Which paragraph contains the following information?
Write the correct letter,
A-l
, in boxes
1-3
on your answer sheet.
1
a reference to characteristics that only apply to food production
Locate
2
a reference to challenges faced only by farmers in certain parts of the world
Locate
3
a reference to difficulties in bringing about co-operation between farmers
Locate

2 ____ a reference to challenges faced only by farmers in certain parts of the world Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1aad44e5-5cdc-5527-83dd-c04bae581ffc', '308d5a2e-58aa-5ff4-b7db-7cf02a2fd51b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d64a2a73-bb0f-5f3e-82f5-9210958802a0', '308d5a2e-58aa-5ff4-b7db-7cf02a2fd51b', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c27d724-15e0-5b78-b1f6-a13d9c21383c', '308d5a2e-58aa-5ff4-b7db-7cf02a2fd51b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('925c70f4-a533-5458-aa09-7a859db0b933', '308d5a2e-58aa-5ff4-b7db-7cf02a2fd51b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37eb28f1-7fff-5a38-91ce-29c3f7644640', '308d5a2e-58aa-5ff4-b7db-7cf02a2fd51b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8dca851-dc70-5625-9717-4323a9da1d36', '308d5a2e-58aa-5ff4-b7db-7cf02a2fd51b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f8f1b06-60dd-50c2-b20d-7cbff1b40474', '308d5a2e-58aa-5ff4-b7db-7cf02a2fd51b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09608bf8-99c0-59e5-85b6-30cbb1a141b8', '308d5a2e-58aa-5ff4-b7db-7cf02a2fd51b', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53ab6dc2-407c-5ed6-a079-703b81287c35', '308d5a2e-58aa-5ff4-b7db-7cf02a2fd51b', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('02c524fb-bcde-57ad-b39a-9d28d18da41a', 'f4b2140d-5ecc-5d49-a960-d4f7be46c944', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-3
Questions 1-3
Reading Passage has nine paragraphs,
A-l.
Which paragraph contains the following information?
Write the correct letter,
A-l
, in boxes
1-3
on your answer sheet.
1
a reference to characteristics that only apply to food production
Locate
2
a reference to challenges faced only by farmers in certain parts of the world
Locate
3
a reference to difficulties in bringing about co-operation between farmers
Locate

3 ____ a reference to difficulties in bringing about co-operation between farmers Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2758f7d8-1bde-5a2c-ab50-90257854b7f1', '02c524fb-bcde-57ad-b39a-9d28d18da41a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de72c9bc-3b80-589e-b440-e833bd4dfb70', '02c524fb-bcde-57ad-b39a-9d28d18da41a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('762c584f-d35f-5cde-8f73-12a2e5bb9dd4', '02c524fb-bcde-57ad-b39a-9d28d18da41a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4d24037-881b-52f8-bc80-a1e8c33a27fa', '02c524fb-bcde-57ad-b39a-9d28d18da41a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6fc9edc1-768f-5676-be85-0e52d956e76d', '02c524fb-bcde-57ad-b39a-9d28d18da41a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97410400-b24f-50a7-a160-afefeddc656b', '02c524fb-bcde-57ad-b39a-9d28d18da41a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87e24714-fec4-58b0-9bfd-5f1aa3e2be3a', '02c524fb-bcde-57ad-b39a-9d28d18da41a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83433671-a6e0-5f8e-913b-dc3adc7d97a3', '02c524fb-bcde-57ad-b39a-9d28d18da41a', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3264eed3-e07a-5c9d-a494-ed56b5caaf8f', '02c524fb-bcde-57ad-b39a-9d28d18da41a', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('85a31ff0-99b6-5658-aa67-14e7b5bbbf7d', 'f4b2140d-5ecc-5d49-a960-d4f7be46c944', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 4-9
Questions 4-9
Look at the following statements (Questions
4-9
) and the list of people below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
4-9
on your answer sheet.
NB
You may use any letter
more than once
.
4
Financial assistance from the government does not always go to the farmers who most need it.
Locate
5
Farmers can benefit from collaborating as a group.
Locate
6
Financial assistance from the government can improve the standard of living of farmers.
Locate
7
Farmers may be helped if there is financial input by the same individuals who buy
Locate
8
Governments can help to reduce variation in pages.
Locate
9
Improvements to infrastructure can have a major impact on risk for farmers.
Locate
from them
List of People
A
Kanayo F. Nwanze
B
Sophia Murphy
C
Shenggen Fan
D
Rokeya Kabir
E
Pat Mooney
F
Giel Ton
G
Sonali Bisht

4 ____ Financial assistance from the government does not always go to the farmers who most need it. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6c2d7c5-021b-54bf-a537-223bd361df09', '85a31ff0-99b6-5658-aa67-14e7b5bbbf7d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20c957e1-3bab-54c3-99b6-44fff46e22b2', '85a31ff0-99b6-5658-aa67-14e7b5bbbf7d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('327b7a98-6dc8-5421-8f28-4c178a0560be', '85a31ff0-99b6-5658-aa67-14e7b5bbbf7d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a433978a-916e-5673-8360-a8adfbd3152e', '85a31ff0-99b6-5658-aa67-14e7b5bbbf7d', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e25b957-ecc3-50e2-9e81-63c9d64d804e', '85a31ff0-99b6-5658-aa67-14e7b5bbbf7d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9884a23c-e234-5ce5-aa98-363e1cc9cd30', '85a31ff0-99b6-5658-aa67-14e7b5bbbf7d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('580e44a5-c77d-57ea-be43-19d7fc95af8c', '85a31ff0-99b6-5658-aa67-14e7b5bbbf7d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('17122dc3-3fbe-5829-b6c1-a7e5daa42f7a', 'f4b2140d-5ecc-5d49-a960-d4f7be46c944', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 4-9
Questions 4-9
Look at the following statements (Questions
4-9
) and the list of people below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
4-9
on your answer sheet.
NB
You may use any letter
more than once
.
4
Financial assistance from the government does not always go to the farmers who most need it.
Locate
5
Farmers can benefit from collaborating as a group.
Locate
6
Financial assistance from the government can improve the standard of living of farmers.
Locate
7
Farmers may be helped if there is financial input by the same individuals who buy
Locate
8
Governments can help to reduce variation in pages.
Locate
9
Improvements to infrastructure can have a major impact on risk for farmers.
Locate
from them
List of People
A
Kanayo F. Nwanze
B
Sophia Murphy
C
Shenggen Fan
D
Rokeya Kabir
E
Pat Mooney
F
Giel Ton
G
Sonali Bisht

5 ____ Farmers can benefit from collaborating as a group. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63aafa89-f408-5c2a-87b6-f04d6a53f019', '17122dc3-3fbe-5829-b6c1-a7e5daa42f7a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('724e85a5-8bb5-5dd5-beb9-6a93eff73725', '17122dc3-3fbe-5829-b6c1-a7e5daa42f7a', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9db9ae61-54ee-5123-b0d6-33c2e01b38f5', '17122dc3-3fbe-5829-b6c1-a7e5daa42f7a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efafe22d-53d4-55aa-a647-cd9826058b45', '17122dc3-3fbe-5829-b6c1-a7e5daa42f7a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e52ad6a-3f49-515d-b316-ba6b352fe5b0', '17122dc3-3fbe-5829-b6c1-a7e5daa42f7a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c8e6f8c-5951-5e03-8056-01c2eda3dd5e', '17122dc3-3fbe-5829-b6c1-a7e5daa42f7a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcca04c7-9566-535a-813f-b23a1c4d6be3', '17122dc3-3fbe-5829-b6c1-a7e5daa42f7a', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('727cfb0b-b748-537d-8d69-9794593568c7', 'f4b2140d-5ecc-5d49-a960-d4f7be46c944', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 4-9
Questions 4-9
Look at the following statements (Questions
4-9
) and the list of people below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
4-9
on your answer sheet.
NB
You may use any letter
more than once
.
4
Financial assistance from the government does not always go to the farmers who most need it.
Locate
5
Farmers can benefit from collaborating as a group.
Locate
6
Financial assistance from the government can improve the standard of living of farmers.
Locate
7
Farmers may be helped if there is financial input by the same individuals who buy
Locate
8
Governments can help to reduce variation in pages.
Locate
9
Improvements to infrastructure can have a major impact on risk for farmers.
Locate
from them
List of People
A
Kanayo F. Nwanze
B
Sophia Murphy
C
Shenggen Fan
D
Rokeya Kabir
E
Pat Mooney
F
Giel Ton
G
Sonali Bisht

6 ____ Financial assistance from the government can improve the standard of living of farmers. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('478021bb-7e2d-5489-929c-e92eee57fdf1', '727cfb0b-b748-537d-8d69-9794593568c7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81ff9c1c-e0de-5024-9dce-995f383a9398', '727cfb0b-b748-537d-8d69-9794593568c7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9b0415e-bd3c-5db8-887c-8a1042e64ec6', '727cfb0b-b748-537d-8d69-9794593568c7', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ac6a94b-ce87-5e6f-8cf7-a93811acf894', '727cfb0b-b748-537d-8d69-9794593568c7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bcc43c0-a2f4-5012-8dc3-9afe515d23b1', '727cfb0b-b748-537d-8d69-9794593568c7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28393e5e-6919-545b-8d52-b1f01fa7673f', '727cfb0b-b748-537d-8d69-9794593568c7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6726c2b6-a91e-51fb-a650-ffdbec1445af', '727cfb0b-b748-537d-8d69-9794593568c7', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('caeee8a4-66d8-5f44-beb6-c6e5acdf5382', 'f4b2140d-5ecc-5d49-a960-d4f7be46c944', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 4-9
Questions 4-9
Look at the following statements (Questions
4-9
) and the list of people below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
4-9
on your answer sheet.
NB
You may use any letter
more than once
.
4
Financial assistance from the government does not always go to the farmers who most need it.
Locate
5
Farmers can benefit from collaborating as a group.
Locate
6
Financial assistance from the government can improve the standard of living of farmers.
Locate
7
Farmers may be helped if there is financial input by the same individuals who buy
Locate
8
Governments can help to reduce variation in pages.
Locate
9
Improvements to infrastructure can have a major impact on risk for farmers.
Locate
from them
List of People
A
Kanayo F. Nwanze
B
Sophia Murphy
C
Shenggen Fan
D
Rokeya Kabir
E
Pat Mooney
F
Giel Ton
G
Sonali Bisht

7 ____ Farmers may be helped if there is financial input by the same individuals who buy Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15258312-5da8-526b-9b72-9b0367775ded', 'caeee8a4-66d8-5f44-beb6-c6e5acdf5382', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9890fee-38b9-5174-a928-a068f85733e9', 'caeee8a4-66d8-5f44-beb6-c6e5acdf5382', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77e0c2ec-f0e2-5a76-a50f-827bcfd0b087', 'caeee8a4-66d8-5f44-beb6-c6e5acdf5382', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d86acb7e-d74c-5c94-aa72-cf7b72f9914b', 'caeee8a4-66d8-5f44-beb6-c6e5acdf5382', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d70ad34-f3a1-5f98-9219-73795e1894db', 'caeee8a4-66d8-5f44-beb6-c6e5acdf5382', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e6dcb1e-1974-5a0b-8918-2dba60f522d3', 'caeee8a4-66d8-5f44-beb6-c6e5acdf5382', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b42f7a96-de21-5248-b067-6adb397d62eb', 'caeee8a4-66d8-5f44-beb6-c6e5acdf5382', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eca5845d-f778-53fd-ab26-9eb521e0816d', 'f4b2140d-5ecc-5d49-a960-d4f7be46c944', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 4-9
Questions 4-9
Look at the following statements (Questions
4-9
) and the list of people below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
4-9
on your answer sheet.
NB
You may use any letter
more than once
.
4
Financial assistance from the government does not always go to the farmers who most need it.
Locate
5
Farmers can benefit from collaborating as a group.
Locate
6
Financial assistance from the government can improve the standard of living of farmers.
Locate
7
Farmers may be helped if there is financial input by the same individuals who buy
Locate
8
Governments can help to reduce variation in pages.
Locate
9
Improvements to infrastructure can have a major impact on risk for farmers.
Locate
from them
List of People
A
Kanayo F. Nwanze
B
Sophia Murphy
C
Shenggen Fan
D
Rokeya Kabir
E
Pat Mooney
F
Giel Ton
G
Sonali Bisht

8 ____ Governments can help to reduce variation in pages. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7d8e802-55b1-5670-b0b4-4232243f0fea', 'eca5845d-f778-53fd-ab26-9eb521e0816d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e09f54b8-7031-51f4-b7ac-eb0c01feb95f', 'eca5845d-f778-53fd-ab26-9eb521e0816d', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c02b3a5-7287-51a0-8604-38cd7a4d4c1e', 'eca5845d-f778-53fd-ab26-9eb521e0816d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81c617df-6bed-5f7c-84ca-4e5212dc2fa1', 'eca5845d-f778-53fd-ab26-9eb521e0816d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1a0b659-45e9-577a-bcd5-3a68109af632', 'eca5845d-f778-53fd-ab26-9eb521e0816d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68b5f3a2-3621-5021-9bfc-3271c46135b9', 'eca5845d-f778-53fd-ab26-9eb521e0816d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b406baad-37d7-5e1b-9089-b9d5796e11d0', 'eca5845d-f778-53fd-ab26-9eb521e0816d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6fd0374f-a974-53a3-aa17-b768286bacd1', 'f4b2140d-5ecc-5d49-a960-d4f7be46c944', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 4-9
Questions 4-9
Look at the following statements (Questions
4-9
) and the list of people below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
4-9
on your answer sheet.
NB
You may use any letter
more than once
.
4
Financial assistance from the government does not always go to the farmers who most need it.
Locate
5
Farmers can benefit from collaborating as a group.
Locate
6
Financial assistance from the government can improve the standard of living of farmers.
Locate
7
Farmers may be helped if there is financial input by the same individuals who buy
Locate
8
Governments can help to reduce variation in pages.
Locate
9
Improvements to infrastructure can have a major impact on risk for farmers.
Locate
from them
List of People
A
Kanayo F. Nwanze
B
Sophia Murphy
C
Shenggen Fan
D
Rokeya Kabir
E
Pat Mooney
F
Giel Ton
G
Sonali Bisht

9 ____ Improvements to infrastructure can have a major impact on risk for farmers. Locate from them$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40acf56e-eaa7-5d9f-9ea8-0daf57fad180', '6fd0374f-a974-53a3-aa17-b768286bacd1', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f96e6c73-8eee-50a9-9232-17891ae52f1c', '6fd0374f-a974-53a3-aa17-b768286bacd1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5aad3dfa-4909-55a5-b654-db4d3e13b8c8', '6fd0374f-a974-53a3-aa17-b768286bacd1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b469b41-3585-510c-aed1-9890da47f0fb', '6fd0374f-a974-53a3-aa17-b768286bacd1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c220aaf3-dcf8-572b-9b8e-c036a0101d67', '6fd0374f-a974-53a3-aa17-b768286bacd1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('288444a9-0567-5abe-92ef-6d437c9c1607', '6fd0374f-a974-53a3-aa17-b768286bacd1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74b61212-9410-5380-adea-8012194529c5', '6fd0374f-a974-53a3-aa17-b768286bacd1', 7, $md$G$md$, false);

COMMIT;
