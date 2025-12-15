BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-reflecting-on-the-mirror-1203'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-reflecting-on-the-mirror-1203';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-reflecting-on-the-mirror-1203';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-reflecting-on-the-mirror-1203';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('54bccde4-1557-5696-bbeb-ab6c156ae23b', 'ielts-reading-reflecting-on-the-mirror-1203', $t$REFLECTING ON THE MIRROR$t$, $md$## REFLECTING ON THE MIRROR

Nguồn:
- Test: https://mini-ielts.com/1203/reading/reflecting-on-the-mirror
- Solution: https://mini-ielts.com/1203/view-solution/reading/reflecting-on-the-mirror$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('cfa56b1e-70eb-5f57-883f-6012d6f42f42', '54bccde4-1557-5696-bbeb-ab6c156ae23b', 1, $t$Reading — REFLECTING ON THE MIRROR$t$, $md$Read the passage and answer questions **1–13**.

### Passage: REFLECTING ON THE MIRROR

In all likelihood the first mirrors would have simply been pools of water that reflected the image of the one who looked into it. Nature’s mirror, while cheap and readily accessible, must have also been quite frustrating with the slightest disturbance on the surface of the water making it difficult to see clearly. It is not altogether clear when the first man-made mirrors were produced but mirrors made of brass are mentioned in the Bible , and after that mirrors of bronze were in common use among the ancient Egyptians, Romans and Greeks. In addition to bronze, the Greeks and Romans experimented with polished silver to produce simple mirrors.

Crude forms of glass mirrors were first made in Venice in 1300. Small sheets of glass were cut from disks made by a spinning process. When this glass was backed with a covering of tin or lead, a ‘mirror’ resulted. During the early periods of their development, mirrors were rare and expensive. France had glass factories but only in Venice, Italy was the secret of mirror foiling know n. The chemical process of coating a glass surface with metallic silver was discovered by German chemist Justus von Liebig in 1835, and this advance inaugurated the modern techniques of mirror making.

By the end of the 17 th century mirrors were made in Britain and the manufacture of mirrors developed subsequently into an important industry in many other European countries. People wore them in their hats, or set them like jewels in their rings. Society glittered and shone like the firmament. A little later on, America was gripped by the mirror craze, only this time they wore interested in larger mirrors. In house after house in residential districts and eastern cities there could be found one long mirror after another placed between two front parlour windows.

In the manufacture of mirrors today, plate glass is cut to size, and all blemishes are removed by polishing with rouge. The glass is scrubbed and flushed with a reducing solution before silver is applied. The glass is then placed on a hollow, cast-iron tabletop, covered with felt, and kept warm by steam. A solution of silver nitrate is poured on the glass and left undisturbed for about 1 hour . The silver nitrate is reduced to a metallic silver and a lustrous deposit of silver gradually forms. The deposit is dried, coated with shellac, and painted. Most present-day mirrors therefore, are made up of these layers. Glass is used on top because it is smooth, clear, and protects the reflective surface . A mirror needs to be very smooth in order for the best reflection to occur.

Mirrors may have plane or curved surfaces. A curved mirror is concave or convex depending on whether the reflecting surface faces toward the centre of the curvature or away from it. Curved mirrors in ordinary usage have surfaces of varying shapes. Perhaps the most common is spherical. Spherical mirrors produce images that are magnified or reduced – exemplified, by mirrors for applying facial makeup and by rear-view mirrors for vehicles . Cylindrical mirrors are another common type of shape. These focus a parallel beam flight to a linear focus. A paraboloidal mirror is one which is often used to focus parallel rays to a sharp focus, as in a telescope mirror, or to produce a parallel beam from a source at its focus, such as a searchlight. A less common but useful shape is the ellipsoidal. Such a mirror will reflect light from one of its two focal points to the other.

While the mirror is the focus of the production, the frame plays an important albeit slightly lesser role as the anchor by which the mirror is affixed to its proper place. From the late 17th century onward, mirrors and their frames played an increasingly important part in the decoration of rooms. Complementing the shiny reflective mirror, the early frames were usually of ivory, silver, ebony, or tortoiseshell or were veneered with walnut, olive, and laburnum. Needlework and bead frames were also to be found. Craftsmen such as Grinling Gibbons often produced elaborately carved mirror frames to match a complete decorative ensemble. The tradition soon became established of incorporating a mirror into the space over the mantelpiece; many of the early versions of these mirrors, usually known as overmantels, were enclosed in glass frames. The architectural structure of which these mirrors formed a part became progressively more elaborate. Focusing heavily on the effect created by mirrors, 18 th century designers such as the English brothers Robert and James Adam created fireplace units stretching from the hearth to the ceiling . Oil the whole, mirror frames reflected the general taste of the time and were often changed to accommodate alterations in taste – frames usually being cheaper and hence more easily replaced than the mirror itself.

By the end of the 18th century, painted decoration largely supplanted carving on mirrors, the frames being decorated with floral patterns or classical ornaments. At the same time the French started producing circular mirrors. Usually surrounded by a neoclassical gilt frame that sometimes supported candlesticks, these mirrors enjoyed great popularity well into the 19 th Improved skill in mirror making also made possible die introduction of the cheval glass, a freestanding full-length mirror, supported on a frame with four feet. These were mainly used for dressing purposes, though occasionally they had a decorative function. New, cheaper techniques of mirror production in the 19th century led to a great proliferation in their use. Not only were they regularly incorporated into pieces of furniture – such as wardrobes and sideboards – they were also used in everything from high-powered telescopes to decorative schemes in public places. Their popularity continues today. Through them, infants are able to develop an awareness of their individuality through ‘mirror games’. This type of emotional reflection stimulates babies to move various parts of their body and even promotes verbal utterances.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('30c8258c-f302-5b9f-8127-fd017623a818', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements reflect the claims of the writer in Reading Passage 1?
In boxes
1-5
on your answer sheet
write
TR
UE
if the statement agree with the information
FALSE
if th
e
statement contradicts the information
NOT GIVEN
if there is no information on this
1
.The Creeks arid Egyptians used polished silver to make mirrors.
Locate
2
.The first man-made mirrors were made of bronze.
Locate
3
.Only the wealthy could afford the first mirrors.
Locate
4
.The first mirrors in America were used for decoration.
5
.Spherical mirrors are commonly used in cars.
Locate

1 ____ .The Creeks arid Egyptians used polished silver to make mirrors. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6155e761-4169-573a-9f89-c4a7add9662f', '30c8258c-f302-5b9f-8127-fd017623a818', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0d716e3-7fa0-5389-854b-0c60b776f039', '30c8258c-f302-5b9f-8127-fd017623a818', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30b3243d-6352-5b26-99f4-2e6182c1dd22', '30c8258c-f302-5b9f-8127-fd017623a818', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5e838732-981e-54dd-8b8e-541814d6dd31', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements reflect the claims of the writer in Reading Passage 1?
In boxes
1-5
on your answer sheet
write
TR
UE
if the statement agree with the information
FALSE
if th
e
statement contradicts the information
NOT GIVEN
if there is no information on this
1
.The Creeks arid Egyptians used polished silver to make mirrors.
Locate
2
.The first man-made mirrors were made of bronze.
Locate
3
.Only the wealthy could afford the first mirrors.
Locate
4
.The first mirrors in America were used for decoration.
5
.Spherical mirrors are commonly used in cars.
Locate

2 ____ .The first man-made mirrors were made of bronze. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5238d6d-8c6b-5a86-9f5c-7662bce27718', '5e838732-981e-54dd-8b8e-541814d6dd31', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95b75d9b-5f3d-5de2-84bd-d7856cf89b40', '5e838732-981e-54dd-8b8e-541814d6dd31', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfde079a-fbe2-5493-bf1d-13a32cc46a15', '5e838732-981e-54dd-8b8e-541814d6dd31', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5aeffde-967a-51c2-ad9e-72e42734b86c', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements reflect the claims of the writer in Reading Passage 1?
In boxes
1-5
on your answer sheet
write
TR
UE
if the statement agree with the information
FALSE
if th
e
statement contradicts the information
NOT GIVEN
if there is no information on this
1
.The Creeks arid Egyptians used polished silver to make mirrors.
Locate
2
.The first man-made mirrors were made of bronze.
Locate
3
.Only the wealthy could afford the first mirrors.
Locate
4
.The first mirrors in America were used for decoration.
5
.Spherical mirrors are commonly used in cars.
Locate

3 ____ .Only the wealthy could afford the first mirrors. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4659252c-2986-52fc-9258-9bf80751c73e', 'a5aeffde-967a-51c2-ad9e-72e42734b86c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cef3fda5-7275-5719-a56c-d62905767769', 'a5aeffde-967a-51c2-ad9e-72e42734b86c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35cc8d99-9861-5960-876b-07d733336abf', 'a5aeffde-967a-51c2-ad9e-72e42734b86c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('037814a5-5f77-50f0-95be-c358a62b588f', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements reflect the claims of the writer in Reading Passage 1?
In boxes
1-5
on your answer sheet
write
TR
UE
if the statement agree with the information
FALSE
if th
e
statement contradicts the information
NOT GIVEN
if there is no information on this
1
.The Creeks arid Egyptians used polished silver to make mirrors.
Locate
2
.The first man-made mirrors were made of bronze.
Locate
3
.Only the wealthy could afford the first mirrors.
Locate
4
.The first mirrors in America were used for decoration.
5
.Spherical mirrors are commonly used in cars.
Locate

4 ____ .The first mirrors in America were used for decoration.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c15286ad-303f-58bf-9ad4-37cbecd4bb97', '037814a5-5f77-50f0-95be-c358a62b588f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89f2f992-6361-584b-b206-6abbcd0544f0', '037814a5-5f77-50f0-95be-c358a62b588f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9cdbc532-365c-53aa-9a67-3d7b69f38891', '037814a5-5f77-50f0-95be-c358a62b588f', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('71fceade-5dc5-51d5-aac3-be9f59d0520b', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements reflect the claims of the writer in Reading Passage 1?
In boxes
1-5
on your answer sheet
write
TR
UE
if the statement agree with the information
FALSE
if th
e
statement contradicts the information
NOT GIVEN
if there is no information on this
1
.The Creeks arid Egyptians used polished silver to make mirrors.
Locate
2
.The first man-made mirrors were made of bronze.
Locate
3
.Only the wealthy could afford the first mirrors.
Locate
4
.The first mirrors in America were used for decoration.
5
.Spherical mirrors are commonly used in cars.
Locate

5 ____ .Spherical mirrors are commonly used in cars. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6d2f58f-ef82-5384-8b4d-548c70b65345', '71fceade-5dc5-51d5-aac3-be9f59d0520b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03f9eb45-551b-508e-9ffc-0e13dda783d3', '71fceade-5dc5-51d5-aac3-be9f59d0520b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d2daed8-3eca-5abc-887e-6d7f616d81a2', '71fceade-5dc5-51d5-aac3-be9f59d0520b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2ce7e1e2-82c9-577d-b571-2fbf284d449a', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Complete the labels on Diagram A below.
Write the correct letter
A-J
in boxes
6-9
on your answer sheet.
Diagram A: Magnified side-view of a mirror
A
. rouge
B.
cast iron
C.
felt
D
. steam
E.
shellac
F.
glass
G.
metal
H.
silver nitrate paint
I.
reducing solution
6
Locate
7
Locate
8
Locate
9
Locate

6 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9cd5e0b6-47a7-5ef3-9650-2283102d3e38', '2ce7e1e2-82c9-577d-b571-2fbf284d449a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c33a1f64-5dff-5c2b-bcbe-ff503379e572', '2ce7e1e2-82c9-577d-b571-2fbf284d449a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3afb92a-9d4c-51bf-a8cb-439cde01f489', '2ce7e1e2-82c9-577d-b571-2fbf284d449a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c12d340b-24ba-5f5c-bb3f-a82388bad0a1', '2ce7e1e2-82c9-577d-b571-2fbf284d449a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0722b257-058f-5b4b-ad13-605f70f1f076', '2ce7e1e2-82c9-577d-b571-2fbf284d449a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00bf251f-02eb-5666-a71a-a3042be3bcd0', '2ce7e1e2-82c9-577d-b571-2fbf284d449a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1564c27-e91a-53a0-8451-cf8958706854', '2ce7e1e2-82c9-577d-b571-2fbf284d449a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cdbacc6-cf1e-5d82-9795-78658b6f92a0', '2ce7e1e2-82c9-577d-b571-2fbf284d449a', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a645009-3a11-5137-a747-96042b9db150', '2ce7e1e2-82c9-577d-b571-2fbf284d449a', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('173b928d-876b-5352-96c8-956467242dba', '2ce7e1e2-82c9-577d-b571-2fbf284d449a', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('285ce36e-0d24-5d05-852d-6d23b24c8445', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Complete the labels on Diagram A below.
Write the correct letter
A-J
in boxes
6-9
on your answer sheet.
Diagram A: Magnified side-view of a mirror
A
. rouge
B.
cast iron
C.
felt
D
. steam
E.
shellac
F.
glass
G.
metal
H.
silver nitrate paint
I.
reducing solution
6
Locate
7
Locate
8
Locate
9
Locate

7 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92e43bc2-6cdb-5257-a099-793852df6a65', '285ce36e-0d24-5d05-852d-6d23b24c8445', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89589689-2ec7-521f-9b30-dc0303a73489', '285ce36e-0d24-5d05-852d-6d23b24c8445', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d56d72f-11ae-5ac2-a8a4-01b5d308ec2c', '285ce36e-0d24-5d05-852d-6d23b24c8445', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eea89db2-3902-5cba-a462-1a1e7118dbee', '285ce36e-0d24-5d05-852d-6d23b24c8445', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2f787a3-8245-5e2a-9bb6-aa0b8e901e30', '285ce36e-0d24-5d05-852d-6d23b24c8445', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff3e46d3-ed3a-5a33-a343-8503f995e336', '285ce36e-0d24-5d05-852d-6d23b24c8445', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52066919-4c5b-597a-975a-e181d4b8b1a4', '285ce36e-0d24-5d05-852d-6d23b24c8445', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24eedcca-9b36-50f1-8e5c-94a21039af36', '285ce36e-0d24-5d05-852d-6d23b24c8445', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d01d457-e8bb-5915-ba47-7eb1639e9313', '285ce36e-0d24-5d05-852d-6d23b24c8445', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('598e4e48-6dd6-5e93-bb83-926bde4aa115', '285ce36e-0d24-5d05-852d-6d23b24c8445', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('17f09ac2-9156-5635-8541-7c6862b8eb7d', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Complete the labels on Diagram A below.
Write the correct letter
A-J
in boxes
6-9
on your answer sheet.
Diagram A: Magnified side-view of a mirror
A
. rouge
B.
cast iron
C.
felt
D
. steam
E.
shellac
F.
glass
G.
metal
H.
silver nitrate paint
I.
reducing solution
6
Locate
7
Locate
8
Locate
9
Locate

8 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('238a5c94-e5e0-53a5-b1c6-2bca8c55863d', '17f09ac2-9156-5635-8541-7c6862b8eb7d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('303e455c-3c31-51ed-8351-80a8a19a41e6', '17f09ac2-9156-5635-8541-7c6862b8eb7d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3fe5d70d-aece-59e8-8f84-c1802e15fd4a', '17f09ac2-9156-5635-8541-7c6862b8eb7d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5832052a-ebc9-5902-8fbc-5f23c030bc07', '17f09ac2-9156-5635-8541-7c6862b8eb7d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94e03a24-e738-5749-8e7f-d4516205bb90', '17f09ac2-9156-5635-8541-7c6862b8eb7d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8193ba97-0e00-5402-ad9a-cb4c86fd8075', '17f09ac2-9156-5635-8541-7c6862b8eb7d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25881adc-903f-5187-9f12-7d4bb3fe2c0a', '17f09ac2-9156-5635-8541-7c6862b8eb7d', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf1d4160-02b4-5e1a-a40d-5a286e6b08c6', '17f09ac2-9156-5635-8541-7c6862b8eb7d', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93189eed-0094-5a4e-aba3-8888f0a5b52b', '17f09ac2-9156-5635-8541-7c6862b8eb7d', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c124b9c6-47b0-5b9d-a279-31f0d1d01ee4', '17f09ac2-9156-5635-8541-7c6862b8eb7d', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9649e213-ef17-5243-ae53-a4c3a216c58f', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Complete the labels on Diagram A below.
Write the correct letter
A-J
in boxes
6-9
on your answer sheet.
Diagram A: Magnified side-view of a mirror
A
. rouge
B.
cast iron
C.
felt
D
. steam
E.
shellac
F.
glass
G.
metal
H.
silver nitrate paint
I.
reducing solution
6
Locate
7
Locate
8
Locate
9
Locate

9 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3eb3baeb-0a8b-53ac-bee1-86496b2c21ff', '9649e213-ef17-5243-ae53-a4c3a216c58f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a7d24bf-1dfa-5b6d-b8ec-184a3463c59c', '9649e213-ef17-5243-ae53-a4c3a216c58f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bbcbde7-7788-5a7a-a6fd-f4f8da3fd6c6', '9649e213-ef17-5243-ae53-a4c3a216c58f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7cd26b3-e815-5645-897d-b32af8d42102', '9649e213-ef17-5243-ae53-a4c3a216c58f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d30cb10-5791-5fad-b470-f3a7c62f539e', '9649e213-ef17-5243-ae53-a4c3a216c58f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab1af87b-53b1-553f-a3b2-b97ef1310e42', '9649e213-ef17-5243-ae53-a4c3a216c58f', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f72cdd89-0d9b-5cff-8905-2c2fac9b21f9', '9649e213-ef17-5243-ae53-a4c3a216c58f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11675e5c-33f7-58a2-b593-6026d8b7260a', '9649e213-ef17-5243-ae53-a4c3a216c58f', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43786024-f40d-5c07-a0e7-b50470069c9c', '9649e213-ef17-5243-ae53-a4c3a216c58f', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0170c570-4b47-5634-8b7e-5956dcaf2fb4', '9649e213-ef17-5243-ae53-a4c3a216c58f', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('55ab1c08-ab51-5282-8963-dcf1f09b6d73', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Choose the correct letter
A, B, C, or D.
Write your answers in boxes
10-13
on your
answer
sheet.
10.
The type of mirror used for looking at the stars is
A
. paraboloidal.
B
.spherical.
C
. cylindrical.
D
. ellipsoidal.
Locate
11
. 17
th
century craftsmen
A
. blended mirror frames well with other household furniture.
B
. hung mirrors above fireplaces.
C
. used mirror frames as a focus for home decoration.
D
. established floral patterns as a standard for mirror frames.
Locate
12
. 18
th
century craftsmen
A
. designed furniture which highlighted the unique properties of mirrors.
B
. experimented largely with mirror frames made of ebony and ivory.
C
. built spherically-shaped minors.
D
. experimented with ceiling mirrors around fireplaces.
Locate
13.
19
th
century craftsmen
A
. used mirrors less than any previous time in history.
B
. introduced mirrors as learning tools.
C
. used mirrors extensively in bedroom furniture.
D
. etched designs into mirrors.
Locate

Choose the correct letter A, B, C, or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4df7a3a1-6874-5401-9773-ade1024bfeb3', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Choose the correct letter
A, B, C, or D.
Write your answers in boxes
10-13
on your
answer
sheet.
10.
The type of mirror used for looking at the stars is
A
. paraboloidal.
B
.spherical.
C
. cylindrical.
D
. ellipsoidal.
Locate
11
. 17
th
century craftsmen
A
. blended mirror frames well with other household furniture.
B
. hung mirrors above fireplaces.
C
. used mirror frames as a focus for home decoration.
D
. established floral patterns as a standard for mirror frames.
Locate
12
. 18
th
century craftsmen
A
. designed furniture which highlighted the unique properties of mirrors.
B
. experimented largely with mirror frames made of ebony and ivory.
C
. built spherically-shaped minors.
D
. experimented with ceiling mirrors around fireplaces.
Locate
13.
19
th
century craftsmen
A
. used mirrors less than any previous time in history.
B
. introduced mirrors as learning tools.
C
. used mirrors extensively in bedroom furniture.
D
. etched designs into mirrors.
Locate

Choose the correct letter A, B, C, or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('afa6359a-ac97-5626-ad86-263a46242ae6', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Choose the correct letter
A, B, C, or D.
Write your answers in boxes
10-13
on your
answer
sheet.
10.
The type of mirror used for looking at the stars is
A
. paraboloidal.
B
.spherical.
C
. cylindrical.
D
. ellipsoidal.
Locate
11
. 17
th
century craftsmen
A
. blended mirror frames well with other household furniture.
B
. hung mirrors above fireplaces.
C
. used mirror frames as a focus for home decoration.
D
. established floral patterns as a standard for mirror frames.
Locate
12
. 18
th
century craftsmen
A
. designed furniture which highlighted the unique properties of mirrors.
B
. experimented largely with mirror frames made of ebony and ivory.
C
. built spherically-shaped minors.
D
. experimented with ceiling mirrors around fireplaces.
Locate
13.
19
th
century craftsmen
A
. used mirrors less than any previous time in history.
B
. introduced mirrors as learning tools.
C
. used mirrors extensively in bedroom furniture.
D
. etched designs into mirrors.
Locate

Choose the correct letter A, B, C, or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9b179df1-0b5d-5a9c-a183-a67dc6e0c9fd', 'cfa56b1e-70eb-5f57-883f-6012d6f42f42', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Choose the correct letter
A, B, C, or D.
Write your answers in boxes
10-13
on your
answer
sheet.
10.
The type of mirror used for looking at the stars is
A
. paraboloidal.
B
.spherical.
C
. cylindrical.
D
. ellipsoidal.
Locate
11
. 17
th
century craftsmen
A
. blended mirror frames well with other household furniture.
B
. hung mirrors above fireplaces.
C
. used mirror frames as a focus for home decoration.
D
. established floral patterns as a standard for mirror frames.
Locate
12
. 18
th
century craftsmen
A
. designed furniture which highlighted the unique properties of mirrors.
B
. experimented largely with mirror frames made of ebony and ivory.
C
. built spherically-shaped minors.
D
. experimented with ceiling mirrors around fireplaces.
Locate
13.
19
th
century craftsmen
A
. used mirrors less than any previous time in history.
B
. introduced mirrors as learning tools.
C
. used mirrors extensively in bedroom furniture.
D
. etched designs into mirrors.
Locate

Choose the correct letter A, B, C, or D.$md$, NULL);

COMMIT;
