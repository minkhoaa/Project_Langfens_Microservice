BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-warning-mondays-are-bad-for-your-heart-1422'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-warning-mondays-are-bad-for-your-heart-1422';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-warning-mondays-are-bad-for-your-heart-1422';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-warning-mondays-are-bad-for-your-heart-1422';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('5d3dacbb-92b6-5811-bc64-11f90d59eac8', 'ielts-reading-warning-mondays-are-bad-for-your-heart-1422', $t$Warning: Mondays are bad for your heart$t$, $md$## Warning: Mondays are bad for your heart

Nguồn:
- Test: https://mini-ielts.com/1422/reading/warning-mondays-are-bad-for-your-heart
- Solution: https://mini-ielts.com/1422/view-solution/reading/warning-mondays-are-bad-for-your-heart$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('725c973e-f31b-5fab-b03f-fda0a8af921a', '5d3dacbb-92b6-5811-bc64-11f90d59eac8', 1, $t$Reading — Warning: Mondays are bad for your heart$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Warning: Mondays are bad for your heart

A. That ‘Monday morning feeling’ could be a crushing pain in the chest which leaves you sweating and gasping for breath. Recent research from Germany and Italy shows that heart attacks are more common on Monday morning and doctors blame the stress of returning to work after the weekend break. B. The risk of having a heart attack on any given day should be one in seven, but a six-year study coordinated by researchers at the Free University of Berlin of more than 2,600 Germans revealed that the average person had a 20 per cent higher chance of having a heart attack on a Monday than on any other day. C. Working Germans are particularly vulnerable, with a 33 per cent higher risk at the beginning of the working week. Non-workers, by comparison, appear to be no more at risk on a Monday than any other day.

D. A study of 11,000 Italians identified 8 am on a Monday morning as the most stressful time for the heart, and both studies showed that Sunday is the least stressful day, with fewer heart attacks in both countries. E. The findings could lead to a better understanding of what triggers heart attacks, according to Dr. Stefan Willich of the Free University. ‘We know a lot about long-term risk factors such as smoking and cholesterol， but we don’t know what actually triggers heart attacks, so we can’t make specific recommendations about how to prevent them,’ he said. F. Monday mornings have a double helping of stress for the working body as it makes a rapid transition from sleep to activity, and from the relaxing weekend to the pressures of work. ‘When people get up, their blood pressure and heart rate go up and there are hormonal changes in their bodies,’ Willich explained. ‘All these things can have an adverse effect in the blood system and increase the risk of a clot in the arteries which will cause a heart attack.’ ‘When people return to work after a weekend off, the pace of their life changes. They have a higher workload, more stress, more anger and more physical activity,’ said Willich. ‘We need to know how these events cause changes in the body before we can understand if they cause heart attacks.’ G. But although it is tempting to believe that returning to work increases the risk of a heart attack, both Willich and the Italian researchers admit that it is only a partial answer. Both studies showed that the over-65s are also vulnerable on a Monday morning even though most no longer work. The reason for this is not clear, but the Italian team at the Luigi Saddo Hospital in Milan speculate that social interactions—the thought of facing another week and all its pressures—may play a part. H. What is clear, however, is that the Monday morning peak seems to be consistent from northern Germany to southern Italy in spite of the differences in diet and lifestyle. I. Willich is reluctant at this stage to make specific recommendations, but he suggests that anyone who suffers from heart disease should take it easy on Monday mornings and leave potentially stressful meetings until midweek. ‘People should try to create a pleasant working environment,’ he added. ‘Maybe this risk applies only to those who see work as a burden, and people who enjoy their work are not so much at risk. We need to find out more.’$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7e9ef221-d389-57ac-a5ec-038494cfc359', '725c973e-f31b-5fab-b03f-fda0a8af921a', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Read the following statements 1-4. According to the reading passage,
If the statement is true, write
True
.
If the statement is false, write
False
.
If there is insufficient evidence, write
NOT GIVEN
.
Write your answers in the spaces numbered
1-4
on the answer sheet. An example is shown below.
Example: It was once believed that there was an equal chance of suffering a heart attack on any day of the week.
Answer: True.
1
Unemployed Germans have a higher risk of heart attack than employed Germans.
2
Unemployed Italians have a lower risk of heart attack than unemployed Germans.
3
Germans risk heart attack because of their high consumption of fatty food.
4
Cholesterol and smoking cause heart attacks.

Answer: True. 1 ____ Unemployed Germans have a higher risk of heart attack than employed Germans. 2 ____ Unemployed Italians have a lower risk of heart attack than unemployed Germans. 3 ____ Germans risk heart attack because of their high consumption of fatty food. 4 ____ Cholesterol and smoking cause heart attacks.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2659d141-2228-53d4-9e04-7cbf764d8f70', '7e9ef221-d389-57ac-a5ec-038494cfc359', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd0581c6-4aac-5bff-b4e7-25ff2272d547', '7e9ef221-d389-57ac-a5ec-038494cfc359', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a44538e-e404-5f38-8563-cc9a0efd1c7b', '7e9ef221-d389-57ac-a5ec-038494cfc359', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9c180859-8e88-5f4f-b0e6-52b89d0abf99', '725c973e-f31b-5fab-b03f-fda0a8af921a', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Read the following statements 1-4. According to the reading passage,
If the statement is true, write
True
.
If the statement is false, write
False
.
If there is insufficient evidence, write
NOT GIVEN
.
Write your answers in the spaces numbered
1-4
on the answer sheet. An example is shown below.
Example: It was once believed that there was an equal chance of suffering a heart attack on any day of the week.
Answer: True.
1
Unemployed Germans have a higher risk of heart attack than employed Germans.
2
Unemployed Italians have a lower risk of heart attack than unemployed Germans.
3
Germans risk heart attack because of their high consumption of fatty food.
4
Cholesterol and smoking cause heart attacks.

Answer: True. 1 ____ Unemployed Germans have a higher risk of heart attack than employed Germans. 2 ____ Unemployed Italians have a lower risk of heart attack than unemployed Germans. 3 ____ Germans risk heart attack because of their high consumption of fatty food. 4 ____ Cholesterol and smoking cause heart attacks.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e34b3c7-7eb4-5ce9-99d2-d50ced696591', '9c180859-8e88-5f4f-b0e6-52b89d0abf99', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48086a9c-1d18-5f68-a224-afb3b0dd9554', '9c180859-8e88-5f4f-b0e6-52b89d0abf99', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ee3bf3d-3890-5a8e-9e2b-2a203011b451', '9c180859-8e88-5f4f-b0e6-52b89d0abf99', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3bf17a27-5841-550f-900c-3a211938e9df', '725c973e-f31b-5fab-b03f-fda0a8af921a', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Read the following statements 1-4. According to the reading passage,
If the statement is true, write
True
.
If the statement is false, write
False
.
If there is insufficient evidence, write
NOT GIVEN
.
Write your answers in the spaces numbered
1-4
on the answer sheet. An example is shown below.
Example: It was once believed that there was an equal chance of suffering a heart attack on any day of the week.
Answer: True.
1
Unemployed Germans have a higher risk of heart attack than employed Germans.
2
Unemployed Italians have a lower risk of heart attack than unemployed Germans.
3
Germans risk heart attack because of their high consumption of fatty food.
4
Cholesterol and smoking cause heart attacks.

Answer: True. 1 ____ Unemployed Germans have a higher risk of heart attack than employed Germans. 2 ____ Unemployed Italians have a lower risk of heart attack than unemployed Germans. 3 ____ Germans risk heart attack because of their high consumption of fatty food. 4 ____ Cholesterol and smoking cause heart attacks.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('386198cc-d92d-5111-a369-c70c1f3226b9', '3bf17a27-5841-550f-900c-3a211938e9df', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe82c18a-3a48-56ab-bb80-83b10fa427a9', '3bf17a27-5841-550f-900c-3a211938e9df', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ecba97e8-5bc9-59c3-8931-c9d27ba21e95', '3bf17a27-5841-550f-900c-3a211938e9df', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('82df3bb7-3a41-5e5b-8f45-cb3df3b5cbd7', '725c973e-f31b-5fab-b03f-fda0a8af921a', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Read the following statements 1-4. According to the reading passage,
If the statement is true, write
True
.
If the statement is false, write
False
.
If there is insufficient evidence, write
NOT GIVEN
.
Write your answers in the spaces numbered
1-4
on the answer sheet. An example is shown below.
Example: It was once believed that there was an equal chance of suffering a heart attack on any day of the week.
Answer: True.
1
Unemployed Germans have a higher risk of heart attack than employed Germans.
2
Unemployed Italians have a lower risk of heart attack than unemployed Germans.
3
Germans risk heart attack because of their high consumption of fatty food.
4
Cholesterol and smoking cause heart attacks.

Answer: True. 1 ____ Unemployed Germans have a higher risk of heart attack than employed Germans. 2 ____ Unemployed Italians have a lower risk of heart attack than unemployed Germans. 3 ____ Germans risk heart attack because of their high consumption of fatty food. 4 ____ Cholesterol and smoking cause heart attacks.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4303c6f-9680-53ba-9552-2f760b2a5761', '82df3bb7-3a41-5e5b-8f45-cb3df3b5cbd7', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d10940d-ae80-5fb2-b3e7-daa48a8cb855', '82df3bb7-3a41-5e5b-8f45-cb3df3b5cbd7', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbfd61b4-2e62-56c5-9464-7d4296b6f11f', '82df3bb7-3a41-5e5b-8f45-cb3df3b5cbd7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bc79bdc2-d357-5eb9-a0b7-f29d801eb3e8', '725c973e-f31b-5fab-b03f-fda0a8af921a', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 6-13
Questions 6-13
Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading
ONCE
only.
5
Heading for Paragraph A
6
Heading for Paragraph B
7
Heading for Paragraph C
8
Heading for Paragraph D
9
Heading for Paragraph E
10
Heading for Paragraph F
11
Heading for Paragraph G
12
Heading for Paragraph H
13
Heading for Paragraph I
List of headings
i
Exact cause of heart attacks
ii
The safest day
iii
Breathless, sweaty and crushed
iv
Reducing heart attack hazard
v
High-risk Monday
vi
Mondays: riskier than food and way of life
vii
Jobless but safer
viii
Elderly also at risk
ix
Bodily adaptations

Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading ONCE only. 5 ____ Heading for Paragraph A 6 ____ Heading for Paragraph B 7 ____ Heading for Paragraph C 8 ____ Heading for Paragraph D 9 ____ Heading for Paragraph E 10 ____ Heading for Paragraph F 11 ____ Heading for Paragraph G 12 ____ Heading for Paragraph H 13 ____ Heading for Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6a5d111-06ce-59bd-a66c-7dfdfd56a1df', 'bc79bdc2-d357-5eb9-a0b7-f29d801eb3e8', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('017af7f4-70f9-5330-a1ae-7c42d6c30d85', 'bc79bdc2-d357-5eb9-a0b7-f29d801eb3e8', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('229ee101-d8c4-5f07-a21f-eda6d8dd585c', 'bc79bdc2-d357-5eb9-a0b7-f29d801eb3e8', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7e6d1ee-6a42-5711-a75c-3f5560642a22', 'bc79bdc2-d357-5eb9-a0b7-f29d801eb3e8', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf732252-dfbd-5c4d-be13-3d7a3e21de8b', 'bc79bdc2-d357-5eb9-a0b7-f29d801eb3e8', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0429002-d0d7-5348-96d6-bd0a773efb92', 'bc79bdc2-d357-5eb9-a0b7-f29d801eb3e8', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb801838-0347-56d5-8265-96caa42917fa', 'bc79bdc2-d357-5eb9-a0b7-f29d801eb3e8', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('069f03c0-bdae-5844-be70-111e0375aec9', 'bc79bdc2-d357-5eb9-a0b7-f29d801eb3e8', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6164774f-cfa1-5fcc-adbb-0a1f99ff5706', 'bc79bdc2-d357-5eb9-a0b7-f29d801eb3e8', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('47a410e9-aba8-5543-a414-5a6f7fd6211e', '725c973e-f31b-5fab-b03f-fda0a8af921a', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-13
Questions 6-13
Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading
ONCE
only.
5
Heading for Paragraph A
6
Heading for Paragraph B
7
Heading for Paragraph C
8
Heading for Paragraph D
9
Heading for Paragraph E
10
Heading for Paragraph F
11
Heading for Paragraph G
12
Heading for Paragraph H
13
Heading for Paragraph I
List of headings
i
Exact cause of heart attacks
ii
The safest day
iii
Breathless, sweaty and crushed
iv
Reducing heart attack hazard
v
High-risk Monday
vi
Mondays: riskier than food and way of life
vii
Jobless but safer
viii
Elderly also at risk
ix
Bodily adaptations

Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading ONCE only. 5 ____ Heading for Paragraph A 6 ____ Heading for Paragraph B 7 ____ Heading for Paragraph C 8 ____ Heading for Paragraph D 9 ____ Heading for Paragraph E 10 ____ Heading for Paragraph F 11 ____ Heading for Paragraph G 12 ____ Heading for Paragraph H 13 ____ Heading for Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d872c19-ac50-53a0-82b3-de4c8fec3ddd', '47a410e9-aba8-5543-a414-5a6f7fd6211e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0b3adc6-f0be-5185-8900-c15b48132806', '47a410e9-aba8-5543-a414-5a6f7fd6211e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eab3dac4-bdc4-54dc-9e5c-e32c69104449', '47a410e9-aba8-5543-a414-5a6f7fd6211e', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('569640ae-72e6-5ac8-aa5d-5c3276695cbb', '47a410e9-aba8-5543-a414-5a6f7fd6211e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a387748a-0061-5814-9315-dc9d7ea340fa', '47a410e9-aba8-5543-a414-5a6f7fd6211e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11621adc-9728-5bb5-a9e6-f382c8ff93a3', '47a410e9-aba8-5543-a414-5a6f7fd6211e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a336d5c1-966f-5e21-8a79-f03efefb093a', '47a410e9-aba8-5543-a414-5a6f7fd6211e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b060e23-a28e-5127-af6a-61da3ca0602e', '47a410e9-aba8-5543-a414-5a6f7fd6211e', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85055d3d-45ea-506a-a837-884804361ca6', '47a410e9-aba8-5543-a414-5a6f7fd6211e', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e312f1a9-bbc1-5e2e-9ab6-7ddb00a3d3d3', '725c973e-f31b-5fab-b03f-fda0a8af921a', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-13
Questions 6-13
Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading
ONCE
only.
5
Heading for Paragraph A
6
Heading for Paragraph B
7
Heading for Paragraph C
8
Heading for Paragraph D
9
Heading for Paragraph E
10
Heading for Paragraph F
11
Heading for Paragraph G
12
Heading for Paragraph H
13
Heading for Paragraph I
List of headings
i
Exact cause of heart attacks
ii
The safest day
iii
Breathless, sweaty and crushed
iv
Reducing heart attack hazard
v
High-risk Monday
vi
Mondays: riskier than food and way of life
vii
Jobless but safer
viii
Elderly also at risk
ix
Bodily adaptations

Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading ONCE only. 5 ____ Heading for Paragraph A 6 ____ Heading for Paragraph B 7 ____ Heading for Paragraph C 8 ____ Heading for Paragraph D 9 ____ Heading for Paragraph E 10 ____ Heading for Paragraph F 11 ____ Heading for Paragraph G 12 ____ Heading for Paragraph H 13 ____ Heading for Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ddac39e-c373-5c91-8527-0ea8db39afe2', 'e312f1a9-bbc1-5e2e-9ab6-7ddb00a3d3d3', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf7ee59e-8c2e-55a5-a298-36fcddfad0df', 'e312f1a9-bbc1-5e2e-9ab6-7ddb00a3d3d3', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12b789e3-2e09-5b46-bdd2-52317645fd07', 'e312f1a9-bbc1-5e2e-9ab6-7ddb00a3d3d3', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e292698-662b-5b50-8275-e8aaf8edc6f3', 'e312f1a9-bbc1-5e2e-9ab6-7ddb00a3d3d3', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0e8cd13-bf9f-5e92-b748-85e34fc4c6c3', 'e312f1a9-bbc1-5e2e-9ab6-7ddb00a3d3d3', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2afbb02e-cdd8-5951-9ce0-a5d6e410f8d2', 'e312f1a9-bbc1-5e2e-9ab6-7ddb00a3d3d3', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e50b4f1-5bc1-5300-8266-292d70149fd7', 'e312f1a9-bbc1-5e2e-9ab6-7ddb00a3d3d3', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('702a9aec-d297-5195-aeda-e6e6c79f6f82', 'e312f1a9-bbc1-5e2e-9ab6-7ddb00a3d3d3', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afb67e64-8ad2-5aa9-ab33-7fb716d0146f', 'e312f1a9-bbc1-5e2e-9ab6-7ddb00a3d3d3', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2117cc1e-e283-5b38-b0d1-039602d20f4b', '725c973e-f31b-5fab-b03f-fda0a8af921a', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-13
Questions 6-13
Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading
ONCE
only.
5
Heading for Paragraph A
6
Heading for Paragraph B
7
Heading for Paragraph C
8
Heading for Paragraph D
9
Heading for Paragraph E
10
Heading for Paragraph F
11
Heading for Paragraph G
12
Heading for Paragraph H
13
Heading for Paragraph I
List of headings
i
Exact cause of heart attacks
ii
The safest day
iii
Breathless, sweaty and crushed
iv
Reducing heart attack hazard
v
High-risk Monday
vi
Mondays: riskier than food and way of life
vii
Jobless but safer
viii
Elderly also at risk
ix
Bodily adaptations

Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading ONCE only. 5 ____ Heading for Paragraph A 6 ____ Heading for Paragraph B 7 ____ Heading for Paragraph C 8 ____ Heading for Paragraph D 9 ____ Heading for Paragraph E 10 ____ Heading for Paragraph F 11 ____ Heading for Paragraph G 12 ____ Heading for Paragraph H 13 ____ Heading for Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d44ba9b-4046-5ed6-93f8-20515cb5d63b', '2117cc1e-e283-5b38-b0d1-039602d20f4b', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('318d299f-844b-59c7-bed9-8cdee47ee663', '2117cc1e-e283-5b38-b0d1-039602d20f4b', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c0437ed-2599-5224-8042-521757cd7bdc', '2117cc1e-e283-5b38-b0d1-039602d20f4b', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e95180d-ee3d-5cb1-84fa-12c32d9eb414', '2117cc1e-e283-5b38-b0d1-039602d20f4b', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fc07345-4ed1-5c0f-a9d3-bcca83c23804', '2117cc1e-e283-5b38-b0d1-039602d20f4b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44cec0f1-3677-5127-9ba9-1828c8dd92a9', '2117cc1e-e283-5b38-b0d1-039602d20f4b', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2ea0c66-9176-555a-ab4d-0502ccbeee5f', '2117cc1e-e283-5b38-b0d1-039602d20f4b', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3af4b0e-4aac-5d37-b466-2a26f40fec66', '2117cc1e-e283-5b38-b0d1-039602d20f4b', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0f6d36a-3ddf-5773-a1d9-02b21f983ac5', '2117cc1e-e283-5b38-b0d1-039602d20f4b', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('84d6ad2b-2160-5390-a471-5910b6d61301', '725c973e-f31b-5fab-b03f-fda0a8af921a', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-13
Questions 6-13
Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading
ONCE
only.
5
Heading for Paragraph A
6
Heading for Paragraph B
7
Heading for Paragraph C
8
Heading for Paragraph D
9
Heading for Paragraph E
10
Heading for Paragraph F
11
Heading for Paragraph G
12
Heading for Paragraph H
13
Heading for Paragraph I
List of headings
i
Exact cause of heart attacks
ii
The safest day
iii
Breathless, sweaty and crushed
iv
Reducing heart attack hazard
v
High-risk Monday
vi
Mondays: riskier than food and way of life
vii
Jobless but safer
viii
Elderly also at risk
ix
Bodily adaptations

Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading ONCE only. 5 ____ Heading for Paragraph A 6 ____ Heading for Paragraph B 7 ____ Heading for Paragraph C 8 ____ Heading for Paragraph D 9 ____ Heading for Paragraph E 10 ____ Heading for Paragraph F 11 ____ Heading for Paragraph G 12 ____ Heading for Paragraph H 13 ____ Heading for Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fde18e11-bb6d-5cd9-891d-2ebbeaab10a2', '84d6ad2b-2160-5390-a471-5910b6d61301', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95a8f6e3-3cfe-562d-80c0-eafbc3c40468', '84d6ad2b-2160-5390-a471-5910b6d61301', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd274b6f-9721-59e7-9473-8de121142638', '84d6ad2b-2160-5390-a471-5910b6d61301', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56fbd67f-accc-5e27-bbe9-ac537e5d1a9b', '84d6ad2b-2160-5390-a471-5910b6d61301', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e7115ba-8dc7-5d04-9767-827063026b6d', '84d6ad2b-2160-5390-a471-5910b6d61301', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c78a3788-2fa7-55fe-a9ea-0efe14c7d022', '84d6ad2b-2160-5390-a471-5910b6d61301', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('452cfe19-082a-53af-9a91-6caa05350e02', '84d6ad2b-2160-5390-a471-5910b6d61301', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9590d04f-282a-5cb2-b47d-31cffe49c5d6', '84d6ad2b-2160-5390-a471-5910b6d61301', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4d90782-f9af-5bc8-8433-65458ef85fe9', '84d6ad2b-2160-5390-a471-5910b6d61301', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8852d37-8525-52a6-966f-dd203d68564b', '725c973e-f31b-5fab-b03f-fda0a8af921a', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-13
Questions 6-13
Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading
ONCE
only.
5
Heading for Paragraph A
6
Heading for Paragraph B
7
Heading for Paragraph C
8
Heading for Paragraph D
9
Heading for Paragraph E
10
Heading for Paragraph F
11
Heading for Paragraph G
12
Heading for Paragraph H
13
Heading for Paragraph I
List of headings
i
Exact cause of heart attacks
ii
The safest day
iii
Breathless, sweaty and crushed
iv
Reducing heart attack hazard
v
High-risk Monday
vi
Mondays: riskier than food and way of life
vii
Jobless but safer
viii
Elderly also at risk
ix
Bodily adaptations

Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading ONCE only. 5 ____ Heading for Paragraph A 6 ____ Heading for Paragraph B 7 ____ Heading for Paragraph C 8 ____ Heading for Paragraph D 9 ____ Heading for Paragraph E 10 ____ Heading for Paragraph F 11 ____ Heading for Paragraph G 12 ____ Heading for Paragraph H 13 ____ Heading for Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00b072b1-4caf-5299-9094-88e3c1a22c4e', 'd8852d37-8525-52a6-966f-dd203d68564b', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f2bfb16-0d94-52df-bd57-dbafb6ba5e61', 'd8852d37-8525-52a6-966f-dd203d68564b', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bad682f-3f39-5504-906d-b7a585fc7e6d', 'd8852d37-8525-52a6-966f-dd203d68564b', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcd7b1f8-bffd-5b31-85b5-965d7fa5f72b', 'd8852d37-8525-52a6-966f-dd203d68564b', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad1e59cf-04eb-53ba-b299-5238214b8c67', 'd8852d37-8525-52a6-966f-dd203d68564b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4520d009-32f1-5209-b195-6f09ea859431', 'd8852d37-8525-52a6-966f-dd203d68564b', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d48c595-e972-53b6-9b98-e194078614de', 'd8852d37-8525-52a6-966f-dd203d68564b', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71e02a9d-0c16-520d-ba2c-59f9f3f432a7', 'd8852d37-8525-52a6-966f-dd203d68564b', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dd9b09e-3230-59ff-8e4d-f8eb704dbd5b', 'd8852d37-8525-52a6-966f-dd203d68564b', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e054ffd7-dfe1-5450-9e1c-532286963960', '725c973e-f31b-5fab-b03f-fda0a8af921a', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 6-13
Questions 6-13
Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading
ONCE
only.
5
Heading for Paragraph A
6
Heading for Paragraph B
7
Heading for Paragraph C
8
Heading for Paragraph D
9
Heading for Paragraph E
10
Heading for Paragraph F
11
Heading for Paragraph G
12
Heading for Paragraph H
13
Heading for Paragraph I
List of headings
i
Exact cause of heart attacks
ii
The safest day
iii
Breathless, sweaty and crushed
iv
Reducing heart attack hazard
v
High-risk Monday
vi
Mondays: riskier than food and way of life
vii
Jobless but safer
viii
Elderly also at risk
ix
Bodily adaptations

Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading ONCE only. 5 ____ Heading for Paragraph A 6 ____ Heading for Paragraph B 7 ____ Heading for Paragraph C 8 ____ Heading for Paragraph D 9 ____ Heading for Paragraph E 10 ____ Heading for Paragraph F 11 ____ Heading for Paragraph G 12 ____ Heading for Paragraph H 13 ____ Heading for Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15ccd13b-ee5b-523b-9bf7-e1067338b881', 'e054ffd7-dfe1-5450-9e1c-532286963960', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58252c86-4f7b-5524-8707-ec0b86449a0c', 'e054ffd7-dfe1-5450-9e1c-532286963960', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2a4e000-fb18-509a-959c-1edba407ad66', 'e054ffd7-dfe1-5450-9e1c-532286963960', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0646918-befa-5d9d-9cd7-b23384290322', 'e054ffd7-dfe1-5450-9e1c-532286963960', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a730865e-c3ec-5591-a305-f535c85910c2', 'e054ffd7-dfe1-5450-9e1c-532286963960', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2beb0886-78be-52d5-8cfc-6935688afd00', 'e054ffd7-dfe1-5450-9e1c-532286963960', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55ed3f37-914b-5fc9-8958-0ae0c416f9cd', 'e054ffd7-dfe1-5450-9e1c-532286963960', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04e3aa09-1017-500a-85c1-3e9d8b4759a0', 'e054ffd7-dfe1-5450-9e1c-532286963960', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffd7e62a-aa87-5bf3-9981-d023513fc66b', 'e054ffd7-dfe1-5450-9e1c-532286963960', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('93103404-de55-555f-82c3-1ae458fa5e17', '725c973e-f31b-5fab-b03f-fda0a8af921a', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 6-13
Questions 6-13
Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading
ONCE
only.
5
Heading for Paragraph A
6
Heading for Paragraph B
7
Heading for Paragraph C
8
Heading for Paragraph D
9
Heading for Paragraph E
10
Heading for Paragraph F
11
Heading for Paragraph G
12
Heading for Paragraph H
13
Heading for Paragraph I
List of headings
i
Exact cause of heart attacks
ii
The safest day
iii
Breathless, sweaty and crushed
iv
Reducing heart attack hazard
v
High-risk Monday
vi
Mondays: riskier than food and way of life
vii
Jobless but safer
viii
Elderly also at risk
ix
Bodily adaptations

Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading ONCE only. 5 ____ Heading for Paragraph A 6 ____ Heading for Paragraph B 7 ____ Heading for Paragraph C 8 ____ Heading for Paragraph D 9 ____ Heading for Paragraph E 10 ____ Heading for Paragraph F 11 ____ Heading for Paragraph G 12 ____ Heading for Paragraph H 13 ____ Heading for Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c82318f-1f34-55ff-9994-2baf09ccf81b', '93103404-de55-555f-82c3-1ae458fa5e17', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20420290-9e11-5057-9b30-44ed96dc7cee', '93103404-de55-555f-82c3-1ae458fa5e17', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3c4f3b3-cf21-58d9-9ec2-03128abf5009', '93103404-de55-555f-82c3-1ae458fa5e17', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d18e8add-acfa-5342-87db-1e9a981440b5', '93103404-de55-555f-82c3-1ae458fa5e17', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('282401c9-c0d9-55ba-9d84-bf35de95a74a', '93103404-de55-555f-82c3-1ae458fa5e17', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4af92261-1821-516f-a9ec-056754939c36', '93103404-de55-555f-82c3-1ae458fa5e17', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07506f95-d325-565c-a18b-48085ec98356', '93103404-de55-555f-82c3-1ae458fa5e17', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('743831aa-b9bf-5510-962a-a9ca743ae255', '93103404-de55-555f-82c3-1ae458fa5e17', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5df635bc-5d53-5d9e-b166-14d8394bc119', '93103404-de55-555f-82c3-1ae458fa5e17', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ad40ea99-4204-540c-b88d-aad39d060cc5', '725c973e-f31b-5fab-b03f-fda0a8af921a', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 6-13
Questions 6-13
Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading
ONCE
only.
5
Heading for Paragraph A
6
Heading for Paragraph B
7
Heading for Paragraph C
8
Heading for Paragraph D
9
Heading for Paragraph E
10
Heading for Paragraph F
11
Heading for Paragraph G
12
Heading for Paragraph H
13
Heading for Paragraph I
List of headings
i
Exact cause of heart attacks
ii
The safest day
iii
Breathless, sweaty and crushed
iv
Reducing heart attack hazard
v
High-risk Monday
vi
Mondays: riskier than food and way of life
vii
Jobless but safer
viii
Elderly also at risk
ix
Bodily adaptations

Read Reading Passage and from the list of headings below, select the best heading for each paragraph A-I. Write the appropriate number i-ix, in the spaces numbered 6-14 on the answer sheet. Use each heading ONCE only. 5 ____ Heading for Paragraph A 6 ____ Heading for Paragraph B 7 ____ Heading for Paragraph C 8 ____ Heading for Paragraph D 9 ____ Heading for Paragraph E 10 ____ Heading for Paragraph F 11 ____ Heading for Paragraph G 12 ____ Heading for Paragraph H 13 ____ Heading for Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('146638ed-6332-512c-8783-53e0a9683df4', 'ad40ea99-4204-540c-b88d-aad39d060cc5', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7637deec-d06a-5e89-9526-5e700ffb178e', 'ad40ea99-4204-540c-b88d-aad39d060cc5', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3ae47d7-28f4-5d30-896c-f7ad3b7bd8f0', 'ad40ea99-4204-540c-b88d-aad39d060cc5', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d66e6aff-dd1d-5e65-b4e6-993875e11b45', 'ad40ea99-4204-540c-b88d-aad39d060cc5', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8e97c7c-b30c-5d00-b20f-b97124518ea9', 'ad40ea99-4204-540c-b88d-aad39d060cc5', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c67b4c39-4472-53a1-ba82-8a42aaace5cc', 'ad40ea99-4204-540c-b88d-aad39d060cc5', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bf9c495-9803-5712-b955-c71f1369f2fc', 'ad40ea99-4204-540c-b88d-aad39d060cc5', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7455f01-a5e6-5dd7-8d05-34e53e2f7b3d', 'ad40ea99-4204-540c-b88d-aad39d060cc5', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f904b2c-19b0-5614-89bf-c3dcc8875859', 'ad40ea99-4204-540c-b88d-aad39d060cc5', 9, $md$ix$md$, false);

COMMIT;
