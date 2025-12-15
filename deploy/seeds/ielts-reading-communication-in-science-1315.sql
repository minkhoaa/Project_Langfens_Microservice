BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-communication-in-science-1315'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-communication-in-science-1315';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-communication-in-science-1315';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-communication-in-science-1315';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('19810bea-8f96-533c-b442-9c79c716e08a', 'ielts-reading-communication-in-science-1315', $t$Communication in Science$t$, $md$## Communication in Science

Nguồn:
- Test: https://mini-ielts.com/1315/reading/communication-in-science
- Solution: https://mini-ielts.com/1315/view-solution/reading/communication-in-science$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f95e91bb-c782-5dfe-b1de-087c2c7ee89d', '19810bea-8f96-533c-b442-9c79c716e08a', 1, $t$Reading — Communication in Science$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Communication in Science

A

Science plays an increasingly significant role in people’s lives, making the faithful communication of scientific developments more important than ever. Yet such communication is fraught with challenges that can easily distort discussions, leading to unnecessary confusion and misunderstandings.

B

Some problems stem from the esoteric nature of current research and the associated difficulty of finding sufficiently faithful terminology. Abstraction and complexity are not signs that a given scientific direction is wrong, as some commentators have suggested, but are instead a tribute to the success of human ingenuity in meeting the increasingly complex challenges that nature presents. They can, however, make communication more difficult. But many of the biggest challenges for science reporting arise because in areas of evolving research, scientists themselves often only partly understand the full implications of any particular advance or development. Since that dynamic applies to most of the scientific developments that directly affect people’s lives global warming, cancer research, diet studies – learning how to overcome it is critical to spurring a more informed scientific debate among the broader public.

C

Ambiguous word choices are the source of some misunderstandings. Scientists often employ colloquial terminology, which they then assign a specific meaning that is impossible to fathom without proper training. The term “relativity,” for example, is intrinsically misleading. Many interpret the theory to mean that everything is relative and there are no absolutes. Yet although the measurements any observer makes depend on his coordinates and reference frame, the physical phenomena he measures have an invariant description that transcends that observer’s particular coordinates. Einstein’s theory of relativity is really about finding an invariant description of physical phenomena. True, Einstein agreed with the idea that his theory would have been better named “Invarianten theorie.” But the term “relativity” was already entrenched at the time for him to change.

D

“The uncertainty principle” is another frequently abused term. It is sometimes interpreted as a limitation on observers and their ability to make measurements.

E

But it is not about intrinsic limitations on any one particular measurement; it is about the inability to precisely measure particular pairs of quantities simultaneously? The first interpretation is perhaps more engaging from a philosophical or political perspective. It’s just not what the science is about.

F

Even the word “theory” can be a problem. Unlike most people, who use the word to describe a passing conjecture that they often regard as suspect, physicists have very specific ideas in mind when they talk about theories. For physicists, theories entail a definite physical framework embodied in a set of fundamental assumptions about the world that lead to a specific set of equations and predictions – ones that are borne out by successful predictions. Theories aren’t necessarily shown to be correct or complete immediately. Even Einstein took the better part of a decade to develop the correct version of his theory of general relativity. But eventually both the ideas and the measurements settle down and theories are either proven correct, abandoned or absorbed into other, more encompassing theories.

G

“Global warming” is another example of problematic terminology. Climatologists predict more drastic fluctuations in temperature and rainfall – not necessarily that every place will be warmer. The name sometimes subverts the debate, since it lets people argue that their winter was worse, so how could there be global warming? Clearly “global climate change” would have been a better name. But not all problems stem solely from poor word choices. Some stem from the intrinsically complex nature of much of modern science. Science sometimes transcends this limitation: remarkably, chemists were able to detail the precise chemical processes involved in the destruction of the ozone layer, making the evidence that chlorofluorocarbon gases (Freon, for example) were destroying the ozone layer indisputable.

H

A better understanding of the mathematical significance of results and less insistence on a simple story would help to clarify many scientific discussions. For several months, Harvard was tortured months, Harvard was tortured by empty debates over the relative intrinsic scientific abilities of men and women. One of the more amusing aspects of the discussion was that those who believed in the differences and those who didn’t use the same evidence about gender-specific special ability? How could that be? The answer is that the data shows no substantial effects. Social factors might account for these tiny differences, which in any case have an unclear connection to scientific ability. Not much of a headline when phrased that way, is it? Each type of science has its own source of complexity and potential for miscommunication. Yet there are steps we can take to improve public understanding in all cases. The first would be to inculcate greater understanding and acceptance of indirect scientific evidence. The information from an unmanned space mission is no less legitimate than the information from one in which people are on board.

I

This doesn’t mean questioning an interpretation, but it also doesn’t mean equating indirect evidence with blind belief, as people sometimes suggest. Second, we might need different standards for evaluating science with urgent policy implications than research with the purely theoretical value. When scientists say they are not certain about their predictions, it doesn’t necessarily mean they’ve found nothing substantial. It would be better if scientists were more open about the mathematical significance of their results and if the public didn’t treat math as quite so scary; statistics and errors, which tell us the uncertainty in a measurement, give us the tools to evaluate new developments fairly.

J

But most important, people have to recognize that science can be complex. If we accept only simple stories, the description will necessarily be distorted. When advances are subtle or complicated, scientists should be willing to go the extra distance to give proper explanations and the public should be more patient about the truth. Even so, some difficulties are unavoidable. Most developments reflect work in progress, so the story is complex because no one yet knows the big picture.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b35fd092-5bda-57e6-9211-3e61ec558d8f', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the correct letter
A
,
B
,
C
or
D
.
Write your answers in boxes
1-5
on your answer sheet.
1.
Why faithful science communication important?
A
Science plays an increasingly significant role in people’s lives.
B
Science is fraught with challenges public are interested in.
C
The nature of complexity in science communication leads to confusion.
D
Scientific inventions are more important than ever before.
2.
what is the reason that the author believes for the biggest challenges for science reporting
A
phenomenon such as global warming, cancer research, diet studies is too complex.
B
Scientists themselves often only partly understand the
Theory of Evolution
C
Scientists do not totally comprehend the meaning of certain scientific evolution
D
Scientists themselves often partly understand the esoteric communication nature
3.
According to the 3rd paragraph, the reference to the term and example of “theory of relativity” is to demonstrate
A
theory of relativity is about an invariant physical phenomenon
B
common people may be misled by the inaccurate choice of scientific phrase
C
the term “relativity,” is designed to be misleading public
D
everything is relative and there is no absolutes existence
4.
Which one is a good example of appropriate word choice:
A
Scientific theory for the
uncertainty principle
B
phenomenon of
Global warming
C
the importance of
ozone layer
D
Freon
’s destructive process on environmental
5.
What is a surprising finding of the Harvard debates in the passage?
A
There are equal intrinsic scientific abilities of men and women.
B
The proof applied by both sides seemed to be of no big difference.
C
The scientific data usually shows no substantial figures to support a debated idea.
D
Social factors might have a clear connection to scientific ability.

Choose the correct letter A , B , C or D . Write your answers in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d79108a3-54b0-56b8-aef5-0e09847d7fe5', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the correct letter
A
,
B
,
C
or
D
.
Write your answers in boxes
1-5
on your answer sheet.
1.
Why faithful science communication important?
A
Science plays an increasingly significant role in people’s lives.
B
Science is fraught with challenges public are interested in.
C
The nature of complexity in science communication leads to confusion.
D
Scientific inventions are more important than ever before.
2.
what is the reason that the author believes for the biggest challenges for science reporting
A
phenomenon such as global warming, cancer research, diet studies is too complex.
B
Scientists themselves often only partly understand the
Theory of Evolution
C
Scientists do not totally comprehend the meaning of certain scientific evolution
D
Scientists themselves often partly understand the esoteric communication nature
3.
According to the 3rd paragraph, the reference to the term and example of “theory of relativity” is to demonstrate
A
theory of relativity is about an invariant physical phenomenon
B
common people may be misled by the inaccurate choice of scientific phrase
C
the term “relativity,” is designed to be misleading public
D
everything is relative and there is no absolutes existence
4.
Which one is a good example of appropriate word choice:
A
Scientific theory for the
uncertainty principle
B
phenomenon of
Global warming
C
the importance of
ozone layer
D
Freon
’s destructive process on environmental
5.
What is a surprising finding of the Harvard debates in the passage?
A
There are equal intrinsic scientific abilities of men and women.
B
The proof applied by both sides seemed to be of no big difference.
C
The scientific data usually shows no substantial figures to support a debated idea.
D
Social factors might have a clear connection to scientific ability.

Choose the correct letter A , B , C or D . Write your answers in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('55db29e0-8f89-5e0d-a78f-5117193b76e3', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the correct letter
A
,
B
,
C
or
D
.
Write your answers in boxes
1-5
on your answer sheet.
1.
Why faithful science communication important?
A
Science plays an increasingly significant role in people’s lives.
B
Science is fraught with challenges public are interested in.
C
The nature of complexity in science communication leads to confusion.
D
Scientific inventions are more important than ever before.
2.
what is the reason that the author believes for the biggest challenges for science reporting
A
phenomenon such as global warming, cancer research, diet studies is too complex.
B
Scientists themselves often only partly understand the
Theory of Evolution
C
Scientists do not totally comprehend the meaning of certain scientific evolution
D
Scientists themselves often partly understand the esoteric communication nature
3.
According to the 3rd paragraph, the reference to the term and example of “theory of relativity” is to demonstrate
A
theory of relativity is about an invariant physical phenomenon
B
common people may be misled by the inaccurate choice of scientific phrase
C
the term “relativity,” is designed to be misleading public
D
everything is relative and there is no absolutes existence
4.
Which one is a good example of appropriate word choice:
A
Scientific theory for the
uncertainty principle
B
phenomenon of
Global warming
C
the importance of
ozone layer
D
Freon
’s destructive process on environmental
5.
What is a surprising finding of the Harvard debates in the passage?
A
There are equal intrinsic scientific abilities of men and women.
B
The proof applied by both sides seemed to be of no big difference.
C
The scientific data usually shows no substantial figures to support a debated idea.
D
Social factors might have a clear connection to scientific ability.

Choose the correct letter A , B , C or D . Write your answers in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d746e7f3-fc56-5a8a-a003-7fbd5d7b45eb', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the correct letter
A
,
B
,
C
or
D
.
Write your answers in boxes
1-5
on your answer sheet.
1.
Why faithful science communication important?
A
Science plays an increasingly significant role in people’s lives.
B
Science is fraught with challenges public are interested in.
C
The nature of complexity in science communication leads to confusion.
D
Scientific inventions are more important than ever before.
2.
what is the reason that the author believes for the biggest challenges for science reporting
A
phenomenon such as global warming, cancer research, diet studies is too complex.
B
Scientists themselves often only partly understand the
Theory of Evolution
C
Scientists do not totally comprehend the meaning of certain scientific evolution
D
Scientists themselves often partly understand the esoteric communication nature
3.
According to the 3rd paragraph, the reference to the term and example of “theory of relativity” is to demonstrate
A
theory of relativity is about an invariant physical phenomenon
B
common people may be misled by the inaccurate choice of scientific phrase
C
the term “relativity,” is designed to be misleading public
D
everything is relative and there is no absolutes existence
4.
Which one is a good example of appropriate word choice:
A
Scientific theory for the
uncertainty principle
B
phenomenon of
Global warming
C
the importance of
ozone layer
D
Freon
’s destructive process on environmental
5.
What is a surprising finding of the Harvard debates in the passage?
A
There are equal intrinsic scientific abilities of men and women.
B
The proof applied by both sides seemed to be of no big difference.
C
The scientific data usually shows no substantial figures to support a debated idea.
D
Social factors might have a clear connection to scientific ability.

Choose the correct letter A , B , C or D . Write your answers in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f8464b03-f55d-5a78-9d5f-c1b064a27bfe', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the correct letter
A
,
B
,
C
or
D
.
Write your answers in boxes
1-5
on your answer sheet.
1.
Why faithful science communication important?
A
Science plays an increasingly significant role in people’s lives.
B
Science is fraught with challenges public are interested in.
C
The nature of complexity in science communication leads to confusion.
D
Scientific inventions are more important than ever before.
2.
what is the reason that the author believes for the biggest challenges for science reporting
A
phenomenon such as global warming, cancer research, diet studies is too complex.
B
Scientists themselves often only partly understand the
Theory of Evolution
C
Scientists do not totally comprehend the meaning of certain scientific evolution
D
Scientists themselves often partly understand the esoteric communication nature
3.
According to the 3rd paragraph, the reference to the term and example of “theory of relativity” is to demonstrate
A
theory of relativity is about an invariant physical phenomenon
B
common people may be misled by the inaccurate choice of scientific phrase
C
the term “relativity,” is designed to be misleading public
D
everything is relative and there is no absolutes existence
4.
Which one is a good example of appropriate word choice:
A
Scientific theory for the
uncertainty principle
B
phenomenon of
Global warming
C
the importance of
ozone layer
D
Freon
’s destructive process on environmental
5.
What is a surprising finding of the Harvard debates in the passage?
A
There are equal intrinsic scientific abilities of men and women.
B
The proof applied by both sides seemed to be of no big difference.
C
The scientific data usually shows no substantial figures to support a debated idea.
D
Social factors might have a clear connection to scientific ability.

Choose the correct letter A , B , C or D . Write your answers in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('32c944a4-8bf1-5d78-962d-56c21ae2ce98', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes
6-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
“Global warming” scientifically refers to greater fluctuations in temperature and rainfall rather than a universal temperature rise.
7
More media coverage of “global warming” would help the public to recognize the phenomenon.
8
Harvard debates should focus more on female scientist and male scientists
9
Public understanding and acceptance of indirect scientific evidence in all cases would lead to confusion

6 ____ “Global warming” scientifically refers to greater fluctuations in temperature and rainfall rather than a universal temperature rise.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7efc4e9-b821-5af6-bc68-1b2576f1f931', '32c944a4-8bf1-5d78-962d-56c21ae2ce98', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2e11bb2-9b7c-524a-8706-07dcbd27f6c7', '32c944a4-8bf1-5d78-962d-56c21ae2ce98', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3797f97b-325b-5a2b-add2-215a1dc40d37', '32c944a4-8bf1-5d78-962d-56c21ae2ce98', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dd02d7d3-b306-58fc-a60c-480f9802477c', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes
6-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
“Global warming” scientifically refers to greater fluctuations in temperature and rainfall rather than a universal temperature rise.
7
More media coverage of “global warming” would help the public to recognize the phenomenon.
8
Harvard debates should focus more on female scientist and male scientists
9
Public understanding and acceptance of indirect scientific evidence in all cases would lead to confusion

7 ____ More media coverage of “global warming” would help the public to recognize the phenomenon.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('319db968-6b77-5106-a49d-d26281085036', 'dd02d7d3-b306-58fc-a60c-480f9802477c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2b58348-13e4-5dd3-827d-81cca74f9805', 'dd02d7d3-b306-58fc-a60c-480f9802477c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('857c67fe-0b88-54d8-8219-d9e1249d0411', 'dd02d7d3-b306-58fc-a60c-480f9802477c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cde6ae33-89d2-5551-b390-4ba87535d235', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes
6-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
“Global warming” scientifically refers to greater fluctuations in temperature and rainfall rather than a universal temperature rise.
7
More media coverage of “global warming” would help the public to recognize the phenomenon.
8
Harvard debates should focus more on female scientist and male scientists
9
Public understanding and acceptance of indirect scientific evidence in all cases would lead to confusion

8 ____ Harvard debates should focus more on female scientist and male scientists$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db8ee94d-5ff4-501a-96bb-1e5424328fad', 'cde6ae33-89d2-5551-b390-4ba87535d235', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ccb7db2-f1ca-5399-9838-31e9aec80ab5', 'cde6ae33-89d2-5551-b390-4ba87535d235', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0a976af-da9f-52a5-9146-53a99cfa2ba0', 'cde6ae33-89d2-5551-b390-4ba87535d235', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('19a61381-ce73-5cf9-866d-d41f18a39b38', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes
6-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
“Global warming” scientifically refers to greater fluctuations in temperature and rainfall rather than a universal temperature rise.
7
More media coverage of “global warming” would help the public to recognize the phenomenon.
8
Harvard debates should focus more on female scientist and male scientists
9
Public understanding and acceptance of indirect scientific evidence in all cases would lead to confusion

9 ____ Public understanding and acceptance of indirect scientific evidence in all cases would lead to confusion$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4d15b1f-7558-5bd0-a11f-0e6d58e39762', '19a61381-ce73-5cf9-866d-d41f18a39b38', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbad8325-7257-5bed-b722-3ee596e25b76', '19a61381-ce73-5cf9-866d-d41f18a39b38', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36986429-c62a-5ed7-8779-f845be1d7da4', '19a61381-ce73-5cf9-866d-d41f18a39b38', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1fe5a4bc-aa39-50ed-9981-34f8a81922e0', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-14
on your answer sheet.
Science Communication is fraught with challenges that can easily distort discussions, leading to unnecessary confusion and misunderstandings. Firstly, Ambiguous
10
are the source of some misunderstandings. Common people without proper training do not understand clearly or deeply a specific scientific meaning via the
11
scientists often employed. Besides, the measurements any
12
makes can not be confined to describe in a(n) constant
13
yet the phenomenon can be. What’s more, even the word “theory” can be a problem. Theories aren’t necessarily shown to be correct or complete immediately since scientists often evolved better versions of specific theories, a good example can be the theory of
14
. Thus, most importantly people have to recognize that science can be complex.

Science Communication is fraught with challenges that can easily distort discussions, leading to unnecessary confusion and misunderstandings. Firstly, Ambiguous 10 ____ are the source of some misunderstandings. Common people without proper training do not understand clearly or deeply a specific scientific meaning via the 11 ____ scientists often employed. Besides, the measurements any 12 ____ makes can not be confined to describe in a(n) constant 13 ____ yet the phenomenon can be. What’s more, even the word “theory” can be a problem. Theories aren’t necessarily shown to be correct or complete immediately since scientists often evolved better versions of specific theories, a good example can be the theory of 14 ____ . Thus, most importantly people have to recognize that science can be complex.$md$, NULL, ARRAY['.*word.*choices.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('78c2f76e-c8f5-5708-aa02-57de0bf6c518', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-14
on your answer sheet.
Science Communication is fraught with challenges that can easily distort discussions, leading to unnecessary confusion and misunderstandings. Firstly, Ambiguous
10
are the source of some misunderstandings. Common people without proper training do not understand clearly or deeply a specific scientific meaning via the
11
scientists often employed. Besides, the measurements any
12
makes can not be confined to describe in a(n) constant
13
yet the phenomenon can be. What’s more, even the word “theory” can be a problem. Theories aren’t necessarily shown to be correct or complete immediately since scientists often evolved better versions of specific theories, a good example can be the theory of
14
. Thus, most importantly people have to recognize that science can be complex.

Science Communication is fraught with challenges that can easily distort discussions, leading to unnecessary confusion and misunderstandings. Firstly, Ambiguous 10 ____ are the source of some misunderstandings. Common people without proper training do not understand clearly or deeply a specific scientific meaning via the 11 ____ scientists often employed. Besides, the measurements any 12 ____ makes can not be confined to describe in a(n) constant 13 ____ yet the phenomenon can be. What’s more, even the word “theory” can be a problem. Theories aren’t necessarily shown to be correct or complete immediately since scientists often evolved better versions of specific theories, a good example can be the theory of 14 ____ . Thus, most importantly people have to recognize that science can be complex.$md$, NULL, ARRAY['.*word.*choices.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7b731df3-3664-5d2b-bd67-0bd4bfb761f5', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-14
on your answer sheet.
Science Communication is fraught with challenges that can easily distort discussions, leading to unnecessary confusion and misunderstandings. Firstly, Ambiguous
10
are the source of some misunderstandings. Common people without proper training do not understand clearly or deeply a specific scientific meaning via the
11
scientists often employed. Besides, the measurements any
12
makes can not be confined to describe in a(n) constant
13
yet the phenomenon can be. What’s more, even the word “theory” can be a problem. Theories aren’t necessarily shown to be correct or complete immediately since scientists often evolved better versions of specific theories, a good example can be the theory of
14
. Thus, most importantly people have to recognize that science can be complex.

Science Communication is fraught with challenges that can easily distort discussions, leading to unnecessary confusion and misunderstandings. Firstly, Ambiguous 10 ____ are the source of some misunderstandings. Common people without proper training do not understand clearly or deeply a specific scientific meaning via the 11 ____ scientists often employed. Besides, the measurements any 12 ____ makes can not be confined to describe in a(n) constant 13 ____ yet the phenomenon can be. What’s more, even the word “theory” can be a problem. Theories aren’t necessarily shown to be correct or complete immediately since scientists often evolved better versions of specific theories, a good example can be the theory of 14 ____ . Thus, most importantly people have to recognize that science can be complex.$md$, NULL, ARRAY['.*word.*choices.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('668d2ddf-0a21-549a-b9a2-723e120cd1be', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-14
on your answer sheet.
Science Communication is fraught with challenges that can easily distort discussions, leading to unnecessary confusion and misunderstandings. Firstly, Ambiguous
10
are the source of some misunderstandings. Common people without proper training do not understand clearly or deeply a specific scientific meaning via the
11
scientists often employed. Besides, the measurements any
12
makes can not be confined to describe in a(n) constant
13
yet the phenomenon can be. What’s more, even the word “theory” can be a problem. Theories aren’t necessarily shown to be correct or complete immediately since scientists often evolved better versions of specific theories, a good example can be the theory of
14
. Thus, most importantly people have to recognize that science can be complex.

Science Communication is fraught with challenges that can easily distort discussions, leading to unnecessary confusion and misunderstandings. Firstly, Ambiguous 10 ____ are the source of some misunderstandings. Common people without proper training do not understand clearly or deeply a specific scientific meaning via the 11 ____ scientists often employed. Besides, the measurements any 12 ____ makes can not be confined to describe in a(n) constant 13 ____ yet the phenomenon can be. What’s more, even the word “theory” can be a problem. Theories aren’t necessarily shown to be correct or complete immediately since scientists often evolved better versions of specific theories, a good example can be the theory of 14 ____ . Thus, most importantly people have to recognize that science can be complex.$md$, NULL, ARRAY['.*word.*choices.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('29bf1484-a76d-5167-a116-34477dee4963', 'f95e91bb-c782-5dfe-b1de-087c2c7ee89d', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-14
on your answer sheet.
Science Communication is fraught with challenges that can easily distort discussions, leading to unnecessary confusion and misunderstandings. Firstly, Ambiguous
10
are the source of some misunderstandings. Common people without proper training do not understand clearly or deeply a specific scientific meaning via the
11
scientists often employed. Besides, the measurements any
12
makes can not be confined to describe in a(n) constant
13
yet the phenomenon can be. What’s more, even the word “theory” can be a problem. Theories aren’t necessarily shown to be correct or complete immediately since scientists often evolved better versions of specific theories, a good example can be the theory of
14
. Thus, most importantly people have to recognize that science can be complex.

Science Communication is fraught with challenges that can easily distort discussions, leading to unnecessary confusion and misunderstandings. Firstly, Ambiguous 10 ____ are the source of some misunderstandings. Common people without proper training do not understand clearly or deeply a specific scientific meaning via the 11 ____ scientists often employed. Besides, the measurements any 12 ____ makes can not be confined to describe in a(n) constant 13 ____ yet the phenomenon can be. What’s more, even the word “theory” can be a problem. Theories aren’t necessarily shown to be correct or complete immediately since scientists often evolved better versions of specific theories, a good example can be the theory of 14 ____ . Thus, most importantly people have to recognize that science can be complex.$md$, NULL, ARRAY['.*word.*choices.*']);

COMMIT;
