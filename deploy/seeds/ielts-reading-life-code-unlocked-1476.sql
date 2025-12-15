BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-life-code-unlocked-1476'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-life-code-unlocked-1476';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-life-code-unlocked-1476';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-life-code-unlocked-1476';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('6d3f8cd1-c638-56f9-adeb-208e12c6243c', 'ielts-reading-life-code-unlocked-1476', $t$Life code: unlocked!$t$, $md$## Life code: unlocked!

Nguồn:
- Test: https://mini-ielts.com/1476/reading/life-code-unlocked
- Solution: https://mini-ielts.com/1476/view-solution/reading/life-code-unlocked$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('87872d86-11ec-5c8c-b9b2-6eb05dd972a1', '6d3f8cd1-c638-56f9-adeb-208e12c6243c', 1, $t$Reading — Life code: unlocked!$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Life code: unlocked!

{A} On an airport shuttle bus to the Kavli Institute for Theoretical Physics in Santa Barbara, Calif., Chris Wiggins took a colleague’s advice and opened a Microsoft Excel spreadsheet. It had nothing to do with the talk on biopolymer physics he was invited to give. Rather the columns and rows of numbers that stared back at him referred to the genetic activity of budding yeast. Specifically, the numbers represented the amount of messenger RNA (MRNA) expressed by all 6,200 genes of the yeast over the course of its reproductive cycle. “It was the first time I ever saw anything like this,” Wiggins recalls of that spring day in 2002. “How to make sense of all this data?”

{B} Instead of shirking from this question, the 36-year-old applied mathematician and physicist at Columbia University embraced it-and now six years later he thinks he has an answer. By foraying into fields outside his own, Wiggins has drudged up tools from a branch of artificial intelligence called machine learning to model the collective protein-making activity of genes from real-world biological data. Engineers originally designed these tools in the late 1950s to predict output from input. Wiggins and his colleagues have now brought machine learning to the natural sciences and tweaked it so that it can also tell a story-one not only about input and output but also about what happens inside a model of gene regulation, the black box in between.

{C} The impetus for this work began in the late 1990s, when high-throughput techniques generated more mRNA expression profiles and DNA sequences than ever before, “opening up a completely different way of thinking about biological phenomena,” Wiggins says. Key among these techniques were DNA microarrays, chips that provide a panoramic view of the activity of genes and their expression levels in any cell type, simultaneously and under myriad conditions. As noisy and incomplete as the data were, biologists could now query which genes turn on or off in different cells and determine the collection of proteins that give rise to a cell’s characteristic features, healthy or diseased.

{D} Yet predicting such gene activity requires uncovering the fundamental rules that govern it. “Over time, these rules have been locked in by cells,” says theoretical physicist Harmen Bussemaker, now an associate professor of biology at Columbia. “Evolution has kept the good stuff.” To find these rules, scientists needed statistics to infer the interaction between genes and the proteins that regulate them and to then mathematically describe this network’s underlying structure-the dynamic pattern of gene and protein activity over time. But physicists who did not work with particles (or planets, for that matter) viewed statistics as nothing short of an anathema. “If your experiment requires statistics,” British physicist Ernest Rutherford once said, “you ought to have done a better experiment.”

{E} But in working with microarrays, “the experiment has been done without you,” Wiggins explains. “And biology doesn’t hand you a model to make sense of the data.” Even more challenging, the building blocks that makeup DNA, RNA, and proteins are assembled in myriad ways; moreover, subtly different rules of interaction govern their activity, making it difficult, if not impossible, to reduce their patterns of interaction to fundamental laws. Some genes and proteins are not even known. “You are trying to find something compelling about the natural world in a context where you don’t know very much,” says William Bialek, a biophysicist at Princeton University. “You’re forced to be agnostic.” Wiggins believes that many machine-learning algorithms perform well under precisely these conditions. When working with so many unknown variables, “machine learning lets the data decide what’s worth looking at,” he says.

{F} At the Kavli Institute, Wiggins began building a model of a gene regulatory network in a yeast-the set of rules by which genes selectively orchestrate how vigorously DNA is transcribed into mRNA. As he worked with different algorithms, he started to attend discussions on gene regulation led by Christina Leslie, who ran the computational biology group at Columbia at the time. Leslie suggested using a specific machine-learning tool called a classifier. Say the algorithm must discriminate between pictures that have bicycles in them and pictures that do not. A classifier sifts through labeled examples and measures everything it can about them, gradually learning the decision rules that govern the grouping. From these rules, the algorithm generates a model that can determine whether or not new pictures have bikes in them. In gene regulatory networks, the learning task becomes the problem of predicting whether genes increase or decrease their protein-making activity.

{G} The algorithm that Wiggins and Leslie began building in the fall of 2002 was trained on the DNA sequences and mRNA levels of regulators expressed during a range of conditions in yeast-when the yeast was cold, hot, starved, and so on. Specifically, this algorithm-MEDUSA (for motif element discrimination using sequence agglomeration) -scans every possible pairing between a set of DNA promoter sequences, called motifs, and regulators. Then, much like a child might match a list of words with their definitions by drawing a line between the two, MEDUSA finds the pairing that best improves the fit between the model and the data it tries to emulate. (Wiggins refers to these pairings as edges.) Each time MEDUSA finds a pairing, it updates the model by adding a new rule to guide its search for the next pairing. It then determines the strength of each pairing by how well the rule improves the existing model. The hierarchy of numbers enables Wiggins and his colleagues to determine which pairings are more important than others and how they can collectively influence the activity of each of the yeast’s 6,200 genes. By adding one pairing at a time, MEDUSA can predict which genes ratchet up their RNA production or clamp that production down, as well as reveal the collective mechanisms that orchestrate an organism’s transcriptional logic.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5c4c6506-9d5d-52ec-90de-0d34ac302856', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A-G from the list below.
Write the correct number, i-x, in boxes 1-6 on your answer sheet.
List of Headings
(I)
The search for the better-fit matching between the model and the gained figures to foresee the activities of the genes
(II)
The definition of MEDUSA
(III)
A flashback of commencement for a far-reaching breakthrough
(IV)
A drawing of the gene map
(V)
An algorithm used to construct a specific model to discern the appearance of something new by the joint effort of Wiggins and another scientist
(VI)
An introduction of a background tracing back to the availability of mature techniques for detailed research on genes
(VII)
A way out to face the challenge confronting the scientist on the deciding of researchable data.
(VIII)
A failure to find out some specific genes controlling the production of certain proteins
(IX)
The use of a means from another domain for reference
(X)
A tough hurdle on the way to find the law governing the activities of the genes
Example: Paragraph A III
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

1 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e305fd30-71bc-51c7-80f4-a8fb318b82c3', '5c4c6506-9d5d-52ec-90de-0d34ac302856', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff31f762-d408-5254-bd10-864b19e68f0c', '5c4c6506-9d5d-52ec-90de-0d34ac302856', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db888ca8-4b9b-559e-90ab-b29c3fb0f300', '5c4c6506-9d5d-52ec-90de-0d34ac302856', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('257f02fe-4623-5ca4-8391-f31b3943fe0d', '5c4c6506-9d5d-52ec-90de-0d34ac302856', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('278ebaed-fa3c-56af-8e1f-bffaa7675635', '5c4c6506-9d5d-52ec-90de-0d34ac302856', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ab67c72-8d9f-579a-bd25-ef7e5a996e44', '5c4c6506-9d5d-52ec-90de-0d34ac302856', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc40d3ca-0d16-5a62-8612-c7439d7544ff', '5c4c6506-9d5d-52ec-90de-0d34ac302856', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01b7dc54-0898-5367-958c-831abc0721b3', '5c4c6506-9d5d-52ec-90de-0d34ac302856', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdf9651c-1a9d-578b-b469-efe091585d53', '5c4c6506-9d5d-52ec-90de-0d34ac302856', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25116ab7-73ab-59c8-8392-680ad922658f', '5c4c6506-9d5d-52ec-90de-0d34ac302856', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1bc9080e-e341-5dbb-8c5c-f98021218dc6', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A-G from the list below.
Write the correct number, i-x, in boxes 1-6 on your answer sheet.
List of Headings
(I)
The search for the better-fit matching between the model and the gained figures to foresee the activities of the genes
(II)
The definition of MEDUSA
(III)
A flashback of commencement for a far-reaching breakthrough
(IV)
A drawing of the gene map
(V)
An algorithm used to construct a specific model to discern the appearance of something new by the joint effort of Wiggins and another scientist
(VI)
An introduction of a background tracing back to the availability of mature techniques for detailed research on genes
(VII)
A way out to face the challenge confronting the scientist on the deciding of researchable data.
(VIII)
A failure to find out some specific genes controlling the production of certain proteins
(IX)
The use of a means from another domain for reference
(X)
A tough hurdle on the way to find the law governing the activities of the genes
Example: Paragraph A III
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

2 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5609829-2d4f-5368-bb7f-2e262cd074e8', '1bc9080e-e341-5dbb-8c5c-f98021218dc6', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('543321cc-3be0-5d22-927f-13542973b668', '1bc9080e-e341-5dbb-8c5c-f98021218dc6', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a07b68f6-209f-5fd5-a366-dd41c9778356', '1bc9080e-e341-5dbb-8c5c-f98021218dc6', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6696bff-3cfb-5aea-8254-bcc96f8b3a0d', '1bc9080e-e341-5dbb-8c5c-f98021218dc6', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f29a775e-87d4-5eee-834f-15cfc1cc8a6c', '1bc9080e-e341-5dbb-8c5c-f98021218dc6', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e12bf51-b47d-50ba-9bf5-32594403bae5', '1bc9080e-e341-5dbb-8c5c-f98021218dc6', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a1eed27-7ec2-5c9a-bf0f-b51dcdf63d4a', '1bc9080e-e341-5dbb-8c5c-f98021218dc6', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b28c6b6-5c59-5c1e-9324-b2e0d01727b9', '1bc9080e-e341-5dbb-8c5c-f98021218dc6', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4201e09-4e40-51ff-afea-7626a23c00e9', '1bc9080e-e341-5dbb-8c5c-f98021218dc6', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fedff5e-e539-5960-b016-8fa1743cdcab', '1bc9080e-e341-5dbb-8c5c-f98021218dc6', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9f56e9cb-dd17-5281-be8b-f5036e518079', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A-G from the list below.
Write the correct number, i-x, in boxes 1-6 on your answer sheet.
List of Headings
(I)
The search for the better-fit matching between the model and the gained figures to foresee the activities of the genes
(II)
The definition of MEDUSA
(III)
A flashback of commencement for a far-reaching breakthrough
(IV)
A drawing of the gene map
(V)
An algorithm used to construct a specific model to discern the appearance of something new by the joint effort of Wiggins and another scientist
(VI)
An introduction of a background tracing back to the availability of mature techniques for detailed research on genes
(VII)
A way out to face the challenge confronting the scientist on the deciding of researchable data.
(VIII)
A failure to find out some specific genes controlling the production of certain proteins
(IX)
The use of a means from another domain for reference
(X)
A tough hurdle on the way to find the law governing the activities of the genes
Example: Paragraph A III
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

3 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eca18817-de12-5f71-a056-1e053c72b26d', '9f56e9cb-dd17-5281-be8b-f5036e518079', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ba8cfd1-215a-5379-b712-57002f048444', '9f56e9cb-dd17-5281-be8b-f5036e518079', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8cafdae5-b326-5a0f-b9a8-876cc5cf08fd', '9f56e9cb-dd17-5281-be8b-f5036e518079', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32c726d9-672e-587a-b700-897403adb1a2', '9f56e9cb-dd17-5281-be8b-f5036e518079', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85bd3246-c5d9-56d5-98e7-92c09b9458c8', '9f56e9cb-dd17-5281-be8b-f5036e518079', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdb9a7d2-a816-56ba-adbf-444529c6e3e2', '9f56e9cb-dd17-5281-be8b-f5036e518079', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5687e625-c704-5760-8b5a-f8f497504139', '9f56e9cb-dd17-5281-be8b-f5036e518079', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3aa836d-c132-5d83-b395-13fcea406428', '9f56e9cb-dd17-5281-be8b-f5036e518079', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d515211-5bd4-5fa8-af75-b4ce74c5fff1', '9f56e9cb-dd17-5281-be8b-f5036e518079', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14885ddc-ecc4-553a-8793-c85e00dc5895', '9f56e9cb-dd17-5281-be8b-f5036e518079', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a2206a6a-cbce-5cbd-8ab2-106d05684e84', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A-G from the list below.
Write the correct number, i-x, in boxes 1-6 on your answer sheet.
List of Headings
(I)
The search for the better-fit matching between the model and the gained figures to foresee the activities of the genes
(II)
The definition of MEDUSA
(III)
A flashback of commencement for a far-reaching breakthrough
(IV)
A drawing of the gene map
(V)
An algorithm used to construct a specific model to discern the appearance of something new by the joint effort of Wiggins and another scientist
(VI)
An introduction of a background tracing back to the availability of mature techniques for detailed research on genes
(VII)
A way out to face the challenge confronting the scientist on the deciding of researchable data.
(VIII)
A failure to find out some specific genes controlling the production of certain proteins
(IX)
The use of a means from another domain for reference
(X)
A tough hurdle on the way to find the law governing the activities of the genes
Example: Paragraph A III
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

4 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('282b7457-cad1-57e2-a2e2-71e3beb849ff', 'a2206a6a-cbce-5cbd-8ab2-106d05684e84', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2595ab2a-45ea-5a48-ac24-965e1bb2aae8', 'a2206a6a-cbce-5cbd-8ab2-106d05684e84', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff10e387-169b-525c-90b7-897f3d629c21', 'a2206a6a-cbce-5cbd-8ab2-106d05684e84', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e5ef753-3be5-5676-90bf-a1db9b1a189b', 'a2206a6a-cbce-5cbd-8ab2-106d05684e84', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42230cbb-5f49-5d01-9de4-d50c37c534f2', 'a2206a6a-cbce-5cbd-8ab2-106d05684e84', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53d2fd9a-245b-5fe7-a657-c723dc55b4e0', 'a2206a6a-cbce-5cbd-8ab2-106d05684e84', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1554b6f2-02e4-550b-83fe-3aefbfffef42', 'a2206a6a-cbce-5cbd-8ab2-106d05684e84', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55c0a6b7-2488-548b-a051-b4d6cfd0f746', 'a2206a6a-cbce-5cbd-8ab2-106d05684e84', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acab9384-5abb-5776-b1bd-dcf7f974b365', 'a2206a6a-cbce-5cbd-8ab2-106d05684e84', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48d4143a-17bc-5afd-b9df-23ece6006b46', 'a2206a6a-cbce-5cbd-8ab2-106d05684e84', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a3f34b81-7299-5615-85c1-4175f0d5a5fc', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A-G from the list below.
Write the correct number, i-x, in boxes 1-6 on your answer sheet.
List of Headings
(I)
The search for the better-fit matching between the model and the gained figures to foresee the activities of the genes
(II)
The definition of MEDUSA
(III)
A flashback of commencement for a far-reaching breakthrough
(IV)
A drawing of the gene map
(V)
An algorithm used to construct a specific model to discern the appearance of something new by the joint effort of Wiggins and another scientist
(VI)
An introduction of a background tracing back to the availability of mature techniques for detailed research on genes
(VII)
A way out to face the challenge confronting the scientist on the deciding of researchable data.
(VIII)
A failure to find out some specific genes controlling the production of certain proteins
(IX)
The use of a means from another domain for reference
(X)
A tough hurdle on the way to find the law governing the activities of the genes
Example: Paragraph A III
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

5 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e709f964-14a5-59f5-961d-33737d8afd54', 'a3f34b81-7299-5615-85c1-4175f0d5a5fc', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ff3a17f-4152-57d7-814a-1829096f1185', 'a3f34b81-7299-5615-85c1-4175f0d5a5fc', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('218b09ef-7dd6-5fa3-a5be-0bfd077817c0', 'a3f34b81-7299-5615-85c1-4175f0d5a5fc', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d27a518-8990-5e8b-9b4a-932f954028ae', 'a3f34b81-7299-5615-85c1-4175f0d5a5fc', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bd09965-41ce-56b5-ac1c-7574fa314533', 'a3f34b81-7299-5615-85c1-4175f0d5a5fc', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4bc38a64-088a-5201-b129-22f22301b3a3', 'a3f34b81-7299-5615-85c1-4175f0d5a5fc', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc440ec1-238c-57b2-b132-6acc81efd701', 'a3f34b81-7299-5615-85c1-4175f0d5a5fc', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8864929-d904-5abb-b60d-9c9ab4353fbe', 'a3f34b81-7299-5615-85c1-4175f0d5a5fc', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03c3e13a-2c1b-52df-a0de-8d479c3ef6ef', 'a3f34b81-7299-5615-85c1-4175f0d5a5fc', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89a261cb-ca60-54ad-b725-abf727c9d484', 'a3f34b81-7299-5615-85c1-4175f0d5a5fc', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('42754d74-7e96-5cbe-918d-4cd21e53e9bd', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs, A-G
Choose the correct heading for paragraphs A-G from the list below.
Write the correct number, i-x, in boxes 1-6 on your answer sheet.
List of Headings
(I)
The search for the better-fit matching between the model and the gained figures to foresee the activities of the genes
(II)
The definition of MEDUSA
(III)
A flashback of commencement for a far-reaching breakthrough
(IV)
A drawing of the gene map
(V)
An algorithm used to construct a specific model to discern the appearance of something new by the joint effort of Wiggins and another scientist
(VI)
An introduction of a background tracing back to the availability of mature techniques for detailed research on genes
(VII)
A way out to face the challenge confronting the scientist on the deciding of researchable data.
(VIII)
A failure to find out some specific genes controlling the production of certain proteins
(IX)
The use of a means from another domain for reference
(X)
A tough hurdle on the way to find the law governing the activities of the genes
Example: Paragraph A III
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa312963-0798-5d3d-ad9b-9f6b7a5d5720', '42754d74-7e96-5cbe-918d-4cd21e53e9bd', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63d4b812-db4c-5638-a544-bdc8f84d0777', '42754d74-7e96-5cbe-918d-4cd21e53e9bd', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37c4c1f6-a4e3-5a0b-99c8-d09db60dd6d2', '42754d74-7e96-5cbe-918d-4cd21e53e9bd', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('152edafe-3eeb-580d-8d46-87679b5d018a', '42754d74-7e96-5cbe-918d-4cd21e53e9bd', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fac23735-3513-5e3d-bf46-ac8347979372', '42754d74-7e96-5cbe-918d-4cd21e53e9bd', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ce7b388-4d57-5e46-bbcb-89350e977920', '42754d74-7e96-5cbe-918d-4cd21e53e9bd', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('336af5a1-c78b-532c-8422-3ada3fdf2707', '42754d74-7e96-5cbe-918d-4cd21e53e9bd', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dbb3faf-34e2-596a-b999-b965576c78f8', '42754d74-7e96-5cbe-918d-4cd21e53e9bd', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30ca2908-d8b9-5f48-92ce-7a8bd65e2a67', '42754d74-7e96-5cbe-918d-4cd21e53e9bd', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ac78275-a38d-5b7a-a45e-c87931cb816c', '42754d74-7e96-5cbe-918d-4cd21e53e9bd', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('776480c2-386f-5ac9-89f6-3b43dd7f166f', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage 1? In boxes 7-9 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
7
Wiggins is the first man to use DNA microarrays for the research on genes.
8
There is almost no possibility for the effort to decrease the patterns of interaction between DNA, RNA, and proteins.
9
Wiggins holds a very positive attitude on the future of genetic research.

7 ____ Wiggins is the first man to use DNA microarrays for the research on genes.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc0434d0-fab5-5869-9b68-ab23069217eb', '776480c2-386f-5ac9-89f6-3b43dd7f166f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f568270-7359-5621-b366-38c8a076cdda', '776480c2-386f-5ac9-89f6-3b43dd7f166f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e95b87c1-1ab5-53fe-a0cc-f3b536f7848d', '776480c2-386f-5ac9-89f6-3b43dd7f166f', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('75248f0f-08b4-5155-b94e-e89747cb0daa', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage 1? In boxes 7-9 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
7
Wiggins is the first man to use DNA microarrays for the research on genes.
8
There is almost no possibility for the effort to decrease the patterns of interaction between DNA, RNA, and proteins.
9
Wiggins holds a very positive attitude on the future of genetic research.

8 ____ There is almost no possibility for the effort to decrease the patterns of interaction between DNA, RNA, and proteins.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9ac6523-c724-5f7e-bf30-b2cfb3225018', '75248f0f-08b4-5155-b94e-e89747cb0daa', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffc25a04-9b4e-57da-b0ae-8c5d8e0dc67a', '75248f0f-08b4-5155-b94e-e89747cb0daa', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7523d7ea-7492-5b2c-b7e6-9f745d2d8a18', '75248f0f-08b4-5155-b94e-e89747cb0daa', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f5e7f225-3a91-5738-8c04-f24844c82de9', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage 1? In boxes 7-9 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
7
Wiggins is the first man to use DNA microarrays for the research on genes.
8
There is almost no possibility for the effort to decrease the patterns of interaction between DNA, RNA, and proteins.
9
Wiggins holds a very positive attitude on the future of genetic research.

9 ____ Wiggins holds a very positive attitude on the future of genetic research.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d79aa0be-ff0f-5601-afb0-552c2c4af68c', 'f5e7f225-3a91-5738-8c04-f24844c82de9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78354600-c137-50f3-a2a1-b851631ad132', 'f5e7f225-3a91-5738-8c04-f24844c82de9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a909d3e-0601-5df5-8757-f1e9d0eb327a', 'f5e7f225-3a91-5738-8c04-f24844c82de9', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2143d48c-0bb0-59e2-af0a-b7c426750f86', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage, using No More than three words from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
Wiggins states that the astoundingly rapid development of techniques concerning the components of genes aroused the researchers to look at
10
from a totally new way.
11
is the heart and soul of these techniques and no matter what the
12
were, at the same time they can offer a whole picture of the genes’ activities as well as
13
in all types of cells. With these techniques, scientists could locate the exact gene which was on or off to manipulate the production of the proteins.

Wiggins states that the astoundingly rapid development of techniques concerning the components of genes aroused the researchers to look at 10 ____ from a totally new way. 11 ____ is the heart and soul of these techniques and no matter what the 12 ____ were, at the same time they can offer a whole picture of the genes’ activities as well as 13 ____ in all types of cells. With these techniques, scientists could locate the exact gene which was on or off to manipulate the production of the proteins.$md$, NULL, ARRAY['.*biological.*phenomena.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6a044463-d0bc-5a57-a40a-7a382e0272cb', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage, using No More than three words from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
Wiggins states that the astoundingly rapid development of techniques concerning the components of genes aroused the researchers to look at
10
from a totally new way.
11
is the heart and soul of these techniques and no matter what the
12
were, at the same time they can offer a whole picture of the genes’ activities as well as
13
in all types of cells. With these techniques, scientists could locate the exact gene which was on or off to manipulate the production of the proteins.

Wiggins states that the astoundingly rapid development of techniques concerning the components of genes aroused the researchers to look at 10 ____ from a totally new way. 11 ____ is the heart and soul of these techniques and no matter what the 12 ____ were, at the same time they can offer a whole picture of the genes’ activities as well as 13 ____ in all types of cells. With these techniques, scientists could locate the exact gene which was on or off to manipulate the production of the proteins.$md$, NULL, ARRAY['.*biological.*phenomena.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8a5ebcea-a714-56a5-a51b-75ace807e860', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage, using No More than three words from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
Wiggins states that the astoundingly rapid development of techniques concerning the components of genes aroused the researchers to look at
10
from a totally new way.
11
is the heart and soul of these techniques and no matter what the
12
were, at the same time they can offer a whole picture of the genes’ activities as well as
13
in all types of cells. With these techniques, scientists could locate the exact gene which was on or off to manipulate the production of the proteins.

Wiggins states that the astoundingly rapid development of techniques concerning the components of genes aroused the researchers to look at 10 ____ from a totally new way. 11 ____ is the heart and soul of these techniques and no matter what the 12 ____ were, at the same time they can offer a whole picture of the genes’ activities as well as 13 ____ in all types of cells. With these techniques, scientists could locate the exact gene which was on or off to manipulate the production of the proteins.$md$, NULL, ARRAY['.*biological.*phenomena.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('be6baf98-fdd7-5edb-8699-c5cc92dd7c0e', '87872d86-11ec-5c8c-b9b2-6eb05dd972a1', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage, using No More than three words from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
Wiggins states that the astoundingly rapid development of techniques concerning the components of genes aroused the researchers to look at
10
from a totally new way.
11
is the heart and soul of these techniques and no matter what the
12
were, at the same time they can offer a whole picture of the genes’ activities as well as
13
in all types of cells. With these techniques, scientists could locate the exact gene which was on or off to manipulate the production of the proteins.

Wiggins states that the astoundingly rapid development of techniques concerning the components of genes aroused the researchers to look at 10 ____ from a totally new way. 11 ____ is the heart and soul of these techniques and no matter what the 12 ____ were, at the same time they can offer a whole picture of the genes’ activities as well as 13 ____ in all types of cells. With these techniques, scientists could locate the exact gene which was on or off to manipulate the production of the proteins.$md$, NULL, ARRAY['.*biological.*phenomena.*']);

COMMIT;
