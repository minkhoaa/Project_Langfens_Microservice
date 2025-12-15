BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-becoming-an-expert-1461'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-becoming-an-expert-1461';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-becoming-an-expert-1461';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-becoming-an-expert-1461';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('7f27e661-46c0-550b-a6dc-bbf2231eb937', 'ielts-reading-becoming-an-expert-1461', $t$Becoming an Expert$t$, $md$## Becoming an Expert

Nguồn:
- Test: https://mini-ielts.com/1461/reading/becoming-an-expert
- Solution: https://mini-ielts.com/1461/view-solution/reading/becoming-an-expert$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('09598e5e-64bb-58ca-9884-27abdb36b59e', '7f27e661-46c0-550b-a6dc-bbf2231eb937', 1, $t$Reading — Becoming an Expert$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Becoming an Expert

| | Becoming an Expert Expertise is commitment coupled with creativity. Specifically, it is the commitment of time, energy, and resource to a relatively narrow field of study and the creative energy necessary to generate new knowledge in that field. It takes a considerable amount of time and regular exposure to a large number of cases to become an expert. An individual enters a field of study as a novice. The novice needs to learn the guiding principles and rules of a given task in order to perform that task. Concurrently, the novice needs to be exposed to specific cases, or instances, that test the boundaries of such principles. Generally, a novice will find a mentor to guide her through the process of acquiring new knowledge. A fairly simple example would be someone learning to play chess. The novice chess player seeks a mentor to tech her the object of the game, the number of spaces, the names of the pieces, the function of each piece, how each piece is moved, and the necessary conditions for winning or losing the game. In time, and with much practice, the novice begins to recognize patterns of behavior within cases and, thus, becomes a journeyman. With more practice and exposure to increasingly complex cases, the journeyman finds patterns not only within cases but also between cases. More importantly, the journeyman learns that these patterns often repeat themselves over time. The journeyman still maintains regular contact with a mentor to solve specific problems and learn more complex strategies. Returning to the example of the chess player, the individual begins to learn patterns of opening moves, offensive and defensive game - playing strategies, and patterns of victory and defeat. When a journeyman starts to make and test hypotheses about future behavior based on past experiences, she begins the next transition. Once she creatively generates knowledge, rather than simply matching superficial patterns, she becomes an expert. At this point, she is confident in her knowledge and no longer needs a mentor as a guide - she becomes responsible for her own knowledge. In the chess example, once a journey man begins competing against experts, makes predictions based on patterns, and tests those predictions against actual behavior, she is generating new knowledge and a deeper understanding of the game. She is creating her own cases rather than relying on the cases of others. The chess example is a rather short description of an apprenticeship model. Apprenticeship may seem like a restrictive 18th century mode of education, but it is still a standard method of training for many complex tasks. Academic doctoral programs are based on an apprenticeship model, as are fields like law, music, engineering, and medicine. Graduate students enter fields of study, find mentors, and begin the long process of becoming independent experts and generating new knowledge in their respective domains. Psychologists and cognitive scientists agree that the time it takes to become an expert depends on the complexity of the task and the number of cases, or patterns, to which an individual is exposed. The more complex the task, the longer it takes to build expertise, or, more accurately, the longer it takes to experience and store a large number of cases or patterns. The Power of Expertise An expert perceives meaningful patterns in her domain better than non-experts. Where a novice perceives random or disconnected data points, an expert connects regular patterns within and between cases. This ability to identify patterns is not an innate perceptual skill; rather it reflects the organization of knowledge after exposure to and experience with thousands of cases. Experts have a deeper understanding of their domains than novices do, and utilize higher -order principles to solve problems. A novice, for example, might group objects together by color or size, whereas an expert would group the same objects according to their function or utility. Experts comprehend the meaning of data and weigh variables with different criteria within their domains better then novices.Experts recognized variables that have the largest influence on a particular problem and focus their attention on those variables. Experts have better domain -specific short -term and long -term memory than novices do. Moreover, experts perform task in their domains faster than novices and commit fewer errors while problem solving. Interestingly, experts go about solving problems differently than novices. Experts spend more time thinking about a problem to fully understand it at the beginning of a task than do novices, who immediately seek to find a solution. Experts use their knowledge of previous cases as context for increasing mental models to solve given problems. Better at self-monitoring then novices, experts are more aware of instances where they have committed errors or failed to understand a problem. Experts check their solutions more often than novices and recognize when they are missing information necessary for solving a problem. Experts are aware of the limits of their domain knowledge and apply their domain's heuristics to solve problems that fall outside of their experience base. The Paradox of Expertise The strengths of expertise can also be weaknesses. Although one would expect experts to be good forecasters, they are not particularly good at making predictions about the future. Since the 1930s, researchers have been testing the ability of experts to make forecasts. The performance of experts has been tested against actuarial tables to determine if they are better at making predictions than simple statistical models. Seventy years later, with more than two hundred experiments in different domains, it is clear that the answer is no. If supplied with an equal amount of data about a particular case, an actuarial table is as good, or better, than an expert at making calls about the future. Even if an expert is given more specific case information than is available to the statistical model, the expert does not tend to outperform the actuarial table. Theorists and researchers differ when trying to explain why experts are less accurate forecasters than statistical models. Some have argued that experts, like all humans, are inconsistent when using mental models to make predictions. A number of researchers point to human biases to explain unreliable expert predictions. During the last 30 years, researchers have categorized, experimented, and theorized about the cognitive aspects of forecasting. Despite such efforts, the literature shows little consensus regarding the causes or manifestations of human bias$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('06514c3c-0cb3-5ed9-bf3e-7b965fb3ab34', '09598e5e-64bb-58ca-9884-27abdb36b59e', 1, 'FORM_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the flow-chart below
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Novice:
needs to study
1
under the guidance of a
2
3
: starts to identify
4
for cases within or between study more
5
ways of doing things create new knowledge
Expert: performs task independently

Novice: needs to study 1 ____ under the guidance of a 2 ____$md$, NULL, ARRAY['.*principles.*and.*rules.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f50ecfd6-8308-58c0-8007-48718b875e33', '09598e5e-64bb-58ca-9884-27abdb36b59e', 2, 'FORM_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the flow-chart below
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Novice:
needs to study
1
under the guidance of a
2
3
: starts to identify
4
for cases within or between study more
5
ways of doing things create new knowledge
Expert: performs task independently

Novice: needs to study 1 ____ under the guidance of a 2 ____$md$, NULL, ARRAY['.*principles.*and.*rules.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8712dfc0-6944-5937-8c61-36c4ecac29ae', '09598e5e-64bb-58ca-9884-27abdb36b59e', 3, 'FORM_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the flow-chart below
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Novice:
needs to study
1
under the guidance of a
2
3
: starts to identify
4
for cases within or between study more
5
ways of doing things create new knowledge
Expert: performs task independently

3 ____ : starts to identify 4 ____ for cases within or between study more 5 ____ ways of doing things create new knowledge$md$, NULL, ARRAY['.*journeyman.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('845f866e-2fc2-5bdd-9e42-5a524fee20ea', '09598e5e-64bb-58ca-9884-27abdb36b59e', 4, 'FORM_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the flow-chart below
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Novice:
needs to study
1
under the guidance of a
2
3
: starts to identify
4
for cases within or between study more
5
ways of doing things create new knowledge
Expert: performs task independently

3 ____ : starts to identify 4 ____ for cases within or between study more 5 ____ ways of doing things create new knowledge$md$, NULL, ARRAY['.*journeyman.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a4aafdab-4c64-5114-8fa3-184e769853d7', '09598e5e-64bb-58ca-9884-27abdb36b59e', 5, 'FORM_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the flow-chart below
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Novice:
needs to study
1
under the guidance of a
2
3
: starts to identify
4
for cases within or between study more
5
ways of doing things create new knowledge
Expert: performs task independently

3 ____ : starts to identify 4 ____ for cases within or between study more 5 ____ ways of doing things create new knowledge$md$, NULL, ARRAY['.*journeyman.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e572c029-0266-5cef-90b6-f1c5cda74f02', '09598e5e-64bb-58ca-9884-27abdb36b59e', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage?
On your answer sheet please write
TRUE
if the statement agrees with the writer
FALSE
if the statement contradicts with the writer
NOT GIVEN
if there is no information about this in the passage.
6
Novices and experts use the same system of knowledge to comprehend and classify objects.
7
The focus of novices' training is necessarily on long term memory.
8
When working out the problems, novices want to solve them straight away.
9
When handling problems, experts are always more efficient than novices in their fields.
10
Expert tend to review more than novices on cases when flaws or limit on understanding took place

6 ____ Novices and experts use the same system of knowledge to comprehend and classify objects.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7dbf473-f86a-5a78-80f7-5631e482060c', 'e572c029-0266-5cef-90b6-f1c5cda74f02', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed231a8a-bb2e-5913-b63f-5ed9c7a26a87', 'e572c029-0266-5cef-90b6-f1c5cda74f02', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b480dca-6154-5894-a634-825dc1fb08e9', 'e572c029-0266-5cef-90b6-f1c5cda74f02', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f4c8a41a-bc87-54f1-b0c8-d5dd9ab7c13e', '09598e5e-64bb-58ca-9884-27abdb36b59e', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage?
On your answer sheet please write
TRUE
if the statement agrees with the writer
FALSE
if the statement contradicts with the writer
NOT GIVEN
if there is no information about this in the passage.
6
Novices and experts use the same system of knowledge to comprehend and classify objects.
7
The focus of novices' training is necessarily on long term memory.
8
When working out the problems, novices want to solve them straight away.
9
When handling problems, experts are always more efficient than novices in their fields.
10
Expert tend to review more than novices on cases when flaws or limit on understanding took place

7 ____ The focus of novices' training is necessarily on long term memory.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac3c28c3-4530-5e4f-b0ac-1252f2f130eb', 'f4c8a41a-bc87-54f1-b0c8-d5dd9ab7c13e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49d2e0ce-2062-5c56-b5bf-d562d8dbf4f2', 'f4c8a41a-bc87-54f1-b0c8-d5dd9ab7c13e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b67b96a-bc84-528b-92f7-b7ca6f2a4eac', 'f4c8a41a-bc87-54f1-b0c8-d5dd9ab7c13e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ec11546c-5728-5b35-bad5-a5a8d63e86d9', '09598e5e-64bb-58ca-9884-27abdb36b59e', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage?
On your answer sheet please write
TRUE
if the statement agrees with the writer
FALSE
if the statement contradicts with the writer
NOT GIVEN
if there is no information about this in the passage.
6
Novices and experts use the same system of knowledge to comprehend and classify objects.
7
The focus of novices' training is necessarily on long term memory.
8
When working out the problems, novices want to solve them straight away.
9
When handling problems, experts are always more efficient than novices in their fields.
10
Expert tend to review more than novices on cases when flaws or limit on understanding took place

8 ____ When working out the problems, novices want to solve them straight away.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('166beba5-2ccf-57c9-a3b3-3b43bf53f384', 'ec11546c-5728-5b35-bad5-a5a8d63e86d9', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98eddd87-ea59-54f7-9ecd-7f2812e672e7', 'ec11546c-5728-5b35-bad5-a5a8d63e86d9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a71c2aa7-0104-5335-a5d3-332b6dfb4cc4', 'ec11546c-5728-5b35-bad5-a5a8d63e86d9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aa7ef56b-0600-5755-b5af-15f2f05520ee', '09598e5e-64bb-58ca-9884-27abdb36b59e', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage?
On your answer sheet please write
TRUE
if the statement agrees with the writer
FALSE
if the statement contradicts with the writer
NOT GIVEN
if there is no information about this in the passage.
6
Novices and experts use the same system of knowledge to comprehend and classify objects.
7
The focus of novices' training is necessarily on long term memory.
8
When working out the problems, novices want to solve them straight away.
9
When handling problems, experts are always more efficient than novices in their fields.
10
Expert tend to review more than novices on cases when flaws or limit on understanding took place

9 ____ When handling problems, experts are always more efficient than novices in their fields.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b8b14d4-a4fb-50a7-a2e6-558224807fea', 'aa7ef56b-0600-5755-b5af-15f2f05520ee', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56f536f2-9554-5f29-a314-aa0981ded788', 'aa7ef56b-0600-5755-b5af-15f2f05520ee', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2d336c0-f804-5e47-a8e1-35ef9d6f13d8', 'aa7ef56b-0600-5755-b5af-15f2f05520ee', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8ab06e6e-e040-5109-8cd9-6fe97b9ba0fb', '09598e5e-64bb-58ca-9884-27abdb36b59e', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage?
On your answer sheet please write
TRUE
if the statement agrees with the writer
FALSE
if the statement contradicts with the writer
NOT GIVEN
if there is no information about this in the passage.
6
Novices and experts use the same system of knowledge to comprehend and classify objects.
7
The focus of novices' training is necessarily on long term memory.
8
When working out the problems, novices want to solve them straight away.
9
When handling problems, experts are always more efficient than novices in their fields.
10
Expert tend to review more than novices on cases when flaws or limit on understanding took place

10 ____ Expert tend to review more than novices on cases when flaws or limit on understanding took place$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39b8e02c-9ab3-50e6-a817-499a09bc5bd6', '8ab06e6e-e040-5109-8cd9-6fe97b9ba0fb', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04345d18-1d9d-53f4-a84e-3fa8737d10de', '8ab06e6e-e040-5109-8cd9-6fe97b9ba0fb', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea598531-a350-53bf-bfbc-5a7108024db7', '8ab06e6e-e040-5109-8cd9-6fe97b9ba0fb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('29987b19-1670-500c-8332-1f2b7344d6c7', '09598e5e-64bb-58ca-9884-27abdb36b59e', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer. Write your answers in boxes 11 -13 on your answer sheet.
While experts outperform novices and machines in pattern recognition and problem solving, expert predictions of future behavior or events are seldom as accurate as simple actuarial tables. Why? Some have tried to explain that experts differ when using cognitive
11
to forecast. Researchers believe it is due to
12
. However attempting endevour of finding answers did not yet produce
13

While experts outperform novices and machines in pattern recognition and problem solving, expert predictions of future behavior or events are seldom as accurate as simple actuarial tables. Why? Some have tried to explain that experts differ when using cognitive 11 ____ to forecast. Researchers believe it is due to 12 ____ . However attempting endevour of finding answers did not yet produce 13 ____$md$, NULL, ARRAY['.*models.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e32ad4f2-771d-5d01-a386-161a4c4a7de6', '09598e5e-64bb-58ca-9884-27abdb36b59e', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer. Write your answers in boxes 11 -13 on your answer sheet.
While experts outperform novices and machines in pattern recognition and problem solving, expert predictions of future behavior or events are seldom as accurate as simple actuarial tables. Why? Some have tried to explain that experts differ when using cognitive
11
to forecast. Researchers believe it is due to
12
. However attempting endevour of finding answers did not yet produce
13

While experts outperform novices and machines in pattern recognition and problem solving, expert predictions of future behavior or events are seldom as accurate as simple actuarial tables. Why? Some have tried to explain that experts differ when using cognitive 11 ____ to forecast. Researchers believe it is due to 12 ____ . However attempting endevour of finding answers did not yet produce 13 ____$md$, NULL, ARRAY['.*models.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4a4b5510-5f92-5ad6-89cb-6eba104f0f5f', '09598e5e-64bb-58ca-9884-27abdb36b59e', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer. Write your answers in boxes 11 -13 on your answer sheet.
While experts outperform novices and machines in pattern recognition and problem solving, expert predictions of future behavior or events are seldom as accurate as simple actuarial tables. Why? Some have tried to explain that experts differ when using cognitive
11
to forecast. Researchers believe it is due to
12
. However attempting endevour of finding answers did not yet produce
13

While experts outperform novices and machines in pattern recognition and problem solving, expert predictions of future behavior or events are seldom as accurate as simple actuarial tables. Why? Some have tried to explain that experts differ when using cognitive 11 ____ to forecast. Researchers believe it is due to 12 ____ . However attempting endevour of finding answers did not yet produce 13 ____$md$, NULL, ARRAY['.*models.*']);

COMMIT;
