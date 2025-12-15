BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-art-in-iron-and-steel-1347'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-art-in-iron-and-steel-1347';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-art-in-iron-and-steel-1347';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-art-in-iron-and-steel-1347';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('e858b8d9-af31-56b6-a4d8-3ae525a95859', 'ielts-reading-art-in-iron-and-steel-1347', $t$Art in Iron and Steel$t$, $md$## Art in Iron and Steel

Nguồn:
- Test: https://mini-ielts.com/1347/reading/art-in-iron-and-steel
- Solution: https://mini-ielts.com/1347/view-solution/reading/art-in-iron-and-steel$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('31c0bbc6-240b-5908-a5e0-1119805e7529', 'e858b8d9-af31-56b6-a4d8-3ae525a95859', 1, $t$Reading — Art in Iron and Steel$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Art in Iron and Steel

A

Works of engineering and technology are sometimes viewed as the antitheses of art and humanity. Think of the connotations of assembly lines, robots, and computers. Any positive values there might be in such creations of the mind and human industry can be overwhelmed by the associated negative images of repetitive, stressful, and threatened jobs. Such images fuel the arguments of critics of technology even as they may drive powerful cars and use the Internet to protest what they see as the artless and dehumanizing aspects of living in an industrialized and digitized society. At the same time, landmark megastructures such as the Brooklyn and Golden Gate bridges are almost universally hailed as majestic human achievements as well as great engineering monuments that have come to embody the spirits of their respective cities. The relationship between art and engineering has seldom been easy or consistent.

B

The human worker may have appeared to be but a cog in the wheel of industry, yet photographers could reveal the beauty of line and composition in a worker doing something as common as using a wrench to turn a bolt. When Henry Ford’s enormous River Rouge plant opened in 1927 to produce the Model A, the painter/photographer Charles Sheeler was chosen to photograph it. The world’s largest car factory captured the imagination of Sheeler, who described it as the most thrilling subject he ever had to work with. The artist also composed oil paintings of the plant, giving them titles such as American Landscape and Classic Landscape.

C

Long before Sheeler, other artists, too, had seen the beauty and humanity in works of engineering and technology. This is perhaps no more evident than in Coalbrookdale, England, where iron, which was so important to the industrial revolution, was worked for centuries. Here, in the late eighteenth century, Abraham Darby III cast on the banks of the Severn River the large ribs that formed the world’s first iron bridge, a dramatic departure from the classic stone and timber bridges that dotted the countryside and were captured in numerous serene landscape paintings. The metal structure, simply but appropriately called Iron Bridge, still spans the river and still beckons engineers, artists, and tourists to gaze upon and walk across it, as if on a pilgrimage to a revered place.

D

At Coalbrookdale, the reflection of the ironwork in the water completes the semicircular structure to form a wide-open eye into the future that is now the past. One artist’s bucolic depiction shows pedestrians and horsemen on the bridge, as if on a woodland trail. On one shore, a pair of well-dressed onlookers interrupts their stroll along the riverbank, perhaps to admire the bridge. On the other side of the gently flowing river, a lone man leads two mules beneath an arch that lets the towpath pass through the bridge’s abutment. A single boatman paddles across the river in a tiny tub boat. He is in no rush because there is no towline to carry from one side of the bridge to the other. This is how Michael Rooker was Iron Bridge in his 1792 painting. A colored engraving of the scene hangs in the nearby Coalbrookdale museum, along with countless other contemporary renderings of the bridge in its full glory and in its context, showing the iron structure not as a blight on the landscape but at the center of it. The surrounding area at the same time radiates out from the bridge and pales behind it.

E

In the nineteenth century, the railroads captured the imagination of artists, and the steam engine in the distance of a landscape became as much a part of it as the herd of cows in the foreground. The Impressionist Claude Monet painted man-made structures like railway stations and cathedrals as well as water lilies. Portrait painters such as Christian Schussele found subjects in engineers and inventors – and their inventions – as well as in the American founding fathers. By the twentieth century, engineering, technology, and industry were very well established as subjects for artists.

F

American-born Joseph Pennell illustrated many European travel articles and books. Pennell, who early in his career made drawings of buildings under construction and shrouded in scaffolding, returned to America late in life and recorded industrial activities during World War I. He is perhaps best known among engineers for his depiction of the Panama Canal as it neared completion and his etchings of the partially completed Hell Gate and Delaware River bridges.

G

Pennell has often been quoted as saying, “Great engineering is great art,” a sentiment that he expressed repeatedly. He wrote of his contemporaries, “I understand nothing of engineering, but I know that engineers are the greatest architects and the most pictorial builders since the Greeks.” Where some observers saw only utility, Pennell saw also beauty, if not in form then at least in scale. He felt he was not only rendering a concrete subject but also conveying through his drawings the impression that it made on him. Pennell called the sensation that he felt before a great construction project ‘The Wonder of Work”. He saw engineering as a process. That process is memorialized in every completed dam, skyscraper, bridge, or other great achievement of engineering.

H

If Pennell experienced the wonder of work in the aggregate, Lewis Hine focused on the individuals who engaged in the work. Hine was trained as a sociologist but became best known as a photographer who exposed the exploitation of children. His early work documented immigrants passing through Ellis Island, along with the conditions in the New York tenements where they lived and the sweatshops where they worked. Upon returning to New York, he was given the opportunity to record the construction of the Empire State Building, which resulted in the striking photographs that have become such familiar images of daring and insouciance. He put his own life at risk to capture workers suspended on cables hundreds of feet in the air and sitting on a high girder eating lunch. To engineers today, one of the most striking features of these photos, published in 1932 in Men at Work, is the absence of safety lines and hard hats. However, perhaps more than anything, the photos evoke Pennell’s “The Wonder of Work” and inspire admiration for the bravery and skill that bring a great engineering project to completion.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a94019cb-c01f-5c1f-86a2-3a58b1d2c169', '31c0bbc6-240b-5908-a5e0-1119805e7529', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The Reading Passage has eight paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-5
on your answer sheet.
1
Art connected with architecture for the first time.
2
small artistic object and constructions built are put together
3
the working condition were recorded by the artist as an exciting subject.
4
mention of one engineers’ artistic work on an unfinished engineering project
5
Two examples of famous bridges which became the iconic symbols of those cities

1 ____ Art connected with architecture for the first time.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('112d0696-4bd2-5eaa-955d-d899033c4f12', 'a94019cb-c01f-5c1f-86a2-3a58b1d2c169', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a863b48d-436a-5e65-a206-a27584e7d0a2', 'a94019cb-c01f-5c1f-86a2-3a58b1d2c169', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06e84a2f-56ca-520a-a2d2-d75a250de17d', 'a94019cb-c01f-5c1f-86a2-3a58b1d2c169', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('886a9199-abb9-5e56-8ddc-422b8ae59dd5', 'a94019cb-c01f-5c1f-86a2-3a58b1d2c169', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ba6494d-8c2c-53d8-8a9d-729c465df2a1', 'a94019cb-c01f-5c1f-86a2-3a58b1d2c169', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acd4a3c4-407c-5676-8ddf-4b311e2659b5', 'a94019cb-c01f-5c1f-86a2-3a58b1d2c169', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0760c6d-6e33-5271-b1d8-0dc559d47a3b', 'a94019cb-c01f-5c1f-86a2-3a58b1d2c169', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef5a42de-1f62-5450-8456-b23410f682b5', 'a94019cb-c01f-5c1f-86a2-3a58b1d2c169', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3af216ab-f45b-5777-a9b8-057865a85cb6', '31c0bbc6-240b-5908-a5e0-1119805e7529', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The Reading Passage has eight paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-5
on your answer sheet.
1
Art connected with architecture for the first time.
2
small artistic object and constructions built are put together
3
the working condition were recorded by the artist as an exciting subject.
4
mention of one engineers’ artistic work on an unfinished engineering project
5
Two examples of famous bridges which became the iconic symbols of those cities

2 ____ small artistic object and constructions built are put together$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8abceac9-b911-5328-9de2-1d528ea9688c', '3af216ab-f45b-5777-a9b8-057865a85cb6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45a94352-6c74-58c4-92c6-af2701299a62', '3af216ab-f45b-5777-a9b8-057865a85cb6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7440c2eb-51ac-572a-bf6c-13ac0971efd1', '3af216ab-f45b-5777-a9b8-057865a85cb6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5213e2a3-6637-5bd8-bbb4-d3f8c8ecf4d6', '3af216ab-f45b-5777-a9b8-057865a85cb6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ceb7a420-51b7-561b-9701-c78074c94dc6', '3af216ab-f45b-5777-a9b8-057865a85cb6', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe0af038-c204-55ed-b3a7-a863d887765a', '3af216ab-f45b-5777-a9b8-057865a85cb6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('225d5eed-f120-54b9-add7-da02b5148550', '3af216ab-f45b-5777-a9b8-057865a85cb6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bca230b-f4b9-558c-a9e1-e9abaacfc19e', '3af216ab-f45b-5777-a9b8-057865a85cb6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5de9ba9-2e69-55e4-971a-a5a21d460fca', '31c0bbc6-240b-5908-a5e0-1119805e7529', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The Reading Passage has eight paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-5
on your answer sheet.
1
Art connected with architecture for the first time.
2
small artistic object and constructions built are put together
3
the working condition were recorded by the artist as an exciting subject.
4
mention of one engineers’ artistic work on an unfinished engineering project
5
Two examples of famous bridges which became the iconic symbols of those cities

3 ____ the working condition were recorded by the artist as an exciting subject.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c3d5603-4552-5955-b860-c474cfd0b48e', 'a5de9ba9-2e69-55e4-971a-a5a21d460fca', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('049bdf49-9716-5e7f-83e5-abe50954c9ab', 'a5de9ba9-2e69-55e4-971a-a5a21d460fca', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90445357-9873-57b0-b788-8a6c3ca045ed', 'a5de9ba9-2e69-55e4-971a-a5a21d460fca', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0026ca34-a888-5abb-8ccd-0524e4cc5a8f', 'a5de9ba9-2e69-55e4-971a-a5a21d460fca', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('846cc84d-b64b-5d6b-923e-4c10f10559e5', 'a5de9ba9-2e69-55e4-971a-a5a21d460fca', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b54371bd-bc60-565c-be97-3def5c528463', 'a5de9ba9-2e69-55e4-971a-a5a21d460fca', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0463f54c-97fc-5db7-8992-353590997cc5', 'a5de9ba9-2e69-55e4-971a-a5a21d460fca', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e33ad90-fa81-5850-aa00-7cde82a09e7c', 'a5de9ba9-2e69-55e4-971a-a5a21d460fca', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('19d8f593-587f-53fc-b137-0fe891eed998', '31c0bbc6-240b-5908-a5e0-1119805e7529', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The Reading Passage has eight paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-5
on your answer sheet.
1
Art connected with architecture for the first time.
2
small artistic object and constructions built are put together
3
the working condition were recorded by the artist as an exciting subject.
4
mention of one engineers’ artistic work on an unfinished engineering project
5
Two examples of famous bridges which became the iconic symbols of those cities

4 ____ mention of one engineers’ artistic work on an unfinished engineering project$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('046fd566-9f20-51bf-b4f0-ae378e04332b', '19d8f593-587f-53fc-b137-0fe891eed998', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6a67315-61c7-563b-a978-900639613a18', '19d8f593-587f-53fc-b137-0fe891eed998', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6a5dbec-1922-53ef-86c2-f7714c483c23', '19d8f593-587f-53fc-b137-0fe891eed998', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1895fdca-7af1-56c3-b190-dfb7efa7804c', '19d8f593-587f-53fc-b137-0fe891eed998', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3286d405-c7f3-5fd6-908b-3ae40ff546ef', '19d8f593-587f-53fc-b137-0fe891eed998', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b5e5012-87a8-572d-b3e1-d51784a0dd7c', '19d8f593-587f-53fc-b137-0fe891eed998', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62db42eb-18eb-5134-8c4d-50f9def0d206', '19d8f593-587f-53fc-b137-0fe891eed998', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9294d637-d2fc-55ff-9932-da4ee380e4af', '19d8f593-587f-53fc-b137-0fe891eed998', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('23adfdbb-c8f9-58fd-94c5-6401bec9526e', '31c0bbc6-240b-5908-a5e0-1119805e7529', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The Reading Passage has eight paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-5
on your answer sheet.
1
Art connected with architecture for the first time.
2
small artistic object and constructions built are put together
3
the working condition were recorded by the artist as an exciting subject.
4
mention of one engineers’ artistic work on an unfinished engineering project
5
Two examples of famous bridges which became the iconic symbols of those cities

5 ____ Two examples of famous bridges which became the iconic symbols of those cities$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('538c9426-f1d0-5a3f-b66c-7e8b259a754b', '23adfdbb-c8f9-58fd-94c5-6401bec9526e', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1292c201-5d29-53c1-a817-a752eb5dc1c3', '23adfdbb-c8f9-58fd-94c5-6401bec9526e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9abd0e86-457a-56a6-a3aa-fd93cca46f76', '23adfdbb-c8f9-58fd-94c5-6401bec9526e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a0a3a81-340f-5049-9622-3f1d67394e96', '23adfdbb-c8f9-58fd-94c5-6401bec9526e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('276d81ae-5e93-5003-a475-630e427af08c', '23adfdbb-c8f9-58fd-94c5-6401bec9526e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10aafd42-a495-5e2b-af79-18c92900f601', '23adfdbb-c8f9-58fd-94c5-6401bec9526e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25449d2e-9584-5c9f-b4da-d720dfb816a0', '23adfdbb-c8f9-58fd-94c5-6401bec9526e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6800d6ad-8089-5707-abbd-80007f2f596c', '23adfdbb-c8f9-58fd-94c5-6401bec9526e', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9cfbc4b2-4d74-5df9-ae9b-ba1e4bdbf5d6', '31c0bbc6-240b-5908-a5e0-1119805e7529', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Use the information in the passage to match the people (listed A-F) with opinions or deeds below.
Write the appropriate letters A-F in boxes 6-10 on your answer sheet.
List of people
A
Charles Sheeler
B
Michael Rooker
C
Claude Monet
D
Christian Schussele
E
Joseph Pennell
F
Lewis Hine
6
who made a comment that concrete constructions have a beauty just as artistic processes created by engineers the architects
7
who made a romantic depiction of an old bridge in one painting
8
who produced art pieces demonstrating the courage of workers in the site
9
who produced portraits involving subjects in engineers and inventions and historical human heroes.
10
who produced a painting of factories and named them ambitiously

6 ____ who made a comment that concrete constructions have a beauty just as artistic processes created by engineers the architects$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e21c4408-2133-5ae0-a2fb-4c9be513aded', '9cfbc4b2-4d74-5df9-ae9b-ba1e4bdbf5d6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1eec186-05e4-582d-9a8d-5d1e231c9ac6', '9cfbc4b2-4d74-5df9-ae9b-ba1e4bdbf5d6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e94e448-238b-5e8e-abd4-c4f4469a5865', '9cfbc4b2-4d74-5df9-ae9b-ba1e4bdbf5d6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3a74da5-46b7-542a-a6c2-926a8d0b84c5', '9cfbc4b2-4d74-5df9-ae9b-ba1e4bdbf5d6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef2b79bd-0d6a-57fd-9948-0ef2cb9031f3', '9cfbc4b2-4d74-5df9-ae9b-ba1e4bdbf5d6', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23bd84b9-f669-51e2-8c4e-ed6b41229748', '9cfbc4b2-4d74-5df9-ae9b-ba1e4bdbf5d6', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('db4f00f0-2bb9-5f91-9ceb-239631146b11', '31c0bbc6-240b-5908-a5e0-1119805e7529', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Use the information in the passage to match the people (listed A-F) with opinions or deeds below.
Write the appropriate letters A-F in boxes 6-10 on your answer sheet.
List of people
A
Charles Sheeler
B
Michael Rooker
C
Claude Monet
D
Christian Schussele
E
Joseph Pennell
F
Lewis Hine
6
who made a comment that concrete constructions have a beauty just as artistic processes created by engineers the architects
7
who made a romantic depiction of an old bridge in one painting
8
who produced art pieces demonstrating the courage of workers in the site
9
who produced portraits involving subjects in engineers and inventions and historical human heroes.
10
who produced a painting of factories and named them ambitiously

7 ____ who made a romantic depiction of an old bridge in one painting$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a7efb82-1da5-5843-9a7f-8776d1062cde', 'db4f00f0-2bb9-5f91-9ceb-239631146b11', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d086a60c-6f8b-5192-a1c7-c5cd00207828', 'db4f00f0-2bb9-5f91-9ceb-239631146b11', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbeb4597-39b8-5fd6-ae26-90c0bc566154', 'db4f00f0-2bb9-5f91-9ceb-239631146b11', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e2dd69d-11ec-592f-8393-67346e9f8d27', 'db4f00f0-2bb9-5f91-9ceb-239631146b11', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bec2cb2c-8c5f-5ec9-8407-bac74ee8b4d4', 'db4f00f0-2bb9-5f91-9ceb-239631146b11', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f909e8bd-aaa0-5c3d-a814-fc3d1852c1e5', 'db4f00f0-2bb9-5f91-9ceb-239631146b11', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('52fd29f0-20a4-5823-abd8-8ab29a49dba1', '31c0bbc6-240b-5908-a5e0-1119805e7529', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Use the information in the passage to match the people (listed A-F) with opinions or deeds below.
Write the appropriate letters A-F in boxes 6-10 on your answer sheet.
List of people
A
Charles Sheeler
B
Michael Rooker
C
Claude Monet
D
Christian Schussele
E
Joseph Pennell
F
Lewis Hine
6
who made a comment that concrete constructions have a beauty just as artistic processes created by engineers the architects
7
who made a romantic depiction of an old bridge in one painting
8
who produced art pieces demonstrating the courage of workers in the site
9
who produced portraits involving subjects in engineers and inventions and historical human heroes.
10
who produced a painting of factories and named them ambitiously

8 ____ who produced art pieces demonstrating the courage of workers in the site$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae6dcd40-6ea7-539f-b16d-d8e33fe77d11', '52fd29f0-20a4-5823-abd8-8ab29a49dba1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b52e3c9f-4816-5ede-82e2-38b9536b7d9a', '52fd29f0-20a4-5823-abd8-8ab29a49dba1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3dbf89aa-ca1d-5e1f-bac4-ad2b752cd153', '52fd29f0-20a4-5823-abd8-8ab29a49dba1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd604f53-cce0-5b87-a0ec-9ece794932d4', '52fd29f0-20a4-5823-abd8-8ab29a49dba1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8eb47945-7267-595e-b1f2-787ae019b0f8', '52fd29f0-20a4-5823-abd8-8ab29a49dba1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2539174-8bce-593b-acdd-8b33aff33b63', '52fd29f0-20a4-5823-abd8-8ab29a49dba1', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c498d1e-8bc2-522a-9d43-106aff80f713', '31c0bbc6-240b-5908-a5e0-1119805e7529', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Use the information in the passage to match the people (listed A-F) with opinions or deeds below.
Write the appropriate letters A-F in boxes 6-10 on your answer sheet.
List of people
A
Charles Sheeler
B
Michael Rooker
C
Claude Monet
D
Christian Schussele
E
Joseph Pennell
F
Lewis Hine
6
who made a comment that concrete constructions have a beauty just as artistic processes created by engineers the architects
7
who made a romantic depiction of an old bridge in one painting
8
who produced art pieces demonstrating the courage of workers in the site
9
who produced portraits involving subjects in engineers and inventions and historical human heroes.
10
who produced a painting of factories and named them ambitiously

9 ____ who produced portraits involving subjects in engineers and inventions and historical human heroes.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('201fcb54-5486-5d3b-8c12-94876041e736', '4c498d1e-8bc2-522a-9d43-106aff80f713', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77f6d8b4-0727-5028-a398-be8f606ddb45', '4c498d1e-8bc2-522a-9d43-106aff80f713', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d4d2266-2c37-597b-8251-e51294791648', '4c498d1e-8bc2-522a-9d43-106aff80f713', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca9eb750-6821-54ad-88ce-0c5e695aca23', '4c498d1e-8bc2-522a-9d43-106aff80f713', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('becfbd06-1271-5d71-abb2-62e015592dd1', '4c498d1e-8bc2-522a-9d43-106aff80f713', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9b170d8-d2f1-5e14-a6c8-9a00b46187fa', '4c498d1e-8bc2-522a-9d43-106aff80f713', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6f38abb4-43dd-512f-9749-48925d6adc1a', '31c0bbc6-240b-5908-a5e0-1119805e7529', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Use the information in the passage to match the people (listed A-F) with opinions or deeds below.
Write the appropriate letters A-F in boxes 6-10 on your answer sheet.
List of people
A
Charles Sheeler
B
Michael Rooker
C
Claude Monet
D
Christian Schussele
E
Joseph Pennell
F
Lewis Hine
6
who made a comment that concrete constructions have a beauty just as artistic processes created by engineers the architects
7
who made a romantic depiction of an old bridge in one painting
8
who produced art pieces demonstrating the courage of workers in the site
9
who produced portraits involving subjects in engineers and inventions and historical human heroes.
10
who produced a painting of factories and named them ambitiously

10 ____ who produced a painting of factories and named them ambitiously$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a68be229-7657-5df0-85f6-7a15b7162f0f', '6f38abb4-43dd-512f-9749-48925d6adc1a', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8922141-e86d-5da7-95b9-831b24f57952', '6f38abb4-43dd-512f-9749-48925d6adc1a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2db6ea48-0dfd-5483-9909-08d8e7f53cba', '6f38abb4-43dd-512f-9749-48925d6adc1a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('201c122d-0566-5204-8a78-1175b4de20f3', '6f38abb4-43dd-512f-9749-48925d6adc1a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd8a0da4-8aff-52d3-b686-468e284e9ed3', '6f38abb4-43dd-512f-9749-48925d6adc1a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d7ee344-202c-5055-a079-701daa61dd3f', '6f38abb4-43dd-512f-9749-48925d6adc1a', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1365de94-1b99-56bf-aede-c378920fc88c', '31c0bbc6-240b-5908-a5e0-1119805e7529', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Iron bridge Coalbrookdale, England
In the late eighteenth century, as artists began to capture the artistic attractiveness incorporated into architecture via engineering and technology were captured in numerous serene landscape paintings. One good example, the engineer called
11
had designed the first iron bridge in the world and changed to using irons yet earlier bridges in the countryside were constructed using materials such as
12
and wood. This first Iron bridge which across the
13
was much significant in the industrial revolution period and it functioned for centuries. Numerous spectacular paintings and sculpture of Iron Bridge are collected and exhibited locally in
14
, showing the iron structure as a theme on the landscape.

In the late eighteenth century, as artists began to capture the artistic attractiveness incorporated into architecture via engineering and technology were captured in numerous serene landscape paintings. One good example, the engineer called 11 ____ had designed the first iron bridge in the world and changed to using irons yet earlier bridges in the countryside were constructed using materials such as 12 ____ and wood. This first Iron bridge which across the 13 ____ was much significant in the industrial revolution period and it functioned for centuries. Numerous spectacular paintings and sculpture of Iron Bridge are collected and exhibited locally in 14 ____ , showing the iron structure as a theme on the landscape.$md$, NULL, ARRAY['.*abraham.*darby.*iii.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9e908cb3-851d-5a97-a631-ced10406cddc', '31c0bbc6-240b-5908-a5e0-1119805e7529', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Iron bridge Coalbrookdale, England
In the late eighteenth century, as artists began to capture the artistic attractiveness incorporated into architecture via engineering and technology were captured in numerous serene landscape paintings. One good example, the engineer called
11
had designed the first iron bridge in the world and changed to using irons yet earlier bridges in the countryside were constructed using materials such as
12
and wood. This first Iron bridge which across the
13
was much significant in the industrial revolution period and it functioned for centuries. Numerous spectacular paintings and sculpture of Iron Bridge are collected and exhibited locally in
14
, showing the iron structure as a theme on the landscape.

In the late eighteenth century, as artists began to capture the artistic attractiveness incorporated into architecture via engineering and technology were captured in numerous serene landscape paintings. One good example, the engineer called 11 ____ had designed the first iron bridge in the world and changed to using irons yet earlier bridges in the countryside were constructed using materials such as 12 ____ and wood. This first Iron bridge which across the 13 ____ was much significant in the industrial revolution period and it functioned for centuries. Numerous spectacular paintings and sculpture of Iron Bridge are collected and exhibited locally in 14 ____ , showing the iron structure as a theme on the landscape.$md$, NULL, ARRAY['.*abraham.*darby.*iii.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('50497cca-1b03-5e05-b571-30be0ce86f54', '31c0bbc6-240b-5908-a5e0-1119805e7529', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Iron bridge Coalbrookdale, England
In the late eighteenth century, as artists began to capture the artistic attractiveness incorporated into architecture via engineering and technology were captured in numerous serene landscape paintings. One good example, the engineer called
11
had designed the first iron bridge in the world and changed to using irons yet earlier bridges in the countryside were constructed using materials such as
12
and wood. This first Iron bridge which across the
13
was much significant in the industrial revolution period and it functioned for centuries. Numerous spectacular paintings and sculpture of Iron Bridge are collected and exhibited locally in
14
, showing the iron structure as a theme on the landscape.

In the late eighteenth century, as artists began to capture the artistic attractiveness incorporated into architecture via engineering and technology were captured in numerous serene landscape paintings. One good example, the engineer called 11 ____ had designed the first iron bridge in the world and changed to using irons yet earlier bridges in the countryside were constructed using materials such as 12 ____ and wood. This first Iron bridge which across the 13 ____ was much significant in the industrial revolution period and it functioned for centuries. Numerous spectacular paintings and sculpture of Iron Bridge are collected and exhibited locally in 14 ____ , showing the iron structure as a theme on the landscape.$md$, NULL, ARRAY['.*abraham.*darby.*iii.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a52d1d50-9a30-5b6e-a820-633ab91ec5c5', '31c0bbc6-240b-5908-a5e0-1119805e7529', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Iron bridge Coalbrookdale, England
In the late eighteenth century, as artists began to capture the artistic attractiveness incorporated into architecture via engineering and technology were captured in numerous serene landscape paintings. One good example, the engineer called
11
had designed the first iron bridge in the world and changed to using irons yet earlier bridges in the countryside were constructed using materials such as
12
and wood. This first Iron bridge which across the
13
was much significant in the industrial revolution period and it functioned for centuries. Numerous spectacular paintings and sculpture of Iron Bridge are collected and exhibited locally in
14
, showing the iron structure as a theme on the landscape.

In the late eighteenth century, as artists began to capture the artistic attractiveness incorporated into architecture via engineering and technology were captured in numerous serene landscape paintings. One good example, the engineer called 11 ____ had designed the first iron bridge in the world and changed to using irons yet earlier bridges in the countryside were constructed using materials such as 12 ____ and wood. This first Iron bridge which across the 13 ____ was much significant in the industrial revolution period and it functioned for centuries. Numerous spectacular paintings and sculpture of Iron Bridge are collected and exhibited locally in 14 ____ , showing the iron structure as a theme on the landscape.$md$, NULL, ARRAY['.*abraham.*darby.*iii.*']);

COMMIT;
