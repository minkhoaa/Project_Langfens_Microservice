BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-making-copier-1249'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-making-copier-1249';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-making-copier-1249';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-making-copier-1249';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('92ad7a79-58cf-5756-a927-100c1a4f7869', 'ielts-reading-making-copier-1249', $t$Making Copier$t$, $md$## Making Copier

Nguồn:
- Test: https://mini-ielts.com/1249/reading/making-copier
- Solution: https://mini-ielts.com/1249/view-solution/reading/making-copier$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('0b364164-15d6-560a-9448-1e20e1f276ad', '92ad7a79-58cf-5756-a927-100c1a4f7869', 1, $t$Reading — Making Copier$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Making Copier

At first, nobody bought Chester Carlson’s strange idea. But trillions of documents later, his invention is the biggest thing in printing since Gutenberg

A

Copying is the engine of civilization: culture is behavior duplicated. The oldest copier invented by people is language, by which an idea of yours becomes an idea of mine. The second great copying machine was writing. When the Sumerians transposed spoken words into stylus marks on clay tablets more than 5,000 years ago, the hugely extended the human network that language had created. Writing freed copying from the chain of living contact. It made ideas permanent, portable and endlessly reproducible.

B

Until Johann Gutenberg invented the printing press in the mid-1400s, producing a book in an edition of more than one generally meant writing it out again. Printing with moveable type was not copying, however. Gutenberg couldn’t take a document that already existed, feed it into his printing press and run off facsimiles. The first true mechanical copier was manufactured in 1780, when James Watt, who is better known as the inventor of the modern steam engine, created the copying press. Few people today know what a copying press was, but you may have seen one in an antique store, where it was perhaps called a book press. A user took a document freshly written in special ink, placed a moistened sheet of translucent paper against the inked surface and squeezed the two sheets together in the press, causing some of the ink from the original to penetrate the second sheet, which could then be read by turning it over and looking through its back. The high cost prohibits the widespread use of this copier.

C

Among the first modem copying machines, introduced in 1950 by 3M, was the Thermo-Fax, and it made a copy by shining infrared light through an original document and a sheet of paper that had been coated with heat-sensitive chemicals. Competing manufacturers soon introduced other copying technologies and marketed machines called Dupliton, Dial-A-Matic Autostat, Verifax, Copease and Copymation. These machines and their successors were welcomed by secretaries, who had no other means of reproducing documents in hand, but each had serious drawbacks. All required expensive chemically treated papers. And all made copies that smelled bad, were hard to read, didn’t last long and tended to curl up into tubes. The machines were displaced, beginning in the late 1800s, by a combination of two 19th century inventions: the typewriter and carbon paper. For those reasons, copying presses were standard equipment in offices for nearly a century and a half.

D

None of those machines is still manufactured today. They were all made obsolete by a radically different machine, which had been developed by an obscure photographic-supply company. That company had been founded in 1906 as the Haloid Company and is known today as the Xerox Corporation. In 1959, it introduced an office copier called the Haloid Xerox 914, a machine that, unlike its numerous competitors, made sharp, permanent copies on ordinary paper-a huge breakthrough. The process, which Haloid called xerography (based on Greek words meaning “dry” and “writing”), was so unusual and nonnutritive that physicists who visited the drafty warehouses where the first machines were built sometimes expressed doubt that it was even theoretically feasible.

E

Remarkably, xerography was conceived by one person- Chester Carlson, a shy, soft-spoken patent attorney, who grew up in almost unspeakable poverty and worked his way through junior college and the California Institute of Technology. Chester Carlson was born in Seattle in 1906. His parents-Olof Adolph Carlson and Ellen Josephine Hawkins—had grown up on neighboring farms in Grove City, Minnesota, a tiny Swedish farming community about 75 miles west of Minneapolis. Compare with competitors, Carlson was not a normal inventor in 20-century. He made his discovery in solitude in 1937 and offered it to more than 20 major corporations, among them IBM, General Electric, Eastman Kodak and RCA. All of them turned him down, expressing what he later called “an enthusiastic lack of interest” and thereby passing up the opportunity to manufacture what Fortune magazine would describe as “the most successful product ever marketed in America.”

F

Carlson’s invention was indeed a commercial triumph. Essentially overnight, people began making copies at a rate that was orders of magnitude higher than anyone had believed possible. And the rate is still growing. In fact, most documents handled by a typical American office worker today are produced xerographically, either on copiers manufactured by Xerox and its competitors or on laser printers, which employ the same process (and were invented, in the 1970s, by a Xerox researcher). This year, the world will produce more than three trillion xerographic copies and laser-printed pages—about 500 for every human on earth.

G

Xerography eventually made Carlson a very wealthy man. (His royalties amounted to something like a 16th of a cent for every Xerox copy made, worldwide, through 1965.) Nevertheless, he lived simply. He never owned a second home or a second car, and his wife had to urge him not to buy third-class train tickets when he traveled in Europe. People who knew him casually seldom suspected that he was rich or even well-to-do; when Carlson told an acquaintance he worked at Xerox, the man assumed he was a factory worker and asked if he belonged to a union. “His possessions seemed to be composed of the number of things he could easily do without,” his second wife said. He spent the last years of his life quietly giving most of his fortune to charities. When he died in 1968, among the eulogizers was the secretary-general of the United Nations.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a6b9e201-ad7b-5570-9fac-d3dee999ac3d', '0b364164-15d6-560a-9448-1e20e1f276ad', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
1
The earliest languages were recorded on papyrus.
2
when applying Johann Gutenberg’s printing machine, it requires lots of training.
3
James Watt invented a modem steam engine before he made his first mechanical copier.
4
using the Dupliton copiers and follower versions are very costly.
5
The typewriters with carbon papers were taken place of very soon because they were not sold well
6
The Haloid Xerox 914 model also required specially treated paper for making copies.

1 ____ The earliest languages were recorded on papyrus.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0dfcd1a9-e8bf-5c3c-846e-af8b52f179e4', 'a6b9e201-ad7b-5570-9fac-d3dee999ac3d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('998f11bf-4416-5066-b5c3-120c4fd26bc7', 'a6b9e201-ad7b-5570-9fac-d3dee999ac3d', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37a6aca0-b5e9-5fd0-bacb-4013687b7fd3', 'a6b9e201-ad7b-5570-9fac-d3dee999ac3d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c526d60-e74f-5512-a8c5-66159a0c153d', '0b364164-15d6-560a-9448-1e20e1f276ad', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
1
The earliest languages were recorded on papyrus.
2
when applying Johann Gutenberg’s printing machine, it requires lots of training.
3
James Watt invented a modem steam engine before he made his first mechanical copier.
4
using the Dupliton copiers and follower versions are very costly.
5
The typewriters with carbon papers were taken place of very soon because they were not sold well
6
The Haloid Xerox 914 model also required specially treated paper for making copies.

2 ____ when applying Johann Gutenberg’s printing machine, it requires lots of training.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d0f8194-fc90-563d-aeea-cc8be05594b5', '1c526d60-e74f-5512-a8c5-66159a0c153d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd71d7bf-07a9-51ee-a128-8cadcf7445b0', '1c526d60-e74f-5512-a8c5-66159a0c153d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d4f0343-6b2f-52fe-80f3-289900b19cb0', '1c526d60-e74f-5512-a8c5-66159a0c153d', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e18b6ad9-3896-588d-a32f-690813853f01', '0b364164-15d6-560a-9448-1e20e1f276ad', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
1
The earliest languages were recorded on papyrus.
2
when applying Johann Gutenberg’s printing machine, it requires lots of training.
3
James Watt invented a modem steam engine before he made his first mechanical copier.
4
using the Dupliton copiers and follower versions are very costly.
5
The typewriters with carbon papers were taken place of very soon because they were not sold well
6
The Haloid Xerox 914 model also required specially treated paper for making copies.

3 ____ James Watt invented a modem steam engine before he made his first mechanical copier.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3e4fdf7-96b9-55c9-ad54-f4e804dd034a', 'e18b6ad9-3896-588d-a32f-690813853f01', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbc92508-2dcd-58ed-bc18-d674aaa4daae', 'e18b6ad9-3896-588d-a32f-690813853f01', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a292dbd-006e-5089-9704-3c85e9dbdba0', 'e18b6ad9-3896-588d-a32f-690813853f01', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('377aa447-7fa9-5ffb-a201-43c513c0ec37', '0b364164-15d6-560a-9448-1e20e1f276ad', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
1
The earliest languages were recorded on papyrus.
2
when applying Johann Gutenberg’s printing machine, it requires lots of training.
3
James Watt invented a modem steam engine before he made his first mechanical copier.
4
using the Dupliton copiers and follower versions are very costly.
5
The typewriters with carbon papers were taken place of very soon because they were not sold well
6
The Haloid Xerox 914 model also required specially treated paper for making copies.

4 ____ using the Dupliton copiers and follower versions are very costly.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75a661a7-4f0c-5db7-a0d5-5369a71d79d2', '377aa447-7fa9-5ffb-a201-43c513c0ec37', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b193d690-31b6-5f92-9750-d24db9216bf7', '377aa447-7fa9-5ffb-a201-43c513c0ec37', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2f47196-66b2-506b-ba54-f0911c6a9a56', '377aa447-7fa9-5ffb-a201-43c513c0ec37', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('98685b9a-d6a9-5c2b-9567-348d70ff9acc', '0b364164-15d6-560a-9448-1e20e1f276ad', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
1
The earliest languages were recorded on papyrus.
2
when applying Johann Gutenberg’s printing machine, it requires lots of training.
3
James Watt invented a modem steam engine before he made his first mechanical copier.
4
using the Dupliton copiers and follower versions are very costly.
5
The typewriters with carbon papers were taken place of very soon because they were not sold well
6
The Haloid Xerox 914 model also required specially treated paper for making copies.

5 ____ The typewriters with carbon papers were taken place of very soon because they were not sold well$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79dfb412-4548-5d23-8c82-54a5fcfb6be7', '98685b9a-d6a9-5c2b-9567-348d70ff9acc', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('746de67e-5afe-5f9f-bb23-e22fc271517e', '98685b9a-d6a9-5c2b-9567-348d70ff9acc', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5730a1d-ecb9-552d-b3a0-404518c06078', '98685b9a-d6a9-5c2b-9567-348d70ff9acc', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6f193cb1-23a0-5031-8084-dda299f2cef3', '0b364164-15d6-560a-9448-1e20e1f276ad', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
1
The earliest languages were recorded on papyrus.
2
when applying Johann Gutenberg’s printing machine, it requires lots of training.
3
James Watt invented a modem steam engine before he made his first mechanical copier.
4
using the Dupliton copiers and follower versions are very costly.
5
The typewriters with carbon papers were taken place of very soon because they were not sold well
6
The Haloid Xerox 914 model also required specially treated paper for making copies.

6 ____ The Haloid Xerox 914 model also required specially treated paper for making copies.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be43e45d-8ea8-50fb-852f-891a50932482', '6f193cb1-23a0-5031-8084-dda299f2cef3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e10eac5-8b00-5311-ab96-80106e5b0c89', '6f193cb1-23a0-5031-8084-dda299f2cef3', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6e36179-fed5-54a3-9661-ce460771151b', '6f193cb1-23a0-5031-8084-dda299f2cef3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b1fce6ba-8ebd-555e-b53c-77b0ff93c875', '0b364164-15d6-560a-9448-1e20e1f276ad', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Reading Passage.
Write your answers in boxes
7-13
on your answer sheet.
Calson, unlike a 20-century
7
, like to work on his own. In 1937, he unsuccessfully invited 20 major
8
to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them
9
. Eventually, Calson’s creation was undeniably a
10
. Thanks for the discovery of Xerography, Calson became a very
11
person. Even so, his life remains as simple as before. It looks as if he can live without his
12
At the same time, he gave lots of his money to
13
.

Calson, unlike a 20-century 7 ____ , like to work on his own. In 1937, he unsuccessfully invited 20 major 8 ____ to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them 9 ____ . Eventually, Calson’s creation was undeniably a 10 ____ . Thanks for the discovery of Xerography, Calson became a very 11 ____ person. Even so, his life remains as simple as before. It looks as if he can live without his 12 ____ At the same time, he gave lots of his money to 13 ____ .$md$, NULL, ARRAY['.*inventor.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d52c79b2-d86b-5d6b-8691-f40d60fea11a', '0b364164-15d6-560a-9448-1e20e1f276ad', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Reading Passage.
Write your answers in boxes
7-13
on your answer sheet.
Calson, unlike a 20-century
7
, like to work on his own. In 1937, he unsuccessfully invited 20 major
8
to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them
9
. Eventually, Calson’s creation was undeniably a
10
. Thanks for the discovery of Xerography, Calson became a very
11
person. Even so, his life remains as simple as before. It looks as if he can live without his
12
At the same time, he gave lots of his money to
13
.

Calson, unlike a 20-century 7 ____ , like to work on his own. In 1937, he unsuccessfully invited 20 major 8 ____ to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them 9 ____ . Eventually, Calson’s creation was undeniably a 10 ____ . Thanks for the discovery of Xerography, Calson became a very 11 ____ person. Even so, his life remains as simple as before. It looks as if he can live without his 12 ____ At the same time, he gave lots of his money to 13 ____ .$md$, NULL, ARRAY['.*inventor.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b13ea34a-4039-5451-a03b-17d42d963fa3', '0b364164-15d6-560a-9448-1e20e1f276ad', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Reading Passage.
Write your answers in boxes
7-13
on your answer sheet.
Calson, unlike a 20-century
7
, like to work on his own. In 1937, he unsuccessfully invited 20 major
8
to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them
9
. Eventually, Calson’s creation was undeniably a
10
. Thanks for the discovery of Xerography, Calson became a very
11
person. Even so, his life remains as simple as before. It looks as if he can live without his
12
At the same time, he gave lots of his money to
13
.

Calson, unlike a 20-century 7 ____ , like to work on his own. In 1937, he unsuccessfully invited 20 major 8 ____ to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them 9 ____ . Eventually, Calson’s creation was undeniably a 10 ____ . Thanks for the discovery of Xerography, Calson became a very 11 ____ person. Even so, his life remains as simple as before. It looks as if he can live without his 12 ____ At the same time, he gave lots of his money to 13 ____ .$md$, NULL, ARRAY['.*inventor.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4c2c4665-4de1-5027-82bb-e945bac3671e', '0b364164-15d6-560a-9448-1e20e1f276ad', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Reading Passage.
Write your answers in boxes
7-13
on your answer sheet.
Calson, unlike a 20-century
7
, like to work on his own. In 1937, he unsuccessfully invited 20 major
8
to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them
9
. Eventually, Calson’s creation was undeniably a
10
. Thanks for the discovery of Xerography, Calson became a very
11
person. Even so, his life remains as simple as before. It looks as if he can live without his
12
At the same time, he gave lots of his money to
13
.

Calson, unlike a 20-century 7 ____ , like to work on his own. In 1937, he unsuccessfully invited 20 major 8 ____ to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them 9 ____ . Eventually, Calson’s creation was undeniably a 10 ____ . Thanks for the discovery of Xerography, Calson became a very 11 ____ person. Even so, his life remains as simple as before. It looks as if he can live without his 12 ____ At the same time, he gave lots of his money to 13 ____ .$md$, NULL, ARRAY['.*inventor.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9b389c30-ccad-5eb4-8970-721fac9714b3', '0b364164-15d6-560a-9448-1e20e1f276ad', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Reading Passage.
Write your answers in boxes
7-13
on your answer sheet.
Calson, unlike a 20-century
7
, like to work on his own. In 1937, he unsuccessfully invited 20 major
8
to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them
9
. Eventually, Calson’s creation was undeniably a
10
. Thanks for the discovery of Xerography, Calson became a very
11
person. Even so, his life remains as simple as before. It looks as if he can live without his
12
At the same time, he gave lots of his money to
13
.

Calson, unlike a 20-century 7 ____ , like to work on his own. In 1937, he unsuccessfully invited 20 major 8 ____ to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them 9 ____ . Eventually, Calson’s creation was undeniably a 10 ____ . Thanks for the discovery of Xerography, Calson became a very 11 ____ person. Even so, his life remains as simple as before. It looks as if he can live without his 12 ____ At the same time, he gave lots of his money to 13 ____ .$md$, NULL, ARRAY['.*inventor.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a77e7d94-dbc1-5ab7-ac4a-9686869c3efa', '0b364164-15d6-560a-9448-1e20e1f276ad', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Reading Passage.
Write your answers in boxes
7-13
on your answer sheet.
Calson, unlike a 20-century
7
, like to work on his own. In 1937, he unsuccessfully invited 20 major
8
to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them
9
. Eventually, Calson’s creation was undeniably a
10
. Thanks for the discovery of Xerography, Calson became a very
11
person. Even so, his life remains as simple as before. It looks as if he can live without his
12
At the same time, he gave lots of his money to
13
.

Calson, unlike a 20-century 7 ____ , like to work on his own. In 1937, he unsuccessfully invited 20 major 8 ____ to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them 9 ____ . Eventually, Calson’s creation was undeniably a 10 ____ . Thanks for the discovery of Xerography, Calson became a very 11 ____ person. Even so, his life remains as simple as before. It looks as if he can live without his 12 ____ At the same time, he gave lots of his money to 13 ____ .$md$, NULL, ARRAY['.*inventor.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4fc2ba0c-1dea-541e-bea5-a847a50a094a', '0b364164-15d6-560a-9448-1e20e1f276ad', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Reading Passage.
Write your answers in boxes
7-13
on your answer sheet.
Calson, unlike a 20-century
7
, like to work on his own. In 1937, he unsuccessfully invited 20 major
8
to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them
9
. Eventually, Calson’s creation was undeniably a
10
. Thanks for the discovery of Xerography, Calson became a very
11
person. Even so, his life remains as simple as before. It looks as if he can live without his
12
At the same time, he gave lots of his money to
13
.

Calson, unlike a 20-century 7 ____ , like to work on his own. In 1937, he unsuccessfully invited 20 major 8 ____ to make his discovery. However, this action was not welcome among shareholders at the beginning, all of them 9 ____ . Eventually, Calson’s creation was undeniably a 10 ____ . Thanks for the discovery of Xerography, Calson became a very 11 ____ person. Even so, his life remains as simple as before. It looks as if he can live without his 12 ____ At the same time, he gave lots of his money to 13 ____ .$md$, NULL, ARRAY['.*inventor.*']);

COMMIT;
