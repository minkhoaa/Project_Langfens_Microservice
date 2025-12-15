BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-decision-making-and-happiness-1385'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-decision-making-and-happiness-1385';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-decision-making-and-happiness-1385';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-decision-making-and-happiness-1385';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('444d6ca4-7724-5f9c-8da8-6f5fd7d69da9', 'ielts-reading-decision-making-and-happiness-1385', $t$Decision making and Happiness$t$, $md$## Decision making and Happiness

Nguồn:
- Test: https://mini-ielts.com/1385/reading/decision-making-and-happiness
- Solution: https://mini-ielts.com/1385/view-solution/reading/decision-making-and-happiness$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('8c475292-0390-53a1-9be6-1f5be9f06a87', '444d6ca4-7724-5f9c-8da8-6f5fd7d69da9', 1, $t$Reading — Decision making and Happiness$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Decision making and Happiness

A

Americans today choose among more options in more parts of life than has ever been pos­sible before. To an extent, the opportunity to choose enhances our lives. It is only logical to think that if some choices are good, more is better; people who care about having infinite options will benefit from them, and those who do not can always just ignore the 273 versions of cereal they have never tried. Yet recent research strongly suggests that, psychologically, this assumption is wrong, with 5% lower percentage announcing they are happy. Although some choices are undoubtedly better than none, more is not always better than less.

B

Recent research offers insight into why many people end up unhappy rather than pleased when their options expand. We began by making a distinction between “maximizers” (those who always aim to make the best possible choice) and “satisficers” (those who aim for “good enough,” whether or not better selections might be out there).

C

In particular, we composed a set of statements—the Maximization Scale—to diagnose peo­ple’s propensity to maximize. Then we had several thousand people rate themselves from 1 to 7 (from “completely disagree” to “completely agree”) on such statements as “I never settle for second best.” We also evaluated their sense of satisfaction with their decisions. We did not define a sharp cutoff to separate maximizers from satisficers, but in general, we think of individuals whose average scores are higher than 4 (the scale’s midpoint) as maxi- misers and those whose scores are lower than the midpoint as satisficers. People who score highest on the test—the greatest maximizers—engage in more product comparisons than the lowest scorers, both before and after they make purchasing decisions, and they take longer to decide what to buy. When satisficers find an item that meets their standards, they stop looking. But maximizers exert enormous effort reading labels, checking out consumer magazines and trying new products. They also spend more time comparing their purchas­ing decisions with those of others.

D

We found that the greatest maximizers are the least happy with the fruits of their efforts. When they compare themselves with others, they get little pleasure from finding out that they did better and substantial dissatisfaction from finding out that they did worse. They are more prone to experiencing regret after a purchase, and if their acquisition disappoints them, their sense of well-being takes longer to recover. They also tend to brood or ruminate more than satisficers do.

E

Does it follow that maximizers are less happy in general than satisficers? We tested this by having people fill out a variety of questionnaires known to be reliable indicators of well­being. As might be expected, individuals with high maximization scores experienced less satisfaction with life and were less happy, less optimistic and more depressed than people with low maximization scores. Indeed, those with extreme maximization ratings had depression scores that placed them in the borderline of clinical range.

F

Several factors explain why more choice is not always better than less, especially for maxi­misers. High among these are “opportunity costs.” The quality of any given option cannot be assessed in isolation from its alternatives. One of the “costs” of making a selection is losing the opportunities that a different option would have afforded. Thus, an opportunity cost of vacationing on the beach in Cape Cod might be missing the fabulous restaurants in the Napa Valley. Early Decision Making Research by Daniel Kahneman and Amos Tversky showed that people respond much more strongly to losses than gains. If we assume that opportunity costs reduce the overall desirability of the most preferred choice, then the more alternatives there are, the deeper our sense of loss will be and the less satisfaction we will derive from our ultimate decision.

G

The problem of opportunity costs will be better for a satisficer. The latter’s “good enough” philosophy can survive thoughts about opportunity costs. In addition, the “good enough” standard leads to much less searching and inspection of alternatives than the maximizer’s “best” standard. With fewer choices under consideration, a person will have fewer opportu­nity costs to subtract.

H

Just as people feel sorrow about the opportunities they have forgone, they may also suffer regret about the option they settled on. My colleagues and I devised a scale to measure proneness to feeling regret, and we found that people with high sensitivity to regret are less happy, less satisfied with life, less optimistic and more depressed than those with low sensitivity. Not surprisingly, we also found that people with high regret sensitivity tend to be maximizers. Indeed, we think that worry over future regret is a major reason that individuals become maximizers. The only way to be sure you will not regret a decision is by making the best possible one. Unfortunately, the more options you have and the more opportunity costs you incur, the more likely you are to experience regret.

I

In a classic demonstration of the power of sunk costs, people were offered season subscrip­tions to a local theatre company. Some were offered the tickets at full price and others at a discount. Then the researchers simply kept track of how often the ticket purchasers actu­ally attended the plays over the course of the season. Full-price payers were more likely to show up at performances than discount payers. The reason for this, the investigators argued, was that the full-price payers would experience more regret if they did not use the tickets because not using the more costly tickets would constitute a bigger loss. To increase sense of happiness, we can decide to restrict our options when the decision is not crucial. For example, make a rule to visit no more than two stores when shopping for clothing.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6541a6e7-32f8-578b-926e-d12a3f02e18f', '8c475292-0390-53a1-9be6-1f5be9f06a87', 1, 'CLASSIFICATION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Look at the following descriptions or deeds (Questions
1-4
) and the list of catego­ries below.
Match each description or deed with the correct category,
A-D
.
Write the correct letter,
A-D
, in boxes
1-4
on your answer sheet.
A
“maximizers”
B
“satisficers”
C
neither “maximizers” nor “satisficers”
D
both “maximizers” and “satisficers”
1
rated to the Maximization Scale of making choice
2
don’t take much time before making a decision
3
are likely to regret about the choice in the future
4
choose the highest price in the range of purchase

1 ____ rated to the Maximization Scale of making choice$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b5791b5-1374-589e-947f-285a78e10645', '6541a6e7-32f8-578b-926e-d12a3f02e18f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec9f944e-26db-575b-8a36-8b7b983920f0', '6541a6e7-32f8-578b-926e-d12a3f02e18f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a59166f-03b3-5d7b-9046-488a6f85a175', '6541a6e7-32f8-578b-926e-d12a3f02e18f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2757e289-b237-5ec5-bfec-0ee80ef02f6b', '6541a6e7-32f8-578b-926e-d12a3f02e18f', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc81ae0a-af48-5366-abf3-561711b8e77f', '8c475292-0390-53a1-9be6-1f5be9f06a87', 2, 'CLASSIFICATION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Look at the following descriptions or deeds (Questions
1-4
) and the list of catego­ries below.
Match each description or deed with the correct category,
A-D
.
Write the correct letter,
A-D
, in boxes
1-4
on your answer sheet.
A
“maximizers”
B
“satisficers”
C
neither “maximizers” nor “satisficers”
D
both “maximizers” and “satisficers”
1
rated to the Maximization Scale of making choice
2
don’t take much time before making a decision
3
are likely to regret about the choice in the future
4
choose the highest price in the range of purchase

2 ____ don’t take much time before making a decision$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5409672d-cf7f-5617-b6dc-b5668883dd86', 'fc81ae0a-af48-5366-abf3-561711b8e77f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06ad8dad-89fb-5315-aa6b-e0fc67ad8f64', 'fc81ae0a-af48-5366-abf3-561711b8e77f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('beb2897d-4418-5c2e-b3e9-596cd005ea4b', 'fc81ae0a-af48-5366-abf3-561711b8e77f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('364094fb-b150-506f-8306-965e7ffeea62', 'fc81ae0a-af48-5366-abf3-561711b8e77f', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e525bf61-6491-5191-8566-5d9d50860941', '8c475292-0390-53a1-9be6-1f5be9f06a87', 3, 'CLASSIFICATION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Look at the following descriptions or deeds (Questions
1-4
) and the list of catego­ries below.
Match each description or deed with the correct category,
A-D
.
Write the correct letter,
A-D
, in boxes
1-4
on your answer sheet.
A
“maximizers”
B
“satisficers”
C
neither “maximizers” nor “satisficers”
D
both “maximizers” and “satisficers”
1
rated to the Maximization Scale of making choice
2
don’t take much time before making a decision
3
are likely to regret about the choice in the future
4
choose the highest price in the range of purchase

3 ____ are likely to regret about the choice in the future$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef785861-2d0e-5862-a488-9773e075b3dc', 'e525bf61-6491-5191-8566-5d9d50860941', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06bedd14-f4d3-54b1-9ad2-f16195d3955a', 'e525bf61-6491-5191-8566-5d9d50860941', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd6ff2dc-3b6b-5835-94ea-cbe45d19d418', 'e525bf61-6491-5191-8566-5d9d50860941', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9271c45-f8dd-50f8-b087-266d55aac8bd', 'e525bf61-6491-5191-8566-5d9d50860941', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7df6eafb-4f80-53e9-bc9c-73173f1f6043', '8c475292-0390-53a1-9be6-1f5be9f06a87', 4, 'CLASSIFICATION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Look at the following descriptions or deeds (Questions
1-4
) and the list of catego­ries below.
Match each description or deed with the correct category,
A-D
.
Write the correct letter,
A-D
, in boxes
1-4
on your answer sheet.
A
“maximizers”
B
“satisficers”
C
neither “maximizers” nor “satisficers”
D
both “maximizers” and “satisficers”
1
rated to the Maximization Scale of making choice
2
don’t take much time before making a decision
3
are likely to regret about the choice in the future
4
choose the highest price in the range of purchase

4 ____ choose the highest price in the range of purchase$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5747f183-3c5c-530c-b083-4b1fb527e509', '7df6eafb-4f80-53e9-bc9c-73173f1f6043', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2db952ac-961e-5592-a41e-638f2a896f69', '7df6eafb-4f80-53e9-bc9c-73173f1f6043', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40db92b6-1dc1-5a1f-b848-20df283e1e5d', '7df6eafb-4f80-53e9-bc9c-73173f1f6043', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('614a1463-3719-50aa-8590-d97771678740', '7df6eafb-4f80-53e9-bc9c-73173f1f6043', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('728f579a-1616-5931-8c65-0bf64b0ba9be', '8c475292-0390-53a1-9be6-1f5be9f06a87', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on you answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
In today’s world, since the society is becoming wealthier, people are happier.
6
In society, there are more maximisers than satisficers.
7
People tend to react more to loses than gains.
8
Females and males acted differently in the study of choice making.

5 ____ In today’s world, since the society is becoming wealthier, people are happier.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('527659d4-7ec2-57a1-88b1-98146d26c80e', '728f579a-1616-5931-8c65-0bf64b0ba9be', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d1eed99-21a5-5451-a496-33fd584d14af', '728f579a-1616-5931-8c65-0bf64b0ba9be', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6c9886d-2fdd-5532-b010-274973a4ddfe', '728f579a-1616-5931-8c65-0bf64b0ba9be', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('20ee35c8-9a18-5697-a23b-5a6ba8935112', '8c475292-0390-53a1-9be6-1f5be9f06a87', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on you answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
In today’s world, since the society is becoming wealthier, people are happier.
6
In society, there are more maximisers than satisficers.
7
People tend to react more to loses than gains.
8
Females and males acted differently in the study of choice making.

6 ____ In society, there are more maximisers than satisficers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0130777-585d-57c5-b7ac-0e9ca2f22bba', '20ee35c8-9a18-5697-a23b-5a6ba8935112', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8609fbb-3f5f-5da8-b177-cf157f443de5', '20ee35c8-9a18-5697-a23b-5a6ba8935112', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41b6f6c2-59f8-55f0-82da-33ab245bb6bf', '20ee35c8-9a18-5697-a23b-5a6ba8935112', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('41a8eaf3-5229-5077-bddd-2410086b8b69', '8c475292-0390-53a1-9be6-1f5be9f06a87', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on you answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
In today’s world, since the society is becoming wealthier, people are happier.
6
In society, there are more maximisers than satisficers.
7
People tend to react more to loses than gains.
8
Females and males acted differently in the study of choice making.

7 ____ People tend to react more to loses than gains.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96b1aca4-4499-55e8-8ac2-fecaea61f03e', '41a8eaf3-5229-5077-bddd-2410086b8b69', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7033cb70-d6ec-5c2d-b04b-ee4b580fd44a', '41a8eaf3-5229-5077-bddd-2410086b8b69', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c0ef5f1-0f8a-5084-91f5-c0b2c954b90b', '41a8eaf3-5229-5077-bddd-2410086b8b69', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d327c131-cec2-5aed-b7ac-2c2036be20ac', '8c475292-0390-53a1-9be6-1f5be9f06a87', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on you answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
In today’s world, since the society is becoming wealthier, people are happier.
6
In society, there are more maximisers than satisficers.
7
People tend to react more to loses than gains.
8
Females and males acted differently in the study of choice making.

8 ____ Females and males acted differently in the study of choice making.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('625ec3d8-1d4a-5138-a6f0-532c9e79a00d', 'd327c131-cec2-5aed-b7ac-2c2036be20ac', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('370a74c9-da6d-5432-b43c-ecb911c7527b', 'd327c131-cec2-5aed-b7ac-2c2036be20ac', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a5eda97-187c-5115-9aaf-cf9b7171f131', 'd327c131-cec2-5aed-b7ac-2c2036be20ac', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9ece52e7-acdc-5ad9-bcfe-4a1a9152e4e3', '8c475292-0390-53a1-9be6-1f5be9f06a87', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes
9-13
on your answer sheet.
9
The Maximization Scale is aimed to
A
know the happiness when they have more choices.
B
measure how people are likely to feel after making choices.
C
help people make better choices.
D
reduce the time of purchasing.
10
According to the text, what is the result of more choices?
A
People can make choices more easily
B
Maximizers are happier to make choices.
C
Satisficers are quicker to make wise choices.
D
People have more tendency to experience regret.
11
The example of theatre ticket is to suggest that
A
they prefer to use more money when buying tickets.
B
they don’t like to spend more money on theatre.
C
higher-priced things would induce more regret if not used properly
D
full-price payers are real theatre lovers.
12
How to increase the happiness when making a better choice?
A
use less time
B
make more comparisons
C
buy more expensive products
D
limit the number of choices in certain situations
13
What is the best title for Reading Passage 1?
A
Reasoning of Worse Choice Making
B
Making Choices in Today’s World
C
The Influence of More Choices
D
Complexity in Choice Making

Choose the correct letter A , B , C or D . Write the correct letter in boxes 9-13 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8600e530-4488-5cfe-b3b2-01a2ebc89263', '8c475292-0390-53a1-9be6-1f5be9f06a87', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes
9-13
on your answer sheet.
9
The Maximization Scale is aimed to
A
know the happiness when they have more choices.
B
measure how people are likely to feel after making choices.
C
help people make better choices.
D
reduce the time of purchasing.
10
According to the text, what is the result of more choices?
A
People can make choices more easily
B
Maximizers are happier to make choices.
C
Satisficers are quicker to make wise choices.
D
People have more tendency to experience regret.
11
The example of theatre ticket is to suggest that
A
they prefer to use more money when buying tickets.
B
they don’t like to spend more money on theatre.
C
higher-priced things would induce more regret if not used properly
D
full-price payers are real theatre lovers.
12
How to increase the happiness when making a better choice?
A
use less time
B
make more comparisons
C
buy more expensive products
D
limit the number of choices in certain situations
13
What is the best title for Reading Passage 1?
A
Reasoning of Worse Choice Making
B
Making Choices in Today’s World
C
The Influence of More Choices
D
Complexity in Choice Making

Choose the correct letter A , B , C or D . Write the correct letter in boxes 9-13 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('08d3c3f6-46b1-5289-9c30-ab40f67bdf00', '8c475292-0390-53a1-9be6-1f5be9f06a87', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes
9-13
on your answer sheet.
9
The Maximization Scale is aimed to
A
know the happiness when they have more choices.
B
measure how people are likely to feel after making choices.
C
help people make better choices.
D
reduce the time of purchasing.
10
According to the text, what is the result of more choices?
A
People can make choices more easily
B
Maximizers are happier to make choices.
C
Satisficers are quicker to make wise choices.
D
People have more tendency to experience regret.
11
The example of theatre ticket is to suggest that
A
they prefer to use more money when buying tickets.
B
they don’t like to spend more money on theatre.
C
higher-priced things would induce more regret if not used properly
D
full-price payers are real theatre lovers.
12
How to increase the happiness when making a better choice?
A
use less time
B
make more comparisons
C
buy more expensive products
D
limit the number of choices in certain situations
13
What is the best title for Reading Passage 1?
A
Reasoning of Worse Choice Making
B
Making Choices in Today’s World
C
The Influence of More Choices
D
Complexity in Choice Making

Choose the correct letter A , B , C or D . Write the correct letter in boxes 9-13 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8804d457-3df5-5a94-88fb-fb5fbc15d9e5', '8c475292-0390-53a1-9be6-1f5be9f06a87', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes
9-13
on your answer sheet.
9
The Maximization Scale is aimed to
A
know the happiness when they have more choices.
B
measure how people are likely to feel after making choices.
C
help people make better choices.
D
reduce the time of purchasing.
10
According to the text, what is the result of more choices?
A
People can make choices more easily
B
Maximizers are happier to make choices.
C
Satisficers are quicker to make wise choices.
D
People have more tendency to experience regret.
11
The example of theatre ticket is to suggest that
A
they prefer to use more money when buying tickets.
B
they don’t like to spend more money on theatre.
C
higher-priced things would induce more regret if not used properly
D
full-price payers are real theatre lovers.
12
How to increase the happiness when making a better choice?
A
use less time
B
make more comparisons
C
buy more expensive products
D
limit the number of choices in certain situations
13
What is the best title for Reading Passage 1?
A
Reasoning of Worse Choice Making
B
Making Choices in Today’s World
C
The Influence of More Choices
D
Complexity in Choice Making

Choose the correct letter A , B , C or D . Write the correct letter in boxes 9-13 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9f092f83-0686-5d76-bf6d-26828c8cbac1', '8c475292-0390-53a1-9be6-1f5be9f06a87', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes
9-13
on your answer sheet.
9
The Maximization Scale is aimed to
A
know the happiness when they have more choices.
B
measure how people are likely to feel after making choices.
C
help people make better choices.
D
reduce the time of purchasing.
10
According to the text, what is the result of more choices?
A
People can make choices more easily
B
Maximizers are happier to make choices.
C
Satisficers are quicker to make wise choices.
D
People have more tendency to experience regret.
11
The example of theatre ticket is to suggest that
A
they prefer to use more money when buying tickets.
B
they don’t like to spend more money on theatre.
C
higher-priced things would induce more regret if not used properly
D
full-price payers are real theatre lovers.
12
How to increase the happiness when making a better choice?
A
use less time
B
make more comparisons
C
buy more expensive products
D
limit the number of choices in certain situations
13
What is the best title for Reading Passage 1?
A
Reasoning of Worse Choice Making
B
Making Choices in Today’s World
C
The Influence of More Choices
D
Complexity in Choice Making

Choose the correct letter A , B , C or D . Write the correct letter in boxes 9-13 on your answer sheet.$md$, NULL);

COMMIT;
