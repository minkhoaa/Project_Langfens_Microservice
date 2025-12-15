BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-rise-and-fall-of-the-british-textile-industry-1210'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-rise-and-fall-of-the-british-textile-industry-1210';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-rise-and-fall-of-the-british-textile-industry-1210';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-rise-and-fall-of-the-british-textile-industry-1210';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('cc8eedbc-b1ef-587e-bf88-0e2c5a06117a', 'ielts-reading-the-rise-and-fall-of-the-british-textile-industry-1210', $t$The Rise and Fall of the British Textile Industry$t$, $md$## The Rise and Fall of the British Textile Industry

Nguồn:
- Test: https://mini-ielts.com/1210/reading/the-rise-and-fall-of-the-british-textile-industry
- Solution: https://mini-ielts.com/1210/view-solution/reading/the-rise-and-fall-of-the-british-textile-industry$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 'cc8eedbc-b1ef-587e-bf88-0e2c5a06117a', 1, $t$Reading — The Rise and Fall of the British Textile Industry$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Rise and Fall of the British Textile Industry

Textile production in Britain can be said to have its roots as an industry at the beginning of the 18 th century, when Thomas Crotchet and George Sorocold established what is thought to be the first factory built in Britain. It was a textile mill with a waterwheel as its source of power, the latest machinery, and even accommodation for the workers. As well as possibly being the first sweatshop in the modern sense, it was the beginning of the end for traditional textile production.

For hundreds of years the spinning and weaving of cloth had been done manually by men, women and children in their own homes.The yarn would be combed and spun using a spindle, then woven on a hand loom, and what they produced would be mainly for local consumption .Technology far more sophisticated than the spindle and hand-loom would change all that.

The demand for cotton textiles had been growing since the Middle Ages, fostered by the importation of high quality cotton fabrics from the Middle East and India . So how were local producers to fight off the com petition? The imported fabrics were of course expensive, so textile makers (not just in Britain but throughout Europe) produced mixed fabrics and cotton substitutes .They also had foreign textiles banned . But the key to the increased productivity needed to meet the demand, was machine production . It would be faster, cheaper and the finished products would be consistent in quality. Not least of the advantages was that it would allow manufacturers to market their goods on a large, if not yet global, scale.

The story of the growth of the British textile industry from about 1733 and for the next two hundred years is one of constant technological innovation and expansion. In 1733 John Kay invented the fly-shuttle, which made the hand-loom more efficient, and in 1764 James Hargreaves came up with the spinning jenny, which among other things had the effect of raising productivity eightfold. The next great innovator was Richard Arkwright, who in 1768 employed John Kay (of the fly-shuttle) to help him build more efficient machinery. He was a man with a vision – to mechanise textile production – and by 1782 he had a network of mills across Britain. As the water-powered machinery, though not yet fully mechanised, became more complex, Kay began to use steam engines for power. The first power-loom, however, which was invented in 1785 by Dr Edmund Cartwright, really did mechanise the weaving stage of textile manufacture.

The pace of growth quickened with the expansion of Britain’s influence in the world and the acquisition of colonies from which cheap raw materials could be imported. For example, in a single decade, from 1781 to 1791, imports of cotton into Britain quadrupled, going on to reach 100 million pounds in weight in 1815 and 263 million in 1830.The increase in exports is equally impressive; in 1751 £46,000 worth of cloth was exported and by the end of the century this had risen to £5.4 million. By the end of the 19 th century the figure had soared to close on £50 million. Britain was now supplying cheaper and better quality clothing to a global market. Yet during the course of the 20 th century Britain lost its position as a major textile manufacturer.

So what happened? There are a number of views on this question, not all of them conflicting, and where there is disagreement it is usually about when the decline began. Whether it began before the First World War (1914-18), or during the inter-war years (1919—1939), or after 1945, most economists would give roughly the same reasons. To start with, there was competition from abroad, especially from developing countries in the Far East, notably Japan . It was thought by manufacturers that the best way to combat this increased competition was to modernise. However, management and the labour unions were unable to agree on how to handle this situation.

Modernisation would mean people losing their jobs and possibly a change in labour practices. Such changes as were made served only to slow down the industry’s decline rather than help regain its predominant position. Economically less developed countries, on the other hand, had the advantage of being able to provide low wage competition , without the problem of powerful labour unions.

There are, of course, many other reasons for the textile industry’s decline, two of which became particularly noticeable in the late twentieth century and are related. The first is out­sourcing, when manufacturers establish factories in countries where there is cheap labour. This obviously leads to less demand for locally-produced goods. Related to this, the textile and clothing industries have acquired a bad reputation for exploiting workers, often illegal immigrants, in sweatshops where they are forced to work long hours and are paid far less than the minimum wage.

We seem to be back with Crotchet and Sorocold and their first live-in factory. The globalising trend of out-sourcing, however, was a rational response to the growing competition from overseas, which, it goes without saying, does not excuse the exploitation of workers. The British industry itself, while no longer holding a key place in the global textile market has adapted itself and now concentrates more on the world of fashion and design, where it seems to be doing quite well.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('226569a7-e8d0-5eb9-a547-872f07683bf0', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 1, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Complete the notes below.
Write
NO MORE THAN THREE WORDS
for each answer.
Textile Manufacture
Early history
Begins as a cottage industry
Products hand-woven and made for
1
Locate
Local producers face
2
Locate
from overseas
Ways found to deal with situation
Imported fabrics
3
Locate
, mixed cottons produced
Early technology
Machine production needed to
4
Locate
for cotton fabrics
Improved technology (such as the fly-shuttle) more
5
Locate
and productive
Machinery begins to be powered by
6
Locate

Products hand-woven and made for 1 ____ Locate$md$, NULL, ARRAY['.*local.*consumption.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9ba7f1f4-88a8-59b0-8067-92e2201e87fd', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 2, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Complete the notes below.
Write
NO MORE THAN THREE WORDS
for each answer.
Textile Manufacture
Early history
Begins as a cottage industry
Products hand-woven and made for
1
Locate
Local producers face
2
Locate
from overseas
Ways found to deal with situation
Imported fabrics
3
Locate
, mixed cottons produced
Early technology
Machine production needed to
4
Locate
for cotton fabrics
Improved technology (such as the fly-shuttle) more
5
Locate
and productive
Machinery begins to be powered by
6
Locate

Local producers face 2 ____ Locate from overseas$md$, NULL, ARRAY['.*competition.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6dd3361a-8a24-5a83-8553-814ecb9b9cc0', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 3, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Complete the notes below.
Write
NO MORE THAN THREE WORDS
for each answer.
Textile Manufacture
Early history
Begins as a cottage industry
Products hand-woven and made for
1
Locate
Local producers face
2
Locate
from overseas
Ways found to deal with situation
Imported fabrics
3
Locate
, mixed cottons produced
Early technology
Machine production needed to
4
Locate
for cotton fabrics
Improved technology (such as the fly-shuttle) more
5
Locate
and productive
Machinery begins to be powered by
6
Locate

Imported fabrics 3 ____ Locate , mixed cottons produced$md$, NULL, ARRAY['.*banned.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2588e49c-7ca4-5159-b947-3c3113e5dba1', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 4, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Complete the notes below.
Write
NO MORE THAN THREE WORDS
for each answer.
Textile Manufacture
Early history
Begins as a cottage industry
Products hand-woven and made for
1
Locate
Local producers face
2
Locate
from overseas
Ways found to deal with situation
Imported fabrics
3
Locate
, mixed cottons produced
Early technology
Machine production needed to
4
Locate
for cotton fabrics
Improved technology (such as the fly-shuttle) more
5
Locate
and productive
Machinery begins to be powered by
6
Locate

Machine production needed to 4 ____ Locate for cotton fabrics$md$, NULL, ARRAY['.*meet.*the.*demand.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c60b6106-9830-541e-a7aa-42c137b1dcea', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 5, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Complete the notes below.
Write
NO MORE THAN THREE WORDS
for each answer.
Textile Manufacture
Early history
Begins as a cottage industry
Products hand-woven and made for
1
Locate
Local producers face
2
Locate
from overseas
Ways found to deal with situation
Imported fabrics
3
Locate
, mixed cottons produced
Early technology
Machine production needed to
4
Locate
for cotton fabrics
Improved technology (such as the fly-shuttle) more
5
Locate
and productive
Machinery begins to be powered by
6
Locate

Improved technology (such as the fly-shuttle) more 5 ____ Locate and productive$md$, NULL, ARRAY['.*efficient.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b384b25c-7ec1-5c4e-9f67-155da27f417b', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Complete the notes below.
Write
NO MORE THAN THREE WORDS
for each answer.
Textile Manufacture
Early history
Begins as a cottage industry
Products hand-woven and made for
1
Locate
Local producers face
2
Locate
from overseas
Ways found to deal with situation
Imported fabrics
3
Locate
, mixed cottons produced
Early technology
Machine production needed to
4
Locate
for cotton fabrics
Improved technology (such as the fly-shuttle) more
5
Locate
and productive
Machinery begins to be powered by
6
Locate

Machinery begins to be powered by 6 ____ Locate$md$, NULL, ARRAY['.*steam.*engines.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae2ad3db-46f1-51d2-b355-1710dfcc4c9a', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Choose the correct letter,
A
,
B
,
C
or
D
.
7.
Which of the following innovations increased productivity by 800%?
A
the power-loom
B
the steam engine
C
the spinning jenny
D
the fly-shuttle
Locate
8.
During which period was the British textile industry at its peak?
A
1733-1785
B
1781-1791
C
1791-1830
D
1830-1900
Locate
9.
Which of the following was a major cause of the British textile industry’s decline?
A
the expansion of foreign textile industries
B
the loss of overseas markets
C
there being no demand for products
D
labour becoming too expensive 9##qa

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fb37b963-20de-50d6-a313-b6c105173c9b', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Choose the correct letter,
A
,
B
,
C
or
D
.
7.
Which of the following innovations increased productivity by 800%?
A
the power-loom
B
the steam engine
C
the spinning jenny
D
the fly-shuttle
Locate
8.
During which period was the British textile industry at its peak?
A
1733-1785
B
1781-1791
C
1791-1830
D
1830-1900
Locate
9.
Which of the following was a major cause of the British textile industry’s decline?
A
the expansion of foreign textile industries
B
the loss of overseas markets
C
there being no demand for products
D
labour becoming too expensive 9##qa

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c0a5ec31-01cf-5971-817d-2db5617ff6c1', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Choose the correct letter,
A
,
B
,
C
or
D
.
7.
Which of the following innovations increased productivity by 800%?
A
the power-loom
B
the steam engine
C
the spinning jenny
D
the fly-shuttle
Locate
8.
During which period was the British textile industry at its peak?
A
1733-1785
B
1781-1791
C
1791-1830
D
1830-1900
Locate
9.
Which of the following was a major cause of the British textile industry’s decline?
A
the expansion of foreign textile industries
B
the loss of overseas markets
C
there being no demand for products
D
labour becoming too expensive 9##qa

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('86880832-8d2f-5531-8b86-87490632d67a', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Foreign textiles were banned because of their inferior quality.
Locate
11
Richard Arkwright built the first fully-mechanised textile mill.
12
In less developed countries, the industry could rely on cheap labour.
Locate
13
Out-sourcing was one method used to compete with foreign manufacturers.
Locate

10 ____ Foreign textiles were banned because of their inferior quality. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a48e3844-87e6-5792-b22a-9343946c77ad', '86880832-8d2f-5531-8b86-87490632d67a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c69c61a1-ac2f-519f-8979-8e882101dac1', '86880832-8d2f-5531-8b86-87490632d67a', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f9954a7-7996-50dd-a977-8b024b40c5aa', '86880832-8d2f-5531-8b86-87490632d67a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bbd0fb3b-fc97-55c6-b6ba-772d41bfc043', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Foreign textiles were banned because of their inferior quality.
Locate
11
Richard Arkwright built the first fully-mechanised textile mill.
12
In less developed countries, the industry could rely on cheap labour.
Locate
13
Out-sourcing was one method used to compete with foreign manufacturers.
Locate

11 ____ Richard Arkwright built the first fully-mechanised textile mill.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec32f759-3e4a-5d77-9ac1-d9b821b3ae9d', 'bbd0fb3b-fc97-55c6-b6ba-772d41bfc043', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b97560b2-0e28-56ac-96fe-9d2fbec11662', 'bbd0fb3b-fc97-55c6-b6ba-772d41bfc043', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a681859d-9519-5223-8e9f-002ac7b2ae67', 'bbd0fb3b-fc97-55c6-b6ba-772d41bfc043', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('07daf475-e32b-56fe-98f3-d6647a42d2f6', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Foreign textiles were banned because of their inferior quality.
Locate
11
Richard Arkwright built the first fully-mechanised textile mill.
12
In less developed countries, the industry could rely on cheap labour.
Locate
13
Out-sourcing was one method used to compete with foreign manufacturers.
Locate

12 ____ In less developed countries, the industry could rely on cheap labour. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44d8012d-fbd5-5c4a-b282-08a424145fd4', '07daf475-e32b-56fe-98f3-d6647a42d2f6', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39a060b7-4475-51ca-b84d-1090cef5cd62', '07daf475-e32b-56fe-98f3-d6647a42d2f6', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92df1644-c2f9-5854-b102-335c5033e009', '07daf475-e32b-56fe-98f3-d6647a42d2f6', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('91d1af63-c88f-5b67-b2e1-578337a08922', 'c022f343-2a95-5f1e-ad0f-fdc0dfa7cf42', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Foreign textiles were banned because of their inferior quality.
Locate
11
Richard Arkwright built the first fully-mechanised textile mill.
12
In less developed countries, the industry could rely on cheap labour.
Locate
13
Out-sourcing was one method used to compete with foreign manufacturers.
Locate

13 ____ Out-sourcing was one method used to compete with foreign manufacturers. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb051f6c-993f-5ec3-88d1-bc4ce2e0a1bb', '91d1af63-c88f-5b67-b2e1-578337a08922', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('305d7e48-1eda-588f-a688-b5243ea830a9', '91d1af63-c88f-5b67-b2e1-578337a08922', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06ae36ce-8cc3-5ef3-ab7c-d98186875b35', '91d1af63-c88f-5b67-b2e1-578337a08922', 3, $md$NOT GIVEN$md$, false);

COMMIT;
