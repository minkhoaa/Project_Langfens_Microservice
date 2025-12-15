BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-build-a-medieval-castle-1250'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-build-a-medieval-castle-1250';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-build-a-medieval-castle-1250';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-build-a-medieval-castle-1250';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('7f9acdca-0af4-51b0-a62f-d9832120b37d', 'ielts-reading-build-a-medieval-castle-1250', $t$Build a Medieval Castle$t$, $md$## Build a Medieval Castle

Nguồn:
- Test: https://mini-ielts.com/1250/reading/build-a-medieval-castle
- Solution: https://mini-ielts.com/1250/view-solution/reading/build-a-medieval-castle$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('ef26310f-ab10-5b32-aea5-548cae35b590', '7f9acdca-0af4-51b0-a62f-d9832120b37d', 1, $t$Reading — Build a Medieval Castle$t$, $md$Read the passage and answer questions **1–10**.

### Passage: Build a Medieval Castle

A. Michel Guyot, owner and restorer of Saint Fargeau castle in France, first had the idea of building a 13th-century style fortress following the discovery that the 15th-century red bricks of his castle obscured the stone walls of a much older stronghold. His dream was to build a castle just as it would have been in the Middle Ages, an http://www.bo.com/iclti9 idea which some found mildly amusing and others dismissed as outright folly.

However, Maryline Martin – project director – was inspired by the exciting potential for the venture to regenerate the region. It took several months to bring together and mobilise all the various different partners: architects, archaeologists and financial backers. A site in the heart of Guédelon forest was found: a site which offered not only all the resources required for building a castle – a stone quarry, an oak forest and a water supply – but in sufficient quantities to satisfy the demands of this gigantic site. The first team started work and on June 20th 1997 the first stone was laid.

B . Unlike any other present-day building site, Michel Guyot’s purpose is clear, he warmly welcomes members of the public to participate. The workers’ role is to demonstrate and explain, to a wide audience, the skills of our forefathers. Stone quarrying, the building of vaulted ceilings, the blacksmith’s work and the raising of roof timbers are just some of the activities which visitors can witness during a visit to Guédelon. The workers are always on hand to talk about their craft and the progress of the castle.

Each year 60,000 children visit Guédelon with their schools. The site is an excellent educational resource, bringing to life the history of the Middle Ages. Guided tours are tailored to the school curriculum and according to age groups: activity trails for primary school children and interactive guided tours for secondary school children. Pupils of all ages have the opportunity to follow in the footsteps of medieval stonemasons by taking part in a stonecarving workshop or discover the secrets of the medieval master-builders at the geometry workshop.

C . Workers in the Burgundy region of France are building a 13th century castle. They’re not restoring an old castle. They’re actually building a new old castle. See the builders are constructing it from scratch. The craftsmen have been working for nearly ten years now but they’re not even halfway done yet. That’s because they’re using only medieval tools and techniques. The World’s Gerry Hadden takes US to the site of what will be the Guedelon Castle. Another reason said by Jean Francois, a member of Guedelon stone cutter’s guild, for eight hours a day he bangs on a 13th century chisel with a 13th century iron mallet.

D . The progress of construction has to give way to tourists side for their visits. The visitors from 2010, however unsightly they may be, are vital to the project. The initial funding came not from pillaging the local peasantry but from regional councils, the European Union and large companies. For the last 10 years, Guédelon, 100 miles southeast of Paris, has funded itself from its entrance fees. Last year it had a record 300,000 visitors, who paid almost €2.5m, making it the second most-visited site in Burgundy. The most visited site was the Hospice de Beaune, a beautiful 15th-century almshouse built 600 years before, or, if you prefer, 200 years “after”, Guédelon.

E . limestone is found in the construction of various local buildings, from the great and prestigious edifice of Ratilly castle to the more modest poyaudines houses. This stone contains 30-40% iron oxide; this can make it extremely hard to extract and dress. Having studied the block in order to determine and anticipate the natural fault lines of the stone, the quarrymen first carve a series of rectilinear holes into the block. Iron wedges are then hammered into this line of holes. The shockwaves produced by the quarrymen’s sledgehammers cause the stone to split along a straight line.

The highest quality blocks are dressed to produce lintels, voussoirs, corbels, ashlars etc. The medium quality blocks are roughly shaped by the stonecutters and used on the uncoursed curtain walls, and as facing stones on the castle’s inner walls. There are water-filled clay pits in the forest. Clay is taken from these pits, cleaned and pugged. It is then shaped in wooden moulds to form bricks. After the bricks have been left to air-dry, they are fired in a woodfired kiln for about 12 hours, at roughly 1000°c.

F. The mortar is the “glue” used to bind the castle’s stones. It is made up of precise doses of lime, sand and water. The people working there wear the tunics, skirts and headgear that they might have worn then, but they wear these over jeans and shoes with reinforced toes. They mix their mortar primarily as they would have done then, using sand they dig themselves, but they are not allowed to use the extremely effective hot lime from medieval days, because of its toxicity, and so they add a modem chemical ingredient instead, to achieve the same effect.

Workers in the Mid Age obviously were unaware of it and some died earlier by inhaling toxic gas. And so, we met many wonderful people who do not pretend to be anything but modem human beings practicing an old technique and finding out what it would have felt like, as much as possible, to do it with only the resources of an older time.

G . We also learned that even if there is a straight lintel across a doorway, you will usually find an arch of stones built into the wall differently. Because of the physics of an arch, which channels the weight above it down into whatever is supporting it at each side instead of pressing down in the middle, this helps to take a lot of the weight off of the lintel itself, whether it is free standing or buried in the wall against the impact of warfare. The arch is the strongest element for spanning space in stone architecture. This is why, in ancient ruins, you will often find the entire wall missing, and the arched windows and doorways still standing, in beautiful patterns against the sky$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e25be07d-c981-512f-9807-f97831b0d1ee', 'ef26310f-ab10-5b32-aea5-548cae35b590', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes 1-4 on your answer sheet, write
TRUE if the Statement is true
FALSE if the statement is false
NOT GIVEN if the information is not given in the passage
1
The French people would not abandon his idea in favor of realistic one.
2
One aim of the castle is to show the ancestral achievement to public.
3
Short lifespan of workers was due to overdue heating.
4
stones were laid not in a straight line arrangement to avoid damaging or collapsing.

1 ____ The French people would not abandon his idea in favor of realistic one.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('221a8e83-85a8-5ebb-acc0-0e4b1aec6392', 'e25be07d-c981-512f-9807-f97831b0d1ee', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('087f2502-ab2e-533b-87c4-5b02016b5c97', 'e25be07d-c981-512f-9807-f97831b0d1ee', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6452f3b2-78cf-5f46-9487-1262a45a9d93', 'e25be07d-c981-512f-9807-f97831b0d1ee', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5f081355-4b04-59ef-a966-1c8ab345bb91', 'ef26310f-ab10-5b32-aea5-548cae35b590', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes 1-4 on your answer sheet, write
TRUE if the Statement is true
FALSE if the statement is false
NOT GIVEN if the information is not given in the passage
1
The French people would not abandon his idea in favor of realistic one.
2
One aim of the castle is to show the ancestral achievement to public.
3
Short lifespan of workers was due to overdue heating.
4
stones were laid not in a straight line arrangement to avoid damaging or collapsing.

2 ____ One aim of the castle is to show the ancestral achievement to public.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('758edd75-70d9-5b79-a7d8-0f46014b0d2b', '5f081355-4b04-59ef-a966-1c8ab345bb91', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b98744e-638f-5ce5-ae4d-9922593d64b9', '5f081355-4b04-59ef-a966-1c8ab345bb91', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab5bc519-2a8b-5f1c-9136-15cbe5256f22', '5f081355-4b04-59ef-a966-1c8ab345bb91', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('26897bfd-0a2d-5537-83a5-ef4e3b0a9c47', 'ef26310f-ab10-5b32-aea5-548cae35b590', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes 1-4 on your answer sheet, write
TRUE if the Statement is true
FALSE if the statement is false
NOT GIVEN if the information is not given in the passage
1
The French people would not abandon his idea in favor of realistic one.
2
One aim of the castle is to show the ancestral achievement to public.
3
Short lifespan of workers was due to overdue heating.
4
stones were laid not in a straight line arrangement to avoid damaging or collapsing.

3 ____ Short lifespan of workers was due to overdue heating.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1dd1ba7-1bd3-547c-86ec-0917e39b2d91', '26897bfd-0a2d-5537-83a5-ef4e3b0a9c47', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f949ed99-48af-5abe-a3b0-c29e07c33875', '26897bfd-0a2d-5537-83a5-ef4e3b0a9c47', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('512e52a9-93bc-57f5-ac0f-50dfa8337f98', '26897bfd-0a2d-5537-83a5-ef4e3b0a9c47', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af986039-a6a0-5f5f-94d5-2c93e0e8ed9c', 'ef26310f-ab10-5b32-aea5-548cae35b590', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes 1-4 on your answer sheet, write
TRUE if the Statement is true
FALSE if the statement is false
NOT GIVEN if the information is not given in the passage
1
The French people would not abandon his idea in favor of realistic one.
2
One aim of the castle is to show the ancestral achievement to public.
3
Short lifespan of workers was due to overdue heating.
4
stones were laid not in a straight line arrangement to avoid damaging or collapsing.

4 ____ stones were laid not in a straight line arrangement to avoid damaging or collapsing.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23a7456e-8a59-55ed-ad50-e5ce88964cea', 'af986039-a6a0-5f5f-94d5-2c93e0e8ed9c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69ef5772-ea19-5c8e-922e-91535d08c2d8', 'af986039-a6a0-5f5f-94d5-2c93e0e8ed9c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77e46d6e-c194-58b5-b60b-c7ea98c9f42f', 'af986039-a6a0-5f5f-94d5-2c93e0e8ed9c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('315eafb5-a29a-5864-9156-64dcd902fda8', 'ef26310f-ab10-5b32-aea5-548cae35b590', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
A-L
from the following options for each answer.
Write your answers in boxes
5-10
on your answer sheet.
Limestone Processing
When
5
found suitable block, they began to cut lines of
6
into it.
7
were used and knocked into and generated shockwaves to make stone
8
. Different qualities of blocks would be used in different place of castle. On the other hand,
9
were shaped from clay in a mould and went through a process of
10
for about 12 hours.
A metal vedge
B hammer handle
C lift
D Masons
E patterns
F heating
G bricks
H wood
I experts
J split
K walls
L holes

When 5 ____ found suitable block, they began to cut lines of 6 ____ into it. 7 ____ were used and knocked into and generated shockwaves to make stone 8 ____ . Different qualities of blocks would be used in different place of castle. On the other hand, 9 ____ were shaped from clay in a mould and went through a process of 10 ____ for about 12 hours.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('839b5fcd-d7ac-5992-a183-39426cfe40d4', '315eafb5-a29a-5864-9156-64dcd902fda8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67156681-79f8-5829-9484-815f3689b2b1', '315eafb5-a29a-5864-9156-64dcd902fda8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5e399cc-cf6e-5096-8178-6bdf7bd09528', '315eafb5-a29a-5864-9156-64dcd902fda8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a357ebba-3b2f-51e7-b437-78abd75f0834', '315eafb5-a29a-5864-9156-64dcd902fda8', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbe90a94-50cd-5a33-99a9-12b35d55cf0c', '315eafb5-a29a-5864-9156-64dcd902fda8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed4d83ff-a022-5dc4-8a5d-9dc48117ec7a', '315eafb5-a29a-5864-9156-64dcd902fda8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4976379e-a693-5dad-ad8a-1317275525c1', '315eafb5-a29a-5864-9156-64dcd902fda8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32448cc5-6c1b-5c84-8053-e8012da0317b', '315eafb5-a29a-5864-9156-64dcd902fda8', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cd39a1d-39ce-5d5c-8f80-3a6c447edfb6', '315eafb5-a29a-5864-9156-64dcd902fda8', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a63d6d60-b943-53ba-ab33-a7a9938aff53', '315eafb5-a29a-5864-9156-64dcd902fda8', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddfb78a4-42dd-5c52-90bb-e64acc795fff', '315eafb5-a29a-5864-9156-64dcd902fda8', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8ff3ded-a2f2-5b52-ae35-6ce1ac65437f', '315eafb5-a29a-5864-9156-64dcd902fda8', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 'ef26310f-ab10-5b32-aea5-548cae35b590', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
A-L
from the following options for each answer.
Write your answers in boxes
5-10
on your answer sheet.
Limestone Processing
When
5
found suitable block, they began to cut lines of
6
into it.
7
were used and knocked into and generated shockwaves to make stone
8
. Different qualities of blocks would be used in different place of castle. On the other hand,
9
were shaped from clay in a mould and went through a process of
10
for about 12 hours.
A metal vedge
B hammer handle
C lift
D Masons
E patterns
F heating
G bricks
H wood
I experts
J split
K walls
L holes

When 5 ____ found suitable block, they began to cut lines of 6 ____ into it. 7 ____ were used and knocked into and generated shockwaves to make stone 8 ____ . Different qualities of blocks would be used in different place of castle. On the other hand, 9 ____ were shaped from clay in a mould and went through a process of 10 ____ for about 12 hours.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b3a087e-3b47-5d8a-a3c3-c704b83299df', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea4d444d-c814-57d9-8672-fbe988b113d3', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe1adc6d-9703-5834-a852-b455d1531b48', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('642ff14f-4169-5b28-914c-2c1bbf350433', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8f8e981-f156-5361-b288-17667d347fee', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a44f069-6c10-5017-9138-8db904b3368b', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e00d35f3-5589-5fe0-a86d-fe546ac4ca11', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7c10ade-068f-555e-8c65-4254748665a5', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b97867a9-b775-5059-94e3-dbb539af649c', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09d2b964-4129-546a-acfb-7dfc45a0e980', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09b8cf60-a93b-5379-ac7d-582cbc75ec04', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('734ac5a1-eb6d-5cff-9596-ed04d3d84d2d', '8645c93e-d78d-5c13-90b7-4aa80ec3bbfa', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('48b7823f-f64d-5c23-a718-57be4347f451', 'ef26310f-ab10-5b32-aea5-548cae35b590', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
A-L
from the following options for each answer.
Write your answers in boxes
5-10
on your answer sheet.
Limestone Processing
When
5
found suitable block, they began to cut lines of
6
into it.
7
were used and knocked into and generated shockwaves to make stone
8
. Different qualities of blocks would be used in different place of castle. On the other hand,
9
were shaped from clay in a mould and went through a process of
10
for about 12 hours.
A metal vedge
B hammer handle
C lift
D Masons
E patterns
F heating
G bricks
H wood
I experts
J split
K walls
L holes

When 5 ____ found suitable block, they began to cut lines of 6 ____ into it. 7 ____ were used and knocked into and generated shockwaves to make stone 8 ____ . Different qualities of blocks would be used in different place of castle. On the other hand, 9 ____ were shaped from clay in a mould and went through a process of 10 ____ for about 12 hours.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7edb100e-260d-52a5-bbd8-baaf35120eb0', '48b7823f-f64d-5c23-a718-57be4347f451', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e037ff6-2716-5066-a7cb-8f6b86afca46', '48b7823f-f64d-5c23-a718-57be4347f451', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('194878c1-6c16-58f5-bb56-727848ba8a78', '48b7823f-f64d-5c23-a718-57be4347f451', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6fdd353-e05b-537a-a36b-79a6f6a954ab', '48b7823f-f64d-5c23-a718-57be4347f451', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1c28d7a-a678-50ed-9062-110b0ff098ec', '48b7823f-f64d-5c23-a718-57be4347f451', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc43b37c-f954-54d3-b94f-ad79535d6993', '48b7823f-f64d-5c23-a718-57be4347f451', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcdee9ab-23e8-5c70-8141-7bf79175ab3b', '48b7823f-f64d-5c23-a718-57be4347f451', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f494528b-5ef4-539b-9211-fd0f6a6b101f', '48b7823f-f64d-5c23-a718-57be4347f451', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c06dbabb-8ecb-5bbd-ae1a-2d8af1089501', '48b7823f-f64d-5c23-a718-57be4347f451', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40c017c9-13b7-5fa4-a7ea-fc4da82f48a5', '48b7823f-f64d-5c23-a718-57be4347f451', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b6853ef-9df3-5dcf-9176-35b7bd8ae6d4', '48b7823f-f64d-5c23-a718-57be4347f451', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d5b3a6a-1997-5793-83f0-f70bca6edaff', '48b7823f-f64d-5c23-a718-57be4347f451', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 'ef26310f-ab10-5b32-aea5-548cae35b590', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
A-L
from the following options for each answer.
Write your answers in boxes
5-10
on your answer sheet.
Limestone Processing
When
5
found suitable block, they began to cut lines of
6
into it.
7
were used and knocked into and generated shockwaves to make stone
8
. Different qualities of blocks would be used in different place of castle. On the other hand,
9
were shaped from clay in a mould and went through a process of
10
for about 12 hours.
A metal vedge
B hammer handle
C lift
D Masons
E patterns
F heating
G bricks
H wood
I experts
J split
K walls
L holes

When 5 ____ found suitable block, they began to cut lines of 6 ____ into it. 7 ____ were used and knocked into and generated shockwaves to make stone 8 ____ . Different qualities of blocks would be used in different place of castle. On the other hand, 9 ____ were shaped from clay in a mould and went through a process of 10 ____ for about 12 hours.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('608c34eb-ba7e-5460-9b4f-99f103de6a39', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4d3e66a-6e2d-5289-b33e-ce3b6ea6d5ca', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f243f43-76c3-5a30-9e86-e4988b8a791c', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31b6bbf6-e0fa-5fec-bd09-049aea5b4599', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69be2e8e-bce9-535b-9105-0cab068fdb5a', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69a08792-6354-51a2-a9de-dd8cc14de63e', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46e2482c-4cb6-5d78-bead-84de495f147b', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c414ecf7-ced5-59d4-a84a-2813be9a8953', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b4b4530-2747-5885-8f3f-0d72da2d33a0', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92c994ab-4f11-5693-afaf-739e4f5e1abc', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2113787-990d-5949-9587-6460a2085b49', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53f38375-7db2-53ef-b879-cfaf11b326d4', '9c7fc8ce-7f1d-5d02-a9a9-1e34f93f5007', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f68a8e87-637c-59d3-ac73-df5bb3ce3298', 'ef26310f-ab10-5b32-aea5-548cae35b590', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
A-L
from the following options for each answer.
Write your answers in boxes
5-10
on your answer sheet.
Limestone Processing
When
5
found suitable block, they began to cut lines of
6
into it.
7
were used and knocked into and generated shockwaves to make stone
8
. Different qualities of blocks would be used in different place of castle. On the other hand,
9
were shaped from clay in a mould and went through a process of
10
for about 12 hours.
A metal vedge
B hammer handle
C lift
D Masons
E patterns
F heating
G bricks
H wood
I experts
J split
K walls
L holes

When 5 ____ found suitable block, they began to cut lines of 6 ____ into it. 7 ____ were used and knocked into and generated shockwaves to make stone 8 ____ . Different qualities of blocks would be used in different place of castle. On the other hand, 9 ____ were shaped from clay in a mould and went through a process of 10 ____ for about 12 hours.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb94e989-701a-504b-874d-8b66dc04488d', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('daff73fd-6d9c-544d-8f08-2a21735b32d9', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7386071-6154-5ffe-b284-69890bbb06bb', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f92338b-67a9-5a76-8611-b86ba6e3e0ac', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40e9b1e1-83ec-5ce9-ab6a-d8181fca1232', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dda8ce4c-1436-51a6-89e6-8f0b26338c22', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee71e224-1100-5cc3-934a-888bddff4a4a', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6293cb73-8f12-5d01-ac00-be1d6dbe3c8b', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e26d411-2b5f-58e7-b312-91f31109a789', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3a6d391-a124-5984-9b13-dffcc9612853', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a87590dd-fa65-5d8c-9c2d-f852df85b859', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7165a091-9ecb-5ada-8641-efb07db68c43', 'f68a8e87-637c-59d3-ac73-df5bb3ce3298', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('729b7456-fec6-56f0-b64d-2380728ab523', 'ef26310f-ab10-5b32-aea5-548cae35b590', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Complete the following summary of the paragraphs of Reading Passage, using
A-L
from the following options for each answer.
Write your answers in boxes
5-10
on your answer sheet.
Limestone Processing
When
5
found suitable block, they began to cut lines of
6
into it.
7
were used and knocked into and generated shockwaves to make stone
8
. Different qualities of blocks would be used in different place of castle. On the other hand,
9
were shaped from clay in a mould and went through a process of
10
for about 12 hours.
A metal vedge
B hammer handle
C lift
D Masons
E patterns
F heating
G bricks
H wood
I experts
J split
K walls
L holes

When 5 ____ found suitable block, they began to cut lines of 6 ____ into it. 7 ____ were used and knocked into and generated shockwaves to make stone 8 ____ . Different qualities of blocks would be used in different place of castle. On the other hand, 9 ____ were shaped from clay in a mould and went through a process of 10 ____ for about 12 hours.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f93c3bc9-83eb-5321-9f1c-9476ca083344', '729b7456-fec6-56f0-b64d-2380728ab523', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f321aa02-4331-5ef9-8f8f-c7ae8c066f53', '729b7456-fec6-56f0-b64d-2380728ab523', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fe842ea-4d8e-5f3e-b7a1-c26f5941d2f1', '729b7456-fec6-56f0-b64d-2380728ab523', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be71c162-13d4-53eb-b471-8e58040f096c', '729b7456-fec6-56f0-b64d-2380728ab523', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af0462ac-0ddc-5b6b-878d-04ead2cdbe87', '729b7456-fec6-56f0-b64d-2380728ab523', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39d18646-81bf-5de4-ad7b-140187396fae', '729b7456-fec6-56f0-b64d-2380728ab523', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a4b2959-14e6-5a3f-a9a7-7393319c41f9', '729b7456-fec6-56f0-b64d-2380728ab523', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0af7d935-75d1-57e6-ad66-306d9c3cbb73', '729b7456-fec6-56f0-b64d-2380728ab523', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05ceb7cc-5e72-5970-8b3f-30d9984572c1', '729b7456-fec6-56f0-b64d-2380728ab523', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39cd70e2-f04a-5fb3-8b15-4476414fca9d', '729b7456-fec6-56f0-b64d-2380728ab523', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cb759a8-672e-57b1-aa6f-85184ee92e47', '729b7456-fec6-56f0-b64d-2380728ab523', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9abeb5a-e8b8-5de1-84dc-c19fa7332dba', '729b7456-fec6-56f0-b64d-2380728ab523', 12, $md$L$md$, false);

COMMIT;
