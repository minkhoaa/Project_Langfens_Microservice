BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-toxic-stress-a-slow-wear-and-tear-1525'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-toxic-stress-a-slow-wear-and-tear-1525';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-toxic-stress-a-slow-wear-and-tear-1525';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-toxic-stress-a-slow-wear-and-tear-1525';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('b547cdcb-5426-5c3a-b925-ca3155996d30', 'ielts-reading-toxic-stress-a-slow-wear-and-tear-1525', $t$﻿Toxic Stress: A Slow Wear And Tear$t$, $md$## ﻿Toxic Stress: A Slow Wear And Tear

Nguồn:
- Test: https://mini-ielts.com/1525/reading/toxic-stress-a-slow-wear-and-tear
- Solution: https://mini-ielts.com/1525/view-solution/reading/toxic-stress-a-slow-wear-and-tear$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 'b547cdcb-5426-5c3a-b925-ca3155996d30', 1, $t$Reading — ﻿Toxic Stress: A Slow Wear And Tear$t$, $md$Read the passage and answer questions **1–13**.

### Passage: ﻿Toxic Stress: A Slow Wear And Tear

| | ﻿Toxic Stress: A Slow Wear And Tear Our bodies are built to respond when under attack. When we sense danger, our brain goes on alert, our heart rate goes up, and our organs flood with stress hormones like cortisol and adrenaline. We breathe faster, taking in more oxygen, muscles tense, our senses are sharpened and beads of sweat appear. This combination of reactions to stress is also known as the "fight-or-flight" response because it evolved as a survival mechanism, enabling people and other mammals to react quickly to life-threatening situations. The carefully orchestrated yet near-instantaneous sequence of hormonal changes and physiological responses helps someone to fight the threat off or flee to safety. Unfortunately, the body can also overreact to stressors that are not life-threatening, such as traffic jams, work pressure, and family difficulties. That's all fine when we need to jump out of the way of a speeding bus, or when someone is following us down a dark alley. In those cases, our stress is considered "positive", because it is temporary and helps us survive. But our bodies sometimes react in the same way to more mundane stressors, too. When a child faces constant and unrelenting stress, from neglect, or abuse, or living in chaos, the response stays activated, and may eventually derail normal development. This is what is known as "toxic stress". The effects are not the same in every child, and can be buffered by the support of a parent or caregiver, in which case the stress is considered "tolerable". But toxic stress can have profound consequences, sometimes even spanning generations. Figuring out how to address stressors before they change the brain and our immune and cardiovascular systems is one of the biggest questions in the field of childhood development today. In 1998, two researchers, Vincent Felitti and Robert Anda, pioneered in publishing a study demonstrating that people who had experienced abuse or household dysfunction as children were more likely to have serious health problems, like cancer or liver diseases, and unhealthy lifestyle habits, like drinking heavily or using drugs as adults. This became known as the "ACE Study," short for "adverse childhood experiences." Scientists have since linked more than a dozen forms of ACEs - including homelessness, discrimination, and physical, mental, and sexual abuse - with a higher risk of poor health in adulthood. Every child reacts to stress differently, and some are naturally more resilient than others. Nevertheless, the pathways that link adversity in childhood with health problems in adulthood lead back to toxic stress. As Jenny Anderson, senior reporter at Quartz, explains, "when a child lives with abuse, neglect, or is witness to violence, he or she is primed for that fight or flight all the time. The burden of that stress, which is known as 'allostatic load or overload,' referring to the wear and tear that results from either too much stress or from inefficient management of internal balance, eg, not turning off the response when it is no longer needed, can damage small, developing brains and bodies. A brain that thinks it is in constant danger has trouble organising itself, which can manifest itself later as problems of paying attention, or sitting still, or following instructions - all of which are needed for learning". Toxic is a loaded word. Critics say the term is inherently judgmental and may appear to blame parents for external social circumstances over which they have little control. Others say it is often misused to describe the source of stress itself rather than the biological process by which it could negatively affect some children. The term, writes John Devaney, centenary chair of social work at the University of Edinburgh, "can stigmatise individuals and imply traumatic happenings in the past". Some paediatricians do not like the term because of how difficult it is to actually fix the stressors their patients face, from poverty to racism. They feel it is too fatalistic to tell families that their child is experiencing toxic stress, and there is little they can do about it. But Nadine Burke Harris, surgeon general of California, argues that naming the problem means we can dedicate resources to it so that paediatricians feel like they have tools to treat "toxic stress". The most effective prevention for toxic stress is to reduce the source of the stress. This can be tricky, especially if the source of the stress is the child's own family. But parent coaching, and connecting families with resources to help address the cause of their stress (sufficient food, housing insecurity, or even the parent's own trauma), can help. Another one is to ensure love and support from a parent or caregiver. Young children's stress responses are more stable, even in difficult situations, when they are with an adult they trust. As Megan Gunnar, a child psychologist and head of the Institute of Child at the University of Minnesota, said: "When the parent is present and relationship is secure, basically the parent eats the stress: the kid cries, the parent comes, and it doesn't need to kick in the big biological guns because the parent is the protective system". That is why Havard's Center on the Developing Child recommends offering care to caregivers, like mental health or addiction support, because when they are healthy and well, they can better care for their children.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('431c127b-3afb-5d6d-a1ea-f8021794aae4', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Question 1-6
Question 1-6
The reading passage has six paragraphs, A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number (i – vii) in boxes.
List of Headings
i The controversy around the word “toxic”
ii Effects of different types of stress
iii How to protect children from toxic stress
iv An association of adverse experience with health problems and unhealthy habits
v Body’s reactions in response to the perceived harmful event
vi Signs of being under sustained stress
vii Negative impacts of toxic stress on children’s mental health
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8c65d4b-f2bf-5977-86fa-11fa5c514d70', '431c127b-3afb-5d6d-a1ea-f8021794aae4', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a00dabf-3ade-5ff2-b4f1-993c1a2c1448', '431c127b-3afb-5d6d-a1ea-f8021794aae4', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e345902f-1a59-5710-ad25-1244abbf36dc', '431c127b-3afb-5d6d-a1ea-f8021794aae4', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a49a157-fa25-53cb-8941-1ec174ff4d9d', '431c127b-3afb-5d6d-a1ea-f8021794aae4', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('966ef74b-1f53-5b3e-b8dd-0baa5246e6fb', '431c127b-3afb-5d6d-a1ea-f8021794aae4', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e76e794c-508f-5ed9-8792-7c934422082e', '431c127b-3afb-5d6d-a1ea-f8021794aae4', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('605145ce-1aa8-5d96-a8e9-28824002532b', '431c127b-3afb-5d6d-a1ea-f8021794aae4', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0cbf8dff-2ccc-510e-9c73-7647092b6b04', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Question 1-6
Question 1-6
The reading passage has six paragraphs, A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number (i – vii) in boxes.
List of Headings
i The controversy around the word “toxic”
ii Effects of different types of stress
iii How to protect children from toxic stress
iv An association of adverse experience with health problems and unhealthy habits
v Body’s reactions in response to the perceived harmful event
vi Signs of being under sustained stress
vii Negative impacts of toxic stress on children’s mental health
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3188c3db-868c-5ddb-a39f-da84982549d0', '0cbf8dff-2ccc-510e-9c73-7647092b6b04', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93322eed-5200-567e-941b-a8d4c59af8fc', '0cbf8dff-2ccc-510e-9c73-7647092b6b04', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1066ce2e-17f7-54c5-99c6-dcc334486434', '0cbf8dff-2ccc-510e-9c73-7647092b6b04', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90813948-a4f7-5fb7-9c19-fb4ba8ac80f6', '0cbf8dff-2ccc-510e-9c73-7647092b6b04', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08ce5cbc-4a6a-5c91-9e5e-da2b8572abc3', '0cbf8dff-2ccc-510e-9c73-7647092b6b04', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0a023ca-aee2-57ee-b64c-0798da4df35d', '0cbf8dff-2ccc-510e-9c73-7647092b6b04', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fafbeaa2-53bd-59ef-9ff8-7ccdd90dfe1b', '0cbf8dff-2ccc-510e-9c73-7647092b6b04', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('36dcd027-effa-589d-b45b-ffbe92f3950a', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Question 1-6
Question 1-6
The reading passage has six paragraphs, A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number (i – vii) in boxes.
List of Headings
i The controversy around the word “toxic”
ii Effects of different types of stress
iii How to protect children from toxic stress
iv An association of adverse experience with health problems and unhealthy habits
v Body’s reactions in response to the perceived harmful event
vi Signs of being under sustained stress
vii Negative impacts of toxic stress on children’s mental health
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c76422a0-e3c5-517d-ab7a-aabb264e86e8', '36dcd027-effa-589d-b45b-ffbe92f3950a', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b316f52-fe8d-5f67-a84d-1c79159c46ff', '36dcd027-effa-589d-b45b-ffbe92f3950a', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c0b20b1-8884-5975-a9bc-96de6ecbbf83', '36dcd027-effa-589d-b45b-ffbe92f3950a', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce5f7509-7d63-5c92-96b7-c8ed2a8c0626', '36dcd027-effa-589d-b45b-ffbe92f3950a', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85518cd4-1823-5975-847f-447224d2238a', '36dcd027-effa-589d-b45b-ffbe92f3950a', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0356164a-d8a1-59ec-b1a7-acdb4fe0f15a', '36dcd027-effa-589d-b45b-ffbe92f3950a', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b933c44-4047-5de8-9c28-a47d1db586ed', '36dcd027-effa-589d-b45b-ffbe92f3950a', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2f2c6133-de6b-5ae4-9f7a-8ddc79950522', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Question 1-6
Question 1-6
The reading passage has six paragraphs, A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number (i – vii) in boxes.
List of Headings
i The controversy around the word “toxic”
ii Effects of different types of stress
iii How to protect children from toxic stress
iv An association of adverse experience with health problems and unhealthy habits
v Body’s reactions in response to the perceived harmful event
vi Signs of being under sustained stress
vii Negative impacts of toxic stress on children’s mental health
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c0b399e-b133-565e-b714-6185ad68a6cc', '2f2c6133-de6b-5ae4-9f7a-8ddc79950522', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c71582bf-9de0-535e-a250-6eef65d1c986', '2f2c6133-de6b-5ae4-9f7a-8ddc79950522', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fbee87b-6ffb-5591-b19c-452df8a3fd83', '2f2c6133-de6b-5ae4-9f7a-8ddc79950522', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0430e073-32f8-51ec-a41a-706ba4890d8a', '2f2c6133-de6b-5ae4-9f7a-8ddc79950522', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f87231f7-f902-550b-a5f0-cf70c982303a', '2f2c6133-de6b-5ae4-9f7a-8ddc79950522', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff974d27-f9e9-562d-a0fd-ba0ae5242e2f', '2f2c6133-de6b-5ae4-9f7a-8ddc79950522', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7f9e018-e83f-53c6-b534-c3fc8e960ab4', '2f2c6133-de6b-5ae4-9f7a-8ddc79950522', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('08d5a97b-554a-5be7-81d2-f54c5a6e8c9e', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Question 1-6
Question 1-6
The reading passage has six paragraphs, A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number (i – vii) in boxes.
List of Headings
i The controversy around the word “toxic”
ii Effects of different types of stress
iii How to protect children from toxic stress
iv An association of adverse experience with health problems and unhealthy habits
v Body’s reactions in response to the perceived harmful event
vi Signs of being under sustained stress
vii Negative impacts of toxic stress on children’s mental health
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea011e15-ba11-594f-baf9-7f4371b6650f', '08d5a97b-554a-5be7-81d2-f54c5a6e8c9e', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dccc56e7-8178-5678-8191-fe362ec30211', '08d5a97b-554a-5be7-81d2-f54c5a6e8c9e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ba22010-f9ba-5b5d-a141-cd515a6d8738', '08d5a97b-554a-5be7-81d2-f54c5a6e8c9e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf4ed67d-54e6-5c48-bf85-dc9612080fdb', '08d5a97b-554a-5be7-81d2-f54c5a6e8c9e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f45f2fe-b374-5b5a-b059-47cee914a7ca', '08d5a97b-554a-5be7-81d2-f54c5a6e8c9e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ada4f3a-b316-57eb-825d-a39d9d5fc9f1', '08d5a97b-554a-5be7-81d2-f54c5a6e8c9e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('958e658b-237a-583a-b7ff-4da65c00a85d', '08d5a97b-554a-5be7-81d2-f54c5a6e8c9e', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d44f244a-748f-5409-aba4-62dce58d19b5', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Question 1-6
Question 1-6
The reading passage has six paragraphs, A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number (i – vii) in boxes.
List of Headings
i The controversy around the word “toxic”
ii Effects of different types of stress
iii How to protect children from toxic stress
iv An association of adverse experience with health problems and unhealthy habits
v Body’s reactions in response to the perceived harmful event
vi Signs of being under sustained stress
vii Negative impacts of toxic stress on children’s mental health
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01723a94-5686-51fb-a177-e96b10314c0e', 'd44f244a-748f-5409-aba4-62dce58d19b5', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2dcf879-c2a1-5fed-8b88-7f7194917a11', 'd44f244a-748f-5409-aba4-62dce58d19b5', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d9409c0-cb18-5547-9ef0-0b5e2dde0dd2', 'd44f244a-748f-5409-aba4-62dce58d19b5', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7635d26-7dcd-56ec-88b7-d61e05341ab2', 'd44f244a-748f-5409-aba4-62dce58d19b5', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62150ba5-a77b-58c1-b069-291d8b87a690', 'd44f244a-748f-5409-aba4-62dce58d19b5', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9311a37e-7cbe-5bf8-b300-a574b26ea2cc', 'd44f244a-748f-5409-aba4-62dce58d19b5', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5826a6de-13f1-5e40-a3af-09be0dec14fe', 'd44f244a-748f-5409-aba4-62dce58d19b5', 7, $md$vii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1321b717-2112-5e67-a389-e2cbc2d6bb24', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Question 7-9
Question 7-9
Choose TRUE if the statement agrees with the information given in the text, choose FALSE if the statement contradicts the information, or choose NOT GIVEN if there is no information on this.
7
Felitti and Anda were the first to show that ACEs create impacts regarding health and habits later on in life.
8
Some children have the same level of vulnerability to stressful events.
9
Several paediatricians consider poverty and racism the primary contributors to toxic stress.

7 ____ Felitti and Anda were the first to show that ACEs create impacts regarding health and habits later on in life.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d258b29f-40d5-5756-a4e4-30de120bcab3', '1321b717-2112-5e67-a389-e2cbc2d6bb24', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('665a5f78-7df1-5d7c-aa57-a9a41a00b6c0', '1321b717-2112-5e67-a389-e2cbc2d6bb24', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2964b06-5f30-5581-81cb-ef149d2a5f87', '1321b717-2112-5e67-a389-e2cbc2d6bb24', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('843d8959-d6ed-57e5-b6b8-d81afc6886bd', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Question 7-9
Question 7-9
Choose TRUE if the statement agrees with the information given in the text, choose FALSE if the statement contradicts the information, or choose NOT GIVEN if there is no information on this.
7
Felitti and Anda were the first to show that ACEs create impacts regarding health and habits later on in life.
8
Some children have the same level of vulnerability to stressful events.
9
Several paediatricians consider poverty and racism the primary contributors to toxic stress.

8 ____ Some children have the same level of vulnerability to stressful events.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('618477ee-50a7-503c-8c96-f2fc5337244e', '843d8959-d6ed-57e5-b6b8-d81afc6886bd', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0d44a1c-7156-56a3-b5a8-c64c675e6f64', '843d8959-d6ed-57e5-b6b8-d81afc6886bd', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08671236-0107-5a2f-955a-a42e6c24f787', '843d8959-d6ed-57e5-b6b8-d81afc6886bd', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f79c44c8-b1a3-54f4-8fe8-ead5ff83dc31', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Question 7-9
Question 7-9
Choose TRUE if the statement agrees with the information given in the text, choose FALSE if the statement contradicts the information, or choose NOT GIVEN if there is no information on this.
7
Felitti and Anda were the first to show that ACEs create impacts regarding health and habits later on in life.
8
Some children have the same level of vulnerability to stressful events.
9
Several paediatricians consider poverty and racism the primary contributors to toxic stress.

9 ____ Several paediatricians consider poverty and racism the primary contributors to toxic stress.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc812318-23a9-5b7d-8b82-229f56abc1b6', 'f79c44c8-b1a3-54f4-8fe8-ead5ff83dc31', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dda4036d-d4de-5a94-9dc2-dc1bab976ea8', 'f79c44c8-b1a3-54f4-8fe8-ead5ff83dc31', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fde10e6-4abc-5146-bdf0-65035e76773b', 'f79c44c8-b1a3-54f4-8fe8-ead5ff83dc31', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6640eab7-8226-54b8-b49c-4704f0c58829', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Question 10-13
Question 10-13
Look at the following people and the list of statements below.
Match each person with the correct statement, A-E.
Write the correct letter A-E in boxes.
List of statements
A Traumatic experiences in childhood might lead to poor self-management.
B Supportive and responsive relationships with caring parents can prevent or reverse the damaging effects of toxic stress responses.
C Properly naming a type of stress can facilitate its treatment process.
D The real name of a particular form of stress could denounce a number of people.
E Toxic stress can cause the next generations to suffer from negative consequences on both mental and physical health problems.
10
Megan Gunnar
11
Jenny Anderson
12
John Devaney
13
Nadine Burke Harris

10 ____ Megan Gunnar$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60576230-c483-515a-a6ab-6307c34bb435', '6640eab7-8226-54b8-b49c-4704f0c58829', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd70ab2b-3b70-5247-adca-ad60498f824b', '6640eab7-8226-54b8-b49c-4704f0c58829', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef618280-be13-5476-8486-1b83c8306449', '6640eab7-8226-54b8-b49c-4704f0c58829', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa82097f-3ca0-56f1-a695-bee08303e4cc', '6640eab7-8226-54b8-b49c-4704f0c58829', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('732f49d9-3d88-5ef8-a0ff-6e2f217b4b9f', '6640eab7-8226-54b8-b49c-4704f0c58829', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2330f387-5070-516f-8f69-a873d31fb757', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Question 10-13
Question 10-13
Look at the following people and the list of statements below.
Match each person with the correct statement, A-E.
Write the correct letter A-E in boxes.
List of statements
A Traumatic experiences in childhood might lead to poor self-management.
B Supportive and responsive relationships with caring parents can prevent or reverse the damaging effects of toxic stress responses.
C Properly naming a type of stress can facilitate its treatment process.
D The real name of a particular form of stress could denounce a number of people.
E Toxic stress can cause the next generations to suffer from negative consequences on both mental and physical health problems.
10
Megan Gunnar
11
Jenny Anderson
12
John Devaney
13
Nadine Burke Harris

11 ____ Jenny Anderson$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ef27cb7-028c-50fa-b456-5e5b8ae09322', '2330f387-5070-516f-8f69-a873d31fb757', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6d26d3a-ec62-53f5-8430-a8a9d18de99c', '2330f387-5070-516f-8f69-a873d31fb757', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4202a5cb-0cfa-552d-aa1a-2a5e2999b3de', '2330f387-5070-516f-8f69-a873d31fb757', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e49f228d-6671-554f-af86-029984872dde', '2330f387-5070-516f-8f69-a873d31fb757', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3de6636b-d720-536d-b343-d06e50aa0d18', '2330f387-5070-516f-8f69-a873d31fb757', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('57b45734-a299-5dd9-982d-0d37550b23a5', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Question 10-13
Question 10-13
Look at the following people and the list of statements below.
Match each person with the correct statement, A-E.
Write the correct letter A-E in boxes.
List of statements
A Traumatic experiences in childhood might lead to poor self-management.
B Supportive and responsive relationships with caring parents can prevent or reverse the damaging effects of toxic stress responses.
C Properly naming a type of stress can facilitate its treatment process.
D The real name of a particular form of stress could denounce a number of people.
E Toxic stress can cause the next generations to suffer from negative consequences on both mental and physical health problems.
10
Megan Gunnar
11
Jenny Anderson
12
John Devaney
13
Nadine Burke Harris

12 ____ John Devaney$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75868360-67a2-54d2-bc8f-7d563998c56b', '57b45734-a299-5dd9-982d-0d37550b23a5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35291f47-cb85-5c57-8b6b-3e3b6d03387c', '57b45734-a299-5dd9-982d-0d37550b23a5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7b753ac-45ef-5939-8710-6ac5cd122aac', '57b45734-a299-5dd9-982d-0d37550b23a5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fae42900-4a82-5a6e-a891-113c85592407', '57b45734-a299-5dd9-982d-0d37550b23a5', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e836f96e-5f3a-5e50-8001-7f2084684e4c', '57b45734-a299-5dd9-982d-0d37550b23a5', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0fc01b84-6d52-54d8-92c2-f199cd62011d', 'eeafb5c2-e4df-5d93-99e0-0b6b8dafd593', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Question 10-13
Question 10-13
Look at the following people and the list of statements below.
Match each person with the correct statement, A-E.
Write the correct letter A-E in boxes.
List of statements
A Traumatic experiences in childhood might lead to poor self-management.
B Supportive and responsive relationships with caring parents can prevent or reverse the damaging effects of toxic stress responses.
C Properly naming a type of stress can facilitate its treatment process.
D The real name of a particular form of stress could denounce a number of people.
E Toxic stress can cause the next generations to suffer from negative consequences on both mental and physical health problems.
10
Megan Gunnar
11
Jenny Anderson
12
John Devaney
13
Nadine Burke Harris

13 ____ Nadine Burke Harris$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('436d8663-0979-5051-b91b-3bdebbfde4c9', '0fc01b84-6d52-54d8-92c2-f199cd62011d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22f982b5-3a34-5bee-952e-80b7ac39f8d4', '0fc01b84-6d52-54d8-92c2-f199cd62011d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d850f896-d40c-541a-9f6d-df0d519f7a00', '0fc01b84-6d52-54d8-92c2-f199cd62011d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af272d88-09ea-576a-804b-a9691fca1372', '0fc01b84-6d52-54d8-92c2-f199cd62011d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af68d171-6bf9-58ce-9024-534bd25cf986', '0fc01b84-6d52-54d8-92c2-f199cd62011d', 5, $md$E$md$, false);

COMMIT;
