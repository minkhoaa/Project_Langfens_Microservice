BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-traditional-maori-medicines-1522'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-traditional-maori-medicines-1522';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-traditional-maori-medicines-1522';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-traditional-maori-medicines-1522';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('0b7082f5-96be-5c3e-9984-b8a2514dbfc7', 'ielts-reading-traditional-maori-medicines-1522', $t$Traditional Maori medicines$t$, $md$## Traditional Maori medicines

Nguồn:
- Test: https://mini-ielts.com/1522/reading/traditional-maori-medicines
- Solution: https://mini-ielts.com/1522/view-solution/reading/traditional-maori-medicines$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('5ab7da2e-c94c-56fc-a568-2c385200d095', '0b7082f5-96be-5c3e-9984-b8a2514dbfc7', 1, $t$Reading — Traditional Maori medicines$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Traditional Maori medicines

The Maori are the indigenous people of the islands of New Zealand. Their traditional medicine, which is believed to date back as far as the 13th century, was a system of healing that was passed down through the generations orally. It comprised diverse practices and placed an emphasis on the spiritual dimension of health. Its practice included remedies made from herbs, and physical therapies such as massage to relieve discomfort in the muscles and bones.

Maori systems for treating illness were well developed before European arrived in New Zealand in the late 1700s: they had quite detailed knowledge of anatomy and recognition of the healing properties of various plants. When Europeans first visited New Zealand, the average age of death for Maori adults was around 30. However, apart from this, the people were fit and healthy, and troubled by few diseases.

Illness was often seen as spiritually based. Maori saw themselves as guardians of the earth, and the focus of their existence was to remain at one with the natural and supernatural world. Rather than a medical problem, sickness was often viewed as a symptom of disharmony with natures.

In Maori culture, illnesses were divided into diseases of the gods (mate atua) and physical diseases (mate tangata). Diseases sent by the gods were often attributed to attacks by evil spirits, because the person had broken a religious rule. For instance, for Maori, Places where people had died, or places where their ancestors were buried were sacred, so if someone took food from a river where someone had died, or took a stick form a tree that had held their ancestor's bones and placed it on a cooking fire, it was believed that the gods could punish them for their disrespectful acts by making them SICK.

More than 200 plants were used medicinally by Maori. The leaves of the flax plant were used to treat skin infections and food poisoning, and the hard part of the leaf was also used as a splint or brace for broken bones and injured backs. Flax fibers were used along with a sharpened stick to sew up bad cuts. The bark and leaves of the pepper tree were used to heal cuts, wounds and stomach pain. People who had toothache were instructed to chew the leaves of this same tree, and this was found to be of considerable benefit. The pepper tree was also used in vapor baths to treat people with painful joints.

Colonization by European in the 1800s had a significant effect on traditional Maori healing. Europeans brought many new diseases with them which Maori healers had limited ability to combat. Though Western medicine was also relatively ineffectual at the time, this failure still strongly affected Maori confidence in their healers. Some western missionaries attributed the spread of disease to the fact the Maori did not believe in Christianity, and as Maori healers appeared powerless, many Maori accepted this explanation and turned to Christianity. Over time the schools of higher learning which ahd trained healers started to close and the tradition of the Maori healer declined.

From the late 20th century, there was renewed Maori interest in their traditional medicine. This was due to several factors. There was a resurgence of all aspects of Maori culture in New Zealand. Furthermore, people started to be less trusting of Western medicine-statistics from the 1970s came out revealing that Maori health continued to be poorer than that of other New Zealanders. There were also problems with access to health care for Maori. Additionally, there was and still a today a perceived lack of a spiritual dimension in Western health services.

Although Maori today largely accepted Western concepts of health and illness, and use the mainstream health system, there is significant demand for traditional medicine. This is true for unusual illnesses, or those that fail to respond to standard medical treatment, but also for common ailments such as the cold and influenza.

Today's healers differ significantly from those of old times. Training is highly variable, usually informal, and often less tribally bound than the rigorous education of the traditional houses of higher learning. Many modern healers work in urban clinics, some alongside mainstream health professionals. They experiment, incorporating knowledge from Western and other medical systems. As a result, their modern day work has no standard system of diagnosis or widespread agreement about treatments. Despite this, many healers are recognized as having knowledge and ability that has been passed down from their ancestors. The Maori language is also seen as important by many of those receiving treatment.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fe3b7cc8-b8c3-5d17-8284-a4e65ac3260f', '5ab7da2e-c94c-56fc-a568-2c385200d095', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Early Maori healers learned their skills through studying written texts.
2
The first Europeans in New Zealand were surprised by how long the Maori lived.
3
Diseases of the gods were believed to be more serious than physical diseases.
4
The leaves of the pepper tree were used to treat toothache.
5
Western religion was one reason why traditional Maori medicine became less popular.
6
Modern day Maori healers often reach the same conclusion about the type of treatment which is best.

1 ____ Early Maori healers learned their skills through studying written texts.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd9b7537-eef7-5a57-aee5-17d703e37b1c', 'fe3b7cc8-b8c3-5d17-8284-a4e65ac3260f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7096f0f-8db9-5a47-ba77-b08e7d6067ca', 'fe3b7cc8-b8c3-5d17-8284-a4e65ac3260f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0391407-de7f-598c-b8d2-fad0ea76f62a', 'fe3b7cc8-b8c3-5d17-8284-a4e65ac3260f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1311e4db-2c3e-5bd4-83ef-a40042cb1ac1', '5ab7da2e-c94c-56fc-a568-2c385200d095', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Early Maori healers learned their skills through studying written texts.
2
The first Europeans in New Zealand were surprised by how long the Maori lived.
3
Diseases of the gods were believed to be more serious than physical diseases.
4
The leaves of the pepper tree were used to treat toothache.
5
Western religion was one reason why traditional Maori medicine became less popular.
6
Modern day Maori healers often reach the same conclusion about the type of treatment which is best.

2 ____ The first Europeans in New Zealand were surprised by how long the Maori lived.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a903e4cf-714a-5979-b2fa-6035f9a9180e', '1311e4db-2c3e-5bd4-83ef-a40042cb1ac1', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('500c8b96-edf7-508a-865d-3fe5828058f1', '1311e4db-2c3e-5bd4-83ef-a40042cb1ac1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec3dbb0a-9a6f-576b-8e0c-c549c5e15c07', '1311e4db-2c3e-5bd4-83ef-a40042cb1ac1', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ff04be4e-2906-5280-9553-f649ec446a1b', '5ab7da2e-c94c-56fc-a568-2c385200d095', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Early Maori healers learned their skills through studying written texts.
2
The first Europeans in New Zealand were surprised by how long the Maori lived.
3
Diseases of the gods were believed to be more serious than physical diseases.
4
The leaves of the pepper tree were used to treat toothache.
5
Western religion was one reason why traditional Maori medicine became less popular.
6
Modern day Maori healers often reach the same conclusion about the type of treatment which is best.

3 ____ Diseases of the gods were believed to be more serious than physical diseases.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e8e7398-f1c4-5272-85ee-55f773b5b166', 'ff04be4e-2906-5280-9553-f649ec446a1b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('382a7065-b512-58b8-81d8-76fb20b7a2ee', 'ff04be4e-2906-5280-9553-f649ec446a1b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2a5ae26-8f27-5ffe-a6e1-542ab4df5858', 'ff04be4e-2906-5280-9553-f649ec446a1b', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5abf09a6-fec9-55b8-85f1-8c17b89a3e60', '5ab7da2e-c94c-56fc-a568-2c385200d095', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Early Maori healers learned their skills through studying written texts.
2
The first Europeans in New Zealand were surprised by how long the Maori lived.
3
Diseases of the gods were believed to be more serious than physical diseases.
4
The leaves of the pepper tree were used to treat toothache.
5
Western religion was one reason why traditional Maori medicine became less popular.
6
Modern day Maori healers often reach the same conclusion about the type of treatment which is best.

4 ____ The leaves of the pepper tree were used to treat toothache.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aec81ffc-d861-5d30-977c-b9cba06ae82b', '5abf09a6-fec9-55b8-85f1-8c17b89a3e60', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e34b359f-95d6-5cdd-8264-9efc0ee320e1', '5abf09a6-fec9-55b8-85f1-8c17b89a3e60', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa622ec0-9b19-574b-b92f-9718e99574f5', '5abf09a6-fec9-55b8-85f1-8c17b89a3e60', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a992ff76-b1a5-5d88-b9d5-2ef802199f2f', '5ab7da2e-c94c-56fc-a568-2c385200d095', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Early Maori healers learned their skills through studying written texts.
2
The first Europeans in New Zealand were surprised by how long the Maori lived.
3
Diseases of the gods were believed to be more serious than physical diseases.
4
The leaves of the pepper tree were used to treat toothache.
5
Western religion was one reason why traditional Maori medicine became less popular.
6
Modern day Maori healers often reach the same conclusion about the type of treatment which is best.

5 ____ Western religion was one reason why traditional Maori medicine became less popular.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6e9ea1c-5433-55fb-8c66-a3f8d2f11a7f', 'a992ff76-b1a5-5d88-b9d5-2ef802199f2f', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e03b5926-42fe-5477-88b2-67caae6ef61b', 'a992ff76-b1a5-5d88-b9d5-2ef802199f2f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fb9d65b-4653-5ab6-a39a-aa641788447f', 'a992ff76-b1a5-5d88-b9d5-2ef802199f2f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d1a34070-af98-551a-942e-048e07f00d41', '5ab7da2e-c94c-56fc-a568-2c385200d095', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Early Maori healers learned their skills through studying written texts.
2
The first Europeans in New Zealand were surprised by how long the Maori lived.
3
Diseases of the gods were believed to be more serious than physical diseases.
4
The leaves of the pepper tree were used to treat toothache.
5
Western religion was one reason why traditional Maori medicine became less popular.
6
Modern day Maori healers often reach the same conclusion about the type of treatment which is best.

6 ____ Modern day Maori healers often reach the same conclusion about the type of treatment which is best.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0316c2f7-76f4-5a7a-941f-6457a2fca3f4', 'd1a34070-af98-551a-942e-048e07f00d41', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7aa7086a-02ba-5413-9154-847617bd45eb', 'd1a34070-af98-551a-942e-048e07f00d41', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a6ccf7c-b163-5032-809d-162e09abbe44', 'd1a34070-af98-551a-942e-048e07f00d41', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cdf86d02-4082-54e7-ba38-06058a1825a9', '5ab7da2e-c94c-56fc-a568-2c385200d095', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
A short history of Maori healing
Pre-European arrival
Maori were using plant based remedies, as well as treatment including massage
Diseases sent from the gods were thought to be caused by disobeying a spiritual
7
Sickness could be attributed to eating food from a sacred
8
or burning sacred wood
After European arrival
1800s
The inability of Maori healers to cure new diseases meant the Maori people lost
9
in them.
Eventually the
10
for Maori healing began shutting down
1970s
Published
11
showed that Maori were not as healthy as Europeans
2000s
Maori healers can be seen working with Western doctors in
12
in
cities
Many patients appreciate the fact that the Maoris
13
in used by
healers

Diseases sent from the gods were thought to be caused by disobeying a spiritual 7 ____$md$, NULL, ARRAY['.*rule.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d176cd0d-7abf-5482-8e3e-6be6e0834932', '5ab7da2e-c94c-56fc-a568-2c385200d095', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
A short history of Maori healing
Pre-European arrival
Maori were using plant based remedies, as well as treatment including massage
Diseases sent from the gods were thought to be caused by disobeying a spiritual
7
Sickness could be attributed to eating food from a sacred
8
or burning sacred wood
After European arrival
1800s
The inability of Maori healers to cure new diseases meant the Maori people lost
9
in them.
Eventually the
10
for Maori healing began shutting down
1970s
Published
11
showed that Maori were not as healthy as Europeans
2000s
Maori healers can be seen working with Western doctors in
12
in
cities
Many patients appreciate the fact that the Maoris
13
in used by
healers

Sickness could be attributed to eating food from a sacred 8 ____ or burning sacred wood$md$, NULL, ARRAY['.*river.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c9a901a2-1167-5bac-88d9-1b47e0e53983', '5ab7da2e-c94c-56fc-a568-2c385200d095', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
A short history of Maori healing
Pre-European arrival
Maori were using plant based remedies, as well as treatment including massage
Diseases sent from the gods were thought to be caused by disobeying a spiritual
7
Sickness could be attributed to eating food from a sacred
8
or burning sacred wood
After European arrival
1800s
The inability of Maori healers to cure new diseases meant the Maori people lost
9
in them.
Eventually the
10
for Maori healing began shutting down
1970s
Published
11
showed that Maori were not as healthy as Europeans
2000s
Maori healers can be seen working with Western doctors in
12
in
cities
Many patients appreciate the fact that the Maoris
13
in used by
healers

The inability of Maori healers to cure new diseases meant the Maori people lost 9 ____ in them.$md$, NULL, ARRAY['.*confidence.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('050aedfc-956e-57d3-aaec-83fe3a65d5c5', '5ab7da2e-c94c-56fc-a568-2c385200d095', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
A short history of Maori healing
Pre-European arrival
Maori were using plant based remedies, as well as treatment including massage
Diseases sent from the gods were thought to be caused by disobeying a spiritual
7
Sickness could be attributed to eating food from a sacred
8
or burning sacred wood
After European arrival
1800s
The inability of Maori healers to cure new diseases meant the Maori people lost
9
in them.
Eventually the
10
for Maori healing began shutting down
1970s
Published
11
showed that Maori were not as healthy as Europeans
2000s
Maori healers can be seen working with Western doctors in
12
in
cities
Many patients appreciate the fact that the Maoris
13
in used by
healers

Eventually the 10 ____ for Maori healing began shutting down$md$, NULL, ARRAY['.*schools.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('aba7cb87-2401-5b5f-bc11-37c007079c2d', '5ab7da2e-c94c-56fc-a568-2c385200d095', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
A short history of Maori healing
Pre-European arrival
Maori were using plant based remedies, as well as treatment including massage
Diseases sent from the gods were thought to be caused by disobeying a spiritual
7
Sickness could be attributed to eating food from a sacred
8
or burning sacred wood
After European arrival
1800s
The inability of Maori healers to cure new diseases meant the Maori people lost
9
in them.
Eventually the
10
for Maori healing began shutting down
1970s
Published
11
showed that Maori were not as healthy as Europeans
2000s
Maori healers can be seen working with Western doctors in
12
in
cities
Many patients appreciate the fact that the Maoris
13
in used by
healers

Published 11 ____ showed that Maori were not as healthy as Europeans$md$, NULL, ARRAY['.*statistics.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b4385dee-246c-5c67-8d03-a8932567936c', '5ab7da2e-c94c-56fc-a568-2c385200d095', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
A short history of Maori healing
Pre-European arrival
Maori were using plant based remedies, as well as treatment including massage
Diseases sent from the gods were thought to be caused by disobeying a spiritual
7
Sickness could be attributed to eating food from a sacred
8
or burning sacred wood
After European arrival
1800s
The inability of Maori healers to cure new diseases meant the Maori people lost
9
in them.
Eventually the
10
for Maori healing began shutting down
1970s
Published
11
showed that Maori were not as healthy as Europeans
2000s
Maori healers can be seen working with Western doctors in
12
in
cities
Many patients appreciate the fact that the Maoris
13
in used by
healers

Maori healers can be seen working with Western doctors in 12 ____ in$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2de42bc2-733f-5771-ba8f-8540eec277dd', '5ab7da2e-c94c-56fc-a568-2c385200d095', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
A short history of Maori healing
Pre-European arrival
Maori were using plant based remedies, as well as treatment including massage
Diseases sent from the gods were thought to be caused by disobeying a spiritual
7
Sickness could be attributed to eating food from a sacred
8
or burning sacred wood
After European arrival
1800s
The inability of Maori healers to cure new diseases meant the Maori people lost
9
in them.
Eventually the
10
for Maori healing began shutting down
1970s
Published
11
showed that Maori were not as healthy as Europeans
2000s
Maori healers can be seen working with Western doctors in
12
in
cities
Many patients appreciate the fact that the Maoris
13
in used by
healers

Many patients appreciate the fact that the Maoris 13 ____ in used by$md$, NULL);

COMMIT;
