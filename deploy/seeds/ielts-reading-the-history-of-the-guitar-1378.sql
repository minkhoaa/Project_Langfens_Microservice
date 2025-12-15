BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-history-of-the-guitar-1378'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-the-guitar-1378';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-the-guitar-1378';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-history-of-the-guitar-1378';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('5f29141d-e83c-5e57-805b-fd1032f888c9', 'ielts-reading-the-history-of-the-guitar-1378', $t$The history of the guitar$t$, $md$## The history of the guitar

Nguồn:
- Test: https://mini-ielts.com/1378/reading/the-history-of-the-guitar
- Solution: https://mini-ielts.com/1378/view-solution/reading/the-history-of-the-guitar$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('0e5d876d-5205-56c9-88a6-22ac86e882eb', '5f29141d-e83c-5e57-805b-fd1032f888c9', 1, $t$Reading — The history of the guitar$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The history of the guitar

The word 'guitar' was brought into English as an adaptation of the Spanish word 'guitarra', which was, in turn, derived from the Greek 'kithara'. Tracing the roots of the word further back into linguistic history, it seems to have been a combination of the Indo-European stem 'guit-', meaning music, and the root ’-tar’, meaning chord or string. The root '-tar' is actually common to a number of languages, and can also be found in the word ’sitar', also a stringed musical instrument. Although the spelling and pronunciation differ between languages, these key elements have been present in most words for 'guitar' throughout history.

While the guitar may have gained most of its popularity as a musical instrument during the modern era, guitar-like instruments have been in existence in numerous cultures throughout the world for more than 5,000 years. The earliest instruments that the modern eye and ear would recognise as a 'normal' acoustic guitar date from about 500 years ago. Prior to this time, stringed instruments were in use throughout the world, but these early instruments are known primarily from visual depictions, not from the continued existence of music written for them. The majority of these depictions show simple stringed instruments, often lacking some of the parts that define a modern guitar. A number of these instruments have more in common with the lute than the guitar.

There is some uncertainty about the exact date of the earliest six-string guitar. The oldest one still in existence, which was made by Gaetano Vinaccia, is dated 1779. However, the authenticity of six-string guitars alleged to have been made prior to 1790 is often suspect, as many fakes have been discovered dating to this era. The early nineteenth century is generally accepted as the time period during which six-string guitars began taking on their modern shape and dimensions. Thus for nearly two hundred years, luthiers, or guitar makers, have been producing versions of the modern acoustic guitar.

The first electric guitar was not developed until the early twentieth century. George Beauchamp received the first patent for an electric guitar in 1936, and Beauchamp went on to co-found Rickenbacker, originally known as the Electro String Instrument Company. Although Rickenbacker began producing electric guitars in the late 1930s, this brand received most of its fame in the 1960s, when John Lennon used a Rickenbacker guitar for the Beatles' debut performance on the Ed Sullivan show in 1964. George Harrison later bought a Rickenbacker guitar of his own, and the company later gave him one of their earliest 12-string electric guitars. Paul McCartney also used a Rickenbacker bass guitar for recording. The Beatles continued to use Rickenbacker guitars throughout their career, and made the instruments highly popular among other musicians of the era.

The Fender Musical Instruments Company and the Gibson Guitar Corporation were two other early electric guitar pioneers, both developing models in the early 1950s. Fender began with the Telecaster in 1950 and 1951, and the Fender Stratocaster debuted in 1954. Gibson began selling the Gibson Les Paul, based partially on assistance from jazz musician and guitar innovator Les Paul, in 1952. The majority of present day solid-body electric guitars are still based largely on these three early electric guitar designs.

Throughout the history of the guitar, an enormous number of individuals have made their mark on the way in which the instrument was built, played and perceived. Though some of these individuals are particularly well known, like the Beatles or Les Paul, the majority of these people are virtually invisible to most modern guitar fans. By looking at the entire history of the guitar, rather than just recent developments, largely confined to electric guitars, it is possible to see more of the contributions of earlier generations.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d0edb30f-57d9-5d98-b2c2-10c6b45827c3', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 1, 'SHORT_ANSWER', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Choose
NO
MORE THAN THREE WORDS
from the passage for each answer.
1 Despite differences in
1
, ‘guit-‘ and ‘
2 Instruments that we would call acoustic guitars have been made and played for approximately
2
3 No one knows the
3
when the first six-string guitar was made.
4 The
4
of acoustic guitars have not changed much in 200 years.
5 A
5
for an electric guitar was issued in the mid-1930s.
6 Les Paul, the well-known
6
guitarist, was involved in the development of the electric guitar.
7 Most
7
of the guitar know little about its rich history.

1 Despite differences in 1 ____ , ‘guit-‘ and ‘$md$, NULL, ARRAY['.*spelling.*and.*pronunciation.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ad82df90-82ab-5738-96e1-3f0f7cd66b66', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 2, 'SHORT_ANSWER', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Choose
NO
MORE THAN THREE WORDS
from the passage for each answer.
1 Despite differences in
1
, ‘guit-‘ and ‘
2 Instruments that we would call acoustic guitars have been made and played for approximately
2
3 No one knows the
3
when the first six-string guitar was made.
4 The
4
of acoustic guitars have not changed much in 200 years.
5 A
5
for an electric guitar was issued in the mid-1930s.
6 Les Paul, the well-known
6
guitarist, was involved in the development of the electric guitar.
7 Most
7
of the guitar know little about its rich history.

2 Instruments that we would call acoustic guitars have been made and played for approximately 2 ____$md$, NULL, ARRAY['.*five.*hundred.*years.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4c38ab18-a92a-5778-a1bb-a02ba2f7e94f', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 3, 'SHORT_ANSWER', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Choose
NO
MORE THAN THREE WORDS
from the passage for each answer.
1 Despite differences in
1
, ‘guit-‘ and ‘
2 Instruments that we would call acoustic guitars have been made and played for approximately
2
3 No one knows the
3
when the first six-string guitar was made.
4 The
4
of acoustic guitars have not changed much in 200 years.
5 A
5
for an electric guitar was issued in the mid-1930s.
6 Les Paul, the well-known
6
guitarist, was involved in the development of the electric guitar.
7 Most
7
of the guitar know little about its rich history.

3 No one knows the 3 ____ when the first six-string guitar was made.$md$, NULL, ARRAY['.*exact.*date.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('effdf1d7-5564-59a6-bca6-d40f8f50ca57', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 4, 'SHORT_ANSWER', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Choose
NO
MORE THAN THREE WORDS
from the passage for each answer.
1 Despite differences in
1
, ‘guit-‘ and ‘
2 Instruments that we would call acoustic guitars have been made and played for approximately
2
3 No one knows the
3
when the first six-string guitar was made.
4 The
4
of acoustic guitars have not changed much in 200 years.
5 A
5
for an electric guitar was issued in the mid-1930s.
6 Les Paul, the well-known
6
guitarist, was involved in the development of the electric guitar.
7 Most
7
of the guitar know little about its rich history.

4 The 4 ____ of acoustic guitars have not changed much in 200 years.$md$, NULL, ARRAY['.*shape.*and.*dimensions.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('87bea6bf-9018-525c-81dc-2c624fea8188', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 5, 'SHORT_ANSWER', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Choose
NO
MORE THAN THREE WORDS
from the passage for each answer.
1 Despite differences in
1
, ‘guit-‘ and ‘
2 Instruments that we would call acoustic guitars have been made and played for approximately
2
3 No one knows the
3
when the first six-string guitar was made.
4 The
4
of acoustic guitars have not changed much in 200 years.
5 A
5
for an electric guitar was issued in the mid-1930s.
6 Les Paul, the well-known
6
guitarist, was involved in the development of the electric guitar.
7 Most
7
of the guitar know little about its rich history.

5 A 5 ____ for an electric guitar was issued in the mid-1930s.$md$, NULL, ARRAY['.*patent.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('24ca07f0-6ae0-5f52-8517-36ab349282dd', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Choose
NO
MORE THAN THREE WORDS
from the passage for each answer.
1 Despite differences in
1
, ‘guit-‘ and ‘
2 Instruments that we would call acoustic guitars have been made and played for approximately
2
3 No one knows the
3
when the first six-string guitar was made.
4 The
4
of acoustic guitars have not changed much in 200 years.
5 A
5
for an electric guitar was issued in the mid-1930s.
6 Les Paul, the well-known
6
guitarist, was involved in the development of the electric guitar.
7 Most
7
of the guitar know little about its rich history.

6 Les Paul, the well-known 6 ____ guitarist, was involved in the development of the electric guitar.$md$, NULL, ARRAY['.*jazz.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('92923711-797d-5e42-8ae5-42727549901d', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Choose
NO
MORE THAN THREE WORDS
from the passage for each answer.
1 Despite differences in
1
, ‘guit-‘ and ‘
2 Instruments that we would call acoustic guitars have been made and played for approximately
2
3 No one knows the
3
when the first six-string guitar was made.
4 The
4
of acoustic guitars have not changed much in 200 years.
5 A
5
for an electric guitar was issued in the mid-1930s.
6 Les Paul, the well-known
6
guitarist, was involved in the development of the electric guitar.
7 Most
7
of the guitar know little about its rich history.

7 Most 7 ____ of the guitar know little about its rich history.$md$, NULL, ARRAY['.*fans.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b13e31ce-84bd-563f-be04-ae6aa70edb94', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8–13
Questions 8–13
Complete the summary.
Choose
NO
MOR
E
THAN
T
WO WORDS
from the passage for each answer.
Instruments similar to the guitar have been played by musicians for over
8
years. What we know about many of these instruments comes from
9
rather than actual physical examples or music played on them. In some ways, these early stringed instruments were closer to
10
than the guitar as we know it today. We do have examples of six-string guitars that are 200 years old. However, the
11
of six -string guitars made by guitar makers (who are also known as
12
) before the final decade of the eighteenth century is often open to question.
Although the electric guitar was invented in the 1930s, it took several decades for electric guitars to develop, with the company Rickenbacker playing a major part in this development. Most
13
electric guitars in use today are similar in design to guitars produced by the Fender Musical Instruments Company and the Gibson Guitar Corporation in the 1950s.

Instruments similar to the guitar have been played by musicians for over 8 ____ years. What we know about many of these instruments comes from 9 ____ rather than actual physical examples or music played on them. In some ways, these early stringed instruments were closer to 10 ____ than the guitar as we know it today. We do have examples of six-string guitars that are 200 years old. However, the 11 ____ of six -string guitars made by guitar makers (who are also known as 12 ____ ) before the final decade of the eighteenth century is often open to question.$md$, NULL, ARRAY['.*five.*thousand.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('51b875c2-2eb0-535e-9b0c-de62e9905cae', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8–13
Questions 8–13
Complete the summary.
Choose
NO
MOR
E
THAN
T
WO WORDS
from the passage for each answer.
Instruments similar to the guitar have been played by musicians for over
8
years. What we know about many of these instruments comes from
9
rather than actual physical examples or music played on them. In some ways, these early stringed instruments were closer to
10
than the guitar as we know it today. We do have examples of six-string guitars that are 200 years old. However, the
11
of six -string guitars made by guitar makers (who are also known as
12
) before the final decade of the eighteenth century is often open to question.
Although the electric guitar was invented in the 1930s, it took several decades for electric guitars to develop, with the company Rickenbacker playing a major part in this development. Most
13
electric guitars in use today are similar in design to guitars produced by the Fender Musical Instruments Company and the Gibson Guitar Corporation in the 1950s.

Instruments similar to the guitar have been played by musicians for over 8 ____ years. What we know about many of these instruments comes from 9 ____ rather than actual physical examples or music played on them. In some ways, these early stringed instruments were closer to 10 ____ than the guitar as we know it today. We do have examples of six-string guitars that are 200 years old. However, the 11 ____ of six -string guitars made by guitar makers (who are also known as 12 ____ ) before the final decade of the eighteenth century is often open to question.$md$, NULL, ARRAY['.*five.*thousand.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('65b80f21-6f5f-5200-a40b-ee91304641f5', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8–13
Questions 8–13
Complete the summary.
Choose
NO
MOR
E
THAN
T
WO WORDS
from the passage for each answer.
Instruments similar to the guitar have been played by musicians for over
8
years. What we know about many of these instruments comes from
9
rather than actual physical examples or music played on them. In some ways, these early stringed instruments were closer to
10
than the guitar as we know it today. We do have examples of six-string guitars that are 200 years old. However, the
11
of six -string guitars made by guitar makers (who are also known as
12
) before the final decade of the eighteenth century is often open to question.
Although the electric guitar was invented in the 1930s, it took several decades for electric guitars to develop, with the company Rickenbacker playing a major part in this development. Most
13
electric guitars in use today are similar in design to guitars produced by the Fender Musical Instruments Company and the Gibson Guitar Corporation in the 1950s.

Instruments similar to the guitar have been played by musicians for over 8 ____ years. What we know about many of these instruments comes from 9 ____ rather than actual physical examples or music played on them. In some ways, these early stringed instruments were closer to 10 ____ than the guitar as we know it today. We do have examples of six-string guitars that are 200 years old. However, the 11 ____ of six -string guitars made by guitar makers (who are also known as 12 ____ ) before the final decade of the eighteenth century is often open to question.$md$, NULL, ARRAY['.*five.*thousand.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f37c82ea-997f-52de-a160-bb88df42c1cf', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8–13
Questions 8–13
Complete the summary.
Choose
NO
MOR
E
THAN
T
WO WORDS
from the passage for each answer.
Instruments similar to the guitar have been played by musicians for over
8
years. What we know about many of these instruments comes from
9
rather than actual physical examples or music played on them. In some ways, these early stringed instruments were closer to
10
than the guitar as we know it today. We do have examples of six-string guitars that are 200 years old. However, the
11
of six -string guitars made by guitar makers (who are also known as
12
) before the final decade of the eighteenth century is often open to question.
Although the electric guitar was invented in the 1930s, it took several decades for electric guitars to develop, with the company Rickenbacker playing a major part in this development. Most
13
electric guitars in use today are similar in design to guitars produced by the Fender Musical Instruments Company and the Gibson Guitar Corporation in the 1950s.

Instruments similar to the guitar have been played by musicians for over 8 ____ years. What we know about many of these instruments comes from 9 ____ rather than actual physical examples or music played on them. In some ways, these early stringed instruments were closer to 10 ____ than the guitar as we know it today. We do have examples of six-string guitars that are 200 years old. However, the 11 ____ of six -string guitars made by guitar makers (who are also known as 12 ____ ) before the final decade of the eighteenth century is often open to question.$md$, NULL, ARRAY['.*five.*thousand.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('543a01b9-7b6a-559a-a418-029e4f1d3aa4', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 8–13
Questions 8–13
Complete the summary.
Choose
NO
MOR
E
THAN
T
WO WORDS
from the passage for each answer.
Instruments similar to the guitar have been played by musicians for over
8
years. What we know about many of these instruments comes from
9
rather than actual physical examples or music played on them. In some ways, these early stringed instruments were closer to
10
than the guitar as we know it today. We do have examples of six-string guitars that are 200 years old. However, the
11
of six -string guitars made by guitar makers (who are also known as
12
) before the final decade of the eighteenth century is often open to question.
Although the electric guitar was invented in the 1930s, it took several decades for electric guitars to develop, with the company Rickenbacker playing a major part in this development. Most
13
electric guitars in use today are similar in design to guitars produced by the Fender Musical Instruments Company and the Gibson Guitar Corporation in the 1950s.

Instruments similar to the guitar have been played by musicians for over 8 ____ years. What we know about many of these instruments comes from 9 ____ rather than actual physical examples or music played on them. In some ways, these early stringed instruments were closer to 10 ____ than the guitar as we know it today. We do have examples of six-string guitars that are 200 years old. However, the 11 ____ of six -string guitars made by guitar makers (who are also known as 12 ____ ) before the final decade of the eighteenth century is often open to question.$md$, NULL, ARRAY['.*five.*thousand.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('60676088-0dc1-5ac4-b7e9-d136b8f7eac3', '0e5d876d-5205-56c9-88a6-22ac86e882eb', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 8–13
Questions 8–13
Complete the summary.
Choose
NO
MOR
E
THAN
T
WO WORDS
from the passage for each answer.
Instruments similar to the guitar have been played by musicians for over
8
years. What we know about many of these instruments comes from
9
rather than actual physical examples or music played on them. In some ways, these early stringed instruments were closer to
10
than the guitar as we know it today. We do have examples of six-string guitars that are 200 years old. However, the
11
of six -string guitars made by guitar makers (who are also known as
12
) before the final decade of the eighteenth century is often open to question.
Although the electric guitar was invented in the 1930s, it took several decades for electric guitars to develop, with the company Rickenbacker playing a major part in this development. Most
13
electric guitars in use today are similar in design to guitars produced by the Fender Musical Instruments Company and the Gibson Guitar Corporation in the 1950s.

Although the electric guitar was invented in the 1930s, it took several decades for electric guitars to develop, with the company Rickenbacker playing a major part in this development. Most 13 ____ electric guitars in use today are similar in design to guitars produced by the Fender Musical Instruments Company and the Gibson Guitar Corporation in the 1950s.$md$, NULL, ARRAY['.*solid.*body.*']);

COMMIT;
