BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-prehistoric-cave-paintings-took-up-to-20000-years-to-complete-1223'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-prehistoric-cave-paintings-took-up-to-20000-years-to-complete-1223';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-prehistoric-cave-paintings-took-up-to-20000-years-to-complete-1223';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-prehistoric-cave-paintings-took-up-to-20000-years-to-complete-1223';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('306a914b-fceb-5a43-8d19-fd00dcdb9009', 'ielts-reading-prehistoric-cave-paintings-took-up-to-20000-years-to-complete-1223', $t$Prehistoric Cave Paintings Took up to 20,000 Years to Complete$t$, $md$## Prehistoric Cave Paintings Took up to 20,000 Years to Complete

Nguồn:
- Test: https://mini-ielts.com/1223/reading/prehistoric-cave-paintings-took-up-to-20000-years-to-complete
- Solution: https://mini-ielts.com/1223/view-solution/reading/prehistoric-cave-paintings-took-up-to-20000-years-to-complete$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('cb63e189-9b0f-523f-9d91-8a610c94b457', '306a914b-fceb-5a43-8d19-fd00dcdb9009', 1, $t$Reading — Prehistoric Cave Paintings Took up to 20,000 Years to Complete$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Prehistoric Cave Paintings Took up to 20,000 Years to Complete

It may have taken Michelangelo four long years to paint his fresco on the ceiling of the Sistine Chapel, but his earliest predecessors spent considerably longer perfecting their own masterpieces. Scientists have discovered that prehistoric cave paintings took up to 20,000 years to complete. Rather than being created in one session, as archaeologists previously thought, many of the works discovered across Europe were produced over hundreds of generations, who added to, refreshed and painted over the original pieces of art.

Until now it has been extremely difficult to pinpoint when prehistoric cave paintings and carvings were created, but a pioneering technique is allowing researchers to date cave art accurately for the first time and show how the works were crafted over thousands of years. Experts now hope the technique will provide a valuable insight into how early human culture developed and changed as the first modern humans moved across Europe around 40,000 years ago.

Dr Alistair Pike, an archaeologist at Bristol University who is leading the research, said:The art gives us a really intimate window into the minds of the individuals who produced it, but what we don’t know is exactly which individuals they were as we don’t know exactly when the art was created. If we can date the art then we can relate that to the artefacts we find in the ground and start to link the symbolic thoughts of these individuals to where, when and how they were living.’

Hundreds of caves have been discovered across Europe with elaborate prehistoric paintings and carvings on their walls. It is thought the designs, which often depict scenes of animals, were created up to 40,000 years ago – some time after humans began moving from southern Europe into northern Europe during the last ice age.

Traditional dating techniques have relied on carbon dating the charcoal and other pigment used in the paintings, but this can be inaccurate as it only gives the date the charcoal was created not when the work was crafted.’When you go into these caves today there is still charcoal lying on the ground, so the artists at the time could have been using old charcoal rather than making it fresh themselves,’ explained Dr Pike.

‘If this was the case, then the date for the painting would be very wrong. Taking samples for carbon dating also means destroying a bit of these precious paintings because you need to take away a bit of the pigment. For carvings, it is virtually impossible to date them as there is no organic pigment containing carbon at ail.’

The scientists have used their technique to date a series of famous Palaeolithic paintings in Altamira cave, northern Spain. Known as the ‘Sistine Chapel of the Palaeolithic’, the elaborate works were thought to date from around 14,000 years ago. But in research published by the Natural Environment Research Council’s new website Planet Earth, Dr Pike discovered some of the paintings were between 25,000 and 35,000 years old. The youngest paintings in the cave were 11,000 years old. Dr Pike said:’We have found that most of these caves were not painted in one go, but the painting spanned up to 20,000 years.This goes against what the archaeologists who excavated in the caves found. It is probably the case that people did not live in the caves they painted. It seems the caves they lived in were elsewhere and there was something special about the painted caves.’

Dr Pike and his team were able to date the paintings using a technique known as uranium series dating, which was originally developed by geologists to date rock formations such as stalactites and stalagmites in caves. As water seeps through a cave, it carries extremely low levels of dissolved radioactive uranium along with the mineral calcium carbonate. Over time small amounts of calcium carbonate are deposited to form a hard layer over the paintings and this layer also traps the uranium. Due to its radioactive properties, the uranium slowly decays to become another element known as thorium. By comparing the ratio of uranium to thorium in the thin layers on top of the cave art, the researchers were able to calculate the age of the paintings.

The researchers have also applied their technique to engravings found in rocks around Creswell Crags in Derbyshire, which are Britain’s only examples of ice age cave art. They proved the engravings were made at least 12,000 years ago. Professor Pablo Arias, an expert on Palaeolithic cave art at the University of Cantabria, Spain, said: ‘Until about ten years ago it was only possible to date cave art by using the style of the figures, but this new technique developed by Bristol University allows that date to be accurately bracketed. We want to study how the people of the time behaved and how they felt and Palaeolithic art gives us a way of looking at the type of symbols that were important to them, so we need to know when the people who were making the art actually lived.’$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b2e92365-1c9b-5a92-9d6e-35f0b964ec7d', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage 1? Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cave paintings inspired Michelangelo to paint the ceiling of the Sistine Chapel.
2
It now seems that cave paintings were painted in one go and then left untouched.
3
Dr Pike is focusing on dating artefacts found on the ground in the caves.
4
There are a number of disadvantages to using carbon dating to date paintings and carvings.
5
The Altamira cave contains more cave paintings than any other cave in Europe.

1 ____ Cave paintings inspired Michelangelo to paint the ceiling of the Sistine Chapel.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e7fee54-63d5-53f1-a0b0-88cf6d3ed551', 'b2e92365-1c9b-5a92-9d6e-35f0b964ec7d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5556d02-3ec9-5a40-9e21-ef4ff983c194', 'b2e92365-1c9b-5a92-9d6e-35f0b964ec7d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f158e4c-bcb3-5c3a-9aab-3cc6657e2e31', 'b2e92365-1c9b-5a92-9d6e-35f0b964ec7d', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af3923e0-66f6-5962-bf67-8d3aace9c5de', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage 1? Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cave paintings inspired Michelangelo to paint the ceiling of the Sistine Chapel.
2
It now seems that cave paintings were painted in one go and then left untouched.
3
Dr Pike is focusing on dating artefacts found on the ground in the caves.
4
There are a number of disadvantages to using carbon dating to date paintings and carvings.
5
The Altamira cave contains more cave paintings than any other cave in Europe.

2 ____ It now seems that cave paintings were painted in one go and then left untouched.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2360ddb2-91f8-5073-81bb-c2422c2c6d33', 'af3923e0-66f6-5962-bf67-8d3aace9c5de', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('605ac452-7c3d-5eb8-9f5f-c35ee95ca6e4', 'af3923e0-66f6-5962-bf67-8d3aace9c5de', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19d31ff5-7b2c-5972-81bf-7065950f9d2a', 'af3923e0-66f6-5962-bf67-8d3aace9c5de', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bb0a4b5f-b451-5199-a499-bcca56cee984', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage 1? Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cave paintings inspired Michelangelo to paint the ceiling of the Sistine Chapel.
2
It now seems that cave paintings were painted in one go and then left untouched.
3
Dr Pike is focusing on dating artefacts found on the ground in the caves.
4
There are a number of disadvantages to using carbon dating to date paintings and carvings.
5
The Altamira cave contains more cave paintings than any other cave in Europe.

3 ____ Dr Pike is focusing on dating artefacts found on the ground in the caves.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a824cf9f-affb-58da-990b-a1f3225bc8ea', 'bb0a4b5f-b451-5199-a499-bcca56cee984', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3a6b34d-ea1b-52b3-9561-0ec926f91339', 'bb0a4b5f-b451-5199-a499-bcca56cee984', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6243ea16-ebdf-5565-b4ab-8ff8e7180ff1', 'bb0a4b5f-b451-5199-a499-bcca56cee984', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e4cea284-100a-5659-9992-7999a1478522', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage 1? Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cave paintings inspired Michelangelo to paint the ceiling of the Sistine Chapel.
2
It now seems that cave paintings were painted in one go and then left untouched.
3
Dr Pike is focusing on dating artefacts found on the ground in the caves.
4
There are a number of disadvantages to using carbon dating to date paintings and carvings.
5
The Altamira cave contains more cave paintings than any other cave in Europe.

4 ____ There are a number of disadvantages to using carbon dating to date paintings and carvings.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74a19ff1-6457-5aa1-9083-c511f6e95eec', 'e4cea284-100a-5659-9992-7999a1478522', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f1b4f94-e7bf-59da-8da7-9a28306703b7', 'e4cea284-100a-5659-9992-7999a1478522', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72add161-a55a-5049-82dc-b0d753dc77d8', 'e4cea284-100a-5659-9992-7999a1478522', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('58fd0560-f782-5131-bb93-c80663cca0ca', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage 1? Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cave paintings inspired Michelangelo to paint the ceiling of the Sistine Chapel.
2
It now seems that cave paintings were painted in one go and then left untouched.
3
Dr Pike is focusing on dating artefacts found on the ground in the caves.
4
There are a number of disadvantages to using carbon dating to date paintings and carvings.
5
The Altamira cave contains more cave paintings than any other cave in Europe.

5 ____ The Altamira cave contains more cave paintings than any other cave in Europe.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0c0d342-c896-5e80-a41e-b5b1eab309e4', '58fd0560-f782-5131-bb93-c80663cca0ca', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ba0e053-5991-507e-bb17-e56a338d1b76', '58fd0560-f782-5131-bb93-c80663cca0ca', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84082816-8836-51fd-b9f3-7e9c42cd9023', '58fd0560-f782-5131-bb93-c80663cca0ca', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8558aa93-6860-5114-a2b5-bc395d43c7c3', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-8
Questions 6-8
Choose the correct letter,
A, B, C
or
D.
6
Dr Pike believes that
A
most caves remained undiscovered for thousands of years.
B
archaeologists should not have excavated the caves at all.
C
the caves were uninhabited but were treated as important.
D
the paintings were painted by the people living in the caves.
7
Uranium series dating
A
was previously used for other purposes.
B
is a technique which was invented by Dr Pike.
C
relies on the presence of stalactites in the caves.
D
only works with caves which are underwater.
8
Professor Pablo Arias
A
is sceptical about the benefits of the new dating technique.
B
is enthusiastic about what the new technique will achieve.
C
used the technique to successfully date Creswell Crags.
D
believes it is necessary only to study the symbols in the art.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('665d2f67-80b4-5f6a-a51e-bae17a3a0990', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-8
Questions 6-8
Choose the correct letter,
A, B, C
or
D.
6
Dr Pike believes that
A
most caves remained undiscovered for thousands of years.
B
archaeologists should not have excavated the caves at all.
C
the caves were uninhabited but were treated as important.
D
the paintings were painted by the people living in the caves.
7
Uranium series dating
A
was previously used for other purposes.
B
is a technique which was invented by Dr Pike.
C
relies on the presence of stalactites in the caves.
D
only works with caves which are underwater.
8
Professor Pablo Arias
A
is sceptical about the benefits of the new dating technique.
B
is enthusiastic about what the new technique will achieve.
C
used the technique to successfully date Creswell Crags.
D
believes it is necessary only to study the symbols in the art.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df7fb73c-1551-5fdf-b6ab-1b3f0ef8a7e4', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-8
Questions 6-8
Choose the correct letter,
A, B, C
or
D.
6
Dr Pike believes that
A
most caves remained undiscovered for thousands of years.
B
archaeologists should not have excavated the caves at all.
C
the caves were uninhabited but were treated as important.
D
the paintings were painted by the people living in the caves.
7
Uranium series dating
A
was previously used for other purposes.
B
is a technique which was invented by Dr Pike.
C
relies on the presence of stalactites in the caves.
D
only works with caves which are underwater.
8
Professor Pablo Arias
A
is sceptical about the benefits of the new dating technique.
B
is enthusiastic about what the new technique will achieve.
C
used the technique to successfully date Creswell Crags.
D
believes it is necessary only to study the symbols in the art.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c04079d9-e94a-577f-a70f-ddaf41c72a7b', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-14
Questions 9-14
What is said about each of these things found in the caves?
Choose your answers from the box and write the letters
A-H
next to Questions
9-14
.
A
When this is removed, it damages the painting.
B
This can damage the stalactites and stalagmites in the caves.
C
Over time, this turns into a different element.
D
We could determine when it was made, but not when it was used.
E
This is produced as a result of radioactive decay.
F
Scientists used to think that this was a mineral.
G
This contains no carbon-based elements at all.
H
This can act as a firm coating over something.
9
charcoal
10
pigment
11
carving
12
uranium
13
calcium carbonate
14
thorium

9 ____ charcoal$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33b3f71b-7764-5d8d-8d6c-20946e290fd7', 'c04079d9-e94a-577f-a70f-ddaf41c72a7b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d27fa810-fc9d-5932-9033-9ca49c43004d', 'c04079d9-e94a-577f-a70f-ddaf41c72a7b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e79a931-e1bd-5ab6-a152-c29c72055386', 'c04079d9-e94a-577f-a70f-ddaf41c72a7b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('768f62f8-9561-57c9-aba0-62a73092535b', 'c04079d9-e94a-577f-a70f-ddaf41c72a7b', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49d1652c-f6e2-5c8d-bce2-9f6d75bb60cc', 'c04079d9-e94a-577f-a70f-ddaf41c72a7b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eae7c21d-f02c-51a1-85ea-c6ee758250ca', 'c04079d9-e94a-577f-a70f-ddaf41c72a7b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af583f06-0e39-57ba-b1d8-dc0d929b222e', 'c04079d9-e94a-577f-a70f-ddaf41c72a7b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64d9075c-3e98-550c-8d38-f39bcd1d77ed', 'c04079d9-e94a-577f-a70f-ddaf41c72a7b', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f8e319dc-6537-5e6c-9e9f-62688755d220', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-14
Questions 9-14
What is said about each of these things found in the caves?
Choose your answers from the box and write the letters
A-H
next to Questions
9-14
.
A
When this is removed, it damages the painting.
B
This can damage the stalactites and stalagmites in the caves.
C
Over time, this turns into a different element.
D
We could determine when it was made, but not when it was used.
E
This is produced as a result of radioactive decay.
F
Scientists used to think that this was a mineral.
G
This contains no carbon-based elements at all.
H
This can act as a firm coating over something.
9
charcoal
10
pigment
11
carving
12
uranium
13
calcium carbonate
14
thorium

10 ____ pigment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da43a617-9deb-5a3e-98a3-572df78ecae8', 'f8e319dc-6537-5e6c-9e9f-62688755d220', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f68410d-590c-5598-9774-02d3c08c2ff7', 'f8e319dc-6537-5e6c-9e9f-62688755d220', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71c3bea9-f203-537d-aca5-3c407e460b5c', 'f8e319dc-6537-5e6c-9e9f-62688755d220', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('324e8e17-f54f-5512-85b1-fb3ca8ec365f', 'f8e319dc-6537-5e6c-9e9f-62688755d220', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c8082bc-cd38-518a-a99f-1123a29c96b3', 'f8e319dc-6537-5e6c-9e9f-62688755d220', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0707f16d-7bd3-59e4-944f-65ca81eb21bc', 'f8e319dc-6537-5e6c-9e9f-62688755d220', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eee126f0-19a0-535c-b524-678534ec9e61', 'f8e319dc-6537-5e6c-9e9f-62688755d220', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('faf0d925-79fe-55bb-aea5-f12fc9fceb99', 'f8e319dc-6537-5e6c-9e9f-62688755d220', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac6bdea6-d89b-531e-9379-2042874f72a6', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-14
Questions 9-14
What is said about each of these things found in the caves?
Choose your answers from the box and write the letters
A-H
next to Questions
9-14
.
A
When this is removed, it damages the painting.
B
This can damage the stalactites and stalagmites in the caves.
C
Over time, this turns into a different element.
D
We could determine when it was made, but not when it was used.
E
This is produced as a result of radioactive decay.
F
Scientists used to think that this was a mineral.
G
This contains no carbon-based elements at all.
H
This can act as a firm coating over something.
9
charcoal
10
pigment
11
carving
12
uranium
13
calcium carbonate
14
thorium

11 ____ carving$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e977de4-dcec-5e8f-835c-625346dcb4d1', 'ac6bdea6-d89b-531e-9379-2042874f72a6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28431f1a-e040-56aa-8ddb-2dea0c9566d5', 'ac6bdea6-d89b-531e-9379-2042874f72a6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b611daf8-e0ce-5263-aedc-605f786be03a', 'ac6bdea6-d89b-531e-9379-2042874f72a6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8eab913d-ccad-5166-b709-dfac027f2035', 'ac6bdea6-d89b-531e-9379-2042874f72a6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91906f70-034c-58d1-b004-03299ab87044', 'ac6bdea6-d89b-531e-9379-2042874f72a6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b121c79f-b7fe-5702-a5b6-8d78df8a9ec5', 'ac6bdea6-d89b-531e-9379-2042874f72a6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6afc7fe-fcac-50b1-88d5-bf3f3393c437', 'ac6bdea6-d89b-531e-9379-2042874f72a6', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('247647d6-af18-50c4-bc19-68a24d5f9857', 'ac6bdea6-d89b-531e-9379-2042874f72a6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('33bbffe9-1177-52cc-a8f7-f4bb918f85aa', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-14
Questions 9-14
What is said about each of these things found in the caves?
Choose your answers from the box and write the letters
A-H
next to Questions
9-14
.
A
When this is removed, it damages the painting.
B
This can damage the stalactites and stalagmites in the caves.
C
Over time, this turns into a different element.
D
We could determine when it was made, but not when it was used.
E
This is produced as a result of radioactive decay.
F
Scientists used to think that this was a mineral.
G
This contains no carbon-based elements at all.
H
This can act as a firm coating over something.
9
charcoal
10
pigment
11
carving
12
uranium
13
calcium carbonate
14
thorium

12 ____ uranium$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4582b237-6371-5fc4-a6fe-86f1b8b9bda1', '33bbffe9-1177-52cc-a8f7-f4bb918f85aa', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cb997bf-48c8-5b06-a296-9263cb3e75c0', '33bbffe9-1177-52cc-a8f7-f4bb918f85aa', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59c5de13-d1ed-53f3-bc3a-9810eaab7d50', '33bbffe9-1177-52cc-a8f7-f4bb918f85aa', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d61047ea-c7d4-5c45-9aa5-d4d69dc60cd0', '33bbffe9-1177-52cc-a8f7-f4bb918f85aa', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63ed5f50-9923-58ca-a691-c63c56a89af0', '33bbffe9-1177-52cc-a8f7-f4bb918f85aa', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97634a8a-097e-5411-a494-826a7b16ebf1', '33bbffe9-1177-52cc-a8f7-f4bb918f85aa', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cd46c86-87fd-5426-9253-c86234f5a13a', '33bbffe9-1177-52cc-a8f7-f4bb918f85aa', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23cf71ed-6cd1-5e5a-9883-ad3e1eb9cad9', '33bbffe9-1177-52cc-a8f7-f4bb918f85aa', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('89d08f4b-c238-57d4-b91b-3a4cbadcac73', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 9-14
Questions 9-14
What is said about each of these things found in the caves?
Choose your answers from the box and write the letters
A-H
next to Questions
9-14
.
A
When this is removed, it damages the painting.
B
This can damage the stalactites and stalagmites in the caves.
C
Over time, this turns into a different element.
D
We could determine when it was made, but not when it was used.
E
This is produced as a result of radioactive decay.
F
Scientists used to think that this was a mineral.
G
This contains no carbon-based elements at all.
H
This can act as a firm coating over something.
9
charcoal
10
pigment
11
carving
12
uranium
13
calcium carbonate
14
thorium

13 ____ calcium carbonate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7941154-b22a-54e7-8d5f-c47dec54b603', '89d08f4b-c238-57d4-b91b-3a4cbadcac73', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65ba0912-3137-5921-9174-33e9415ddfbd', '89d08f4b-c238-57d4-b91b-3a4cbadcac73', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6629dee2-4fb6-55c7-ac5b-07a89c14ad30', '89d08f4b-c238-57d4-b91b-3a4cbadcac73', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1b26fec-c1ae-57bc-9792-a795f3953379', '89d08f4b-c238-57d4-b91b-3a4cbadcac73', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a4e2adf-64e7-5292-9f8f-eec84cbce764', '89d08f4b-c238-57d4-b91b-3a4cbadcac73', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b732033-34e8-5fa7-ae34-2a0a30d3a8df', '89d08f4b-c238-57d4-b91b-3a4cbadcac73', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2926fcd-43d0-5ca7-9b88-65dcc2b1db1b', '89d08f4b-c238-57d4-b91b-3a4cbadcac73', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96b18d9a-1e48-58dc-a6e4-601255cfd40b', '89d08f4b-c238-57d4-b91b-3a4cbadcac73', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8723d611-5b3e-504a-9a27-7245ae2ee78a', 'cb63e189-9b0f-523f-9d91-8a610c94b457', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 9-14
Questions 9-14
What is said about each of these things found in the caves?
Choose your answers from the box and write the letters
A-H
next to Questions
9-14
.
A
When this is removed, it damages the painting.
B
This can damage the stalactites and stalagmites in the caves.
C
Over time, this turns into a different element.
D
We could determine when it was made, but not when it was used.
E
This is produced as a result of radioactive decay.
F
Scientists used to think that this was a mineral.
G
This contains no carbon-based elements at all.
H
This can act as a firm coating over something.
9
charcoal
10
pigment
11
carving
12
uranium
13
calcium carbonate
14
thorium

14 ____ thorium$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4eb5a037-ac5e-56b9-b797-a31b5b259017', '8723d611-5b3e-504a-9a27-7245ae2ee78a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5ec652e-a915-5902-b51d-ea62dc0e2f60', '8723d611-5b3e-504a-9a27-7245ae2ee78a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('170ad7a2-ba34-57e1-b010-30cbd84cae3c', '8723d611-5b3e-504a-9a27-7245ae2ee78a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e713847b-4e63-5f61-872c-80eb0d08b1b7', '8723d611-5b3e-504a-9a27-7245ae2ee78a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a853bb7-a050-5d3e-8d75-9b1f9f0a0092', '8723d611-5b3e-504a-9a27-7245ae2ee78a', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1367ee71-7487-51ed-a7f2-c46f025e8aa8', '8723d611-5b3e-504a-9a27-7245ae2ee78a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('883aefd1-1ba7-585a-b1a8-ee06a8eaecb7', '8723d611-5b3e-504a-9a27-7245ae2ee78a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cde7720-a85c-5468-98d3-46c7813c2ec9', '8723d611-5b3e-504a-9a27-7245ae2ee78a', 8, $md$H$md$, false);

COMMIT;
