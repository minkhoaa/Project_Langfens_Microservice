BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-book-review-on-musicophilia-1320'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-book-review-on-musicophilia-1320';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-book-review-on-musicophilia-1320';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-book-review-on-musicophilia-1320';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9f10f790-8776-5e4f-8337-088ff3c308c8', 'ielts-reading-book-review-on-musicophilia-1320', $t$Book review on Musicophilia$t$, $md$## Book review on Musicophilia

Nguồn:
- Test: https://mini-ielts.com/1320/reading/book-review-on-musicophilia
- Solution: https://mini-ielts.com/1320/view-solution/reading/book-review-on-musicophilia$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1ed49413-a15a-572d-9c94-147e0e2e6c1b', '9f10f790-8776-5e4f-8337-088ff3c308c8', 1, $t$Reading — Book review on Musicophilia$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Book review on Musicophilia

Norman M. Weinberger reviews the latest work of Oliver Sacks on music.

A

Music and the brain are both endlessly fascinating subjects, and as a neuroscientist specialising in auditory learning and memory, I find them especially intriguing. So I had high expectations of Musicophilia, the latest offering from neurologist and prolific author Oliver Sacks. And I confess to feeling a little guilty reporting that my reactions to the book are mixed.

B

Sacks himself is the best part of Musicophilia. He richly documents his own life in the book and reveals highly personal experiences. The photograph of him on the cover of the book-which shows him wearing headphones, eyes closed, clearly enchanted as he listens to Alfred Brendel perform Beethoven’s Pathetique Sonata-makes a positive impression that is borne out by the contents of the book. Sacks’ voice throughout is steady and erudite but never pontifical. He is neither self-conscious nor self-promoting.

C

The preface gives a good idea of what the book will deliver. In it, Sacks explains that he wants to convey the insights gleaned from the “enormous and rapidly growing body of work on the neural underpinnings of musical perception and imagery, and the complex and often bizarre disorders to which these are prone.” He also stresses the importance of “the simple art of observation” and “the richness of the human context.” He wants to combine “observation and description with the latest in technology,” he says, and to imaginatively enter into the experience of his patients and subjects. The reader can see that Sacks, who has been practicing neurology for 40 years, is torn between the “old-fashioned” path of observation and the new-fangled, high-tech approach: He knows that he needs to take heed of the latter, but his heart lies with the former.

D

The book consists mainly of detailed descriptions of cases, most of them involving patients whom Sacks has seen in his practice. Brief discussions of contemporary neuroscientific reports are sprinkled liberally throughout the text. Part, “Haunted by Music,” begins with the strange case of Tony Cicoria, a nonmusical, middle-aged surgeon who was consumed by a love of music after being hit by lightning. He suddenly began to crave listening to piano music, which he had never cared for in the past. He started to play the piano and then to compose music, which arose spontaneously in his mind in a “torrent” of notes. How could this happen? Was the cause psychological? (He had had a near-death experience when the lightning struck him.) Or was it the direct result of a change in the auditory regions of his cerebral cortex? Electroencephalography (EEG) showed his brain waves to be normal in the mid-1990s, just after his trauma and subsequent “conversion” to music. There are now more sensitive tests, but Cicoria, has declined to undergo them; he does not want to delve into the causes of his musicality. What a shame!

E

Part II, “A Range of Musicality,” covers a wider variety of topics, but unfortunately, some of the chapters offer little or nothing that is new. For example, chapter 13, which is five pages long, merely notes that the blind often has better hearing than the sighted. The most interesting chapters are those that present the strangest cases. Chapter 8 is about “amusia,” an inability to hear sounds like music, and “dysharmonia,” a highly specific impairment of the ability to hear harmony, with the ability to understand melody left intact. Such specific “dissociations” are found throughout the cases Sacks recounts.

F

To Sacks’s credit, part III, “Memory, Movement and Music,” brings us into the underappreciated realm of music therapy. Chapter 16 explains how “melodic intonation therapy” is being used to help expressive aphasic patients (those unable to express their thoughts verbally following a stroke or other cerebral incident) once again become capable of fluent speech. In chapter 20, Sacks demonstrates the near-miraculous power of music to animate Parkinson’s patients and other people with severe movement disorders, even those who are frozen into odd postures. Scientists cannot yet explain how music achieves this effect

G

To readers who are unfamiliar with neuroscience and music behavior, Musicophilia may be something of a revelation. But the book will not satisfy those seeking the causes and implications of the phenomena Sacks describes. For one thing, Sacks appears to be more at ease discussing patients than discussing experiments. And he tends to be rather uncritical in accepting scientific findings and theories.

H

It’s true that the causes of music-brain oddities remain poorly understood. However, Sacks could have done more to draw out some of the implications of the careful observations that he and other neurologists have made and of the treatments that have been successful. For example, he might have noted that the many specific dissociations among components of music comprehension, such as loss of the ability to perceive harmony but not melody, indicate that there is no music center in the brain. Because many people who read the book are likely to believe in the brain localisation of all mental functions, this was a missed educational opportunity.

I

Another conclusion one could draw is that there seem to be no “cures” for neurological problems involving music. A drug can alleviate a symptom in one patient and aggravate it in another or can have both positive and negative effects in the same patient. Treatments mentioned seem to be almost exclusively antiepileptic medications, which “damp down” the excitability of the brain in general; their effectiveness varies widely.

J

Finally, in many of the cases described here the patient with music-brain symptoms is reported to have “normal” EEG results. Although Sacks recognises the existence of new technologies, among them far more sensitive ways to analyze brain waves than the standard neurological EEG test, he does not call for their use. In fact, although he exhibits the greatest compassion for patients, he conveys no sense of urgency about the pursuit of new avenues in the diagnosis and treatment of music-brain disorders. This absence echoes the book’s preface, in which Sacks expresses fear that “the simple art of observation may be lost” if we rely too much on new technologies. He does call for both approaches, though, and we can only hope that the neurological community will respond.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8a689e6e-6f93-59f5-bc19-a9c66fa70ffa', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1.
Why does the writer have a mixed feeling about the book?
A
The guilty feeling made him so.
B
The writer expected it to be better than it was.
C
Sacks failed to include his personal stories in the book.
D
This is the only book written by Sacks.
2.
What is the best part of the book?
A
the photo of Sacks listening to music
B
the tone of voice of the book
C
the autobiographical description in the book
D
the description of Sacks’ wealth
3.
In the preface, what did Sacks try to achieve?
A
make a herald introduction of the research work and technique applied
B
give a detailed description of various musical disorders
C
explain why he needs to do away with the simple observation
D
explain why he needs to do away with the simple observation
4.
What is disappointing about Tony Cicoria’s case?
A
He refuses to have further tests.
B
He can’t determine the cause of his sudden musicality.
C
He nearly died because of the lightening.
D
His brain waves were too normal to show anything.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae71dfa5-fd24-5392-80fb-003201ba115c', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1.
Why does the writer have a mixed feeling about the book?
A
The guilty feeling made him so.
B
The writer expected it to be better than it was.
C
Sacks failed to include his personal stories in the book.
D
This is the only book written by Sacks.
2.
What is the best part of the book?
A
the photo of Sacks listening to music
B
the tone of voice of the book
C
the autobiographical description in the book
D
the description of Sacks’ wealth
3.
In the preface, what did Sacks try to achieve?
A
make a herald introduction of the research work and technique applied
B
give a detailed description of various musical disorders
C
explain why he needs to do away with the simple observation
D
explain why he needs to do away with the simple observation
4.
What is disappointing about Tony Cicoria’s case?
A
He refuses to have further tests.
B
He can’t determine the cause of his sudden musicality.
C
He nearly died because of the lightening.
D
His brain waves were too normal to show anything.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('127dec3b-3be6-5a90-a5b6-046c8d6a290b', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1.
Why does the writer have a mixed feeling about the book?
A
The guilty feeling made him so.
B
The writer expected it to be better than it was.
C
Sacks failed to include his personal stories in the book.
D
This is the only book written by Sacks.
2.
What is the best part of the book?
A
the photo of Sacks listening to music
B
the tone of voice of the book
C
the autobiographical description in the book
D
the description of Sacks’ wealth
3.
In the preface, what did Sacks try to achieve?
A
make a herald introduction of the research work and technique applied
B
give a detailed description of various musical disorders
C
explain why he needs to do away with the simple observation
D
explain why he needs to do away with the simple observation
4.
What is disappointing about Tony Cicoria’s case?
A
He refuses to have further tests.
B
He can’t determine the cause of his sudden musicality.
C
He nearly died because of the lightening.
D
His brain waves were too normal to show anything.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d51cb1f3-ac62-5b96-98db-bfceed3d8c2d', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1.
Why does the writer have a mixed feeling about the book?
A
The guilty feeling made him so.
B
The writer expected it to be better than it was.
C
Sacks failed to include his personal stories in the book.
D
This is the only book written by Sacks.
2.
What is the best part of the book?
A
the photo of Sacks listening to music
B
the tone of voice of the book
C
the autobiographical description in the book
D
the description of Sacks’ wealth
3.
In the preface, what did Sacks try to achieve?
A
make a herald introduction of the research work and technique applied
B
give a detailed description of various musical disorders
C
explain why he needs to do away with the simple observation
D
explain why he needs to do away with the simple observation
4.
What is disappointing about Tony Cicoria’s case?
A
He refuses to have further tests.
B
He can’t determine the cause of his sudden musicality.
C
He nearly died because of the lightening.
D
His brain waves were too normal to show anything.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('93811290-56fa-55e1-a4f5-5052beca904f', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
5-10
on your answer sheet, write
TRUE
if the statement agrees with the views of the writer
FALSE
if the statement contradicts with the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult to give a well-reputable writer a less than totally favorable review.
6
Beethoven’s Pathetique Sonata is a good treatment for musical disorders.
7
Sacks believes technological methods is of little importance compared with traditional observation when studying his patients.
8
It is difficult to understand why music therapy is undervalued
9
Sacks held little skepticism when borrowing other theories and findings in describing reasons and notion for phenomena he depicts in the book.
10
Sacks is in a rush to use new testing methods to do treatment for patients.

5 ____ It is difficult to give a well-reputable writer a less than totally favorable review.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('574be23f-e766-5f6a-a944-f793f0eefc84', '93811290-56fa-55e1-a4f5-5052beca904f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e96b848-d87b-51fc-949c-62b1501c0f9e', '93811290-56fa-55e1-a4f5-5052beca904f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('073cd0b7-cb83-50f4-b4d6-9c9eb8d5a870', '93811290-56fa-55e1-a4f5-5052beca904f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ad6b0688-8cc2-5bb2-a7c8-60c9fbccbaab', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
5-10
on your answer sheet, write
TRUE
if the statement agrees with the views of the writer
FALSE
if the statement contradicts with the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult to give a well-reputable writer a less than totally favorable review.
6
Beethoven’s Pathetique Sonata is a good treatment for musical disorders.
7
Sacks believes technological methods is of little importance compared with traditional observation when studying his patients.
8
It is difficult to understand why music therapy is undervalued
9
Sacks held little skepticism when borrowing other theories and findings in describing reasons and notion for phenomena he depicts in the book.
10
Sacks is in a rush to use new testing methods to do treatment for patients.

6 ____ Beethoven’s Pathetique Sonata is a good treatment for musical disorders.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('773d20ec-1eec-50d2-910d-11c29a96070a', 'ad6b0688-8cc2-5bb2-a7c8-60c9fbccbaab', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('108565ab-98c5-5179-bd7b-e7f2f4aec1a9', 'ad6b0688-8cc2-5bb2-a7c8-60c9fbccbaab', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d39f7251-ee91-5cf4-a143-836ddca64d52', 'ad6b0688-8cc2-5bb2-a7c8-60c9fbccbaab', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b7d0e686-884b-53cd-b8b9-8149ff46b84a', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
5-10
on your answer sheet, write
TRUE
if the statement agrees with the views of the writer
FALSE
if the statement contradicts with the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult to give a well-reputable writer a less than totally favorable review.
6
Beethoven’s Pathetique Sonata is a good treatment for musical disorders.
7
Sacks believes technological methods is of little importance compared with traditional observation when studying his patients.
8
It is difficult to understand why music therapy is undervalued
9
Sacks held little skepticism when borrowing other theories and findings in describing reasons and notion for phenomena he depicts in the book.
10
Sacks is in a rush to use new testing methods to do treatment for patients.

7 ____ Sacks believes technological methods is of little importance compared with traditional observation when studying his patients.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60592bd6-6a39-559c-ba7a-e8297c802e57', 'b7d0e686-884b-53cd-b8b9-8149ff46b84a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b0f8ca7-2193-5dd8-88e7-e2491073e242', 'b7d0e686-884b-53cd-b8b9-8149ff46b84a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94353ede-8fa9-59eb-9eac-755c737dc579', 'b7d0e686-884b-53cd-b8b9-8149ff46b84a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8cdbef21-de90-5f88-8ed0-35235655bf29', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
5-10
on your answer sheet, write
TRUE
if the statement agrees with the views of the writer
FALSE
if the statement contradicts with the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult to give a well-reputable writer a less than totally favorable review.
6
Beethoven’s Pathetique Sonata is a good treatment for musical disorders.
7
Sacks believes technological methods is of little importance compared with traditional observation when studying his patients.
8
It is difficult to understand why music therapy is undervalued
9
Sacks held little skepticism when borrowing other theories and findings in describing reasons and notion for phenomena he depicts in the book.
10
Sacks is in a rush to use new testing methods to do treatment for patients.

8 ____ It is difficult to understand why music therapy is undervalued$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('114e87e1-71d9-5cbc-960d-4e4d8b9dddbe', '8cdbef21-de90-5f88-8ed0-35235655bf29', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c52bbe98-0c3a-5399-b6e7-1c79c9a7c4c8', '8cdbef21-de90-5f88-8ed0-35235655bf29', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('823513b6-0452-5e66-adad-30712ef756f8', '8cdbef21-de90-5f88-8ed0-35235655bf29', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('84b4a45b-5748-58dc-90db-2a1864f6f733', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
5-10
on your answer sheet, write
TRUE
if the statement agrees with the views of the writer
FALSE
if the statement contradicts with the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult to give a well-reputable writer a less than totally favorable review.
6
Beethoven’s Pathetique Sonata is a good treatment for musical disorders.
7
Sacks believes technological methods is of little importance compared with traditional observation when studying his patients.
8
It is difficult to understand why music therapy is undervalued
9
Sacks held little skepticism when borrowing other theories and findings in describing reasons and notion for phenomena he depicts in the book.
10
Sacks is in a rush to use new testing methods to do treatment for patients.

9 ____ Sacks held little skepticism when borrowing other theories and findings in describing reasons and notion for phenomena he depicts in the book.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1f68c4e-2ee7-583e-ae14-04a9dd0badfa', '84b4a45b-5748-58dc-90db-2a1864f6f733', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6946066-bc8c-578a-a1b4-513fd780e567', '84b4a45b-5748-58dc-90db-2a1864f6f733', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c620742-de82-5899-8335-d1edc5dd97ad', '84b4a45b-5748-58dc-90db-2a1864f6f733', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aa15f667-0562-5f9f-a44e-690c7a04032b', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
5-10
on your answer sheet, write
TRUE
if the statement agrees with the views of the writer
FALSE
if the statement contradicts with the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult to give a well-reputable writer a less than totally favorable review.
6
Beethoven’s Pathetique Sonata is a good treatment for musical disorders.
7
Sacks believes technological methods is of little importance compared with traditional observation when studying his patients.
8
It is difficult to understand why music therapy is undervalued
9
Sacks held little skepticism when borrowing other theories and findings in describing reasons and notion for phenomena he depicts in the book.
10
Sacks is in a rush to use new testing methods to do treatment for patients.

10 ____ Sacks is in a rush to use new testing methods to do treatment for patients.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4bc6d9c1-5fd8-5be5-b760-90205c19c912', 'aa15f667-0562-5f9f-a44e-690c7a04032b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdb8aa3f-85c5-5c05-98b1-98b9b0402d58', 'aa15f667-0562-5f9f-a44e-690c7a04032b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffaa1742-e64c-59ed-9d69-5114f0973557', 'aa15f667-0562-5f9f-a44e-690c7a04032b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c1d9ca4b-47dd-586d-b60f-aa56398b82e1', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes 11-14 on your answer sheet.
11
The content covered dissociations in understanding between harmony and melody
12
The study of treating musical disorders
13
The EEG scans of Sacks’ patients
14
Sacks believes testing based on new technologies
A
show no music-brain disorders.
B
indicates that medication can have varied results.
C
is key for the neurological community to unravel the mysteries.
D
should not be used in isolation.
E
indicate that not everyone can receive a good education.
F
show a misconception that there is a function centre localized in the brain

11 ____ The content covered dissociations in understanding between harmony and melody$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('817e1a3e-2ff5-56b8-b176-7eae7c47d76d', 'c1d9ca4b-47dd-586d-b60f-aa56398b82e1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6fb20bdb-af41-566c-83a2-d10b0ce2247b', 'c1d9ca4b-47dd-586d-b60f-aa56398b82e1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('505fc3cb-9819-550d-b5f6-53e4a047c792', 'c1d9ca4b-47dd-586d-b60f-aa56398b82e1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7833f202-0f31-5099-bcf9-f8b99055dc94', 'c1d9ca4b-47dd-586d-b60f-aa56398b82e1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5310864-563d-571b-bf30-e8f2f5c41c81', 'c1d9ca4b-47dd-586d-b60f-aa56398b82e1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f0cb399-1ceb-514a-a740-73117b2e6e68', 'c1d9ca4b-47dd-586d-b60f-aa56398b82e1', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e339706c-a706-5a0e-bc23-c6e554ddda50', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes 11-14 on your answer sheet.
11
The content covered dissociations in understanding between harmony and melody
12
The study of treating musical disorders
13
The EEG scans of Sacks’ patients
14
Sacks believes testing based on new technologies
A
show no music-brain disorders.
B
indicates that medication can have varied results.
C
is key for the neurological community to unravel the mysteries.
D
should not be used in isolation.
E
indicate that not everyone can receive a good education.
F
show a misconception that there is a function centre localized in the brain

12 ____ The study of treating musical disorders$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9d551a7-cb04-5fe9-9260-640b945225ec', 'e339706c-a706-5a0e-bc23-c6e554ddda50', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8085d537-0a78-5613-b788-e5daaf38f879', 'e339706c-a706-5a0e-bc23-c6e554ddda50', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3a73357-30d6-5636-b91b-8719c2804bfe', 'e339706c-a706-5a0e-bc23-c6e554ddda50', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d671efe-da47-552c-b54c-c54b21187eb1', 'e339706c-a706-5a0e-bc23-c6e554ddda50', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0079170-c629-527a-980f-5ae45144170f', 'e339706c-a706-5a0e-bc23-c6e554ddda50', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e8ecce4-06d2-5e0a-a535-b95dd6a96756', 'e339706c-a706-5a0e-bc23-c6e554ddda50', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7fec3d70-26e7-5f40-9966-ad5ae1515284', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes 11-14 on your answer sheet.
11
The content covered dissociations in understanding between harmony and melody
12
The study of treating musical disorders
13
The EEG scans of Sacks’ patients
14
Sacks believes testing based on new technologies
A
show no music-brain disorders.
B
indicates that medication can have varied results.
C
is key for the neurological community to unravel the mysteries.
D
should not be used in isolation.
E
indicate that not everyone can receive a good education.
F
show a misconception that there is a function centre localized in the brain

13 ____ The EEG scans of Sacks’ patients$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b9f0686-1906-54fe-bf26-a3aab16e3d99', '7fec3d70-26e7-5f40-9966-ad5ae1515284', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b7cc373-2dce-5cb2-93eb-1f01f9a7a7a8', '7fec3d70-26e7-5f40-9966-ad5ae1515284', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e80fcfe-f37f-5b95-93cd-bc0cb215cb78', '7fec3d70-26e7-5f40-9966-ad5ae1515284', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e66e077-6245-535d-8619-ae0eac16e3f8', '7fec3d70-26e7-5f40-9966-ad5ae1515284', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5eb62477-839d-53d3-a9d6-3c660b0b678a', '7fec3d70-26e7-5f40-9966-ad5ae1515284', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99005323-c349-530f-a149-3d3afe9ebeaa', '7fec3d70-26e7-5f40-9966-ad5ae1515284', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc29b099-8301-50f4-9e97-448e9d4ce718', '1ed49413-a15a-572d-9c94-147e0e2e6c1b', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes 11-14 on your answer sheet.
11
The content covered dissociations in understanding between harmony and melody
12
The study of treating musical disorders
13
The EEG scans of Sacks’ patients
14
Sacks believes testing based on new technologies
A
show no music-brain disorders.
B
indicates that medication can have varied results.
C
is key for the neurological community to unravel the mysteries.
D
should not be used in isolation.
E
indicate that not everyone can receive a good education.
F
show a misconception that there is a function centre localized in the brain

14 ____ Sacks believes testing based on new technologies$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd5ca7b9-7bd0-5c17-ada4-c237017a8e00', 'fc29b099-8301-50f4-9e97-448e9d4ce718', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1129b2e0-005f-5720-93e0-115251f63613', 'fc29b099-8301-50f4-9e97-448e9d4ce718', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d0775ed-8e6b-55a6-aeb8-e48d36c6c00b', 'fc29b099-8301-50f4-9e97-448e9d4ce718', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f64d2a9-4aa9-54fd-af2c-74ad7134f5ca', 'fc29b099-8301-50f4-9e97-448e9d4ce718', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ada82cc8-141a-5ba9-b2ff-a74b0df027c9', 'fc29b099-8301-50f4-9e97-448e9d4ce718', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe9a16ca-ea05-5d1d-8c8f-8fcbae9f8883', 'fc29b099-8301-50f4-9e97-448e9d4ce718', 6, $md$F$md$, false);

COMMIT;
