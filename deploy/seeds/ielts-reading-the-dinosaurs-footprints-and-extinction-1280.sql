BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-dinosaurs-footprints-and-extinction-1280'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-dinosaurs-footprints-and-extinction-1280';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-dinosaurs-footprints-and-extinction-1280';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-dinosaurs-footprints-and-extinction-1280';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('fd5874d0-1425-580d-91d3-beca6460bac2', 'ielts-reading-the-dinosaurs-footprints-and-extinction-1280', $t$The Dinosaurs Footprints and Extinction$t$, $md$## The Dinosaurs Footprints and Extinction

Nguồn:
- Test: https://mini-ielts.com/1280/reading/the-dinosaurs-footprints-and-extinction
- Solution: https://mini-ielts.com/1280/view-solution/reading/the-dinosaurs-footprints-and-extinction$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('d8def478-733e-5408-a5ea-3966c80b7e1e', 'fd5874d0-1425-580d-91d3-beca6460bac2', 1, $t$Reading — The Dinosaurs Footprints and Extinction$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Dinosaurs Footprints and Extinction

A

B

Dinosaurs first appeared in the fossil record 230m years ago, during the Triassic period. But they were mostly small, and they shared the earth with lots of other sorts of reptile. It was in the subsequent Jurassic, which began 202 million years ago, that they overran the planet and turned into the monsters depicted in the book and movie “ Jurassic Park ”. (Actually, though, the dinosaurs that appeared on screen were from the still more recent Cretaceous period.) Dr Olsen and his colleagues are not the first to suggest that the dinosaurs inherited the earth as the result of an asteroid strike. But they are the first to show that the takeover did, indeed, happen in a geological eyeblink.

C

Dinosaur skeletons are rare. Dinosaur footprints are, however, surprisingly abundant. And the sizes of the prints are as good an indication of the sizes of the beasts as are the skeletons themselves. Dr Olsen and his colleagues, therefore, concentrated on prints, not bones.

D

The prints in question were made in eastern North America, a part of the world the full of rift valleys to those in East Africa today. Like the modern African rift valleys, the Triassic/Jurassic American ones contained lakes, and these lakes grew and shrank at regular intervals because of climatic changes caused by periodic shifts in the earth’s orbit. (A similar phenomenon is responsible for modern ice ages.) That regularity, combined with reversals in the earth’s magnetic field, which are detectable in the tiny fields of certain magnetic minerals, means that rocks from this place and period can be dated to within a few thousand years. As a bonus, squishy lake-edge sediments are just the things for recording the tracks of passing animals. By dividing the labour between themselves, the ten authors of the paper were able to study such tracks at 80 sites.

E

The researchers looked at 18 so-called ichnotaxa. These are recognizable types of the footprint that cannot be matched precisely with the species of animal that left them. But they can be matched with a general sort of animal, and thus act as an indicator of the fate of that group, even when there are no bones to tell the story. Five of the ichnotaxa disappear before the end of the Triassic, and four march confidently across the boundary into the Jurassic. Six, however, vanish at the boundary, or only just splutter across it; and there appear from nowhere, almost as soon as the Jurassic begins.

F

That boundary itself is suggestive. The first geological indication of the impact that killed the dinosaurs was an unusually high level of iridium in rocks at the end of the Cretaceous when the beasts disappear from the fossil record. Iridium is normally rare at the earth’s surface, but it is more abundant in meteorites. When people began to believe the impact theory, they started looking for other Cretaceous-and anomalies. One that turned up was a surprising abundance of fern spores in rocks just above the boundary layer – a phenomenon known as a “fern spike”.

G

That matched the theory nicely. Many modern ferns are opportunists. They cannot compete against plants with leaves, but if a piece of land is cleared by, say, a volcanic eruption, they are often the first things to set up shop there. An asteroid strike would have scoured much of the earth of its vegetable cover, and provided a paradise for ferns. A fern spike in the rocks is thus a good indication that something terrible has happened.

H

Both an iridium anomaly and a fern spike appear in rocks at the end of the Triassic, too. That accounts for the disappearing ichnotaxa: the creatures that made them did not survive the holocaust. The surprise is how rapidly the new ichnotaxa appear.

I

Dr Olsen and his colleagues suggest that the explanation for this rapid increase in size may be a phenomenon called ecological release. This is seen today when reptiles (which, in modern times, tend to be small creatures) reach islands where they face no competitors. The most spectacular example is on the Indonesian island of Komodo, where local lizards have grown so large that they are often referred to as dragons. The dinosaurs, in other words, could flourish only when the competition had been knocked out.

J

That leaves the question of where the impact happened. No large hole in the earth’s crust seems to be 202m years old. It may, of course, have been overlooked. Old craters are eroded and buried, and not always easy to find. Alternatively, it may have vanished. Although the continental crust is more or less permanent, the ocean floor is constantly recycled by the tectonic processes that bring about continental drift. There is no ocean floor left that is more than 200m years old, so a crater that formed in the ocean would have been swallowed up by now.

K

There is a third possibility, however. This is that the crater is known, but has been misdated. The Manicouagan “structure”, a crater in Quebec, is thought to be 214m years old. It is huge – some 100km across – and seems to be the largest of between three and five craters that formed within a few hours of each other as the lumps of a disintegrated comet hit the earth one by one.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ad0428d-6c98-5276-acda-79ecc9a2302a', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
Dr Paul Olsen and his colleagues believe that asteroid knock may also lead to dinosaurs’ boom.
2
Books and movie like
Jurassic Park
often exaggerate the size of the dinosaurs.
3
Dinosaur footprints are more adequate than dinosaur skeletons.
4
The prints were chosen by Dr Olsen to study because they are more detectable than the earth magnetic field to track the date of geological precise within thousands of years.
5
Ichnotaxa showed that footprints of dinosaurs offer exact information of the trace left by an individual species.
6
We can find more Iridium in the earth’s surface than in meteorites.

1 ____ Dr Paul Olsen and his colleagues believe that asteroid knock may also lead to dinosaurs’ boom.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ef6329d-d857-5ba0-9eca-098958a11a36', '7ad0428d-6c98-5276-acda-79ecc9a2302a', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95a10991-a900-5b26-b501-b325ed814d80', '7ad0428d-6c98-5276-acda-79ecc9a2302a', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98ebd3bb-4fde-5853-b0e3-5674aa054445', '7ad0428d-6c98-5276-acda-79ecc9a2302a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e4870e76-901d-5dc8-97fd-ee37b5494770', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
Dr Paul Olsen and his colleagues believe that asteroid knock may also lead to dinosaurs’ boom.
2
Books and movie like
Jurassic Park
often exaggerate the size of the dinosaurs.
3
Dinosaur footprints are more adequate than dinosaur skeletons.
4
The prints were chosen by Dr Olsen to study because they are more detectable than the earth magnetic field to track the date of geological precise within thousands of years.
5
Ichnotaxa showed that footprints of dinosaurs offer exact information of the trace left by an individual species.
6
We can find more Iridium in the earth’s surface than in meteorites.

2 ____ Books and movie like Jurassic Park often exaggerate the size of the dinosaurs.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffe6efa1-d473-54b2-8863-bf950f7d4b2a', 'e4870e76-901d-5dc8-97fd-ee37b5494770', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63a09426-d17f-5e23-996b-7fc8c5944e98', 'e4870e76-901d-5dc8-97fd-ee37b5494770', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d587652-c431-5dac-9425-45b9d1592fe3', 'e4870e76-901d-5dc8-97fd-ee37b5494770', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72806950-12e2-52c5-9385-afc9f2c5591a', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
Dr Paul Olsen and his colleagues believe that asteroid knock may also lead to dinosaurs’ boom.
2
Books and movie like
Jurassic Park
often exaggerate the size of the dinosaurs.
3
Dinosaur footprints are more adequate than dinosaur skeletons.
4
The prints were chosen by Dr Olsen to study because they are more detectable than the earth magnetic field to track the date of geological precise within thousands of years.
5
Ichnotaxa showed that footprints of dinosaurs offer exact information of the trace left by an individual species.
6
We can find more Iridium in the earth’s surface than in meteorites.

3 ____ Dinosaur footprints are more adequate than dinosaur skeletons.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03fc9e7d-4b81-5c87-8765-f55dcdef3062', '72806950-12e2-52c5-9385-afc9f2c5591a', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('854ddb46-19ed-5dae-bf3f-7e96d16ec84c', '72806950-12e2-52c5-9385-afc9f2c5591a', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d7469c3-4816-5a1c-8334-0db708cb0351', '72806950-12e2-52c5-9385-afc9f2c5591a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('94bf1dbf-d6f2-5853-be90-7699fe80505e', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
Dr Paul Olsen and his colleagues believe that asteroid knock may also lead to dinosaurs’ boom.
2
Books and movie like
Jurassic Park
often exaggerate the size of the dinosaurs.
3
Dinosaur footprints are more adequate than dinosaur skeletons.
4
The prints were chosen by Dr Olsen to study because they are more detectable than the earth magnetic field to track the date of geological precise within thousands of years.
5
Ichnotaxa showed that footprints of dinosaurs offer exact information of the trace left by an individual species.
6
We can find more Iridium in the earth’s surface than in meteorites.

4 ____ The prints were chosen by Dr Olsen to study because they are more detectable than the earth magnetic field to track the date of geological precise within thousands of years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f50fe692-247c-5a53-8db8-f2317e2b12b5', '94bf1dbf-d6f2-5853-be90-7699fe80505e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22aa1b02-4a6f-56a5-85da-688dfaf95f36', '94bf1dbf-d6f2-5853-be90-7699fe80505e', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abfffcc5-a2d4-5ae1-869e-d6afee0b7783', '94bf1dbf-d6f2-5853-be90-7699fe80505e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f6c125d6-0ec9-58de-b35d-037536773d9e', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
Dr Paul Olsen and his colleagues believe that asteroid knock may also lead to dinosaurs’ boom.
2
Books and movie like
Jurassic Park
often exaggerate the size of the dinosaurs.
3
Dinosaur footprints are more adequate than dinosaur skeletons.
4
The prints were chosen by Dr Olsen to study because they are more detectable than the earth magnetic field to track the date of geological precise within thousands of years.
5
Ichnotaxa showed that footprints of dinosaurs offer exact information of the trace left by an individual species.
6
We can find more Iridium in the earth’s surface than in meteorites.

5 ____ Ichnotaxa showed that footprints of dinosaurs offer exact information of the trace left by an individual species.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59d5925c-f0d3-5955-bff9-1c5e43951507', 'f6c125d6-0ec9-58de-b35d-037536773d9e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14468ad6-7f77-5d08-9fed-430867f9a1e6', 'f6c125d6-0ec9-58de-b35d-037536773d9e', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46297033-bd6c-54fd-b055-cea2dd67f6b9', 'f6c125d6-0ec9-58de-b35d-037536773d9e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a9a68c6-2938-5ba0-b294-07258f7b1c46', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-6
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
Dr Paul Olsen and his colleagues believe that asteroid knock may also lead to dinosaurs’ boom.
2
Books and movie like
Jurassic Park
often exaggerate the size of the dinosaurs.
3
Dinosaur footprints are more adequate than dinosaur skeletons.
4
The prints were chosen by Dr Olsen to study because they are more detectable than the earth magnetic field to track the date of geological precise within thousands of years.
5
Ichnotaxa showed that footprints of dinosaurs offer exact information of the trace left by an individual species.
6
We can find more Iridium in the earth’s surface than in meteorites.

6 ____ We can find more Iridium in the earth’s surface than in meteorites.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('430c6329-1a72-581a-83b2-7d01258b35d2', '9a9a68c6-2938-5ba0-b294-07258f7b1c46', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1aca76e2-481e-52d1-84e2-851507b07b9a', '9a9a68c6-2938-5ba0-b294-07258f7b1c46', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35e90b54-acf8-54c0-8805-984a242ed871', '9a9a68c6-2938-5ba0-b294-07258f7b1c46', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d86b3028-7691-5c6c-96f8-10863ea07215', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
Dr Olsen and his colleagues applied a phenomenon named
7
to explain the large size of the Eubrontes, which is a similar case to that nowadays reptiles invade a place where there are no
8
; for example, on an island called Komodo, indigenous huge lizards grow so big that people even regarding them as
9
However, there were no old impact trace being found? The answer may be that we have
10
. the evidence. Old craters are difficult to spot or it probably
11
. Due to the effect of the earth moving. Even a crater formed in Ocean had been
12
under the impact of crust movement. Besides, the third hypothesis is that the potential evidence – some craters maybe
13
.

Dr Olsen and his colleagues applied a phenomenon named 7 ____ to explain the large size of the Eubrontes, which is a similar case to that nowadays reptiles invade a place where there are no 8 ____ ; for example, on an island called Komodo, indigenous huge lizards grow so big that people even regarding them as 9 ____$md$, NULL, ARRAY['.*ecological.*release.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('257068bf-1203-56c1-9874-5d308e41c1f5', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
Dr Olsen and his colleagues applied a phenomenon named
7
to explain the large size of the Eubrontes, which is a similar case to that nowadays reptiles invade a place where there are no
8
; for example, on an island called Komodo, indigenous huge lizards grow so big that people even regarding them as
9
However, there were no old impact trace being found? The answer may be that we have
10
. the evidence. Old craters are difficult to spot or it probably
11
. Due to the effect of the earth moving. Even a crater formed in Ocean had been
12
under the impact of crust movement. Besides, the third hypothesis is that the potential evidence – some craters maybe
13
.

Dr Olsen and his colleagues applied a phenomenon named 7 ____ to explain the large size of the Eubrontes, which is a similar case to that nowadays reptiles invade a place where there are no 8 ____ ; for example, on an island called Komodo, indigenous huge lizards grow so big that people even regarding them as 9 ____$md$, NULL, ARRAY['.*ecological.*release.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6bc30828-8f53-5107-82e7-6e57ff539ac2', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
Dr Olsen and his colleagues applied a phenomenon named
7
to explain the large size of the Eubrontes, which is a similar case to that nowadays reptiles invade a place where there are no
8
; for example, on an island called Komodo, indigenous huge lizards grow so big that people even regarding them as
9
However, there were no old impact trace being found? The answer may be that we have
10
. the evidence. Old craters are difficult to spot or it probably
11
. Due to the effect of the earth moving. Even a crater formed in Ocean had been
12
under the impact of crust movement. Besides, the third hypothesis is that the potential evidence – some craters maybe
13
.

Dr Olsen and his colleagues applied a phenomenon named 7 ____ to explain the large size of the Eubrontes, which is a similar case to that nowadays reptiles invade a place where there are no 8 ____ ; for example, on an island called Komodo, indigenous huge lizards grow so big that people even regarding them as 9 ____$md$, NULL, ARRAY['.*ecological.*release.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9bd1ede2-0f1e-53f2-bd37-87cd6f3a5647', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
Dr Olsen and his colleagues applied a phenomenon named
7
to explain the large size of the Eubrontes, which is a similar case to that nowadays reptiles invade a place where there are no
8
; for example, on an island called Komodo, indigenous huge lizards grow so big that people even regarding them as
9
However, there were no old impact trace being found? The answer may be that we have
10
. the evidence. Old craters are difficult to spot or it probably
11
. Due to the effect of the earth moving. Even a crater formed in Ocean had been
12
under the impact of crust movement. Besides, the third hypothesis is that the potential evidence – some craters maybe
13
.

However, there were no old impact trace being found? The answer may be that we have 10 ____ . the evidence. Old craters are difficult to spot or it probably 11 ____ . Due to the effect of the earth moving. Even a crater formed in Ocean had been 12 ____ under the impact of crust movement. Besides, the third hypothesis is that the potential evidence – some craters maybe 13 ____ .$md$, NULL, ARRAY['.*overlooked.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c1f62e05-67bf-5b30-a9d6-7aa1ab4f2f0f', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
Dr Olsen and his colleagues applied a phenomenon named
7
to explain the large size of the Eubrontes, which is a similar case to that nowadays reptiles invade a place where there are no
8
; for example, on an island called Komodo, indigenous huge lizards grow so big that people even regarding them as
9
However, there were no old impact trace being found? The answer may be that we have
10
. the evidence. Old craters are difficult to spot or it probably
11
. Due to the effect of the earth moving. Even a crater formed in Ocean had been
12
under the impact of crust movement. Besides, the third hypothesis is that the potential evidence – some craters maybe
13
.

However, there were no old impact trace being found? The answer may be that we have 10 ____ . the evidence. Old craters are difficult to spot or it probably 11 ____ . Due to the effect of the earth moving. Even a crater formed in Ocean had been 12 ____ under the impact of crust movement. Besides, the third hypothesis is that the potential evidence – some craters maybe 13 ____ .$md$, NULL, ARRAY['.*overlooked.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('36ca682f-fe5f-59d7-9c3e-5466b4c2b59e', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
Dr Olsen and his colleagues applied a phenomenon named
7
to explain the large size of the Eubrontes, which is a similar case to that nowadays reptiles invade a place where there are no
8
; for example, on an island called Komodo, indigenous huge lizards grow so big that people even regarding them as
9
However, there were no old impact trace being found? The answer may be that we have
10
. the evidence. Old craters are difficult to spot or it probably
11
. Due to the effect of the earth moving. Even a crater formed in Ocean had been
12
under the impact of crust movement. Besides, the third hypothesis is that the potential evidence – some craters maybe
13
.

However, there were no old impact trace being found? The answer may be that we have 10 ____ . the evidence. Old craters are difficult to spot or it probably 11 ____ . Due to the effect of the earth moving. Even a crater formed in Ocean had been 12 ____ under the impact of crust movement. Besides, the third hypothesis is that the potential evidence – some craters maybe 13 ____ .$md$, NULL, ARRAY['.*overlooked.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('17f951ce-92a2-5b5f-91fa-b8fb3bde8dff', 'd8def478-733e-5408-a5ea-3966c80b7e1e', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
Dr Olsen and his colleagues applied a phenomenon named
7
to explain the large size of the Eubrontes, which is a similar case to that nowadays reptiles invade a place where there are no
8
; for example, on an island called Komodo, indigenous huge lizards grow so big that people even regarding them as
9
However, there were no old impact trace being found? The answer may be that we have
10
. the evidence. Old craters are difficult to spot or it probably
11
. Due to the effect of the earth moving. Even a crater formed in Ocean had been
12
under the impact of crust movement. Besides, the third hypothesis is that the potential evidence – some craters maybe
13
.

However, there were no old impact trace being found? The answer may be that we have 10 ____ . the evidence. Old craters are difficult to spot or it probably 11 ____ . Due to the effect of the earth moving. Even a crater formed in Ocean had been 12 ____ under the impact of crust movement. Besides, the third hypothesis is that the potential evidence – some craters maybe 13 ____ .$md$, NULL, ARRAY['.*overlooked.*']);

COMMIT;
