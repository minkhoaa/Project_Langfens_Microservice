BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-alfred-nobel-the-man-behind-the-nobel-prize-1389'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-alfred-nobel-the-man-behind-the-nobel-prize-1389';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-alfred-nobel-the-man-behind-the-nobel-prize-1389';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-alfred-nobel-the-man-behind-the-nobel-prize-1389';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('de98b179-ecb8-5b12-94e9-cecd5d682f70', 'ielts-reading-alfred-nobel-the-man-behind-the-nobel-prize-1389', $t$Alfred Nobel: The man behind the Nobel Prize$t$, $md$## Alfred Nobel: The man behind the Nobel Prize

Nguồn:
- Test: https://mini-ielts.com/1389/reading/alfred-nobel-the-man-behind-the-nobel-prize
- Solution: https://mini-ielts.com/1389/view-solution/reading/alfred-nobel-the-man-behind-the-nobel-prize$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('cf1947e1-d03d-55ac-8dd2-dca2adb20617', 'de98b179-ecb8-5b12-94e9-cecd5d682f70', 1, $t$Reading — Alfred Nobel: The man behind the Nobel Prize$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Alfred Nobel: The man behind the Nobel Prize

A

Since 1901, the Nobel Prize has been honoring men and women from all corners of the globe for outstanding achievements in physics, chemistry, medicine, literature, and for work in peace. The foundations for the prize were laid in 1895 when Alfred Nobel wrote his last will, leaving much of his wealth to the establishment of the Nobel Prize.

B

Alfred Nobel was born in Stockholm on October 21, 1833. His father Immanuel Nobel was an engineer and inventor who built bridges and buildings in Stockholm. In connection with his construction work, Immanuel Nobel also experimented with different techniques for blasting rocks. Successful in his industrial and business ventures, Immanuel Nobel was able, in 1842, to bring his family to St. Petersburg. There, his sons were given a first-class education by private teachers. The training included natural sciences, languages and literature. By the age of 17, Alfred Nobel was fluent in Swedish, Russian, French, English and German. His primary interests were in English literature and poetry as well as in chemistry and physics. Alfred’s father, who wanted his sons to join his enterprise as engineers, disliked Alfred’s interest in poetry and found his son rather introverted.

C

In order to widen Alfred’s horizons, his father sent him abroad for further training in chemical engineering. During a two year period, Alfred Nobel visited Sweden, Germany, France and the United States. In Paris, the city he came to like best, he worked in the private laboratory of Professor T. J. Pclouze, a famous chemist. There he met the young Italian chemist Ascanio Sobrero who, three years earlier, had invented nitroglycerine, a highly explosive liquid. But it was considered too dangerous to be of any practical use. Although its explosive power greatly exceeded that of gunpowder, the liquid would explode in a very unpredictable manner if subjected to heat and pressure. Alfred Nobel became very interested in nitroglycerine and how it could be put to practical use in construction work. He also realized that the safety problems had to be solved and a method had to be developed for the controlled detonation of nitroglycerine.

D

After his return to Sweden in 1863, Alfred Nobel concentrated on developing nitroglycerine as an explosive. Several explosions, including one (1864) in which his brother Emil and several other persons were killed, convinced the authorities that nitroglycerine production was exceedingly dangerous. They forbade further experimentation with nitroglycerine within the Stockholm city limits and Alfred Nobel had to move his experimentation to a barge anchored on Lake Malaren. Alfred was not discouraged and in 1864 he was able to start mass production of nitroglycerine. To make the handling of nitroglycerine safer Alfred Nobel experimented with different additives. He soon found that mixing nitroglycerine with kieselguhr would turn the liquid into a paste which could be shaped into rods of a size and form suitable for insertion into drilling holes. In 1867 he patented this material under the name of dynamite. To be able to detonate the dynamite rods he also invented a detonator (blasting cap) which could be ignited by lighting a fuse. These inventions were made at the same time as the pneumatic drill came into general use. Together these inventions drastically reduced the cost of blasting rock, drilling tunnels, building canals and many other forms of construction work.

E

The market for dynamite and detonating caps grew very rapidly and Alfred Nobel also proved himself to be a very skillful entrepreneur and businessman. Over the years he founded factories and laboratories in some 90 different places in more than 20 countries. Although he lived in Paris much of his life he was constantly traveling. When he was not traveling or engaging in business activities Nobel himself worked intensively in his various laboratories, first in Stockholm and later in other places. He focused on the development of explosives technology as well as other chemical inventions including such materials as synthetic rubber and leather, artificial silk, etc. By the time of his death in 18%, he had 355 patents.

F

Intensive work and travel did not leave much time for private life. At the age of 43, he was feeling like an old man. At this time he advertised in a newspaper “Wealthy, highly-educated elderly gentleman seeks the lady of mature age, versed in languages, as secretary and supervisor of household.” The most qualified applicant turned out to be an Austrian woman, Countess Bertha Kinsky. After working a very short time for Nobel she decided to return to Austria to marry Count Arthur von Suttner. In spite of this Alfred Nobel and Bertha von Suttner remained friends and kept writing letters to each other for decades. Over the years Bertha von Suttner became increasingly critical of the arms race. She wrote a famous book, Lay Down Your Arms and became a prominent figure in the peace movement. No doubt this influenced Alfred Nobel when he wrote his final will which was to include a Prize for persons or organizations who promoted peace. Several years after the death of Alfred Nobel, the Norwegian Storting (Parliament) decided to award the 1905 Nobel Peace Prize to Bertha von Suttner.

G

Alfred Nobel died in San Remo, Italy, on December 10, 1896. When his will was opened it came as a surprise that his fortune was to be used for Prizes in Physics, Chemistry, Physiology or Medicine, Literature and Peace. The executors of his will were two young engineers, Ragnar Sohlman and Rudolf Lilljequist. They set about forming the Nobel Foundation as an organization to take care of the financial assets left by Nobel for this purpose and to coordinate the work of the Prize-Awarding Institutions. This was not without its difficulties since the will was contested by relatives and questioned by authorities in various countries.

H

Alfred Nobel’s greatness lay in his ability to combine the penetrating mind of the scientist and inventor with the forward-looking dynamism of the industrialist. Nobel was very interested in social and peace-related issues and held what were considered radical views in his era. He had a great interest in literature and wrote his own poetry and dramatic works. The Nobel Prizes became an extension and a fulfillment of his lifetime interests.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fd635ee1-e2af-5b90-a0eb-71d3c2532cf4', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The first Nobel Prize was awarded in 1895.
2
Nobel’s father wanted his son to have a better education than what he had had.
3
Nobel was an unsuccessful businessman.
4
Bertha von Suttner
was selected by Nobel himself for the first peace prize.
5
The Nobel Foundation was established after the death of Nobel
6
Nobel’s social involvement was uncommon in the 1800s.

1 ____ The first Nobel Prize was awarded in 1895.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33814dd8-5a01-505b-ad87-28b79d7717c7', 'fd635ee1-e2af-5b90-a0eb-71d3c2532cf4', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e011acc8-e9f8-553f-b919-fd8ff539bf3b', 'fd635ee1-e2af-5b90-a0eb-71d3c2532cf4', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be9d12f6-b2e3-5955-8371-1071152c885c', 'fd635ee1-e2af-5b90-a0eb-71d3c2532cf4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e802710d-d517-557d-8566-cc1e408a2c87', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The first Nobel Prize was awarded in 1895.
2
Nobel’s father wanted his son to have a better education than what he had had.
3
Nobel was an unsuccessful businessman.
4
Bertha von Suttner
was selected by Nobel himself for the first peace prize.
5
The Nobel Foundation was established after the death of Nobel
6
Nobel’s social involvement was uncommon in the 1800s.

2 ____ Nobel’s father wanted his son to have a better education than what he had had.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78ea6e8d-2e35-5bf7-8ca5-2e78f6a85e92', 'e802710d-d517-557d-8566-cc1e408a2c87', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e82851de-ae4f-5681-955b-6989bfa6f4b6', 'e802710d-d517-557d-8566-cc1e408a2c87', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5802914-c7fb-526a-8dc0-ad9a16233afd', 'e802710d-d517-557d-8566-cc1e408a2c87', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('52dde294-9a5d-5d77-a53c-a2be18db6b6e', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The first Nobel Prize was awarded in 1895.
2
Nobel’s father wanted his son to have a better education than what he had had.
3
Nobel was an unsuccessful businessman.
4
Bertha von Suttner
was selected by Nobel himself for the first peace prize.
5
The Nobel Foundation was established after the death of Nobel
6
Nobel’s social involvement was uncommon in the 1800s.

3 ____ Nobel was an unsuccessful businessman.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('757904b9-1a36-54e0-accc-b0d6602c2ff6', '52dde294-9a5d-5d77-a53c-a2be18db6b6e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04d5e3eb-f30c-58af-9cea-7d1ecc0d721d', '52dde294-9a5d-5d77-a53c-a2be18db6b6e', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1876d9e8-22cf-5948-90ec-645a336312c2', '52dde294-9a5d-5d77-a53c-a2be18db6b6e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6aa203e5-d82b-5d2d-b9b0-c50abec15d21', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The first Nobel Prize was awarded in 1895.
2
Nobel’s father wanted his son to have a better education than what he had had.
3
Nobel was an unsuccessful businessman.
4
Bertha von Suttner
was selected by Nobel himself for the first peace prize.
5
The Nobel Foundation was established after the death of Nobel
6
Nobel’s social involvement was uncommon in the 1800s.

4 ____ Bertha von Suttner was selected by Nobel himself for the first peace prize.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d92d251-29ca-5474-a517-22eee97311cb', '6aa203e5-d82b-5d2d-b9b0-c50abec15d21', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5cadc12d-fc53-58ab-875e-7cd3f8d77695', '6aa203e5-d82b-5d2d-b9b0-c50abec15d21', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adae5a62-b261-53ea-a6c4-00a2a6656a2c', '6aa203e5-d82b-5d2d-b9b0-c50abec15d21', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('da04121c-6302-54be-a9dc-f06770e27721', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The first Nobel Prize was awarded in 1895.
2
Nobel’s father wanted his son to have a better education than what he had had.
3
Nobel was an unsuccessful businessman.
4
Bertha von Suttner
was selected by Nobel himself for the first peace prize.
5
The Nobel Foundation was established after the death of Nobel
6
Nobel’s social involvement was uncommon in the 1800s.

5 ____ The Nobel Foundation was established after the death of Nobel$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a767946d-3d7e-53c6-ac47-6323a55baf6b', 'da04121c-6302-54be-a9dc-f06770e27721', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89ec9a40-b6e7-5e96-b3dc-0276a8c3d781', 'da04121c-6302-54be-a9dc-f06770e27721', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d14fab6-cb43-5964-9956-1ebc80ead41f', 'da04121c-6302-54be-a9dc-f06770e27721', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('789159eb-586a-5be8-9142-c51afc1e1d0b', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The first Nobel Prize was awarded in 1895.
2
Nobel’s father wanted his son to have a better education than what he had had.
3
Nobel was an unsuccessful businessman.
4
Bertha von Suttner
was selected by Nobel himself for the first peace prize.
5
The Nobel Foundation was established after the death of Nobel
6
Nobel’s social involvement was uncommon in the 1800s.

6 ____ Nobel’s social involvement was uncommon in the 1800s.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d50e8869-4ef0-577c-b49b-4e21f07072eb', '789159eb-586a-5be8-9142-c51afc1e1d0b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('131121b9-d2f7-5ecc-ab60-f5ee6e928482', '789159eb-586a-5be8-9142-c51afc1e1d0b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fdfd2a3-2007-5f4d-ab3c-02bfcb88e8b8', '789159eb-586a-5be8-9142-c51afc1e1d0b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('85797420-7260-57a8-9059-ebcf06c61f87', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Complete the notes below using
NO MORE THAN TWO WORDS
from the passage.
Write your answers in boxes
7-13
on your answer sheet.
Education:
Having accumulated a great fortune in his business, Nobel’s father determined to give his son the best education and sent him abroad to be trained in
7
during Nobel’s study in Paris, he worked in a private laboratory, where he came in contact with a young engineer
8
and his invention nitroglycerine, a more powerful explosive than
9
.
Benefits in construction works:
Nobel became really interested in this new explosive and experimented on it. But nitroglycerine was too dangerous and was banned for experiments within the city of
10
. So Nobel had to move his experiments to a lake. To make nitroglycerine easily usable, Nobel invented dynamite along with
11
. while in the meantime
12
became popular, all of which dramatically lowered the
13
of construction works.

Having accumulated a great fortune in his business, Nobel’s father determined to give his son the best education and sent him abroad to be trained in 7 ____ during Nobel’s study in Paris, he worked in a private laboratory, where he came in contact with a young engineer 8 ____ and his invention nitroglycerine, a more powerful explosive than 9 ____ .$md$, NULL, ARRAY['.*chemical.*engineering.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('47c58fff-4460-5477-a53b-ebf963d17439', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Complete the notes below using
NO MORE THAN TWO WORDS
from the passage.
Write your answers in boxes
7-13
on your answer sheet.
Education:
Having accumulated a great fortune in his business, Nobel’s father determined to give his son the best education and sent him abroad to be trained in
7
during Nobel’s study in Paris, he worked in a private laboratory, where he came in contact with a young engineer
8
and his invention nitroglycerine, a more powerful explosive than
9
.
Benefits in construction works:
Nobel became really interested in this new explosive and experimented on it. But nitroglycerine was too dangerous and was banned for experiments within the city of
10
. So Nobel had to move his experiments to a lake. To make nitroglycerine easily usable, Nobel invented dynamite along with
11
. while in the meantime
12
became popular, all of which dramatically lowered the
13
of construction works.

Having accumulated a great fortune in his business, Nobel’s father determined to give his son the best education and sent him abroad to be trained in 7 ____ during Nobel’s study in Paris, he worked in a private laboratory, where he came in contact with a young engineer 8 ____ and his invention nitroglycerine, a more powerful explosive than 9 ____ .$md$, NULL, ARRAY['.*chemical.*engineering.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('860f0bf3-98b0-51c5-8445-14e0940a0544', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Complete the notes below using
NO MORE THAN TWO WORDS
from the passage.
Write your answers in boxes
7-13
on your answer sheet.
Education:
Having accumulated a great fortune in his business, Nobel’s father determined to give his son the best education and sent him abroad to be trained in
7
during Nobel’s study in Paris, he worked in a private laboratory, where he came in contact with a young engineer
8
and his invention nitroglycerine, a more powerful explosive than
9
.
Benefits in construction works:
Nobel became really interested in this new explosive and experimented on it. But nitroglycerine was too dangerous and was banned for experiments within the city of
10
. So Nobel had to move his experiments to a lake. To make nitroglycerine easily usable, Nobel invented dynamite along with
11
. while in the meantime
12
became popular, all of which dramatically lowered the
13
of construction works.

Having accumulated a great fortune in his business, Nobel’s father determined to give his son the best education and sent him abroad to be trained in 7 ____ during Nobel’s study in Paris, he worked in a private laboratory, where he came in contact with a young engineer 8 ____ and his invention nitroglycerine, a more powerful explosive than 9 ____ .$md$, NULL, ARRAY['.*chemical.*engineering.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5af46989-4e39-5847-bbd2-c00b2d512379', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Complete the notes below using
NO MORE THAN TWO WORDS
from the passage.
Write your answers in boxes
7-13
on your answer sheet.
Education:
Having accumulated a great fortune in his business, Nobel’s father determined to give his son the best education and sent him abroad to be trained in
7
during Nobel’s study in Paris, he worked in a private laboratory, where he came in contact with a young engineer
8
and his invention nitroglycerine, a more powerful explosive than
9
.
Benefits in construction works:
Nobel became really interested in this new explosive and experimented on it. But nitroglycerine was too dangerous and was banned for experiments within the city of
10
. So Nobel had to move his experiments to a lake. To make nitroglycerine easily usable, Nobel invented dynamite along with
11
. while in the meantime
12
became popular, all of which dramatically lowered the
13
of construction works.

Nobel became really interested in this new explosive and experimented on it. But nitroglycerine was too dangerous and was banned for experiments within the city of 10 ____ . So Nobel had to move his experiments to a lake. To make nitroglycerine easily usable, Nobel invented dynamite along with 11 ____ . while in the meantime 12 ____ became popular, all of which dramatically lowered the 13 ____ of construction works.$md$, NULL, ARRAY['.*stockholm.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('42ef4085-8926-521b-908c-27a033931cef', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Complete the notes below using
NO MORE THAN TWO WORDS
from the passage.
Write your answers in boxes
7-13
on your answer sheet.
Education:
Having accumulated a great fortune in his business, Nobel’s father determined to give his son the best education and sent him abroad to be trained in
7
during Nobel’s study in Paris, he worked in a private laboratory, where he came in contact with a young engineer
8
and his invention nitroglycerine, a more powerful explosive than
9
.
Benefits in construction works:
Nobel became really interested in this new explosive and experimented on it. But nitroglycerine was too dangerous and was banned for experiments within the city of
10
. So Nobel had to move his experiments to a lake. To make nitroglycerine easily usable, Nobel invented dynamite along with
11
. while in the meantime
12
became popular, all of which dramatically lowered the
13
of construction works.

Nobel became really interested in this new explosive and experimented on it. But nitroglycerine was too dangerous and was banned for experiments within the city of 10 ____ . So Nobel had to move his experiments to a lake. To make nitroglycerine easily usable, Nobel invented dynamite along with 11 ____ . while in the meantime 12 ____ became popular, all of which dramatically lowered the 13 ____ of construction works.$md$, NULL, ARRAY['.*stockholm.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('16b7ab34-ffec-5ed9-a229-8cba6fb54200', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Complete the notes below using
NO MORE THAN TWO WORDS
from the passage.
Write your answers in boxes
7-13
on your answer sheet.
Education:
Having accumulated a great fortune in his business, Nobel’s father determined to give his son the best education and sent him abroad to be trained in
7
during Nobel’s study in Paris, he worked in a private laboratory, where he came in contact with a young engineer
8
and his invention nitroglycerine, a more powerful explosive than
9
.
Benefits in construction works:
Nobel became really interested in this new explosive and experimented on it. But nitroglycerine was too dangerous and was banned for experiments within the city of
10
. So Nobel had to move his experiments to a lake. To make nitroglycerine easily usable, Nobel invented dynamite along with
11
. while in the meantime
12
became popular, all of which dramatically lowered the
13
of construction works.

Nobel became really interested in this new explosive and experimented on it. But nitroglycerine was too dangerous and was banned for experiments within the city of 10 ____ . So Nobel had to move his experiments to a lake. To make nitroglycerine easily usable, Nobel invented dynamite along with 11 ____ . while in the meantime 12 ____ became popular, all of which dramatically lowered the 13 ____ of construction works.$md$, NULL, ARRAY['.*stockholm.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2ebf040b-67e8-5f46-b962-bfc6110dfcf9', 'cf1947e1-d03d-55ac-8dd2-dca2adb20617', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Complete the notes below using
NO MORE THAN TWO WORDS
from the passage.
Write your answers in boxes
7-13
on your answer sheet.
Education:
Having accumulated a great fortune in his business, Nobel’s father determined to give his son the best education and sent him abroad to be trained in
7
during Nobel’s study in Paris, he worked in a private laboratory, where he came in contact with a young engineer
8
and his invention nitroglycerine, a more powerful explosive than
9
.
Benefits in construction works:
Nobel became really interested in this new explosive and experimented on it. But nitroglycerine was too dangerous and was banned for experiments within the city of
10
. So Nobel had to move his experiments to a lake. To make nitroglycerine easily usable, Nobel invented dynamite along with
11
. while in the meantime
12
became popular, all of which dramatically lowered the
13
of construction works.

Nobel became really interested in this new explosive and experimented on it. But nitroglycerine was too dangerous and was banned for experiments within the city of 10 ____ . So Nobel had to move his experiments to a lake. To make nitroglycerine easily usable, Nobel invented dynamite along with 11 ____ . while in the meantime 12 ____ became popular, all of which dramatically lowered the 13 ____ of construction works.$md$, NULL, ARRAY['.*stockholm.*']);

COMMIT;
