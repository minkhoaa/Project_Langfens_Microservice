BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-longaeva-ancient-bristlecone-pine-1308'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-longaeva-ancient-bristlecone-pine-1308';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-longaeva-ancient-bristlecone-pine-1308';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-longaeva-ancient-bristlecone-pine-1308';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9a542b59-9729-57e7-b048-b6b149623560', 'ielts-reading-longaeva-ancient-bristlecone-pine-1308', $t$Longaeva: Ancient Bristlecone Pine$t$, $md$## Longaeva: Ancient Bristlecone Pine

Nguồn:
- Test: https://mini-ielts.com/1308/reading/longaeva-ancient-bristlecone-pine
- Solution: https://mini-ielts.com/1308/view-solution/reading/longaeva-ancient-bristlecone-pine$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('9a0280ec-709b-5a69-a5e4-78354ad91d6a', '9a542b59-9729-57e7-b048-b6b149623560', 1, $t$Reading — Longaeva: Ancient Bristlecone Pine$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Longaeva: Ancient Bristlecone Pine

A

To understand more about the earth’s history, humans have often looked to the natural environment for insight into the past. The bristlecone pine (Pinus longaeva), of the White Mountains in California, has served this purpose greater than any other species of tree on the planet. Conditions here are brutal: scant precipitation and low average temperatures mean a short growing season, only intensified by ferocious wind and mal-nutritious rocky. Nevertheless, bristlecone pines have claimed these barren slopes as their permanent home. Evolving here in this harsh environment, super-adapted and without much competition, bristlecones have earned their seat on the longevity throne by becoming the oldest living trees on the planet. Results of extensive studies on bristlecone pine stands have shown that in fact such, environmental limitations are positively associated with the attainment of great age. This intriguing phenomenon will be discussed further on.

B

But exactly how old is old? Sprouted before the invention of Egyptian hieroglyphs and long before the teachings of Jesus of Nazareth, Methuselah is the oldest bristlecone alive at roughly 4,700 years. Although specimens of this age do not represent the species’ average, there are 200 trees more than 3,000 years old, and two dozen more than 4,000. Considering that these high ages are obtained in the face of such remarkable environmental adversity, the bristlecone pines have become the focus of much scientific examination over the past half-century.

C

Perhaps most interested in the bristlecone pine are dendrochronologists or tree-ring daters. With every strenuous year that passes in the While Mountains, each bristlecone grows and forms a new outer layer of cambium that reflects a season’s particular ease or hardship. So while growing seasons may expand or shrink, the trees carry on, their growth rings faithfully recording the bad years alongside the goods. Through examining the annual growth rings of both living and dead specimens, taking thousands of core samples, and by processes of cross-dating between trees and other qualitative records, scientists have compiled a continuous tree-ring record that dates back to the last Ice Age between eight and ten thousand years ago. Among other linked accomplishments, this record has enhanced the dating process, helping to double-check and correct the radiocarbon-14 method to more accurately estimate the age of organic material.

D

Now more than ever the importance of monitoring the bristlecone is being realized. As our global climate continues to undergo its most recent and abrupt atmospheric change, these ancient scribes continue to respond. Since, the rings of wood formed each year reveal the trees’ response to climatic conditions during a particular growing season, in their persistence they have left us natural recordings of the past, markers of the present, and clues to the future.

E

The species’ name originates from the appearance of its unusual cones and needles. The bristlecone’s short, pale needles are also trademarks, bunching together to form foxtail-like bundles. As is the case of most conifer needles, these specialized leaves cluster together to shelter the stomata so very little moisture is lost through them. This adaptation helps the bristlecone photosynthesize during particularly brutal months. Saving the energy of constant needle replacement and providing a stable supply of chlorophyll. For a plant trying to store so much energy, bristlecone seeds are relatively large in size. They are first reproduced when trees reach ages between thirty and seventy-five years old. Germination rates are generally high, in part because seeds require little to no initial stratification. Perhaps the most intriguing physical characteristic of a mature bristlecone, however, is its ratio of living to deadwood on harsh sites and how this relates to old age. In older trees, however, especially in individuals over 1,500 years, a strip-bark trait is adaptive. This condition occurs as a result of cambium dieback, which erodes and thereby exposes certain areas of the bole, leaving only narrow bands of bark intact.

F

The technique of cambial edge retreat has helped promote old age in bristlecone pine, but that certainly is no the only reason. Most crucial to these trees’ longevity is their compact size and slow rates of growth. By remaining in most cases under ten meters tall, bristlecones stay close to the limited water supply and can hence support more branches and photosynthesizing. Combined with the dry, windy, and often freezing mountain air, slow growth guarantees the bristlecones tight, fibrous rings with a high resin content and structural strength. The absence of natural disaster has also safeguarded the bristlecone’s lengthy lifespan. Due to a lack of ground cover vegetation and an evenly spaced layout, bristlecone stands on the White Mountain peaks have been practically unaffected by the fire. This lack of vegetation also means a lack of competition for the bristlecones.

G

Bristlecone pines restricted to numerous, rather isolated stands at higher altitudes in the southwestern United States. Stands occur from the Rocky Mountains, through the Colorado Plateau, to the western margin of the Great Basin. Within this natural range, the oldest and most widely researched stands of bristlecones occur in California’s the White Mountains. Even just 200 miles away from the Pacific Ocean, the White Mountains are home to one of this country’s few high-elevation deserts. Located in the extreme eastern rain shadow of the Sierra Nevada, this region receives only 12.54 inches of precipitation per year and experiences temperatures between -20F and +50F. The peaks south of the Owens Valley, are higher up than they might appear from a distance. Although most summits exist somewhere around 11,000 feet, snow-capped White Mountain Peak, for which the range is named, stands at 14,246 feet above sea level. That said, to reach areas of a pure bristlecone is an intense journey all to itself.

H

With seemingly endless areas of wonder and interest, the bristlecone pines have become subject to much research over the past half-century. Since the annual growth of these ancient organisms directly reflects the climatic conditions of a particular time period, bristlecones are of greatest significance to dendrochronologists or tree-ring specialists. Dating any tree is simple and can be done within reasonable accuracy just by counting out the rings made each year by the plant’s natural means of growth. By carefully compiling a nearly 10,000-year-old bristlecone pine record, these patient scientists have accurately corrected the carbon-14 dating method and estimated ages of past periods of global climate change. What makes this record so special to dendrochronologists, too, is that, nowhere, throughout time, is precisely the same long-term sequence of wide and narrow rings repeated, because year-to-year variations in climate are never exactly the same.

I

Historically the bristlecone’s remote location and gnarled wood have deterred commercial extraction, but nothing on earth will go unaffected by global warming. If temperatures rise by only 6 degrees F, which many experts say is likely this century, about two-thirds of the bristlecones’ ideal habitat in the White Mountains effectively will be gone. Almost 30,000 acres of National Forest now preserves the ancient bristlecone, but paved roads, campsites, and self-guided trails have led only to more human impact. In 1966, the U.S.F.S reported over 20,000 visitors to the Ancient Bristlecone Pine Forest, a figure which could exceed 40,000 today. Over the past hundreds of thousands of years, this species has endured in one of the earth’s most trying environments; they deserve our respect and reverence. As global climate change slowly alters their environment, we as humans must do our part to raise awareness and lower our impact.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2f3e1fc4-38f6-54b2-8f7d-50c4fc67b7aa', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-4
on your answer sheet.
1
Human activity threats bristlecone pines habitat
2
Explanations for a ring of bristlecone pines
3
An accountable recording provided from the past until now
4
Survived in a hostile environment

1 ____ Human activity threats bristlecone pines habitat$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('326b36db-b234-5c5b-8f43-a8d2707802f1', '2f3e1fc4-38f6-54b2-8f7d-50c4fc67b7aa', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d1c2f30-2486-5d58-8fc3-05b298d608d1', '2f3e1fc4-38f6-54b2-8f7d-50c4fc67b7aa', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('624eee0b-a303-5462-989e-da60c2f12291', '2f3e1fc4-38f6-54b2-8f7d-50c4fc67b7aa', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a254635a-882a-55ee-bebd-96b21574c794', '2f3e1fc4-38f6-54b2-8f7d-50c4fc67b7aa', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26a32be9-48da-58aa-ade7-7ca8a1af68c9', '2f3e1fc4-38f6-54b2-8f7d-50c4fc67b7aa', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9249ed56-7c7a-538c-9464-dbcddae0398c', '2f3e1fc4-38f6-54b2-8f7d-50c4fc67b7aa', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5eb0a3ac-4d47-5378-a60c-c96417d8eea6', '2f3e1fc4-38f6-54b2-8f7d-50c4fc67b7aa', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c703f9ea-9168-51ed-b892-dbdafdc3e529', '2f3e1fc4-38f6-54b2-8f7d-50c4fc67b7aa', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bafa9d1d-a6f2-53e4-89b2-0c875c3f351d', '2f3e1fc4-38f6-54b2-8f7d-50c4fc67b7aa', 9, $md$I$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('116eadc0-34b3-55fa-a1af-defaea57ad89', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-4
on your answer sheet.
1
Human activity threats bristlecone pines habitat
2
Explanations for a ring of bristlecone pines
3
An accountable recording provided from the past until now
4
Survived in a hostile environment

2 ____ Explanations for a ring of bristlecone pines$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d749bc6-c195-52a7-8a52-d149a8f1e289', '116eadc0-34b3-55fa-a1af-defaea57ad89', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e36babc-a319-52b4-8a04-5e9350dc72f9', '116eadc0-34b3-55fa-a1af-defaea57ad89', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f0217d3-8993-58e4-9f4d-90e323d9bf66', '116eadc0-34b3-55fa-a1af-defaea57ad89', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('902a8c97-cc0d-5adc-9d22-bc1f294d064b', '116eadc0-34b3-55fa-a1af-defaea57ad89', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e39b538-1e08-52ff-bddf-76314efc4f5b', '116eadc0-34b3-55fa-a1af-defaea57ad89', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ba4b500-43ff-5056-99be-7ee005e6ae8d', '116eadc0-34b3-55fa-a1af-defaea57ad89', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('226a709a-ad3c-578e-b350-753069984876', '116eadc0-34b3-55fa-a1af-defaea57ad89', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('911af5ef-fdf3-5357-8655-e09a91e44967', '116eadc0-34b3-55fa-a1af-defaea57ad89', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b0a3bd6-55c1-5a23-a08f-4c252467df19', '116eadc0-34b3-55fa-a1af-defaea57ad89', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e2f44f69-5921-59d3-8923-b48110d8ecc3', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-4
on your answer sheet.
1
Human activity threats bristlecone pines habitat
2
Explanations for a ring of bristlecone pines
3
An accountable recording provided from the past until now
4
Survived in a hostile environment

3 ____ An accountable recording provided from the past until now$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b45b119a-7499-56d9-a2d6-ba1e23702289', 'e2f44f69-5921-59d3-8923-b48110d8ecc3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b3e3f60-e224-5306-a0b2-511624fa8553', 'e2f44f69-5921-59d3-8923-b48110d8ecc3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f08d6bc2-3c24-5356-8c7f-a3129b65b03c', 'e2f44f69-5921-59d3-8923-b48110d8ecc3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c89f3364-2eec-5e40-a1f1-f65e9303d53d', 'e2f44f69-5921-59d3-8923-b48110d8ecc3', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58e50e3e-99e4-5faf-84f3-bf8b267cbc3c', 'e2f44f69-5921-59d3-8923-b48110d8ecc3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09d5558c-cae3-54c4-8451-28d61f2576dd', 'e2f44f69-5921-59d3-8923-b48110d8ecc3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1d5bca9-686d-5274-a4a0-f36ac7bb38e4', 'e2f44f69-5921-59d3-8923-b48110d8ecc3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5cd3ad3-6bca-5ace-87a1-2401774e52e7', 'e2f44f69-5921-59d3-8923-b48110d8ecc3', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3f44ada-5f7e-53ab-8380-dfd0e032f4a0', 'e2f44f69-5921-59d3-8923-b48110d8ecc3', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e49df30c-8ef0-599a-8c8a-f0dfd0c1dc8a', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-4
on your answer sheet.
1
Human activity threats bristlecone pines habitat
2
Explanations for a ring of bristlecone pines
3
An accountable recording provided from the past until now
4
Survived in a hostile environment

4 ____ Survived in a hostile environment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e24d7b6-c86d-52ad-b109-026b2a330d7a', 'e49df30c-8ef0-599a-8c8a-f0dfd0c1dc8a', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f549926-74e1-5766-9413-017e063f8517', 'e49df30c-8ef0-599a-8c8a-f0dfd0c1dc8a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7f4d54f-9a29-5f53-8c3d-5e98c6f24de7', 'e49df30c-8ef0-599a-8c8a-f0dfd0c1dc8a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a423b559-fd23-5a8b-9224-bedeb1ecbbe6', 'e49df30c-8ef0-599a-8c8a-f0dfd0c1dc8a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('668bc2ff-70b1-5988-8860-0acc8cbe4b68', 'e49df30c-8ef0-599a-8c8a-f0dfd0c1dc8a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48b9cc90-863d-57c8-a3bc-d1f30d3fc991', 'e49df30c-8ef0-599a-8c8a-f0dfd0c1dc8a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eecf565b-b73c-5f1a-88a2-16117bff996d', 'e49df30c-8ef0-599a-8c8a-f0dfd0c1dc8a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e4ececf-92fe-5108-b686-82cce3b91da7', 'e49df30c-8ef0-599a-8c8a-f0dfd0c1dc8a', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a389906-9462-580e-a269-f00166db2599', 'e49df30c-8ef0-599a-8c8a-f0dfd0c1dc8a', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fd417692-19dd-54c8-93f2-119f49f71a45', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-7
Questions 5-7
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
5-7
on your answer sheet.
5 According to passage A, what aspect of bristlecone pines attracts author’s attention?
A
Brutal environment they live
B
Remarkable long age
C
They only live in California
D
Outstanding height
6 Why do we investigate Bristlecone pines in higher altitudes of California’s the White Mountains?
A
Because of the oldest ones researched in this region
B
Because most bizarre ones are in this region
C
Because precipitation is rich in this region
D
Because sea level is comparatively high in this region
7 Why there are repeated patterns of wide and narrow rings?
A
Because sea level rises which affect tree ring
B
Because tree ring pattern is completely random
C
Because ancient organisms affect their growth
D
Because the variation of climate change is different

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f4f7a919-8b52-594c-80ae-197d5015c6f9', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-7
Questions 5-7
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
5-7
on your answer sheet.
5 According to passage A, what aspect of bristlecone pines attracts author’s attention?
A
Brutal environment they live
B
Remarkable long age
C
They only live in California
D
Outstanding height
6 Why do we investigate Bristlecone pines in higher altitudes of California’s the White Mountains?
A
Because of the oldest ones researched in this region
B
Because most bizarre ones are in this region
C
Because precipitation is rich in this region
D
Because sea level is comparatively high in this region
7 Why there are repeated patterns of wide and narrow rings?
A
Because sea level rises which affect tree ring
B
Because tree ring pattern is completely random
C
Because ancient organisms affect their growth
D
Because the variation of climate change is different

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f9a1a761-3b0a-5f93-aa70-55d6cc744ff9', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-7
Questions 5-7
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
5-7
on your answer sheet.
5 According to passage A, what aspect of bristlecone pines attracts author’s attention?
A
Brutal environment they live
B
Remarkable long age
C
They only live in California
D
Outstanding height
6 Why do we investigate Bristlecone pines in higher altitudes of California’s the White Mountains?
A
Because of the oldest ones researched in this region
B
Because most bizarre ones are in this region
C
Because precipitation is rich in this region
D
Because sea level is comparatively high in this region
7 Why there are repeated patterns of wide and narrow rings?
A
Because sea level rises which affect tree ring
B
Because tree ring pattern is completely random
C
Because ancient organisms affect their growth
D
Because the variation of climate change is different

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8e5309c5-13c4-5bd0-b98c-28d4e3cfece3', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the
8
of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary
9
, Germination rate is high. Because of cambium dieback, only narrow
10
remain complete. Due to multiple factors such as windy, cold climate and
11
, bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little
12
plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a
13

The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the 8 ____ of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary 9 ____ , Germination rate is high. Because of cambium dieback, only narrow 10 ____ remain complete. Due to multiple factors such as windy, cold climate and 11 ____ , bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little 12 ____ plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a 13 ____$md$, NULL, ARRAY['.*energy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ad247b4b-dc3a-5d6f-bfd2-3a0e8d2c6e87', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the
8
of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary
9
, Germination rate is high. Because of cambium dieback, only narrow
10
remain complete. Due to multiple factors such as windy, cold climate and
11
, bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little
12
plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a
13

The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the 8 ____ of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary 9 ____ , Germination rate is high. Because of cambium dieback, only narrow 10 ____ remain complete. Due to multiple factors such as windy, cold climate and 11 ____ , bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little 12 ____ plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a 13 ____$md$, NULL, ARRAY['.*energy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('38cd56c6-1b32-50c1-987e-792cc3f30c9b', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the
8
of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary
9
, Germination rate is high. Because of cambium dieback, only narrow
10
remain complete. Due to multiple factors such as windy, cold climate and
11
, bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little
12
plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a
13

The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the 8 ____ of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary 9 ____ , Germination rate is high. Because of cambium dieback, only narrow 10 ____ remain complete. Due to multiple factors such as windy, cold climate and 11 ____ , bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little 12 ____ plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a 13 ____$md$, NULL, ARRAY['.*energy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c66e8f43-6276-52dc-9cc7-6a0f6d00bd37', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the
8
of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary
9
, Germination rate is high. Because of cambium dieback, only narrow
10
remain complete. Due to multiple factors such as windy, cold climate and
11
, bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little
12
plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a
13

The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the 8 ____ of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary 9 ____ , Germination rate is high. Because of cambium dieback, only narrow 10 ____ remain complete. Due to multiple factors such as windy, cold climate and 11 ____ , bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little 12 ____ plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a 13 ____$md$, NULL, ARRAY['.*energy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('159756a8-1bb7-5fe6-9e51-f99b660474f5', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the
8
of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary
9
, Germination rate is high. Because of cambium dieback, only narrow
10
remain complete. Due to multiple factors such as windy, cold climate and
11
, bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little
12
plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a
13

The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the 8 ____ of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary 9 ____ , Germination rate is high. Because of cambium dieback, only narrow 10 ____ remain complete. Due to multiple factors such as windy, cold climate and 11 ____ , bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little 12 ____ plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a 13 ____$md$, NULL, ARRAY['.*energy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('64e1d242-a2dd-56e4-bd31-a86e394bfc51', '9a0280ec-709b-5a69-a5e4-78354ad91d6a', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the
8
of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary
9
, Germination rate is high. Because of cambium dieback, only narrow
10
remain complete. Due to multiple factors such as windy, cold climate and
11
, bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little
12
plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a
13

The bristlecone’s special adaptation is a benefit for photosynthesizing, and reserving the 8 ____ of leave replacement and providing sufficient chlorophyll. Probably because seeds do not rely on primary 9 ____ , Germination rate is high. Because of cambium dieback, only narrow 10 ____ remain complete. Due to multiple factors such as windy, cold climate and 11 ____ , bristlecones’ rings have a tight and solid structure full of resin. Moreover, bristlecone stands are safe from the fire because of little 12 ____ plants spread in this place. The summits of Owens Valley is higher than they emerge if you observe from a 13 ____$md$, NULL, ARRAY['.*energy.*']);

COMMIT;
