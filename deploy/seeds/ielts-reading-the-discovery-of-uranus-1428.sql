BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-discovery-of-uranus-1428'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-discovery-of-uranus-1428';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-discovery-of-uranus-1428';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-discovery-of-uranus-1428';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('05e886e7-b582-5b70-b069-023e9f5605b4', 'ielts-reading-the-discovery-of-uranus-1428', $t$The Discovery of Uranus$t$, $md$## The Discovery of Uranus

Nguồn:
- Test: https://mini-ielts.com/1428/reading/the-discovery-of-uranus
- Solution: https://mini-ielts.com/1428/view-solution/reading/the-discovery-of-uranus$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', '05e886e7-b582-5b70-b069-023e9f5605b4', 1, $t$Reading — The Discovery of Uranus$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Discovery of Uranus

Someone once put forward an attractive though unlikely theory. Throughout the Earth’s annual revolution around the sun, there is one point of space always hidden from our eyes. This point is the opposite part of the Earth’s orbit, which is always hidden by the sun. Could there be another planet there, essentially similar to our own, but always invisible?

If a space probe today sent back evidence that such a world existed it would cause not much more sensation than Sir William Herschel’s discovery of a new planet, Uranus, in 1781. Herschel was an extraordinary man — no other astronomer has ever covered so vast a field of work — and his career deserves study. He was born in Hanover in Germany in 1738, left the German army in 1757, and arrived in England the same year with no money but quite exceptional music ability. He played the violin and oboe and at one time was organist in the Octagon Chapel in the city of Bath. Herschel’s was an active mind, and deep inside he was conscious that music was not his destiny; he therefore, read widely in science and the arts, but not until 1772 did he come across a book on astronomy. He was then 34, middle-aged by the standards of the time, but without hesitation he embarked on his new career, financing it by his professional work as a musician. He spent years mastering the art of telescope construction, and even by present-day standards his instruments are comparable with the best.

Serious observation began 1774. He set himself the astonishing task of ‘reviewing the heavens’, in other words, pointing his telescope to every accessible part of the sky and recording what he saw. The first review was made in 1775; the second, and most momentous, in 1780-81. It was during the latter part of this that he discovered Uranus. Afterwards, supported by the royal grant in recognition of his work, he was able to devote himself entirely to astronomy. His final achievements spread from the sun and moon to remote galaxies (of which he discovered hundreds), and papers flooded from his pen until his death in 1822. Among these, there was one sent to the Royal Society in 1781, entitled An Account of a Comet. In his own words:

On Tuesday the 13th of March, between ten and eleven in the evening, while I was examining the small stars in the neighbourhood of H Geminorum, I perceived one that appeared visibly larger than the rest; being struck with its uncommon magnitude, I compared it to H Geminorum and the small star in the quartile between Auriga and Gemini, and finding it to be much larger than either of them, suspected it to be a comet.

Herschel’s care was the hallmark of a great observer; he was not prepared to jump any conclusions. Also, to be fair, the discovery of a new planet was the last thought in anybody’s mind. But further observation by other astronomers besides Herschel revealed two curious facts. For the comet, it showed a remarkably sharp disc; furthermore, it was moving so slowly that it was thought to be a great distance from the sun, and comets are only normally visible in the immediate vicinity of the sun. As its orbit came to be worked out the truth dawned that it was a new planet far beyond Saturn’s realm, and that the ‘reviewer of the heavens’ had stumbled across an unprecedented prize. Herschel wanted to call it georgium sidus (Star of George) in honour of his royal patron King George III of Great Britain. The planet was later for a time called Herschel in honour of its discoverer. The name Uranus, which was first proposed by the German astronomer Johann Elert Bode, was in use by the late 19th century.

Uranus is a giant in construction, but not so much in size; its diameter compares unfavourably with that of Jupiter and Saturn, though on the terrestrial scale it is still colossal. Uranus’ atmosphere consists largely of hydrogen and helium, with a trace of methane. Through a telescope the planet appears as a small bluish-green disc with a faint green periphery. In 1977, while recording the occultation 1 of a star behind the planet, the American astronomer James L. Elliot discovered the presence of five rings encircling the equator of Uranus. Four more rings were discovered in January 1986 during the exploratory flight of Voyager 2 2 , In addition to its rings, Uranus has 15 satellites (‘moons’), the last 10 discovered by Voyager 2 on the same flight; all revolve about its equator and move with the planet in an east—west direction. The two largest moons, Titania and Oberon, were discovered by Herschel in 1787. The next two, Umbriel and Ariel, were found in 1851 by the British astronomer William Lassell. Miranda, thought before 1986 to be the innermost moon, was discovered in 1948 by the American astronomer Gerard Peter Kuiper.

Glossary: ‘O ccultation ‘ : in astronomy, when one object passes in front of another and hides the second from view, especially, for example, when the moon comes between an observer and a star or planet . ‘ Voyager 2 ‘ : an unmanned spacecraft sent on a voyage past Saturn, Uranus and Jupiter in 1986; during which it sent back information about these planets to scientists on earth .$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c567f299-8802-5b90-a1fb-c2947086fe42', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 1, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
omplete the table below. Write a date for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Event
Date
Example
William Herschel was born
Answer
1738
Herschel began investigating astronomy
1
Discovery of the planet Uranus
2
Discovery of the moons Titania and Oberon
3
First discovery of Uranus’ rings
4
Discovery of the last 10 moons of Uranus
5

1 ____$md$, NULL, ARRAY['.*1772.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ad979176-e51e-57aa-96ed-f25553be635b', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 2, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
omplete the table below. Write a date for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Event
Date
Example
William Herschel was born
Answer
1738
Herschel began investigating astronomy
1
Discovery of the planet Uranus
2
Discovery of the moons Titania and Oberon
3
First discovery of Uranus’ rings
4
Discovery of the last 10 moons of Uranus
5

2 ____$md$, NULL, ARRAY['.*1781.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bae5ed1e-a351-5c72-ac04-c1aeb1a8963d', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 3, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
omplete the table below. Write a date for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Event
Date
Example
William Herschel was born
Answer
1738
Herschel began investigating astronomy
1
Discovery of the planet Uranus
2
Discovery of the moons Titania and Oberon
3
First discovery of Uranus’ rings
4
Discovery of the last 10 moons of Uranus
5

3 ____$md$, NULL, ARRAY['.*1787.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b2c6dc51-13bf-5c26-b51a-22d09f0f4de0', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 4, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
omplete the table below. Write a date for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Event
Date
Example
William Herschel was born
Answer
1738
Herschel began investigating astronomy
1
Discovery of the planet Uranus
2
Discovery of the moons Titania and Oberon
3
First discovery of Uranus’ rings
4
Discovery of the last 10 moons of Uranus
5

4 ____$md$, NULL, ARRAY['.*1977.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('41319e39-f8c6-5d87-8d37-546bf835e720', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 5, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
omplete the table below. Write a date for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Event
Date
Example
William Herschel was born
Answer
1738
Herschel began investigating astronomy
1
Discovery of the planet Uranus
2
Discovery of the moons Titania and Oberon
3
First discovery of Uranus’ rings
4
Discovery of the last 10 moons of Uranus
5

5 ____$md$, NULL, ARRAY['.*1986.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('83e072e3-1ed1-52c8-adcb-0b94ed092368', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Do the following statements reflect the claims of the writer of the Reading Passage?
In boxes 6-10 on your answer sheet write
YES
if the statement reflects the claims of the writer
NO
if the statement contradicts the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
Example Answer
Herschel was multi-talented
YES
6
It is improbable that there is a planet hidden behind the sun.
7
Herschel knew immediately that he had found a new planet.
8
Herschel collaborated with other astronomers of his time.
9
Herschel’s newly-discovered object was considered to be too far from the sun to be a comet.
10
Herschel’s discovery was the most important find of the last three hundred years.

6 ____ It is improbable that there is a planet hidden behind the sun. 7 ____ Herschel knew immediately that he had found a new planet. 8 ____ Herschel collaborated with other astronomers of his time. 9 ____ Herschel’s newly-discovered object was considered to be too far from the sun to be a comet. 10 ____ Herschel’s discovery was the most important find of the last three hundred years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93dc91d0-3e12-5a7a-9da5-e399c8dbb1a4', '83e072e3-1ed1-52c8-adcb-0b94ed092368', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d47fcc7-c527-5952-ae9b-f9b1f3115f0a', '83e072e3-1ed1-52c8-adcb-0b94ed092368', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37a7a1bb-63e7-5a85-805c-d7ebad58ea0d', '83e072e3-1ed1-52c8-adcb-0b94ed092368', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2f7f5f13-ca90-52c8-8bf6-7ef05035d385', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Do the following statements reflect the claims of the writer of the Reading Passage?
In boxes 6-10 on your answer sheet write
YES
if the statement reflects the claims of the writer
NO
if the statement contradicts the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
Example Answer
Herschel was multi-talented
YES
6
It is improbable that there is a planet hidden behind the sun.
7
Herschel knew immediately that he had found a new planet.
8
Herschel collaborated with other astronomers of his time.
9
Herschel’s newly-discovered object was considered to be too far from the sun to be a comet.
10
Herschel’s discovery was the most important find of the last three hundred years.

6 ____ It is improbable that there is a planet hidden behind the sun. 7 ____ Herschel knew immediately that he had found a new planet. 8 ____ Herschel collaborated with other astronomers of his time. 9 ____ Herschel’s newly-discovered object was considered to be too far from the sun to be a comet. 10 ____ Herschel’s discovery was the most important find of the last three hundred years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b15bfaa6-8989-55de-817f-dc7b080bb10b', '2f7f5f13-ca90-52c8-8bf6-7ef05035d385', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98fd554f-9dbf-5075-b9dc-35c94b6f5ad9', '2f7f5f13-ca90-52c8-8bf6-7ef05035d385', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3453d9d2-0960-550d-8e8b-67b710de6ec3', '2f7f5f13-ca90-52c8-8bf6-7ef05035d385', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f2d5248f-0a79-5c3f-917c-6471164af177', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Do the following statements reflect the claims of the writer of the Reading Passage?
In boxes 6-10 on your answer sheet write
YES
if the statement reflects the claims of the writer
NO
if the statement contradicts the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
Example Answer
Herschel was multi-talented
YES
6
It is improbable that there is a planet hidden behind the sun.
7
Herschel knew immediately that he had found a new planet.
8
Herschel collaborated with other astronomers of his time.
9
Herschel’s newly-discovered object was considered to be too far from the sun to be a comet.
10
Herschel’s discovery was the most important find of the last three hundred years.

6 ____ It is improbable that there is a planet hidden behind the sun. 7 ____ Herschel knew immediately that he had found a new planet. 8 ____ Herschel collaborated with other astronomers of his time. 9 ____ Herschel’s newly-discovered object was considered to be too far from the sun to be a comet. 10 ____ Herschel’s discovery was the most important find of the last three hundred years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acaf609b-6461-5d76-b4ad-695f8e33a891', 'f2d5248f-0a79-5c3f-917c-6471164af177', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee6547b8-4bfe-597e-98cf-49c27227a79f', 'f2d5248f-0a79-5c3f-917c-6471164af177', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d83bc81c-645a-5f11-bcb1-1ae58d236970', 'f2d5248f-0a79-5c3f-917c-6471164af177', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('696ad47e-ff70-5a75-b4f4-3cf206fd4f0f', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Do the following statements reflect the claims of the writer of the Reading Passage?
In boxes 6-10 on your answer sheet write
YES
if the statement reflects the claims of the writer
NO
if the statement contradicts the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
Example Answer
Herschel was multi-talented
YES
6
It is improbable that there is a planet hidden behind the sun.
7
Herschel knew immediately that he had found a new planet.
8
Herschel collaborated with other astronomers of his time.
9
Herschel’s newly-discovered object was considered to be too far from the sun to be a comet.
10
Herschel’s discovery was the most important find of the last three hundred years.

6 ____ It is improbable that there is a planet hidden behind the sun. 7 ____ Herschel knew immediately that he had found a new planet. 8 ____ Herschel collaborated with other astronomers of his time. 9 ____ Herschel’s newly-discovered object was considered to be too far from the sun to be a comet. 10 ____ Herschel’s discovery was the most important find of the last three hundred years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf5f0db8-5160-528c-a9cf-dcf622292a4a', '696ad47e-ff70-5a75-b4f4-3cf206fd4f0f', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d054c706-bc0b-51e0-9044-19b21603984b', '696ad47e-ff70-5a75-b4f4-3cf206fd4f0f', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88d5c658-dfd2-5292-bb09-83025f741cd1', '696ad47e-ff70-5a75-b4f4-3cf206fd4f0f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('802392a4-71b5-518d-abec-29a3bf6d7a9e', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Do the following statements reflect the claims of the writer of the Reading Passage?
In boxes 6-10 on your answer sheet write
YES
if the statement reflects the claims of the writer
NO
if the statement contradicts the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
Example Answer
Herschel was multi-talented
YES
6
It is improbable that there is a planet hidden behind the sun.
7
Herschel knew immediately that he had found a new planet.
8
Herschel collaborated with other astronomers of his time.
9
Herschel’s newly-discovered object was considered to be too far from the sun to be a comet.
10
Herschel’s discovery was the most important find of the last three hundred years.

6 ____ It is improbable that there is a planet hidden behind the sun. 7 ____ Herschel knew immediately that he had found a new planet. 8 ____ Herschel collaborated with other astronomers of his time. 9 ____ Herschel’s newly-discovered object was considered to be too far from the sun to be a comet. 10 ____ Herschel’s discovery was the most important find of the last three hundred years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b6ba6ea-10bb-5b2c-8ea0-f19cb30d4e99', '802392a4-71b5-518d-abec-29a3bf6d7a9e', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7d477ad-8958-5d25-92e7-67c307663e30', '802392a4-71b5-518d-abec-29a3bf6d7a9e', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7430fe9b-6e86-581e-a7e3-e220b7bb7a29', '802392a4-71b5-518d-abec-29a3bf6d7a9e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('19ffbeb1-92ff-5c37-b109-d8a6b6a4f530', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete each of the following statements (Questions 11-14) with a name from the Reading Passage.
Write your answers in boxes 11-14 on your answer sheet.
The suggested names of the new planet started with
11
, then
12
, before finally settling on Uranus. The first five rings around Uranus were discovered by
13
. From 1948 until 1986, the moon
14
was believed to be the moon closest to the surface of Uranus.

The suggested names of the new planet started with 11 ____ , then 12 ____ , before finally settling on Uranus. The first five rings around Uranus were discovered by 13 ____ . From 1948 until 1986, the moon 14 ____ was believed to be the moon closest to the surface of Uranus.$md$, NULL, ARRAY['.*georgium.*sidus.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f76eb347-4660-5cd5-b4a0-0f280d0bc1e0', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete each of the following statements (Questions 11-14) with a name from the Reading Passage.
Write your answers in boxes 11-14 on your answer sheet.
The suggested names of the new planet started with
11
, then
12
, before finally settling on Uranus. The first five rings around Uranus were discovered by
13
. From 1948 until 1986, the moon
14
was believed to be the moon closest to the surface of Uranus.

The suggested names of the new planet started with 11 ____ , then 12 ____ , before finally settling on Uranus. The first five rings around Uranus were discovered by 13 ____ . From 1948 until 1986, the moon 14 ____ was believed to be the moon closest to the surface of Uranus.$md$, NULL, ARRAY['.*georgium.*sidus.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('65b65f40-aade-5860-aff3-dc37def4acc8', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete each of the following statements (Questions 11-14) with a name from the Reading Passage.
Write your answers in boxes 11-14 on your answer sheet.
The suggested names of the new planet started with
11
, then
12
, before finally settling on Uranus. The first five rings around Uranus were discovered by
13
. From 1948 until 1986, the moon
14
was believed to be the moon closest to the surface of Uranus.

The suggested names of the new planet started with 11 ____ , then 12 ____ , before finally settling on Uranus. The first five rings around Uranus were discovered by 13 ____ . From 1948 until 1986, the moon 14 ____ was believed to be the moon closest to the surface of Uranus.$md$, NULL, ARRAY['.*georgium.*sidus.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('980d60f1-154e-5d8d-a7ba-a7798994bbd2', '746b5e88-dfa5-5826-aeca-e9aaca7b4ef5', 14, 'SHORT_ANSWER', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete each of the following statements (Questions 11-14) with a name from the Reading Passage.
Write your answers in boxes 11-14 on your answer sheet.
The suggested names of the new planet started with
11
, then
12
, before finally settling on Uranus. The first five rings around Uranus were discovered by
13
. From 1948 until 1986, the moon
14
was believed to be the moon closest to the surface of Uranus.

The suggested names of the new planet started with 11 ____ , then 12 ____ , before finally settling on Uranus. The first five rings around Uranus were discovered by 13 ____ . From 1948 until 1986, the moon 14 ____ was believed to be the moon closest to the surface of Uranus.$md$, NULL, ARRAY['.*georgium.*sidus.*']);

COMMIT;
