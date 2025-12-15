BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-sand-dunes-1384'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-sand-dunes-1384';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-sand-dunes-1384';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-sand-dunes-1384';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('ec1b08da-7d86-50dd-a4cc-8e7f1f68581a', 'ielts-reading-sand-dunes-1384', $t$Sand Dunes$t$, $md$## Sand Dunes

Nguồn:
- Test: https://mini-ielts.com/1384/reading/sand-dunes
- Solution: https://mini-ielts.com/1384/view-solution/reading/sand-dunes$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('5d02a248-ae72-5576-bb67-e78166f6c786', 'ec1b08da-7d86-50dd-a4cc-8e7f1f68581a', 1, $t$Reading — Sand Dunes$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Sand Dunes

A

One of the main problems posed by sand dunes is their encroachment on human habitats. Sand dunes move by different means, all of them aided by the wind. Sand dunes threaten buildings and crops in Africa, the Middle East, and China. Preventing sand dunes from overwhelming cities and agricultural areas has become a priority for the United Nations Environment Program. On the other hand, dune habitats provide niches for highly specialized plants and animals, including numerous rare and endangered species.

B

Sand is usually composed of hard minerals such as quartz that cannot be broken down into silt or clay. Yellow, brown and reddish shades of sand indicate their presence of iron compounds. Red sand is composed of quartz coated by a layer of iron oxide. White sands are nearly pure gypsum. Sand with a high percentage of silicate can be used in glassmaking. Sandstone is created by sand, mixed with lime, chalk or some other material that acts as a binding agent, that is deposited in layers at the bottom of a sea or other area and pressed together into rock by the great pressure of sediments that are deposited on top of it over thousands or millions of years.

C

The most common dune form on Earth and on Mars is crescentic. Crescent-shaped mounds are generally wider than they are long. The slipfaces are on the concave sides of the dunes. These dunes form under winds that blow consistently from one direction, and they also are known as barchans or transverse dunes. Some types of crescentic dunes move more quickly over desert surfaces than any other type of dune. A group of dunes moved more than 100 metres per year between 1954 and 1959 the China’s Ningxia Province, and similar speeds have been recorded in the Western Desert of Egypt. The largest crescentic dunes on Earth, with mean crest-to-crest widths of more than 3 kilometres, are in China’s Taklamakan Desert.

D

Radially symmetrical, star dunes are pyramidal sand mounds with slipfaces on there or more arms that radiate from the high center of the mound. They tend to accumulate in areas with multidirectional wind regimes. Star dunes grow upward rather than laterally. They dominate the Grand Erg Oriental of the Sahara. In other deserts, they occur around the margins of the sand seas, particularly near topographic barriers. In the southeast Badain Jaran Desert of China, the star dunes are up to 500 metres tall and may be the tallest dunes on Earth. Straight or slightly sinuous sand ridges typically much longer than they are wide are known as linear dunes. They may be more than 160 kilometres (99 mi) long. Some linear dunes merge to form Y-shaped compound dunes. Many forms in bidirectional wind regimes. The long axes of these dunes extend in the resultant direction of sand movement. Linear loess hills known as pahas are superficially similar.

E

Once sand begins to pile up, ripples and dunes can form. Wind continues to move sand up to the top of the pile until the pile is so steep that it collapses under its own weight. The collapsing sand comes to rest when it reaches just the right steepness to keep the dune stable. This angle, usually about 30-34°, is called the angle of repose. Every pile of loose particles has a unique angle of repose, depending upon the properties of the material it’s made of, such as the grain size and roundness. Ripples grow into dunes with the increase of wind and sand input.

F

The repeating cycle of sand inching up the windward side to the dune crest, then slipping down the dune’s slip face allows the dune to inch forward, migrating in the direction the wind blows. As you might guess, all of this climbing then slipping leaves its mark on the internal structure of the dune. The image on the right shows fossil sand dune structure preserved in the Merced Formation at Fort Funston, Golden Gate National Recreation Area. The sloping lines or laminations you see are the preserved slip faces of a migrating sand dune. This structure is called cross-bedding and can be the result of either wind or water currents. The larger the cross-bedded structure, however, the more likely it is to be formed by wind, rather than water.

G

Sand dunes can “sing” at a level up to 115 decibels and generate sounds in different notes. The dunes at Sand Mountain n Nevada usually sing in a low C but can also sing in B and C sharp. The La Mar de Dunas in Chile hum in F while those at the Ghord Lahmar in Morocco howl in G sharp. The sounds are produced by avalanches of sand generated by blowing winds. For a while, it was thought that the avalanches caused the entire dune to resonate like a flute or violin but if that were true then different size dunes would produce different notes. In the mid 2000s, American, French and Moroccan scientists visiting sand dunes in Morocco, Chile, China and Oman published a paper in the Physical Review Letters that determined the sounds were produced by collisions between grains of sand that caused the motions of the grains to become synchronized, causing the outer layer of a dune to vibrate like the cone of a loudspeaker, producing sound. The tone of the sounds depended primarily on the size of the grains.

H

Scientists performed a computer simulation on patterns and dynamics of desert dunes in laboratory. Dune patterns observed in deserts were reproduced. From the initial random state, stars and linear dunes are produced, depending on the variability of the wind direction. The efficiency in sand transport is calculated through the course of development. Scientists found that the sand transport is the most efficient in the linear transverse dune. The efficiency in sand transport always increased through the evolution, and the way it increases was stepwise. They also found that the shadow zone, the region where the sand wastes the chance to move, shrinks through the course of evolution, which greatly helps them build a model to simulate a sand move.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('28314bad-c416-555b-8a21-e06e2db96a57', '5d02a248-ae72-5576-bb67-e78166f6c786', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-x
, in boxes
1-8
on your answer sheet.
List of Headings
i
potential threat to buildings and crops despite of benefit.
ii
the cycle of sand moving forward with wind
iii
protection method in various countries.
iv
scientists simulate sand move and build model in lab
v
sand composition explanation
vi
singing sand dunes
vii
other types of sand dunes
viii
the personal opinion on related issues.
ix
reasons why sand dunes form
x
the most common sand type
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
8
Paragraph H

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed2a291d-4347-58ce-94d1-b00a6c96791d', '28314bad-c416-555b-8a21-e06e2db96a57', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9caf1626-e4cb-597f-a046-32713c497107', '28314bad-c416-555b-8a21-e06e2db96a57', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10a82cf2-4179-5ebb-9530-abf05d8b4eb9', '28314bad-c416-555b-8a21-e06e2db96a57', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24a8cdbf-3ca0-5a92-ac13-ebec134395e9', '28314bad-c416-555b-8a21-e06e2db96a57', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f046028e-abc4-577a-9876-1a46602d7413', '28314bad-c416-555b-8a21-e06e2db96a57', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6b68e04-a28b-52ea-b748-f2412c3e80be', '28314bad-c416-555b-8a21-e06e2db96a57', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6438e817-7320-52f6-b699-0a90c5b9a98f', '28314bad-c416-555b-8a21-e06e2db96a57', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46d7b4c3-b043-5c29-9cc5-27e935e02539', '28314bad-c416-555b-8a21-e06e2db96a57', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8983384d-ddd2-5204-9e8c-48e662049df2', '28314bad-c416-555b-8a21-e06e2db96a57', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f647d18-fd5a-50cc-a556-e3fcf560655c', '28314bad-c416-555b-8a21-e06e2db96a57', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ad2df626-49f3-5195-9e71-ddb07ad28080', '5d02a248-ae72-5576-bb67-e78166f6c786', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-x
, in boxes
1-8
on your answer sheet.
List of Headings
i
potential threat to buildings and crops despite of benefit.
ii
the cycle of sand moving forward with wind
iii
protection method in various countries.
iv
scientists simulate sand move and build model in lab
v
sand composition explanation
vi
singing sand dunes
vii
other types of sand dunes
viii
the personal opinion on related issues.
ix
reasons why sand dunes form
x
the most common sand type
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
8
Paragraph H

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16faffc7-8aa8-585d-be76-bf88a077eb3c', 'ad2df626-49f3-5195-9e71-ddb07ad28080', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37a57124-f0ef-58ce-83e5-daec45425554', 'ad2df626-49f3-5195-9e71-ddb07ad28080', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72c16b46-71d3-5d18-bd32-4dd45cc8b4d6', 'ad2df626-49f3-5195-9e71-ddb07ad28080', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d925f36-7c0f-5a3c-bf30-632796510bf4', 'ad2df626-49f3-5195-9e71-ddb07ad28080', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5b838d4-9e00-514e-a753-efe4bed7bca3', 'ad2df626-49f3-5195-9e71-ddb07ad28080', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('111c771a-b08a-506a-bf3d-caab73d34917', 'ad2df626-49f3-5195-9e71-ddb07ad28080', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4db44b59-659e-54b6-a2ee-a85e0ec9c7dd', 'ad2df626-49f3-5195-9e71-ddb07ad28080', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b9cc84c-fd21-5b1d-b790-7555add7ce48', 'ad2df626-49f3-5195-9e71-ddb07ad28080', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f24c317d-4bc0-5f48-a276-42b12d518599', 'ad2df626-49f3-5195-9e71-ddb07ad28080', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70257b73-d3cb-5280-b525-241f507e0807', 'ad2df626-49f3-5195-9e71-ddb07ad28080', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b89e2769-bd51-5284-9cf1-4d2951b3d001', '5d02a248-ae72-5576-bb67-e78166f6c786', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-x
, in boxes
1-8
on your answer sheet.
List of Headings
i
potential threat to buildings and crops despite of benefit.
ii
the cycle of sand moving forward with wind
iii
protection method in various countries.
iv
scientists simulate sand move and build model in lab
v
sand composition explanation
vi
singing sand dunes
vii
other types of sand dunes
viii
the personal opinion on related issues.
ix
reasons why sand dunes form
x
the most common sand type
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
8
Paragraph H

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14407d5b-2a0f-55f1-87db-2376ffeb25aa', 'b89e2769-bd51-5284-9cf1-4d2951b3d001', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d4b7af0-aec3-5a93-883b-d2c6017e3586', 'b89e2769-bd51-5284-9cf1-4d2951b3d001', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d52d8f48-4c69-515b-8010-1b3dee4dc484', 'b89e2769-bd51-5284-9cf1-4d2951b3d001', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd46e2aa-0639-5ba1-b595-9e033df72bd5', 'b89e2769-bd51-5284-9cf1-4d2951b3d001', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a2d3fca-dfad-5394-8eee-ffbe12342ea8', 'b89e2769-bd51-5284-9cf1-4d2951b3d001', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45a8a8c1-b908-5922-8280-d45901e196e4', 'b89e2769-bd51-5284-9cf1-4d2951b3d001', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eedb1250-f311-53ab-8fec-f40c275026b3', 'b89e2769-bd51-5284-9cf1-4d2951b3d001', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3d93783-25d0-56f3-a9fc-b816be85a3fd', 'b89e2769-bd51-5284-9cf1-4d2951b3d001', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9aee7494-0b79-5447-a4fc-31d21ce4fa18', 'b89e2769-bd51-5284-9cf1-4d2951b3d001', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23ca4b1a-065a-5785-ad3d-7376a4e2a447', 'b89e2769-bd51-5284-9cf1-4d2951b3d001', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d627d4cc-1bfc-5b7e-bbfc-0c53084078ca', '5d02a248-ae72-5576-bb67-e78166f6c786', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-x
, in boxes
1-8
on your answer sheet.
List of Headings
i
potential threat to buildings and crops despite of benefit.
ii
the cycle of sand moving forward with wind
iii
protection method in various countries.
iv
scientists simulate sand move and build model in lab
v
sand composition explanation
vi
singing sand dunes
vii
other types of sand dunes
viii
the personal opinion on related issues.
ix
reasons why sand dunes form
x
the most common sand type
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
8
Paragraph H

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('408c23f0-d595-58a0-a891-2e617d7d5e1b', 'd627d4cc-1bfc-5b7e-bbfc-0c53084078ca', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6f954fc-8f2a-5028-a587-000085940664', 'd627d4cc-1bfc-5b7e-bbfc-0c53084078ca', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0d37d2e-92e0-555c-a360-01a33e06d959', 'd627d4cc-1bfc-5b7e-bbfc-0c53084078ca', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8acf4225-c556-561c-9d1a-b2589decb305', 'd627d4cc-1bfc-5b7e-bbfc-0c53084078ca', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9711b9a1-2b3d-5c92-b719-586298a9fcac', 'd627d4cc-1bfc-5b7e-bbfc-0c53084078ca', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('571a3048-aaae-5b9a-adf8-e0aa7ddff9b0', 'd627d4cc-1bfc-5b7e-bbfc-0c53084078ca', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac6b37c0-b49f-5313-862d-3fc310bf1908', 'd627d4cc-1bfc-5b7e-bbfc-0c53084078ca', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b737883-6440-51d8-a9a0-77fe10fdf541', 'd627d4cc-1bfc-5b7e-bbfc-0c53084078ca', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5cd7f6fd-8890-5750-ae9b-104b94ed204e', 'd627d4cc-1bfc-5b7e-bbfc-0c53084078ca', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81961917-8112-5a05-9884-e5a03dd8c065', 'd627d4cc-1bfc-5b7e-bbfc-0c53084078ca', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('79531d08-a261-5ffb-b1e9-de167886dfc1', '5d02a248-ae72-5576-bb67-e78166f6c786', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-x
, in boxes
1-8
on your answer sheet.
List of Headings
i
potential threat to buildings and crops despite of benefit.
ii
the cycle of sand moving forward with wind
iii
protection method in various countries.
iv
scientists simulate sand move and build model in lab
v
sand composition explanation
vi
singing sand dunes
vii
other types of sand dunes
viii
the personal opinion on related issues.
ix
reasons why sand dunes form
x
the most common sand type
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
8
Paragraph H

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acc6862f-ed11-5336-b44c-3398728e8972', '79531d08-a261-5ffb-b1e9-de167886dfc1', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bae2c651-0569-589c-a505-7af7617e69cb', '79531d08-a261-5ffb-b1e9-de167886dfc1', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e97dd8b-2ad5-5d1c-a617-9d3005a3a6bb', '79531d08-a261-5ffb-b1e9-de167886dfc1', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea057cb8-a85e-5c6c-90cb-6d3442119263', '79531d08-a261-5ffb-b1e9-de167886dfc1', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7d6b476-ab76-52a2-9dc7-8008115e137c', '79531d08-a261-5ffb-b1e9-de167886dfc1', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abc75001-ebf5-56c6-acd8-8789e9f7dd54', '79531d08-a261-5ffb-b1e9-de167886dfc1', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('deccd4cf-7286-50eb-b094-d9da88033580', '79531d08-a261-5ffb-b1e9-de167886dfc1', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b12d020-5ddc-5279-b9a2-61eb68549595', '79531d08-a261-5ffb-b1e9-de167886dfc1', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f07dfe89-7c11-5b6f-adcf-6772da6b778b', '79531d08-a261-5ffb-b1e9-de167886dfc1', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7e6e934-ed7e-50d1-9b5e-c94b2409272a', '79531d08-a261-5ffb-b1e9-de167886dfc1', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df942597-2bee-5c10-b609-bd13992c412c', '5d02a248-ae72-5576-bb67-e78166f6c786', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-x
, in boxes
1-8
on your answer sheet.
List of Headings
i
potential threat to buildings and crops despite of benefit.
ii
the cycle of sand moving forward with wind
iii
protection method in various countries.
iv
scientists simulate sand move and build model in lab
v
sand composition explanation
vi
singing sand dunes
vii
other types of sand dunes
viii
the personal opinion on related issues.
ix
reasons why sand dunes form
x
the most common sand type
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
8
Paragraph H

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('116ffbe4-3bba-5be5-8926-8608ce1b0c8d', 'df942597-2bee-5c10-b609-bd13992c412c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a913314-1b61-5614-b349-82a1672b1c78', 'df942597-2bee-5c10-b609-bd13992c412c', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9d914d2-9212-5d5e-8d26-df54aa55a540', 'df942597-2bee-5c10-b609-bd13992c412c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ceee9a9f-743b-5b27-9c89-bfff09c685e4', 'df942597-2bee-5c10-b609-bd13992c412c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf8d43fb-d00f-5b33-a984-60cce8e72055', 'df942597-2bee-5c10-b609-bd13992c412c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdec4b1a-39a3-56f4-86e1-ad57e5ca4bc6', 'df942597-2bee-5c10-b609-bd13992c412c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67fb3128-b41a-57df-a305-961a4aef0070', 'df942597-2bee-5c10-b609-bd13992c412c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('daae1094-dff4-52ee-b8e4-292f46bd31e2', 'df942597-2bee-5c10-b609-bd13992c412c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec2f95f5-0313-5838-bbe9-8b78ea8c8cde', 'df942597-2bee-5c10-b609-bd13992c412c', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a80ab301-b943-5289-8fd6-91cf0243ee33', 'df942597-2bee-5c10-b609-bd13992c412c', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c907a4b0-c978-5d98-b799-2ca943620b8b', '5d02a248-ae72-5576-bb67-e78166f6c786', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-x
, in boxes
1-8
on your answer sheet.
List of Headings
i
potential threat to buildings and crops despite of benefit.
ii
the cycle of sand moving forward with wind
iii
protection method in various countries.
iv
scientists simulate sand move and build model in lab
v
sand composition explanation
vi
singing sand dunes
vii
other types of sand dunes
viii
the personal opinion on related issues.
ix
reasons why sand dunes form
x
the most common sand type
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
8
Paragraph H

7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dff873a-398a-54d7-a087-1f200778c7fc', 'c907a4b0-c978-5d98-b799-2ca943620b8b', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83d3620f-0cd1-5a44-9580-7baf5d522bf7', 'c907a4b0-c978-5d98-b799-2ca943620b8b', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3b2a4dc-c884-5d16-a1b1-34aa60625e1b', 'c907a4b0-c978-5d98-b799-2ca943620b8b', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24d3407c-5bd4-57f4-9f4e-b2a55977f7fb', 'c907a4b0-c978-5d98-b799-2ca943620b8b', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31d410df-189b-5a01-b989-d2c0bdfb9586', 'c907a4b0-c978-5d98-b799-2ca943620b8b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e7c7323-6c16-5f06-a1b5-4c1709346e48', 'c907a4b0-c978-5d98-b799-2ca943620b8b', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37d8b9d2-f144-5dc0-84ea-4763cb017dfe', 'c907a4b0-c978-5d98-b799-2ca943620b8b', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85584ff4-6437-579f-8759-4a1c97a0aa7b', 'c907a4b0-c978-5d98-b799-2ca943620b8b', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac852981-48e0-5eec-921c-296eb8e74919', 'c907a4b0-c978-5d98-b799-2ca943620b8b', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b6e7a26-4aea-54c9-9626-af7398afadaf', 'c907a4b0-c978-5d98-b799-2ca943620b8b', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c6fd508-2e48-5137-8833-a0615e3d5b72', '5d02a248-ae72-5576-bb67-e78166f6c786', 8, 'MATCHING_HEADING', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-x
, in boxes
1-8
on your answer sheet.
List of Headings
i
potential threat to buildings and crops despite of benefit.
ii
the cycle of sand moving forward with wind
iii
protection method in various countries.
iv
scientists simulate sand move and build model in lab
v
sand composition explanation
vi
singing sand dunes
vii
other types of sand dunes
viii
the personal opinion on related issues.
ix
reasons why sand dunes form
x
the most common sand type
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
8
Paragraph H

8 ____ Paragraph H$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42db8296-16cf-5a3c-9771-fdca8b5f3b3f', '4c6fd508-2e48-5137-8833-a0615e3d5b72', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21eb80c7-dba3-597c-9c37-ec59aa273e87', '4c6fd508-2e48-5137-8833-a0615e3d5b72', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3d91e70-49eb-55b7-ab5f-d3c8011387ce', '4c6fd508-2e48-5137-8833-a0615e3d5b72', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52681167-6df4-5834-aefb-3149bcdc8975', '4c6fd508-2e48-5137-8833-a0615e3d5b72', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e80cc42a-f24f-55e7-8d71-9a754850036b', '4c6fd508-2e48-5137-8833-a0615e3d5b72', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67737864-5863-507b-9a9a-65727c098f1b', '4c6fd508-2e48-5137-8833-a0615e3d5b72', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c10c1c8-c56b-5940-8bdb-b28d4169abf5', '4c6fd508-2e48-5137-8833-a0615e3d5b72', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c73bebb-1bff-591f-9228-b1ea38ca4c97', '4c6fd508-2e48-5137-8833-a0615e3d5b72', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3f7dfdf-a3d1-5c9d-aaa1-3c086bd4fc9c', '4c6fd508-2e48-5137-8833-a0615e3d5b72', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b7c2d8f-b656-5ae0-8a80-fb0f397bd790', '4c6fd508-2e48-5137-8833-a0615e3d5b72', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ee227895-34ef-56b8-bd5a-8964597347e5', '5d02a248-ae72-5576-bb67-e78166f6c786', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-10
Questions 9-10
Answer the questions
9-10
and choose correct letter
A
,
B
,
C
or
D
.
9.
What is the main composition of
white sand
made of according to the passage?
A
Quartz
B
Gypsum
C
Lime
D
Iron
10.
Which one is not mentioned as a sand type in this passage?
A
Linear
B
Crescentic
C
Overlap
D
Star

Answer the questions 9-10 and choose correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0841efe0-5d11-53b2-8278-ab00922710d8', '5d02a248-ae72-5576-bb67-e78166f6c786', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-10
Questions 9-10
Answer the questions
9-10
and choose correct letter
A
,
B
,
C
or
D
.
9.
What is the main composition of
white sand
made of according to the passage?
A
Quartz
B
Gypsum
C
Lime
D
Iron
10.
Which one is not mentioned as a sand type in this passage?
A
Linear
B
Crescentic
C
Overlap
D
Star

Answer the questions 9-10 and choose correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1914cded-6e45-5ad5-a5f6-5cd6b1f1e211', '5d02a248-ae72-5576-bb67-e78166f6c786', 11, 'CLASSIFICATION', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete the summary using the list of words,
A-J
below.
Write the correct letter,
A-J
in boxes
11-14
on your answer sheet.
Crescentic is an ordinary
11
on both Earth and Mars, apart from which, there are also other types of sand dunes. Different color of the sand reflects different components, some of them are rich in
12
that can not be easily broken into clay. Sand dunes can “sing” at a level up to 115 decibels and generate sounds in different notes. Sand dunes can be able to
13
at a certain level of sound intensity, and the different size of grains creates different
14
of the sounds.
A
quartz
B
shape
C
pressure
D
tone
E
protection
F
category
G
minerals
H
sing
I
lab
J
direction

Crescentic is an ordinary 11 ____ on both Earth and Mars, apart from which, there are also other types of sand dunes. Different color of the sand reflects different components, some of them are rich in 12 ____ that can not be easily broken into clay. Sand dunes can “sing” at a level up to 115 decibels and generate sounds in different notes. Sand dunes can be able to 13 ____ at a certain level of sound intensity, and the different size of grains creates different 14 ____ of the sounds.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eebd9cdc-2119-50b0-8c41-8bc516953bda', '1914cded-6e45-5ad5-a5f6-5cd6b1f1e211', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebcb3fb6-a66d-5e55-b794-268386a1c650', '1914cded-6e45-5ad5-a5f6-5cd6b1f1e211', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1635e12f-70c4-5ae3-9233-e261a4d3c314', '1914cded-6e45-5ad5-a5f6-5cd6b1f1e211', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68c0789e-cdc6-5f2a-ae97-d99526a66d4c', '1914cded-6e45-5ad5-a5f6-5cd6b1f1e211', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76897c99-301d-5b9e-b477-988a103a6ecf', '1914cded-6e45-5ad5-a5f6-5cd6b1f1e211', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0c06d9f-1a31-5804-b6db-9a1a4ffe45ec', '1914cded-6e45-5ad5-a5f6-5cd6b1f1e211', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73670ac2-9e4c-5896-8b47-eb62fcccd8a6', '1914cded-6e45-5ad5-a5f6-5cd6b1f1e211', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c50defe0-6cf8-5d08-b3a9-7f98f3c2d559', '1914cded-6e45-5ad5-a5f6-5cd6b1f1e211', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28099498-2695-5d0c-9bce-cd336b9043ab', '1914cded-6e45-5ad5-a5f6-5cd6b1f1e211', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94418702-587d-522c-ac4b-b649893b67cf', '1914cded-6e45-5ad5-a5f6-5cd6b1f1e211', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f304db53-afb6-54e6-a22c-4f11b88d3df3', '5d02a248-ae72-5576-bb67-e78166f6c786', 12, 'CLASSIFICATION', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete the summary using the list of words,
A-J
below.
Write the correct letter,
A-J
in boxes
11-14
on your answer sheet.
Crescentic is an ordinary
11
on both Earth and Mars, apart from which, there are also other types of sand dunes. Different color of the sand reflects different components, some of them are rich in
12
that can not be easily broken into clay. Sand dunes can “sing” at a level up to 115 decibels and generate sounds in different notes. Sand dunes can be able to
13
at a certain level of sound intensity, and the different size of grains creates different
14
of the sounds.
A
quartz
B
shape
C
pressure
D
tone
E
protection
F
category
G
minerals
H
sing
I
lab
J
direction

Crescentic is an ordinary 11 ____ on both Earth and Mars, apart from which, there are also other types of sand dunes. Different color of the sand reflects different components, some of them are rich in 12 ____ that can not be easily broken into clay. Sand dunes can “sing” at a level up to 115 decibels and generate sounds in different notes. Sand dunes can be able to 13 ____ at a certain level of sound intensity, and the different size of grains creates different 14 ____ of the sounds.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e3e929b-3b3b-5efd-b3e6-2431f71a6577', 'f304db53-afb6-54e6-a22c-4f11b88d3df3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98b9cc76-bf0e-56a3-b2d6-dd81c1d89dd2', 'f304db53-afb6-54e6-a22c-4f11b88d3df3', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79f74ba4-a83a-5286-83ec-2703faca165e', 'f304db53-afb6-54e6-a22c-4f11b88d3df3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1713ade5-1472-58a7-a725-12040388a3b0', 'f304db53-afb6-54e6-a22c-4f11b88d3df3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50478812-4bbb-5c7a-8b2d-bb99d5d7ab14', 'f304db53-afb6-54e6-a22c-4f11b88d3df3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('933f4d7c-0382-5b2c-bb0a-785bc30c3a45', 'f304db53-afb6-54e6-a22c-4f11b88d3df3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('899f97af-f355-56f1-8388-63ef4a8a857a', 'f304db53-afb6-54e6-a22c-4f11b88d3df3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85d4c040-89ea-5893-b1be-bbc700aeeb12', 'f304db53-afb6-54e6-a22c-4f11b88d3df3', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29adecd7-7d6e-584e-8902-f329f9e2e17d', 'f304db53-afb6-54e6-a22c-4f11b88d3df3', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3bda8c6-d84d-5c69-8a2f-633169740ae1', 'f304db53-afb6-54e6-a22c-4f11b88d3df3', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b6503270-bdb6-5805-baa3-52fb7524dd88', '5d02a248-ae72-5576-bb67-e78166f6c786', 13, 'CLASSIFICATION', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete the summary using the list of words,
A-J
below.
Write the correct letter,
A-J
in boxes
11-14
on your answer sheet.
Crescentic is an ordinary
11
on both Earth and Mars, apart from which, there are also other types of sand dunes. Different color of the sand reflects different components, some of them are rich in
12
that can not be easily broken into clay. Sand dunes can “sing” at a level up to 115 decibels and generate sounds in different notes. Sand dunes can be able to
13
at a certain level of sound intensity, and the different size of grains creates different
14
of the sounds.
A
quartz
B
shape
C
pressure
D
tone
E
protection
F
category
G
minerals
H
sing
I
lab
J
direction

Crescentic is an ordinary 11 ____ on both Earth and Mars, apart from which, there are also other types of sand dunes. Different color of the sand reflects different components, some of them are rich in 12 ____ that can not be easily broken into clay. Sand dunes can “sing” at a level up to 115 decibels and generate sounds in different notes. Sand dunes can be able to 13 ____ at a certain level of sound intensity, and the different size of grains creates different 14 ____ of the sounds.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67c12387-6319-5c73-a6ee-434196c2ade5', 'b6503270-bdb6-5805-baa3-52fb7524dd88', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7cfdc29-61e9-5a23-8698-1371195daa9c', 'b6503270-bdb6-5805-baa3-52fb7524dd88', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60fb4cfa-643c-57b3-9c32-8ccfe1aed92d', 'b6503270-bdb6-5805-baa3-52fb7524dd88', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b140991f-caec-5c8b-a3cc-48849fc4db8d', 'b6503270-bdb6-5805-baa3-52fb7524dd88', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f71c8a1d-be66-5493-b80d-e7eefce538f0', 'b6503270-bdb6-5805-baa3-52fb7524dd88', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5a80447-7b73-5916-a666-a19f33134b30', 'b6503270-bdb6-5805-baa3-52fb7524dd88', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('297861f0-295c-5c89-b5ab-1db9e9e99f3c', 'b6503270-bdb6-5805-baa3-52fb7524dd88', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbe9de3b-1403-5f05-9d81-4620d89b8c1b', 'b6503270-bdb6-5805-baa3-52fb7524dd88', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f6f71e9-35a0-5650-8870-5c5e72806078', 'b6503270-bdb6-5805-baa3-52fb7524dd88', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d4a14d6-5456-5ae7-a687-ef1b5d36d7c0', 'b6503270-bdb6-5805-baa3-52fb7524dd88', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b75afb01-f6ef-5b5d-b6d5-e67b21fd840b', '5d02a248-ae72-5576-bb67-e78166f6c786', 14, 'CLASSIFICATION', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete the summary using the list of words,
A-J
below.
Write the correct letter,
A-J
in boxes
11-14
on your answer sheet.
Crescentic is an ordinary
11
on both Earth and Mars, apart from which, there are also other types of sand dunes. Different color of the sand reflects different components, some of them are rich in
12
that can not be easily broken into clay. Sand dunes can “sing” at a level up to 115 decibels and generate sounds in different notes. Sand dunes can be able to
13
at a certain level of sound intensity, and the different size of grains creates different
14
of the sounds.
A
quartz
B
shape
C
pressure
D
tone
E
protection
F
category
G
minerals
H
sing
I
lab
J
direction

Crescentic is an ordinary 11 ____ on both Earth and Mars, apart from which, there are also other types of sand dunes. Different color of the sand reflects different components, some of them are rich in 12 ____ that can not be easily broken into clay. Sand dunes can “sing” at a level up to 115 decibels and generate sounds in different notes. Sand dunes can be able to 13 ____ at a certain level of sound intensity, and the different size of grains creates different 14 ____ of the sounds.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9f92a30-7be0-59a4-8a91-fba6af66ba72', 'b75afb01-f6ef-5b5d-b6d5-e67b21fd840b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4af501de-e245-5e7f-ad78-12ad327b356c', 'b75afb01-f6ef-5b5d-b6d5-e67b21fd840b', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a234d580-4861-56bd-89e9-88f529bb78fe', 'b75afb01-f6ef-5b5d-b6d5-e67b21fd840b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2798b0ea-5511-5761-93c6-46645566c885', 'b75afb01-f6ef-5b5d-b6d5-e67b21fd840b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5565412a-185a-5f61-ba79-4e7ea003393b', 'b75afb01-f6ef-5b5d-b6d5-e67b21fd840b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa3dfeab-e7f5-5a06-b0a3-ac05ca9e29f2', 'b75afb01-f6ef-5b5d-b6d5-e67b21fd840b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a3bad60-afaa-5c6d-8aed-065304e0b938', 'b75afb01-f6ef-5b5d-b6d5-e67b21fd840b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb31160e-11b5-598e-891b-57825f1887ba', 'b75afb01-f6ef-5b5d-b6d5-e67b21fd840b', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e888a230-3135-5841-a6ee-a33d7011ea8e', 'b75afb01-f6ef-5b5d-b6d5-e67b21fd840b', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('397d4de2-1a58-5c48-86a0-0cfe26444cb1', 'b75afb01-f6ef-5b5d-b6d5-e67b21fd840b', 10, $md$J$md$, false);

COMMIT;
