BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-bird-migration-1260'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-bird-migration-1260';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-bird-migration-1260';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-bird-migration-1260';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('3a186ef5-d49f-537e-b009-1f52a7fed66e', 'ielts-reading-bird-migration-1260', $t$Bird Migration$t$, $md$## Bird Migration

Nguồn:
- Test: https://mini-ielts.com/1260/reading/bird-migration
- Solution: https://mini-ielts.com/1260/view-solution/reading/bird-migration$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('829ea7cc-640c-5589-8f12-ebf010a429a8', '3a186ef5-d49f-537e-b009-1f52a7fed66e', 1, $t$Reading — Bird Migration$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Bird Migration

A. Birds have many unique design features that enable them to perform such amazing feats of endurance. They are equipped with lightweight, hollow bones, intricately designed feathers providing both lift and thrust for rapid flight, navigation systems superior to any that man has developed, and an ingenious heat conserving design that, among other things, concentrates all blood circulation beneath layers of warm, waterproof plumage, leaving them fit to face life in the harshest of climates. Their respiratory systems have to perform efficiently during sustained flights at altitude, so they have a system of extracting oxygen from their lungs that far exceeds that of any other animal. During the later stages of the summer breeding season, when food is plentiful, their bodies can accumulate considerable layers of fat, to provide sufficient energy for their long migratory flights.

B. The fundamental reason that birds migrate is to find adequate food during the winter months when it is in short supply. This particularly applies to birds that breed in the temperate and Arctic regions of the Northern Hemisphere, where food is abundant during the short growing season. Many species can tolerate cold temperatures if food is plentiful, but when food is not available, they must migrate. However, intriguing questions remain.

C. One puzzling fact is that many birds journey much further than would be necessary just to find food and good weather. Nobody knows, for instance, why British swallows, which could presumably survive equally well if they spent the winter in equatorial Africa, instead of fly several thousands of miles further to their preferred winter home in South Africa’s Cape Province. Another mystery involves the huge migrations performed by arctic terns and mudflat-feeding shorebirds that breed close to Polar Regions. In general, the further north a migrant species breeds, the further south it spends the winter. For arctic terns, this necessitates an annual round trip of 25,000 miles. Yet, en route to their final destination in far-flung southern latitudes, all these individuals overfly other areas of seemingly suitable habitat spanning two hemispheres. While we may not fully understand birds’ reasons for going to particular places, we can marvel at their feats.

D. One of the greatest mysteries is how young birds know how to find the traditional wintering areas without parental guidance. Very few adults migrate with juveniles in tow, and youngsters may even have little or no inkling of their parents’ appearance. A familiar example is that of the cuckoo, which lays its eggs in another species’ nest and never reencounters its young. It is mind-boggling to consider that, once raised by its host species, the young cuckoo makes its way to ancestral wintering grounds in the tropics before returning single-handedly to northern Europe the next season to seek out a mate among its kind. The obvious implication is that it inherits from its parents an inbuilt route map and direction-finding capability, as well as a mental image of what another cuckoo looks like. Yet nobody has the slightest idea as to how this is possible.

E. Mounting evidence has confirmed that birds use the positions of the sun and stars to obtain compass directions. They also seem to be able to detect the earth’s magnetic field, probably due to having minute crystals of magnetite in the region of their brains. However, accurate navigation also requires an awareness of position and time, especially when lost. Experiments have shown that after being taken thousands of miles over an unfamiliar landmass, birds are still capable of returning rapidly to nest sites. Such phenomenal powers are the product of computing several sophisticated cues, including an inborn map of the night sky and the pull of the earth’s magnetic field. How the birds use their ‘instruments’ remains unknown, but one thing is clear: they see the world with a superior sensory perception to ours. Most small birds migrate at night and take their direction from the position of the setting sun. However, as well as seeing the sun go down, they also seem to see the plane of polarized light caused by it, which calibrates their compass. Travelling at night provides other benefits. Daytime predators are avoided and the danger of dehydration due to flying for long periods in warm, sunlit skies is reduced. Furthermore, at night the air is generally cool and less turbulent and so conducive to sustained, stable flight.

F. Nevertheless, all journeys involve considerable risk, and part of the skill in arriving safely is setting off at the right time. This means accurate weather forecasting and utilizing favourable winds. Birds are adept at both, and, in laboratory tests, some have been shown to detect the minute difference in barometric pressure between the floor and ceiling of a room. Often birds react to weather changes before there is any visible sign of them. Lapwings, which feed on grassland, flee west from the Netherlands to the British Isles, France, and Spain at the onset of a cold snap. When the ground surface freezes, the birds could starve. Yet they return to Holland ahead of a thaw, their arrival linked to a pressure change presaging an improvement in the weather.

G. In one instance a Welsh Manx shearwater carried to America and released was back in its burrow on Skokholm Island, off the Pembrokeshire coast, one day before a letter announcing its release! Conversely, each autumn a small number of North American birds are blown across the Atlantic by fast-moving westerly tailwinds. Not only do they arrive safely in Europe, but, based on ringing evidence, some make it back to North America the following spring, after probably spending the winter with European migrants in sunny African climes.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('526fb131-1c37-5b52-855f-7aa6ca450ea3', '829ea7cc-640c-5589-8f12-ebf010a429a8', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of headings
i. The best moment to migrate
ii. The unexplained rejection of closer feeding ground
iii.The influence of weather on the migration route
iv. Physical characteristics that allow birds to migrate
v. The main reason why birds migrate
vi. The best wintering grounds for birds
vii. Research findings on how birds migrate
viii. Successful migration despite the trouble of wind
ix. The contrast between long-distance migration and short-distance migration
x. Mysterious migration despite lack of teaching
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F
7
Paragraph
G

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b64a06f-280d-5582-8264-f6e9db3ebbfc', '526fb131-1c37-5b52-855f-7aa6ca450ea3', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6cd4ce4-2bb5-5b9e-a7b3-4d80badc95f0', '526fb131-1c37-5b52-855f-7aa6ca450ea3', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4bebefb-f8cd-5f3a-bcfb-2f3357a5e674', '526fb131-1c37-5b52-855f-7aa6ca450ea3', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cb7ba6a-142e-5ec9-b243-9bc91f2bfdc9', '526fb131-1c37-5b52-855f-7aa6ca450ea3', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('899155de-3e35-5614-be21-9ec5d596fcca', '526fb131-1c37-5b52-855f-7aa6ca450ea3', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1070f8b1-3972-582b-ac16-b494a357b744', '526fb131-1c37-5b52-855f-7aa6ca450ea3', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a95c3ac-1e21-5e25-9409-2a99eb10c577', '526fb131-1c37-5b52-855f-7aa6ca450ea3', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('037bef9c-a561-5172-a8eb-921493e79a50', '526fb131-1c37-5b52-855f-7aa6ca450ea3', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9bf9b49-8cd7-56fd-9649-1f025c641055', '526fb131-1c37-5b52-855f-7aa6ca450ea3', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44ededf4-27e1-51fe-a7d7-f9562b1ad444', '526fb131-1c37-5b52-855f-7aa6ca450ea3', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dc31c00d-8147-5b6c-b8bc-3fde3c2b87da', '829ea7cc-640c-5589-8f12-ebf010a429a8', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of headings
i. The best moment to migrate
ii. The unexplained rejection of closer feeding ground
iii.The influence of weather on the migration route
iv. Physical characteristics that allow birds to migrate
v. The main reason why birds migrate
vi. The best wintering grounds for birds
vii. Research findings on how birds migrate
viii. Successful migration despite the trouble of wind
ix. The contrast between long-distance migration and short-distance migration
x. Mysterious migration despite lack of teaching
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F
7
Paragraph
G

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0575732c-02c0-59bc-848c-911e9fe6ff4f', 'dc31c00d-8147-5b6c-b8bc-3fde3c2b87da', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6baa7986-f143-59a7-9e46-f9afd4656112', 'dc31c00d-8147-5b6c-b8bc-3fde3c2b87da', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e28e85db-d73e-56cf-a75e-15ff49c4467b', 'dc31c00d-8147-5b6c-b8bc-3fde3c2b87da', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2572ee76-4546-5efa-a442-08186ab4c50e', 'dc31c00d-8147-5b6c-b8bc-3fde3c2b87da', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ccf8e34f-e5e2-5c43-aed3-be8230e8a4cd', 'dc31c00d-8147-5b6c-b8bc-3fde3c2b87da', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eac8a82d-dcfd-5838-92e1-b6013262d348', 'dc31c00d-8147-5b6c-b8bc-3fde3c2b87da', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5be77f00-9d55-53ef-a35f-4b3cc5df667f', 'dc31c00d-8147-5b6c-b8bc-3fde3c2b87da', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b69f822c-87b5-577c-afc4-37bc36675385', 'dc31c00d-8147-5b6c-b8bc-3fde3c2b87da', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16f7de8b-ef4b-51e4-b5da-7bcb1470249b', 'dc31c00d-8147-5b6c-b8bc-3fde3c2b87da', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a8dd3ae-f952-5632-9212-d9ba0a70a8af', 'dc31c00d-8147-5b6c-b8bc-3fde3c2b87da', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e778797-6b36-5d11-b58d-4dc8d842b74a', '829ea7cc-640c-5589-8f12-ebf010a429a8', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of headings
i. The best moment to migrate
ii. The unexplained rejection of closer feeding ground
iii.The influence of weather on the migration route
iv. Physical characteristics that allow birds to migrate
v. The main reason why birds migrate
vi. The best wintering grounds for birds
vii. Research findings on how birds migrate
viii. Successful migration despite the trouble of wind
ix. The contrast between long-distance migration and short-distance migration
x. Mysterious migration despite lack of teaching
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F
7
Paragraph
G

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc039e84-78c3-5af3-b392-3054fbb1b76c', '6e778797-6b36-5d11-b58d-4dc8d842b74a', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a75b95d4-76a8-5380-8071-283345f96580', '6e778797-6b36-5d11-b58d-4dc8d842b74a', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35d4dbe3-5ff8-524a-aa66-2b16a35f784a', '6e778797-6b36-5d11-b58d-4dc8d842b74a', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79f9d855-f65b-54e3-8db4-3eb97c04b805', '6e778797-6b36-5d11-b58d-4dc8d842b74a', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20bcf69d-823f-5490-99aa-c6630e34c7da', '6e778797-6b36-5d11-b58d-4dc8d842b74a', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1f902f8-5a40-5a26-bc48-abb89843e283', '6e778797-6b36-5d11-b58d-4dc8d842b74a', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b9a51b7-87a1-5640-a2f2-634d317c5bad', '6e778797-6b36-5d11-b58d-4dc8d842b74a', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d02c4306-b12e-5f28-8d21-4023f3fc2ecc', '6e778797-6b36-5d11-b58d-4dc8d842b74a', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b6339f7-60d4-5a82-91bc-1de7abeea67b', '6e778797-6b36-5d11-b58d-4dc8d842b74a', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86a1f3f2-a02e-5f5f-9315-8b7d5ad1012b', '6e778797-6b36-5d11-b58d-4dc8d842b74a', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dcf5b473-b95e-5e2a-b557-a7e6fa454fe4', '829ea7cc-640c-5589-8f12-ebf010a429a8', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of headings
i. The best moment to migrate
ii. The unexplained rejection of closer feeding ground
iii.The influence of weather on the migration route
iv. Physical characteristics that allow birds to migrate
v. The main reason why birds migrate
vi. The best wintering grounds for birds
vii. Research findings on how birds migrate
viii. Successful migration despite the trouble of wind
ix. The contrast between long-distance migration and short-distance migration
x. Mysterious migration despite lack of teaching
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F
7
Paragraph
G

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a690eb07-ee0a-5380-ad40-6be2b4093420', 'dcf5b473-b95e-5e2a-b557-a7e6fa454fe4', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30dcd3a3-d8ae-5411-ad37-684e2c3efeed', 'dcf5b473-b95e-5e2a-b557-a7e6fa454fe4', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1db24b4-5f93-560c-9d8d-8f2e9ef2e47b', 'dcf5b473-b95e-5e2a-b557-a7e6fa454fe4', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cce81508-5341-5944-947d-8f738aee9a75', 'dcf5b473-b95e-5e2a-b557-a7e6fa454fe4', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db0f1961-fe2f-57b9-930c-954106420d23', 'dcf5b473-b95e-5e2a-b557-a7e6fa454fe4', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8980261a-96cc-5ad2-8e88-3b4e26c75166', 'dcf5b473-b95e-5e2a-b557-a7e6fa454fe4', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9783ec2-1694-588e-8d7c-6c2441231ef2', 'dcf5b473-b95e-5e2a-b557-a7e6fa454fe4', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('284a5c84-0e55-57f7-9da2-d8f7e5f68fbd', 'dcf5b473-b95e-5e2a-b557-a7e6fa454fe4', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22ad5a5d-9d71-5f6e-85b4-9875391ab616', 'dcf5b473-b95e-5e2a-b557-a7e6fa454fe4', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84e46497-0cde-5577-9182-9cee7e95ba7f', 'dcf5b473-b95e-5e2a-b557-a7e6fa454fe4', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3216a45b-776e-5f6c-832e-dfb3edb46d6c', '829ea7cc-640c-5589-8f12-ebf010a429a8', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of headings
i. The best moment to migrate
ii. The unexplained rejection of closer feeding ground
iii.The influence of weather on the migration route
iv. Physical characteristics that allow birds to migrate
v. The main reason why birds migrate
vi. The best wintering grounds for birds
vii. Research findings on how birds migrate
viii. Successful migration despite the trouble of wind
ix. The contrast between long-distance migration and short-distance migration
x. Mysterious migration despite lack of teaching
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F
7
Paragraph
G

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('297089b5-4860-5531-a743-5e4b27bff596', '3216a45b-776e-5f6c-832e-dfb3edb46d6c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e6efc7e-4cc6-5f8e-b4f9-531f413c60d7', '3216a45b-776e-5f6c-832e-dfb3edb46d6c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('daa70f55-092f-526f-9581-c0a1f33293d2', '3216a45b-776e-5f6c-832e-dfb3edb46d6c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13c5eeaf-ffd0-56f1-b7b1-e29ca4d2c737', '3216a45b-776e-5f6c-832e-dfb3edb46d6c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('408ec08c-62ec-51e3-a02e-8e2df567057a', '3216a45b-776e-5f6c-832e-dfb3edb46d6c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a49bad69-be99-5365-a7a9-25f389fa37db', '3216a45b-776e-5f6c-832e-dfb3edb46d6c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db33acba-ad58-537f-87e2-04d5d62dd26c', '3216a45b-776e-5f6c-832e-dfb3edb46d6c', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('782d9420-d547-5717-aca9-0e733461a301', '3216a45b-776e-5f6c-832e-dfb3edb46d6c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7971be6-c228-5092-8731-759d1e00c969', '3216a45b-776e-5f6c-832e-dfb3edb46d6c', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ad2c8c5-adf5-5607-a99b-99eda6b2d3e2', '3216a45b-776e-5f6c-832e-dfb3edb46d6c', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('65ab8d35-867f-55bd-a0b1-0e68145864a8', '829ea7cc-640c-5589-8f12-ebf010a429a8', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of headings
i. The best moment to migrate
ii. The unexplained rejection of closer feeding ground
iii.The influence of weather on the migration route
iv. Physical characteristics that allow birds to migrate
v. The main reason why birds migrate
vi. The best wintering grounds for birds
vii. Research findings on how birds migrate
viii. Successful migration despite the trouble of wind
ix. The contrast between long-distance migration and short-distance migration
x. Mysterious migration despite lack of teaching
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F
7
Paragraph
G

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe4afefe-eb72-5c6f-b0fc-29e86a32e8bc', '65ab8d35-867f-55bd-a0b1-0e68145864a8', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df60821b-834a-5682-ae75-733cec437cd0', '65ab8d35-867f-55bd-a0b1-0e68145864a8', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67fb63e3-69d1-549a-bab4-05d30c1578bd', '65ab8d35-867f-55bd-a0b1-0e68145864a8', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64511a2d-55cf-538c-a0a0-a86676ae7b3f', '65ab8d35-867f-55bd-a0b1-0e68145864a8', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e2eea22-797f-5a10-bdbd-6798789bcc9d', '65ab8d35-867f-55bd-a0b1-0e68145864a8', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac5f0055-3947-5f8e-a574-810ae8ef6590', '65ab8d35-867f-55bd-a0b1-0e68145864a8', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efc4ae60-ba4e-5c2d-974c-2243e0a6fc05', '65ab8d35-867f-55bd-a0b1-0e68145864a8', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eeacfbdc-cfd1-57aa-9179-bb3c720f9eae', '65ab8d35-867f-55bd-a0b1-0e68145864a8', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e23589a1-cf9d-593c-aad8-4acff80125cc', '65ab8d35-867f-55bd-a0b1-0e68145864a8', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60b6fd48-6978-5db7-aeda-d7907ba78edf', '65ab8d35-867f-55bd-a0b1-0e68145864a8', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4827b84e-3a1d-579b-8a74-6e2d365099ac', '829ea7cc-640c-5589-8f12-ebf010a429a8', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading passage has seven paragraphs, A-G.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-x, in boxes 1-7 on your answer sheet.
List of headings
i. The best moment to migrate
ii. The unexplained rejection of closer feeding ground
iii.The influence of weather on the migration route
iv. Physical characteristics that allow birds to migrate
v. The main reason why birds migrate
vi. The best wintering grounds for birds
vii. Research findings on how birds migrate
viii. Successful migration despite the trouble of wind
ix. The contrast between long-distance migration and short-distance migration
x. Mysterious migration despite lack of teaching
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F
7
Paragraph
G

7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb1cd55e-2334-5bd1-9d92-7903f0234f32', '4827b84e-3a1d-579b-8a74-6e2d365099ac', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64d3604d-1df2-5266-9f88-dd5ace33b541', '4827b84e-3a1d-579b-8a74-6e2d365099ac', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b4697e1-3f60-58ad-bc36-f9542bd798e9', '4827b84e-3a1d-579b-8a74-6e2d365099ac', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53afe1fa-5b07-547a-8948-0069fe153602', '4827b84e-3a1d-579b-8a74-6e2d365099ac', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5071a951-8681-5adf-8d45-7d851333048a', '4827b84e-3a1d-579b-8a74-6e2d365099ac', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1438756e-d31e-5314-b16b-5933c59963f4', '4827b84e-3a1d-579b-8a74-6e2d365099ac', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c70554c-131d-541f-97fd-def7bd9d905c', '4827b84e-3a1d-579b-8a74-6e2d365099ac', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46309e87-991a-5edd-8b76-0094fab1da6c', '4827b84e-3a1d-579b-8a74-6e2d365099ac', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d0e94ab-fd43-54a3-b0f8-2e152a099dff', '4827b84e-3a1d-579b-8a74-6e2d365099ac', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('def82bd1-bab7-5f44-b171-cad13392e4e4', '4827b84e-3a1d-579b-8a74-6e2d365099ac', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c881c3cd-43bc-5ab6-a03d-9bff95db52e8', '829ea7cc-640c-5589-8f12-ebf010a429a8', 10, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 10

Question 10-13
Question 10-13
Complete the sentences below using
NO MORE THAN ONE WORD OR NUMBER
from the passage.
Write your answers in your answer sheet
10.
It is a great mystery that young birds like cuckoos can find their wintering
grounds without
10
11.
Evidence shows birds can tell directions like a
11
by observing the sun and the
stars.
12.
One advantage for birds flying at night is that they can avoid contact with
12
13.
Laboratory tests show that birds can detect weather without
13
signs.

10. It is a great mystery that young birds like cuckoos can find their wintering grounds without 10 ____$md$, NULL, ARRAY['.*parental.*guidance.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4a468973-0eae-507c-9a66-ce6589ab7b37', '829ea7cc-640c-5589-8f12-ebf010a429a8', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Question 10-13
Question 10-13
Complete the sentences below using
NO MORE THAN ONE WORD OR NUMBER
from the passage.
Write your answers in your answer sheet
10.
It is a great mystery that young birds like cuckoos can find their wintering
grounds without
10
11.
Evidence shows birds can tell directions like a
11
by observing the sun and the
stars.
12.
One advantage for birds flying at night is that they can avoid contact with
12
13.
Laboratory tests show that birds can detect weather without
13
signs.

11. Evidence shows birds can tell directions like a 11 ____ by observing the sun and the stars.$md$, NULL, ARRAY['.*compass.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3f852fd6-9909-5f58-923d-c44f49059b97', '829ea7cc-640c-5589-8f12-ebf010a429a8', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Question 10-13
Question 10-13
Complete the sentences below using
NO MORE THAN ONE WORD OR NUMBER
from the passage.
Write your answers in your answer sheet
10.
It is a great mystery that young birds like cuckoos can find their wintering
grounds without
10
11.
Evidence shows birds can tell directions like a
11
by observing the sun and the
stars.
12.
One advantage for birds flying at night is that they can avoid contact with
12
13.
Laboratory tests show that birds can detect weather without
13
signs.

12. One advantage for birds flying at night is that they can avoid contact with 12 ____$md$, NULL, ARRAY['.*predators.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f8a7585c-d031-52ee-93f8-b2502a9eef58', '829ea7cc-640c-5589-8f12-ebf010a429a8', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Question 10-13
Question 10-13
Complete the sentences below using
NO MORE THAN ONE WORD OR NUMBER
from the passage.
Write your answers in your answer sheet
10.
It is a great mystery that young birds like cuckoos can find their wintering
grounds without
10
11.
Evidence shows birds can tell directions like a
11
by observing the sun and the
stars.
12.
One advantage for birds flying at night is that they can avoid contact with
12
13.
Laboratory tests show that birds can detect weather without
13
signs.

13. Laboratory tests show that birds can detect weather without 13 ____ signs.$md$, NULL, ARRAY['.*visible.*']);

COMMIT;
