BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-man-or-machine-1366'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-man-or-machine-1366';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-man-or-machine-1366';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-man-or-machine-1366';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2ccbec3e-a64a-5f9f-bc95-441becbc576d', 'ielts-reading-man-or-machine-1366', $t$Man or Machine$t$, $md$## Man or Machine

Nguồn:
- Test: https://mini-ielts.com/1366/reading/man-or-machine
- Solution: https://mini-ielts.com/1366/view-solution/reading/man-or-machine$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('937f50a4-df59-59cc-b4ec-755cfc9d4937', '2ccbec3e-a64a-5f9f-bc95-441becbc576d', 1, $t$Reading — Man or Machine$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Man or Machine

A

During July 2003, the Museum of Science in Cambridge, Massachusetts exhibited what Honda calls ‘the world’s most advanced humanoid robot’, ASIMO (the Advanced Step in Innovative Mobility). Honda’s brainchild is on tour in North America and delighting audiences wherever it goes. After 17 years in the making, ASIMO stands at four feet tall, weighs around 115 pounds and looks like a child in an astronaut’s suit. Though it is difficult to see ASIMO’s face at a distance, on closer inspection it has a smile and two large ‘eyes’ that conceal cameras. The robot cannot work autonomously – its actions are ‘remote-controlled’ by scientists through the computer in its backpack. Yet watching AIMIO perform at a show in Massachusetts it seemed uncannily human. The audience cheered as ASIMO walked forwards and backwards, side to side and up and downstairs. After the show, a number of people told me that they would like robots to play more of a role in daily life – one even said that the robot would be like ‘another person’.

B

While the Japanese have made huge strides in solving some of the engineering problems of human kinetics and bipedal movements, for the past 10 years scientists at MIT’s former Artificial Intelligence (AI) lab (recently renamed the Computer Science and Artificial Intelligence Laboratory, CSAIL) have been making robots that can behave like humans and interact with humans. One of MIT’s robots, Kismet, is an anthropomorphic head and has two eyes (complete with eyelids), ears, a mouth, and eyebrows. It has several facial expressions, including happy, sad, frightened and disgusted. Human interlocutors are able to read some of the robot’s facial expressions, and often change their behavior towards the machine as a result – for example, playing with it when it appears ‘sad’. Kismet is now in MIT’s museum, but the ideas developed here continue to be explored in new robots.

C

Cog (short for Cognition) is another pioneering project from MIT’s former AI lab. Cog has a head, eyes, two arms, hands and a torso – and its proportions were originally measured from the body of a researcher in the lab. The work on Cog has been used to test theories of embodiment and developmental robotics, particularly getting a robot to develop intelligence by responding to its environment via sensors, and to learn through these types of interactions.

D

MIT is getting furthest down the road to creating human-like and interactive robots. Some scientists argue that ASIMO is a great engineering feat but not an intelligent machine – because it is unable to interact autonomously with unpredictabilities in its environment in meaningful ways, and learn from experience. Robots like Cog and Kismet and new robots at MIT’s CSAIL and media lab, however, are beginning to do this.

E

These are exciting developments. Creating a machine that can walk, make gestures and learn from its environment is an amazing achievement. And watch this space: these achievements are likely rapidly to be improved upon. Humanoid robots could have a plethora of uses in society, helping to free people from everyday tasks. In Japan, for example, there is an aim to create robots that can do the tasks similar to an average human and also act in more sophisticated situations as firefighters, astronauts or medical assistants to the elderly in the workplace and in homes – partly in order to counterbalance the effects of an ageing population.

F

Such robots say much about the way in which we view humanity, and they bring out the best and worst of us. On one hand, these developments express human creativity – our ability to invent, experiment, and to extend our control over the world. On the other hand, the aim to create a robot like a human being is spurred on by dehumanized ideas – by the sense that human companionship can be substituted by machines; that humans lose their humanity when they interact with technology; or that we are a little more than surface and ritual behaviors, that can be simulated with metal and electrical circuits.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9fada2e4-e85c-5b03-8d85-b5ace0e1d9e9', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading passage 1 has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
1
different ways of using robots
2
a robot whose body has the same proportion as that of an adult
3
the fact that human can be copied and replaced by robots
4
a comparison between ASIMO for Honda and other robots
5
the pros and cons of creating robots
6
a robot that has eyebrows

1 ____ different ways of using robots$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48b92bac-a436-5936-8a00-e1ee1c457dd4', '9fada2e4-e85c-5b03-8d85-b5ace0e1d9e9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c7a7990-c9ce-542b-ae4e-6b6f78b1e648', '9fada2e4-e85c-5b03-8d85-b5ace0e1d9e9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33a00925-ac2f-5832-b7ce-ba80bd03528c', '9fada2e4-e85c-5b03-8d85-b5ace0e1d9e9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77812488-8f4e-5781-a26d-9d04d9be547e', '9fada2e4-e85c-5b03-8d85-b5ace0e1d9e9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c003ceb0-68a9-5455-b5a8-5bb5b94c2163', '9fada2e4-e85c-5b03-8d85-b5ace0e1d9e9', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21426f15-43f8-5081-bff2-8b38d61f60de', '9fada2e4-e85c-5b03-8d85-b5ace0e1d9e9', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('68a5f396-e8e0-5888-8834-d8b7b0b0916a', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading passage 1 has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
1
different ways of using robots
2
a robot whose body has the same proportion as that of an adult
3
the fact that human can be copied and replaced by robots
4
a comparison between ASIMO for Honda and other robots
5
the pros and cons of creating robots
6
a robot that has eyebrows

2 ____ a robot whose body has the same proportion as that of an adult$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88e4c178-a5d3-56c0-b674-518f267787fa', '68a5f396-e8e0-5888-8834-d8b7b0b0916a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1acf1f29-8ab1-5190-b63b-0ceca0f68dfa', '68a5f396-e8e0-5888-8834-d8b7b0b0916a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85b83cee-88b9-5c8f-83b5-debd8fccf621', '68a5f396-e8e0-5888-8834-d8b7b0b0916a', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e0b560d-49ef-5581-8cf1-384bdb319c2d', '68a5f396-e8e0-5888-8834-d8b7b0b0916a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('430cecc5-bff2-5d27-8900-713ab5485ec5', '68a5f396-e8e0-5888-8834-d8b7b0b0916a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88423481-e943-5f2c-b8bf-18d980983646', '68a5f396-e8e0-5888-8834-d8b7b0b0916a', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fe9cab7b-0da3-5fad-8012-a1cd9a022322', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading passage 1 has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
1
different ways of using robots
2
a robot whose body has the same proportion as that of an adult
3
the fact that human can be copied and replaced by robots
4
a comparison between ASIMO for Honda and other robots
5
the pros and cons of creating robots
6
a robot that has eyebrows

3 ____ the fact that human can be copied and replaced by robots$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('819d986a-0801-5aa0-a389-02013c2303c7', 'fe9cab7b-0da3-5fad-8012-a1cd9a022322', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e41a3241-2951-5e16-ae8a-329f2b0eb1c1', 'fe9cab7b-0da3-5fad-8012-a1cd9a022322', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba15d3ae-5107-599c-8097-4ff2b03a22be', 'fe9cab7b-0da3-5fad-8012-a1cd9a022322', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dff0486-244e-590f-9868-cf50e21141a6', 'fe9cab7b-0da3-5fad-8012-a1cd9a022322', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3df246d-4dad-55ac-bc30-66cfc0d65d71', 'fe9cab7b-0da3-5fad-8012-a1cd9a022322', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ba52188-8f7d-575b-a9ad-af59f67cd610', 'fe9cab7b-0da3-5fad-8012-a1cd9a022322', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6d05dc3e-8ecf-5a0a-ac4c-8410c2c04a66', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading passage 1 has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
1
different ways of using robots
2
a robot whose body has the same proportion as that of an adult
3
the fact that human can be copied and replaced by robots
4
a comparison between ASIMO for Honda and other robots
5
the pros and cons of creating robots
6
a robot that has eyebrows

4 ____ a comparison between ASIMO for Honda and other robots$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34ccb3be-1df5-5074-95bb-d09773f67a44', '6d05dc3e-8ecf-5a0a-ac4c-8410c2c04a66', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3c6bee6-087e-578b-9660-210c908b2b42', '6d05dc3e-8ecf-5a0a-ac4c-8410c2c04a66', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f53fc3a8-94fc-5c41-b045-9058c6bd09fb', '6d05dc3e-8ecf-5a0a-ac4c-8410c2c04a66', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f597ff7b-ee0c-5879-b4bc-32903a92221f', '6d05dc3e-8ecf-5a0a-ac4c-8410c2c04a66', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0974ee1-c105-5ee8-a04c-48bbbfac2e25', '6d05dc3e-8ecf-5a0a-ac4c-8410c2c04a66', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffe71c2d-b3bc-5d96-9e12-1cdb674d2b12', '6d05dc3e-8ecf-5a0a-ac4c-8410c2c04a66', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c05970ab-81aa-54fd-8748-3f79066f5cd6', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading passage 1 has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
1
different ways of using robots
2
a robot whose body has the same proportion as that of an adult
3
the fact that human can be copied and replaced by robots
4
a comparison between ASIMO for Honda and other robots
5
the pros and cons of creating robots
6
a robot that has eyebrows

5 ____ the pros and cons of creating robots$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba76f7f6-5a08-5e86-a06b-92c7d50a59e1', 'c05970ab-81aa-54fd-8748-3f79066f5cd6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d06c0300-b514-5393-9535-171a354ee843', 'c05970ab-81aa-54fd-8748-3f79066f5cd6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b868b2e-5259-501f-b202-485e9eaff8f2', 'c05970ab-81aa-54fd-8748-3f79066f5cd6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c976318-c42b-516d-a5a0-01ad55b3ce8e', 'c05970ab-81aa-54fd-8748-3f79066f5cd6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aeb4c3ac-a552-5048-be37-cabe7754c335', 'c05970ab-81aa-54fd-8748-3f79066f5cd6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6740f41-2314-58f3-b783-9cd93b8af45c', 'c05970ab-81aa-54fd-8748-3f79066f5cd6', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('85d6d5e8-1f76-5196-a7a4-407328119bf5', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading passage 1 has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
1
different ways of using robots
2
a robot whose body has the same proportion as that of an adult
3
the fact that human can be copied and replaced by robots
4
a comparison between ASIMO for Honda and other robots
5
the pros and cons of creating robots
6
a robot that has eyebrows

6 ____ a robot that has eyebrows$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eacee052-7519-5fab-8cdd-06353f8af16d', '85d6d5e8-1f76-5196-a7a4-407328119bf5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68ff283e-33a8-5522-b7a3-1c7fa398d9e1', '85d6d5e8-1f76-5196-a7a4-407328119bf5', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('928ef209-4220-52a6-aa9d-8b33e14aa458', '85d6d5e8-1f76-5196-a7a4-407328119bf5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16c2453e-57d4-5741-8378-5ff6684fafbe', '85d6d5e8-1f76-5196-a7a4-407328119bf5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2729290-326d-574b-9891-472413c2c39f', '85d6d5e8-1f76-5196-a7a4-407328119bf5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bce6ec45-e2d7-547e-b093-04935df067ea', '85d6d5e8-1f76-5196-a7a4-407328119bf5', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c846c8b2-67a0-5aa7-8099-ce519a5dda5b', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage 1.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of
7
in the making. The operating information is stored in the computer in its
8
so that scientists can control
ASIMO’s
movement. While Japan is making great progress, MIT is developing robots that are human-like and can
9
. Humans. What is special about Kismet is that it has different
10
which can be read by human interlocutors.
11
is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through
12
, it could develop its
13
##a.

In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of 7 ____ in the making. The operating information is stored in the computer in its 8 ____ so that scientists can control ASIMO’s movement. While Japan is making great progress, MIT is developing robots that are human-like and can 9 ____ . Humans. What is special about Kismet is that it has different 10 ____ which can be read by human interlocutors. 11 ____ is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through 12 ____ , it could develop its 13 ____ ##a.$md$, NULL, ARRAY['.*17.*years.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bd7ad5ab-8f5e-52a6-9279-59bf1699d406', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage 1.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of
7
in the making. The operating information is stored in the computer in its
8
so that scientists can control
ASIMO’s
movement. While Japan is making great progress, MIT is developing robots that are human-like and can
9
. Humans. What is special about Kismet is that it has different
10
which can be read by human interlocutors.
11
is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through
12
, it could develop its
13
##a.

In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of 7 ____ in the making. The operating information is stored in the computer in its 8 ____ so that scientists can control ASIMO’s movement. While Japan is making great progress, MIT is developing robots that are human-like and can 9 ____ . Humans. What is special about Kismet is that it has different 10 ____ which can be read by human interlocutors. 11 ____ is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through 12 ____ , it could develop its 13 ____ ##a.$md$, NULL, ARRAY['.*17.*years.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5a0f72a2-e793-5a62-ac98-d7222b69be9c', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage 1.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of
7
in the making. The operating information is stored in the computer in its
8
so that scientists can control
ASIMO’s
movement. While Japan is making great progress, MIT is developing robots that are human-like and can
9
. Humans. What is special about Kismet is that it has different
10
which can be read by human interlocutors.
11
is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through
12
, it could develop its
13
##a.

In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of 7 ____ in the making. The operating information is stored in the computer in its 8 ____ so that scientists can control ASIMO’s movement. While Japan is making great progress, MIT is developing robots that are human-like and can 9 ____ . Humans. What is special about Kismet is that it has different 10 ____ which can be read by human interlocutors. 11 ____ is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through 12 ____ , it could develop its 13 ____ ##a.$md$, NULL, ARRAY['.*17.*years.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('38154417-4f9e-5e09-aa6c-fe1488df65ce', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage 1.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of
7
in the making. The operating information is stored in the computer in its
8
so that scientists can control
ASIMO’s
movement. While Japan is making great progress, MIT is developing robots that are human-like and can
9
. Humans. What is special about Kismet is that it has different
10
which can be read by human interlocutors.
11
is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through
12
, it could develop its
13
##a.

In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of 7 ____ in the making. The operating information is stored in the computer in its 8 ____ so that scientists can control ASIMO’s movement. While Japan is making great progress, MIT is developing robots that are human-like and can 9 ____ . Humans. What is special about Kismet is that it has different 10 ____ which can be read by human interlocutors. 11 ____ is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through 12 ____ , it could develop its 13 ____ ##a.$md$, NULL, ARRAY['.*17.*years.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('923276a8-1615-5ecf-9e6b-7bcdcc0938f8', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage 1.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of
7
in the making. The operating information is stored in the computer in its
8
so that scientists can control
ASIMO’s
movement. While Japan is making great progress, MIT is developing robots that are human-like and can
9
. Humans. What is special about Kismet is that it has different
10
which can be read by human interlocutors.
11
is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through
12
, it could develop its
13
##a.

In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of 7 ____ in the making. The operating information is stored in the computer in its 8 ____ so that scientists can control ASIMO’s movement. While Japan is making great progress, MIT is developing robots that are human-like and can 9 ____ . Humans. What is special about Kismet is that it has different 10 ____ which can be read by human interlocutors. 11 ____ is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through 12 ____ , it could develop its 13 ____ ##a.$md$, NULL, ARRAY['.*17.*years.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d0ce1de3-b0b0-5a49-b4e7-207bfb6366ec', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage 1.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of
7
in the making. The operating information is stored in the computer in its
8
so that scientists can control
ASIMO’s
movement. While Japan is making great progress, MIT is developing robots that are human-like and can
9
. Humans. What is special about Kismet is that it has different
10
which can be read by human interlocutors.
11
is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through
12
, it could develop its
13
##a.

In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of 7 ____ in the making. The operating information is stored in the computer in its 8 ____ so that scientists can control ASIMO’s movement. While Japan is making great progress, MIT is developing robots that are human-like and can 9 ____ . Humans. What is special about Kismet is that it has different 10 ____ which can be read by human interlocutors. 11 ____ is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through 12 ____ , it could develop its 13 ____ ##a.$md$, NULL, ARRAY['.*17.*years.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7919b3a9-62c5-59dc-b7cd-1cfd72c67870', '937f50a4-df59-59cc-b4ec-755cfc9d4937', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage 1.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of
7
in the making. The operating information is stored in the computer in its
8
so that scientists can control
ASIMO’s
movement. While Japan is making great progress, MIT is developing robots that are human-like and can
9
. Humans. What is special about Kismet is that it has different
10
which can be read by human interlocutors.
11
is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through
12
, it could develop its
13
##a.

In 2003, Massachusetts displayed a robot named ASIMO which was invented by Honda, after a period of 7 ____ in the making. The operating information is stored in the computer in its 8 ____ so that scientists can control ASIMO’s movement. While Japan is making great progress, MIT is developing robots that are human-like and can 9 ____ . Humans. What is special about Kismet is that it has different 10 ____ which can be read by human interlocutors. 11 ____ is another robot from MIT, whose body’s proportion is the same as an adult. By responding to the surroundings through 12 ____ , it could develop its 13 ____ ##a.$md$, NULL, ARRAY['.*17.*years.*']);

COMMIT;
