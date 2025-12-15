BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-can--a-brief-history-lesson-1455'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-can--a-brief-history-lesson-1455';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-can--a-brief-history-lesson-1455';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-can--a-brief-history-lesson-1455';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c97e8623-3d06-5e45-a07d-51c91afe0709', 'ielts-reading-the-can--a-brief-history-lesson-1455', $t$The Can – A Brief History Lesson$t$, $md$## The Can – A Brief History Lesson

Nguồn:
- Test: https://mini-ielts.com/1455/reading/the-can--a-brief-history-lesson
- Solution: https://mini-ielts.com/1455/view-solution/reading/the-can--a-brief-history-lesson$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('98bacfa9-3889-5b74-bf15-dd9335c58e88', 'c97e8623-3d06-5e45-a07d-51c91afe0709', 1, $t$Reading — The Can – A Brief History Lesson$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Can – A Brief History Lesson

A. The story of the can begins in 1795 when Nicholas Appert, a Parisian, had an idea: why not pack food in bottles like wine? Fifteen years later, after researching and testing his idea, he published his theory: if food is sufficiently heated and sealed in an airtight container, it will not spoil. In 1810 Peter Durand, an Englishman, wanted to surpass Appert’s invention, so he elected to try tin instead of glass. Like glass, tin could be sealed airtight but tin was not breakable and was much easier to handle. Durand himself did no canning, but two other Englishmen, Bryan Donkin and John Hall, used Durand’s patent. After experimenting for more than a year, they set up a commercial canning factory and by 1813 they were sending tins of food to British army and navy authorities for trial.

B. Perhaps the greatest encouragement to the newborn canning industry was the explosion in the number of new colonial territories. As people and goods were being transported to all parts of the world, the can industry itself was growing in new territories. Englishmen who emigrated to America brought their newfound knowledge with them. One of these was Thomas Kensett, who might fairly be called the father of the can manufacturing industry in the United States. In 1812 he set up a small plant on the New York waterfront to can the first hermetically sealed products in the United States.

C. Just before the Civil War, a technical advance by canners enabled them to speed up production. Adding calcium chloride to the water in which cans were cooked raised the water temperature, speeding up the canning process. Also for almost 100 years, tin cans were made by artisans by hand. It was a laborious process, requiring considerable skill and muscle. As the industrial revolution took hold in the United States, the demand for cans increased and machines began to replace the artisans’ handiwork. A good artisan could make only 10 cans a day. True production progress in can-making began in 1922, when American engineers perfected the body-making process. New methods soon increased production of cans to as many as 250 a minute.

D. As early as 1940, can manufacturers began to explore the possibility of adapting cans to package carbonated soft drinks. The can had to be strengthened to accommodate higher internal can pressures created by carbonation (especially during warm summer months), which meant increasing the thickness of the metal used in the can ends. Another concern for the new beverage can was its shelf life. Even small amounts of dissolved tin or iron from the can could impair the drinking quality of drinks. Also the food acids, including carbonic, citric and phosphoric, in soft drinks presented a risk for the rapid corrosion of exposed tin and iron in the can. At this point the can was upgraded by improving the organic coatings used to line the inside. The can manufacturers then embarked on a program of material and cost savings by reducing both the amount of steel and the amount of coating used in can making. These efforts were in part inspired by a new competitor - aluminum.

E. Beverage cans made from aluminum were first introduced in 1965. This was an exciting innovation for the packaging industry because the aluminum can was made with only two pieces - a body and an end. This made production easier. Some of the reasons for the aluminum can’s acceptance were its ductility, its support of carbonation pressure, its lighter weight and the fact that aluminum does not rust. Both steel and aluminum cans used an easy-open end tab but the aluminum tab was much easier to make. Perhaps the most critical element in the aluminum can’s market success was its recycling value. Aluminum can recycling excelled economically in the competition with steel because of the efficiencies aluminum cans realized in making new cans from recycled materials compared with 100 percent virgin aluminum. Steel did not realize similar economies in the recycling process.

F. Prior to 1970, can makers, customers and consumers alike were unaware of the impact that the mining and manufacturing of steel or aluminum had on the environment. The concept of natural resource preservation was not an issue of great importance and the low growth of population during these early years further de-emphasized concerns for resource depletion. Both industries, however, came to realize the importance of reducing their impact on the environment in the late 1960s and early 1970s as a new environmentally conscious generation emerged. Manufacturers began to recognize the economics of recycling, namely lower manufacturing costs from using less material and less energy. By the 1980s and 1990s, recycling had become a way of life. Aluminum can recycling has become a billion-dollar business and one of the world’s most successful environmental enterprises. Over the years, the aluminum can has come to be known as America’s most recyclable package, with over 60 percent of cans being recycled annually.

G. Advances in can manufacturing technology have also brought us lighter aluminum cans. In 1972, one pound of aluminum yielded only 21.75 cans. Today, by using less material to make each can, one pound of aluminum makes approximately 32 cans - a 47 percent improvement. Just the lightening of can ends makes a huge difference. When you multiply the savings by the 100 billion cans that are made each year, the weight and savings are phenomenal - over 200 million pounds of aluminum!$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (i – xi) in boxes 1-6 on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
List of headings
i The Invention of the Aluminium Can
ii Technological Breakthroughs
iii Canning and the Beer Industry
iv The Invention
v Canning and War
vi Further Manufacturing Advances
vii Problems with Spoiled Contents
viii Expansion of the Industry
ix Today’s Uses for Canning
x Drinks Canning
xi Cans and The Environment
Example Answer
Paragraph
A
iv
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
VALUES ('d81b7ac7-a9f7-59cb-9eb7-2374c7f038f7', '1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdf95579-500c-5f7c-a91e-e6da8596749e', '1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27af99cb-3177-5728-a0c3-49c6a2621c23', '1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af7bbb34-0bd8-512c-9812-ba7b55472fe5', '1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cbe8a16-0769-5424-bd4d-ad04c2e1ae62', '1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f927ee81-3501-5183-9fab-83f3fd9fc826', '1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9099dd05-87f4-5e1f-8f2e-cdb5f8f0f699', '1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b145659f-9546-596c-afe5-9b414bbcb376', '1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76fd3aa6-75cc-5924-a136-1e9a43ff784c', '1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09c04f23-5cf2-5c9c-bf2a-3eec5e5d4ae9', '1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2462c06b-291b-5a32-8c13-3c6b0eb9e025', '1d2fd3c7-bd04-5062-9c5f-02a8482ef50e', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (i – xi) in boxes 1-6 on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
List of headings
i The Invention of the Aluminium Can
ii Technological Breakthroughs
iii Canning and the Beer Industry
iv The Invention
v Canning and War
vi Further Manufacturing Advances
vii Problems with Spoiled Contents
viii Expansion of the Industry
ix Today’s Uses for Canning
x Drinks Canning
xi Cans and The Environment
Example Answer
Paragraph
A
iv
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
VALUES ('ac40343e-ba01-51c8-83d9-85c1a522823c', '59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cf718ef-6a31-5cef-a64d-0d4d2a874115', '59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49999624-1b3d-54f7-876e-ab260ae2a42d', '59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6f65214-fbcb-5ad7-ac20-e9742beca139', '59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6aae01bf-2d38-5d15-84ab-28f865044cf4', '59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('508e694b-8f06-5aa2-89ab-3a72feb2e65e', '59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0843389b-a131-5581-83bb-1e92cb9bf560', '59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a67aa68a-3293-5a6f-aad1-a06934252e4c', '59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5c1fb84-ee5d-5777-96d5-3439294d7961', '59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('182676f8-bd92-5b6e-81a0-6f3084b1423d', '59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('950c5434-e660-5fc6-9eb4-2d0ed854c718', '59ebec37-ce1e-5754-9bfd-73ea2e1e5a8b', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('20de6898-c1bd-5793-9e11-f5006993c4d1', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (i – xi) in boxes 1-6 on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
List of headings
i The Invention of the Aluminium Can
ii Technological Breakthroughs
iii Canning and the Beer Industry
iv The Invention
v Canning and War
vi Further Manufacturing Advances
vii Problems with Spoiled Contents
viii Expansion of the Industry
ix Today’s Uses for Canning
x Drinks Canning
xi Cans and The Environment
Example Answer
Paragraph
A
iv
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
VALUES ('ba508d8c-7d8e-5b6a-bbfb-eb159f6b312c', '20de6898-c1bd-5793-9e11-f5006993c4d1', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a50738a-4650-56fe-a0bb-57811729b13f', '20de6898-c1bd-5793-9e11-f5006993c4d1', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ab895ea-596a-5ea2-b8d1-bc658ec650b0', '20de6898-c1bd-5793-9e11-f5006993c4d1', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bd31977-c384-5bb1-ad8e-21d1d11399ee', '20de6898-c1bd-5793-9e11-f5006993c4d1', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('675b74b4-b848-5ca2-899d-38c89133f062', '20de6898-c1bd-5793-9e11-f5006993c4d1', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b5bee4e-448c-5608-8330-38d24d9c5a0f', '20de6898-c1bd-5793-9e11-f5006993c4d1', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09cf6d12-da9a-56a3-a535-fbb2e36ee3df', '20de6898-c1bd-5793-9e11-f5006993c4d1', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e805f18-6748-5a1c-a20c-a019a2b782f2', '20de6898-c1bd-5793-9e11-f5006993c4d1', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb3cf6aa-a743-5768-a7b6-8e94349bc306', '20de6898-c1bd-5793-9e11-f5006993c4d1', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f98762b-6b48-502f-b353-437595e9469e', '20de6898-c1bd-5793-9e11-f5006993c4d1', 10, $md$x$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf5080c1-dc14-5cf6-bc90-a447a3560450', '20de6898-c1bd-5793-9e11-f5006993c4d1', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c6d4a5fd-a214-5ee1-861f-28232be1acb2', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (i – xi) in boxes 1-6 on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
List of headings
i The Invention of the Aluminium Can
ii Technological Breakthroughs
iii Canning and the Beer Industry
iv The Invention
v Canning and War
vi Further Manufacturing Advances
vii Problems with Spoiled Contents
viii Expansion of the Industry
ix Today’s Uses for Canning
x Drinks Canning
xi Cans and The Environment
Example Answer
Paragraph
A
iv
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
VALUES ('763190d6-c3dc-5d9b-b23b-0ed967752cbe', 'c6d4a5fd-a214-5ee1-861f-28232be1acb2', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1f2b07a-f8a3-580d-bb0d-b918948a21f8', 'c6d4a5fd-a214-5ee1-861f-28232be1acb2', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40bb5794-fff7-525f-8c85-d5780756419a', 'c6d4a5fd-a214-5ee1-861f-28232be1acb2', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3469edb-1251-5f0e-8ee7-6972139eecfa', 'c6d4a5fd-a214-5ee1-861f-28232be1acb2', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('803f9cfd-470e-5789-93be-01a2f08427ac', 'c6d4a5fd-a214-5ee1-861f-28232be1acb2', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69e71ac0-38e3-5b8b-9380-cabe0d566192', 'c6d4a5fd-a214-5ee1-861f-28232be1acb2', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('157a2a7e-aa4e-5155-9991-cc08d1e30f32', 'c6d4a5fd-a214-5ee1-861f-28232be1acb2', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26f5898f-1578-5ae8-8c4b-9b70e75c3319', 'c6d4a5fd-a214-5ee1-861f-28232be1acb2', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bddf5dc3-2c64-5c43-98c4-fdbb0254a48a', 'c6d4a5fd-a214-5ee1-861f-28232be1acb2', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f17e210-ed9e-59d9-acde-ad149742040f', 'c6d4a5fd-a214-5ee1-861f-28232be1acb2', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a1adc44-4178-5534-9062-f4cf713ff5bc', 'c6d4a5fd-a214-5ee1-861f-28232be1acb2', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('46a31110-83e3-54d1-b91c-12ee7693a05c', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (i – xi) in boxes 1-6 on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
List of headings
i The Invention of the Aluminium Can
ii Technological Breakthroughs
iii Canning and the Beer Industry
iv The Invention
v Canning and War
vi Further Manufacturing Advances
vii Problems with Spoiled Contents
viii Expansion of the Industry
ix Today’s Uses for Canning
x Drinks Canning
xi Cans and The Environment
Example Answer
Paragraph
A
iv
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
VALUES ('95b88ee3-504b-5c4f-a984-07836032efbe', '46a31110-83e3-54d1-b91c-12ee7693a05c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfb0ac6b-e1ab-5d91-a7a5-c855f49d36b3', '46a31110-83e3-54d1-b91c-12ee7693a05c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77466055-5af3-59ea-8bee-f909c7ed3190', '46a31110-83e3-54d1-b91c-12ee7693a05c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e000203f-1031-5f0c-ac14-305727f43f70', '46a31110-83e3-54d1-b91c-12ee7693a05c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1aaa45e-6711-5d75-a802-9f6729fc6457', '46a31110-83e3-54d1-b91c-12ee7693a05c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39be2664-75cf-5488-b87a-5cb8df317946', '46a31110-83e3-54d1-b91c-12ee7693a05c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('215a8dd6-a9ad-5afc-923f-0541c0775bfa', '46a31110-83e3-54d1-b91c-12ee7693a05c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('371bfca7-f7d9-5c7e-b143-6ed7221ee9dd', '46a31110-83e3-54d1-b91c-12ee7693a05c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00306683-2eb9-5d96-b865-14aaf7fdd5d1', '46a31110-83e3-54d1-b91c-12ee7693a05c', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c558277-95b2-59cc-91c5-b903b14d36cd', '46a31110-83e3-54d1-b91c-12ee7693a05c', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74e91a81-453c-5baa-ac50-41f8df88c7f2', '46a31110-83e3-54d1-b91c-12ee7693a05c', 11, $md$xi$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a154c7cf-0372-5a73-97c5-220ecdfa4d13', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven paragraphs
A – G
.
From the list of headings below choose the most suitable headings for paragraphs
B – G
.
Write the appropriate number (i – xi) in boxes 1-6 on your answer sheet.
NB
There are more headings than paragraphs, so you will not use them all.
List of headings
i The Invention of the Aluminium Can
ii Technological Breakthroughs
iii Canning and the Beer Industry
iv The Invention
v Canning and War
vi Further Manufacturing Advances
vii Problems with Spoiled Contents
viii Expansion of the Industry
ix Today’s Uses for Canning
x Drinks Canning
xi Cans and The Environment
Example Answer
Paragraph
A
iv
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
VALUES ('b5b25f87-8a61-5da6-8fda-b439aba1cc92', 'a154c7cf-0372-5a73-97c5-220ecdfa4d13', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f6bed59-5976-56f1-a283-728994c7f136', 'a154c7cf-0372-5a73-97c5-220ecdfa4d13', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e90182cc-c054-56b3-8530-53a97df28449', 'a154c7cf-0372-5a73-97c5-220ecdfa4d13', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13e39fc8-b031-5ebc-a0c4-dd44159e713e', 'a154c7cf-0372-5a73-97c5-220ecdfa4d13', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db6604b3-6fea-54fc-a138-12c67f38ad3a', 'a154c7cf-0372-5a73-97c5-220ecdfa4d13', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e464651f-5cc4-58a1-b23c-8c37c2f74a54', 'a154c7cf-0372-5a73-97c5-220ecdfa4d13', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('215e28ac-9708-5dc0-8a9f-4c42a0c19ab0', 'a154c7cf-0372-5a73-97c5-220ecdfa4d13', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f5fa2ad-d9b1-5120-843b-535a97ae290f', 'a154c7cf-0372-5a73-97c5-220ecdfa4d13', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9b45471-6d27-5c93-b479-2bff867556f9', 'a154c7cf-0372-5a73-97c5-220ecdfa4d13', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cacea21f-3acb-5144-896f-782ce0e13664', 'a154c7cf-0372-5a73-97c5-220ecdfa4d13', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1aee357-e70d-53a9-9b2c-94f8df8b7242', 'a154c7cf-0372-5a73-97c5-220ecdfa4d13', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ad06da03-4eaa-57a0-a985-1ec3044e959f', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

QUESTIONS 7-12
QUESTIONS 7-12
The first list (questions 7-12) is a list of dates of events in Reading Passage.
The second list (
A - G
) is a list of the events. Match the year with the correct event in the history of the can.
Write your answers in boxes 7-128 on your answer sheet.
List of events
A
Mass production techniques revolutionized the canning process.
B
Tinned food was tested by military authorities.
C
Today’s canning material was first introduced.
D
The first American canning factory was opened.
E
Tin was used in the canning process for the first time.
F
The canning of fizzy drinks began.
G
The first business canning plant was opened.
List of dates
7
1922
8
1812
9
1813
10
1965
11
1813
12
1940

7 ____ 1922$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35bd732a-13df-5df4-ad99-6c7d133818f7', 'ad06da03-4eaa-57a0-a985-1ec3044e959f', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef73e9ac-8918-5ea2-9b11-41619b06fee8', 'ad06da03-4eaa-57a0-a985-1ec3044e959f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0dcdaa6-0ebc-5c99-8bb8-c43b748caf3f', 'ad06da03-4eaa-57a0-a985-1ec3044e959f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2e6c1e8-9017-5b38-a516-af23d08da932', 'ad06da03-4eaa-57a0-a985-1ec3044e959f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eba9f409-8440-5337-9322-916cb96a2902', 'ad06da03-4eaa-57a0-a985-1ec3044e959f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9b1ed95-5c5c-5a48-824b-4b4ef6724399', 'ad06da03-4eaa-57a0-a985-1ec3044e959f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7a2e6b0-9106-50bc-8614-4f03e197790d', 'ad06da03-4eaa-57a0-a985-1ec3044e959f', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('59e52434-acb6-58d3-becb-d0159a0b7e71', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

QUESTIONS 7-12
QUESTIONS 7-12
The first list (questions 7-12) is a list of dates of events in Reading Passage.
The second list (
A - G
) is a list of the events. Match the year with the correct event in the history of the can.
Write your answers in boxes 7-128 on your answer sheet.
List of events
A
Mass production techniques revolutionized the canning process.
B
Tinned food was tested by military authorities.
C
Today’s canning material was first introduced.
D
The first American canning factory was opened.
E
Tin was used in the canning process for the first time.
F
The canning of fizzy drinks began.
G
The first business canning plant was opened.
List of dates
7
1922
8
1812
9
1813
10
1965
11
1813
12
1940

8 ____ 1812$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c003f4c-f405-52d1-be9f-323b738fd511', '59e52434-acb6-58d3-becb-d0159a0b7e71', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('144f25fd-7126-55c7-9bb4-04a5f3c59d39', '59e52434-acb6-58d3-becb-d0159a0b7e71', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fd95420-3785-5d82-bc03-b5b69b2cd734', '59e52434-acb6-58d3-becb-d0159a0b7e71', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b2fdb46-c2e8-59e3-bacf-f057aedec731', '59e52434-acb6-58d3-becb-d0159a0b7e71', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c1f6401-2a14-5484-b043-f7a191930c2e', '59e52434-acb6-58d3-becb-d0159a0b7e71', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9eddb1dd-6964-59c2-8e20-9c191088fcbf', '59e52434-acb6-58d3-becb-d0159a0b7e71', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21ff74df-cfd5-540d-bc58-03c1dd655c99', '59e52434-acb6-58d3-becb-d0159a0b7e71', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('743fad99-93d1-593d-b14a-92c7c83eaa74', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

QUESTIONS 7-12
QUESTIONS 7-12
The first list (questions 7-12) is a list of dates of events in Reading Passage.
The second list (
A - G
) is a list of the events. Match the year with the correct event in the history of the can.
Write your answers in boxes 7-128 on your answer sheet.
List of events
A
Mass production techniques revolutionized the canning process.
B
Tinned food was tested by military authorities.
C
Today’s canning material was first introduced.
D
The first American canning factory was opened.
E
Tin was used in the canning process for the first time.
F
The canning of fizzy drinks began.
G
The first business canning plant was opened.
List of dates
7
1922
8
1812
9
1813
10
1965
11
1813
12
1940

9 ____ 1813$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80cd1938-1e62-5550-9461-fafd3dbfa4b8', '743fad99-93d1-593d-b14a-92c7c83eaa74', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1300b9d4-3b7e-52d0-8a1b-f68d78f57328', '743fad99-93d1-593d-b14a-92c7c83eaa74', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fcc7cca-20ce-50f7-b416-7fadf227a065', '743fad99-93d1-593d-b14a-92c7c83eaa74', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aad08fbc-b664-527f-aff2-5278f218f978', '743fad99-93d1-593d-b14a-92c7c83eaa74', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1b6ca47-0210-504c-8204-3f21678972ed', '743fad99-93d1-593d-b14a-92c7c83eaa74', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e19fd745-edfc-5275-abbe-5e14d5c192b6', '743fad99-93d1-593d-b14a-92c7c83eaa74', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5283baa-e13f-5b7e-9586-4bd69defecb2', '743fad99-93d1-593d-b14a-92c7c83eaa74', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d79f6709-b00f-5b9d-ab46-e4f56dec4012', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

QUESTIONS 7-12
QUESTIONS 7-12
The first list (questions 7-12) is a list of dates of events in Reading Passage.
The second list (
A - G
) is a list of the events. Match the year with the correct event in the history of the can.
Write your answers in boxes 7-128 on your answer sheet.
List of events
A
Mass production techniques revolutionized the canning process.
B
Tinned food was tested by military authorities.
C
Today’s canning material was first introduced.
D
The first American canning factory was opened.
E
Tin was used in the canning process for the first time.
F
The canning of fizzy drinks began.
G
The first business canning plant was opened.
List of dates
7
1922
8
1812
9
1813
10
1965
11
1813
12
1940

10 ____ 1965$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2828e4dd-a20e-5a28-8fcc-e0047f1ab4e3', 'd79f6709-b00f-5b9d-ab46-e4f56dec4012', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d71a9a02-1fe5-511d-ad0c-2696cf1c092b', 'd79f6709-b00f-5b9d-ab46-e4f56dec4012', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a5f4314-9b2f-57df-b279-41a610b34388', 'd79f6709-b00f-5b9d-ab46-e4f56dec4012', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ce86200-e5ab-50d0-8820-6d03d77efb17', 'd79f6709-b00f-5b9d-ab46-e4f56dec4012', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc2d2d42-b3aa-53cf-9da9-d7a89162862a', 'd79f6709-b00f-5b9d-ab46-e4f56dec4012', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6f5057c-558b-57df-b72e-d90e70d55bc9', 'd79f6709-b00f-5b9d-ab46-e4f56dec4012', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84f943f7-0c62-502c-ae1d-a5a62d65ad76', 'd79f6709-b00f-5b9d-ab46-e4f56dec4012', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('494f2f1e-f822-5da3-8e36-f4b0099645f1', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

QUESTIONS 7-12
QUESTIONS 7-12
The first list (questions 7-12) is a list of dates of events in Reading Passage.
The second list (
A - G
) is a list of the events. Match the year with the correct event in the history of the can.
Write your answers in boxes 7-128 on your answer sheet.
List of events
A
Mass production techniques revolutionized the canning process.
B
Tinned food was tested by military authorities.
C
Today’s canning material was first introduced.
D
The first American canning factory was opened.
E
Tin was used in the canning process for the first time.
F
The canning of fizzy drinks began.
G
The first business canning plant was opened.
List of dates
7
1922
8
1812
9
1813
10
1965
11
1813
12
1940

11 ____ 1813$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a240d5f-7067-5e59-a173-da575c980e10', '494f2f1e-f822-5da3-8e36-f4b0099645f1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58fd039d-eaa0-5dbb-ae8e-c9b624793272', '494f2f1e-f822-5da3-8e36-f4b0099645f1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c196e07c-6239-505e-ace0-55a8065a4682', '494f2f1e-f822-5da3-8e36-f4b0099645f1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d320ae6-d90e-59c8-b411-88d7e2da2fd6', '494f2f1e-f822-5da3-8e36-f4b0099645f1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d11d074c-39ce-5cd9-9e9a-138570d57fc8', '494f2f1e-f822-5da3-8e36-f4b0099645f1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('038c18b2-5990-5279-a53e-770b4f9ed099', '494f2f1e-f822-5da3-8e36-f4b0099645f1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d761078-1c7d-5981-ab1b-2aad71ed16c8', '494f2f1e-f822-5da3-8e36-f4b0099645f1', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('180ec690-182b-5be6-ae32-b080cf57c6a0', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

QUESTIONS 7-12
QUESTIONS 7-12
The first list (questions 7-12) is a list of dates of events in Reading Passage.
The second list (
A - G
) is a list of the events. Match the year with the correct event in the history of the can.
Write your answers in boxes 7-128 on your answer sheet.
List of events
A
Mass production techniques revolutionized the canning process.
B
Tinned food was tested by military authorities.
C
Today’s canning material was first introduced.
D
The first American canning factory was opened.
E
Tin was used in the canning process for the first time.
F
The canning of fizzy drinks began.
G
The first business canning plant was opened.
List of dates
7
1922
8
1812
9
1813
10
1965
11
1813
12
1940

12 ____ 1940$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a83c4be-b845-5a62-a1d9-a4d93a6b5289', '180ec690-182b-5be6-ae32-b080cf57c6a0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22492b8f-4c8f-5f03-9568-62a7b19ea012', '180ec690-182b-5be6-ae32-b080cf57c6a0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef2436a6-0484-5199-8e5b-f75057d4dee3', '180ec690-182b-5be6-ae32-b080cf57c6a0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac5c9190-6af8-510f-a055-5cfd17e5cd57', '180ec690-182b-5be6-ae32-b080cf57c6a0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('685ad9f8-69e9-5e21-a3a7-92ca38523312', '180ec690-182b-5be6-ae32-b080cf57c6a0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('555ed79d-cd81-5b84-b50b-9179cf5eff0d', '180ec690-182b-5be6-ae32-b080cf57c6a0', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3fc34ac-6440-5535-9743-2351942f55a1', '180ec690-182b-5be6-ae32-b080cf57c6a0', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0e5c21ad-421f-5682-847d-dc3fbee7beb4', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

QUESTIONS 13-14
QUESTIONS 13-14
Do the following statements agree with the information given in Reading Passage?
In boxes 13-14 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
13
Recycling has helped reduce manufacturing overheads.
14
Aluminium can production costs have fallen by nearly 50% since 1972.

13 ____ Recycling has helped reduce manufacturing overheads.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8ec33ea-69dc-501e-b8d9-6f4c0fdf03fe', '0e5c21ad-421f-5682-847d-dc3fbee7beb4', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94e94596-8d25-5f93-9799-827e9fb75110', '0e5c21ad-421f-5682-847d-dc3fbee7beb4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06198efd-7f44-5db9-b609-bdc82b224235', '0e5c21ad-421f-5682-847d-dc3fbee7beb4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bfe612d4-5193-575f-9344-e6c0dac8c570', '98bacfa9-3889-5b74-bf15-dd9335c58e88', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

QUESTIONS 13-14
QUESTIONS 13-14
Do the following statements agree with the information given in Reading Passage?
In boxes 13-14 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
13
Recycling has helped reduce manufacturing overheads.
14
Aluminium can production costs have fallen by nearly 50% since 1972.

14 ____ Aluminium can production costs have fallen by nearly 50% since 1972.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66bb311d-cba9-5bf5-bcb9-31c4480dcc35', 'bfe612d4-5193-575f-9344-e6c0dac8c570', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d66ef91-63ce-57a0-9377-cd1d0f1e30b4', 'bfe612d4-5193-575f-9344-e6c0dac8c570', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f079eff0-ee73-5649-93fd-095d824e66f1', 'bfe612d4-5193-575f-9344-e6c0dac8c570', 3, $md$NOT GIVEN$md$, true);

COMMIT;
