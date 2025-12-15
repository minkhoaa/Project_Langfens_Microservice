BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-researcher-on-the-tree-crown-1396'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-researcher-on-the-tree-crown-1396';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-researcher-on-the-tree-crown-1396';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-researcher-on-the-tree-crown-1396';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('3d3a0ba3-5dd5-58e1-8834-1040e34cda8b', 'ielts-reading-researcher-on-the-tree-crown-1396', $t$Researcher on the Tree Crown$t$, $md$## Researcher on the Tree Crown

Nguồn:
- Test: https://mini-ielts.com/1396/reading/researcher-on-the-tree-crown
- Solution: https://mini-ielts.com/1396/view-solution/reading/researcher-on-the-tree-crown$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('17a11cdb-f287-5bfe-9fae-628d5572eaff', '3d3a0ba3-5dd5-58e1-8834-1040e34cda8b', 1, $t$Reading — Researcher on the Tree Crown$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Researcher on the Tree Crown

A

The forest canopy – the term given to the aggregated crowns of trees in a forest – is thought to host up to 40 per cent of all species, of which ten per cent could be unique to the forest roof. “We’re dealing with the richest, least known, most threatened habitat on Earth,” says Andrew Mitchell, the executive director of the Global Canopy Programme (GCP), a collection of groups undertaking research into this lofty world. “The problem with our understanding of forests is that nearly all the information we have has been gleaned from just two meters above the soil, and yet we’re dealing with trees that grow to heights of 60 meters, or in the case of the tallest redwood 112 meters. It’s like doctors trying to treat humans by only looking at their feet.”

B

Tropical rainforest comprises the richest of ecosystems, rivalled only by coral reel for its diversity and complex interrelationships. And a great deal of that diversity lives up in the canopy – an estimated 70-90 per cent of life in the rainforest exists in the trees; one in ten of all vascular plants are canopy dwellers, and about 20-25 per cent of all invertebrates are thought to be unique to the canopy.

C

The first Briton to actually get into the canopy may have been Sir Francis Drake who, in 1573, gained his first glimpse of the Pacific Ocean from a tall tree in Darien, Panama. However, the first serious effort to reach and study the canopy didn’t begin until 1929. The Oxford University Expedition to British Guiana, led by Major RWG Hingston, still ended up help of locals when it came to building an observation platform. It was a successful expedition all the same, despite the colony’s acting governor getting stuck high up on a winched seat during a visit. In terms of canopy access, the French have proved themselves to be excellent innovators, taking things further with the development of ‘lighter-than-air platforms -balloons and related equipment, to you and me. Francis Halle; from the Laboratoire de Botanique Tropicale at Montpellier University took to a balloon in the mid-1980s in order to approach the canopy from above. His work in French Guiana was inspired by the use in Gabon of a tethered helium balloon by Marcel and Annette Hladick. Halle went one further by using a small purpose-built airship-a cigar-shaped balloon with propellers to aid manoeuvrability. “We suddenly had a mobile system that could move around the treetops; there were no other means of doing this,” says Mitchell.

D

From this, two balloon-dependent features have developed: the radeau or raft, and the luge or sledge. The raft is a ‘floating’ platform, employed by French academics Dany Cleyet-Marrel and Laurent Pyot and is essentially an island in the treetops. Made of kevlar mesh netting and edged with inflated neoprene tubes, it rests on top of the canopy, allowing sampling (mostly of plants and insects) to take place at the edges of the platform, and can stay in position for several days. The luge, on the other hand, is an inflated hexagon similar to a traditional balloon basket but with a hole in the bottom covered with Kevlar mesh. Such techniques aren’t without their problems, however, “balloons can cover larger areas, especially for collection purposes, but they are extremely expensive- Jibe raft alone cost 122,000 [euro] (86,000 [pounds sterling]) in 2001], nut very effective because you can only reach the tops of the trees, and are highly dependent on the weather, ” says Dr Wilfried Morawetz, director of systematic botany at the University of Leipzig. “Balloons can usually only be used in the early morning for two to four hours. Last time, we could only fly three times during the whole week.” Given these factors, it comes as no surprise that operations involving these balloons numbered just six between 1986 and 2001.

E

Smithsonian Tropical Research Institute in Panama. Smith had the idea of using a static crane to get into the treetops. Un-tethered balloons may allow widely distributed sites to be sampled, but cranes allow scientists to study an area of at least a hectare from soil to canopy throughout the year, year after year. “Cranes beat any other access mode. They are cheap, reliable and fast. In two minutes I can reach any point in our forest, which is essential for comparative measurements across species,” says Professor Christian Korner of the University of Basel. Korner is using a static crane in a unique carbon dioxide-enrichment experiment in Switzerland, in an attempt to discover how forests might respond to the global increase in atmospheric carbon dioxide (see Swiss canopy-crane carbon experiment, right). For reasons of convenience, cranes are generally situated close to cities or a research center. Leipzig University has a crane not far from the town, the Location allowing scientists to study the effect of city pollutants on forests. In order to increase the amount of canopy a crane can access, some have been mounted on short rail tracks. In “1995, Dr Wilfried Morawetz was the first to use this technique, installing a crane on 150 meters of track in the Venezuelan rainforest. “In my opinion, cranes should be the core of canopy research in the future,” he says.

F

It appears that the rest of the scientific community has now come around to Mitchell’s way of thinking. “I think most scientists thought him mad to consider such a complex field station at first,” says internationally respected ‘canopist’ Meg Lowman, the executive director of the Marie Selby Botanical Gardens. “However, we’ve all come to realize that a combination of methods, a long-term approach to ecological studies and a collaborative approach are the absolute best ways to advance canopy science. A permanent canopy field station would allow that to happen.” With A dedicated group of canopy scientists working together and a wide range of tools available for them to get into the treetops, we’re now finally on our way towards a true understanding of the least-known terrestrial habitat.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b544b5ec-5fbc-502e-8570-030417fd6723', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
, in boxes
1-5
on your answer sheet
1
The Scientific significance for committing canopy study.
2
The first academic research attempt mentioned to getting the top canopy.
3
The overview idea of the forest canopy and the problem of understanding the forests.
4
Recognition for a long term effect and cooperation.
5
An innovation accessing to treetop which proved to be an ultimate solution till now.

1 ____ The Scientific significance for committing canopy study.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17a492f5-2215-5072-b5b9-b90bcad2f498', 'b544b5ec-5fbc-502e-8570-030417fd6723', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd611342-3580-5b6e-8a9f-04a81cc7de5e', 'b544b5ec-5fbc-502e-8570-030417fd6723', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41dcc593-e533-5edf-bc17-62aac8370b05', 'b544b5ec-5fbc-502e-8570-030417fd6723', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6014924-ac37-5289-a887-6f3f6c7b6bfc', 'b544b5ec-5fbc-502e-8570-030417fd6723', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('324aa5ca-b98e-5bf1-ba44-1b6ffbf7a0d3', 'b544b5ec-5fbc-502e-8570-030417fd6723', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b56d282-bd55-5430-8af7-123dba2e2c46', 'b544b5ec-5fbc-502e-8570-030417fd6723', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('24517e8f-afae-5f00-af20-a98128664547', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
, in boxes
1-5
on your answer sheet
1
The Scientific significance for committing canopy study.
2
The first academic research attempt mentioned to getting the top canopy.
3
The overview idea of the forest canopy and the problem of understanding the forests.
4
Recognition for a long term effect and cooperation.
5
An innovation accessing to treetop which proved to be an ultimate solution till now.

2 ____ The first academic research attempt mentioned to getting the top canopy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88808124-2db4-58be-836b-dd2c7180e26d', '24517e8f-afae-5f00-af20-a98128664547', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2af75bd-fd55-5cae-a5fc-6236f5bf7e4b', '24517e8f-afae-5f00-af20-a98128664547', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da4548a1-4957-5391-b395-69cd1e73586d', '24517e8f-afae-5f00-af20-a98128664547', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e726eed-9a7f-5777-bec1-a0fbb7cd6667', '24517e8f-afae-5f00-af20-a98128664547', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59411bc0-2698-58c4-b7c7-46bc9bbb7f30', '24517e8f-afae-5f00-af20-a98128664547', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b386fb76-9c52-5a44-a829-57bd4d3fde82', '24517e8f-afae-5f00-af20-a98128664547', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0559d4cd-cb2a-5ac1-9b55-bfce7be0baf6', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
, in boxes
1-5
on your answer sheet
1
The Scientific significance for committing canopy study.
2
The first academic research attempt mentioned to getting the top canopy.
3
The overview idea of the forest canopy and the problem of understanding the forests.
4
Recognition for a long term effect and cooperation.
5
An innovation accessing to treetop which proved to be an ultimate solution till now.

3 ____ The overview idea of the forest canopy and the problem of understanding the forests.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db7b9b17-dced-5261-9dfd-ed37abe4ac56', '0559d4cd-cb2a-5ac1-9b55-bfce7be0baf6', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bd5dd27-4194-53a3-8278-4464d990988f', '0559d4cd-cb2a-5ac1-9b55-bfce7be0baf6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4c368ab-4c44-540c-9f27-626166a1c28b', '0559d4cd-cb2a-5ac1-9b55-bfce7be0baf6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53f8c086-2d26-5908-b01b-42e203220eaa', '0559d4cd-cb2a-5ac1-9b55-bfce7be0baf6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('765413fd-c4dc-5642-9bc1-f69a4635c1e4', '0559d4cd-cb2a-5ac1-9b55-bfce7be0baf6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bacec78-f191-5b9f-a485-76b4f1283398', '0559d4cd-cb2a-5ac1-9b55-bfce7be0baf6', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1fdd789-ea42-5359-b18b-f8918c09615e', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
, in boxes
1-5
on your answer sheet
1
The Scientific significance for committing canopy study.
2
The first academic research attempt mentioned to getting the top canopy.
3
The overview idea of the forest canopy and the problem of understanding the forests.
4
Recognition for a long term effect and cooperation.
5
An innovation accessing to treetop which proved to be an ultimate solution till now.

4 ____ Recognition for a long term effect and cooperation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f3195d4-17fc-57a7-b159-83e852d48bd1', 'e1fdd789-ea42-5359-b18b-f8918c09615e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18c16048-fa4f-500b-b161-9b4b5c20ffbb', 'e1fdd789-ea42-5359-b18b-f8918c09615e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7811fb6-9264-5c88-923e-d6f619760d5a', 'e1fdd789-ea42-5359-b18b-f8918c09615e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('911add82-ad11-5676-88e2-5a22faf0b6bc', 'e1fdd789-ea42-5359-b18b-f8918c09615e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c802249-1d51-5219-b69c-b5a05d25872b', 'e1fdd789-ea42-5359-b18b-f8918c09615e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d9a5434-cc52-596a-89ad-ca9b7a62482a', 'e1fdd789-ea42-5359-b18b-f8918c09615e', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('45ecf81e-a791-50ba-ac56-1d46359da2d1', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
, in boxes
1-5
on your answer sheet
1
The Scientific significance for committing canopy study.
2
The first academic research attempt mentioned to getting the top canopy.
3
The overview idea of the forest canopy and the problem of understanding the forests.
4
Recognition for a long term effect and cooperation.
5
An innovation accessing to treetop which proved to be an ultimate solution till now.

5 ____ An innovation accessing to treetop which proved to be an ultimate solution till now.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('864d8e3e-1633-5233-91ed-44dd145e5aa0', '45ecf81e-a791-50ba-ac56-1d46359da2d1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2d9351b-0889-5136-923e-ce06e430af12', '45ecf81e-a791-50ba-ac56-1d46359da2d1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d42da67-5ccc-50f9-8eb4-4b5a93ca87ab', '45ecf81e-a791-50ba-ac56-1d46359da2d1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7185e30a-fa46-5f83-af14-e7c39d552e0b', '45ecf81e-a791-50ba-ac56-1d46359da2d1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b12e1e01-d7a4-5eb3-90bb-a5de35ced454', '45ecf81e-a791-50ba-ac56-1d46359da2d1', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('217eb985-9850-5293-8d31-70f2b8007d15', '45ecf81e-a791-50ba-ac56-1d46359da2d1', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f2f14f0f-99cb-512c-a54a-5df0cfd86687', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
Scientists keep trying new methods to access to the canopy of the treetop. Though early attempt succeeded in building an observation platform yet the help from the
6
was imperative; further innovators made by the French who built a platform with equipment by using
7
. Later, the ‘floating’ platform of
8
is serving as an island in the treetops. Then finally, there came the next major breakthrough in Panama. Scientists applied
9
to access to the treetops, which are proved to be the center of canopy research in today and in the future.

Scientists keep trying new methods to access to the canopy of the treetop. Though early attempt succeeded in building an observation platform yet the help from the 6 ____ was imperative; further innovators made by the French who built a platform with equipment by using 7 ____ . Later, the ‘floating’ platform of 8 ____ is serving as an island in the treetops. Then finally, there came the next major breakthrough in Panama. Scientists applied 9 ____ to access to the treetops, which are proved to be the center of canopy research in today and in the future.$md$, NULL, ARRAY['.*locals.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1a21994e-8015-5a45-b88f-b073c85ab1b7', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
Scientists keep trying new methods to access to the canopy of the treetop. Though early attempt succeeded in building an observation platform yet the help from the
6
was imperative; further innovators made by the French who built a platform with equipment by using
7
. Later, the ‘floating’ platform of
8
is serving as an island in the treetops. Then finally, there came the next major breakthrough in Panama. Scientists applied
9
to access to the treetops, which are proved to be the center of canopy research in today and in the future.

Scientists keep trying new methods to access to the canopy of the treetop. Though early attempt succeeded in building an observation platform yet the help from the 6 ____ was imperative; further innovators made by the French who built a platform with equipment by using 7 ____ . Later, the ‘floating’ platform of 8 ____ is serving as an island in the treetops. Then finally, there came the next major breakthrough in Panama. Scientists applied 9 ____ to access to the treetops, which are proved to be the center of canopy research in today and in the future.$md$, NULL, ARRAY['.*locals.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8eff82c4-4200-573e-b9bd-ecc7471bf9f8', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
Scientists keep trying new methods to access to the canopy of the treetop. Though early attempt succeeded in building an observation platform yet the help from the
6
was imperative; further innovators made by the French who built a platform with equipment by using
7
. Later, the ‘floating’ platform of
8
is serving as an island in the treetops. Then finally, there came the next major breakthrough in Panama. Scientists applied
9
to access to the treetops, which are proved to be the center of canopy research in today and in the future.

Scientists keep trying new methods to access to the canopy of the treetop. Though early attempt succeeded in building an observation platform yet the help from the 6 ____ was imperative; further innovators made by the French who built a platform with equipment by using 7 ____ . Later, the ‘floating’ platform of 8 ____ is serving as an island in the treetops. Then finally, there came the next major breakthrough in Panama. Scientists applied 9 ____ to access to the treetops, which are proved to be the center of canopy research in today and in the future.$md$, NULL, ARRAY['.*locals.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f31cf80a-b496-534d-b262-d98820c39d76', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
Scientists keep trying new methods to access to the canopy of the treetop. Though early attempt succeeded in building an observation platform yet the help from the
6
was imperative; further innovators made by the French who built a platform with equipment by using
7
. Later, the ‘floating’ platform of
8
is serving as an island in the treetops. Then finally, there came the next major breakthrough in Panama. Scientists applied
9
to access to the treetops, which are proved to be the center of canopy research in today and in the future.

Scientists keep trying new methods to access to the canopy of the treetop. Though early attempt succeeded in building an observation platform yet the help from the 6 ____ was imperative; further innovators made by the French who built a platform with equipment by using 7 ____ . Later, the ‘floating’ platform of 8 ____ is serving as an island in the treetops. Then finally, there came the next major breakthrough in Panama. Scientists applied 9 ____ to access to the treetops, which are proved to be the center of canopy research in today and in the future.$md$, NULL, ARRAY['.*locals.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('223a5dda-6a2b-50b7-a8d1-1558b60adeca', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 10, 'CLASSIFICATION', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Use the information in the passage to match the category (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
10-14
on your answer sheet.
NB
You may use any letter more than once
A
Sir Francis Drake
B
Wilfried Morawetz
C
Dany Cleyet-Marrel
D
Francis Halle
E
Christian Korner
F
Alan Smith
10
Scientist whose work was inspired by the method used by other researchers.
11
Scientist who made a claim that a balloon could only be used in a limited frequency or time.
12
Scientist who initiated a successful access mode which is cheap and stable.
13
Scientist who had committed canopy-crane experiment for a specific scientific project.
14
Scientist who initiated the use of crane on the short rail tracks.

10 ____ Scientist whose work was inspired by the method used by other researchers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03032b72-941e-5b14-a10e-d0513d8cdd32', '223a5dda-6a2b-50b7-a8d1-1558b60adeca', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8b1917a-bfbe-5d6d-a064-9709fcbaa4b9', '223a5dda-6a2b-50b7-a8d1-1558b60adeca', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4b8169b-611f-5b36-8860-6f50baf347f3', '223a5dda-6a2b-50b7-a8d1-1558b60adeca', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('966b2af2-75b4-5750-bb96-3c538f66c0f2', '223a5dda-6a2b-50b7-a8d1-1558b60adeca', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63c1c3fa-5c42-5c21-b7b0-118ea7d0a725', '223a5dda-6a2b-50b7-a8d1-1558b60adeca', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('187b3ed3-e3fb-5aba-b3e1-6e9ddae03af5', '223a5dda-6a2b-50b7-a8d1-1558b60adeca', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('769df23f-5213-549a-a0b8-35aa5b6db04f', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 11, 'CLASSIFICATION', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Use the information in the passage to match the category (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
10-14
on your answer sheet.
NB
You may use any letter more than once
A
Sir Francis Drake
B
Wilfried Morawetz
C
Dany Cleyet-Marrel
D
Francis Halle
E
Christian Korner
F
Alan Smith
10
Scientist whose work was inspired by the method used by other researchers.
11
Scientist who made a claim that a balloon could only be used in a limited frequency or time.
12
Scientist who initiated a successful access mode which is cheap and stable.
13
Scientist who had committed canopy-crane experiment for a specific scientific project.
14
Scientist who initiated the use of crane on the short rail tracks.

11 ____ Scientist who made a claim that a balloon could only be used in a limited frequency or time.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('557cb43e-e793-50a0-a90f-87a7094c7f8b', '769df23f-5213-549a-a0b8-35aa5b6db04f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0f377e9-f526-5469-a87c-7cc829b7b0cf', '769df23f-5213-549a-a0b8-35aa5b6db04f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('282e859f-9136-5b73-ba99-22c6e9c36515', '769df23f-5213-549a-a0b8-35aa5b6db04f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f0744ba-824b-557e-a197-23267f586ef0', '769df23f-5213-549a-a0b8-35aa5b6db04f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80f203b7-4a60-53bd-9eac-15e17f9b8072', '769df23f-5213-549a-a0b8-35aa5b6db04f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ef5c830-63a8-5b36-bd7c-a38dedc3e635', '769df23f-5213-549a-a0b8-35aa5b6db04f', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ef328756-1834-5dd0-ac72-1991d3018398', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 12, 'CLASSIFICATION', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Use the information in the passage to match the category (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
10-14
on your answer sheet.
NB
You may use any letter more than once
A
Sir Francis Drake
B
Wilfried Morawetz
C
Dany Cleyet-Marrel
D
Francis Halle
E
Christian Korner
F
Alan Smith
10
Scientist whose work was inspired by the method used by other researchers.
11
Scientist who made a claim that a balloon could only be used in a limited frequency or time.
12
Scientist who initiated a successful access mode which is cheap and stable.
13
Scientist who had committed canopy-crane experiment for a specific scientific project.
14
Scientist who initiated the use of crane on the short rail tracks.

12 ____ Scientist who initiated a successful access mode which is cheap and stable.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c791aee5-9e39-5a2c-9294-4dbb6bfc2634', 'ef328756-1834-5dd0-ac72-1991d3018398', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de5d31cc-735d-5941-9e22-e57dbc9570f1', 'ef328756-1834-5dd0-ac72-1991d3018398', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cd8a042-4bce-5340-b44b-f0da36183781', 'ef328756-1834-5dd0-ac72-1991d3018398', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a82b8c1-84ce-5e01-99f0-a9e8aaabd8c6', 'ef328756-1834-5dd0-ac72-1991d3018398', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41266563-e16f-5e43-8d9a-c383be316057', 'ef328756-1834-5dd0-ac72-1991d3018398', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8a1f137-1ec5-5573-ab0e-a4bbcec5149f', 'ef328756-1834-5dd0-ac72-1991d3018398', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b1e46d01-a803-5312-8e48-cd62873ff5a2', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 13, 'CLASSIFICATION', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Use the information in the passage to match the category (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
10-14
on your answer sheet.
NB
You may use any letter more than once
A
Sir Francis Drake
B
Wilfried Morawetz
C
Dany Cleyet-Marrel
D
Francis Halle
E
Christian Korner
F
Alan Smith
10
Scientist whose work was inspired by the method used by other researchers.
11
Scientist who made a claim that a balloon could only be used in a limited frequency or time.
12
Scientist who initiated a successful access mode which is cheap and stable.
13
Scientist who had committed canopy-crane experiment for a specific scientific project.
14
Scientist who initiated the use of crane on the short rail tracks.

13 ____ Scientist who had committed canopy-crane experiment for a specific scientific project.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d576469f-971f-5ae9-a22a-4936a0cf8571', 'b1e46d01-a803-5312-8e48-cd62873ff5a2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f72f944-1048-5418-ac36-bc13d924ac0f', 'b1e46d01-a803-5312-8e48-cd62873ff5a2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1de01507-34d8-5ad4-af4a-d0ee3cf13768', 'b1e46d01-a803-5312-8e48-cd62873ff5a2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7163da84-ecab-554a-844b-cad7b0c5eb69', 'b1e46d01-a803-5312-8e48-cd62873ff5a2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb3effdf-5cf9-5991-b69d-2c9cfd0fae2f', 'b1e46d01-a803-5312-8e48-cd62873ff5a2', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e516504b-c99b-5977-b7a5-28dad3efa4a6', 'b1e46d01-a803-5312-8e48-cd62873ff5a2', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7dc2bd24-3d1e-53a6-a50c-cffeffef8276', '17a11cdb-f287-5bfe-9fae-628d5572eaff', 14, 'CLASSIFICATION', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Use the information in the passage to match the category (listed
A-F
) with opinions or deeds below.
Write the appropriate letters
A-F
in boxes
10-14
on your answer sheet.
NB
You may use any letter more than once
A
Sir Francis Drake
B
Wilfried Morawetz
C
Dany Cleyet-Marrel
D
Francis Halle
E
Christian Korner
F
Alan Smith
10
Scientist whose work was inspired by the method used by other researchers.
11
Scientist who made a claim that a balloon could only be used in a limited frequency or time.
12
Scientist who initiated a successful access mode which is cheap and stable.
13
Scientist who had committed canopy-crane experiment for a specific scientific project.
14
Scientist who initiated the use of crane on the short rail tracks.

14 ____ Scientist who initiated the use of crane on the short rail tracks.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44a32067-3324-5f82-95b0-a1ed3b5edc54', '7dc2bd24-3d1e-53a6-a50c-cffeffef8276', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a4dbdda-3491-5005-9b10-c44798b7eaff', '7dc2bd24-3d1e-53a6-a50c-cffeffef8276', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21e5e016-4c90-592f-a5ec-3d087fb5664f', '7dc2bd24-3d1e-53a6-a50c-cffeffef8276', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f38db9e9-1b26-5280-b296-d9db92557dfd', '7dc2bd24-3d1e-53a6-a50c-cffeffef8276', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9af20d37-fcdf-555f-abb0-020435f83f03', '7dc2bd24-3d1e-53a6-a50c-cffeffef8276', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5553716d-20e0-52e1-8bf3-a04682a53185', '7dc2bd24-3d1e-53a6-a50c-cffeffef8276', 6, $md$F$md$, false);

COMMIT;
