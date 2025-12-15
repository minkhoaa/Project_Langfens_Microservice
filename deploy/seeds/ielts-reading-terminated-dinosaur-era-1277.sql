BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-terminated-dinosaur-era-1277'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-terminated-dinosaur-era-1277';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-terminated-dinosaur-era-1277';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-terminated-dinosaur-era-1277';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4250df7c-43c8-5330-927c-47534b3ea3f2', 'ielts-reading-terminated-dinosaur-era-1277', $t$Terminated Dinosaur Era$t$, $md$## Terminated Dinosaur Era

Nguồn:
- Test: https://mini-ielts.com/1277/reading/terminated-dinosaur-era
- Solution: https://mini-ielts.com/1277/view-solution/reading/terminated-dinosaur-era$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('12077980-8b1f-5a8e-add1-52cbe37af8c7', '4250df7c-43c8-5330-927c-47534b3ea3f2', 1, $t$Reading — Terminated Dinosaur Era$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Terminated Dinosaur Era

Day after day, we hear about how anthropogenic development is causing global warming. According to an increasingly vocal minority, however, we should be asking ourselves how much of this is media hype, and how much is based on real evidence. It seems – as so often is the ease – that it depends on which expert you listen to, or which statistics you study.

Yes, it is true that there is a mass of evidence to indicate that the world is getting warmer, with one of the world’s leading weather predictors stating that air temperatures have frown an increase of just under half a degree Celsius since the beginning of the twentieth century. And while this may not sound like anything worth losing sleep over, the interna­tional press would have us believe that the consequences could be devastating. Other ex­perts, however, are of the opinion that what we are seeing is just part of a natural upward and downward swing that has always been part of the cycle of global weather. An analysis of the views of major meteorologists in the United States showed that less than 20% of them believed that any change in temperature over the last hundred years was our own fault – the rest attributed it to natural cyclical changes.

There is, of course, no denying that we are still at a very early stage in understanding weather. The effects of such variables as rainfall, cloud formation, the seas and oceans, gases such as methane and ozone, or even solar energy are still not really understood, and therefore the predictions that we make using them cannot always be relied on.

Dr James Hansen, in 19BH, was predicting that the likely effects of global warming would be a raising of the world temperature which would have disastrous consequences for mankind: “a strong cause arid effect relationship between the current climate and human alteration of the at­mosphere”. He has now gone on record as stating that using artificial models of climate as a way of predicting change is all but impossible. In fact, he now believes that, rather than getting hotter, our planet is getting greener as a result of the carbon dioxide increase, with the prospect of increasing vegetation in areas which in recent history have been frozen wastelands.

In fact, there is some evidence to suggest that as our computer-based weather models have become more sophisticated, the predicted rises In temperature have been cut back. In addi­tion, if we look at the much-reported rise in global temperature over the last century, a close analysis reveals that the lion’s share of that increase, almost three quarters in total, occurred before man began to “poison” his world with industrial processes and the accom­panying greenhouse gas emissions in the second half of the twentieth century.

So should we pay any attention to those stories that scream out at us from billboards and television news headlines, claiming that man, with his inexhaustible dependence on oil-based machinery and ever more sophisticated forms of transport is creating a nightmare level of greenhouse gas emissions, poisoning his environment and ripping open the ozone layer?

Doubters point to scientific evidence, which can prove that, of all the greenhouse gases, only two per cent come from man-made sources, the rest resulting from natural emissions. Who, then, to believe: the environmentalist exhorting us to leave the car at home, to buy re-usable products packaged in recycled paper and to plant trees in our back yard? Or the sceptics, including, of course, a lot of big businesses who have most to lose, when they tell us that we are making a mountain out of a molehill? And my own opinion? The jury’s still out as for as I am concerned!$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('107c2550-632a-5594-90bb-021fc7e4474b', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the appropriate letters A-
D
Write a theme in Boxes 1-5 on your answer sheet.
1. The author …
A
believes that man is causing global warming
B
believes that global warming is a natural process
C
is sure what the causes of global warming are
D
does not say what he believes the causes of global warming are
2. As to the cause of global warming, the author believes that …
A
occasionally the fact depends on who you are talking to
B
the facts always depend on who you are talking to
C
often the fact depends on which expert you listen to
D
you should not speak to experts
3. More than 80% of the top meteorologists in the United States are of the opinion that…
A
global warming should make us lose sleep
B
global warming is not the result of oil natural cyclical changes, but man-made
C
the consequences of global warming will be deviating
D
global warming is not man-made, but the result of natural cyclical changes.
4. Our understanding of the weather…
A
leads to reliable predictions
B
is variable
C
cannot be denied
D
is not very developed yet
5. Currently, Dr. James Hansen’s beliefs include the fact that …
A
It is nearly impossible to predict weather change using artificial models
B
the consequences of global warming would be disastrous in mankind
C
there is a significant link between the climate now, mid man’s changing of the atmosphere
D
Earth is getting colder

Write a theme in Boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dc488320-e26b-568e-9c5a-9262dcc9b2d1', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the appropriate letters A-
D
Write a theme in Boxes 1-5 on your answer sheet.
1. The author …
A
believes that man is causing global warming
B
believes that global warming is a natural process
C
is sure what the causes of global warming are
D
does not say what he believes the causes of global warming are
2. As to the cause of global warming, the author believes that …
A
occasionally the fact depends on who you are talking to
B
the facts always depend on who you are talking to
C
often the fact depends on which expert you listen to
D
you should not speak to experts
3. More than 80% of the top meteorologists in the United States are of the opinion that…
A
global warming should make us lose sleep
B
global warming is not the result of oil natural cyclical changes, but man-made
C
the consequences of global warming will be deviating
D
global warming is not man-made, but the result of natural cyclical changes.
4. Our understanding of the weather…
A
leads to reliable predictions
B
is variable
C
cannot be denied
D
is not very developed yet
5. Currently, Dr. James Hansen’s beliefs include the fact that …
A
It is nearly impossible to predict weather change using artificial models
B
the consequences of global warming would be disastrous in mankind
C
there is a significant link between the climate now, mid man’s changing of the atmosphere
D
Earth is getting colder

Write a theme in Boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('616c6387-e349-5ebf-9147-3c6699f68e92', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the appropriate letters A-
D
Write a theme in Boxes 1-5 on your answer sheet.
1. The author …
A
believes that man is causing global warming
B
believes that global warming is a natural process
C
is sure what the causes of global warming are
D
does not say what he believes the causes of global warming are
2. As to the cause of global warming, the author believes that …
A
occasionally the fact depends on who you are talking to
B
the facts always depend on who you are talking to
C
often the fact depends on which expert you listen to
D
you should not speak to experts
3. More than 80% of the top meteorologists in the United States are of the opinion that…
A
global warming should make us lose sleep
B
global warming is not the result of oil natural cyclical changes, but man-made
C
the consequences of global warming will be deviating
D
global warming is not man-made, but the result of natural cyclical changes.
4. Our understanding of the weather…
A
leads to reliable predictions
B
is variable
C
cannot be denied
D
is not very developed yet
5. Currently, Dr. James Hansen’s beliefs include the fact that …
A
It is nearly impossible to predict weather change using artificial models
B
the consequences of global warming would be disastrous in mankind
C
there is a significant link between the climate now, mid man’s changing of the atmosphere
D
Earth is getting colder

Write a theme in Boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ec431ce6-5d02-5e86-9da5-911b2a51be56', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the appropriate letters A-
D
Write a theme in Boxes 1-5 on your answer sheet.
1. The author …
A
believes that man is causing global warming
B
believes that global warming is a natural process
C
is sure what the causes of global warming are
D
does not say what he believes the causes of global warming are
2. As to the cause of global warming, the author believes that …
A
occasionally the fact depends on who you are talking to
B
the facts always depend on who you are talking to
C
often the fact depends on which expert you listen to
D
you should not speak to experts
3. More than 80% of the top meteorologists in the United States are of the opinion that…
A
global warming should make us lose sleep
B
global warming is not the result of oil natural cyclical changes, but man-made
C
the consequences of global warming will be deviating
D
global warming is not man-made, but the result of natural cyclical changes.
4. Our understanding of the weather…
A
leads to reliable predictions
B
is variable
C
cannot be denied
D
is not very developed yet
5. Currently, Dr. James Hansen’s beliefs include the fact that …
A
It is nearly impossible to predict weather change using artificial models
B
the consequences of global warming would be disastrous in mankind
C
there is a significant link between the climate now, mid man’s changing of the atmosphere
D
Earth is getting colder

Write a theme in Boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('234dc046-4869-5753-9614-baef54485ef7', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the appropriate letters A-
D
Write a theme in Boxes 1-5 on your answer sheet.
1. The author …
A
believes that man is causing global warming
B
believes that global warming is a natural process
C
is sure what the causes of global warming are
D
does not say what he believes the causes of global warming are
2. As to the cause of global warming, the author believes that …
A
occasionally the fact depends on who you are talking to
B
the facts always depend on who you are talking to
C
often the fact depends on which expert you listen to
D
you should not speak to experts
3. More than 80% of the top meteorologists in the United States are of the opinion that…
A
global warming should make us lose sleep
B
global warming is not the result of oil natural cyclical changes, but man-made
C
the consequences of global warming will be deviating
D
global warming is not man-made, but the result of natural cyclical changes.
4. Our understanding of the weather…
A
leads to reliable predictions
B
is variable
C
cannot be denied
D
is not very developed yet
5. Currently, Dr. James Hansen’s beliefs include the fact that …
A
It is nearly impossible to predict weather change using artificial models
B
the consequences of global warming would be disastrous in mankind
C
there is a significant link between the climate now, mid man’s changing of the atmosphere
D
Earth is getting colder

Write a theme in Boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c661ec0e-5feb-5f26-a050-da2603bf4993', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage 1? In Boxes 6-11, write:
YES
, if the statement agrees with the information in the passage
NO
, if the statement contradicts the information in the passage
NOT GIVEN
, if there is no information about the statement in the passage
Example:
Computer-based weather models have become more sophisticated.
Answer:
Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase in global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environment-friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the sceptics as regards the cause of global warming.

6 ____ At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b849a798-9c57-5c32-84a5-bf41c22237b2', 'c661ec0e-5feb-5f26-a050-da2603bf4993', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('317ed817-391f-56a2-89e1-ab6c54cd22fc', 'c661ec0e-5feb-5f26-a050-da2603bf4993', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20b836d3-3e30-5696-856e-1780fed55e4c', 'c661ec0e-5feb-5f26-a050-da2603bf4993', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4961a0ca-0e01-592a-85fe-3766d10b4ddd', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage 1? In Boxes 6-11, write:
YES
, if the statement agrees with the information in the passage
NO
, if the statement contradicts the information in the passage
NOT GIVEN
, if there is no information about the statement in the passage
Example:
Computer-based weather models have become more sophisticated.
Answer:
Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase in global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environment-friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the sceptics as regards the cause of global warming.

7 ____ Most of the increase in global temperature happened in the second half of the twentieth century.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3eeddc8b-e422-5908-8f96-0848bf960a86', '4961a0ca-0e01-592a-85fe-3766d10b4ddd', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43a54bcf-fc3d-56fb-b96b-172334816c5f', '4961a0ca-0e01-592a-85fe-3766d10b4ddd', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99672ac7-65ec-5d6c-a15b-c02194ace5b1', '4961a0ca-0e01-592a-85fe-3766d10b4ddd', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('42440aea-f799-53e9-a05f-05a5511531be', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage 1? In Boxes 6-11, write:
YES
, if the statement agrees with the information in the passage
NO
, if the statement contradicts the information in the passage
NOT GIVEN
, if there is no information about the statement in the passage
Example:
Computer-based weather models have become more sophisticated.
Answer:
Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase in global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environment-friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the sceptics as regards the cause of global warming.

8 ____ The media wants us to blame ourselves for global warming.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e02c57cf-e2b4-560d-ad1f-bd46a72ac369', '42440aea-f799-53e9-a05f-05a5511531be', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a921f5d-ba2d-5ba3-b4bd-75190b47744a', '42440aea-f799-53e9-a05f-05a5511531be', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f24603c-0584-5c1d-90a8-109e290fbcef', '42440aea-f799-53e9-a05f-05a5511531be', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9e11935e-272d-51d7-bd76-938313963848', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage 1? In Boxes 6-11, write:
YES
, if the statement agrees with the information in the passage
NO
, if the statement contradicts the information in the passage
NOT GIVEN
, if there is no information about the statement in the passage
Example:
Computer-based weather models have become more sophisticated.
Answer:
Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase in global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environment-friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the sceptics as regards the cause of global warming.

9 ____ The media encourages the public to use environment-friendly vehicles, such as electric cars to combat global warming.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c607642-b3a9-518a-8a43-d2a062422a5c', '9e11935e-272d-51d7-bd76-938313963848', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87aadd8a-1f40-5064-be4a-da8e7e55a501', '9e11935e-272d-51d7-bd76-938313963848', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95e45f8c-8be7-547e-bfb7-1e98a5027120', '9e11935e-272d-51d7-bd76-938313963848', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6d23462f-1c2a-553e-8970-5fa63ab9a7ad', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage 1? In Boxes 6-11, write:
YES
, if the statement agrees with the information in the passage
NO
, if the statement contradicts the information in the passage
NOT GIVEN
, if there is no information about the statement in the passage
Example:
Computer-based weather models have become more sophisticated.
Answer:
Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase in global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environment-friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the sceptics as regards the cause of global warming.

10 ____ Environmentalists are very effective at persuading people to be kind to the environment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6805ae53-6c3d-50e5-95ab-67feb2b72981', '6d23462f-1c2a-553e-8970-5fa63ab9a7ad', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3b03592-13aa-5fc2-8bc1-a90b5e70ea84', '6d23462f-1c2a-553e-8970-5fa63ab9a7ad', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54405d95-c781-58e0-b2e7-4abd075172cd', '6d23462f-1c2a-553e-8970-5fa63ab9a7ad', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('01ee1dee-79de-5518-90d8-e6845239b780', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 6-11
Questions 6-11
Do the statements below agree with the information in Reading Passage 1? In Boxes 6-11, write:
YES
, if the statement agrees with the information in the passage
NO
, if the statement contradicts the information in the passage
NOT GIVEN
, if there is no information about the statement in the passage
Example:
Computer-based weather models have become more sophisticated.
Answer:
Yes.
6
At the same time that computer-based weather models have become more sophisticated, weather forecasters have become more expert.
7
Most of the increase in global temperature happened in the second half of the twentieth century.
8
The media wants us to blame ourselves for global warming.
9
The media encourages the public to use environment-friendly vehicles, such as electric cars to combat global warming.
10
Environmentalists are very effective at persuading people to be kind to the environment.
11
Many big businesses are on the side of the sceptics as regards the cause of global warming.

11 ____ Many big businesses are on the side of the sceptics as regards the cause of global warming.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57701408-7c02-5238-8419-12624cf667f6', '01ee1dee-79de-5518-90d8-e6845239b780', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edc5d1ee-2f86-558e-a280-dd739b9ef4a6', '01ee1dee-79de-5518-90d8-e6845239b780', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b416a017-bafb-5925-8bdf-91578959dfd6', '01ee1dee-79de-5518-90d8-e6845239b780', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6c6b5814-728c-57a0-bb38-b885832144d5', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 12 and 13
Questions 12 and 13
Complete the sentences below.
Use
NO MORE THAN THREE WORDS
from the passage for each blank space.
Write your answers in boxes 12 and 13 on your answer sheet.
12. As well as planting trees and not driving, the environmentalist would like us to choose products that are wrapped
12
and can be used more than once.
13. Big businesses would have us believe that we are making too much fuss about global warming, because they have
13
.

12. As well as planting trees and not driving, the environmentalist would like us to choose products that are wrapped 12 ____ and can be used more than once.$md$, NULL, ARRAY['.*in.*recycled.*paper.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6ad256a5-c89f-512d-8be5-5bf460c0ee87', '12077980-8b1f-5a8e-add1-52cbe37af8c7', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 12 and 13
Questions 12 and 13
Complete the sentences below.
Use
NO MORE THAN THREE WORDS
from the passage for each blank space.
Write your answers in boxes 12 and 13 on your answer sheet.
12. As well as planting trees and not driving, the environmentalist would like us to choose products that are wrapped
12
and can be used more than once.
13. Big businesses would have us believe that we are making too much fuss about global warming, because they have
13
.

13. Big businesses would have us believe that we are making too much fuss about global warming, because they have 13 ____ .$md$, NULL, ARRAY['.*most.*to.*lose.*']);

COMMIT;
