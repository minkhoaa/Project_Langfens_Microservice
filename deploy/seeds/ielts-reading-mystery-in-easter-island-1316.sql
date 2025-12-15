BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-mystery-in-easter-island-1316'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mystery-in-easter-island-1316';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mystery-in-easter-island-1316';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-mystery-in-easter-island-1316';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('726db53a-ebe8-5383-ac02-32fd1c3f9ed7', 'ielts-reading-mystery-in-easter-island-1316', $t$Mystery in Easter Island$t$, $md$## Mystery in Easter Island

Nguồn:
- Test: https://mini-ielts.com/1316/reading/mystery-in-easter-island
- Solution: https://mini-ielts.com/1316/view-solution/reading/mystery-in-easter-island$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('86705068-f802-5ba1-9832-80772f918964', '726db53a-ebe8-5383-ac02-32fd1c3f9ed7', 1, $t$Reading — Mystery in Easter Island$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Mystery in Easter Island

A

One of the world’s most famous yet least visited archaeological sites, Easter Island is a small, hilly, now treeless island of volcanic origin. Located in the Pacific Ocean at 27 degrees south of the equator and some 2200 miles (3600 kilometers) off the coast of Chile, it is considered to be the world’s most remote inhabited island. The island is, technically speaking, a single massive volcano rising over ten thousand feet from the Pacific Ocean floor. The island received its most well-known current name, Easter Island, from the Dutch sea captain Jacob Roggeveen who became the first European to visit Easter Sunday, April 5, 1722.

B

In the early 1950s, the Norwegian explorer Thor Heyerdahl popularized the idea that the island had been originally settled by advanced societies of Indians from the coast of South America. Extensive archaeological, ethnographic and linguistic research has conclusively shown this hypothesis to be inaccurate. It is now recognized that the original inhabitants of Easter Island are of Polynesian stock (DNA extracts from skeletons have confirmed this), that they most probably came from the Marquesas or Society islands, and that they arrived as early as 318 AD (carbon dating of reeds from a grave confirms this). At the time of their arrival, much of the island was forested, was teeming with land birds, and was perhaps the most productive breeding site for seabirds in the Polynesia region. Because of the plentiful bird, fish and plant food sources, the human population grew and gave rise to a rich religious and artistic culture.

C

That culture’s most famous features are its enormous stone statues called moai, at least 288 of which once stood upon massive stone platforms called ahu . There are some 250 of these ahu platforms spaced approximately one-half mile apart and creating an almost unbroken line around the perimeter of the island. Another 600 moai statues, in various stages of completion, are scattered around the island, either in quarries or along ancient roads between the quarries and the coastal areas where the statues were most often erected. Nearly all the moai are carved from the tough stone of the Rano Raraku volcano. The average statue is 14 feet and 6 inches tall and weighs 14 tons. Some moai were as large as 33 feet and weighed more than 80 tons. Depending upon the size of the statues, it has been estimated that between 50 and 150 people were needed to drag them across the countryside on sledges and rollers made from the island’s trees.

D

Scholars are unable to definitively explain the function and use of the moai statues. It is assumed that their carving and erection derived from an idea rooted in similar practices found elsewhere in Polynesia but which evolved in a unique way on Easter Island. Archaeological and iconographic analysis indicates that the statue cult was based on an ideology of male, lineage-based authority incorporating anthropomorphic symbolism. The statues were thus symbols of authority and power, both religious and political. But they were not only symbols. To the people who erected and used them, they were actual repositories of sacred spirit. Carved stone and wooden objects in ancient Polynesian religions, when properly fashioned and ritually prepared, were believed to be charged by a magical spiritual essence called mana . The ahu platforms of Easter Island were the sanctuaries of the people, and the moai statues were the ritually charged sacred objects of those sanctuaries.

E

Besides its more well-known name, Easter Island is also known as Te-Pito-O-Te-Henua b , meaning ‘The Navel of the World’, and as Mata-Ki-Te-Rani , meaning ‘Eyes Looking at Heaven’. These ancient name and a host of mythological details ignored by mainstream archaeologists point to the possibility that the remote island may once have been a geodetic marker and the site of an astronomical observatory of a long-forgotten civilization. In his book, Heaven’s Mirror, Graham Hancock suggests that Easter Island may once have been a significant scientific outpost of this antediluvian civilization and that its location had extreme importance in a planet-spanning, mathematically precise grid of sacred sites. Two other alternative scholars, Christopher Knight and Robert Lomas, have extensively studied the location and possible function of these geodetic markers. In their fascinating book, Uriel’s Machine, they suggest that one purpose of the geodetic markers was as part of a global network of sophisticated astronomical observatories dedicated to predicting and preparing for future commentary impacts and crystal displacement cataclysms.

F

In the latter years of the 20th century and the first years of the 21st century, various writers and scientists have advanced theories regarding the rapid decline of Easter Island’s magnificent civilization around the time of the first European contact. Principal among these theories, and now shown to be inaccurate, is that postulated by Jared Diamond in his book Collapse: How Societies Choose to Fail or Survive. Basically, these theories state that a few centuries after Easter Island’s initial colonization the resource needs of the growing population had begun to outpace the island’s capacity to renew itself ecologically. By the 1400s the forests had been entirely cut, the rich ground cover had eroded away, the springs had dried up, and the vast flocks of birds coming to roost on the island had disappeared. With no logs to build canoes for offshore fishing, with depleted bird and wildlife food sources, and with declining crop yields because of the erosion of good soil, the nutritional intake of the people plummeted. First famine, then cannibalism, set in. Because the island could no longer feed the chiefs, bureaucrats and priests who kept the complex society running, the resulting chaos triggered a social and cultural collapse. By 1700 the population dropped to between one-quarter and one-tenth of its former number, and many of the statues were toppled during supposed “clan wars” of the 1600 and 1700s.

G

The faulty notions presented in these theories began with the racist assumptions of Thor Heyerdahl and have been perpetuated by writers, such as Jared Diamond, who do not have sufficient archaeological and historical understanding of the actual events which occurred on Easter Island. The real truth regarding the tremendous social devastation which occurred on Easter Island is that it was a direct consequence of the inhumane behavior of many of the first European visitors, particularly the slavers who raped and murdered the islanders, introduced smallpox and other diseases, and brutally removed the natives to mainland South America.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dcc0d1c0-d542-5460-a6fe-7e42b586fb55', '86705068-f802-5ba1-9832-80772f918964', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-xi
, in boxes
1-4
on your answer sheet.
NB
There are more headings than paragraphs
List of headings
i
The famous moai
ii
The status represented symbols of combined purposes
iii
The ancient spots which indicate the scientific application
iv
The story of the name
v
Early immigrants, rise and prosperity
vi
The geology of Easter Island
vii
The begin of Thor Heyerdahl’s discovery
viii
The countering explanation to the misconceptions politically manipulated
ix
Symbols of authority and power
x
The Navel of the World
xi
The Norwegian Invaders’ legacy
Example: Paragraph
A
iv
1
Paragraph
B
Example: Paragraph
C
i
2
Paragraph
D
3
Paragraph
E
4
Paragraph
G

1 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f1795e5-17ba-55fe-90f8-1939376d93e9', 'dcc0d1c0-d542-5460-a6fe-7e42b586fb55', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49cb426c-6d21-55a4-b746-8fec01a18d3c', 'dcc0d1c0-d542-5460-a6fe-7e42b586fb55', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00b76760-ed05-50cf-a3a7-1a2ba1b66cbc', 'dcc0d1c0-d542-5460-a6fe-7e42b586fb55', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8fadeb3-00c5-57a7-9c54-52e512d085e2', 'dcc0d1c0-d542-5460-a6fe-7e42b586fb55', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0503311f-dc94-5ecd-b1f4-66e7f84bce6f', 'dcc0d1c0-d542-5460-a6fe-7e42b586fb55', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53db8e94-7c9f-505e-bd95-1c83f0a5de54', 'dcc0d1c0-d542-5460-a6fe-7e42b586fb55', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2db228c5-ccf1-5a98-85f4-1e8f7d2bf62c', 'dcc0d1c0-d542-5460-a6fe-7e42b586fb55', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa1d50d4-9eb4-51de-ab5b-c0430e741634', 'dcc0d1c0-d542-5460-a6fe-7e42b586fb55', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aaee21b8-9891-58e8-bbfb-d1deec7b63cf', 'dcc0d1c0-d542-5460-a6fe-7e42b586fb55', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9366419d-6ab0-517c-b383-8a35fcc4392b', 'dcc0d1c0-d542-5460-a6fe-7e42b586fb55', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0d08db5-f4e8-5f37-9a80-91a9f1a045db', 'dcc0d1c0-d542-5460-a6fe-7e42b586fb55', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', '86705068-f802-5ba1-9832-80772f918964', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-xi
, in boxes
1-4
on your answer sheet.
NB
There are more headings than paragraphs
List of headings
i
The famous moai
ii
The status represented symbols of combined purposes
iii
The ancient spots which indicate the scientific application
iv
The story of the name
v
Early immigrants, rise and prosperity
vi
The geology of Easter Island
vii
The begin of Thor Heyerdahl’s discovery
viii
The countering explanation to the misconceptions politically manipulated
ix
Symbols of authority and power
x
The Navel of the World
xi
The Norwegian Invaders’ legacy
Example: Paragraph
A
iv
1
Paragraph
B
Example: Paragraph
C
i
2
Paragraph
D
3
Paragraph
E
4
Paragraph
G

2 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a3b41a8-bc6b-56d5-a0ae-63055a509cf7', 'ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6568879-29df-5648-b737-7c3852f86347', 'ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0dcea99f-6551-5c03-a754-01cb1b0e757f', 'ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b860fb3-4077-54c4-bce3-e4600c0639c6', 'ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed1173df-ddd4-522a-ad4b-20bc3dff7cc0', 'ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('928d8227-f828-56e0-8c96-00b36e908192', 'ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7266977-3b02-5dc3-8dbd-f79409e0756d', 'ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9e990cc-6a85-5785-babd-5a11d1ab0bd5', 'ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7e006c1-c49a-5c06-bbca-160ef15cc09d', 'ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('077e08e4-4b08-5275-9d33-28731e1bab83', 'ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a69a73b4-e0a1-52b8-ae6b-165d3f29d77f', 'ebdcc6b4-eaa6-58e5-aa1a-89fe00ebc09f', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e96a9879-5871-59e9-8240-36c05f737d40', '86705068-f802-5ba1-9832-80772f918964', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-xi
, in boxes
1-4
on your answer sheet.
NB
There are more headings than paragraphs
List of headings
i
The famous moai
ii
The status represented symbols of combined purposes
iii
The ancient spots which indicate the scientific application
iv
The story of the name
v
Early immigrants, rise and prosperity
vi
The geology of Easter Island
vii
The begin of Thor Heyerdahl’s discovery
viii
The countering explanation to the misconceptions politically manipulated
ix
Symbols of authority and power
x
The Navel of the World
xi
The Norwegian Invaders’ legacy
Example: Paragraph
A
iv
1
Paragraph
B
Example: Paragraph
C
i
2
Paragraph
D
3
Paragraph
E
4
Paragraph
G

3 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7eac6481-7093-5d90-9b3d-00bb82891d25', 'e96a9879-5871-59e9-8240-36c05f737d40', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82f2d121-7959-5de2-97b1-3bfe34c89916', 'e96a9879-5871-59e9-8240-36c05f737d40', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a5343a8-e5d3-525b-8972-2374b8129b28', 'e96a9879-5871-59e9-8240-36c05f737d40', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4b40b87-2e61-5053-b454-9680e310e778', 'e96a9879-5871-59e9-8240-36c05f737d40', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('280ca8af-5088-5d61-907b-a5262b958d95', 'e96a9879-5871-59e9-8240-36c05f737d40', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b39045ba-4dae-53e0-8ab1-6ea89d1768ae', 'e96a9879-5871-59e9-8240-36c05f737d40', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1c9f05f-848d-5422-ad3d-52424d0114f2', 'e96a9879-5871-59e9-8240-36c05f737d40', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6693f6e6-7999-5166-8081-cd3687018884', 'e96a9879-5871-59e9-8240-36c05f737d40', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74979286-0517-5725-9f02-3fdf4560ea79', 'e96a9879-5871-59e9-8240-36c05f737d40', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b445ae7-d54a-5552-946b-7d3105112f1f', 'e96a9879-5871-59e9-8240-36c05f737d40', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3526cb6d-81c2-5d58-abf8-0065a9020a4b', 'e96a9879-5871-59e9-8240-36c05f737d40', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6024a5cd-5077-5c3c-8623-d10887606cb2', '86705068-f802-5ba1-9832-80772f918964', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-xi
, in boxes
1-4
on your answer sheet.
NB
There are more headings than paragraphs
List of headings
i
The famous moai
ii
The status represented symbols of combined purposes
iii
The ancient spots which indicate the scientific application
iv
The story of the name
v
Early immigrants, rise and prosperity
vi
The geology of Easter Island
vii
The begin of Thor Heyerdahl’s discovery
viii
The countering explanation to the misconceptions politically manipulated
ix
Symbols of authority and power
x
The Navel of the World
xi
The Norwegian Invaders’ legacy
Example: Paragraph
A
iv
1
Paragraph
B
Example: Paragraph
C
i
2
Paragraph
D
3
Paragraph
E
4
Paragraph
G

4 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06952ccb-c9b6-5176-995b-4c8031fa69b8', '6024a5cd-5077-5c3c-8623-d10887606cb2', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03006c26-f262-5b28-a2ae-e4492e18da04', '6024a5cd-5077-5c3c-8623-d10887606cb2', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('528e5b16-4235-5179-91d1-1242f9c1d104', '6024a5cd-5077-5c3c-8623-d10887606cb2', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6aa08412-1ae9-5155-b1fe-4ef2b46909d5', '6024a5cd-5077-5c3c-8623-d10887606cb2', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36542ade-7185-5808-8fbb-3bf9ec0dfecf', '6024a5cd-5077-5c3c-8623-d10887606cb2', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76b17ad3-b668-5eba-a597-4574a7125751', '6024a5cd-5077-5c3c-8623-d10887606cb2', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f047a3af-0271-5526-9e1d-470cbbe388ec', '6024a5cd-5077-5c3c-8623-d10887606cb2', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc0eeaf6-cfc7-53a0-8e09-7da1ee8dabd8', '6024a5cd-5077-5c3c-8623-d10887606cb2', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12119bc2-5be2-5ec1-96ad-be510700dd2e', '6024a5cd-5077-5c3c-8623-d10887606cb2', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68790d4e-f528-53c3-aa95-075cc2b8beb5', '6024a5cd-5077-5c3c-8623-d10887606cb2', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1e66e93-41f7-5dfd-a4e0-36d0492969d2', '6024a5cd-5077-5c3c-8623-d10887606cb2', 11, $md$xi$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('70cd4b04-ac25-54ba-8578-315938431313', '86705068-f802-5ba1-9832-80772f918964', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage?
In boxes
5-10
on your answer sheet write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The first inhabitants of Easter Island are Polynesian, from the Marquesas or Society islands.
6
Construction of some moai statues on the island was not finished.
7
The Moai can be found not only on Easter Island but also elsewhere in Polynesia.
8
Most archaeologists recognised the religious and astronomical functions for an ancient society.
9
The structures of Easter Island work as an astronomical outpost for extraterrestrial visitors.
10
the theory that depleted natural resources leading to the fail of Easter Island actual have a distorted perspective

5 ____ The first inhabitants of Easter Island are Polynesian, from the Marquesas or Society islands.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bff4c25-3c40-58e8-ace2-a99e1fb2c977', '70cd4b04-ac25-54ba-8578-315938431313', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4165e327-e4ca-58fc-8c30-5ff083bfed3e', '70cd4b04-ac25-54ba-8578-315938431313', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b53f7df-dba3-5f88-bf9f-f162e6925668', '70cd4b04-ac25-54ba-8578-315938431313', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d4e0f4ec-ee0c-556f-84d4-bc0c80dc4a43', '86705068-f802-5ba1-9832-80772f918964', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage?
In boxes
5-10
on your answer sheet write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The first inhabitants of Easter Island are Polynesian, from the Marquesas or Society islands.
6
Construction of some moai statues on the island was not finished.
7
The Moai can be found not only on Easter Island but also elsewhere in Polynesia.
8
Most archaeologists recognised the religious and astronomical functions for an ancient society.
9
The structures of Easter Island work as an astronomical outpost for extraterrestrial visitors.
10
the theory that depleted natural resources leading to the fail of Easter Island actual have a distorted perspective

6 ____ Construction of some moai statues on the island was not finished.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3c3bd4e-3b39-5d7f-952e-677a4cd494cf', 'd4e0f4ec-ee0c-556f-84d4-bc0c80dc4a43', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e63fc79-b55c-5edd-af26-4a43d3fd497f', 'd4e0f4ec-ee0c-556f-84d4-bc0c80dc4a43', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75eea029-17f3-55f3-94fe-c31e2d8be0fc', 'd4e0f4ec-ee0c-556f-84d4-bc0c80dc4a43', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c6047e36-611f-5d7d-81be-f83f33b9a9c2', '86705068-f802-5ba1-9832-80772f918964', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage?
In boxes
5-10
on your answer sheet write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The first inhabitants of Easter Island are Polynesian, from the Marquesas or Society islands.
6
Construction of some moai statues on the island was not finished.
7
The Moai can be found not only on Easter Island but also elsewhere in Polynesia.
8
Most archaeologists recognised the religious and astronomical functions for an ancient society.
9
The structures of Easter Island work as an astronomical outpost for extraterrestrial visitors.
10
the theory that depleted natural resources leading to the fail of Easter Island actual have a distorted perspective

7 ____ The Moai can be found not only on Easter Island but also elsewhere in Polynesia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3be5c4be-b44a-5846-be60-0c79d9238f1d', 'c6047e36-611f-5d7d-81be-f83f33b9a9c2', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('827eeb06-b04d-5faf-b5dd-44c6b6c602cb', 'c6047e36-611f-5d7d-81be-f83f33b9a9c2', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fcbb5ac-b652-597f-87ac-63d3d5ba8935', 'c6047e36-611f-5d7d-81be-f83f33b9a9c2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8385d873-90d7-5303-8a26-a8e5a466c885', '86705068-f802-5ba1-9832-80772f918964', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage?
In boxes
5-10
on your answer sheet write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The first inhabitants of Easter Island are Polynesian, from the Marquesas or Society islands.
6
Construction of some moai statues on the island was not finished.
7
The Moai can be found not only on Easter Island but also elsewhere in Polynesia.
8
Most archaeologists recognised the religious and astronomical functions for an ancient society.
9
The structures of Easter Island work as an astronomical outpost for extraterrestrial visitors.
10
the theory that depleted natural resources leading to the fail of Easter Island actual have a distorted perspective

8 ____ Most archaeologists recognised the religious and astronomical functions for an ancient society.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87fa3b5a-6c43-53fa-a608-849b715fdbd7', '8385d873-90d7-5303-8a26-a8e5a466c885', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0756fd1-780c-570b-a1e5-94081d67ef71', '8385d873-90d7-5303-8a26-a8e5a466c885', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72c203f9-c2fc-540d-9a6e-0d20afb371c0', '8385d873-90d7-5303-8a26-a8e5a466c885', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e84735d8-1d83-50e8-bef0-408e06affa2c', '86705068-f802-5ba1-9832-80772f918964', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage?
In boxes
5-10
on your answer sheet write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The first inhabitants of Easter Island are Polynesian, from the Marquesas or Society islands.
6
Construction of some moai statues on the island was not finished.
7
The Moai can be found not only on Easter Island but also elsewhere in Polynesia.
8
Most archaeologists recognised the religious and astronomical functions for an ancient society.
9
The structures of Easter Island work as an astronomical outpost for extraterrestrial visitors.
10
the theory that depleted natural resources leading to the fail of Easter Island actual have a distorted perspective

9 ____ The structures of Easter Island work as an astronomical outpost for extraterrestrial visitors.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c53d44d8-1b3c-5614-b6c1-8a198a0c909d', 'e84735d8-1d83-50e8-bef0-408e06affa2c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2f14054-ef43-57da-8d6b-570ed8c97d5a', 'e84735d8-1d83-50e8-bef0-408e06affa2c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20a92a8e-1467-5730-9785-145a11448f58', 'e84735d8-1d83-50e8-bef0-408e06affa2c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4a6da87e-8f1b-51a1-b161-df3df79717d5', '86705068-f802-5ba1-9832-80772f918964', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage?
In boxes
5-10
on your answer sheet write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The first inhabitants of Easter Island are Polynesian, from the Marquesas or Society islands.
6
Construction of some moai statues on the island was not finished.
7
The Moai can be found not only on Easter Island but also elsewhere in Polynesia.
8
Most archaeologists recognised the religious and astronomical functions for an ancient society.
9
The structures of Easter Island work as an astronomical outpost for extraterrestrial visitors.
10
the theory that depleted natural resources leading to the fail of Easter Island actual have a distorted perspective

10 ____ the theory that depleted natural resources leading to the fail of Easter Island actual have a distorted perspective$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3c8580d-24de-5b9f-94f5-4ebf3d059bf6', '4a6da87e-8f1b-51a1-b161-df3df79717d5', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1624006b-d326-5984-8520-1a74c4be9731', '4a6da87e-8f1b-51a1-b161-df3df79717d5', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9c72cc7-1576-5569-961c-7ff45e809f41', '4a6da87e-8f1b-51a1-b161-df3df79717d5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('17a037a8-6f51-5a9d-acd0-3f124cc6ba4c', '86705068-f802-5ba1-9832-80772f918964', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Many theories speculated that Easter Island’s fall around the era of the initial European contact. Some say the resources are depleted by a
11
; The erroneous theories began with a root of the
12
advanced by some scholars. Early writers did not have adequate
13
understandings to comprehend the true nature of events on the island. The social devastation was, in fact, a direct result of
14
of the first European settlers.

Many theories speculated that Easter Island’s fall around the era of the initial European contact. Some say the resources are depleted by a 11 ____ ; The erroneous theories began with a root of the 12 ____ advanced by some scholars. Early writers did not have adequate 13 ____ understandings to comprehend the true nature of events on the island. The social devastation was, in fact, a direct result of 14 ____ of the first European settlers.$md$, NULL, ARRAY['.*growing.*population.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5d5b8a75-20a9-5463-8898-4fb4fa4ae1cb', '86705068-f802-5ba1-9832-80772f918964', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Many theories speculated that Easter Island’s fall around the era of the initial European contact. Some say the resources are depleted by a
11
; The erroneous theories began with a root of the
12
advanced by some scholars. Early writers did not have adequate
13
understandings to comprehend the true nature of events on the island. The social devastation was, in fact, a direct result of
14
of the first European settlers.

Many theories speculated that Easter Island’s fall around the era of the initial European contact. Some say the resources are depleted by a 11 ____ ; The erroneous theories began with a root of the 12 ____ advanced by some scholars. Early writers did not have adequate 13 ____ understandings to comprehend the true nature of events on the island. The social devastation was, in fact, a direct result of 14 ____ of the first European settlers.$md$, NULL, ARRAY['.*growing.*population.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('77e9a5bd-a1d8-511d-9854-8d30d028729f', '86705068-f802-5ba1-9832-80772f918964', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Many theories speculated that Easter Island’s fall around the era of the initial European contact. Some say the resources are depleted by a
11
; The erroneous theories began with a root of the
12
advanced by some scholars. Early writers did not have adequate
13
understandings to comprehend the true nature of events on the island. The social devastation was, in fact, a direct result of
14
of the first European settlers.

Many theories speculated that Easter Island’s fall around the era of the initial European contact. Some say the resources are depleted by a 11 ____ ; The erroneous theories began with a root of the 12 ____ advanced by some scholars. Early writers did not have adequate 13 ____ understandings to comprehend the true nature of events on the island. The social devastation was, in fact, a direct result of 14 ____ of the first European settlers.$md$, NULL, ARRAY['.*growing.*population.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('96d18c24-69ea-5b8c-b14e-48148250a7d3', '86705068-f802-5ba1-9832-80772f918964', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Many theories speculated that Easter Island’s fall around the era of the initial European contact. Some say the resources are depleted by a
11
; The erroneous theories began with a root of the
12
advanced by some scholars. Early writers did not have adequate
13
understandings to comprehend the true nature of events on the island. The social devastation was, in fact, a direct result of
14
of the first European settlers.

Many theories speculated that Easter Island’s fall around the era of the initial European contact. Some say the resources are depleted by a 11 ____ ; The erroneous theories began with a root of the 12 ____ advanced by some scholars. Early writers did not have adequate 13 ____ understandings to comprehend the true nature of events on the island. The social devastation was, in fact, a direct result of 14 ____ of the first European settlers.$md$, NULL, ARRAY['.*growing.*population.*']);

COMMIT;
