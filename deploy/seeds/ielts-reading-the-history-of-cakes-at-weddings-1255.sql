BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-history-of-cakes-at-weddings-1255'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-cakes-at-weddings-1255';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-cakes-at-weddings-1255';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-history-of-cakes-at-weddings-1255';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('04d808cd-ce8d-530e-8000-5ea302c0da35', 'ielts-reading-the-history-of-cakes-at-weddings-1255', $t$The history of cakes at weddings$t$, $md$## The history of cakes at weddings

Nguồn:
- Test: https://mini-ielts.com/1255/reading/the-history-of-cakes-at-weddings
- Solution: https://mini-ielts.com/1255/view-solution/reading/the-history-of-cakes-at-weddings$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', '04d808cd-ce8d-530e-8000-5ea302c0da35', 1, $t$Reading — The history of cakes at weddings$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The history of cakes at weddings

In Western cultures, since antiquity. Weddings customarily have been celebrated with a special cake. Ancient Roman wedding ceremonies were finalized by breaking a cake of wheat or barley over the bride’s head as n symbol of good fortune. The newly married couple then ate some of the crumbs together. Afterward, the wedding guests gathered up the remaining crumbs as tokens of good luck. Wedding guests were also supplied with sweetmeats called confetti, a sweet mixture of nuts, dried fruit and honeyed almonds. Handfuls of confetti were showered over the bride and groom; indeed, it seems to have been the custom to throw confetti about enthusiastically. Eventually, confetti in the form of sweets and nuts was replaced with rice, flower petals, or colored paper, and these new types of confetti continue to be thrown over newly married couples in many countries around the world.

When the Romans invaded Britain in 43 AD, many of their customs and traditions became part of British life. These customs included their wedding customs, and when the Normans invaded Britain in 1066 they brought many French traditions. Other changes came about due to increased trade and contact with Europe, but present-day British wedding traditions remain firmly rooted in the past. In medieval Britain, small spiced buns, which were common everyday fare, were often eaten at weddings. These were stacked in a towering pile, as high as possible. If the bride and groom were able to kiss over the tall stack, it augured a lifetime of riches. The earliest British recipe exclusively for eating at weddings is Bride Pie, which was recorded in 1685. This was a large round pie with an elaborately decorated pastry crust that concealed a filling of oysters, pine nuts lamb and spices. Each guest had to eat a small piece of the pier not to do so was considered extremely impolite. A ring was traditionally placed in the pie, and the lady who found it would be next to marry.

In the 17 th century, Bride Pie was changed into Bride Cake, the predecessor of the modern British wedding cake. Cakes containing dried fruit and sugar, symbols of prosperity, gradually became the centerpieces for weddings. Some people made Bride Cake in the cheaper form of two large rounds of pastry sandwiched together with currants and sprinkled with sugar. Very few homes at the time could boast of having ovens, but this type of pastry cake could be cooked on a baking stone on the hearth.

Later in the 17 th century, there was a new development when wedding cakes began to be made in pairs, one for the bride and another for the groom. Both cakes were dark, heavy fruitcakes; the groom’s cake was smaller than the bride’s cake, and was cut up into little squares that were placed in boxes for the guests to take home as a wedding memento. Groom’s cakes gradually died out and are no longer part of British weddings. However, the tradition has undergone a revival in the United States, where for many years the groom’s cake has served as a wedding gift for guests. Modern groom’s cakes are often formed and decorated to depict the groom’s hobby, for example a golf bag, a camera, a chess board.

Groom’s cakes were never covered with icing, but Bride Cake covered with white icing first appeared sometime in the 17 th century. After the cake was baked, it was covered with a pure white, smooth icing made with double refined sugar, egg whites, and orange-flower water. The mixture was beaten for two hours, then spread over the cake and dried in the oven until hard. A pure white color was much sought after for wedding cake icing because white icing meant that only the finest refined sugar had been used. Thus a pure white cake was a status symbol, as it displayed the family’s wealth.

The late 1800s in Britain saw the introduction of a new tradition, with the first multi-tiered wedding cakes. These were impressive cakes: they were heavy because they were made with so much dried fruit, and highly decorated with icing and embellished with sugar flowers, doves, horseshoes and bells. The first multi-tiered cakes comprised iced cakes stacked on top of each other rather like a succession of boxes gradually decreasing in size. The cakes from the upper tiers did not sink into the lower tiers because they were a bit put on top of each other until the icing between each cake had had time to harden. It was not until the beginning of the 20 th century that the cake tiers were separated and supported by columns.

Twenty-first-century weddings are big business for Britain’s wedding industry. Over 300,000 people get married each year and a wedding can cost thousands of pounds. The cost of the all-important wedding cake can be hundreds of pounds, depending on the dimension and design. It will be interesting to see whether wedding cakes continue to be popular at weddings.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f2272928-4e52-53c3-a393-ba90e77ab6ff', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

QUESTIONS 1 - 6
QUESTIONS 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Breaking a cake over the bride’s head was the last part of an ancient Roman wedding ceremony.
2
Confetti is still made of nuts, dried fruit and honeyed almonds.
3
The groom’s family used to supply the confetti.
4
It was considered lucky for a newly married couple to be able to kiss over a tower of spiced buns.
5
Only brides were allowed to eat Bride Pie.
6
The wedding cakes eaten in Britain today developed from Bride Cake of the 17
th
century.

1 ____ Breaking a cake over the bride’s head was the last part of an ancient Roman wedding ceremony.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a9e6ed2-2685-557c-89ab-9ba516cdc0e5', 'f2272928-4e52-53c3-a393-ba90e77ab6ff', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12846bd6-2ec1-5f58-bc3e-b599455487ee', 'f2272928-4e52-53c3-a393-ba90e77ab6ff', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1505a17-c6ec-5da0-848a-2cef2503ec18', 'f2272928-4e52-53c3-a393-ba90e77ab6ff', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('92d381dd-0e3b-5c8c-97aa-8002bd6c044f', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

QUESTIONS 1 - 6
QUESTIONS 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Breaking a cake over the bride’s head was the last part of an ancient Roman wedding ceremony.
2
Confetti is still made of nuts, dried fruit and honeyed almonds.
3
The groom’s family used to supply the confetti.
4
It was considered lucky for a newly married couple to be able to kiss over a tower of spiced buns.
5
Only brides were allowed to eat Bride Pie.
6
The wedding cakes eaten in Britain today developed from Bride Cake of the 17
th
century.

2 ____ Confetti is still made of nuts, dried fruit and honeyed almonds.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a282497-2457-5bba-aec4-a7cc0c284f26', '92d381dd-0e3b-5c8c-97aa-8002bd6c044f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9ad0e1f-c8df-529e-aec5-7a3f929fd9ad', '92d381dd-0e3b-5c8c-97aa-8002bd6c044f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed0d5067-6557-5045-9aa7-db3751cfdd6f', '92d381dd-0e3b-5c8c-97aa-8002bd6c044f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bc98a88b-4ecd-58e9-b6ad-904fd8e13bfe', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

QUESTIONS 1 - 6
QUESTIONS 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Breaking a cake over the bride’s head was the last part of an ancient Roman wedding ceremony.
2
Confetti is still made of nuts, dried fruit and honeyed almonds.
3
The groom’s family used to supply the confetti.
4
It was considered lucky for a newly married couple to be able to kiss over a tower of spiced buns.
5
Only brides were allowed to eat Bride Pie.
6
The wedding cakes eaten in Britain today developed from Bride Cake of the 17
th
century.

3 ____ The groom’s family used to supply the confetti.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7505829-56e3-570d-92d1-c4a2e1974549', 'bc98a88b-4ecd-58e9-b6ad-904fd8e13bfe', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd1a034d-1b03-5a1c-81f7-e9499557dd11', 'bc98a88b-4ecd-58e9-b6ad-904fd8e13bfe', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd2ff224-b69e-5a0b-83eb-546220d79282', 'bc98a88b-4ecd-58e9-b6ad-904fd8e13bfe', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e196be91-5ed9-5324-9ab6-9bf9d99e7d3a', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

QUESTIONS 1 - 6
QUESTIONS 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Breaking a cake over the bride’s head was the last part of an ancient Roman wedding ceremony.
2
Confetti is still made of nuts, dried fruit and honeyed almonds.
3
The groom’s family used to supply the confetti.
4
It was considered lucky for a newly married couple to be able to kiss over a tower of spiced buns.
5
Only brides were allowed to eat Bride Pie.
6
The wedding cakes eaten in Britain today developed from Bride Cake of the 17
th
century.

4 ____ It was considered lucky for a newly married couple to be able to kiss over a tower of spiced buns.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c92f5466-9a7c-5c84-8bef-ce01d2c0ef27', 'e196be91-5ed9-5324-9ab6-9bf9d99e7d3a', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03727096-9796-578f-957b-1ae3566499aa', 'e196be91-5ed9-5324-9ab6-9bf9d99e7d3a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4f03fb8-047a-5845-9fd9-b95180d5cd2b', 'e196be91-5ed9-5324-9ab6-9bf9d99e7d3a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c450e93a-d2e8-5617-8ef4-3a3b446053f0', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

QUESTIONS 1 - 6
QUESTIONS 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Breaking a cake over the bride’s head was the last part of an ancient Roman wedding ceremony.
2
Confetti is still made of nuts, dried fruit and honeyed almonds.
3
The groom’s family used to supply the confetti.
4
It was considered lucky for a newly married couple to be able to kiss over a tower of spiced buns.
5
Only brides were allowed to eat Bride Pie.
6
The wedding cakes eaten in Britain today developed from Bride Cake of the 17
th
century.

5 ____ Only brides were allowed to eat Bride Pie.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46bd4d5f-36e5-58e1-9b7a-20054b1c4b57', 'c450e93a-d2e8-5617-8ef4-3a3b446053f0', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c56a2314-fadf-5a8c-b316-7ea338eb8f2b', 'c450e93a-d2e8-5617-8ef4-3a3b446053f0', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76581164-9bbb-5524-8f7e-6e71a4d36b1f', 'c450e93a-d2e8-5617-8ef4-3a3b446053f0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('17ce0485-ead2-54bc-b4c3-74547d342562', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

QUESTIONS 1 - 6
QUESTIONS 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Breaking a cake over the bride’s head was the last part of an ancient Roman wedding ceremony.
2
Confetti is still made of nuts, dried fruit and honeyed almonds.
3
The groom’s family used to supply the confetti.
4
It was considered lucky for a newly married couple to be able to kiss over a tower of spiced buns.
5
Only brides were allowed to eat Bride Pie.
6
The wedding cakes eaten in Britain today developed from Bride Cake of the 17
th
century.

6 ____ The wedding cakes eaten in Britain today developed from Bride Cake of the 17 th century.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d6414f8-6580-583d-9d7d-6d3a5a3dceb5', '17ce0485-ead2-54bc-b4c3-74547d342562', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d60095f4-da10-5779-add3-cf9a54f48487', '17ce0485-ead2-54bc-b4c3-74547d342562', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1153668e-cbd5-5242-9fe1-602631fcc91b', '17ce0485-ead2-54bc-b4c3-74547d342562', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('20cba18b-4567-59fd-87ec-5ab3c91d96ba', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

QUESTIONS 7 - 9
QUESTIONS 7 - 9
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answer in boxes 7-9 on your answer sheet.
Wedding cakes
17
th
century- Britain Bride Cake
:
- expensive ingredients were a sign of wealth
- less expensive round cakes were made of
7
with currants in between and sugar on top
- they were baked on a hearth stone because not all homes had
8
Now- United States - Groom’s cake:
- guest receive pieces of the groom’s cake
- cakes may represent the
9
of the groom

- less expensive round cakes were made of 7 ____ with currants in between and sugar on top$md$, NULL, ARRAY['.*pastry.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ad8647ed-2bf2-57aa-b855-8cd5899908db', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

QUESTIONS 7 - 9
QUESTIONS 7 - 9
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answer in boxes 7-9 on your answer sheet.
Wedding cakes
17
th
century- Britain Bride Cake
:
- expensive ingredients were a sign of wealth
- less expensive round cakes were made of
7
with currants in between and sugar on top
- they were baked on a hearth stone because not all homes had
8
Now- United States - Groom’s cake:
- guest receive pieces of the groom’s cake
- cakes may represent the
9
of the groom

- they were baked on a hearth stone because not all homes had 8 ____$md$, NULL, ARRAY['.*ovens.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bc6eea74-9c2e-5fbb-b812-260f0939c61c', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

QUESTIONS 7 - 9
QUESTIONS 7 - 9
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answer in boxes 7-9 on your answer sheet.
Wedding cakes
17
th
century- Britain Bride Cake
:
- expensive ingredients were a sign of wealth
- less expensive round cakes were made of
7
with currants in between and sugar on top
- they were baked on a hearth stone because not all homes had
8
Now- United States - Groom’s cake:
- guest receive pieces of the groom’s cake
- cakes may represent the
9
of the groom

- cakes may represent the 9 ____ of the groom$md$, NULL, ARRAY['.*hobby.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f7328d44-b905-5d57-a6be-6230d1cc0377', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

QUESTIONS 10 - 13
QUESTIONS 10 - 13
Label the diagram below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet.
10. Examples of wedding cakes with several
10
.
11. In the early 1900s,
11
were used to keep individual cakes apart.
12. The size of these cakes as well as their
12
affects pricing.
13. Hardened
13
between cakes stopped higher cakes sinking into tower cakes.

10. Examples of wedding cakes with several 10 ____ .$md$, NULL, ARRAY['.*boxes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7906a2b6-f426-5455-aa88-22b564187033', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

QUESTIONS 10 - 13
QUESTIONS 10 - 13
Label the diagram below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet.
10. Examples of wedding cakes with several
10
.
11. In the early 1900s,
11
were used to keep individual cakes apart.
12. The size of these cakes as well as their
12
affects pricing.
13. Hardened
13
between cakes stopped higher cakes sinking into tower cakes.

11. In the early 1900s, 11 ____ were used to keep individual cakes apart.$md$, NULL, ARRAY['.*columns.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5edbe16a-395c-5cf8-b25a-ec1d7ad26450', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

QUESTIONS 10 - 13
QUESTIONS 10 - 13
Label the diagram below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet.
10. Examples of wedding cakes with several
10
.
11. In the early 1900s,
11
were used to keep individual cakes apart.
12. The size of these cakes as well as their
12
affects pricing.
13. Hardened
13
between cakes stopped higher cakes sinking into tower cakes.

12. The size of these cakes as well as their 12 ____ affects pricing.$md$, NULL, ARRAY['.*design.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9c2b1b75-30e3-5a4a-949f-465ef99c7703', '0d41f2b7-6bbd-54c0-9597-71cbc6a2b1ce', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

QUESTIONS 10 - 13
QUESTIONS 10 - 13
Label the diagram below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet.
10. Examples of wedding cakes with several
10
.
11. In the early 1900s,
11
were used to keep individual cakes apart.
12. The size of these cakes as well as their
12
affects pricing.
13. Hardened
13
between cakes stopped higher cakes sinking into tower cakes.

13. Hardened 13 ____ between cakes stopped higher cakes sinking into tower cakes.$md$, NULL, ARRAY['.*icing.*']);

COMMIT;
