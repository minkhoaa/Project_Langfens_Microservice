BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-history-of-glass-1146'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-glass-1146';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-glass-1146';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-history-of-glass-1146';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('cecbc7ba-03dd-5fcf-8e6c-0cc4c1512dc6', 'ielts-reading-the-history-of-glass-1146', $t$The history of glass$t$, $md$## The history of glass

Nguồn:
- Test: https://mini-ielts.com/1146/reading/the-history-of-glass
- Solution: https://mini-ielts.com/1146/view-solution/reading/the-history-of-glass$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('88107270-2512-5408-a852-f8a0d679ae21', 'cecbc7ba-03dd-5fcf-8e6c-0cc4c1512dc6', 1, $t$Reading — The history of glass$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The history of glass

From our earliest origins, man has been making use of glass. Historians have discovered that a type of natural glass - obsidian - formed in places such as the mouth of a volcano as a result of the intense heat of an eruption melting sand - was first used as tips for spears . Archaeologists have even found evidence of man-made glass which dates back to 4000 BC; this took the form of glazes used for coating stone beads . It was not until 1500 BC, however, that the first hollow glass container was made by covering a sand core with a layer of molten glass.

Glass blowing became the most common way to make glass containers from the first century BC. The glass made during this time was highly coloured due to the impurities of the raw material. In the first century AD, methods of creating colourless glass were developed, which was then tinted by the addition of colouring materials. The secret of glass making was taken across Europe by the Romans during this century. However, they guarded the skills and technology required to make glass very closely, and it was not until their empire collapsed in 476 AD that glass-making knowledge became widespread throughout Europe and the Middle East. From the 10th century onwards, the Venetians gained a reputation for technical skill and artistic ability in the making of glass bottles, and many of the city’s craftsmen left Italy to set up glassworks throughout Europe.

A major milestone in the history of glass occurred with the invention of lead crystal glass by the English glass manufacturer George Ravenscroft (1632 - 1683). He attempted to counter the effect of clouding that sometimes occurred in blown glass by introducing lead to the raw materials used in the process. The new glass he created was softer and easier to decorate, and had a higher refractive index, adding to its brilliance and beauty, and it proved invaluable to the optical industry. It is thanks to Ravenscroft’s invention that optical lenses, astronomical telescopes, microscopes and the like became possible.

In Britain, the modem glass industry only really started to develop after the repeal of the Excise Act in 1845. Before that time, heavy taxes had been placed on the amount of glass melted in a glasshouse, and were levied continuously from 1745 to 1845. Joseph Paxton’s Crystal Palace at London’s Great Exhibition of 1851 marked the beginning of glass as a material used in the building industry. This revolutionary new building encouraged the use of glass in public, domestic and horticultural architecture. Glass manufacturing techniques also improved with the advancement of science and the development of better technology.

From 1887 onwards, glass making developed from traditional mouth-blowing to a semi-automatic process, after factory- owner HM Ashley introduced a machine capable of producing 200 bottles per hour in Castleford, Yorkshire, England - more than three times quicker than any previous production method. Then in 1907, the first fully automated machine was developed in the USA by Michael Owens - founder of the Owens Bottle Machine Company (later the major manufacturers Owens- Illinois) - and installed in its factory. Owens’ invention could produce an impressive 2,500 bottles per hour Other developments followed rapidly, but it | was not until the First World War when Britain became cut off from essential glass suppliers, that glass became part of the scientific sector. Previous to this, glass had been seen as a craft rather than a precise science.

Today, glass making is big business. It has become a modem, hi-tech industry operating in a fiercely competitive global market where quality, design and service levels are critical to maintaining market share. Modem glass plants are capable of making millions of glass containers a day in many different colours, with green, brown and clear remaining the most popular. Few of us can imagine modem life without glass. It features in almost every aspect of our lives - in our homes, our cars and whenever we sit down to eat or drink. Glass packaging is used for many products, many beverages are sold in glass, as are numerous foodstuffs, as well as medicines and cosmetics.

Glass is an ideal material for recycling, and with growing consumer concern for green issues, glass bottles and jars are becoming ever more popular. Glass recycling is good news for the environment. It saves used glass containers being sent to landfill. As less energy is needed to melt recycled glass than to melt down raw materials, this also saves fuel and production costs . Recycling also reduces the need for raw materials to be quarried, thus saving precious resources.

----------------------------------------------------

Great thanks to volunteer Lan Nguyen has contributed these explanations markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('48cd6745-7058-5d6b-81df-4ed1ea51df77', '88107270-2512-5408-a852-f8a0d679ae21', 1, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet
The History of Glass
• Early humans used a material called
1
Locate
to make the sharp points of their
2
Locate
• 4000 BC:
3
made of stone were covered in a coating of man-made glass.
Locate
• First century BC: glass was coloured because of the
4
in the material.
Locate
• Until 476 AD: Only the
5
knew how to make glass.
Locate
• From 10th century: Venetians became famous for making bottles out of glass.
• 17th century: George Ravenscroft developed a process using
6
Locate
to avoid the occurrence of
7
in blown glass.
Locate
• Mid-19th century: British glass production developed after changes to laws concerning
8
Locate

• Early humans used a material called 1 ____ Locate to make the sharp points of their 2 ____ Locate$md$, NULL, ARRAY['.*obsidian.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2eda928d-2818-5d2d-8e78-8f9a9c53c252', '88107270-2512-5408-a852-f8a0d679ae21', 2, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet
The History of Glass
• Early humans used a material called
1
Locate
to make the sharp points of their
2
Locate
• 4000 BC:
3
made of stone were covered in a coating of man-made glass.
Locate
• First century BC: glass was coloured because of the
4
in the material.
Locate
• Until 476 AD: Only the
5
knew how to make glass.
Locate
• From 10th century: Venetians became famous for making bottles out of glass.
• 17th century: George Ravenscroft developed a process using
6
Locate
to avoid the occurrence of
7
in blown glass.
Locate
• Mid-19th century: British glass production developed after changes to laws concerning
8
Locate

• Early humans used a material called 1 ____ Locate to make the sharp points of their 2 ____ Locate$md$, NULL, ARRAY['.*obsidian.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6b3c29ca-106b-583d-8a29-316016464688', '88107270-2512-5408-a852-f8a0d679ae21', 3, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet
The History of Glass
• Early humans used a material called
1
Locate
to make the sharp points of their
2
Locate
• 4000 BC:
3
made of stone were covered in a coating of man-made glass.
Locate
• First century BC: glass was coloured because of the
4
in the material.
Locate
• Until 476 AD: Only the
5
knew how to make glass.
Locate
• From 10th century: Venetians became famous for making bottles out of glass.
• 17th century: George Ravenscroft developed a process using
6
Locate
to avoid the occurrence of
7
in blown glass.
Locate
• Mid-19th century: British glass production developed after changes to laws concerning
8
Locate

• 4000 BC: 3 ____ made of stone were covered in a coating of man-made glass. Locate$md$, NULL, ARRAY['.*beads.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2fec0a88-9d15-5944-8b58-e3f361ee45fe', '88107270-2512-5408-a852-f8a0d679ae21', 4, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet
The History of Glass
• Early humans used a material called
1
Locate
to make the sharp points of their
2
Locate
• 4000 BC:
3
made of stone were covered in a coating of man-made glass.
Locate
• First century BC: glass was coloured because of the
4
in the material.
Locate
• Until 476 AD: Only the
5
knew how to make glass.
Locate
• From 10th century: Venetians became famous for making bottles out of glass.
• 17th century: George Ravenscroft developed a process using
6
Locate
to avoid the occurrence of
7
in blown glass.
Locate
• Mid-19th century: British glass production developed after changes to laws concerning
8
Locate

• First century BC: glass was coloured because of the 4 ____ in the material. Locate$md$, NULL, ARRAY['.*impurities.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('60e9b9be-e4bc-543f-8d88-9c4786838331', '88107270-2512-5408-a852-f8a0d679ae21', 5, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet
The History of Glass
• Early humans used a material called
1
Locate
to make the sharp points of their
2
Locate
• 4000 BC:
3
made of stone were covered in a coating of man-made glass.
Locate
• First century BC: glass was coloured because of the
4
in the material.
Locate
• Until 476 AD: Only the
5
knew how to make glass.
Locate
• From 10th century: Venetians became famous for making bottles out of glass.
• 17th century: George Ravenscroft developed a process using
6
Locate
to avoid the occurrence of
7
in blown glass.
Locate
• Mid-19th century: British glass production developed after changes to laws concerning
8
Locate

• Until 476 AD: Only the 5 ____ knew how to make glass. Locate$md$, NULL, ARRAY['.*romans.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d7ead0b9-7ef3-53c7-ad79-7fe323f83ffb', '88107270-2512-5408-a852-f8a0d679ae21', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet
The History of Glass
• Early humans used a material called
1
Locate
to make the sharp points of their
2
Locate
• 4000 BC:
3
made of stone were covered in a coating of man-made glass.
Locate
• First century BC: glass was coloured because of the
4
in the material.
Locate
• Until 476 AD: Only the
5
knew how to make glass.
Locate
• From 10th century: Venetians became famous for making bottles out of glass.
• 17th century: George Ravenscroft developed a process using
6
Locate
to avoid the occurrence of
7
in blown glass.
Locate
• Mid-19th century: British glass production developed after changes to laws concerning
8
Locate

• 17th century: George Ravenscroft developed a process using 6 ____ Locate to avoid the occurrence of 7 ____ in blown glass. Locate$md$, NULL, ARRAY['.*lead.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1a15ba3a-612b-5bd1-bf7d-e5d9ea363c86', '88107270-2512-5408-a852-f8a0d679ae21', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet
The History of Glass
• Early humans used a material called
1
Locate
to make the sharp points of their
2
Locate
• 4000 BC:
3
made of stone were covered in a coating of man-made glass.
Locate
• First century BC: glass was coloured because of the
4
in the material.
Locate
• Until 476 AD: Only the
5
knew how to make glass.
Locate
• From 10th century: Venetians became famous for making bottles out of glass.
• 17th century: George Ravenscroft developed a process using
6
Locate
to avoid the occurrence of
7
in blown glass.
Locate
• Mid-19th century: British glass production developed after changes to laws concerning
8
Locate

• 17th century: George Ravenscroft developed a process using 6 ____ Locate to avoid the occurrence of 7 ____ in blown glass. Locate$md$, NULL, ARRAY['.*lead.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2f52871d-8546-590b-b6a2-cc90d23697b1', '88107270-2512-5408-a852-f8a0d679ae21', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-8
on your answer sheet
The History of Glass
• Early humans used a material called
1
Locate
to make the sharp points of their
2
Locate
• 4000 BC:
3
made of stone were covered in a coating of man-made glass.
Locate
• First century BC: glass was coloured because of the
4
in the material.
Locate
• Until 476 AD: Only the
5
knew how to make glass.
Locate
• From 10th century: Venetians became famous for making bottles out of glass.
• 17th century: George Ravenscroft developed a process using
6
Locate
to avoid the occurrence of
7
in blown glass.
Locate
• Mid-19th century: British glass production developed after changes to laws concerning
8
Locate

• Mid-19th century: British glass production developed after changes to laws concerning 8 ____ Locate$md$, NULL, ARRAY['.*taxes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c58779c-0f82-5043-b02c-0146c8ef21dc', '88107270-2512-5408-a852-f8a0d679ae21', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
In 1887, HM Ashley had the fastest bottle-producing machine that existed at the time.
Locate
10
Michael Owens was hired by a large US company to design a fully-automated bottle manufacturing machine for them.
Locate
11
Nowadays, most glass is produced by large international manufacturers.
12
Concern for the environment is leading to an increased demand for glass containers.
Locate
13
It is more expensive to produce recycled glass than to manufacture new glass.
Locate

9 ____ In 1887, HM Ashley had the fastest bottle-producing machine that existed at the time. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd1a6244-d249-5e82-a0db-f4a22ab60272', '1c58779c-0f82-5043-b02c-0146c8ef21dc', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5913353-ce43-5110-bad3-07f7732c8934', '1c58779c-0f82-5043-b02c-0146c8ef21dc', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5eb7758d-af1f-5c96-98d9-ee17d2813324', '1c58779c-0f82-5043-b02c-0146c8ef21dc', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('99a26133-6baa-54c4-bef5-d242e65fcea9', '88107270-2512-5408-a852-f8a0d679ae21', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
In 1887, HM Ashley had the fastest bottle-producing machine that existed at the time.
Locate
10
Michael Owens was hired by a large US company to design a fully-automated bottle manufacturing machine for them.
Locate
11
Nowadays, most glass is produced by large international manufacturers.
12
Concern for the environment is leading to an increased demand for glass containers.
Locate
13
It is more expensive to produce recycled glass than to manufacture new glass.
Locate

10 ____ Michael Owens was hired by a large US company to design a fully-automated bottle manufacturing machine for them. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17b9a4d4-13b6-57e7-ac4a-035c0aee68e2', '99a26133-6baa-54c4-bef5-d242e65fcea9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e30b92ac-46b5-5f99-b458-035771949654', '99a26133-6baa-54c4-bef5-d242e65fcea9', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f850d165-b516-55eb-93c2-5524529105fa', '99a26133-6baa-54c4-bef5-d242e65fcea9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d498f30a-e851-540e-ad60-d8df35a8f7bc', '88107270-2512-5408-a852-f8a0d679ae21', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
In 1887, HM Ashley had the fastest bottle-producing machine that existed at the time.
Locate
10
Michael Owens was hired by a large US company to design a fully-automated bottle manufacturing machine for them.
Locate
11
Nowadays, most glass is produced by large international manufacturers.
12
Concern for the environment is leading to an increased demand for glass containers.
Locate
13
It is more expensive to produce recycled glass than to manufacture new glass.
Locate

11 ____ Nowadays, most glass is produced by large international manufacturers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8ec23c3-c971-5ac1-8f7d-75ae4e08b2db', 'd498f30a-e851-540e-ad60-d8df35a8f7bc', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c36d1dce-aea8-5f89-b5e9-cd0a3412eb2f', 'd498f30a-e851-540e-ad60-d8df35a8f7bc', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8ac6aa3-efc1-5a7a-8019-cb2e66c601ea', 'd498f30a-e851-540e-ad60-d8df35a8f7bc', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('748b7ac5-63b2-5f86-8d59-913dc5cf7023', '88107270-2512-5408-a852-f8a0d679ae21', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
In 1887, HM Ashley had the fastest bottle-producing machine that existed at the time.
Locate
10
Michael Owens was hired by a large US company to design a fully-automated bottle manufacturing machine for them.
Locate
11
Nowadays, most glass is produced by large international manufacturers.
12
Concern for the environment is leading to an increased demand for glass containers.
Locate
13
It is more expensive to produce recycled glass than to manufacture new glass.
Locate

12 ____ Concern for the environment is leading to an increased demand for glass containers. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5e234bc-cb32-5473-ab29-46a680d02221', '748b7ac5-63b2-5f86-8d59-913dc5cf7023', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3009b24a-d425-576c-a4eb-6be5951321e7', '748b7ac5-63b2-5f86-8d59-913dc5cf7023', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f52e974e-1ab0-58b5-b198-0554eef32a44', '748b7ac5-63b2-5f86-8d59-913dc5cf7023', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('590af858-7540-5c15-9a9e-130da32a83ef', '88107270-2512-5408-a852-f8a0d679ae21', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
In 1887, HM Ashley had the fastest bottle-producing machine that existed at the time.
Locate
10
Michael Owens was hired by a large US company to design a fully-automated bottle manufacturing machine for them.
Locate
11
Nowadays, most glass is produced by large international manufacturers.
12
Concern for the environment is leading to an increased demand for glass containers.
Locate
13
It is more expensive to produce recycled glass than to manufacture new glass.
Locate

13 ____ It is more expensive to produce recycled glass than to manufacture new glass. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54f3bbcf-a8b1-5424-b272-157a05471e68', '590af858-7540-5c15-9a9e-130da32a83ef', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcdc8cc8-c0a7-5508-818f-7e963b5034e3', '590af858-7540-5c15-9a9e-130da32a83ef', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1149519e-9064-5c6b-998d-b4962d252416', '590af858-7540-5c15-9a9e-130da32a83ef', 3, $md$NOT GIVEN$md$, false);

COMMIT;
