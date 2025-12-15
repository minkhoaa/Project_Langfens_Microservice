BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-new-zealand-seaweed-1075'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-new-zealand-seaweed-1075';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-new-zealand-seaweed-1075';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-new-zealand-seaweed-1075';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('22f416f0-39e6-54ce-9501-76453612b503', 'ielts-reading-new-zealand-seaweed-1075', $t$New Zealand Seaweed$t$, $md$## New Zealand Seaweed

Nguồn:
- Test: https://mini-ielts.com/1075/reading/new-zealand-seaweed
- Solution: https://mini-ielts.com/1075/view-solution/reading/new-zealand-seaweed$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1e2647b0-8e6d-5c83-97b4-182515836f49', '22f416f0-39e6-54ce-9501-76453612b503', 1, $t$Reading — New Zealand Seaweed$t$, $md$Read the passage and answer questions **1–13**.

### Passage: New Zealand Seaweed

Call us not weeds; we are flowers of the sea.

Section A - Nutritious value of seaweeds

Seaweed is a particularly nutritious food , which absorbs and concentrates traces of a wide variety of minerals necessary to the body's health. Many elements may occur in seaweed - aluminium, barium, calcium, chlorine, copper, iodine and iron, to name but a few - traces normally produced by erosion and carried to the seaweed beds by river and sea currents. Seaweeds are also rich in vita­mins: indeed, Eskimos obtain a high proportion of their bodily requirements of vitamin C from the seaweeds they eat.

The nutritive value of seaweed has long been recognised. For instance, there is a remarkably low incidence of goitre amongst the Japanese, and for that mat­ter, amongst our own Maori people, who have always eaten seaweeds, and this may well be attributed to the high iodine content of this food. Research into old Maori eating customs shows that jellies were made using seaweeds, fresh fruit and nuts, fuchsia and tutu berries, cape gooseberries, and many other fruits which either grew here naturally or were sown from seeds brought by settlers and explorers.

Section B - Various products of seaweeds

New Zealand lays claim to approximately 700 species of seaweed, some of which have no representation outside this country. Of several species grown worldwide, New Zealand also has a particularly large share. For example, it is estimated that New Zealand has some 30 species of Gigartina, a close relative of carrageen or Irish moss. These are often referred to as the New Zealand carrageens . The gel-forming substance called agar which can be extracted from this species gives them great commercial application in seameal, from which seameal custard is made, and in cough mixture , confectionery, cosmetics, the canning, paint and leather industries, the manufacture of duplicating pads, and in toothpaste. In fact, during World War II, New Zealand Gigartina were sent toAustralia to be used in toothpaste. Section C - Underuse of native species

Yet although New Zealand has so much of the commercially profitable red sea­weeds, several of which are a source of agar (Pterocladia, Gelidium, Chondrus, Gigartina), before 1940 relatively little use was made of them. New Zealand used to import the Northern Hemisphere Irish moss (Chondrus crispus) from England and ready-made agar from Japan. Although distribution of the Gigartina is confined to certain areas according to species, it is only on the east coast of the North Island that its occurrence is rare. And even then, the east coast, and the area around Hokiangna, have a considerable supply of the two species of Pterocladia from which agar is also available. Happily, New Zealand-made agar is now obtainable in health food shops.

Section D - Locations and features of different seaweeds Seaweeds are divided into three classes determined by colour - red, brown and green - and each tends to live in a specific location . However, except for the unmistakable sea lettuce (Ulva), few are totally one colour; and especially when dry, some species can change colour quite significantly - a brown one may turn quite black, or a red one appear black, brown, pink or purple.

Identification is nevertheless facilitated by the fact that the factors which de­termine where a seaweed will grow are quite precise, and they therefore tend to occur in very well-defined zones. Although there are exceptions, the green seaweeds are mainly shallow-water algae ; the browns belong to medium depths, and the reds are plants of the deeper water . Flat rock surfaces near mid-level tides are the most usual habitat of sea bombs, Venus’ necklace and most brown seaweeds. This is also the location of the purple laver or Maori karengo, which looks rather like a reddish-purple lettuce. Deep-water rocks on open coasts, exposed only at very low tide, are usually the site of bull kelp, strap weeds and similar tough specimens. Those species able to resist long periods of exposure to the sun and air are usually found on the upper shore, while those less able to stand such exposure occur nearer to or below the low-water mark. Radiation from the sun, the temperature level, and the length of time immersed all play a part in the zoning of seaweeds.

Section E - How seaweeds reproduce and grow

Propagation of seaweeds occurs by spores, or by fertilisation of egg cells . None have roots in the usual sense; few have leaves, and none have flowers, fruits or seeds. The plants absorb their nourishment through their fronds when they are surrounded by water: the base or "holdfast" of seaweeds is purely an attaching organ, not an absorbing one.

Section F - Why it doesn't dry or sink

Some of the large seaweeds maintain buoyancy with air-filled floats ; others, such as bull kelp, have large cells filled with air. Some, which spend a good part of their time exposed to the air, often reduce dehydration either by having swollen stems that contain water, or they may (like Venus' necklace) have | swollen nodules, or they may have distinctive shape like a sea bomb. Others, like the sea cactus, are filled with slimy fluid or have coating of mucilage on % the surface. In some of the larger kelps, this coating is not only to keep the plant moist but also to protect it from the violent action of waves.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5fe26ddc-2c6e-5d99-844f-9d59c1f18f1c', '1e2647b0-8e6d-5c83-97b4-182515836f49', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage 1 has six sections
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-6
on your answer sheet.
List of Headings
i
Locations and features of different seaweeds
ii
Various products of seaweeds
iii
Use of seaweeds in Japan
iv
Seaweed species around the globe
v
Nutritious value of seaweeds
vi
Why it doesn't dry or sink
vii
Where to find red seaweeds
viii
Underuse of native species
ix
Mystery solved
x
How seaweeds reproduce and grow
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate

1 ____ Section A Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('156db305-de2a-5a82-9a92-999612205927', '5fe26ddc-2c6e-5d99-844f-9d59c1f18f1c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4472088b-eaf0-58e0-b0e9-cd59f7ba15c1', '5fe26ddc-2c6e-5d99-844f-9d59c1f18f1c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5002b319-5e60-5d31-8bed-4f7bd6adb534', '5fe26ddc-2c6e-5d99-844f-9d59c1f18f1c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('864c4361-91f5-5e5e-9647-d1c2cda8cb83', '5fe26ddc-2c6e-5d99-844f-9d59c1f18f1c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b500e953-4b50-502e-985c-697ad5b14950', '5fe26ddc-2c6e-5d99-844f-9d59c1f18f1c', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6518a6b-1464-506a-a433-2e7ece22490c', '5fe26ddc-2c6e-5d99-844f-9d59c1f18f1c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0609697-503c-5a80-a971-d043d4cc8906', '5fe26ddc-2c6e-5d99-844f-9d59c1f18f1c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('611b3ab7-8e7e-527a-8462-453a2269c78f', '5fe26ddc-2c6e-5d99-844f-9d59c1f18f1c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1d13f2b-7d72-5fb0-ae23-61b2d487de40', '5fe26ddc-2c6e-5d99-844f-9d59c1f18f1c', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7053b86-adef-547e-b473-45cfe01a7239', '5fe26ddc-2c6e-5d99-844f-9d59c1f18f1c', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aba84cc7-b2b9-52e4-a8f2-40bbb8dbbb70', '1e2647b0-8e6d-5c83-97b4-182515836f49', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage 1 has six sections
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-6
on your answer sheet.
List of Headings
i
Locations and features of different seaweeds
ii
Various products of seaweeds
iii
Use of seaweeds in Japan
iv
Seaweed species around the globe
v
Nutritious value of seaweeds
vi
Why it doesn't dry or sink
vii
Where to find red seaweeds
viii
Underuse of native species
ix
Mystery solved
x
How seaweeds reproduce and grow
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate

2 ____ Section B Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4fe454b-6dde-5919-9ffe-030f966999d5', 'aba84cc7-b2b9-52e4-a8f2-40bbb8dbbb70', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64f10692-c865-5afb-8b63-7686eecf08a3', 'aba84cc7-b2b9-52e4-a8f2-40bbb8dbbb70', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19011a2c-d70c-545c-8c86-cce42be6e86f', 'aba84cc7-b2b9-52e4-a8f2-40bbb8dbbb70', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a73c334-a83b-5581-ad53-db4f1f053821', 'aba84cc7-b2b9-52e4-a8f2-40bbb8dbbb70', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5802160-3a6e-517f-971c-c28d53bae0db', 'aba84cc7-b2b9-52e4-a8f2-40bbb8dbbb70', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d3b554a-276b-56b2-a38c-44b1172039ea', 'aba84cc7-b2b9-52e4-a8f2-40bbb8dbbb70', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae2ddea6-184e-574a-a1e5-7cb90fe005e0', 'aba84cc7-b2b9-52e4-a8f2-40bbb8dbbb70', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26ac06c0-d076-5b0a-b487-bc971e899002', 'aba84cc7-b2b9-52e4-a8f2-40bbb8dbbb70', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('829ca1de-3f99-539f-b311-f309d46e29d5', 'aba84cc7-b2b9-52e4-a8f2-40bbb8dbbb70', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0181423f-d7c9-5325-9cec-f4ff49018921', 'aba84cc7-b2b9-52e4-a8f2-40bbb8dbbb70', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d10379b1-88f6-5f2b-a6f7-f326dd8dbc68', '1e2647b0-8e6d-5c83-97b4-182515836f49', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage 1 has six sections
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-6
on your answer sheet.
List of Headings
i
Locations and features of different seaweeds
ii
Various products of seaweeds
iii
Use of seaweeds in Japan
iv
Seaweed species around the globe
v
Nutritious value of seaweeds
vi
Why it doesn't dry or sink
vii
Where to find red seaweeds
viii
Underuse of native species
ix
Mystery solved
x
How seaweeds reproduce and grow
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate

3 ____ Section C Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf59c479-5d54-57c2-9b2c-236ccf788203', 'd10379b1-88f6-5f2b-a6f7-f326dd8dbc68', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c47dac1-f302-5569-b93c-71599969ee41', 'd10379b1-88f6-5f2b-a6f7-f326dd8dbc68', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17f0557c-3eb6-59b6-af6b-ec20af5178c2', 'd10379b1-88f6-5f2b-a6f7-f326dd8dbc68', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc8b4fde-8262-5d38-af04-0bb788bbf430', 'd10379b1-88f6-5f2b-a6f7-f326dd8dbc68', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('415deae8-4021-5c48-9e5b-84bd65ae7291', 'd10379b1-88f6-5f2b-a6f7-f326dd8dbc68', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bfb7ab2-f792-5ac6-bfa8-9192287f50fc', 'd10379b1-88f6-5f2b-a6f7-f326dd8dbc68', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca0e9761-909d-5327-9d57-05757e28cba3', 'd10379b1-88f6-5f2b-a6f7-f326dd8dbc68', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43114567-5b46-5b00-931e-c478d5d6e95a', 'd10379b1-88f6-5f2b-a6f7-f326dd8dbc68', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3595ee9-767c-59a0-b775-30e911dae332', 'd10379b1-88f6-5f2b-a6f7-f326dd8dbc68', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d35fb15b-2412-524f-bab2-5ab5aa1a3c38', 'd10379b1-88f6-5f2b-a6f7-f326dd8dbc68', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('176e1b96-b68c-5e9a-b598-e8fb6e07df7b', '1e2647b0-8e6d-5c83-97b4-182515836f49', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage 1 has six sections
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-6
on your answer sheet.
List of Headings
i
Locations and features of different seaweeds
ii
Various products of seaweeds
iii
Use of seaweeds in Japan
iv
Seaweed species around the globe
v
Nutritious value of seaweeds
vi
Why it doesn't dry or sink
vii
Where to find red seaweeds
viii
Underuse of native species
ix
Mystery solved
x
How seaweeds reproduce and grow
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate

4 ____ Section D Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e0c847c-7b01-5f34-89d4-aa3ba4f7ae97', '176e1b96-b68c-5e9a-b598-e8fb6e07df7b', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95180a5e-d137-59cc-870e-d83a0515a858', '176e1b96-b68c-5e9a-b598-e8fb6e07df7b', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17a3e0fd-b86c-5ea0-83f0-93b1d8ec2069', '176e1b96-b68c-5e9a-b598-e8fb6e07df7b', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23a05d7d-56e5-51ed-a05a-7a8451246dc6', '176e1b96-b68c-5e9a-b598-e8fb6e07df7b', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cebbedcd-e643-5201-8e61-1bea7093571d', '176e1b96-b68c-5e9a-b598-e8fb6e07df7b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('054c474b-56a3-576b-9967-e4ae0460351d', '176e1b96-b68c-5e9a-b598-e8fb6e07df7b', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d24e1e01-c45e-59e6-a844-1eeb856cd76d', '176e1b96-b68c-5e9a-b598-e8fb6e07df7b', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('578eda68-1d6d-5b9a-a8c4-b585bd178397', '176e1b96-b68c-5e9a-b598-e8fb6e07df7b', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56e48af2-19ee-506c-8794-a595ee544705', '176e1b96-b68c-5e9a-b598-e8fb6e07df7b', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf6b9d29-2cb1-50c0-8421-81edacaf3e4c', '176e1b96-b68c-5e9a-b598-e8fb6e07df7b', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('22d3e575-b860-5db1-9dd0-cbcf1ebaf96b', '1e2647b0-8e6d-5c83-97b4-182515836f49', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage 1 has six sections
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-6
on your answer sheet.
List of Headings
i
Locations and features of different seaweeds
ii
Various products of seaweeds
iii
Use of seaweeds in Japan
iv
Seaweed species around the globe
v
Nutritious value of seaweeds
vi
Why it doesn't dry or sink
vii
Where to find red seaweeds
viii
Underuse of native species
ix
Mystery solved
x
How seaweeds reproduce and grow
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate

5 ____ Section E Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32505fb5-f14c-53b1-8790-2e7950c17037', '22d3e575-b860-5db1-9dd0-cbcf1ebaf96b', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57f68266-ab0e-5036-b1dd-1bb96529b7b2', '22d3e575-b860-5db1-9dd0-cbcf1ebaf96b', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c472aaa-72d5-500e-b390-00cb5356b2da', '22d3e575-b860-5db1-9dd0-cbcf1ebaf96b', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c4ab3f6-d9f4-5b6e-a73c-531930f086de', '22d3e575-b860-5db1-9dd0-cbcf1ebaf96b', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('040271f6-1516-5152-9915-4c0406ba365a', '22d3e575-b860-5db1-9dd0-cbcf1ebaf96b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f816fcc-895b-5c17-817d-e27509a292f5', '22d3e575-b860-5db1-9dd0-cbcf1ebaf96b', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57fca54b-21a9-5fc9-b10d-c7c7a6f29654', '22d3e575-b860-5db1-9dd0-cbcf1ebaf96b', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('413ea036-aca2-5a45-bb77-7f411bc31fc6', '22d3e575-b860-5db1-9dd0-cbcf1ebaf96b', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8018a68e-3be3-55c7-96dc-6c557a1d00f8', '22d3e575-b860-5db1-9dd0-cbcf1ebaf96b', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ad63a2d-797d-5416-a46a-9dc8785d67c7', '22d3e575-b860-5db1-9dd0-cbcf1ebaf96b', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ae74994-20df-5191-af12-e621e8bff447', '1e2647b0-8e6d-5c83-97b4-182515836f49', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage 1 has six sections
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-6
on your answer sheet.
List of Headings
i
Locations and features of different seaweeds
ii
Various products of seaweeds
iii
Use of seaweeds in Japan
iv
Seaweed species around the globe
v
Nutritious value of seaweeds
vi
Why it doesn't dry or sink
vii
Where to find red seaweeds
viii
Underuse of native species
ix
Mystery solved
x
How seaweeds reproduce and grow
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate

6 ____ Section F Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76b5fc1e-d8b3-5c1f-9f52-6cb949975c3a', '7ae74994-20df-5191-af12-e621e8bff447', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65dbdc84-1136-5245-863a-220ce3b60859', '7ae74994-20df-5191-af12-e621e8bff447', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('284704d0-ad88-53a3-82a7-4d9dddcc296d', '7ae74994-20df-5191-af12-e621e8bff447', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94e7aa1e-9128-5a50-9c36-b4ab4e424dad', '7ae74994-20df-5191-af12-e621e8bff447', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a8a5649-be6e-57f6-ba7e-57e5dbbecbce', '7ae74994-20df-5191-af12-e621e8bff447', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ae3d072-8d43-581f-82c1-65efe665e336', '7ae74994-20df-5191-af12-e621e8bff447', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3deaf980-99d9-53ea-93ee-006a48e64663', '7ae74994-20df-5191-af12-e621e8bff447', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aff244fe-ca6b-57b2-bd8c-75782b6501f6', '7ae74994-20df-5191-af12-e621e8bff447', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70b9a37d-84b0-5baa-b57d-ffa3f2d83d3f', '7ae74994-20df-5191-af12-e621e8bff447', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('372f3358-9c03-513c-a70a-35d2a377bb6d', '7ae74994-20df-5191-af12-e621e8bff447', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1dc6ad05-22ee-5183-afcf-5ede4b24de9a', '1e2647b0-8e6d-5c83-97b4-182515836f49', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Complete the flow chart below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
7
Locate
8
Locate
9
10
Locate

7 ____ Locate$md$, NULL, ARRAY['.*new.*zealand.*carrageen.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e7e91db5-a5fa-5b79-8e98-292e93a8d293', '1e2647b0-8e6d-5c83-97b4-182515836f49', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Complete the flow chart below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
7
Locate
8
Locate
9
10
Locate

8 ____ Locate$md$, NULL, ARRAY['.*agar.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('622248aa-bb32-5fc6-892d-dca005214f3d', '1e2647b0-8e6d-5c83-97b4-182515836f49', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Complete the flow chart below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
7
Locate
8
Locate
9
10
Locate

9 ____$md$, NULL, ARRAY['.*seameal.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f60bc09a-1291-5298-8b10-72e79d401ca9', '1e2647b0-8e6d-5c83-97b4-182515836f49', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Complete the flow chart below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
7
Locate
8
Locate
9
10
Locate

10 ____ Locate$md$, NULL, ARRAY['.*cough.*mixture.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('622256e7-d549-50ec-b9a7-f84fbda78cf1', '1e2647b0-8e6d-5c83-97b4-182515836f49', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Classify the following description as relating to
A
Green seaweeds
B
Brown seaweeds
C
Red seaweeds
Write the correct letter
A, B
, or
C
in boxes
11-13
on your answer sheet.
11
Can resist exposure to sunlight at high-water mark
Locate
12
Grow in far open sea water
Locate
13
Share their habitat with karengo
Locate

11 ____ Can resist exposure to sunlight at high-water mark Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('183b4362-a3c7-5d49-898b-f612d9eccd92', '622256e7-d549-50ec-b9a7-f84fbda78cf1', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7af89cf-9e69-5939-9fab-b0949671a004', '622256e7-d549-50ec-b9a7-f84fbda78cf1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d30c825-b0e2-54f9-b69e-6389a5e6170c', '622256e7-d549-50ec-b9a7-f84fbda78cf1', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cc04af52-185e-52b9-9a64-b9e7779c7bc2', '1e2647b0-8e6d-5c83-97b4-182515836f49', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Classify the following description as relating to
A
Green seaweeds
B
Brown seaweeds
C
Red seaweeds
Write the correct letter
A, B
, or
C
in boxes
11-13
on your answer sheet.
11
Can resist exposure to sunlight at high-water mark
Locate
12
Grow in far open sea water
Locate
13
Share their habitat with karengo
Locate

12 ____ Grow in far open sea water Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4da39262-0581-5229-823b-7f7989c047d4', 'cc04af52-185e-52b9-9a64-b9e7779c7bc2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79d86f9b-2984-5d99-89f4-96799f84c123', 'cc04af52-185e-52b9-9a64-b9e7779c7bc2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('425acbb6-a26b-51d2-9bb8-fff892362f8e', 'cc04af52-185e-52b9-9a64-b9e7779c7bc2', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c2aea5a-9549-535c-87a1-e9a6e0308842', '1e2647b0-8e6d-5c83-97b4-182515836f49', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Classify the following description as relating to
A
Green seaweeds
B
Brown seaweeds
C
Red seaweeds
Write the correct letter
A, B
, or
C
in boxes
11-13
on your answer sheet.
11
Can resist exposure to sunlight at high-water mark
Locate
12
Grow in far open sea water
Locate
13
Share their habitat with karengo
Locate

13 ____ Share their habitat with karengo Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03c60770-b8a6-5539-951f-f4948e6ebb22', '4c2aea5a-9549-535c-87a1-e9a6e0308842', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('611e1498-b7c0-510a-93f0-324212cdd626', '4c2aea5a-9549-535c-87a1-e9a6e0308842', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37adcde3-87df-5ca4-9f59-6ec4b062fd73', '4c2aea5a-9549-535c-87a1-e9a6e0308842', 3, $md$C$md$, false);

COMMIT;
