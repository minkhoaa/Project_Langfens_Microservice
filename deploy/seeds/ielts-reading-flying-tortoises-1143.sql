BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-flying-tortoises-1143'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-flying-tortoises-1143';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-flying-tortoises-1143';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-flying-tortoises-1143';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('0a2efa73-a522-5a69-a70b-98f0f9a78102', 'ielts-reading-flying-tortoises-1143', $t$Flying tortoises$t$, $md$## Flying tortoises

Nguồn:
- Test: https://mini-ielts.com/1143/reading/flying-tortoises
- Solution: https://mini-ielts.com/1143/view-solution/reading/flying-tortoises$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7c9da94b-0edf-5450-87e1-981f6a06d884', '0a2efa73-a522-5a69-a70b-98f0f9a78102', 1, $t$Reading — Flying tortoises$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Flying tortoises

An airborne reintroduction programme has helped conservationists take significant steps to protect the endangered Galapagos tortoise.

A

Forests of spiny cacti cover much of the uneven lava plains that separate the interior of the Galapagos island of Isabela from the Pacific Ocean. With its five distinct volcanoes, the island resembles a lunar landscape. Only the thick vegetation at the skirt of the often cloud-covered peak of Sierra Negra offers respite from the barren terrain below.

This inhospitable environment is home to the giant Galapagos tortoise . Some time after the Galapagos’s birth, around five million years ago, the islands were colonised by one or more tortoises from mainland South America. As these ancestral tortoises settled on the individual islands, the different populations adapted to their unique environments, giving rise to at least 14 different subspecies. Island life agreed with them. In the absence of significant predators, they grew to become the largest and longest-living tortoises on the planet, weighing more than 400 kilograms, occasionally exceeding 1,8 metres in length and living for more than a century.

B

Before human arrival, the archipelago's tortoises numbered in the hundreds of thousands. From the 17th century onwards , pirates took a few on board for food , but the arrival of whaling ships in the 1790s saw this exploitation grow exponentially. Relatively immobile and capable of surviving for months without food or water, the tortoises were taken on board these ships to act as food supplies during long ocean passages. Sometimes, their bodies were processed into high- grade oil .

In total, an estimated 200,000 animals were taken from the archipelago before the 20th century. This historical exploitation was then exacerbated when settlers came to the islands. They hunted the tortoises and destroyed their habitat to clear land for agriculture. They also introduced alien species - ranging from cattle, pigs, goats, rats and dogs to plants and ants - that either prey on the eggs and young tortoises or damage or destroy their habitat.

C

Today, only 11 of the original subspecies survive and of these, several are highly endangered. In 1989, work began on a tortoise-breeding centre just outside the town of Puerto Villamil on Isabela, dedicated to protecting the island’s tortoise populations . The centre’s captive-breeding programme proved to be extremely successful, and it eventually had to deal with an overpopulation problem.

D

The problem was also a pressing one. Captive-bred tortoises can’t be reintroduced into the wild until they’re at least five years old and weigh at least 4,5 kilograms, at which point their size and weight - and their hardened shells - are sufficient to protect them from predators. But if people wait too long after that point, the tortoises eventually become too large to transport.

E

For years, repatriation efforts were carried out in small numbers, with the tortoises carried on the backs of men over weeks of long, treacherous hikes along narrow trails. But in November 2010, the environmentalist and Galapagos National Park liaison officer Godfrey Merlin, a visiting private motor yacht captain and a helicopter pilot gathered around a table in a small cafe in Puerto Ayora on the island of Santa Cruz to work out more ambitious reintroduction . The aim was to use a helicopter to move 300 of the breeding centre’s tortoises to various locations close to Sierra Negra.

F

This unprecedented effort was made possible by the owners of the 67-metre yacht White Cloud, who provided the Galapagos National Park with free use of their helicopter and its experienced pilot, as well as the logistical support of the yacht, its captain and crew. Originally an air ambulance, the yacht’s helicopter has a rear double door and a large internal space that’s well suited for cargo, so a custom crate was designed to hold up to 33 tortoises with a total weight of about 150 kilograms. This weight, together with that of the fuel, pilot and four crew, approached the helicopter’s maximum payload, and there were times when it was clearly right on the edge of the helicopter’s capabilities. During a period of three days, a group of volunteers from the breeding centre worked around the clock to prepare the young tortoises for transport. Meanwhile, park wardens, dropped off ahead of time in remote locations, cleared landing sites within the thick brush, cacti and lava rocks.

G

Upon their release, the juvenile tortoises quickly spread out over their ancestral territory, investigating their new surroundings and feeding on the vegetation. Eventually, one tiny tortoise came across a fully grown giant who had been lumbering around the island for around a hundred years . The two stood side by side, a powerful symbol of the regeneration of an ancient species.

----------------------------------------------------

Great thanks to volunteer Lan Nguyen has contributed these explanations markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('79c01f73-f2cd-57c9-bfaf-e917df0041c4', '7c9da94b-0edf-5450-87e1-981f6a06d884', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

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
The importance of getting the timing right
ii
Young meets old
iii
Developments to the disadvantage of tortoise
populations
iv
Planning a bigger idea
v
Tortoises populate the islands
vi
Carrying out a carefully prepared operation
vii
Looking for a home for the islands’ tortoises
viii
The start of the conservation project

1 ____ Paragraph A Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91458d15-65ad-5ac6-b6a5-71c76f484190', '79c01f73-f2cd-57c9-bfaf-e917df0041c4', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cad8cca4-bb02-5939-843f-063a7b7e3f05', '79c01f73-f2cd-57c9-bfaf-e917df0041c4', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e40dd43-3fa1-5d7f-981f-9f7a8da4aef5', '79c01f73-f2cd-57c9-bfaf-e917df0041c4', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f44b106-18a6-54a5-bc21-cf948bedc2ce', '79c01f73-f2cd-57c9-bfaf-e917df0041c4', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50354b88-04a5-561c-ad69-2dc11784894d', '79c01f73-f2cd-57c9-bfaf-e917df0041c4', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31670395-666e-5636-9b87-20af46fc40eb', '79c01f73-f2cd-57c9-bfaf-e917df0041c4', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bece96b-78fd-57d0-a754-93a0d28805e2', '79c01f73-f2cd-57c9-bfaf-e917df0041c4', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8939a28-d6bb-5a2c-b31f-2946a6c6f9cb', '79c01f73-f2cd-57c9-bfaf-e917df0041c4', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b7e12c0d-70d2-5b05-a2f5-1a4ef02d2a96', '7c9da94b-0edf-5450-87e1-981f6a06d884', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

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
The importance of getting the timing right
ii
Young meets old
iii
Developments to the disadvantage of tortoise
populations
iv
Planning a bigger idea
v
Tortoises populate the islands
vi
Carrying out a carefully prepared operation
vii
Looking for a home for the islands’ tortoises
viii
The start of the conservation project

2 ____ Paragraph B Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d00364b-dc5a-53d8-8510-d4db8cfc80ea', 'b7e12c0d-70d2-5b05-a2f5-1a4ef02d2a96', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1fec3b4-42a9-56dd-9f64-1a14555ad0d4', 'b7e12c0d-70d2-5b05-a2f5-1a4ef02d2a96', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46608f5b-d3f5-5e90-be66-cc54f47782f3', 'b7e12c0d-70d2-5b05-a2f5-1a4ef02d2a96', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87e0666a-5f47-5ca1-8cf6-496b4843d191', 'b7e12c0d-70d2-5b05-a2f5-1a4ef02d2a96', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e697e4a-5350-546f-beb5-a0dc8eefa26f', 'b7e12c0d-70d2-5b05-a2f5-1a4ef02d2a96', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbce7ef5-c14f-56f8-ac5a-7c7014d7674b', 'b7e12c0d-70d2-5b05-a2f5-1a4ef02d2a96', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac63b386-cb74-5bbf-a77d-9adb0fff559f', 'b7e12c0d-70d2-5b05-a2f5-1a4ef02d2a96', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bf0c154-7d10-5ef9-ab55-f7b4cbf17aa0', 'b7e12c0d-70d2-5b05-a2f5-1a4ef02d2a96', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0c96bfc9-98e3-5f01-8186-0d2961ffc409', '7c9da94b-0edf-5450-87e1-981f6a06d884', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

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
The importance of getting the timing right
ii
Young meets old
iii
Developments to the disadvantage of tortoise
populations
iv
Planning a bigger idea
v
Tortoises populate the islands
vi
Carrying out a carefully prepared operation
vii
Looking for a home for the islands’ tortoises
viii
The start of the conservation project

3 ____ Paragraph C Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('928854b5-7b08-5b18-bfbb-ef4fd6f6c43d', '0c96bfc9-98e3-5f01-8186-0d2961ffc409', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3f6a1a6-5259-5dd6-b6c2-00f8705e5df8', '0c96bfc9-98e3-5f01-8186-0d2961ffc409', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29e3723e-75d0-5216-a916-e589be461ae3', '0c96bfc9-98e3-5f01-8186-0d2961ffc409', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66a11d4d-f3fa-54cf-9574-5674f6f95121', '0c96bfc9-98e3-5f01-8186-0d2961ffc409', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e256142-44db-5784-bccf-6dc12baf3886', '0c96bfc9-98e3-5f01-8186-0d2961ffc409', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81ac6d8d-0ea0-5538-a089-f5627db0538e', '0c96bfc9-98e3-5f01-8186-0d2961ffc409', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61269868-cb94-51bc-97b2-2f53762c91b2', '0c96bfc9-98e3-5f01-8186-0d2961ffc409', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a50991c-2c0e-5d89-9ef8-3468b4d8d60f', '0c96bfc9-98e3-5f01-8186-0d2961ffc409', 8, $md$viii$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a95ab748-da37-5d84-b3e6-c341cf1980c8', '7c9da94b-0edf-5450-87e1-981f6a06d884', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

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
The importance of getting the timing right
ii
Young meets old
iii
Developments to the disadvantage of tortoise
populations
iv
Planning a bigger idea
v
Tortoises populate the islands
vi
Carrying out a carefully prepared operation
vii
Looking for a home for the islands’ tortoises
viii
The start of the conservation project

4 ____ Paragraph D Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b05cccf-659e-5f19-a542-b78bb4d76d76', 'a95ab748-da37-5d84-b3e6-c341cf1980c8', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e6ac3f8-cdfc-5535-83aa-43d063e51680', 'a95ab748-da37-5d84-b3e6-c341cf1980c8', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88bdf41d-0d3f-5eb8-b2eb-30548f69a94c', 'a95ab748-da37-5d84-b3e6-c341cf1980c8', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea4ece96-50c0-52b1-aac8-ac10bff64e1e', 'a95ab748-da37-5d84-b3e6-c341cf1980c8', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e515657-2f6b-5187-a6ae-488ab2fb727f', 'a95ab748-da37-5d84-b3e6-c341cf1980c8', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44c18db5-6079-5501-96fb-0e93a289441c', 'a95ab748-da37-5d84-b3e6-c341cf1980c8', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8669663-982c-5064-8fba-c7a112d47298', 'a95ab748-da37-5d84-b3e6-c341cf1980c8', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70d1870a-966d-568a-b439-b170067cb729', 'a95ab748-da37-5d84-b3e6-c341cf1980c8', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bd0d7f6f-181e-5efd-bf4d-6d6c110c4abb', '7c9da94b-0edf-5450-87e1-981f6a06d884', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

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
The importance of getting the timing right
ii
Young meets old
iii
Developments to the disadvantage of tortoise
populations
iv
Planning a bigger idea
v
Tortoises populate the islands
vi
Carrying out a carefully prepared operation
vii
Looking for a home for the islands’ tortoises
viii
The start of the conservation project

5 ____ Paragraph E Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c997ac8-5a79-551b-912b-5bf8ab6efea7', 'bd0d7f6f-181e-5efd-bf4d-6d6c110c4abb', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d49aa10-1c38-543d-8aba-69106c03de01', 'bd0d7f6f-181e-5efd-bf4d-6d6c110c4abb', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebaf9f28-21b8-5504-872e-0b0a75f8ad1b', 'bd0d7f6f-181e-5efd-bf4d-6d6c110c4abb', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e59f293-854d-5025-989a-7ac69285bbd2', 'bd0d7f6f-181e-5efd-bf4d-6d6c110c4abb', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7cf19b1-21bc-5508-b724-0494e093fe5f', 'bd0d7f6f-181e-5efd-bf4d-6d6c110c4abb', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d5e65fd-e243-5b50-ad53-855f8920dacc', 'bd0d7f6f-181e-5efd-bf4d-6d6c110c4abb', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51e35bf2-41b5-5632-a8d5-21ebe2acc9c7', 'bd0d7f6f-181e-5efd-bf4d-6d6c110c4abb', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffe14865-a400-5b57-9639-e614c9148af8', 'bd0d7f6f-181e-5efd-bf4d-6d6c110c4abb', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cdf337f5-f20b-510e-8361-771030315d31', '7c9da94b-0edf-5450-87e1-981f6a06d884', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

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
The importance of getting the timing right
ii
Young meets old
iii
Developments to the disadvantage of tortoise
populations
iv
Planning a bigger idea
v
Tortoises populate the islands
vi
Carrying out a carefully prepared operation
vii
Looking for a home for the islands’ tortoises
viii
The start of the conservation project

6 ____ Paragraph F Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8aa95c70-3176-59c1-a08d-2c3d2fd8e75e', 'cdf337f5-f20b-510e-8361-771030315d31', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a333aa18-d061-5277-8567-e5096dead61d', 'cdf337f5-f20b-510e-8361-771030315d31', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb8eae30-0424-5219-8a6e-a2118b47c7e7', 'cdf337f5-f20b-510e-8361-771030315d31', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81411b32-2e65-5ee5-962a-a54462ff009a', 'cdf337f5-f20b-510e-8361-771030315d31', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6df4997d-79f3-524e-b735-5c3ebe99ec30', 'cdf337f5-f20b-510e-8361-771030315d31', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36ee40dc-8167-5554-8f72-bafadb103db2', 'cdf337f5-f20b-510e-8361-771030315d31', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e72a383-d65e-56dc-aacc-7b2a60bd0095', 'cdf337f5-f20b-510e-8361-771030315d31', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('655172bf-2209-5805-981a-75e4a894a710', 'cdf337f5-f20b-510e-8361-771030315d31', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a693fa34-b1f8-50d0-9739-1a0032c086d0', '7c9da94b-0edf-5450-87e1-981f6a06d884', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

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
The importance of getting the timing right
ii
Young meets old
iii
Developments to the disadvantage of tortoise
populations
iv
Planning a bigger idea
v
Tortoises populate the islands
vi
Carrying out a carefully prepared operation
vii
Looking for a home for the islands’ tortoises
viii
The start of the conservation project

7 ____ Paragraph G Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e269f7f7-f3d8-5ddb-922a-34ec7dd9fa68', 'a693fa34-b1f8-50d0-9739-1a0032c086d0', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a4f610b-2aa5-5722-bc07-e0ab579d776b', 'a693fa34-b1f8-50d0-9739-1a0032c086d0', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('125cd9ea-8b5f-5d75-9920-8dd6b8862d99', 'a693fa34-b1f8-50d0-9739-1a0032c086d0', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77ad5984-bae8-5dc3-9bf1-e639b904b95f', 'a693fa34-b1f8-50d0-9739-1a0032c086d0', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88c15078-f68c-57d9-a175-c6b20fc683ee', 'a693fa34-b1f8-50d0-9739-1a0032c086d0', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('028cd946-2cef-5bf9-b747-7f89c1acf551', 'a693fa34-b1f8-50d0-9739-1a0032c086d0', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c50b8ca-03ba-58f9-97b2-5648efcebd0d', 'a693fa34-b1f8-50d0-9739-1a0032c086d0', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b0c9056-794d-59c1-baaa-8a926b301b7e', 'a693fa34-b1f8-50d0-9739-1a0032c086d0', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a8c82313-b987-52d4-b66a-f26adad70248', '7c9da94b-0edf-5450-87e1-981f6a06d884', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The decline of the Galapagos tortoise
• Originally from mainland South America
• Numbers on Galapagos islands increased, due to lack of predators
• 17th century: small numbers taken onto ships used by
8
Locate
• 1790s: very large numbers taken onto whaling ships, kept for
9
Locate
and also used to produce
10
Locate
• Hunted by
11
on islands
Locate
• Habitat destruction: for the establishment of agriculture and by various
12
Locate
not native to the islands, which also fed on baby tortoises and tortoises’
13
Locate

• 17th century: small numbers taken onto ships used by 8 ____ Locate$md$, NULL, ARRAY['.*pirates.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fd4c5ba1-917f-5d40-b272-010f42648bdb', '7c9da94b-0edf-5450-87e1-981f6a06d884', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The decline of the Galapagos tortoise
• Originally from mainland South America
• Numbers on Galapagos islands increased, due to lack of predators
• 17th century: small numbers taken onto ships used by
8
Locate
• 1790s: very large numbers taken onto whaling ships, kept for
9
Locate
and also used to produce
10
Locate
• Hunted by
11
on islands
Locate
• Habitat destruction: for the establishment of agriculture and by various
12
Locate
not native to the islands, which also fed on baby tortoises and tortoises’
13
Locate

• 1790s: very large numbers taken onto whaling ships, kept for 9 ____ Locate and also used to produce 10 ____ Locate$md$, NULL, ARRAY['.*food.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('27b79e81-9cdf-5cfc-8e0d-d136284949c5', '7c9da94b-0edf-5450-87e1-981f6a06d884', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The decline of the Galapagos tortoise
• Originally from mainland South America
• Numbers on Galapagos islands increased, due to lack of predators
• 17th century: small numbers taken onto ships used by
8
Locate
• 1790s: very large numbers taken onto whaling ships, kept for
9
Locate
and also used to produce
10
Locate
• Hunted by
11
on islands
Locate
• Habitat destruction: for the establishment of agriculture and by various
12
Locate
not native to the islands, which also fed on baby tortoises and tortoises’
13
Locate

• 1790s: very large numbers taken onto whaling ships, kept for 9 ____ Locate and also used to produce 10 ____ Locate$md$, NULL, ARRAY['.*food.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('dcb1a0a8-fd43-5362-a3db-44e71931b4d0', '7c9da94b-0edf-5450-87e1-981f6a06d884', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The decline of the Galapagos tortoise
• Originally from mainland South America
• Numbers on Galapagos islands increased, due to lack of predators
• 17th century: small numbers taken onto ships used by
8
Locate
• 1790s: very large numbers taken onto whaling ships, kept for
9
Locate
and also used to produce
10
Locate
• Hunted by
11
on islands
Locate
• Habitat destruction: for the establishment of agriculture and by various
12
Locate
not native to the islands, which also fed on baby tortoises and tortoises’
13
Locate

• Hunted by 11 ____ on islands Locate$md$, NULL, ARRAY['.*settlers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('568de73e-f402-5731-89de-1040fc96339d', '7c9da94b-0edf-5450-87e1-981f6a06d884', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The decline of the Galapagos tortoise
• Originally from mainland South America
• Numbers on Galapagos islands increased, due to lack of predators
• 17th century: small numbers taken onto ships used by
8
Locate
• 1790s: very large numbers taken onto whaling ships, kept for
9
Locate
and also used to produce
10
Locate
• Hunted by
11
on islands
Locate
• Habitat destruction: for the establishment of agriculture and by various
12
Locate
not native to the islands, which also fed on baby tortoises and tortoises’
13
Locate

• Habitat destruction: for the establishment of agriculture and by various 12 ____ Locate not native to the islands, which also fed on baby tortoises and tortoises’ 13 ____ Locate$md$, NULL, ARRAY['.*species.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f304a2ed-8a4c-5cac-9359-2eb5db59d9b9', '7c9da94b-0edf-5450-87e1-981f6a06d884', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The decline of the Galapagos tortoise
• Originally from mainland South America
• Numbers on Galapagos islands increased, due to lack of predators
• 17th century: small numbers taken onto ships used by
8
Locate
• 1790s: very large numbers taken onto whaling ships, kept for
9
Locate
and also used to produce
10
Locate
• Hunted by
11
on islands
Locate
• Habitat destruction: for the establishment of agriculture and by various
12
Locate
not native to the islands, which also fed on baby tortoises and tortoises’
13
Locate

• Habitat destruction: for the establishment of agriculture and by various 12 ____ Locate not native to the islands, which also fed on baby tortoises and tortoises’ 13 ____ Locate$md$, NULL, ARRAY['.*species.*']);

COMMIT;
