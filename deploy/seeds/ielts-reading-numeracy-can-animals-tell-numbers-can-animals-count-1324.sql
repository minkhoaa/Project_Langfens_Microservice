BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-numeracy-can-animals-tell-numbers-can-animals-count-1324'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-numeracy-can-animals-tell-numbers-can-animals-count-1324';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-numeracy-can-animals-tell-numbers-can-animals-count-1324';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-numeracy-can-animals-tell-numbers-can-animals-count-1324';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('5d7fb93a-a26f-5d42-91d5-45dcc925b968', 'ielts-reading-numeracy-can-animals-tell-numbers-can-animals-count-1324', $t$Numeracy: can animals tell numbers? (Can animals count?)$t$, $md$## Numeracy: can animals tell numbers? (Can animals count?)

Nguồn:
- Test: https://mini-ielts.com/1324/reading/numeracy-can-animals-tell-numbers-can-animals-count
- Solution: https://mini-ielts.com/1324/view-solution/reading/numeracy-can-animals-tell-numbers-can-animals-count$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', '5d7fb93a-a26f-5d42-91d5-45dcc925b968', 1, $t$Reading — Numeracy: can animals tell numbers? (Can animals count?)$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Numeracy: can animals tell numbers? (Can animals count?)

A

Prime among basic numerical faculties is the ability to distinguish between a larger and a smaller, says psychologist Elizabeth Brannon. Humans can do this with ease – providing the ratio is big enough – but do other animals share this ability? In one experiment, rhesus monkeys and university students examined two sets of geometrical objects that appeared briefly on a computer monitor. They had to decide which set contained more objects. Both groups performed successfully but, importantly, Brannon’s team found that monkeys, like humans, make more errors when two sets of objects are close in number. The students’ performance ends up looking just like a monkey’s. It’s practically identical, she says.

B

Humans and monkeys are mammals, in the animal family known as primates. These are not the only animals whose numerical capacities rely on ratio, however. The same seems to apply to some amphibians. Psychologist Claudia Uller’s team tempted salamanders with two sets of fruit flies held in clear tubes. In a series of trials, the researchers noted which tube the salamanders scampered towards, reasoning that if they had a capacity to recognise the number, they would head for the larger number. The salamanders successfully discriminated between tubes containing 8 and 16 flies respectively, but not between 3 and 4, 4 and 6, or 8 and 12. So it seems that for the salamanders to discriminate between two numbers, the larger must be at least twice as big as the smaller. However, they could differentiate between 2 and 3 flies just as well as between 1 and 2 flies, suggesting they recognise small numbers in a different way from larger numbers.

C

Further support for this theory comes from studies of mosquitofish, which instinctively join the biggest shoal they can. A team at the University of Padova found that while mosquitofish can tell the difference between a group containing 3 shoal-mates and a group containing 4, they did not show a preference between groups of 4 and 5. The team also found that mosquitofish can discriminate between numbers up to 16, but only if the ratio between the fish in each shoal was greater than 2:1. This indicates that the fish, like salamanders, possess both the approximate and precise number systems found in more intelligent animals such as infant humans and other primates.

D

While these findings are highly suggestive, some critics argue that the animals might be relying on other factors to complete the tasks, without considering the number itself. ‘Any study that’s claiming an animal is capable of representing number should also be controlling for other factors,’ says Brannon. Experiments have confirmed that primates can indeed perform numerical feats without extra clues, but what about the more primitive animals?

E

To consider this possibility, the mosquitofish tests were repeated, this time using varying geometrical shapes in place of fish. The team arranged these shapes so that they had the same overall surface area and luminance even though they contained a different number of objects. Across hundreds of trials on 14 different fish, the team found they consistently discriminated 2 objects from 3. The team is now testing whether mosquitofish can also distinguish 3 geometric objects from 4.

F

Even more primitive organisms may share this ability. Entomologist Jurgen Tautz sent a group of bees down a corridor, at the end of which lay two chambers – one which contained sugar water, which they like, while the other was empty. To test the bees’ numeracy, the team marked each chamber with a different number of geometrical shapes – between 2 and 6. The bees quickly learned to match the number of shapes with the correct chamber. Like the salamanders and fish, there was a limit to the bees’ mathematical prowess – they could differentiate up to 4 shapes, but failed with 5 or 6 shapes.

G

These studies still do not show whether animals learn to count through training, or whether they are born with the skills already intact. If the latter is true, it would suggest there was a strong evolutionary advantage to a mathematical mind. Proof that this may be the case has emerged from an experiment testing the mathematical ability of three – and four-day-old chicks. Like mosquitofish, chicks prefer to be around as many of their siblings as possible, so they will always head towards a larger number of their kin. If chicks spend their first few days surrounded by certain objects, they become attached to these objects as if they were family. Researchers placed each chick in the middle of a platform and showed it two groups of balls of paper. Next, they hid the two piles behind screens, changed the quantities and revealed them to the chick. This forced the chick to perform simple computations to decide which side now contained the biggest number of its “brothers”. Without any prior coaching, the chicks scuttled to the larger quantity at a rate well above chance. They were doing some very simple arithmetic, claim the researchers.

H

Why these skills evolved is not hard to imagine, since it would help almost any animal forage for food. Animals on the prowl for sustenance must constantly decide which tree has the most fruit, or which patch of flowers will contain the most nectar. There are also other, less obvious, advantages of numeracy. In one compelling example, researchers in America found that female coots appear to calculate how many eggs they have laid – and add any in the nest laid by an intruder – before making any decisions about adding to them. Exactly how ancient these skills are is difficult to determine, however. Only by studying the numerical abilities of more and more creatures using standardised procedures can we hope to understand the basic preconditions for the evolution of number.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('94b8bf03-3e8d-5d84-b763-817220f39bec', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 1, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Answer the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet
Animal numeracy
Subjects
Experiments
Results
Mammals and birds
rhesus monkeys and humans
looked at two sets of geometrical objects on a computer screen
Performance of the two groups is almost
1
chicks
chose between two sets of
2
which are altered
chicks can do calculations in order to choose a larger group
coots
behaviour of female birds was observed
A bird seems to have ability to
3
Amphibians, fish and insects
salamanders
offered clear tubes containing different quantities of
4
salamanders distinguish between numbers over four if the bigger number is at least two times larger
5
shown real shoals and later artificial ones of geometrical shapes; these are used to check the influence of total
6
and brightness
subjects know the difference between two and three and possibly three and four, but not between four and five
bees
Had to learn where
7
was stored
could soon choose the correct place

Performance of the two groups is almost 1 ____$md$, NULL, ARRAY['.*identical.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('77407e12-0879-594c-839f-bc511e7527da', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 2, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Answer the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet
Animal numeracy
Subjects
Experiments
Results
Mammals and birds
rhesus monkeys and humans
looked at two sets of geometrical objects on a computer screen
Performance of the two groups is almost
1
chicks
chose between two sets of
2
which are altered
chicks can do calculations in order to choose a larger group
coots
behaviour of female birds was observed
A bird seems to have ability to
3
Amphibians, fish and insects
salamanders
offered clear tubes containing different quantities of
4
salamanders distinguish between numbers over four if the bigger number is at least two times larger
5
shown real shoals and later artificial ones of geometrical shapes; these are used to check the influence of total
6
and brightness
subjects know the difference between two and three and possibly three and four, but not between four and five
bees
Had to learn where
7
was stored
could soon choose the correct place

chose between two sets of 2 ____ which are altered$md$, NULL, ARRAY['.*balls.*of.*paper.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('575e4b91-402c-576d-bc42-c2b1f5fb4c22', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 3, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Answer the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet
Animal numeracy
Subjects
Experiments
Results
Mammals and birds
rhesus monkeys and humans
looked at two sets of geometrical objects on a computer screen
Performance of the two groups is almost
1
chicks
chose between two sets of
2
which are altered
chicks can do calculations in order to choose a larger group
coots
behaviour of female birds was observed
A bird seems to have ability to
3
Amphibians, fish and insects
salamanders
offered clear tubes containing different quantities of
4
salamanders distinguish between numbers over four if the bigger number is at least two times larger
5
shown real shoals and later artificial ones of geometrical shapes; these are used to check the influence of total
6
and brightness
subjects know the difference between two and three and possibly three and four, but not between four and five
bees
Had to learn where
7
was stored
could soon choose the correct place

A bird seems to have ability to 3 ____$md$, NULL, ARRAY['.*calculate.*eggs.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4d9bffd0-52c7-5cf8-9d17-5436cad904c3', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 4, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Answer the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet
Animal numeracy
Subjects
Experiments
Results
Mammals and birds
rhesus monkeys and humans
looked at two sets of geometrical objects on a computer screen
Performance of the two groups is almost
1
chicks
chose between two sets of
2
which are altered
chicks can do calculations in order to choose a larger group
coots
behaviour of female birds was observed
A bird seems to have ability to
3
Amphibians, fish and insects
salamanders
offered clear tubes containing different quantities of
4
salamanders distinguish between numbers over four if the bigger number is at least two times larger
5
shown real shoals and later artificial ones of geometrical shapes; these are used to check the influence of total
6
and brightness
subjects know the difference between two and three and possibly three and four, but not between four and five
bees
Had to learn where
7
was stored
could soon choose the correct place

offered clear tubes containing different quantities of 4 ____$md$, NULL, ARRAY['.*fruits.*flies.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d20eb6be-7523-5516-a753-8b4a17426203', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 5, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Answer the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet
Animal numeracy
Subjects
Experiments
Results
Mammals and birds
rhesus monkeys and humans
looked at two sets of geometrical objects on a computer screen
Performance of the two groups is almost
1
chicks
chose between two sets of
2
which are altered
chicks can do calculations in order to choose a larger group
coots
behaviour of female birds was observed
A bird seems to have ability to
3
Amphibians, fish and insects
salamanders
offered clear tubes containing different quantities of
4
salamanders distinguish between numbers over four if the bigger number is at least two times larger
5
shown real shoals and later artificial ones of geometrical shapes; these are used to check the influence of total
6
and brightness
subjects know the difference between two and three and possibly three and four, but not between four and five
bees
Had to learn where
7
was stored
could soon choose the correct place

5 ____$md$, NULL, ARRAY['.*mosquitofish.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('228d4c63-7396-5014-9004-bf5d79e5755a', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 6, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Answer the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet
Animal numeracy
Subjects
Experiments
Results
Mammals and birds
rhesus monkeys and humans
looked at two sets of geometrical objects on a computer screen
Performance of the two groups is almost
1
chicks
chose between two sets of
2
which are altered
chicks can do calculations in order to choose a larger group
coots
behaviour of female birds was observed
A bird seems to have ability to
3
Amphibians, fish and insects
salamanders
offered clear tubes containing different quantities of
4
salamanders distinguish between numbers over four if the bigger number is at least two times larger
5
shown real shoals and later artificial ones of geometrical shapes; these are used to check the influence of total
6
and brightness
subjects know the difference between two and three and possibly three and four, but not between four and five
bees
Had to learn where
7
was stored
could soon choose the correct place

shown real shoals and later artificial ones of geometrical shapes; these are used to check the influence of total 6 ____ and brightness$md$, NULL, ARRAY['.*surface.*area.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ee07d471-0355-5b2b-9432-e0581a7c1cb9', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 7, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Answer the table below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes
1-7
on your answer sheet
Animal numeracy
Subjects
Experiments
Results
Mammals and birds
rhesus monkeys and humans
looked at two sets of geometrical objects on a computer screen
Performance of the two groups is almost
1
chicks
chose between two sets of
2
which are altered
chicks can do calculations in order to choose a larger group
coots
behaviour of female birds was observed
A bird seems to have ability to
3
Amphibians, fish and insects
salamanders
offered clear tubes containing different quantities of
4
salamanders distinguish between numbers over four if the bigger number is at least two times larger
5
shown real shoals and later artificial ones of geometrical shapes; these are used to check the influence of total
6
and brightness
subjects know the difference between two and three and possibly three and four, but not between four and five
bees
Had to learn where
7
was stored
could soon choose the correct place

Had to learn where 7 ____ was stored$md$, NULL, ARRAY['.*sugar.*water.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('054ce831-7ed4-59ce-9445-de2828ec1d53', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
Primates are better at identifying the larger of two numbers if one is much bigger than the other.
9
Jurgen Tautz trained the insects in his experiment to recognise the shapes of individual numbers.
10
The research involving young chicks took place over two separate days.
11
The experiment with chicks suggests that some numerical ability exists in newborn animals.
12
Researchers have experimented by altering quantities of nectar or fruit available to certain wild animals.
13
When assessing the number of eggs in their nest, coots take into account those of other birds.

8 ____ Primates are better at identifying the larger of two numbers if one is much bigger than the other.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d7f159f-ed6a-5545-afd3-fe9a51a52eb5', '054ce831-7ed4-59ce-9445-de2828ec1d53', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38aa0b7a-7fa5-5727-ad2f-78293d1f755e', '054ce831-7ed4-59ce-9445-de2828ec1d53', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6dd382be-552f-59b0-8277-4019c91e5074', '054ce831-7ed4-59ce-9445-de2828ec1d53', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('23ebe759-4fc2-5d73-ab92-08c1f3feca43', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
Primates are better at identifying the larger of two numbers if one is much bigger than the other.
9
Jurgen Tautz trained the insects in his experiment to recognise the shapes of individual numbers.
10
The research involving young chicks took place over two separate days.
11
The experiment with chicks suggests that some numerical ability exists in newborn animals.
12
Researchers have experimented by altering quantities of nectar or fruit available to certain wild animals.
13
When assessing the number of eggs in their nest, coots take into account those of other birds.

9 ____ Jurgen Tautz trained the insects in his experiment to recognise the shapes of individual numbers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f700b1f0-dc11-57d8-9055-cd902e55bf91', '23ebe759-4fc2-5d73-ab92-08c1f3feca43', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edb45bc6-5532-5b8e-94cc-d016ec4a512f', '23ebe759-4fc2-5d73-ab92-08c1f3feca43', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a8686a4-a889-5062-bb83-9fa41f73c05d', '23ebe759-4fc2-5d73-ab92-08c1f3feca43', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('82a3acff-8bb8-53dc-8da8-d5889dc94cd7', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
Primates are better at identifying the larger of two numbers if one is much bigger than the other.
9
Jurgen Tautz trained the insects in his experiment to recognise the shapes of individual numbers.
10
The research involving young chicks took place over two separate days.
11
The experiment with chicks suggests that some numerical ability exists in newborn animals.
12
Researchers have experimented by altering quantities of nectar or fruit available to certain wild animals.
13
When assessing the number of eggs in their nest, coots take into account those of other birds.

10 ____ The research involving young chicks took place over two separate days.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47505688-440a-5519-9a57-a3c17de24b34', '82a3acff-8bb8-53dc-8da8-d5889dc94cd7', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4196c8bf-fdf9-5f22-a46d-3d0fa53bf39c', '82a3acff-8bb8-53dc-8da8-d5889dc94cd7', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0de666d1-73a2-5ab1-bf9e-7c006ac4e13d', '82a3acff-8bb8-53dc-8da8-d5889dc94cd7', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1647acd8-9073-5807-a692-16ed70b54c19', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
Primates are better at identifying the larger of two numbers if one is much bigger than the other.
9
Jurgen Tautz trained the insects in his experiment to recognise the shapes of individual numbers.
10
The research involving young chicks took place over two separate days.
11
The experiment with chicks suggests that some numerical ability exists in newborn animals.
12
Researchers have experimented by altering quantities of nectar or fruit available to certain wild animals.
13
When assessing the number of eggs in their nest, coots take into account those of other birds.

11 ____ The experiment with chicks suggests that some numerical ability exists in newborn animals.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c57d1cb-31cf-537b-af81-8eadefcb1ef2', '1647acd8-9073-5807-a692-16ed70b54c19', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fd9147c-b49c-5196-af65-2e8860aae1fb', '1647acd8-9073-5807-a692-16ed70b54c19', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c5bee21-5470-565e-a777-74559fbf572a', '1647acd8-9073-5807-a692-16ed70b54c19', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1af566b8-62bf-54ed-9533-a22374cf90a0', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
Primates are better at identifying the larger of two numbers if one is much bigger than the other.
9
Jurgen Tautz trained the insects in his experiment to recognise the shapes of individual numbers.
10
The research involving young chicks took place over two separate days.
11
The experiment with chicks suggests that some numerical ability exists in newborn animals.
12
Researchers have experimented by altering quantities of nectar or fruit available to certain wild animals.
13
When assessing the number of eggs in their nest, coots take into account those of other birds.

12 ____ Researchers have experimented by altering quantities of nectar or fruit available to certain wild animals.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8559c195-c751-5e16-93a6-23cd2f038694', '1af566b8-62bf-54ed-9533-a22374cf90a0', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44e877f7-b02b-56ea-a96e-273a625b426e', '1af566b8-62bf-54ed-9533-a22374cf90a0', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6de445d-effd-5a61-a7aa-18138ce4210a', '1af566b8-62bf-54ed-9533-a22374cf90a0', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5db22de0-0644-5fa2-b9c4-d782df3ea5f6', 'ebca96d8-06a3-5a8c-98ef-79fc5cc21c23', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
8
Primates are better at identifying the larger of two numbers if one is much bigger than the other.
9
Jurgen Tautz trained the insects in his experiment to recognise the shapes of individual numbers.
10
The research involving young chicks took place over two separate days.
11
The experiment with chicks suggests that some numerical ability exists in newborn animals.
12
Researchers have experimented by altering quantities of nectar or fruit available to certain wild animals.
13
When assessing the number of eggs in their nest, coots take into account those of other birds.

13 ____ When assessing the number of eggs in their nest, coots take into account those of other birds.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fe273ce-b200-5a2b-bb73-70fc5f045998', '5db22de0-0644-5fa2-b9c4-d782df3ea5f6', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('286f7da3-9c6a-50b7-9bb6-8edd921bea0c', '5db22de0-0644-5fa2-b9c4-d782df3ea5f6', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8880f69b-7b3a-50c2-9beb-2a7f61912a39', '5db22de0-0644-5fa2-b9c4-d782df3ea5f6', 3, $md$NOT GIVEN$md$, false);

COMMIT;
