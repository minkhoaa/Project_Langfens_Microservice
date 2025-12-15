BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-consecutive-and-simultaneous-translation-1289'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-consecutive-and-simultaneous-translation-1289';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-consecutive-and-simultaneous-translation-1289';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-consecutive-and-simultaneous-translation-1289';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c3340e74-2215-5210-8887-3800cc4ba41d', 'ielts-reading-consecutive-and-simultaneous-translation-1289', $t$Consecutive and Simultaneous Translation$t$, $md$## Consecutive and Simultaneous Translation

Nguồn:
- Test: https://mini-ielts.com/1289/reading/consecutive-and-simultaneous-translation
- Solution: https://mini-ielts.com/1289/view-solution/reading/consecutive-and-simultaneous-translation$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('274818c1-f5a9-5987-8902-1ae9207aa018', 'c3340e74-2215-5210-8887-3800cc4ba41d', 1, $t$Reading — Consecutive and Simultaneous Translation$t$, $md$Read the passage and answer questions **1–9**.

### Passage: Consecutive and Simultaneous Translation

{A} When people are faced with a foreign-language barrier, the usual way around it is to find someone to interpret or translate for them. The term ‘translation’, is the neutral term used for all tasks where the meaning of expressions in one language (the source language) is turned into the meaning of another (the ‘target’ language), whether the medium is spoken, written, or signed. In specific professional contexts, however, a distinction is drawn between people who work with the spoken or signed language (interpreters), and those who work with the written language (translators). There are certain tasks that blur this distinction, as when source speeches turned into target writing. But usually the two roles are seen as quite distinct, and it is unusual to find one person who is equally happy with both occupations. Some writers on translation, indeed, consider the interpreting task to be more suitable for extrovert personalities, and the translating task for introverts.

{B} Interpreting is today widely known from its use in international political life. When senior ministers from different language backgrounds meet, the television record invariably shows a pair of interpreters hovering in the background. At major conferences, such as the United Nations General Assembly, the presence of headphones is a clear indication that a major linguistic exercise is taking place. In everyday circumstances, interpreters are frequently needed, especially in cosmopolitan societies formed by new reiterations of immigrants and Gastarbeiter. Often, the business of law courts, hospitals, local health clinics, classrooms, or industrial tribunals cannot be carried on without the presence of an interpreter. Given the importance and frequency of this task, therefore, it is remarkable that so little study has been made of what actually happens when interpreting takes place, and of how successful an exercise it is.

{C} There are two main kinds of oral translation – consecutive and simultaneous In consecutive translation the translating starts after the original speech or some part of it has been completed. Here the interpreter’s strategy and the final results depend, to a great extent on the length of the segment to be translated. If the segment is just a sentence or two the interpreter closely follows the original speech. As often as not, however, the interpreter is expected to translate a long speech which has lasted for scores of minutes or even longer. In this case he has to remember a great number of messages, and keep them in mind until he begins his translation. To make this possible the interpreter has to take notes of the original messages, various systems of notation having been suggested for the purpose. The study of, and practice in, such notation is the integral part of the interpreter’s training as are special exercises to develop his memory.

{D} Doubtless the recency of developments in the field partly explains this neglect. One procedure, consecutive interpreting, is very old — and presumably dates from the Tower of Babel! Here, the interpreter translates after the speaker has finished speaking. This approach is widely practiced in informal situations, as well as in committees and small conferences. In larger and more formal settings, however, it has been generally replaced by simultaneous interpreting — a recent development that arose from the availability of modern audiological equipment and the advent of increased international interaction following the Second World War.

{E} Of the two procedures, it is the second that has attracted most interest, because of the complexity of the task and the remarkable skills required. In no other context of human communication is anyone routinely required to listen and speak at the same time, preserving an exact semantic correspondence between the two modes. Moreover, there is invariably a delay of a few words between the stimulus and the response, because of the time it takes to assimilate what is being said in the source language and to translate it into an acceptable form in the target language. This ‘ear-voice span’ is usually about 2 or 3 seconds, but it may be as much as 10 seconds or so, if the text is complex. The brain has to remember what has just been said, attend to what is currently being said, and anticipate the construction of what is about to be said. As you start a sentence you are taking a leap in the dark, you are mortgaging your grammatical future; the original sentence may suddenly be turned in such a way that your translation of its end cannot easily be reconciled ( with your translation of its start. Great nimbleness is called for

{F} How it is all done is not at all clear. That it is done at all is a source of some wonder, given the often lengthy periods of interpreting required, the confined environment of an interpreting booth, the presence of background noise, and the awareness that major decisions may depend upon the accuracy of the work. Other considerations such as cultural background also make it aim to pay full attention to the backgrounds of the authors and the recipients and to take into account differences between source and target language.

{G} Research projects have now begun to look at these factors – to determine, for example, how far successful interpreting is affected by poor listening conditions or the speed at which the source language is spoken. It seems that an input speed of between 100 and 120 words per minute is a comfortable rate for interpreting, with an upper limit of around 200 w.p.m. But even small increases in speed can dramatically affect the accuracy of output. In one controlled study, when speeds were gradually increased in a series of stages from 95 to 164 w.p.m., the ear-voice span also increased with each stage, and the amount correctly interpreted showed a clear decline. Also, as the translating load increases, not only are there more errors of commission (mistranslations, cases of vagueness replacing precision), there are also more errors of omission, as words and segments of meaning are filtered out. These are important findings, given the need for accuracy in international communication. What is needed is a more detailed identification of the problem areas, and of the strategies speakers, listeners, and interpreters use to solve them. There is an urgent need to expand what has so far been one of the most neglected fields of communication research.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('98878a2e-928d-5492-bd9e-8123f2564903', '274818c1-f5a9-5987-8902-1ae9207aa018', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-5 on your answer sheet.
Question 1 In which way does author state translation at the beginning of the passage?
A
abstract and concrete meaning
B
general and specific meaning
C
several examples of translation’s meaning
D
different meaning in various profession
Question 2 Application of headphone in a UN conference tells us that:
A
TV show is being conducted
B
radio program is on the air
C
two sides are debating
D
language practice is in the process
Question 3 In the passage, what is the author’s purpose in citing the Tower of Babel?
A
interpreting secret is stored in the Tower
B
interpreter emerged exactly from time of Tower of Babel
C
consecutive interpreting has a long history
D
consecutive interpreting should be abandoned
Question 4 About simultaneous interpreting, which of the following is TRUE?
A
it is an old and disposable interpretation method
B
it doesn’t need outstanding professional ability
C
it relies on professional equipment
D
it takes less than two seconds ear-voice span
Question 5 In consecutive translation, if the section is longer than expected, what would an interpreter most probably do?
A
he or she has to remember some parts ahead
B
he or she has to break them down first
C
he or she has to respond as quickly as possible
D
he or she has to remember all parts ahead

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('078f4b4b-189c-5e3e-a3af-114260f6f978', '274818c1-f5a9-5987-8902-1ae9207aa018', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-5 on your answer sheet.
Question 1 In which way does author state translation at the beginning of the passage?
A
abstract and concrete meaning
B
general and specific meaning
C
several examples of translation’s meaning
D
different meaning in various profession
Question 2 Application of headphone in a UN conference tells us that:
A
TV show is being conducted
B
radio program is on the air
C
two sides are debating
D
language practice is in the process
Question 3 In the passage, what is the author’s purpose in citing the Tower of Babel?
A
interpreting secret is stored in the Tower
B
interpreter emerged exactly from time of Tower of Babel
C
consecutive interpreting has a long history
D
consecutive interpreting should be abandoned
Question 4 About simultaneous interpreting, which of the following is TRUE?
A
it is an old and disposable interpretation method
B
it doesn’t need outstanding professional ability
C
it relies on professional equipment
D
it takes less than two seconds ear-voice span
Question 5 In consecutive translation, if the section is longer than expected, what would an interpreter most probably do?
A
he or she has to remember some parts ahead
B
he or she has to break them down first
C
he or she has to respond as quickly as possible
D
he or she has to remember all parts ahead

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('482a67c3-5588-5e0b-b64d-c6220b0ba858', '274818c1-f5a9-5987-8902-1ae9207aa018', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-5 on your answer sheet.
Question 1 In which way does author state translation at the beginning of the passage?
A
abstract and concrete meaning
B
general and specific meaning
C
several examples of translation’s meaning
D
different meaning in various profession
Question 2 Application of headphone in a UN conference tells us that:
A
TV show is being conducted
B
radio program is on the air
C
two sides are debating
D
language practice is in the process
Question 3 In the passage, what is the author’s purpose in citing the Tower of Babel?
A
interpreting secret is stored in the Tower
B
interpreter emerged exactly from time of Tower of Babel
C
consecutive interpreting has a long history
D
consecutive interpreting should be abandoned
Question 4 About simultaneous interpreting, which of the following is TRUE?
A
it is an old and disposable interpretation method
B
it doesn’t need outstanding professional ability
C
it relies on professional equipment
D
it takes less than two seconds ear-voice span
Question 5 In consecutive translation, if the section is longer than expected, what would an interpreter most probably do?
A
he or she has to remember some parts ahead
B
he or she has to break them down first
C
he or she has to respond as quickly as possible
D
he or she has to remember all parts ahead

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6fe3e52c-7df2-5d29-9b55-c0f685ba4eda', '274818c1-f5a9-5987-8902-1ae9207aa018', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-5 on your answer sheet.
Question 1 In which way does author state translation at the beginning of the passage?
A
abstract and concrete meaning
B
general and specific meaning
C
several examples of translation’s meaning
D
different meaning in various profession
Question 2 Application of headphone in a UN conference tells us that:
A
TV show is being conducted
B
radio program is on the air
C
two sides are debating
D
language practice is in the process
Question 3 In the passage, what is the author’s purpose in citing the Tower of Babel?
A
interpreting secret is stored in the Tower
B
interpreter emerged exactly from time of Tower of Babel
C
consecutive interpreting has a long history
D
consecutive interpreting should be abandoned
Question 4 About simultaneous interpreting, which of the following is TRUE?
A
it is an old and disposable interpretation method
B
it doesn’t need outstanding professional ability
C
it relies on professional equipment
D
it takes less than two seconds ear-voice span
Question 5 In consecutive translation, if the section is longer than expected, what would an interpreter most probably do?
A
he or she has to remember some parts ahead
B
he or she has to break them down first
C
he or she has to respond as quickly as possible
D
he or she has to remember all parts ahead

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b5ffdcaa-fe12-541e-9c21-9491094c1341', '274818c1-f5a9-5987-8902-1ae9207aa018', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D.
Write your answers in boxes 1-5 on your answer sheet.
Question 1 In which way does author state translation at the beginning of the passage?
A
abstract and concrete meaning
B
general and specific meaning
C
several examples of translation’s meaning
D
different meaning in various profession
Question 2 Application of headphone in a UN conference tells us that:
A
TV show is being conducted
B
radio program is on the air
C
two sides are debating
D
language practice is in the process
Question 3 In the passage, what is the author’s purpose in citing the Tower of Babel?
A
interpreting secret is stored in the Tower
B
interpreter emerged exactly from time of Tower of Babel
C
consecutive interpreting has a long history
D
consecutive interpreting should be abandoned
Question 4 About simultaneous interpreting, which of the following is TRUE?
A
it is an old and disposable interpretation method
B
it doesn’t need outstanding professional ability
C
it relies on professional equipment
D
it takes less than two seconds ear-voice span
Question 5 In consecutive translation, if the section is longer than expected, what would an interpreter most probably do?
A
he or she has to remember some parts ahead
B
he or she has to break them down first
C
he or she has to respond as quickly as possible
D
he or she has to remember all parts ahead

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('24025956-2074-5297-8d72-19bc2b942ff5', '274818c1-f5a9-5987-8902-1ae9207aa018', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Summary
Complete the following summary of the paragraphs of Reading Passage, using
no more than two words or a number
from the Reading Passage for each answer. Write your answers in boxes 6-9 on your answer sheet.
The cycle from ear to voice normally lasts about
6
, which depends on the sophistication of paper, for example, it could go up to
7
sometimes. When experts took close research on affecting elements, they found appropriate speaking speed is somehow among
8
w.p.m. In a specific experiment, the accuracy of interpretation dropped while the ear-voice span speed increased between 95 to 164 w.p.m. However, the maximum speed was about
9
W.p.m.

The cycle from ear to voice normally lasts about 6 ____ , which depends on the sophistication of paper, for example, it could go up to 7 ____ sometimes. When experts took close research on affecting elements, they found appropriate speaking speed is somehow among 8 ____ w.p.m. In a specific experiment, the accuracy of interpretation dropped while the ear-voice span speed increased between 95 to 164 w.p.m. However, the maximum speed was about 9 ____ W.p.m.$md$, NULL, ARRAY['.*2.*3.*seconds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('005c5627-da83-541e-a247-91e6dbc8e025', '274818c1-f5a9-5987-8902-1ae9207aa018', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Summary
Complete the following summary of the paragraphs of Reading Passage, using
no more than two words or a number
from the Reading Passage for each answer. Write your answers in boxes 6-9 on your answer sheet.
The cycle from ear to voice normally lasts about
6
, which depends on the sophistication of paper, for example, it could go up to
7
sometimes. When experts took close research on affecting elements, they found appropriate speaking speed is somehow among
8
w.p.m. In a specific experiment, the accuracy of interpretation dropped while the ear-voice span speed increased between 95 to 164 w.p.m. However, the maximum speed was about
9
W.p.m.

The cycle from ear to voice normally lasts about 6 ____ , which depends on the sophistication of paper, for example, it could go up to 7 ____ sometimes. When experts took close research on affecting elements, they found appropriate speaking speed is somehow among 8 ____ w.p.m. In a specific experiment, the accuracy of interpretation dropped while the ear-voice span speed increased between 95 to 164 w.p.m. However, the maximum speed was about 9 ____ W.p.m.$md$, NULL, ARRAY['.*2.*3.*seconds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c4129641-3642-5310-b734-d21c5a5b42ff', '274818c1-f5a9-5987-8902-1ae9207aa018', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Summary
Complete the following summary of the paragraphs of Reading Passage, using
no more than two words or a number
from the Reading Passage for each answer. Write your answers in boxes 6-9 on your answer sheet.
The cycle from ear to voice normally lasts about
6
, which depends on the sophistication of paper, for example, it could go up to
7
sometimes. When experts took close research on affecting elements, they found appropriate speaking speed is somehow among
8
w.p.m. In a specific experiment, the accuracy of interpretation dropped while the ear-voice span speed increased between 95 to 164 w.p.m. However, the maximum speed was about
9
W.p.m.

The cycle from ear to voice normally lasts about 6 ____ , which depends on the sophistication of paper, for example, it could go up to 7 ____ sometimes. When experts took close research on affecting elements, they found appropriate speaking speed is somehow among 8 ____ w.p.m. In a specific experiment, the accuracy of interpretation dropped while the ear-voice span speed increased between 95 to 164 w.p.m. However, the maximum speed was about 9 ____ W.p.m.$md$, NULL, ARRAY['.*2.*3.*seconds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1046a5af-edb9-5ddb-91c9-8f8c3e16731a', '274818c1-f5a9-5987-8902-1ae9207aa018', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Summary
Complete the following summary of the paragraphs of Reading Passage, using
no more than two words or a number
from the Reading Passage for each answer. Write your answers in boxes 6-9 on your answer sheet.
The cycle from ear to voice normally lasts about
6
, which depends on the sophistication of paper, for example, it could go up to
7
sometimes. When experts took close research on affecting elements, they found appropriate speaking speed is somehow among
8
w.p.m. In a specific experiment, the accuracy of interpretation dropped while the ear-voice span speed increased between 95 to 164 w.p.m. However, the maximum speed was about
9
W.p.m.

The cycle from ear to voice normally lasts about 6 ____ , which depends on the sophistication of paper, for example, it could go up to 7 ____ sometimes. When experts took close research on affecting elements, they found appropriate speaking speed is somehow among 8 ____ w.p.m. In a specific experiment, the accuracy of interpretation dropped while the ear-voice span speed increased between 95 to 164 w.p.m. However, the maximum speed was about 9 ____ W.p.m.$md$, NULL, ARRAY['.*2.*3.*seconds.*']);

COMMIT;
