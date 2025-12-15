BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-cosmetics-in-ancient-past-1265'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-cosmetics-in-ancient-past-1265';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-cosmetics-in-ancient-past-1265';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-cosmetics-in-ancient-past-1265';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('08bb8e66-661b-575f-ab60-e7f0025f1f69', 'ielts-reading-cosmetics-in-ancient-past-1265', $t$Cosmetics in Ancient Past$t$, $md$## Cosmetics in Ancient Past

Nguồn:
- Test: https://mini-ielts.com/1265/reading/cosmetics-in-ancient-past
- Solution: https://mini-ielts.com/1265/view-solution/reading/cosmetics-in-ancient-past$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', '08bb8e66-661b-575f-ab60-e7f0025f1f69', 1, $t$Reading — Cosmetics in Ancient Past$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Cosmetics in Ancient Past

A

Since cosmetics and perfumes are still in wide use today, it is interesting to compare the attitudes, customs and beliefs related to them in ancient times to those of our own day and age. Cosmetics and perfumes have been popular since the dawn of civilization; it is shown by the discovery of a great deal of pertinent archaeological material, dating from the third millennium BC. Mosaics, glass perfume flasks, stone vessels, ovens, cooking-pots, clay jars, etc., some inscribed by the hand of the artisan. Evidence also appears in the Bible and other classical writings, where it is written that spices and perfumes were prestigious products known throughout the ancient world and coveted by kings and princes. The written and pictorial descriptions, as well as archaeological findings, all show how important body care and aesthetic appearance were in the lives of the ancient people. The chain of evidence spans many centuries, detailing the usage of cosmetics in various cultures from the earliest period of recorded history.

B

In antiquity, however, at least in the onset, cosmetics served in religious ceremonies and for healing purposes. Cosmetics were also connected with cultic worship and witchcraft: to appease the various gods, fragrant ointments were applied to the statuary images and even to their attendants. From this, in the course of time, developed the custom of personal use, to enhance the beauty of the face and the body, and to conceal defects.

C

Perfumes and fragrant spices were precious commodities in antiquity, very much in demand, and at times even exceeded silver and gold in value. Therefore they were luxury products, used mainly in the temples and in the homes of the noble and wealthy. The Judean kings kept them in treasure houses (2 Kings 20:13). And the Queen of Sheba brought to Solomon “camels laden with spices, gold in great quantity and precious stones.” (1 Kings 10:2, 10). However, within time, the use of cosmetics became the custom of that period. The use of cosmetics became widespread among the lower classes as well as among the wealthy; in the same way, they washed the body, so they used to care for the body with substances that softened the skin and anoint it with fragrant oils and ointments.

D

Facial treatment was highly developed and women devoted many hours to it. They used to spread various scented creams on the face and to apply makeup in vivid and contrasting colors. An Egyptian papyrus from the 16th century BC contains detailed recipes to remove blemishes, wrinkles, and other signs of age. Greek and Roman women would cover their faces in the evening with a “beauty mask” to remove blemishes, which consisted mainly of flour mixed with fragrant spices, leaving it on their face all night. The next morning they would wash it off with asses’ milk. The very common creams used by women in the ancient Far East, particularly important in the hot climate and prevalent in that area of the globe, were made up of oils and aromatic scents. Sometimes the oil in these creams was extracted from olives, almonds, gourds, sesame, or from trees and plants; but, for those of limited means, scented animal and fish fats were commonly used.

E

Women in the ancient past commonly put colors around their eyes. Besides beautification, its purpose was also medicinal as covering the sensitive skin of the lids with colored ointments that prevented dryness and eye diseases: the eye-paint repelled the little flies that transmitted eye inflammations. Egyptian women colored the upper eyelid black and the lower one green and painted the space between the upper lid and the eyebrow gray and blue. The women of Mesopotamia favored yellows and reds. The use of kohl for painting the eyes is mentioned three times in the Bible, always with disapproval by the sages (2 Kings, 9:30; Jeremiah 4:30; Ezekiel 23:40). In contrast, Job named one of his daughters “Keren Happukh”- “horn of eye paint” (Job 42:14)

F

Great importance was attached to the care for hair in ancient times. Long hair was always considered a symbol of beauty, and kings, nobles and dignitaries grew their hair long and kept it well-groomed and cared for. Women devoted much time to the style of the hair; while no cutting, they would apply much care to it by arranging it skillfully in plaits and “building it up” sometimes with the help of wigs. Egyptian women generally wore their hair flowing down to their shoulders or even longer. In Mesopotamia, women cherished long hair as a part of their beauty, and hair flowing down their backs in a thick plait and tied with a ribbon is seen in art. Assyrian women wore their hair shorter, braiding and binding it in a bun at the back. In Ancient Israel, brides would wear their hair long on the wedding day as a sign of their virginity. Ordinary people and slaves, however, usually wore their hair short, mainly for hygienic reasons, since they could not afford to invest in the kind of treatment that long hair required.

G

From the Bible and Egyptian and Assyrian sources, as well as the words of classical authors, it appears that the centers of the trade-in aromatic resins and incense were located in the kingdoms of southern Arabia, and even as far as India, where some of these precious aromatic plants were grown. “Dealers from Sheba and Rammah dealt with you, offering the choicest spices…” (Ezekiel 27:22). The Nabateans functioned as the important middlemen in this trade; Palestine also served as a very important component, as the trade routes crisscrossed the country. It is known that the Egyptian Queen Hatsheput (15th century BC) sent a royal expedition to the Land of Punt (Somalia) in order to bring back myrrh seedlings to plant in her temple. In Assyrian records of tribute and spoils of war, perfumes and resins are mentioned; the text from the time of Tukulti-Ninurta II (890-884 BC) refers to balls of myrrh as a part of the tribute brought to the Assyrian king by the Aramaean kings. The trade-in spices and perfumes are also mentioned in the Bible as written in Genesis (37:25-26), “Camels carrying gum tragacanth and balm and myrrh”.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('61c017ec-69c5-551d-bab9-0a79f181b163', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 15-21
Questions 15-21
Reading Passage has 7 paragraphs
A-G
Which paragraph contains the following information?
Write your answers in boxes
1-7
on your answer sheet.
1
recipes to conceal facial defects caused by aging
2
perfumes were presented to conquerors in war
3
long hair of girls had special meanings in marriage
4
evidence exists in abundance showing cosmetics use in ancient times
5
protecting eyes from fly-transmitted diseases
6
from witchcraft to beautification
7
more expensive than gold

1 ____ recipes to conceal facial defects caused by aging$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7db40f0b-3f55-58c8-9242-9ab446e05669', '61c017ec-69c5-551d-bab9-0a79f181b163', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b60bc25f-e2c4-5c85-9dc2-87744d0b22a2', '61c017ec-69c5-551d-bab9-0a79f181b163', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40427bb6-1669-5383-b1e6-b76ab90dad5d', '61c017ec-69c5-551d-bab9-0a79f181b163', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4387ab42-f24d-5f03-8107-ddcfcdbb4445', '61c017ec-69c5-551d-bab9-0a79f181b163', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2381866d-0317-5a9a-84f9-96ad8fead063', '61c017ec-69c5-551d-bab9-0a79f181b163', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1176f29d-7f0e-51db-8253-7bf1a44a192f', '61c017ec-69c5-551d-bab9-0a79f181b163', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0dff6f67-5ee8-531d-abdd-6bbb6088e43e', '61c017ec-69c5-551d-bab9-0a79f181b163', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('836e4046-0c02-53cf-92a7-4dd4b6ed9c99', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 15-21
Questions 15-21
Reading Passage has 7 paragraphs
A-G
Which paragraph contains the following information?
Write your answers in boxes
1-7
on your answer sheet.
1
recipes to conceal facial defects caused by aging
2
perfumes were presented to conquerors in war
3
long hair of girls had special meanings in marriage
4
evidence exists in abundance showing cosmetics use in ancient times
5
protecting eyes from fly-transmitted diseases
6
from witchcraft to beautification
7
more expensive than gold

2 ____ perfumes were presented to conquerors in war$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5722e89f-7cd4-5471-84df-0b96b24f2dff', '836e4046-0c02-53cf-92a7-4dd4b6ed9c99', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8324a305-8fdf-5238-ab8a-dd2e95981006', '836e4046-0c02-53cf-92a7-4dd4b6ed9c99', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85acd014-cc53-5207-b510-5ab3ca09f6e9', '836e4046-0c02-53cf-92a7-4dd4b6ed9c99', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2a32783-5d90-57b7-8026-f17087387879', '836e4046-0c02-53cf-92a7-4dd4b6ed9c99', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f49a18a1-2ef5-5583-bcc4-bae554ec404d', '836e4046-0c02-53cf-92a7-4dd4b6ed9c99', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b82db3fb-05a5-5840-959d-58ad9f8ad30f', '836e4046-0c02-53cf-92a7-4dd4b6ed9c99', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2983f62-fac4-5164-bac3-8857a0ec7506', '836e4046-0c02-53cf-92a7-4dd4b6ed9c99', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dac92126-48ad-5565-9382-0f60597a3dcd', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 15-21
Questions 15-21
Reading Passage has 7 paragraphs
A-G
Which paragraph contains the following information?
Write your answers in boxes
1-7
on your answer sheet.
1
recipes to conceal facial defects caused by aging
2
perfumes were presented to conquerors in war
3
long hair of girls had special meanings in marriage
4
evidence exists in abundance showing cosmetics use in ancient times
5
protecting eyes from fly-transmitted diseases
6
from witchcraft to beautification
7
more expensive than gold

3 ____ long hair of girls had special meanings in marriage$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4bb33644-81e1-54b4-8cb3-69393aced2e4', 'dac92126-48ad-5565-9382-0f60597a3dcd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12abd962-41bf-5978-893f-ea4fa4cd28ee', 'dac92126-48ad-5565-9382-0f60597a3dcd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76c3a946-03da-5808-b60c-db5c3bb7a5e8', 'dac92126-48ad-5565-9382-0f60597a3dcd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8cd695d4-101d-5148-9454-f3ddf1ed5f53', 'dac92126-48ad-5565-9382-0f60597a3dcd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('548738f1-a5a2-56fd-aed4-c442859adeda', 'dac92126-48ad-5565-9382-0f60597a3dcd', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0c05fea-f3d7-53b9-95f9-57da9c606dc1', 'dac92126-48ad-5565-9382-0f60597a3dcd', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e24b70cb-fc1f-593f-9d75-ac87ab4bf0f7', 'dac92126-48ad-5565-9382-0f60597a3dcd', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f5ca65e4-94e6-57fe-b497-0b25699f8ed6', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 15-21
Questions 15-21
Reading Passage has 7 paragraphs
A-G
Which paragraph contains the following information?
Write your answers in boxes
1-7
on your answer sheet.
1
recipes to conceal facial defects caused by aging
2
perfumes were presented to conquerors in war
3
long hair of girls had special meanings in marriage
4
evidence exists in abundance showing cosmetics use in ancient times
5
protecting eyes from fly-transmitted diseases
6
from witchcraft to beautification
7
more expensive than gold

4 ____ evidence exists in abundance showing cosmetics use in ancient times$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbdf51b5-13c8-50d1-a7bf-4a668d09cedd', 'f5ca65e4-94e6-57fe-b497-0b25699f8ed6', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('699ed6b4-09a9-5ef0-b4e1-ef3b8a83977d', 'f5ca65e4-94e6-57fe-b497-0b25699f8ed6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acddef5e-5c93-5afe-8be5-c4f1360cd452', 'f5ca65e4-94e6-57fe-b497-0b25699f8ed6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1e114e6-35b1-5942-a438-4367e0bae152', 'f5ca65e4-94e6-57fe-b497-0b25699f8ed6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37bda1a5-cab8-5d8c-9610-787953bc24d6', 'f5ca65e4-94e6-57fe-b497-0b25699f8ed6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2ccc1f6-32a4-5366-b7c8-5f89c1c02ef5', 'f5ca65e4-94e6-57fe-b497-0b25699f8ed6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5944b3e-ddfd-57d0-9f57-1b127539b87a', 'f5ca65e4-94e6-57fe-b497-0b25699f8ed6', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('da55c387-2f1c-54ca-bcd6-e057b4b29f96', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 15-21
Questions 15-21
Reading Passage has 7 paragraphs
A-G
Which paragraph contains the following information?
Write your answers in boxes
1-7
on your answer sheet.
1
recipes to conceal facial defects caused by aging
2
perfumes were presented to conquerors in war
3
long hair of girls had special meanings in marriage
4
evidence exists in abundance showing cosmetics use in ancient times
5
protecting eyes from fly-transmitted diseases
6
from witchcraft to beautification
7
more expensive than gold

5 ____ protecting eyes from fly-transmitted diseases$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d53a2761-be7b-5208-8cda-47232b8c6d48', 'da55c387-2f1c-54ca-bcd6-e057b4b29f96', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5571d938-f6d9-551f-a7bc-44ab8f3838af', 'da55c387-2f1c-54ca-bcd6-e057b4b29f96', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff78ddee-9be4-5414-899a-9e10f219d709', 'da55c387-2f1c-54ca-bcd6-e057b4b29f96', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd417ac5-93f3-5db5-88b8-b8ac6c558e55', 'da55c387-2f1c-54ca-bcd6-e057b4b29f96', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6aa59465-d7ee-578e-9ff8-3415475b9503', 'da55c387-2f1c-54ca-bcd6-e057b4b29f96', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89aa78f3-51ed-574a-a895-1780d5a4c4e3', 'da55c387-2f1c-54ca-bcd6-e057b4b29f96', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36bc62a6-7885-5ecc-8673-135881894685', 'da55c387-2f1c-54ca-bcd6-e057b4b29f96', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('84ecd866-7dc3-56a7-90cd-d18054bed258', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 15-21
Questions 15-21
Reading Passage has 7 paragraphs
A-G
Which paragraph contains the following information?
Write your answers in boxes
1-7
on your answer sheet.
1
recipes to conceal facial defects caused by aging
2
perfumes were presented to conquerors in war
3
long hair of girls had special meanings in marriage
4
evidence exists in abundance showing cosmetics use in ancient times
5
protecting eyes from fly-transmitted diseases
6
from witchcraft to beautification
7
more expensive than gold

6 ____ from witchcraft to beautification$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a10b50f-d5c1-5471-82ff-8db05b7a7ec7', '84ecd866-7dc3-56a7-90cd-d18054bed258', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9004e586-3268-53ec-8d60-3d3c2bf8605b', '84ecd866-7dc3-56a7-90cd-d18054bed258', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e3ca8b3-7d8c-562f-a4f4-e80d081f26df', '84ecd866-7dc3-56a7-90cd-d18054bed258', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c8bb056-5d5d-5dcd-b220-8a57f2573607', '84ecd866-7dc3-56a7-90cd-d18054bed258', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfa93c93-4a35-5ea2-aac5-5f4a5a392839', '84ecd866-7dc3-56a7-90cd-d18054bed258', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3acac4c7-14f5-5d62-9779-584e1fecdd88', '84ecd866-7dc3-56a7-90cd-d18054bed258', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68da28d8-e1e4-5504-a71e-0f3559b41ed4', '84ecd866-7dc3-56a7-90cd-d18054bed258', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ff561af7-2a2a-52a7-bf3e-bc0055e61cea', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 15-21
Questions 15-21
Reading Passage has 7 paragraphs
A-G
Which paragraph contains the following information?
Write your answers in boxes
1-7
on your answer sheet.
1
recipes to conceal facial defects caused by aging
2
perfumes were presented to conquerors in war
3
long hair of girls had special meanings in marriage
4
evidence exists in abundance showing cosmetics use in ancient times
5
protecting eyes from fly-transmitted diseases
6
from witchcraft to beautification
7
more expensive than gold

7 ____ more expensive than gold$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d6506ce-000e-50cc-ae91-96d3edd7a2a8', 'ff561af7-2a2a-52a7-bf3e-bc0055e61cea', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f02c24a0-d5dc-5aef-971f-d48632c6ace9', 'ff561af7-2a2a-52a7-bf3e-bc0055e61cea', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f01cfb96-3fc1-5d8a-9fce-18fe45490d91', 'ff561af7-2a2a-52a7-bf3e-bc0055e61cea', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e35292a4-600d-512a-b7af-678dfdf14503', 'ff561af7-2a2a-52a7-bf3e-bc0055e61cea', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('774f84c7-beaf-5ce7-93f7-f95d2eaf00f1', 'ff561af7-2a2a-52a7-bf3e-bc0055e61cea', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('316ba3ca-5893-5ebe-b46c-3ecdae4ad651', 'ff561af7-2a2a-52a7-bf3e-bc0055e61cea', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c15f41aa-616a-5488-bc7f-2462502bf348', 'ff561af7-2a2a-52a7-bf3e-bc0055e61cea', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('999018c1-db0a-58a0-ba6e-9744e0d57b14', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
The written record for cosmetics and perfumes dates back to the third millennium BC.
9
Since perfumes and spices were luxury products, their use was exclusive to the noble and the wealthy.
10
In the ancient Far East, fish fats were used as a cream by a woman from poor households.
11
The teachings in the Bible were repeatedly against the use of kohl for painting the eyes.
12
Long hair as a symbol of beauty was worn solely by women of ancient cultures
13
The Egyptian Queen Hatsheput sent a royal expedition to Punt to establish a trade route for myrrh

8 ____ The written record for cosmetics and perfumes dates back to the third millennium BC.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b708b1fd-7c6d-5501-9ee9-e11d6498eba5', '999018c1-db0a-58a0-ba6e-9744e0d57b14', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e557d2f5-8ba0-5fae-8a19-ff7a3add36bb', '999018c1-db0a-58a0-ba6e-9744e0d57b14', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4563a5e-2fa1-5eaf-a9f8-bfca4ebfde37', '999018c1-db0a-58a0-ba6e-9744e0d57b14', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c1ec81b5-3454-53c8-933e-e98e8a01ed5c', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
The written record for cosmetics and perfumes dates back to the third millennium BC.
9
Since perfumes and spices were luxury products, their use was exclusive to the noble and the wealthy.
10
In the ancient Far East, fish fats were used as a cream by a woman from poor households.
11
The teachings in the Bible were repeatedly against the use of kohl for painting the eyes.
12
Long hair as a symbol of beauty was worn solely by women of ancient cultures
13
The Egyptian Queen Hatsheput sent a royal expedition to Punt to establish a trade route for myrrh

9 ____ Since perfumes and spices were luxury products, their use was exclusive to the noble and the wealthy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be7ba2e8-0cc4-5a31-9b80-0b49a093b2c3', 'c1ec81b5-3454-53c8-933e-e98e8a01ed5c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22504f1e-8a47-51d7-b76b-8ffa1abac910', 'c1ec81b5-3454-53c8-933e-e98e8a01ed5c', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fac4d14b-0e3d-5323-992d-c0dd4b192a6c', 'c1ec81b5-3454-53c8-933e-e98e8a01ed5c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('46ba1250-435d-5240-a075-2d2ebdf9e993', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
The written record for cosmetics and perfumes dates back to the third millennium BC.
9
Since perfumes and spices were luxury products, their use was exclusive to the noble and the wealthy.
10
In the ancient Far East, fish fats were used as a cream by a woman from poor households.
11
The teachings in the Bible were repeatedly against the use of kohl for painting the eyes.
12
Long hair as a symbol of beauty was worn solely by women of ancient cultures
13
The Egyptian Queen Hatsheput sent a royal expedition to Punt to establish a trade route for myrrh

10 ____ In the ancient Far East, fish fats were used as a cream by a woman from poor households.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e584c7cd-0f55-50b3-97c9-eae5792a0326', '46ba1250-435d-5240-a075-2d2ebdf9e993', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8032b95e-84f2-5897-9b2c-afe7698d0dad', '46ba1250-435d-5240-a075-2d2ebdf9e993', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15147b56-f325-5d49-a205-799d293ebf64', '46ba1250-435d-5240-a075-2d2ebdf9e993', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8ed18773-e9da-5603-aa18-f26949f18330', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
The written record for cosmetics and perfumes dates back to the third millennium BC.
9
Since perfumes and spices were luxury products, their use was exclusive to the noble and the wealthy.
10
In the ancient Far East, fish fats were used as a cream by a woman from poor households.
11
The teachings in the Bible were repeatedly against the use of kohl for painting the eyes.
12
Long hair as a symbol of beauty was worn solely by women of ancient cultures
13
The Egyptian Queen Hatsheput sent a royal expedition to Punt to establish a trade route for myrrh

11 ____ The teachings in the Bible were repeatedly against the use of kohl for painting the eyes.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dec67052-690a-5e48-85a5-c8776a3b2412', '8ed18773-e9da-5603-aa18-f26949f18330', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f8163f8-9222-5d21-8e8b-8632660413ad', '8ed18773-e9da-5603-aa18-f26949f18330', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fb018df-1dfd-5413-8c4a-cdad404e930b', '8ed18773-e9da-5603-aa18-f26949f18330', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d6c0b5d-2c70-5dba-8953-7991078c6d0a', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
The written record for cosmetics and perfumes dates back to the third millennium BC.
9
Since perfumes and spices were luxury products, their use was exclusive to the noble and the wealthy.
10
In the ancient Far East, fish fats were used as a cream by a woman from poor households.
11
The teachings in the Bible were repeatedly against the use of kohl for painting the eyes.
12
Long hair as a symbol of beauty was worn solely by women of ancient cultures
13
The Egyptian Queen Hatsheput sent a royal expedition to Punt to establish a trade route for myrrh

12 ____ Long hair as a symbol of beauty was worn solely by women of ancient cultures$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa38499e-3026-5446-8311-4849a596ff00', '5d6c0b5d-2c70-5dba-8953-7991078c6d0a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c84fd850-5ba6-5dd2-8cd9-35458f406185', '5d6c0b5d-2c70-5dba-8953-7991078c6d0a', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('492a6a23-3f94-55d5-af94-be5d0e442eec', '5d6c0b5d-2c70-5dba-8953-7991078c6d0a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('92c96ea9-aee4-52f3-80a7-69eac8a6b7c7', '8bcbb2cf-6b9d-5c14-99fe-04aa42639a03', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
The written record for cosmetics and perfumes dates back to the third millennium BC.
9
Since perfumes and spices were luxury products, their use was exclusive to the noble and the wealthy.
10
In the ancient Far East, fish fats were used as a cream by a woman from poor households.
11
The teachings in the Bible were repeatedly against the use of kohl for painting the eyes.
12
Long hair as a symbol of beauty was worn solely by women of ancient cultures
13
The Egyptian Queen Hatsheput sent a royal expedition to Punt to establish a trade route for myrrh

13 ____ The Egyptian Queen Hatsheput sent a royal expedition to Punt to establish a trade route for myrrh$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b28c10b1-752a-52ae-b238-24566c1eb8c1', '92c96ea9-aee4-52f3-80a7-69eac8a6b7c7', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abcc070f-aa78-59c1-af44-d6a5e4ff8d80', '92c96ea9-aee4-52f3-80a7-69eac8a6b7c7', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('911d4697-71e2-5d63-a90d-53518017d2ca', '92c96ea9-aee4-52f3-80a7-69eac8a6b7c7', 3, $md$NOT GIVEN$md$, true);

COMMIT;
