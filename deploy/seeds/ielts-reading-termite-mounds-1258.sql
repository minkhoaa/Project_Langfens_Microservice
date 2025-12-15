BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-termite-mounds-1258'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-termite-mounds-1258';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-termite-mounds-1258';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-termite-mounds-1258';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('efb59c32-f6c5-5ccd-b400-430adf94e9d5', 'ielts-reading-termite-mounds-1258', $t$Termite Mounds$t$, $md$## Termite Mounds

Nguồn:
- Test: https://mini-ielts.com/1258/reading/termite-mounds
- Solution: https://mini-ielts.com/1258/view-solution/reading/termite-mounds$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 'efb59c32-f6c5-5ccd-b400-430adf94e9d5', 1, $t$Reading — Termite Mounds$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Termite Mounds

Could the vast towers of mud constructed by insects in sub-Saharan Africa hold the key to our energy-efficient building of the future?

A. To most of us, termites are destructive insects which can cause damage on a devastating scale. But according to Dr Rupert Soar of Loughborough University’s School of Mechanical and Manufacturing Engineering, these pests may serve a useful purpose for us after all. His multi-disciplinary team of British and American engineers and biologists have set out to investigate the giant mounds built by termites in Namibia, in sub-Saharan Africa, as part of the most extensive study of these structures ever taken.

B. Termite mounds are impressive for their size alone; typically they are three metres high, and some as tall as eight metres by found. They also reach far into the earth, where the insects ‘mine’ their building materials, carefully selecting each grain of sand they use. The termite's nest is contained in the central cavity of the mound, safely protected from the harsh environment outside. The mound itself is formed of an intricate lattice of tunnels, which spilt into smaller and smaller tunnels, much like a person’s blood vessels.

C. This complex system of tunnels draws in air from the outside, capturing wind energy to drive it through the mound. It also serves to expel spent respiratory gases from the nest to prevent the termites from suffocating, so ensuring them a continuous provision of fresh, breathable air. So detailed is the design that the nest stays within three degrees of a constant temperature, despite variations on the outside of up to 50 o C, from blistering heat in the daytime to below freezing on the coldest nights. The mound also automatically regulates moisture in the air, by means of best its underground ‘cellar’, and evaporation from the top of the mound. Some colonies even had ‘chimneys’ at a height of 20m to control moisture less in the hottest regions of sub-Saharan Africa.

D. Furthermore, the termites have evolved in such a way as to outsource some of their biological functions. Part of their digestive process in camera out by a fungus, which they ‘farm’ inside the mound. This fungus, which is found nowhere else on earth, thrives in the constant and optimum environment of the mound. The termites feed the fungus with slightly chewed wood pulp, which the fungus then breaks down into a digestible sugary food to provide the insects with energy, and cellulose which they use for building. And, although the termites must generate waste, none ever leaves the structure, indicating that there is also some kind of internal waste-recycling system.

E. Scientists are so excited by the mounds that they have labelled them a ‘super organism’ because, in Soar’s word. “They dance on the edge of what we would perceive to cool down, or if you’re too cold you need to thrive: that’s called homeostasis. What the termites have done is to move homeostatic function away from their body, into the structure in which they live. ‘As more information comes to light about the unique features of termite mounds, we may ultimately need to redefine our understanding of what constitutes a ‘living’ organism.

F. To reveal the structure of the mounds, Soar’s team begins by filling and covering their plaster of Paris, a chalky white paste based on the mineral gypsum, which becomes rock-solid when dry. The researcher's hen carves the plaster of Paris into half-millimatre-thick slices, and photograph them sequentially. Once the pictures are digitally scanned, computer technology is able to recreate complex three-dimensional images of the mounds. These models have enabled the team to map termite architecture at a level of detail never before attained.

G. Soar hopes that the models will explain how termite mounds create a self-regulating living environment which manages to respond to changing internal and external conditions without drawing on any outside source of power. If they do, the findings could be invaluable in informing future architectural design, and could inspire buildings that are self-sufficient, environmentally, and cheap to run. ‘As we approach a world of climate change, we need temperatures to rise, he explains, there will not be enough fuel to drive air conditioners around the world. It is hoped, says Soar, ‘ that the findings will provide clues that aid the ultimate development of new kinds of human habitats, suitable for a variety of arid, hostile environments not only on the earth but maybe one day on the moon and beyond.’$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('afe4d1f6-98c9-5130-aba3-93321fb46cce', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

QUESTIONS 1-7
QUESTIONS 1-7
Reading Passage 3 has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-ix, in boxes 1-7 on your answer sheet.
List of heading
i methods used to investigate termite mound formation
ii challenging our assumptions about the nature of life
iii reconsidering the termite’s reputation
iv principal functions of the termite mound
v distribution of termite mounds in sub-Saharan Africa
vi some potential benefits of understanding termite architecture
vii the astonishing physical dimensions of the termite mound
viii termite mounds under threat from global climate change
ix a mutually beneficial relationship
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
7
Paragraph G

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8377ddf0-235e-568a-a515-1e341557ec75', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74aa33d1-3987-5141-9b20-9b522582de1f', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08b0ce13-8244-5273-b583-5c0a28eb5437', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ab94c16-47d9-5ed9-8c57-a4974b49f41a', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afee9336-25b9-5b79-b9dd-e2c438c0fe8b', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a646356f-4e7c-5840-b290-803453ffe63e', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9758d565-c6f2-5872-8442-9140d6302723', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('267e4b97-ce1f-5909-8f39-14061aba243d', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 8, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e95fbe02-17fc-5340-85a0-a8be3b885e7a', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 9, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d18cb2f9-6e78-5249-b0e6-1ad4a5575e70', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 10, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a65a0d24-96b2-527f-859c-a6f1029069fb', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 11, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6e98957-f9e9-5d66-8106-a7b53206cc08', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 12, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8baa91d8-6dbd-52c6-bc00-3d47cb9049ed', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 13, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08c8afe6-cf32-54ca-b541-c158982dcd6a', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 14, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('403e07bb-780c-5596-84cb-381f88720ea4', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 15, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3a73cb9-1a35-5eaf-b608-39262a408a1f', 'afe4d1f6-98c9-5130-aba3-93321fb46cce', 16, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('83465d28-0207-5cb2-bc78-3af8c1967021', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

QUESTIONS 1-7
QUESTIONS 1-7
Reading Passage 3 has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-ix, in boxes 1-7 on your answer sheet.
List of heading
i methods used to investigate termite mound formation
ii challenging our assumptions about the nature of life
iii reconsidering the termite’s reputation
iv principal functions of the termite mound
v distribution of termite mounds in sub-Saharan Africa
vi some potential benefits of understanding termite architecture
vii the astonishing physical dimensions of the termite mound
viii termite mounds under threat from global climate change
ix a mutually beneficial relationship
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
7
Paragraph G

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a10285d-1186-5f3b-98a6-112e2997a464', '83465d28-0207-5cb2-bc78-3af8c1967021', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bec70e9d-5b55-5a64-99e5-fd349f36e30f', '83465d28-0207-5cb2-bc78-3af8c1967021', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86436e48-eecb-573a-9f1f-702d00f28aaa', '83465d28-0207-5cb2-bc78-3af8c1967021', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('038b56c2-b972-59cb-9aa5-bea275964bdd', '83465d28-0207-5cb2-bc78-3af8c1967021', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d96f5918-0ee5-559c-a041-2945983a7720', '83465d28-0207-5cb2-bc78-3af8c1967021', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07543cf0-29be-5eb6-9b78-3b26c6bc4957', '83465d28-0207-5cb2-bc78-3af8c1967021', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01061228-d881-5e24-a724-8ff2fb0f14b0', '83465d28-0207-5cb2-bc78-3af8c1967021', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('266d4d30-fbdc-5222-862e-970e61a03a26', '83465d28-0207-5cb2-bc78-3af8c1967021', 8, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9bb823b-8e7b-51a7-964a-6ca82c64d3c9', '83465d28-0207-5cb2-bc78-3af8c1967021', 9, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8031e2e-9f7b-5a1f-a8ae-48ef150ea4a0', '83465d28-0207-5cb2-bc78-3af8c1967021', 10, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4790f81-02b0-5954-8431-63d66ff80ef5', '83465d28-0207-5cb2-bc78-3af8c1967021', 11, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3043460f-e59f-5d6c-bbdf-0b2e54533bc1', '83465d28-0207-5cb2-bc78-3af8c1967021', 12, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a051240-ec30-5ee0-8975-aa2ede3bd6dd', '83465d28-0207-5cb2-bc78-3af8c1967021', 13, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff8917be-c944-529d-8727-11b0017c5c1f', '83465d28-0207-5cb2-bc78-3af8c1967021', 14, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19ab25fe-6b74-519c-a5c9-61f8e79a2294', '83465d28-0207-5cb2-bc78-3af8c1967021', 15, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53c3a2e5-22cb-50be-a8cc-fa41377777ae', '83465d28-0207-5cb2-bc78-3af8c1967021', 16, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9983a742-cf0a-58ed-a412-e82701712b12', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

QUESTIONS 1-7
QUESTIONS 1-7
Reading Passage 3 has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-ix, in boxes 1-7 on your answer sheet.
List of heading
i methods used to investigate termite mound formation
ii challenging our assumptions about the nature of life
iii reconsidering the termite’s reputation
iv principal functions of the termite mound
v distribution of termite mounds in sub-Saharan Africa
vi some potential benefits of understanding termite architecture
vii the astonishing physical dimensions of the termite mound
viii termite mounds under threat from global climate change
ix a mutually beneficial relationship
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
7
Paragraph G

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13e969d1-9075-5386-9bf6-f8a47fd34623', '9983a742-cf0a-58ed-a412-e82701712b12', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('338a01c7-5b34-5e57-a247-effc94f63644', '9983a742-cf0a-58ed-a412-e82701712b12', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b877c0aa-f8b7-5ead-9251-aef5fb10fc44', '9983a742-cf0a-58ed-a412-e82701712b12', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4261af21-28e4-5025-a1c4-a7994dbeadf6', '9983a742-cf0a-58ed-a412-e82701712b12', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce8b9ae2-8cab-525b-846a-af9362873155', '9983a742-cf0a-58ed-a412-e82701712b12', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd2cd6b7-f58b-5dea-b715-52d26097e4a3', '9983a742-cf0a-58ed-a412-e82701712b12', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7083b3f2-54e2-531f-9144-272b6fe0b92d', '9983a742-cf0a-58ed-a412-e82701712b12', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed493e1d-e86b-5105-9335-9374810a2deb', '9983a742-cf0a-58ed-a412-e82701712b12', 8, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86708188-ec0f-5167-a0a8-ed99cc50d099', '9983a742-cf0a-58ed-a412-e82701712b12', 9, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a318fc0-ba00-59a1-a0ee-aead445375f4', '9983a742-cf0a-58ed-a412-e82701712b12', 10, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebf531c7-8d53-55ee-a685-6026e690f327', '9983a742-cf0a-58ed-a412-e82701712b12', 11, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc1dc776-f82e-5017-8fa6-605e3a652209', '9983a742-cf0a-58ed-a412-e82701712b12', 12, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('016792ce-f9af-5820-9ea0-498f0235a44f', '9983a742-cf0a-58ed-a412-e82701712b12', 13, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd879b74-ea0b-579b-a55a-6eb672ed5e92', '9983a742-cf0a-58ed-a412-e82701712b12', 14, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea3c358f-2b6f-597e-a6f4-2aa349769a08', '9983a742-cf0a-58ed-a412-e82701712b12', 15, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55d1345e-fe9d-5e37-8ff6-ffc7f99f2f40', '9983a742-cf0a-58ed-a412-e82701712b12', 16, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e10d5ce-7701-5b11-bc6a-06459cf1007f', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

QUESTIONS 1-7
QUESTIONS 1-7
Reading Passage 3 has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-ix, in boxes 1-7 on your answer sheet.
List of heading
i methods used to investigate termite mound formation
ii challenging our assumptions about the nature of life
iii reconsidering the termite’s reputation
iv principal functions of the termite mound
v distribution of termite mounds in sub-Saharan Africa
vi some potential benefits of understanding termite architecture
vii the astonishing physical dimensions of the termite mound
viii termite mounds under threat from global climate change
ix a mutually beneficial relationship
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
7
Paragraph G

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99563499-7160-5dcd-bb0a-98ff18ee3e9d', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9afed68-08fa-56c1-a34c-fdd8cbeae4f1', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d38743d-2ed9-5b1a-9b85-87088bf4365a', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e84eea6a-8d62-523d-9809-5dd133738294', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('278d7606-723b-5016-a7c8-ed1fcd149854', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a04d98c-092b-5545-89e0-2e108b338cdd', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f08ecda7-c1be-5784-9f90-ff7ab57e68b6', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bf30fed-7981-58b0-bf3e-db1b6daa0077', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 8, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('392d199e-b254-57be-8554-967489d4d43a', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 9, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60b428d4-a229-5482-be47-fba228852711', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 10, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c19d961a-e739-58e3-b8f3-b4f68a306af6', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 11, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c98f522a-8ea1-56c8-8e0a-c1be99b6ca37', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 12, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f92aebff-549e-5262-b598-ab15bc96e8c9', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 13, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8b51585-b4f2-5235-8932-12513c5d2174', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 14, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e09b85c-5e44-5484-bdab-8b59166f703b', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 15, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79e24b15-248f-5beb-a750-1eb8f75716dc', '6e10d5ce-7701-5b11-bc6a-06459cf1007f', 16, $md$ix$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('59791678-5383-560f-8cbc-22d05276e84a', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

QUESTIONS 1-7
QUESTIONS 1-7
Reading Passage 3 has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-ix, in boxes 1-7 on your answer sheet.
List of heading
i methods used to investigate termite mound formation
ii challenging our assumptions about the nature of life
iii reconsidering the termite’s reputation
iv principal functions of the termite mound
v distribution of termite mounds in sub-Saharan Africa
vi some potential benefits of understanding termite architecture
vii the astonishing physical dimensions of the termite mound
viii termite mounds under threat from global climate change
ix a mutually beneficial relationship
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
7
Paragraph G

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d76b9d14-8431-56f4-9c84-f24f8d32db7d', '59791678-5383-560f-8cbc-22d05276e84a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d6fb288-aeb4-55bf-84ea-156e395ff7f2', '59791678-5383-560f-8cbc-22d05276e84a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78bf40e9-0fb2-58ea-83d2-54d459f29665', '59791678-5383-560f-8cbc-22d05276e84a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83a08bc2-1de1-5673-a9da-a3d2e756f335', '59791678-5383-560f-8cbc-22d05276e84a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d08360a3-d7ac-5760-b3f7-6265e7c6bce0', '59791678-5383-560f-8cbc-22d05276e84a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('246b79a6-d7e6-553a-8374-0f52d0e914ad', '59791678-5383-560f-8cbc-22d05276e84a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5117a8e-2e8e-57bb-9f2d-42cb94f11941', '59791678-5383-560f-8cbc-22d05276e84a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f7e4863-0a35-5366-8a7f-04474fc23b10', '59791678-5383-560f-8cbc-22d05276e84a', 8, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('963cf3d1-cc91-5a1d-bf52-50f804e53efd', '59791678-5383-560f-8cbc-22d05276e84a', 9, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0582cb71-5d16-550f-a90a-fbad2fdbfa5f', '59791678-5383-560f-8cbc-22d05276e84a', 10, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1391e3c-eca3-52d7-92f1-fa1b8a8aacda', '59791678-5383-560f-8cbc-22d05276e84a', 11, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3870117-22af-57f8-b2f6-debb020badbe', '59791678-5383-560f-8cbc-22d05276e84a', 12, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6314264-80bd-54b5-91b8-6a68f707bca5', '59791678-5383-560f-8cbc-22d05276e84a', 13, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7406d54d-5622-5c37-aa4d-6e3309bacec4', '59791678-5383-560f-8cbc-22d05276e84a', 14, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a61f80ec-9ad0-59bc-9246-3055eb5613c1', '59791678-5383-560f-8cbc-22d05276e84a', 15, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97f83c9e-2622-5818-aec7-98a95a00d069', '59791678-5383-560f-8cbc-22d05276e84a', 16, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

QUESTIONS 1-7
QUESTIONS 1-7
Reading Passage 3 has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-ix, in boxes 1-7 on your answer sheet.
List of heading
i methods used to investigate termite mound formation
ii challenging our assumptions about the nature of life
iii reconsidering the termite’s reputation
iv principal functions of the termite mound
v distribution of termite mounds in sub-Saharan Africa
vi some potential benefits of understanding termite architecture
vii the astonishing physical dimensions of the termite mound
viii termite mounds under threat from global climate change
ix a mutually beneficial relationship
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
7
Paragraph G

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc12c960-8189-5e02-afc1-5f5f19219da6', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40e3d55a-4487-5fca-ae66-8255e9f34183', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('681aefbc-3868-5d11-9eca-84ca2a43f03d', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1136abd-b05b-5902-a28a-a5dab0ce3e01', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b751e91f-3e87-5d80-ad38-d1e75642a7ca', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5861c65-bd27-5e94-b1d8-5b92a6f3b738', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b42fc09e-970b-5521-b003-a3522d82fac3', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2926125e-ab99-5953-9ba0-71838126913e', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 8, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ac164c0-7ba3-52e4-a861-24312332539d', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 9, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5706da2e-df5b-58e0-baf3-32690905f38c', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 10, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68dca302-577f-5b37-96cc-11f554dd2b4f', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 11, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2e4c4b7-91a5-5f99-91a0-a22dd580bacc', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 12, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('236637d1-61c0-5b2a-8022-896be0736913', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 13, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08c880ba-62b5-532e-8486-92d56ac0c75d', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 14, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c3f3828-674a-5f74-b227-b56c2d99a7fc', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 15, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bed1f08-138c-5d12-8ff5-822453b5ae24', '6367ca8e-9b08-5bc1-9cb5-07247d44e7ce', 16, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e4be1ca4-0e01-563f-8cea-5e86070d5add', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

QUESTIONS 1-7
QUESTIONS 1-7
Reading Passage 3 has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-ix, in boxes 1-7 on your answer sheet.
List of heading
i methods used to investigate termite mound formation
ii challenging our assumptions about the nature of life
iii reconsidering the termite’s reputation
iv principal functions of the termite mound
v distribution of termite mounds in sub-Saharan Africa
vi some potential benefits of understanding termite architecture
vii the astonishing physical dimensions of the termite mound
viii termite mounds under threat from global climate change
ix a mutually beneficial relationship
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
7
Paragraph G

7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7359df29-0165-5c4c-a7a0-7abe53595ce2', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d0f6564-87b4-547d-b725-7a293c10ecce', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('019c24f4-a180-5277-9eb3-c67c73b8a550', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5296552e-90b8-5966-8778-caef6e7f6c30', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d80d990c-b582-595d-8908-6fb931083adc', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26a8b135-4954-511f-ad55-e10e714bd668', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2eb39e09-9f98-58bd-b9b9-db9560c978c2', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce910fd8-a818-5fac-8944-c22f9b504a74', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 8, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00c29938-1339-5adf-a0e2-ac6630af9554', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 9, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d77aa22-1b50-546c-b8d2-61f6f2ef8077', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 10, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5270e146-37db-54c2-9eb5-6569576718e3', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 11, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c54994b6-6753-534f-a45a-65699f3e71f0', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 12, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a083894-d6a1-5344-aa33-b5fc17426289', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 13, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('292a3fe4-09ac-5eea-a148-687ecb3c11f9', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 14, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c8d92df-9077-5763-8763-f573d5ee7ba5', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 15, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9169ce3c-d5d7-57be-99a6-29f0a687485b', 'e4be1ca4-0e01-563f-8cea-5e86070d5add', 16, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('73726ebd-c903-5f5c-b63b-7aa53087024b', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

QUESTIONS 8-11
QUESTIONS 8-11
Label the diagram below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 8-11 on your answer sheet.
network of
8
helps to give the termites a constant
9
supply and to maintain a limited temperature range
cellar to aid control of
10
levels in mound
top of the mound permits
11

network of 8 ____ helps to give the termites a constant$md$, NULL, ARRAY['.*tunnels.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3acc58d8-f68b-5b2e-992b-8909b3bc9774', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

QUESTIONS 8-11
QUESTIONS 8-11
Label the diagram below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 8-11 on your answer sheet.
network of
8
helps to give the termites a constant
9
supply and to maintain a limited temperature range
cellar to aid control of
10
levels in mound
top of the mound permits
11

9 ____ supply and to maintain a limited temperature range$md$, NULL, ARRAY['.*air.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fc40b147-f661-5b00-9b01-e78bc0ff6e8e', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

QUESTIONS 8-11
QUESTIONS 8-11
Label the diagram below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 8-11 on your answer sheet.
network of
8
helps to give the termites a constant
9
supply and to maintain a limited temperature range
cellar to aid control of
10
levels in mound
top of the mound permits
11

cellar to aid control of 10 ____ levels in mound$md$, NULL, ARRAY['.*moisture.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5ffd2cba-4f35-5f0d-8a87-6fb2df68fbc6', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

QUESTIONS 8-11
QUESTIONS 8-11
Label the diagram below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 8-11 on your answer sheet.
network of
8
helps to give the termites a constant
9
supply and to maintain a limited temperature range
cellar to aid control of
10
levels in mound
top of the mound permits
11

top of the mound permits 11 ____$md$, NULL, ARRAY['.*evaporation.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5019926d-d1f9-50cd-810c-ce57673c1dca', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

QUESTIONS 12-14
QUESTIONS 12-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 12-14 on your sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts with the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
12
The termite mound appears to process its refuse material internally.
13
Dr Soar’s reconstruction involves scanning a single photograph of a complete mound into acomputer.
14
New information about termite architecture could help people deal with future energy crises.

12 ____ The termite mound appears to process its refuse material internally.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0e20bbf-46a5-589a-90d5-76c2379d2728', '5019926d-d1f9-50cd-810c-ce57673c1dca', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d956835-9ea4-5276-92ef-02d043e5be39', '5019926d-d1f9-50cd-810c-ce57673c1dca', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5fc16c7-2f72-59a5-aa4f-0385bedbb1ad', '5019926d-d1f9-50cd-810c-ce57673c1dca', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b93e7983-485f-567d-a132-ff302864b51c', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

QUESTIONS 12-14
QUESTIONS 12-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 12-14 on your sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts with the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
12
The termite mound appears to process its refuse material internally.
13
Dr Soar’s reconstruction involves scanning a single photograph of a complete mound into acomputer.
14
New information about termite architecture could help people deal with future energy crises.

13 ____ Dr Soar’s reconstruction involves scanning a single photograph of a complete mound into acomputer.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bff44e3-faa5-5002-a9f0-1a600d6cdb24', 'b93e7983-485f-567d-a132-ff302864b51c', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67f70509-997f-5220-beb7-b4174ea7763c', 'b93e7983-485f-567d-a132-ff302864b51c', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0e6d5ea-ce59-5563-8954-7fe58888e54b', 'b93e7983-485f-567d-a132-ff302864b51c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d3fb185b-342d-5b36-ac33-27024935fe32', 'f74ab4f3-bbf4-547b-8171-6c5f4ba071d9', 14, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 14

QUESTIONS 12-14
QUESTIONS 12-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 12-14 on your sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts with the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
12
The termite mound appears to process its refuse material internally.
13
Dr Soar’s reconstruction involves scanning a single photograph of a complete mound into acomputer.
14
New information about termite architecture could help people deal with future energy crises.

14 ____ New information about termite architecture could help people deal with future energy crises.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4adde712-f5d9-52a8-ab7c-a84f1c3eddb7', 'd3fb185b-342d-5b36-ac33-27024935fe32', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4335419-50ad-5518-ab23-855f9079b60f', 'd3fb185b-342d-5b36-ac33-27024935fe32', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fcc1d7e-cf97-56dc-b054-43269e3f1ab1', 'd3fb185b-342d-5b36-ac33-27024935fe32', 3, $md$NOT GIVEN$md$, true);

COMMIT;
