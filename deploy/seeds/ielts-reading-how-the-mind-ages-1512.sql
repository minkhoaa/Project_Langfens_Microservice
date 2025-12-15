BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-how-the-mind-ages-1512'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-the-mind-ages-1512';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-the-mind-ages-1512';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-how-the-mind-ages-1512';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('90b56bc1-684e-575c-867e-401846d7a2a6', 'ielts-reading-how-the-mind-ages-1512', $t$How the mind ages$t$, $md$## How the mind ages

Nguồn:
- Test: https://mini-ielts.com/1512/reading/how-the-mind-ages
- Solution: https://mini-ielts.com/1512/view-solution/reading/how-the-mind-ages$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('9b467118-83e1-599c-93c9-33d4164a55e2', '90b56bc1-684e-575c-867e-401846d7a2a6', 1, $t$Reading — How the mind ages$t$, $md$Read the passage and answer questions **1–13**.

### Passage: How the mind ages

The way mental function changes is largely determined by three factors-mental lifestyle, the impact of chronic disease and flexibility of the mind.

Experiments have shown that younger monkeys consistently outperform their older colleagues on memory tests. Formerly, psychologists concluded that memory and other mental functions in humans deteriorate over time because of changes in the brain. Thus mental decline after young adulthood appeared inevitable. The truth, however, is not quite so simple.

Stanley Rapoport at the National Institute of Health in the United States measured the flow of blood in the brains of old and young people as they completed different tasks. Since blood flow reflects neural activity. Rapoport could compare which networks of neurons were the same, the neural networks they used were significantly different. The older subjects used different internal strategies to accomplish comparable results at the same time,'Rapoport says. At the Georgia Institute of Technology, psychologist Timothy Salthouse compared a group of fast and accurate typists of college age with another group in their 60s. Both groups typed 60 words a minute. The older typists, it turned out, achieved their speed with cunning little strategies that made them more efficient than their younger counterparts. They made fewer finger shifts, gaining a fraction of a second here and there. They also read ahead in the test. The neural networks involved in typing appear to have been reshaped to compensate for losses in motor skills or other age changes.

In fact, there's evidence that deterioration in mental functions can actually be reversed. Neuropsychologist Marion Diamond at the University of California has shown that mental activity maks neurons sprout new dendrites* which establish connections with other neurons. The dendrites shrink when the mind is idle. For example,'when a rat is kept in isolation, the animal's brain shrinks, but if we put that rat with other rats in a large cage and give them an assortment of toys, we can show, after four days, significant differences in its brain.'says Diamond. After a month in the enriched surroundings, the whole cerebral cortex has expanded, as has its blood supply.'But even in the enriched surroundings, rats get bored unless the toys are varied. Animals are just like we are. They need stimulation,'says Diamond. A busy mental lifestyle keeps the human mind fit, says Warner Schaie of Penn State University. ‘People who regularly participate in challenging tasks retain their intellectual abilities better than mental couch potatoes.'

In his studies, Schaie detected a decline in mental function among individuals who underwent lengthy stays in hospital for chronic illness. He postulated it might be due to the mental passivity encouraged by hospital routine.

One of the most profoundly important mental functions is memory. Memory exists in more than one form, what we call knowledge- facts- is what psychologists such as Harry Bahrick of Ohio Wesleyan University call semantic memory. Events, conversations and occurrences in time and space, on the other hand, make up episodic memory. It's true that episodic memory begins to decline when most people are in their 50s, but it's never perfect at any age.

Probing the longevity of knowledge, Bahrick tested 1,000 high school graduates to see how well they remembered the school subject algebra. Some had completed the course a month before, other 50 years earlier. Surprisingly, he found that a person's grasp of algebra did not depend on how long ago he'd taken the course. The determining factor was the duration of instruction. Those who had spent only a few months learning algebra forgot most of it within two or three years while others who had been instructed for longer remembered better. According to Bahrick,'the long-term residue of knowledge remains stable over the decades, independent of the age of the person and the memory.'

Perhaps even more important than the ability to remember is the ability to manage memory- a mental function known as metamemory.'You could say metamemory is a byproduct of going to school,'says psychologist Robert Kail of Purdue University,'The question-and-answer process,especially exam taking, helps children learn and teaches them how their memory functions.This may be one reason why the better educated a person is, the more likely they are to perform well in many aspects of life and in psychological assessments: A group of adult novice chess players were compared with a group of child experts at the game. But when asked to remember the patterns of chess pieces arranged on a board, the children won.' Because they'd played a lot of chess, their knowledge of chess was better organized than that of the adults, and their existing knowledge of chess served as a framework for new memory,'explains Kail. Cognitive style, another factor in maintaining mental function, is what Schaie calls the ability to adapt and roll with life's punches.'He measured mental flexibility with questions and tests requiring people to carry out in an offbeat way an everyday activity they had done millions of times. One example was asking people to copy a paragraph substituting uppercase letters for lowercase ones. These tests seem silly, but flexible-minded people manage to complete them,'says Schaie. The rigid person responds with tension instead and performs poorly. Those who score highly on tests of cognition at an advanced age are those who tested high in mental flexibility at middle age'.

On a more optimistic note, one mental resource that only improves with time is specialized knowledge. Crystallised intelligence about one's occupation apparently does not decline at all until at least age 75. Vocabulary is another such specialized form of knowledge. Research clearly shows that vocabulary develops with time. Retired teachers and journalists consistently score higher on tests of vocabulary and general information than college students.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b8c91033-4b5a-5283-8e99-8ae548fd79fd', '9b467118-83e1-599c-93c9-33d4164a55e2', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-3
Questions 1-3
Choose the correct letter
A, B, C or D
.
Write the correct letter in boxes 1-3 on your answer sheet.
1. What does the writer say about the performance of older typists on the test?
A
They used different motor skills from younger typists.
B
They had been more efficiently trained than younger typists.
C
They used more time-saving techniques than younger typists.
D
They had better concentration skills than younger typists.
2. The experiment with the rats showed that
A
brain structure only changed when the rats were given a familiar toy
B
the rats became anxious after a lengthy period of time alone
C
the rats lived longer then they were part of a social group
D
the rats'brains expanded or shrank depending on the level of mental activity
3. A comparison between adults and children who played chess showed that
A
the children were as capable as the adults of remembering a series of numbers
B
the children had better recall of the layout of pieces
C
the adults stored memories of chess moves in a more logical manner
D
the adults had clearer memories of chess games they had played

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f9ce17c7-c6d8-5b37-b7b1-29324d9546b9', '9b467118-83e1-599c-93c9-33d4164a55e2', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-3
Questions 1-3
Choose the correct letter
A, B, C or D
.
Write the correct letter in boxes 1-3 on your answer sheet.
1. What does the writer say about the performance of older typists on the test?
A
They used different motor skills from younger typists.
B
They had been more efficiently trained than younger typists.
C
They used more time-saving techniques than younger typists.
D
They had better concentration skills than younger typists.
2. The experiment with the rats showed that
A
brain structure only changed when the rats were given a familiar toy
B
the rats became anxious after a lengthy period of time alone
C
the rats lived longer then they were part of a social group
D
the rats'brains expanded or shrank depending on the level of mental activity
3. A comparison between adults and children who played chess showed that
A
the children were as capable as the adults of remembering a series of numbers
B
the children had better recall of the layout of pieces
C
the adults stored memories of chess moves in a more logical manner
D
the adults had clearer memories of chess games they had played

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a47d5cc9-1a81-5a43-a1d8-1c85cebc62da', '9b467118-83e1-599c-93c9-33d4164a55e2', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-3
Questions 1-3
Choose the correct letter
A, B, C or D
.
Write the correct letter in boxes 1-3 on your answer sheet.
1. What does the writer say about the performance of older typists on the test?
A
They used different motor skills from younger typists.
B
They had been more efficiently trained than younger typists.
C
They used more time-saving techniques than younger typists.
D
They had better concentration skills than younger typists.
2. The experiment with the rats showed that
A
brain structure only changed when the rats were given a familiar toy
B
the rats became anxious after a lengthy period of time alone
C
the rats lived longer then they were part of a social group
D
the rats'brains expanded or shrank depending on the level of mental activity
3. A comparison between adults and children who played chess showed that
A
the children were as capable as the adults of remembering a series of numbers
B
the children had better recall of the layout of pieces
C
the adults stored memories of chess moves in a more logical manner
D
the adults had clearer memories of chess games they had played

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6839aba9-f940-52b2-b70b-a4379727967c', '9b467118-83e1-599c-93c9-33d4164a55e2', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 4-9
Questions 4-9
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 17-22 on your answer sheet.
Types of memory
Psychologists distinguish between two different types of memory:
4
Locate
and
5
Locate
memory. A study was conducted into people's knowledge of
6
Locate
to determine recall ability. This aspect of memory was found to be a function not of age but rather of length of tuition.
School also helps with a brain function called
7
Locate
. This is why a more highly educated person is generally more successful and does better in
8
Locate
tests.
Some of our mental functions remain unaffected by age or even improve. For example, as we get older, our knowledge of
9
Locate
increases.

Psychologists distinguish between two different types of memory: 4 ____ Locate and 5 ____ Locate memory. A study was conducted into people's knowledge of 6 ____ Locate to determine recall ability. This aspect of memory was found to be a function not of age but rather of length of tuition.$md$, NULL, ARRAY['.*semantic.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('eeffa04f-3f97-5e77-a1b1-82c9798d7079', '9b467118-83e1-599c-93c9-33d4164a55e2', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 4-9
Questions 4-9
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 17-22 on your answer sheet.
Types of memory
Psychologists distinguish between two different types of memory:
4
Locate
and
5
Locate
memory. A study was conducted into people's knowledge of
6
Locate
to determine recall ability. This aspect of memory was found to be a function not of age but rather of length of tuition.
School also helps with a brain function called
7
Locate
. This is why a more highly educated person is generally more successful and does better in
8
Locate
tests.
Some of our mental functions remain unaffected by age or even improve. For example, as we get older, our knowledge of
9
Locate
increases.

Psychologists distinguish between two different types of memory: 4 ____ Locate and 5 ____ Locate memory. A study was conducted into people's knowledge of 6 ____ Locate to determine recall ability. This aspect of memory was found to be a function not of age but rather of length of tuition.$md$, NULL, ARRAY['.*semantic.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d78d737b-6849-5fe7-9a7c-0fef1dbc9d0a', '9b467118-83e1-599c-93c9-33d4164a55e2', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 4-9
Questions 4-9
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 17-22 on your answer sheet.
Types of memory
Psychologists distinguish between two different types of memory:
4
Locate
and
5
Locate
memory. A study was conducted into people's knowledge of
6
Locate
to determine recall ability. This aspect of memory was found to be a function not of age but rather of length of tuition.
School also helps with a brain function called
7
Locate
. This is why a more highly educated person is generally more successful and does better in
8
Locate
tests.
Some of our mental functions remain unaffected by age or even improve. For example, as we get older, our knowledge of
9
Locate
increases.

Psychologists distinguish between two different types of memory: 4 ____ Locate and 5 ____ Locate memory. A study was conducted into people's knowledge of 6 ____ Locate to determine recall ability. This aspect of memory was found to be a function not of age but rather of length of tuition.$md$, NULL, ARRAY['.*semantic.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2be83237-591d-5bc2-aaca-c9d8aded4c2e', '9b467118-83e1-599c-93c9-33d4164a55e2', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 4-9
Questions 4-9
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 17-22 on your answer sheet.
Types of memory
Psychologists distinguish between two different types of memory:
4
Locate
and
5
Locate
memory. A study was conducted into people's knowledge of
6
Locate
to determine recall ability. This aspect of memory was found to be a function not of age but rather of length of tuition.
School also helps with a brain function called
7
Locate
. This is why a more highly educated person is generally more successful and does better in
8
Locate
tests.
Some of our mental functions remain unaffected by age or even improve. For example, as we get older, our knowledge of
9
Locate
increases.

School also helps with a brain function called 7 ____ Locate . This is why a more highly educated person is generally more successful and does better in 8 ____ Locate tests.$md$, NULL, ARRAY['.*metamemory.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('97a8ce73-a9b4-5d38-8969-e38122237456', '9b467118-83e1-599c-93c9-33d4164a55e2', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 4-9
Questions 4-9
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 17-22 on your answer sheet.
Types of memory
Psychologists distinguish between two different types of memory:
4
Locate
and
5
Locate
memory. A study was conducted into people's knowledge of
6
Locate
to determine recall ability. This aspect of memory was found to be a function not of age but rather of length of tuition.
School also helps with a brain function called
7
Locate
. This is why a more highly educated person is generally more successful and does better in
8
Locate
tests.
Some of our mental functions remain unaffected by age or even improve. For example, as we get older, our knowledge of
9
Locate
increases.

School also helps with a brain function called 7 ____ Locate . This is why a more highly educated person is generally more successful and does better in 8 ____ Locate tests.$md$, NULL, ARRAY['.*metamemory.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ba4dbec5-6844-589a-a8b3-a6fbb3cfdd8a', '9b467118-83e1-599c-93c9-33d4164a55e2', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 4-9
Questions 4-9
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 17-22 on your answer sheet.
Types of memory
Psychologists distinguish between two different types of memory:
4
Locate
and
5
Locate
memory. A study was conducted into people's knowledge of
6
Locate
to determine recall ability. This aspect of memory was found to be a function not of age but rather of length of tuition.
School also helps with a brain function called
7
Locate
. This is why a more highly educated person is generally more successful and does better in
8
Locate
tests.
Some of our mental functions remain unaffected by age or even improve. For example, as we get older, our knowledge of
9
Locate
increases.

Some of our mental functions remain unaffected by age or even improve. For example, as we get older, our knowledge of 9 ____ Locate increases.$md$, NULL, ARRAY['.*vocabulary.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1132e767-fb5f-544c-9d00-82739425e588', '9b467118-83e1-599c-93c9-33d4164a55e2', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Look at the following statements and the list of people below.
Match each statement with the correct person,
A-E
.
Write the correct letter,
A-E
, in boxes 23-26 on your answer sheet.
10
The educational system makes students aware of how their memory works.
11
Although older people may use a different mental approach when completing a task, they can still achieve the same result as younger people
12
Being open to new ways of doing things can have a positive impact on your mental condition as we get older
13
Both animals and humans need to exist in an environment full of interest.
List of People
A Stanley Rapoport
B Marion Diamond
C Warner Schaie
D Harry Bahrick
E Robert Kail

10 ____ The educational system makes students aware of how their memory works.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acf43c02-9757-59ef-b6e4-3ff1042d44ca', '1132e767-fb5f-544c-9d00-82739425e588', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee998890-9e98-5ad0-a378-a1699a931072', '1132e767-fb5f-544c-9d00-82739425e588', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ad85e28-2a57-56a8-ab83-e23eb97265cf', '1132e767-fb5f-544c-9d00-82739425e588', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fedfbcf-cf64-55a3-9991-8fd7e349b444', '1132e767-fb5f-544c-9d00-82739425e588', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a32e05fb-b9c0-558b-a2c8-a75c9a40350f', '1132e767-fb5f-544c-9d00-82739425e588', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b8e38267-0cf8-5c02-8309-bf2ca2aa8367', '9b467118-83e1-599c-93c9-33d4164a55e2', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Look at the following statements and the list of people below.
Match each statement with the correct person,
A-E
.
Write the correct letter,
A-E
, in boxes 23-26 on your answer sheet.
10
The educational system makes students aware of how their memory works.
11
Although older people may use a different mental approach when completing a task, they can still achieve the same result as younger people
12
Being open to new ways of doing things can have a positive impact on your mental condition as we get older
13
Both animals and humans need to exist in an environment full of interest.
List of People
A Stanley Rapoport
B Marion Diamond
C Warner Schaie
D Harry Bahrick
E Robert Kail

11 ____ Although older people may use a different mental approach when completing a task, they can still achieve the same result as younger people$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c11bc52-b694-5699-b2e3-1deb0509c096', 'b8e38267-0cf8-5c02-8309-bf2ca2aa8367', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3aa88ab9-b7b9-5c6d-9906-b84b55abafa9', 'b8e38267-0cf8-5c02-8309-bf2ca2aa8367', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e55c6d0f-470e-5784-8860-9288ed9278bc', 'b8e38267-0cf8-5c02-8309-bf2ca2aa8367', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5794e73-2ce7-56e1-82a3-20b69a685edc', 'b8e38267-0cf8-5c02-8309-bf2ca2aa8367', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6994379-a9d4-54b8-a930-8ac434b91cda', 'b8e38267-0cf8-5c02-8309-bf2ca2aa8367', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('64cddaad-a619-5b18-89b5-fca5f8d43121', '9b467118-83e1-599c-93c9-33d4164a55e2', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Look at the following statements and the list of people below.
Match each statement with the correct person,
A-E
.
Write the correct letter,
A-E
, in boxes 23-26 on your answer sheet.
10
The educational system makes students aware of how their memory works.
11
Although older people may use a different mental approach when completing a task, they can still achieve the same result as younger people
12
Being open to new ways of doing things can have a positive impact on your mental condition as we get older
13
Both animals and humans need to exist in an environment full of interest.
List of People
A Stanley Rapoport
B Marion Diamond
C Warner Schaie
D Harry Bahrick
E Robert Kail

12 ____ Being open to new ways of doing things can have a positive impact on your mental condition as we get older$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acc4b296-1827-5390-b251-b2f37ee97fca', '64cddaad-a619-5b18-89b5-fca5f8d43121', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9619ed89-da7c-5630-a79e-3e1b6585a40e', '64cddaad-a619-5b18-89b5-fca5f8d43121', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52d71a3d-f1e8-5a34-a32b-f8a22667552f', '64cddaad-a619-5b18-89b5-fca5f8d43121', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df8e2a12-30f0-5cd6-a7db-43b1626d2e02', '64cddaad-a619-5b18-89b5-fca5f8d43121', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70adea21-37ec-55a1-9d9e-af1d5ef8d662', '64cddaad-a619-5b18-89b5-fca5f8d43121', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('81e102bd-8920-58af-8149-f58a27413316', '9b467118-83e1-599c-93c9-33d4164a55e2', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Look at the following statements and the list of people below.
Match each statement with the correct person,
A-E
.
Write the correct letter,
A-E
, in boxes 23-26 on your answer sheet.
10
The educational system makes students aware of how their memory works.
11
Although older people may use a different mental approach when completing a task, they can still achieve the same result as younger people
12
Being open to new ways of doing things can have a positive impact on your mental condition as we get older
13
Both animals and humans need to exist in an environment full of interest.
List of People
A Stanley Rapoport
B Marion Diamond
C Warner Schaie
D Harry Bahrick
E Robert Kail

13 ____ Both animals and humans need to exist in an environment full of interest.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63671dbe-a115-5b92-bab8-517978d9de4c', '81e102bd-8920-58af-8149-f58a27413316', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e51a8ddc-f580-5fe8-94a8-ec507961e807', '81e102bd-8920-58af-8149-f58a27413316', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9678d20d-b1dc-57f7-b8d3-727eafa317ca', '81e102bd-8920-58af-8149-f58a27413316', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adc8bea1-169c-57ad-8141-6946b31b6d60', '81e102bd-8920-58af-8149-f58a27413316', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01c3fe16-5ad0-5377-b667-7bba5fb17154', '81e102bd-8920-58af-8149-f58a27413316', 5, $md$E$md$, false);

COMMIT;
