BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-an-important-language-development-1437'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-an-important-language-development-1437';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-an-important-language-development-1437';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-an-important-language-development-1437';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('80b43831-6420-5b3b-9656-f23564607415', 'ielts-reading-an-important-language-development-1437', $t$An important language development$t$, $md$## An important language development

Nguồn:
- Test: https://mini-ielts.com/1437/reading/an-important-language-development
- Solution: https://mini-ielts.com/1437/view-solution/reading/an-important-language-development$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7de17e5c-f261-5980-bb2b-78f0bd4c1946', '80b43831-6420-5b3b-9656-f23564607415', 1, $t$Reading — An important language development$t$, $md$Read the passage and answer questions **1–13**.

### Passage: An important language development

Cuneiform, the world’s first known system of handwriting, originated some 6.000 years ago in Summer in what is now southern Iraq. It was most often inscribed on palm­sized, rectangular clay tablets measuring several centimetres across, although occasionally, larger tablets or cylinders were used. Clay was an excellent medium for writing. Other surfaces which have been employed - for example, parchment, papyrus and paper - are not long - lasting and are easily destroyed by fire and water. But clay has proved to be resistant to those particular kinds of damage.

The word ‘cuneiform’ actually refers to the marks or signs inscribed in the clay. The original cuneiform signs consisted of a series of lines - triangular, vertical, diagonal and horizontal. Sumerian writers would impress these lines into the wet clay with a stylus - a long, thin, pointed instrument which looked somewhat like a pen. Oddly, the signs were often almost too small to see with the naked eye. Cuneiform signs were used for the writing of at least a dozen languages. This is similar to how the Latin alphabet is used today for writing English, French, Spanish and German for example.

Before the development of cuneiform, tokens were used by the Sumerians to record certain information. For example, they might take small stones and use them as tokens or representations of something else, like a goat. A number of tokens, then, might mean a herd of goat. These tokens might then be placed in a cloth container and provided to a buyer as a receipt for a transaction, perhaps five tokens for five animals. It was not that different from what we do today when we buy some bread and the clerk gives us back a piece of paper with numbers on it to confirm the exchange.

By the 4 th century BCE, the Sumerians had adapted this system to a form of writing. They began putting tokens in a container resembling an envelope, and now made of clay instead of cloth. They then stamped the outside to indicate the number and type of tokens inside. A person could then ‘read’ what was stamped on the container and know what was inside.

Gradually, Sumerians developed symbols for words. When first developed, each symbol looked like the concrete thing it represented. For example, an image which resembled the drawing of a sheep meant just that. Then another level of abstraction was introduced when symbols were developed for intangible ideas such as ‘female’ of ‘hot’ or ‘God’. Cuneiform, in other words, evolved from a way used primarily to track and store information into a way to represent the world symbolically. Over the centuries, the marks became ever more abstract, finally evolving into signs that looked nothing like what they referred to, just as the letters ‘h-o-u-s-e’ have no visual connection to the place we live in. At this last stage in the evolution of cuneiform, the signs took the form of tringles, which became common cuneiform signs.

As the marks became more abstract, the system became more efficient because there were fewer marks a ‘reader’ needed to learn. But cuneiform also became more complex because society itself was becoming more complex, so there were more ideas and concepts that needed to be expressed. However, most linguists and historians agree cuneiform developed primarily as a tool for accounting. Of the cuneiform tablets that have been discovered, excavated and translated, about 75 percent contain this type of practical information, rather than artistic or imaginative work.

Cuneiform writing was used for thousands of years, but it eventually ceased to be used in everyday life. In fact, it died out and remained unintelligible for almost 2.000 years. In the late 19 th century, a British army officer, Henry Rawlinson, discovered cuneiform inscriptions which had been carved in the surface of rocks in the Behistun mountains in what is present-day Iran. Rawlinson made impressions of the marks on large pieces of paper, as he balanced dangerously on the surrounding rocks.

Rawlinson took his copies home to Britain and studied them for years to determine what each line stood for, and what each group of symbols meant. He found that in the writing on those particular rocks every word was repeated three times in three languages: Old Persian, Elamite and Babylonian. Since the meanings in these languages were already known to linguists, he could thus translate the cuneiform. Eventually, he fully decoded the cuneiform marks and he discovered that they described the life of Darius, a king of the Persian Empire in the 5 th century BCE.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e24bd818-ac9f-5b52-bc82-62015cb23671', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cuneiform tablets were produced in different shapes and sizes.
2
When Sumerian writers marked on the clay tablets, the tablets were dry
3
Cuneiform was often difficult to read because of its size.
4
A number of languages adopted cuneiform.
5
Cuneiform signs, can be found in some modern alphabets.

1 ____ Cuneiform tablets were produced in different shapes and sizes.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23e4895e-a2e3-5758-9833-b2247460e0f7', 'e24bd818-ac9f-5b52-bc82-62015cb23671', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffa78e9a-8d69-548c-83a6-4df71cf351a1', 'e24bd818-ac9f-5b52-bc82-62015cb23671', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e673c106-7a96-5493-9a53-fcd7055a753e', 'e24bd818-ac9f-5b52-bc82-62015cb23671', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('71667afb-25dd-5754-8413-e871b6c67b0c', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cuneiform tablets were produced in different shapes and sizes.
2
When Sumerian writers marked on the clay tablets, the tablets were dry
3
Cuneiform was often difficult to read because of its size.
4
A number of languages adopted cuneiform.
5
Cuneiform signs, can be found in some modern alphabets.

2 ____ When Sumerian writers marked on the clay tablets, the tablets were dry$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('deead918-04c2-5d50-a620-154486782b70', '71667afb-25dd-5754-8413-e871b6c67b0c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec3ae74b-32dd-55cb-9cb9-c663953e285c', '71667afb-25dd-5754-8413-e871b6c67b0c', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bffa62c-14f0-5d7e-a6be-e3a6a3d3c770', '71667afb-25dd-5754-8413-e871b6c67b0c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7cdd1460-9255-5fc5-847b-2fcdfacf8d71', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cuneiform tablets were produced in different shapes and sizes.
2
When Sumerian writers marked on the clay tablets, the tablets were dry
3
Cuneiform was often difficult to read because of its size.
4
A number of languages adopted cuneiform.
5
Cuneiform signs, can be found in some modern alphabets.

3 ____ Cuneiform was often difficult to read because of its size.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef8e79c4-cf1e-5d68-929c-de5257831caf', '7cdd1460-9255-5fc5-847b-2fcdfacf8d71', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62eaa092-e297-5c8c-89d7-4a6804fbc2b6', '7cdd1460-9255-5fc5-847b-2fcdfacf8d71', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c366b778-c2e9-539a-88c0-7e4f4501102e', '7cdd1460-9255-5fc5-847b-2fcdfacf8d71', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('abf82d49-79f9-5f35-9fcb-db7a221522a1', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cuneiform tablets were produced in different shapes and sizes.
2
When Sumerian writers marked on the clay tablets, the tablets were dry
3
Cuneiform was often difficult to read because of its size.
4
A number of languages adopted cuneiform.
5
Cuneiform signs, can be found in some modern alphabets.

4 ____ A number of languages adopted cuneiform.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54cee905-9909-59f2-ae93-099fd2ba163f', 'abf82d49-79f9-5f35-9fcb-db7a221522a1', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11b4b7ec-e3e4-5771-9133-c372b88b5cfe', 'abf82d49-79f9-5f35-9fcb-db7a221522a1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a41129a8-63df-53f9-b99f-dfcb61ad6d0e', 'abf82d49-79f9-5f35-9fcb-db7a221522a1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('80b9be5e-5c79-572e-8d01-3245687e7dce', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cuneiform tablets were produced in different shapes and sizes.
2
When Sumerian writers marked on the clay tablets, the tablets were dry
3
Cuneiform was often difficult to read because of its size.
4
A number of languages adopted cuneiform.
5
Cuneiform signs, can be found in some modern alphabets.

5 ____ Cuneiform signs, can be found in some modern alphabets.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1940a437-9233-5121-8b54-9044904b4559', '80b9be5e-5c79-572e-8d01-3245687e7dce', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e093542e-a10d-50b2-993f-e1836fa5aa02', '80b9be5e-5c79-572e-8d01-3245687e7dce', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4613805-417f-56af-b626-1cf954c4c754', '80b9be5e-5c79-572e-8d01-3245687e7dce', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('236341b5-4312-5a8a-96ed-346b3c98b452', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet,
The development and translation of cuneiform
Before cuneiform
tokens, for example,
6
were often used
the first tokens were kept in containers made of
7
tokens were used as a
8
to give when selling something
By 4
th
century BCE
tokens were put in a container that looked like a clay
9
Complex, abstract symbols developed
at first, signs looked like what they indicated, e.g.
10
then signs became more abstract
eventually, cuneiform signs shaped like
11
were developed
according to experts, cuneiform was mainly used for
12
19
th
-century translation of cuneiform inscriptions by Henry Rawlinson
Rawlinson found cuneiform inscriptions in the Behistun mountains
Rawlinson copied inscriptions onto
13
Rawlinson realised that each word of the inscriptions appeared in different languages
When translated, Rawlinson found the writings were about a 5
th
-century BCE king

tokens, for example, 6 ____ were often used$md$, NULL, ARRAY['.*stones.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e15a0072-ea4d-5f6b-923f-7fcba23c26d8', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet,
The development and translation of cuneiform
Before cuneiform
tokens, for example,
6
were often used
the first tokens were kept in containers made of
7
tokens were used as a
8
to give when selling something
By 4
th
century BCE
tokens were put in a container that looked like a clay
9
Complex, abstract symbols developed
at first, signs looked like what they indicated, e.g.
10
then signs became more abstract
eventually, cuneiform signs shaped like
11
were developed
according to experts, cuneiform was mainly used for
12
19
th
-century translation of cuneiform inscriptions by Henry Rawlinson
Rawlinson found cuneiform inscriptions in the Behistun mountains
Rawlinson copied inscriptions onto
13
Rawlinson realised that each word of the inscriptions appeared in different languages
When translated, Rawlinson found the writings were about a 5
th
-century BCE king

the first tokens were kept in containers made of 7 ____$md$, NULL, ARRAY['.*cloth.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('533c8ab7-04bc-5aed-8de7-08d051eeb4b0', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet,
The development and translation of cuneiform
Before cuneiform
tokens, for example,
6
were often used
the first tokens were kept in containers made of
7
tokens were used as a
8
to give when selling something
By 4
th
century BCE
tokens were put in a container that looked like a clay
9
Complex, abstract symbols developed
at first, signs looked like what they indicated, e.g.
10
then signs became more abstract
eventually, cuneiform signs shaped like
11
were developed
according to experts, cuneiform was mainly used for
12
19
th
-century translation of cuneiform inscriptions by Henry Rawlinson
Rawlinson found cuneiform inscriptions in the Behistun mountains
Rawlinson copied inscriptions onto
13
Rawlinson realised that each word of the inscriptions appeared in different languages
When translated, Rawlinson found the writings were about a 5
th
-century BCE king

tokens were used as a 8 ____ to give when selling something$md$, NULL, ARRAY['.*receipt.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0988ebac-9885-518c-9d31-a808bd43dd45', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet,
The development and translation of cuneiform
Before cuneiform
tokens, for example,
6
were often used
the first tokens were kept in containers made of
7
tokens were used as a
8
to give when selling something
By 4
th
century BCE
tokens were put in a container that looked like a clay
9
Complex, abstract symbols developed
at first, signs looked like what they indicated, e.g.
10
then signs became more abstract
eventually, cuneiform signs shaped like
11
were developed
according to experts, cuneiform was mainly used for
12
19
th
-century translation of cuneiform inscriptions by Henry Rawlinson
Rawlinson found cuneiform inscriptions in the Behistun mountains
Rawlinson copied inscriptions onto
13
Rawlinson realised that each word of the inscriptions appeared in different languages
When translated, Rawlinson found the writings were about a 5
th
-century BCE king

tokens were put in a container that looked like a clay 9 ____$md$, NULL, ARRAY['.*envelope.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cdd60804-6708-5086-aad0-b9fedc26cb85', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet,
The development and translation of cuneiform
Before cuneiform
tokens, for example,
6
were often used
the first tokens were kept in containers made of
7
tokens were used as a
8
to give when selling something
By 4
th
century BCE
tokens were put in a container that looked like a clay
9
Complex, abstract symbols developed
at first, signs looked like what they indicated, e.g.
10
then signs became more abstract
eventually, cuneiform signs shaped like
11
were developed
according to experts, cuneiform was mainly used for
12
19
th
-century translation of cuneiform inscriptions by Henry Rawlinson
Rawlinson found cuneiform inscriptions in the Behistun mountains
Rawlinson copied inscriptions onto
13
Rawlinson realised that each word of the inscriptions appeared in different languages
When translated, Rawlinson found the writings were about a 5
th
-century BCE king

at first, signs looked like what they indicated, e.g. 10 ____$md$, NULL, ARRAY['.*sheep.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('06be2227-dd9d-5667-95c3-acd076028fda', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet,
The development and translation of cuneiform
Before cuneiform
tokens, for example,
6
were often used
the first tokens were kept in containers made of
7
tokens were used as a
8
to give when selling something
By 4
th
century BCE
tokens were put in a container that looked like a clay
9
Complex, abstract symbols developed
at first, signs looked like what they indicated, e.g.
10
then signs became more abstract
eventually, cuneiform signs shaped like
11
were developed
according to experts, cuneiform was mainly used for
12
19
th
-century translation of cuneiform inscriptions by Henry Rawlinson
Rawlinson found cuneiform inscriptions in the Behistun mountains
Rawlinson copied inscriptions onto
13
Rawlinson realised that each word of the inscriptions appeared in different languages
When translated, Rawlinson found the writings were about a 5
th
-century BCE king

eventually, cuneiform signs shaped like 11 ____ were developed$md$, NULL, ARRAY['.*triangles.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('734c0779-c2b4-513c-b60d-661118b17414', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet,
The development and translation of cuneiform
Before cuneiform
tokens, for example,
6
were often used
the first tokens were kept in containers made of
7
tokens were used as a
8
to give when selling something
By 4
th
century BCE
tokens were put in a container that looked like a clay
9
Complex, abstract symbols developed
at first, signs looked like what they indicated, e.g.
10
then signs became more abstract
eventually, cuneiform signs shaped like
11
were developed
according to experts, cuneiform was mainly used for
12
19
th
-century translation of cuneiform inscriptions by Henry Rawlinson
Rawlinson found cuneiform inscriptions in the Behistun mountains
Rawlinson copied inscriptions onto
13
Rawlinson realised that each word of the inscriptions appeared in different languages
When translated, Rawlinson found the writings were about a 5
th
-century BCE king

according to experts, cuneiform was mainly used for 12 ____$md$, NULL, ARRAY['.*accounting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3f11a7b4-377f-5b1b-9645-5c6746ec44eb', '7de17e5c-f261-5980-bb2b-78f0bd4c1946', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 6-13 on your answer sheet,
The development and translation of cuneiform
Before cuneiform
tokens, for example,
6
were often used
the first tokens were kept in containers made of
7
tokens were used as a
8
to give when selling something
By 4
th
century BCE
tokens were put in a container that looked like a clay
9
Complex, abstract symbols developed
at first, signs looked like what they indicated, e.g.
10
then signs became more abstract
eventually, cuneiform signs shaped like
11
were developed
according to experts, cuneiform was mainly used for
12
19
th
-century translation of cuneiform inscriptions by Henry Rawlinson
Rawlinson found cuneiform inscriptions in the Behistun mountains
Rawlinson copied inscriptions onto
13
Rawlinson realised that each word of the inscriptions appeared in different languages
When translated, Rawlinson found the writings were about a 5
th
-century BCE king

Rawlinson copied inscriptions onto 13 ____$md$, NULL, ARRAY['.*paper.*']);

COMMIT;
