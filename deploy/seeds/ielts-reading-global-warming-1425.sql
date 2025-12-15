BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-global-warming-1425'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-global-warming-1425';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-global-warming-1425';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-global-warming-1425';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('bee301c9-6951-509e-9b55-8b6d73e1b422', 'ielts-reading-global-warming-1425', $t$Global Warming$t$, $md$## Global Warming

Nguồn:
- Test: https://mini-ielts.com/1425/reading/global-warming
- Solution: https://mini-ielts.com/1425/view-solution/reading/global-warming$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 'bee301c9-6951-509e-9b55-8b6d73e1b422', 1, $t$Reading — Global Warming$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Global Warming

Day after day we hear about how anthropogenic development is causing global warming. According to an increasingly vocal minority, however, we should be asking ourselves how much of this is media hype cud how much is based on real evidence. It seems, as so often is the ease, that it depends on which expert you listen to, or which statistics you study. Yes, It is true that there is a mass of evidence to indicate that the world is getting wanner, with one of the world’s leading weather predictors stating that air temperatures have frown an increase of just under half a degree Celsius since the beginning of the twentieth century. And while this may not sound like anything worth losing sleep over, the interna­tional press would have us believe that the consequences could be devastating. Other ex­perts, however, are of the opinion that what we are seeing is just part of a natural upward and downward swing flint has always been part of the cycle of global weather. An analysis of the views of major meteorologists in the United States showed that less than 20% of them believed that any change in temperature over the lust hundred years was our own fault – the rest attributed it to natural cyclical changes. There is, of course, no denying that we are still at a very early stage in understanding weather. The effects of such variables as rainfall, cloud formation, the seas and oceans, gases such as methane and ozone, or even solar energy are still not really understood, and therefore the predictions that we make using them cannot always be relied on. Dr. James Hansen, in 19BH, was predicting that the likely effects of global warming would be a raising of world temperature which would have disastrous consequences for mankind: “a strong cause arid effect relationship between the current climate and human alteration of the at­mosphere”. He has now gone on record as stating that using artificial models of climate as a way of predicting change is all but impossible. In fact, he now believes that, rather than getting hotter, our planet is getting greener as a result of the carbon dioxide increase, with the prospect of increasing vegetation In areas which in recent history have been frozen wastelands.

In fact, there is some evidence to suggest that as our computer-based weather models have become more sophisticated, the predicted rises In temperature have been cut back. In addi­tion, if we Look at the much reported rise in global temperature over the last century, a close analysis reveals that the lion’s share of that increase, almost three quarters in total, occurred before man began to “poison” his world with industrial processes anti the accom­panying greenhouse gas emissions in the second half of the twentieth century. So should we pay any attention to those stories that scream out at us from billboards and television news headlines, claiming that man, with his inexhaustible dependence on oil-based machinery and ever more sophisticated forms of transport is creating a nightmare level of greenhouse gas emissions, poisoning his environment and ripping open the ozone layer? Doubters point to scientific evidence, which can prove that, of all the greenhouse gases, only two percent come From man-made sources, the rest resulting from natural emissions. Who, then, to believe: the environmentalist exhorting us to leave the car at home, to buy re-usable products packaged in recycled paper and to plant trees in our back yard? Or the sceptics, including, of course, a lot of big businesses who have most to lose, when they tell us that we are making a mountain out of a molehill? And my own opinion? The jury’s still out as for as I am concerned!$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6b1d9aa9-3510-532a-8c95-9ad432263b1e', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
1) The author …
A
believes that man is causing global warming
B
believes that global warming is a natural process
C
is sure what the causes of global warming are
D
does not say what he believes the causes of global warming are
2) As to the cause of global warming, the author believes that …
A
occasionally the fact depend on who you are talking to
B
the facts always depend on who you are talking to
C
often the fact depend on which expert you listen to
D
you should not speak to experts
3) More than 80% of the top meteorologists in the United States are of the opinion that.. .
A
global warming should make us lose sleep
B
global warming is not the result oil natural cyclical changes, but man-made
C
the consequences of global warming will be deviating
D
global warming is not man-made, but the result of natural cyclical changes
4) Our understanding of weather…
A
leads to reliable predictions
B
Is variable
C
cannot be denied
D
is not very developed yet
5) Currently, Dr. James Hansen’s beliefs include the fact that …
A
It is nearly Impossible to predict weather change using artificial models
B
the consequences of global warming would be disastrous for in mankind
C
there Is a significant link between the climate now, mid man’s changing of the atmosphere
D
Earth is getting colder

1) The author …$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d01f3156-3fd1-51ec-88e6-bb56ea2bbf52', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
1) The author …
A
believes that man is causing global warming
B
believes that global warming is a natural process
C
is sure what the causes of global warming are
D
does not say what he believes the causes of global warming are
2) As to the cause of global warming, the author believes that …
A
occasionally the fact depend on who you are talking to
B
the facts always depend on who you are talking to
C
often the fact depend on which expert you listen to
D
you should not speak to experts
3) More than 80% of the top meteorologists in the United States are of the opinion that.. .
A
global warming should make us lose sleep
B
global warming is not the result oil natural cyclical changes, but man-made
C
the consequences of global warming will be deviating
D
global warming is not man-made, but the result of natural cyclical changes
4) Our understanding of weather…
A
leads to reliable predictions
B
Is variable
C
cannot be denied
D
is not very developed yet
5) Currently, Dr. James Hansen’s beliefs include the fact that …
A
It is nearly Impossible to predict weather change using artificial models
B
the consequences of global warming would be disastrous for in mankind
C
there Is a significant link between the climate now, mid man’s changing of the atmosphere
D
Earth is getting colder

1) The author …$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dbf3f6f1-372e-5a88-9877-126eed841301', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
1) The author …
A
believes that man is causing global warming
B
believes that global warming is a natural process
C
is sure what the causes of global warming are
D
does not say what he believes the causes of global warming are
2) As to the cause of global warming, the author believes that …
A
occasionally the fact depend on who you are talking to
B
the facts always depend on who you are talking to
C
often the fact depend on which expert you listen to
D
you should not speak to experts
3) More than 80% of the top meteorologists in the United States are of the opinion that.. .
A
global warming should make us lose sleep
B
global warming is not the result oil natural cyclical changes, but man-made
C
the consequences of global warming will be deviating
D
global warming is not man-made, but the result of natural cyclical changes
4) Our understanding of weather…
A
leads to reliable predictions
B
Is variable
C
cannot be denied
D
is not very developed yet
5) Currently, Dr. James Hansen’s beliefs include the fact that …
A
It is nearly Impossible to predict weather change using artificial models
B
the consequences of global warming would be disastrous for in mankind
C
there Is a significant link between the climate now, mid man’s changing of the atmosphere
D
Earth is getting colder

1) The author …$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('30878bbe-91e9-5883-8f8d-4473204effdc', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
1) The author …
A
believes that man is causing global warming
B
believes that global warming is a natural process
C
is sure what the causes of global warming are
D
does not say what he believes the causes of global warming are
2) As to the cause of global warming, the author believes that …
A
occasionally the fact depend on who you are talking to
B
the facts always depend on who you are talking to
C
often the fact depend on which expert you listen to
D
you should not speak to experts
3) More than 80% of the top meteorologists in the United States are of the opinion that.. .
A
global warming should make us lose sleep
B
global warming is not the result oil natural cyclical changes, but man-made
C
the consequences of global warming will be deviating
D
global warming is not man-made, but the result of natural cyclical changes
4) Our understanding of weather…
A
leads to reliable predictions
B
Is variable
C
cannot be denied
D
is not very developed yet
5) Currently, Dr. James Hansen’s beliefs include the fact that …
A
It is nearly Impossible to predict weather change using artificial models
B
the consequences of global warming would be disastrous for in mankind
C
there Is a significant link between the climate now, mid man’s changing of the atmosphere
D
Earth is getting colder

1) The author …$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7a3077ff-594d-5005-83b8-b4a997a3fc84', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
1) The author …
A
believes that man is causing global warming
B
believes that global warming is a natural process
C
is sure what the causes of global warming are
D
does not say what he believes the causes of global warming are
2) As to the cause of global warming, the author believes that …
A
occasionally the fact depend on who you are talking to
B
the facts always depend on who you are talking to
C
often the fact depend on which expert you listen to
D
you should not speak to experts
3) More than 80% of the top meteorologists in the United States are of the opinion that.. .
A
global warming should make us lose sleep
B
global warming is not the result oil natural cyclical changes, but man-made
C
the consequences of global warming will be deviating
D
global warming is not man-made, but the result of natural cyclical changes
4) Our understanding of weather…
A
leads to reliable predictions
B
Is variable
C
cannot be denied
D
is not very developed yet
5) Currently, Dr. James Hansen’s beliefs include the fact that …
A
It is nearly Impossible to predict weather change using artificial models
B
the consequences of global warming would be disastrous for in mankind
C
there Is a significant link between the climate now, mid man’s changing of the atmosphere
D
Earth is getting colder

1) The author …$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c2de31cb-365d-591d-af47-168638f93583', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage? In Boxes 6-11, write:
Yes
if the statement agrees with the information in the passage
No
if the statement contradicts the information in the passage
Not Given
if there ls no information about the statement in the passage
Example: Computer-based weather models have become more sophisticated.
Answer: Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase In global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environmentally friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the skeptics as regards the cause of global warming.

6 ____ At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e76f5720-2bf2-5bd9-95a5-a211d08f57e7', 'c2de31cb-365d-591d-af47-168638f93583', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('caeb4e7e-bbcd-5468-bf8c-9819d90e0408', 'c2de31cb-365d-591d-af47-168638f93583', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bef8b406-eef9-5dc4-b97b-56367a066fe7', 'c2de31cb-365d-591d-af47-168638f93583', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a083f264-a08e-53ea-bc51-53efbcb00f5e', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage? In Boxes 6-11, write:
Yes
if the statement agrees with the information in the passage
No
if the statement contradicts the information in the passage
Not Given
if there ls no information about the statement in the passage
Example: Computer-based weather models have become more sophisticated.
Answer: Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase In global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environmentally friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the skeptics as regards the cause of global warming.

7 ____ Most of the increase In global temperature happened in the second half of the twentieth century.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('090a2fa6-49f8-51f5-a6dc-ad5bd2eb6562', 'a083f264-a08e-53ea-bc51-53efbcb00f5e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20ac83c8-d9f1-5844-968f-763b61b39c35', 'a083f264-a08e-53ea-bc51-53efbcb00f5e', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('878192ff-439e-57d7-8de1-e17304b154a7', 'a083f264-a08e-53ea-bc51-53efbcb00f5e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0412ce5c-7281-5fb5-8267-84ac55d2acbe', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage? In Boxes 6-11, write:
Yes
if the statement agrees with the information in the passage
No
if the statement contradicts the information in the passage
Not Given
if there ls no information about the statement in the passage
Example: Computer-based weather models have become more sophisticated.
Answer: Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase In global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environmentally friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the skeptics as regards the cause of global warming.

8 ____ The media wants us to blame ourselves for global warming.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6644a17f-8933-592b-b9a8-63d1ab151760', '0412ce5c-7281-5fb5-8267-84ac55d2acbe', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a814dc7-75ee-5ba8-9824-2fb450b817e3', '0412ce5c-7281-5fb5-8267-84ac55d2acbe', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf053dc7-f012-57fe-841d-72d14887a5cd', '0412ce5c-7281-5fb5-8267-84ac55d2acbe', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d3bebf6e-2c9a-5ba6-8a91-e7888fe7a93c', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage? In Boxes 6-11, write:
Yes
if the statement agrees with the information in the passage
No
if the statement contradicts the information in the passage
Not Given
if there ls no information about the statement in the passage
Example: Computer-based weather models have become more sophisticated.
Answer: Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase In global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environmentally friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the skeptics as regards the cause of global warming.

9 ____ The media encourages the public to use environmentally friendly vehicles, such as electric cars to combat global warming.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3372bca-b496-5a75-87d6-d7c95989634c', 'd3bebf6e-2c9a-5ba6-8a91-e7888fe7a93c', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e62a928c-c535-524e-bdc5-6894da37def7', 'd3bebf6e-2c9a-5ba6-8a91-e7888fe7a93c', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8867d370-4f46-595a-a9d3-718b0e124adc', 'd3bebf6e-2c9a-5ba6-8a91-e7888fe7a93c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5ffca470-bb36-5f9b-9eaa-73462a480827', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage? In Boxes 6-11, write:
Yes
if the statement agrees with the information in the passage
No
if the statement contradicts the information in the passage
Not Given
if there ls no information about the statement in the passage
Example: Computer-based weather models have become more sophisticated.
Answer: Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase In global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environmentally friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the skeptics as regards the cause of global warming.

10 ____ Environmentalists are very effective at persuading people to be kind to the environment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2163e20-8340-5ff4-a85e-742f4c68cc97', '5ffca470-bb36-5f9b-9eaa-73462a480827', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d0f1c2a-aa8d-5f62-8300-b66a66d9f01e', '5ffca470-bb36-5f9b-9eaa-73462a480827', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d09184f-6828-54b5-9f62-e9483d43e122', '5ffca470-bb36-5f9b-9eaa-73462a480827', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5dba3f27-e7b7-5a42-951c-512807c31f62', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage? In Boxes 6-11, write:
Yes
if the statement agrees with the information in the passage
No
if the statement contradicts the information in the passage
Not Given
if there ls no information about the statement in the passage
Example: Computer-based weather models have become more sophisticated.
Answer: Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase In global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environmentally friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the skeptics as regards the cause of global warming.

11 ____ Many big businesses are on the side of the skeptics as regards the cause of global warming.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6404a2b-9ab4-5a01-a281-a9efbf60eec5', '5dba3f27-e7b7-5a42-951c-512807c31f62', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dc44433-7ee6-5132-97d6-436851a3258d', '5dba3f27-e7b7-5a42-951c-512807c31f62', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7365c16a-6ba5-5ef5-8c09-9b525ad2d98c', '5dba3f27-e7b7-5a42-951c-512807c31f62', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3d16859f-e4c4-52c0-97f2-b885313072c1', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 12 and 13
Questions 12 and 13
Complete the sentences below. Use NO MORE THAN THREE WORDS from the passage for each blank space.
Write your answers in Boxes 12 and 13 on your answer sheet.
12) As well as planting trees and not driving, the environmentalist would like us to
choose products that are wrapped
12
and can be used more than once.
13) Big businesses would have us believe that we are making too much fuss about global warming, because they have
13

choose products that are wrapped 12 ____ and can be used more than once.$md$, NULL, ARRAY['.*in.*recycled.*paper.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b6db9cf4-f96a-5707-bfe0-8fd1ab03a81a', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 12 and 13
Questions 12 and 13
Complete the sentences below. Use NO MORE THAN THREE WORDS from the passage for each blank space.
Write your answers in Boxes 12 and 13 on your answer sheet.
12) As well as planting trees and not driving, the environmentalist would like us to
choose products that are wrapped
12
and can be used more than once.
13) Big businesses would have us believe that we are making too much fuss about global warming, because they have
13

13) Big businesses would have us believe that we are making too much fuss about global warming, because they have 13 ____$md$, NULL, ARRAY['.*most.*to.*lose.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2513f27c-7013-5342-ad72-50231f9015f2', '3b8ace9f-4de9-533a-8b3a-92f95ff67e58', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Question 14
Question 14
Choose the appropriate letter A-D and write it in Box 14 on your answer sheet
14) Which of these is the best title for this text?
A
Global Warming is for real
B
Global warming – media hype or a genuine threat?
C
Weather changes over the last 100 years
D
Global Warming – the greatest threat to mankind

Choose the appropriate letter A-D and write it in Box 14 on your answer sheet$md$, NULL);

COMMIT;
