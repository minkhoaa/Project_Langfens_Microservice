BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-history-of-timekeeping-1404'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-history-of-timekeeping-1404';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-history-of-timekeeping-1404';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-history-of-timekeeping-1404';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('21cc43b4-6777-5d96-9e0f-a51ec3924df2', 'ielts-reading-history-of-timekeeping-1404', $t$History of timekeeping$t$, $md$## History of timekeeping

Nguồn:
- Test: https://mini-ielts.com/1404/reading/history-of-timekeeping
- Solution: https://mini-ielts.com/1404/view-solution/reading/history-of-timekeeping$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', '21cc43b4-6777-5d96-9e0f-a51ec3924df2', 1, $t$Reading — History of timekeeping$t$, $md$Read the passage and answer questions **1–13**.

### Passage: History of timekeeping

Ever since man first noticed the regular movement of the Sun and the stars, we have wondered about the passage of time. Prehistoric people first recorded the phases of the Moon some 30,000 years ago, and recording time has been a way by which humanity has observed the heavens and represented the progress of civilization.

The earliest natural events to be recognized were in the heavens, but during the course of the year, there were many other events that indicated significant changes in the environment. Seasonal winds and rains, the flooding of rivers, the flowering of trees and plants, and the breeding cycles or migration of animals and birds, all led to natural divisions of the year, and further observation and local customs led to the recognition of the seasons.

Egyptian shadow clocks divided daytime into 12 parts with each part further divided into more precise parts. One type of shadow clock consisted of a long stem with five variable marks and an elevated crossbar which cast a shadow over those marks. It was positioned eastward in the morning and was turned west at noon. Obelisks functioned in much the same manner: the shadow cast on the markers around it allowed the Egyptians to calculate the time. The obelisk also indicated whether it was morning or afternoon, as well as the summer and winter solstices. 1500 BCE, was similar in shape to a bent T-square. It measured the passage of time by the shadow cast by its crossbar on a non-linear rule. The T was oriented eastward in the mornings and turned around at noon so that it could cast its shadow in the opposite direction. Although accurate, shadow clocks relied on the sun, and so were useless at night and in cloudy weather.

Inventions for measuring and regulating time

The early inventions were made to divide the day or the night into different periods in order to regulate work or ritual, so the lengths of the time periods varied greatly from place to place and from one culture to another.

Oil lamps

There is archaeological evidence of oil lamps about 4,000 BCE, and the Chinese were using oil for heating and lighting by 2,000 BCE. Oil lamps are still significant in religious practices, symbolic of the journey from darkness and ignorance to light and knowledge. The shape of the lamp gradually evolved into the typical pottery style shown. It was possible to devise a way of measuring the level in the oil reservoir to measure the passing of time.

Candle Clocks

Marked candles were used for telling the time in China from the sixth century CE. There is a popular story that King Alfred the Great invented the candle clock, but we know they were in use in England from the tenth century CE. However, the rate of burning is subject to draughts, and the variable quality of the wax. Life oil lamps, candles were used to mark the passage of time from one event to another, rather than tell the time of day.

Water Clocks

The water clock, or clepsydra, appears to have been invented about 1,500 BCE and was a device which relied on the steady flow of water from or into a container. Measurements could be marked on the container or on a receptacle for the water. In comparison with the candle or the oil lamp, the clepsydra was more reliable, but the water flow still depended on the variation of pressure from the head of water in the container.

Astronomical and astrological clock making was developed in China from 200 to 1300 CE. Early Chinese clepsydras drove various mechanisms illustrating astronomical phenomena. The astronomer Su Sung and his associates built an elaborate clepsydra in 1088 CE. This device incorporated a water-driven bucket system originally invented about 725 CE. Among the displays were a bronze power-driven rotating celestial globe, and manikins that rang gongs, and indicated special times of the day.

Hour Glasses or Sandglasses

As the technology of glass-blowing developed, from some time in the 14th century it became possible to make sandglasses. Originally, sandglasses were used as a measure for periods of time like the lamps or candles, but as clocks became more accurate they were used to calibrate sandglasses to measure specific periods of time, and to determine the duration of sermons, university lectures, and even periods of torture.

The Division of the Day and the Length of the ‘Hour’ An Egyptian sundial from about 1,500 BCE is the earliest evidence of the division of the day into equal parts, but the sundial was no use at night. The passage of time was extremely important for astronomers and priests who were responsible for determining the exact hour for the daily rituals and for the important religious festivals, so a water clock was invented.

The Merkhet

The Egyptians improved upon the sundial with a ‘merkhet’, one of the oldest known astronomical instruments. It was developed around 600 BCE and uses a string with a weight as a plumb line to obtain a true vertical line, as in the picture. The other object is the rib of a palm leaf, stripped of its fronds and split at one end, making a thin slit for a sight.

A pair of merkhets were used to establish a North-South direction by lining them up one behind the other with the Pole Star. Viewing the plumb lines through the sight made sure the two merkhets and the sight were in the same straight line with the Pole Star. This allowed for the measurement of night-time events with a water clock when certain stars crossed the vertical plumb line (a ‘transit line’), and these events could then be recorded by ‘night-time lines’ drawn on a sundial.

There are various theories about how the 24 hour day developed. The fact that the day was divided into 12 hours might be because 12 is a factor of 60, and both the Babylonian and Egyptian civilisations recognised a zodiac cycle of 12 constellations. On the other hand, (excuse the pun) finger-counting with base 12 was a possibility. The fingers each have 3 joints, and so counting on the joints gives one ‘full hand’ of 12.

In classical Greek and Roman times they used twelve hours from sunrise to sunset; but since summer days and winter nights are longer than winter days and summer nights, the lengths of the hours varied throughout the year.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('785484ed-3f3a-575d-a302-3714f9addab3', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
Timekeeper’s exact date of origin was not clear today.
2
People use candles and oil lamps for recording time to do things in the early days.
3
Oil lamps are used for religious beliefs in 4000 BCE.
4
The sundials have always been inaccurate to record time in ancient Egypt.

1 ____ Timekeeper’s exact date of origin was not clear today.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2be5b5b0-51ae-5f1e-91cd-c8c8a9c49621', '785484ed-3f3a-575d-a302-3714f9addab3', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e47f29c-d9c7-5977-b2de-e63c008f6a3e', '785484ed-3f3a-575d-a302-3714f9addab3', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82363caf-c263-5947-87a3-40cf4169a040', '785484ed-3f3a-575d-a302-3714f9addab3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cd72e6e2-0411-515d-b0c6-7fe5c2b30d9f', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
Timekeeper’s exact date of origin was not clear today.
2
People use candles and oil lamps for recording time to do things in the early days.
3
Oil lamps are used for religious beliefs in 4000 BCE.
4
The sundials have always been inaccurate to record time in ancient Egypt.

2 ____ People use candles and oil lamps for recording time to do things in the early days.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ea73c88-29d5-59bd-b850-615f594f047e', 'cd72e6e2-0411-515d-b0c6-7fe5c2b30d9f', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4d0b225-45b1-5b32-a239-111f07473310', 'cd72e6e2-0411-515d-b0c6-7fe5c2b30d9f', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7e2d830-af61-5317-bd7a-860e66f46f6f', 'cd72e6e2-0411-515d-b0c6-7fe5c2b30d9f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f56938be-46f5-52de-8182-d295a2bd6de7', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
Timekeeper’s exact date of origin was not clear today.
2
People use candles and oil lamps for recording time to do things in the early days.
3
Oil lamps are used for religious beliefs in 4000 BCE.
4
The sundials have always been inaccurate to record time in ancient Egypt.

3 ____ Oil lamps are used for religious beliefs in 4000 BCE.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('820b617b-3c4e-5db1-b916-28b84b42d572', 'f56938be-46f5-52de-8182-d295a2bd6de7', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7028e3c8-bda3-5dbe-95ca-43a611df0b5a', 'f56938be-46f5-52de-8182-d295a2bd6de7', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4e95ff3-30ca-5066-942a-05982db38582', 'f56938be-46f5-52de-8182-d295a2bd6de7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a90ba5ee-b23b-5efc-8ceb-e6ffc9a239f0', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT
GIVEN
if the information is not given in the passage
1
Timekeeper’s exact date of origin was not clear today.
2
People use candles and oil lamps for recording time to do things in the early days.
3
Oil lamps are used for religious beliefs in 4000 BCE.
4
The sundials have always been inaccurate to record time in ancient Egypt.

4 ____ The sundials have always been inaccurate to record time in ancient Egypt.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d9e28a4-da9b-595b-b23c-e6d085489134', 'a90ba5ee-b23b-5efc-8ceb-e6ffc9a239f0', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49609ad7-9987-58d7-9d96-e0696862071b', 'a90ba5ee-b23b-5efc-8ceb-e6ffc9a239f0', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe315725-39ec-562b-9f4d-25258d2922f5', 'a90ba5ee-b23b-5efc-8ceb-e6ffc9a239f0', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('22f4dc2a-5039-5fb5-b8f3-67cca5b3dde6', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Write the correct letter
A-D
, in boxes
5-10
on your answer sheet
NB
You may use any letter more than once.
A
Wooden shadow clock
B
Clepsydra
C
Sandglasses
D
lamp oil candle
5
It is used the container tag position recording time
6
It is used to measure a particular time
7
It is used only in the sunny day
8
It is used oil cistern to measure the passage of time
9
It isn’t only used to tell the time
10
It is more accurate than candles and oil lamps

5 ____ It is used the container tag position recording time$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9696f9e5-39e9-55a7-944c-d254261ba958', '22f4dc2a-5039-5fb5-b8f3-67cca5b3dde6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f354dbb-77d9-55f6-b2f5-6531b905fe33', '22f4dc2a-5039-5fb5-b8f3-67cca5b3dde6', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c90a0026-c5cb-57c2-9b6e-f3d413a0305b', '22f4dc2a-5039-5fb5-b8f3-67cca5b3dde6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a7ac3ce-eab3-51d0-8ea6-c25af2ddcb38', '22f4dc2a-5039-5fb5-b8f3-67cca5b3dde6', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('18860994-1ed4-5db6-84d7-9944eed72c8e', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Write the correct letter
A-D
, in boxes
5-10
on your answer sheet
NB
You may use any letter more than once.
A
Wooden shadow clock
B
Clepsydra
C
Sandglasses
D
lamp oil candle
5
It is used the container tag position recording time
6
It is used to measure a particular time
7
It is used only in the sunny day
8
It is used oil cistern to measure the passage of time
9
It isn’t only used to tell the time
10
It is more accurate than candles and oil lamps

6 ____ It is used to measure a particular time$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e437e72-b991-5337-acc6-9fdb93a897d1', '18860994-1ed4-5db6-84d7-9944eed72c8e', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f5f7152-c80a-5883-b37b-d5cdcadb1297', '18860994-1ed4-5db6-84d7-9944eed72c8e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e57f09b2-dede-52c0-add7-88c1259418ce', '18860994-1ed4-5db6-84d7-9944eed72c8e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2eaa17b6-9cea-52b3-b3f9-bce45b5c459c', '18860994-1ed4-5db6-84d7-9944eed72c8e', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9c66493e-7e4f-5e74-93f6-58d99562dc61', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Write the correct letter
A-D
, in boxes
5-10
on your answer sheet
NB
You may use any letter more than once.
A
Wooden shadow clock
B
Clepsydra
C
Sandglasses
D
lamp oil candle
5
It is used the container tag position recording time
6
It is used to measure a particular time
7
It is used only in the sunny day
8
It is used oil cistern to measure the passage of time
9
It isn’t only used to tell the time
10
It is more accurate than candles and oil lamps

7 ____ It is used only in the sunny day$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3aec0f53-230d-5a4d-9103-9bb53800c9cf', '9c66493e-7e4f-5e74-93f6-58d99562dc61', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d07d410-2717-50d9-b3f0-fde9d9451429', '9c66493e-7e4f-5e74-93f6-58d99562dc61', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35a8f625-dc0e-58ba-bfb2-b3e5eaac9416', '9c66493e-7e4f-5e74-93f6-58d99562dc61', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2b86b2a-2632-5f16-a2dd-8fc1625d1e0f', '9c66493e-7e4f-5e74-93f6-58d99562dc61', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('40181e18-315c-5742-b37a-f85490c8d7fe', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Write the correct letter
A-D
, in boxes
5-10
on your answer sheet
NB
You may use any letter more than once.
A
Wooden shadow clock
B
Clepsydra
C
Sandglasses
D
lamp oil candle
5
It is used the container tag position recording time
6
It is used to measure a particular time
7
It is used only in the sunny day
8
It is used oil cistern to measure the passage of time
9
It isn’t only used to tell the time
10
It is more accurate than candles and oil lamps

8 ____ It is used oil cistern to measure the passage of time$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e302e266-3092-51ef-9b5f-dea8d138dade', '40181e18-315c-5742-b37a-f85490c8d7fe', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('538c9ad4-0b1c-5ca2-a151-7bfb14f3431a', '40181e18-315c-5742-b37a-f85490c8d7fe', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fd2fcda-75f1-5088-97be-a73b1843a57b', '40181e18-315c-5742-b37a-f85490c8d7fe', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb03d9d8-2b08-5501-8ce7-5fec89caa3d5', '40181e18-315c-5742-b37a-f85490c8d7fe', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d4398d20-c99c-54f0-a94f-7b3d36ef3add', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Write the correct letter
A-D
, in boxes
5-10
on your answer sheet
NB
You may use any letter more than once.
A
Wooden shadow clock
B
Clepsydra
C
Sandglasses
D
lamp oil candle
5
It is used the container tag position recording time
6
It is used to measure a particular time
7
It is used only in the sunny day
8
It is used oil cistern to measure the passage of time
9
It isn’t only used to tell the time
10
It is more accurate than candles and oil lamps

9 ____ It isn’t only used to tell the time$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('771e3d48-3ae8-5242-bb2a-afc5db835b89', 'd4398d20-c99c-54f0-a94f-7b3d36ef3add', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de779ae7-7c76-593e-a64b-fa8743bab15c', 'd4398d20-c99c-54f0-a94f-7b3d36ef3add', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9882458f-d0f4-5c37-a88c-7dce59bf58fd', 'd4398d20-c99c-54f0-a94f-7b3d36ef3add', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e673007-242a-53d2-b10f-b671f09e7304', 'd4398d20-c99c-54f0-a94f-7b3d36ef3add', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e973423e-7bf9-528a-bdda-5685fa7ed006', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Write the correct letter
A-D
, in boxes
5-10
on your answer sheet
NB
You may use any letter more than once.
A
Wooden shadow clock
B
Clepsydra
C
Sandglasses
D
lamp oil candle
5
It is used the container tag position recording time
6
It is used to measure a particular time
7
It is used only in the sunny day
8
It is used oil cistern to measure the passage of time
9
It isn’t only used to tell the time
10
It is more accurate than candles and oil lamps

10 ____ It is more accurate than candles and oil lamps$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a342b9a-4969-5010-9db8-2be33b8d47eb', 'e973423e-7bf9-528a-bdda-5685fa7ed006', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3286801-06d3-58be-9ed9-77a84bd67e26', 'e973423e-7bf9-528a-bdda-5685fa7ed006', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a1fae7e-8bca-54bc-a163-f8ca74521d13', 'e973423e-7bf9-528a-bdda-5685fa7ed006', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8ac2f4b-b204-549f-8c54-3cbc97418fed', 'e973423e-7bf9-528a-bdda-5685fa7ed006', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2ce7bce7-0aac-5e99-a30e-d81243d15385', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
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
11-13
on your answer.
11
Which picture shows the working principle of clepsydra?
A
B
C
D
12
Which picture best describes the wooden shadow?
A
B
C
D
13
The picture below illustrates the oil lamp clock’s working
A
B
C
D

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d01bf0ad-4a8a-5d33-b906-34efb12a7a33', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
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
11-13
on your answer.
11
Which picture shows the working principle of clepsydra?
A
B
C
D
12
Which picture best describes the wooden shadow?
A
B
C
D
13
The picture below illustrates the oil lamp clock’s working
A
B
C
D

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3323ec36-bffe-5519-a9f7-4b27a27f8c96', '901cac32-6f8a-578f-bbe2-e8ffdb00f2a0', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
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
11-13
on your answer.
11
Which picture shows the working principle of clepsydra?
A
B
C
D
12
Which picture best describes the wooden shadow?
A
B
C
D
13
The picture below illustrates the oil lamp clock’s working
A
B
C
D

Choose the correct letter, A , B , C or D .$md$, NULL);

COMMIT;
