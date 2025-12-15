BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-detection-of-a-meteorite-lake-1269'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-detection-of-a-meteorite-lake-1269';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-detection-of-a-meteorite-lake-1269';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-detection-of-a-meteorite-lake-1269';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('fc7e0035-55a2-5dd2-ae61-4ee88c802306', 'ielts-reading-detection-of-a-meteorite-lake-1269', $t$Detection of a meteorite Lake$t$, $md$## Detection of a meteorite Lake

Nguồn:
- Test: https://mini-ielts.com/1269/reading/detection-of-a-meteorite-lake
- Solution: https://mini-ielts.com/1269/view-solution/reading/detection-of-a-meteorite-lake$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('0741d075-4942-5f83-9e07-7ab530ae20f1', 'fc7e0035-55a2-5dd2-ae61-4ee88c802306', 1, $t$Reading — Detection of a meteorite Lake$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Detection of a meteorite Lake

A

As the sun rose over picturesque Lake Bosumtwi, a team of Syracuse University researchers prepared for another day of using state-of-the-art equipment to help bottom. Nestled in the heart of Ghana, the lake holds an untapped reservoir of information that could help scientists predict future climate changes by looking at evidence from the past. This information will also improve the scientists’ understanding of the changes that occur in a region struck by a massive meteorite.

B

The project, led by earth sciences professor Christopher Scholz of the College of Arts and Sciences and funded by the National Science Foundation (NSF), is the first large-scale effort to study Lake Bosumtwi, which formed 1.1 million years ago when a giant meteor crashed into the Earth’s surface. The resulting crater is one of the largest and most well-preserved geologically young craters in the world, says Scholz, who is collaborating on the project with researchers from the University of Arizona, the University of South Carolina, the University of Rhode Island, and several Ghanaian institutions. “Our data should provide information about what happens when an impact hits hard, pre-Cambrian, crystalline rocks that are a billion years old,” he says.

C

Equally important is the fact that the lake, which is about 8 kilometers in diameter, has no natural outlet. The rim of the crater rises about 250 meters above the water’s surface. Streams flow into the lake, Scholz says, but the water leaves only by evaporation, or by seeping through the lake sediments. For the past million years, the lake has acted as a tropical rain gauge, filling and drying with changes in precipitation and the tropical climate. The record of those changes is hidden in the sediment below the lake bottom. “The lake is one of the best sites in the world for the study of tropical climate changes,” Scholz says. “The tropics are the heat engine for the Earth’s climate. To understand the global climate, we need to have records of climate changes from many sites around the world, including the tropics.”

D

Before the researchers could explore the lake’s subsurface, they needed a boat with a large, working deck area that could carry eight tons of scientific equipment. The boat – dubbed R/V Kilindi – was built in Florida last year. It was constructed in modules that were dismantled, packed inside a shipping container, and reassembled over a 10-day period in late November and early December 1999 in the rural village of Abono, Ghana. The research team then spent the next two weeks testing the boat and equipment before returning to the United States for the holidays.

E

In mid-January, five members of the team – Keely Brooks, an earth sciences graduate student; Peter Cattaneo, a research analyst; and Kiram Lezzar, a postdoctoral scholar, all from SU; James McGill, a geophysical field engineer; and Nick Peters, a Ph.D. student in geophysics from the University of Miami – returned to Abono to begin collecting data about the lake’s subsurface using a technique called seismic reflection profiling. In this process, a high-pressure air gun is used to create small, pneumatic explosions in the water. The sound energy penetrates about 1,000 to 2,000 meters into the lake’s subsurface before bouncing back to the surface of the water.

F

The reflected sound energy is detected by underwater microphones – called hydrophones – embedded in a 50-meter-long cable that is towed behind the boat as it crosses the lake in a carefully designed grid pattern. On-board computers record the signals, and the resulting data are then processed and analyzed in the laboratory. “The results will give us a good idea of the shape of the basin, how thick the layers of sediment are, and when and where there were major changes in sediment accumulation,” Scholz says. “We are now developing a three-dimensional perspective of the lake’s subsurface and the layers of sediment that have been laid down.”

G

Team members spent about four weeks in Ghana collecting the data. They worked seven days a week, arriving at the lake just after sunrise. On a good day, when everything went as planned, the team could collect data and be back at the dock by early afternoon. Except for a few relatively minor adjustments, the equipment and the boat worked well. Problems that arose were primarily non-scientific – tree stumps, fishing nets, cultural barriers, and occasional misunderstandings with local villagers.

H

Lake Bosumtwi, the largest natural freshwater lake in the country, is sacred to the Ashanti people, who believe their souls come to the lake to bid farewell to their god. The lake is also the primary source of fish for the 26 surrounding villages. Conventional canoes and boats are forbidden. Fishermen travel on the lake by floating on traditional planks they propel with small paddles. Before the research project could begin, Scholz and his Ghanaian counterparts had to secure special permission from tribal chiefs to put the R/V Kilindi on the lake.

I

When the team began gathering data, rumors flew around the lake as to why the researchers were there. “Some thought we were dredging the lake for gold, others thought we were going to drain the lake or that we had bought the lake,” Cattaneo says. “But once the local people understood why we were there, they were very helpful.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae74b207-1767-5c71-bce8-4d24bc1ef8f0', '0741d075-4942-5f83-9e07-7ab530ae20f1', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
With the investigation of the lake, the scientist may predict the climate changes in the future.
2
The crater resulted from a meteorite impact is the largest and most preserved one in the world.
3
The water stored in lake Bosumtwi was gone only by seeping through the lake sediments.
4
Historical climate changes can be detected by the analysis of the sediment in the lake.
5
The greatest obstacle to the research of scientists had been the interference by the locals due to their indigenous believes.

1 ____ With the investigation of the lake, the scientist may predict the climate changes in the future.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b0ef498-4ec3-54e4-b146-23b8147f4b3f', 'ae74b207-1767-5c71-bce8-4d24bc1ef8f0', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7026d202-9653-583d-926e-61314789a941', 'ae74b207-1767-5c71-bce8-4d24bc1ef8f0', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c147081-482c-5458-930c-c2e4014c71dc', 'ae74b207-1767-5c71-bce8-4d24bc1ef8f0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d6ea87c-58f3-555a-bb2b-c42274cab1f2', '0741d075-4942-5f83-9e07-7ab530ae20f1', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
With the investigation of the lake, the scientist may predict the climate changes in the future.
2
The crater resulted from a meteorite impact is the largest and most preserved one in the world.
3
The water stored in lake Bosumtwi was gone only by seeping through the lake sediments.
4
Historical climate changes can be detected by the analysis of the sediment in the lake.
5
The greatest obstacle to the research of scientists had been the interference by the locals due to their indigenous believes.

2 ____ The crater resulted from a meteorite impact is the largest and most preserved one in the world.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7a1a8e2-3aa2-5d4a-b66c-d85e0fa1e436', '3d6ea87c-58f3-555a-bb2b-c42274cab1f2', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83b60646-c08f-53c1-b4da-831d7d4a9f83', '3d6ea87c-58f3-555a-bb2b-c42274cab1f2', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fecd36bd-7473-5488-a1b5-b90c9ad7cfdf', '3d6ea87c-58f3-555a-bb2b-c42274cab1f2', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b0be1c6c-7d70-5f5f-8aa7-a7452c7eb5b1', '0741d075-4942-5f83-9e07-7ab530ae20f1', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
With the investigation of the lake, the scientist may predict the climate changes in the future.
2
The crater resulted from a meteorite impact is the largest and most preserved one in the world.
3
The water stored in lake Bosumtwi was gone only by seeping through the lake sediments.
4
Historical climate changes can be detected by the analysis of the sediment in the lake.
5
The greatest obstacle to the research of scientists had been the interference by the locals due to their indigenous believes.

3 ____ The water stored in lake Bosumtwi was gone only by seeping through the lake sediments.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a34afc0-2cb8-5fe8-9354-7c6229e8c65d', 'b0be1c6c-7d70-5f5f-8aa7-a7452c7eb5b1', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('708b576b-62c3-517d-b5b0-2eb5362ed3cd', 'b0be1c6c-7d70-5f5f-8aa7-a7452c7eb5b1', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fae0a17-13d9-575c-9283-873ca5316522', 'b0be1c6c-7d70-5f5f-8aa7-a7452c7eb5b1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8b88521e-d90a-5af8-b530-f5fc23fce0b4', '0741d075-4942-5f83-9e07-7ab530ae20f1', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
With the investigation of the lake, the scientist may predict the climate changes in the future.
2
The crater resulted from a meteorite impact is the largest and most preserved one in the world.
3
The water stored in lake Bosumtwi was gone only by seeping through the lake sediments.
4
Historical climate changes can be detected by the analysis of the sediment in the lake.
5
The greatest obstacle to the research of scientists had been the interference by the locals due to their indigenous believes.

4 ____ Historical climate changes can be detected by the analysis of the sediment in the lake.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('076daf24-6b85-59ce-ace9-59e575699046', '8b88521e-d90a-5af8-b530-f5fc23fce0b4', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9296b997-8cf7-5319-a63b-5ef4074bb331', '8b88521e-d90a-5af8-b530-f5fc23fce0b4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27464d93-20c2-5999-86be-02520ad127e6', '8b88521e-d90a-5af8-b530-f5fc23fce0b4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('22eb8d08-18ae-5bfd-afb3-c5bac027e8ef', '0741d075-4942-5f83-9e07-7ab530ae20f1', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
With the investigation of the lake, the scientist may predict the climate changes in the future.
2
The crater resulted from a meteorite impact is the largest and most preserved one in the world.
3
The water stored in lake Bosumtwi was gone only by seeping through the lake sediments.
4
Historical climate changes can be detected by the analysis of the sediment in the lake.
5
The greatest obstacle to the research of scientists had been the interference by the locals due to their indigenous believes.

5 ____ The greatest obstacle to the research of scientists had been the interference by the locals due to their indigenous believes.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('400f905f-e79b-571b-9784-1887e161c3a5', '22eb8d08-18ae-5bfd-afb3-c5bac027e8ef', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a57be0b9-f161-577f-a253-7ef1af7b87c1', '22eb8d08-18ae-5bfd-afb3-c5bac027e8ef', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c6123d8-4bd4-5dcc-9ae6-e7c5243610f2', '22eb8d08-18ae-5bfd-afb3-c5bac027e8ef', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('92439197-12b8-5cac-bc0d-b12aeb34c292', '0741d075-4942-5f83-9e07-7ab530ae20f1', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
There are three steps of collecting data from the lake as followings, please fill the blanks in the Flow Chart below:
6
7
8
9

6 ____$md$, NULL, ARRAY['.*air.*gun.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a0b26d88-14dc-5cf5-8ff6-3e5d39abeb4a', '0741d075-4942-5f83-9e07-7ab530ae20f1', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
There are three steps of collecting data from the lake as followings, please fill the blanks in the Flow Chart below:
6
7
8
9

7 ____$md$, NULL, ARRAY['.*sound.*energy.*','.*sound.*wave.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c1762bae-b1aa-5c80-9e04-dcd653dba6f2', '0741d075-4942-5f83-9e07-7ab530ae20f1', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
There are three steps of collecting data from the lake as followings, please fill the blanks in the Flow Chart below:
6
7
8
9

8 ____$md$, NULL, ARRAY['.*cable.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7de9f675-28c6-54bf-b080-4a51182fa1b9', '0741d075-4942-5f83-9e07-7ab530ae20f1', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
There are three steps of collecting data from the lake as followings, please fill the blanks in the Flow Chart below:
6
7
8
9

9 ____$md$, NULL, ARRAY['.*hydrophones.*','.*underwater.*microphones.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a79d981c-69cf-5560-8660-a34c80654dad', '0741d075-4942-5f83-9e07-7ab530ae20f1', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Complete the following summary of the paragraph of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes 10-14 on your answer sheet.
The boat-double R/V Kilindi crossed the lake was dismantled and stored in a
10
. The technology they used called
11
; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves. Then the data had been analyzed and processed in the
12
Scholz also added that they were now building
13
. View of the sediment or sub-image in the bottom of the lake. The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or
14
. Floating on the surface of the lake.

The boat-double R/V Kilindi crossed the lake was dismantled and stored in a 10 ____ . The technology they used called 11 ____ ; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves. Then the data had been analyzed and processed in the 12 ____ Scholz also added that they were now building 13 ____ . View of the sediment or sub-image in the bottom of the lake. The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or 14 ____ . Floating on the surface of the lake.$md$, NULL, ARRAY['.*shipping.*container.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1beab509-a4b2-566b-951a-fa65ce906006', '0741d075-4942-5f83-9e07-7ab530ae20f1', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Complete the following summary of the paragraph of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes 10-14 on your answer sheet.
The boat-double R/V Kilindi crossed the lake was dismantled and stored in a
10
. The technology they used called
11
; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves. Then the data had been analyzed and processed in the
12
Scholz also added that they were now building
13
. View of the sediment or sub-image in the bottom of the lake. The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or
14
. Floating on the surface of the lake.

The boat-double R/V Kilindi crossed the lake was dismantled and stored in a 10 ____ . The technology they used called 11 ____ ; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves. Then the data had been analyzed and processed in the 12 ____ Scholz also added that they were now building 13 ____ . View of the sediment or sub-image in the bottom of the lake. The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or 14 ____ . Floating on the surface of the lake.$md$, NULL, ARRAY['.*shipping.*container.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('71e1b904-5993-5a39-885e-04f8a771c581', '0741d075-4942-5f83-9e07-7ab530ae20f1', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Complete the following summary of the paragraph of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes 10-14 on your answer sheet.
The boat-double R/V Kilindi crossed the lake was dismantled and stored in a
10
. The technology they used called
11
; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves. Then the data had been analyzed and processed in the
12
Scholz also added that they were now building
13
. View of the sediment or sub-image in the bottom of the lake. The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or
14
. Floating on the surface of the lake.

The boat-double R/V Kilindi crossed the lake was dismantled and stored in a 10 ____ . The technology they used called 11 ____ ; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves. Then the data had been analyzed and processed in the 12 ____ Scholz also added that they were now building 13 ____ . View of the sediment or sub-image in the bottom of the lake. The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or 14 ____ . Floating on the surface of the lake.$md$, NULL, ARRAY['.*shipping.*container.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('dc8212fb-6c56-5f64-a099-a185cc5b6a50', '0741d075-4942-5f83-9e07-7ab530ae20f1', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Complete the following summary of the paragraph of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes 10-14 on your answer sheet.
The boat-double R/V Kilindi crossed the lake was dismantled and stored in a
10
. The technology they used called
11
; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves. Then the data had been analyzed and processed in the
12
Scholz also added that they were now building
13
. View of the sediment or sub-image in the bottom of the lake. The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or
14
. Floating on the surface of the lake.

The boat-double R/V Kilindi crossed the lake was dismantled and stored in a 10 ____ . The technology they used called 11 ____ ; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves. Then the data had been analyzed and processed in the 12 ____ Scholz also added that they were now building 13 ____ . View of the sediment or sub-image in the bottom of the lake. The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or 14 ____ . Floating on the surface of the lake.$md$, NULL, ARRAY['.*shipping.*container.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('31de9163-0c2d-5055-a24b-37aed12ac073', '0741d075-4942-5f83-9e07-7ab530ae20f1', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Complete the following summary of the paragraph of Reading Passage.
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes 10-14 on your answer sheet.
The boat-double R/V Kilindi crossed the lake was dismantled and stored in a
10
. The technology they used called
11
; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves. Then the data had been analyzed and processed in the
12
Scholz also added that they were now building
13
. View of the sediment or sub-image in the bottom of the lake. The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or
14
. Floating on the surface of the lake.

The boat-double R/V Kilindi crossed the lake was dismantled and stored in a 10 ____ . The technology they used called 11 ____ ; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves. Then the data had been analyzed and processed in the 12 ____ Scholz also added that they were now building 13 ____ . View of the sediment or sub-image in the bottom of the lake. The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or 14 ____ . Floating on the surface of the lake.$md$, NULL, ARRAY['.*shipping.*container.*']);

COMMIT;
