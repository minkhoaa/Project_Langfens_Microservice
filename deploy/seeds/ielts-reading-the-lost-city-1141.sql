BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-lost-city-1141'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-lost-city-1141';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-lost-city-1141';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-lost-city-1141';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('3d20c321-019d-59c8-83b2-6dfae0ff9b57', 'ielts-reading-the-lost-city-1141', $t$The Lost City$t$, $md$## The Lost City

Nguồn:
- Test: https://mini-ielts.com/1141/reading/the-lost-city
- Solution: https://mini-ielts.com/1141/view-solution/reading/the-lost-city$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f2a87763-51d1-5d8e-ac51-fe3e0e17181d', '3d20c321-019d-59c8-83b2-6dfae0ff9b57', 1, $t$Reading — The Lost City$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Lost City

A When the US explorer and academic Hiram Bingham arrived in South America in 1911, he was ready for what was to be the greatest achievement of his life: the exploration of the remote hinterland to the west of Cusco, the old capital of the Inca empire in the Andes mountains of Peru. His goal was to locate the remains of a city called Vitcos, the last capital of the Inca civilisation .

Cusco lies on a high plateau at an elevation of more than 3,000 metres, and Bingham’s plan was to descend from this plateau along the valley of the Urubamba river, which takes a circuitous route down to the Amazon and passes through an area of dramatic canyons and mountain ranges.

B When Bingham and his team set off down the Urubamba in late July, they had an advantage over travellers who had preceded them : a track had recently been blasted down the valley canyon to enable rubber to be brought up by mules from the jungle. Almost all previous travellers had left the river at Ollantaytambo and taken a high pass across the mountains to rejoin the river lower down, thereby cutting a substantial corner, but also therefore never passing through the area around Machu Picchu.

C On 24 July they were a few days into their descent of the valley. The day began slowly, with Bingham trying to arrange sufficient mules for the next stage of the trek. His companions showed no interest in accompanying him up the nearby hill to see some ruins that a local farmer , Melchor Arteaga, had told them about the night before. The morning was dull and damp, and also seems to have been less than keen on the prospect of climbing the hill . In his book Lost City of the Incas, he relates that he made the ascent without having the least expectation that he would find anything at the top.

D Bingham writes about the approach in vivid style in his book. First, as he climbs up the hill, he describes the ever-present possibility of deadly snakes , ‘capable of making considerable springs when in pursuit of their prey’; not that he sees any. Then there’s a sense of mounting discovery as he comes across great sweeps of terraces, then a mausoleum, followed by monumental staircases and, finally, the grand ceremonial buildings of Machu Picchu. 'It seemed like an unbelievable dream the sight held me spellbound ’, he wrote.

E We should remember, however, that Lost City of the Incas is a work of hindsight, not written until 1948, many years after his journey. His journal entries of the time reveal a much more gradual appreciation of his achievement. He spent the afternoon at the ruins noting down the dimensions of some of the buildings, then descended and rejoined his companions, to whom he seems to have said little about his discovery. At this stage, didn’t realise the extent or the importance of the site, nor did he realise what use he could make of the discovery.

F However, soon after returning it occurred to him that he could make a name for himself from this discovery. When he came to write the National Geographic magazine article that broke the story to the world in April 1913, he knew he had to produce a big idea.

He wondered whether it could have been the birthplace of the very first Inca, Manco the Great, and whether it could also have been what chroniclers described as ‘the last city of the Incas’. This term refers to Vilcabamba the settlement where the Incas had fled from Spanish invaders in the 1530s. Bingham made desperate attempts to prove this belief for nearly 40 years. Sadly, his vision of the site as both the beginning and end of the Inca civilisation, while a magnificent one, is inaccurate. We now know, that Vilcabamba actually lies 65 kilometres away in the depths of the jungle.

G One question that has perplexed visitors, historians and archaeologists alike ever since Bingham, is why the site seems to have been abandoned before the Spanish Conquest. There are no references to it by any of the Spanish chroniclers - and if they had known of its existence so close to Cusco they would certainly have come in search of gold.

An idea which has gained wide acceptance over the past few years is that was a , a country estate built by an Inca emperor to escape the cold winters of Cusco, where the elite could enjoy monumental architecture and spectacular views. Furthermore, the particular architecture of Machu Picchu suggests that it was constructed at the time of the greatest of all the Incas, the emperor Pachacuti (1438-71). By custom, Pachacuti’s descendants built other similar estates for their own use, and so Machu Picchu would have been abandoned after his death, some 50 years before the Spanish Conquest.

----------------------------------------------------

Great thanks to volunteer Lan Nguyen has contributed these explanations and question markings.

If you want to make a better world like this, please contact us$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('89c2b067-d3d1-5dde-be91-85671f919022', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Different accounts of the same journey
ii
Bingham gains support
iii
A common belief
iv
The aim of the trip
v
A dramatic description
vi
A new route
vii
Bingham publishes his theory
viii
Bingham’s lack of enthusiasm

1 ____ Paragraph A Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b238a7b5-b2aa-51bf-afc9-a0c630995368', '89c2b067-d3d1-5dde-be91-85671f919022', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d26f4541-f2e5-5bcf-9089-1848dc0e8f90', '89c2b067-d3d1-5dde-be91-85671f919022', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b79a05c4-5ec7-565f-b96c-b6c83ffb4b72', '89c2b067-d3d1-5dde-be91-85671f919022', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d0590fa-cf48-56bf-8d9e-b7aa7c8c82d4', '89c2b067-d3d1-5dde-be91-85671f919022', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7774d3fd-449e-50dc-ab4a-e1fa3f2047f4', '89c2b067-d3d1-5dde-be91-85671f919022', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9209e105-af50-503a-8cc9-f6074941e777', '89c2b067-d3d1-5dde-be91-85671f919022', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b55618f5-1c7f-5cd6-92bc-e2fc1a0a39e9', '89c2b067-d3d1-5dde-be91-85671f919022', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a9bb47f-0f72-56d9-ae00-c0a0a3b698fb', '89c2b067-d3d1-5dde-be91-85671f919022', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('11cb2973-e29b-56f5-9a51-700d038568a8', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Different accounts of the same journey
ii
Bingham gains support
iii
A common belief
iv
The aim of the trip
v
A dramatic description
vi
A new route
vii
Bingham publishes his theory
viii
Bingham’s lack of enthusiasm

2 ____ Paragraph B Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c5e87c1-2f40-5f9e-afa0-5bdbf85cbde5', '11cb2973-e29b-56f5-9a51-700d038568a8', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4e4c104-917e-564d-8ef0-108e6bd8bdff', '11cb2973-e29b-56f5-9a51-700d038568a8', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7006edf0-9bf9-5cc2-b25f-0c27be80d091', '11cb2973-e29b-56f5-9a51-700d038568a8', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1951fbd7-4aa9-5432-b2a9-94796753d11c', '11cb2973-e29b-56f5-9a51-700d038568a8', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17fa47f6-d394-5ab0-ac47-fe90514720a4', '11cb2973-e29b-56f5-9a51-700d038568a8', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8cac30b-be1f-51c4-a204-16b4c7a47ed2', '11cb2973-e29b-56f5-9a51-700d038568a8', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a73538e5-0fa5-596f-a2ef-df5e970fdaed', '11cb2973-e29b-56f5-9a51-700d038568a8', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d66b8929-bb6d-57cd-92f0-0fddfaf379f4', '11cb2973-e29b-56f5-9a51-700d038568a8', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a4b2eb3-05b8-554c-b147-a887bb448199', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Different accounts of the same journey
ii
Bingham gains support
iii
A common belief
iv
The aim of the trip
v
A dramatic description
vi
A new route
vii
Bingham publishes his theory
viii
Bingham’s lack of enthusiasm

3 ____ Paragraph C Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45a11eb4-67d9-5da7-84f9-63e8db5a369b', '9a4b2eb3-05b8-554c-b147-a887bb448199', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6ac984d-e5dc-5ace-9db5-2396f030d6a1', '9a4b2eb3-05b8-554c-b147-a887bb448199', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12cece57-c0f2-5e9f-9668-71b35bdf8044', '9a4b2eb3-05b8-554c-b147-a887bb448199', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f39a574-6b26-5537-bada-a562bbc4df78', '9a4b2eb3-05b8-554c-b147-a887bb448199', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53d058db-7462-5048-aec4-d3fc086d7129', '9a4b2eb3-05b8-554c-b147-a887bb448199', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('118909f3-891e-5225-965c-dd031420a27b', '9a4b2eb3-05b8-554c-b147-a887bb448199', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('095525e5-24b9-52fd-9ab6-493a53f1337f', '9a4b2eb3-05b8-554c-b147-a887bb448199', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea25eb60-71b0-5c81-8e5b-1a08ae4c956f', '9a4b2eb3-05b8-554c-b147-a887bb448199', 8, $md$viii$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cb70540f-4de8-5abd-b066-03982ae72b71', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Different accounts of the same journey
ii
Bingham gains support
iii
A common belief
iv
The aim of the trip
v
A dramatic description
vi
A new route
vii
Bingham publishes his theory
viii
Bingham’s lack of enthusiasm

4 ____ Paragraph D Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('982ce9b3-c057-51bc-95ac-0939daf7e271', 'cb70540f-4de8-5abd-b066-03982ae72b71', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05acd9a8-5130-5bdf-909f-a01bcb0582a2', 'cb70540f-4de8-5abd-b066-03982ae72b71', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d583a60-f4a6-5ed6-8276-1a25752d479c', 'cb70540f-4de8-5abd-b066-03982ae72b71', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36ee3660-f72f-5916-a5ce-5d021a23d5c4', 'cb70540f-4de8-5abd-b066-03982ae72b71', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eaea58ae-97f5-585a-bd17-8258c88ebe73', 'cb70540f-4de8-5abd-b066-03982ae72b71', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc0f5fbf-68b7-5fd0-8c0d-969c61026122', 'cb70540f-4de8-5abd-b066-03982ae72b71', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea1e3900-88e1-51f8-87c4-53cd7c05da5a', 'cb70540f-4de8-5abd-b066-03982ae72b71', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f0b0242-ac1a-513b-bb1c-779e150d6cad', 'cb70540f-4de8-5abd-b066-03982ae72b71', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3c525113-2835-57a6-b623-5c235a9ff8ff', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Different accounts of the same journey
ii
Bingham gains support
iii
A common belief
iv
The aim of the trip
v
A dramatic description
vi
A new route
vii
Bingham publishes his theory
viii
Bingham’s lack of enthusiasm

5 ____ Paragraph E Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6b27179-9a05-5268-88aa-887baffbb9f3', '3c525113-2835-57a6-b623-5c235a9ff8ff', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e8e1a7d-d277-57fc-9e1b-2dbe0d4648aa', '3c525113-2835-57a6-b623-5c235a9ff8ff', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51e0c16d-6758-55db-a22f-fe48ce90fd2d', '3c525113-2835-57a6-b623-5c235a9ff8ff', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f98b8786-e2ba-5af0-abf6-907ebc371a7b', '3c525113-2835-57a6-b623-5c235a9ff8ff', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('520b188a-d025-5a36-a1d8-a7cc2afb95c5', '3c525113-2835-57a6-b623-5c235a9ff8ff', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b45348ae-1365-5f54-967f-5dfee870ee60', '3c525113-2835-57a6-b623-5c235a9ff8ff', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6fc671a-75ba-5560-a692-0c7231ed1b4e', '3c525113-2835-57a6-b623-5c235a9ff8ff', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efa97a11-5538-5eb0-ad2d-1f85c9e377ed', '3c525113-2835-57a6-b623-5c235a9ff8ff', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1528e159-76f0-5137-bec1-ff6535dc85e7', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Different accounts of the same journey
ii
Bingham gains support
iii
A common belief
iv
The aim of the trip
v
A dramatic description
vi
A new route
vii
Bingham publishes his theory
viii
Bingham’s lack of enthusiasm

6 ____ Paragraph F Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f77be800-73b9-5a07-ab89-3841ef6b6058', '1528e159-76f0-5137-bec1-ff6535dc85e7', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3adbf9f-7677-555a-ba99-192f3c7a5e15', '1528e159-76f0-5137-bec1-ff6535dc85e7', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb3ae775-d00e-5f86-8212-56a55bb7af81', '1528e159-76f0-5137-bec1-ff6535dc85e7', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f984ab8-14b9-58b6-9dd9-2f7629f3c118', '1528e159-76f0-5137-bec1-ff6535dc85e7', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71ebb66d-d26e-5ddf-a198-9c5301ec84cd', '1528e159-76f0-5137-bec1-ff6535dc85e7', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f480d51-13f3-5ea8-b8d5-f6c77a0a335b', '1528e159-76f0-5137-bec1-ff6535dc85e7', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0adacde2-caa3-5136-8296-83ed3eb0e102', '1528e159-76f0-5137-bec1-ff6535dc85e7', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06e9090e-f04c-568a-add9-f3ef4cdc86f6', '1528e159-76f0-5137-bec1-ff6535dc85e7', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0fe0d14e-63bd-5c45-ae6a-28f0d78c29e1', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-7
on your answer sheet.
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate
List of Headings
i
Different accounts of the same journey
ii
Bingham gains support
iii
A common belief
iv
The aim of the trip
v
A dramatic description
vi
A new route
vii
Bingham publishes his theory
viii
Bingham’s lack of enthusiasm

7 ____ Paragraph G Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fb46681-ee46-55c8-bc88-b450b8f9a707', '0fe0d14e-63bd-5c45-ae6a-28f0d78c29e1', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('942958a2-3cfa-5cf5-a7d3-ccf418fee2f0', '0fe0d14e-63bd-5c45-ae6a-28f0d78c29e1', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6747a81e-cd03-5b6c-ab15-c0aa1c6c5de3', '0fe0d14e-63bd-5c45-ae6a-28f0d78c29e1', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22eb502a-9617-5632-a403-c8ce4cb5e91c', '0fe0d14e-63bd-5c45-ae6a-28f0d78c29e1', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('032c1741-3a93-5bfe-9c68-7f21246df256', '0fe0d14e-63bd-5c45-ae6a-28f0d78c29e1', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('013a8e5e-4331-542f-aa4a-be4cff2cb86e', '0fe0d14e-63bd-5c45-ae6a-28f0d78c29e1', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa7c530a-a985-5c93-a04d-aee333b53973', '0fe0d14e-63bd-5c45-ae6a-28f0d78c29e1', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03856452-26eb-5ef8-9edd-dc892ba95eca', '0fe0d14e-63bd-5c45-ae6a-28f0d78c29e1', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('46e6b672-4203-580c-ab61-8241243e67aa', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage?
In boxes
8-11
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
Bingham went to South America in search of an Inca city.
Locate
9
Bingham chose a particular route down the Urubamba valley because it was the most common route used by travellers.
Locate
10
Bingham understood the significance of Machu Picchu as soon as he saw it.
Locate
11
Bingham returned to Machu Picchu in order to find evidence to support his theory.

8 ____ Bingham went to South America in search of an Inca city. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7b787a1-a6ee-5c04-9b5b-40a9429e7512', '46e6b672-4203-580c-ab61-8241243e67aa', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3510b713-db51-5141-96b5-ddff558ca5b7', '46e6b672-4203-580c-ab61-8241243e67aa', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e37e77c6-cb89-5847-b2b9-fea1f53b09aa', '46e6b672-4203-580c-ab61-8241243e67aa', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1285102b-7016-5f0e-b754-60cddad56f8a', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage?
In boxes
8-11
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
Bingham went to South America in search of an Inca city.
Locate
9
Bingham chose a particular route down the Urubamba valley because it was the most common route used by travellers.
Locate
10
Bingham understood the significance of Machu Picchu as soon as he saw it.
Locate
11
Bingham returned to Machu Picchu in order to find evidence to support his theory.

9 ____ Bingham chose a particular route down the Urubamba valley because it was the most common route used by travellers. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7630568-dc22-5c31-8069-015f0b03acbb', '1285102b-7016-5f0e-b754-60cddad56f8a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('517cf693-0109-5881-8d05-81a3aa9a051b', '1285102b-7016-5f0e-b754-60cddad56f8a', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55aa65cc-b6eb-53fe-b4f6-72f899e7fe25', '1285102b-7016-5f0e-b754-60cddad56f8a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('15c496e5-cd21-56c0-b1c0-4893f106d434', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage?
In boxes
8-11
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
Bingham went to South America in search of an Inca city.
Locate
9
Bingham chose a particular route down the Urubamba valley because it was the most common route used by travellers.
Locate
10
Bingham understood the significance of Machu Picchu as soon as he saw it.
Locate
11
Bingham returned to Machu Picchu in order to find evidence to support his theory.

10 ____ Bingham understood the significance of Machu Picchu as soon as he saw it. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b37863e1-b36c-59b4-b154-bc84479b324d', '15c496e5-cd21-56c0-b1c0-4893f106d434', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17674d09-57ff-5b59-9202-708e6b509011', '15c496e5-cd21-56c0-b1c0-4893f106d434', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa06aac2-89b8-5c48-8d31-d9948120401f', '15c496e5-cd21-56c0-b1c0-4893f106d434', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6605eca2-4604-54ec-860d-fe446029b61a', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 8-11
Questions 8-11
Do the following statements agree with the information given in Reading Passage?
In boxes
8-11
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
Bingham went to South America in search of an Inca city.
Locate
9
Bingham chose a particular route down the Urubamba valley because it was the most common route used by travellers.
Locate
10
Bingham understood the significance of Machu Picchu as soon as he saw it.
Locate
11
Bingham returned to Machu Picchu in order to find evidence to support his theory.

11 ____ Bingham returned to Machu Picchu in order to find evidence to support his theory.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('644c2caf-5dae-5ff5-9182-267d2f3e44ae', '6605eca2-4604-54ec-860d-fe446029b61a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47acf815-af56-5c3b-98e2-82fa3221db48', '6605eca2-4604-54ec-860d-fe446029b61a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ae0db0f-40e0-54ac-9730-722d99bd17d7', '6605eca2-4604-54ec-860d-fe446029b61a', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('80f44ab9-793e-508a-921b-2a00254bccb2', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 12-13
Questions 12-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
12-13
on your answer sheet.
12
The track that took Bingham down the Urubamba valley had been created for the transportation of
Locate
13
Bingham found out about the ruins of Machu Picchu from a
in the Urubamba valley.
Locate

12 The track that took Bingham down the Urubamba valley had been created for the transportation of ____ Locate$md$, NULL, ARRAY['.*rubber.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5783be22-bd62-52dc-a177-9750d2bf893e', 'f2a87763-51d1-5d8e-ac51-fe3e0e17181d', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 12-13
Questions 12-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
12-13
on your answer sheet.
12
The track that took Bingham down the Urubamba valley had been created for the transportation of
Locate
13
Bingham found out about the ruins of Machu Picchu from a
in the Urubamba valley.
Locate

13 Bingham found out about the ruins of Machu Picchu from a ____ in the Urubamba valley. Locate$md$, NULL, ARRAY['.*farmer.*']);

COMMIT;
