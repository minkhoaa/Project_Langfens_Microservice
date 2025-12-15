BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-economic-evolution-1483'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-economic-evolution-1483';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-economic-evolution-1483';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-economic-evolution-1483';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('247acc0f-a9b3-5440-99e0-8d92e64ad7c8', 'ielts-reading-economic-evolution-1483', $t$Economic Evolution$t$, $md$## Economic Evolution

Nguồn:
- Test: https://mini-ielts.com/1483/reading/economic-evolution
- Solution: https://mini-ielts.com/1483/view-solution/reading/economic-evolution$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('46a2debc-6e3c-5597-8ad6-85465eddd18a', '247acc0f-a9b3-5440-99e0-8d92e64ad7c8', 1, $t$Reading — Economic Evolution$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Economic Evolution

{A} Living along the Orinoco River that borders Brazil and Venezuela are the Yanomami people, hunter-gatherers whose average annual income has been estimated at the equivalent of $90 per person per year. Living along the Hudson River that borders New York State and New Jersey are the Manhattan people, consumer traders whose average annual income has been estimated at $36,000 per person per year. That dramatic difference of 400 times, however, pales in comparison to the differences in Stock Keeping Units (SKUs, a measure of the number of types of retail products available), which has been estimated at 300 for the Yanomami and 10 billion for the Manhattans, a difference of 33 million times.

{B} How did this happen? According to economist Eric D. Beinhocker, who published these calculations in his revelatory work The Origin of Wealth (Harvard Business School Press, 2006), the explanation is to be found in complexity theory. Evolution and economics are not just analogous to each other, but they are actually two forms of a larger phenomenon called complex adaptive systems, in which individual elements, parts or agents interact, then process information and adapt their behaviour to changing conditions. Immune systems, ecosystems, language, the law and the Internet are all examples of complex adaptive systems.

{C} In biological evolution, nature selects from the variation produced by random genetic mutations and the mixing of parental genes. Out of that process of cumulative selection emerges complexity and diversity. In economic evolution, our material economy proceeds through the production and selection of numerous permutations of countless products. Those 10 billion products in the Manhattan village represent only those variations that made it to market, after which there is a cumulative selection by consumers in the marketplace for those deemed most useful: VHS over Betamax, DVDs over VHS, CDs over vinyl records, flip phones over brick phones, computers over typewriters, Google over Altavista, SUVs over station wagons, paper books over e-books (still), and Internet news over network news (soon). Those that are purchased “survive” and “reproduce” into the future through repetitive use and remanufacturing.

{D} As with living organisms and ecosystems, the economy looks designed—so just as Humans naturally deduce the existence of a top-down intelligent designer, humans also (understandably) infer that a top-down government designer is needed in nearly every aspect of the economy. But just as living organisms are shaped from the bottom up by natural selection, the economy is moulded from the bottom up by the invisible hand. The correspondence between evolution and economics is not perfect, because some top-down institutional rules and laws are needed to provide a structure within which free and fair trade can occur. But too much top-down interference into the marketplace makes trade neither free nor fair. When such attempts have been made in the past, they have failed—because markets are far too complex, interactive and autocatalytic to be designed from the top down. In his 1922 book, Socialism, Ludwig Von Mises spelt out the reasons why most notably the problem of “economic calculation” in a planned socialist economy. In capitalism, prices are in constant and rapid flux and are determined from below by individuals freely exchanging in the marketplace. Money is a means of exchange, and prices are the information people use to guide their choices. Von Mises demonstrated that socialist economies depend on capitalist economies to determine what prices should be assigned to goods and services. And they do so cumbersomely and inefficiently. Relatively free markets are, ultimately, the only way to find out what buyers are willing to pay and what sellers are willing to accept.

{E} Economics helps to explain how Yanomami-like hunter-gatherers evolved into Manhattan-like consumer traders. In the Nineteenth century French economist Frédéric Bastiat well captured the principle: “Where goods do not cross frontiers, armies will.” In addition to being fierce warriors, the Yanomami are also sophisticated traders, and the more they trade the less they fight. The reason is that trade is a powerful social adhesive that creates political alliances. One village cannot go to another village and announce that they are worried about being conquered by a third, more powerful village—that would reveal weakness. Instead, they mask the real motives for alliance through trade and reciprocal feasting. And, as a result, not only gain military protection but also initiate a system of trade that—in the long run—leads to an increase in both wealth and SKUs.

{F} Free and fair trade occurs in societies where most individuals interact in ways that provide mutual benefit. The necessary rules weren’t generated by wise men in a sacred temple or lawmakers in congress, but rather evolved over generations and were widely accepted and practised before the law was ever written. Laws that fail this test are ignored. If enforcement becomes too onerous, there is rebellion. Yet the concept that human interaction must, and can be controlled by a higher force is universal. Interestingly, there is no widespread agreement on who the “higher force” is. Religious people ascribe good behaviour to God’s law. They cannot conceive of an orderly society of atheists. Secular people credit the government. They consider anarchy to be synonymous with barbarity. Everyone seems to agree on the concept that an orderly society requires an omnipotent force. Yet, everywhere there is evidence that this is not so. An important distinction between spontaneous social order and social anarchy is that the former is developed by work and investment, under the rule of law and with a set of evolved morals while the latter is chaos. The classical liberal tradition of von Mises and Hayek never makes the claim that the complete absence of top-down rules leads to the optimal social order. It simply says we should be sceptical about our ability to manage them in the name of social justice, equality, or progress.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('06b4bf44-63c4-5bb7-b001-c161554593de', '46a2debc-6e3c-5597-8ad6-85465eddd18a', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in the Reading Passage? In boxes 1-5 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if there is no information about this in the passage
1
SKUs is a more precise measurement to demonstrate the economic level of a community.
2
No concrete examples are presented when the author makes the statement concerning economic evolution.
3
Evolution and economics show a defective homolog.
4
Martial actions might be taken to cross the borders if trades do not work.
5
Profit is the invisible hand to guide the market.

1 ____ SKUs is a more precise measurement to demonstrate the economic level of a community.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a332c6d-2e69-5584-b2e7-e7b8e0af12ed', '06b4bf44-63c4-5bb7-b001-c161554593de', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d196f68-0d40-5ef5-a621-dcfe0ba935a0', '06b4bf44-63c4-5bb7-b001-c161554593de', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e50e31f-9d01-5237-9d6e-1cbadcf259c1', '06b4bf44-63c4-5bb7-b001-c161554593de', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9764c4f3-3285-537d-a77b-81149dbd33fa', '46a2debc-6e3c-5597-8ad6-85465eddd18a', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in the Reading Passage? In boxes 1-5 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if there is no information about this in the passage
1
SKUs is a more precise measurement to demonstrate the economic level of a community.
2
No concrete examples are presented when the author makes the statement concerning economic evolution.
3
Evolution and economics show a defective homolog.
4
Martial actions might be taken to cross the borders if trades do not work.
5
Profit is the invisible hand to guide the market.

2 ____ No concrete examples are presented when the author makes the statement concerning economic evolution.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b70b5a26-d5b1-506d-b203-bd640921e3f5', '9764c4f3-3285-537d-a77b-81149dbd33fa', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ec5bfe9-8412-5de5-8622-42b1b1405b2a', '9764c4f3-3285-537d-a77b-81149dbd33fa', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3702f171-d904-597c-9e78-bd4301e6e013', '9764c4f3-3285-537d-a77b-81149dbd33fa', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9aad6c87-8852-55ca-8a82-38da9e794003', '46a2debc-6e3c-5597-8ad6-85465eddd18a', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in the Reading Passage? In boxes 1-5 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if there is no information about this in the passage
1
SKUs is a more precise measurement to demonstrate the economic level of a community.
2
No concrete examples are presented when the author makes the statement concerning economic evolution.
3
Evolution and economics show a defective homolog.
4
Martial actions might be taken to cross the borders if trades do not work.
5
Profit is the invisible hand to guide the market.

3 ____ Evolution and economics show a defective homolog.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cb0eca6-6420-5d5a-a4df-222752f6b912', '9aad6c87-8852-55ca-8a82-38da9e794003', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d2c7966-fb39-5f8a-83a1-81ec00778603', '9aad6c87-8852-55ca-8a82-38da9e794003', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e24a6c5b-c7a3-5c0e-97e2-2aaddb8fe798', '9aad6c87-8852-55ca-8a82-38da9e794003', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4029b701-1261-5c35-a1a2-3c9e0ebbd94c', '46a2debc-6e3c-5597-8ad6-85465eddd18a', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in the Reading Passage? In boxes 1-5 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if there is no information about this in the passage
1
SKUs is a more precise measurement to demonstrate the economic level of a community.
2
No concrete examples are presented when the author makes the statement concerning economic evolution.
3
Evolution and economics show a defective homolog.
4
Martial actions might be taken to cross the borders if trades do not work.
5
Profit is the invisible hand to guide the market.

4 ____ Martial actions might be taken to cross the borders if trades do not work.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f383ea2-8e2b-5bd2-856c-99350b831854', '4029b701-1261-5c35-a1a2-3c9e0ebbd94c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07583e10-f831-58f1-bfba-a1eafed06521', '4029b701-1261-5c35-a1a2-3c9e0ebbd94c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65f11ec1-c657-546d-bb46-83269cf0d2fb', '4029b701-1261-5c35-a1a2-3c9e0ebbd94c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b51057c4-8cef-53fc-a0cd-4bcd8806086e', '46a2debc-6e3c-5597-8ad6-85465eddd18a', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in the Reading Passage? In boxes 1-5 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if there is no information about this in the passage
1
SKUs is a more precise measurement to demonstrate the economic level of a community.
2
No concrete examples are presented when the author makes the statement concerning economic evolution.
3
Evolution and economics show a defective homolog.
4
Martial actions might be taken to cross the borders if trades do not work.
5
Profit is the invisible hand to guide the market.

5 ____ Profit is the invisible hand to guide the market.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ed15043-e406-545a-829d-d418172db4a9', 'b51057c4-8cef-53fc-a0cd-4bcd8806086e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73809ba0-01d0-5142-99ce-eed9f16e1a2f', 'b51057c4-8cef-53fc-a0cd-4bcd8806086e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e88110b1-1e63-54af-b26e-17144cff2632', 'b51057c4-8cef-53fc-a0cd-4bcd8806086e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('26958b34-b998-51d9-83e0-d5a272c69811', '46a2debc-6e3c-5597-8ad6-85465eddd18a', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6
Questions 6
Choose the correct letter, A, B, C or D.
Question 6:
What ought to play a vital role in each field of the economy?
A
a strict rule
B
a smart strategy
C
a tightly managed authority
D
a powerful legislation

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d9748740-f6ce-53df-8040-1199d997a8eb', '46a2debc-6e3c-5597-8ad6-85465eddd18a', 9, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage, using no more than three words from the Reading Passage for each answer. Write your answers in boxes 36-40 on your answer sheet.
In response to the search for reasons for the phenomenon shown by the huge difference in the income between two groups of people both dwelling near the rivers, several researchers made their effort and gave certain explanations. One attributes
9
to the interesting change claiming that it is not as simple as it seems to be in appearance that the relationship between
10
which is a good example of
11
, which involved in the interaction of separate factors for the processing of information as well as the behavioural adaptation to unstable conditions. As far as the biological transformation is concerned, both
12
and the blend of genres from the last generation brings about the difference. The economic counterpart shows how generating and choosing the
13
of innumerable goods moves forward the material-oriented economy.

In response to the search for reasons for the phenomenon shown by the huge difference in the income between two groups of people both dwelling near the rivers, several researchers made their effort and gave certain explanations. One attributes 9 ____ to the interesting change claiming that it is not as simple as it seems to be in appearance that the relationship between 10 ____ which is a good example of 11 ____ , which involved in the interaction of separate factors for the processing of information as well as the behavioural adaptation to unstable conditions. As far as the biological transformation is concerned, both 12 ____ and the blend of genres from the last generation brings about the difference. The economic counterpart shows how generating and choosing the 13 ____ of innumerable goods moves forward the material-oriented economy.$md$, NULL, ARRAY['.*complexity.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e09f3575-4547-52b1-b9f6-018abaef9266', '46a2debc-6e3c-5597-8ad6-85465eddd18a', 10, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage, using no more than three words from the Reading Passage for each answer. Write your answers in boxes 36-40 on your answer sheet.
In response to the search for reasons for the phenomenon shown by the huge difference in the income between two groups of people both dwelling near the rivers, several researchers made their effort and gave certain explanations. One attributes
9
to the interesting change claiming that it is not as simple as it seems to be in appearance that the relationship between
10
which is a good example of
11
, which involved in the interaction of separate factors for the processing of information as well as the behavioural adaptation to unstable conditions. As far as the biological transformation is concerned, both
12
and the blend of genres from the last generation brings about the difference. The economic counterpart shows how generating and choosing the
13
of innumerable goods moves forward the material-oriented economy.

In response to the search for reasons for the phenomenon shown by the huge difference in the income between two groups of people both dwelling near the rivers, several researchers made their effort and gave certain explanations. One attributes 9 ____ to the interesting change claiming that it is not as simple as it seems to be in appearance that the relationship between 10 ____ which is a good example of 11 ____ , which involved in the interaction of separate factors for the processing of information as well as the behavioural adaptation to unstable conditions. As far as the biological transformation is concerned, both 12 ____ and the blend of genres from the last generation brings about the difference. The economic counterpart shows how generating and choosing the 13 ____ of innumerable goods moves forward the material-oriented economy.$md$, NULL, ARRAY['.*complexity.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2b42e3b3-7832-54f7-be09-1b09e3575aa8', '46a2debc-6e3c-5597-8ad6-85465eddd18a', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage, using no more than three words from the Reading Passage for each answer. Write your answers in boxes 36-40 on your answer sheet.
In response to the search for reasons for the phenomenon shown by the huge difference in the income between two groups of people both dwelling near the rivers, several researchers made their effort and gave certain explanations. One attributes
9
to the interesting change claiming that it is not as simple as it seems to be in appearance that the relationship between
10
which is a good example of
11
, which involved in the interaction of separate factors for the processing of information as well as the behavioural adaptation to unstable conditions. As far as the biological transformation is concerned, both
12
and the blend of genres from the last generation brings about the difference. The economic counterpart shows how generating and choosing the
13
of innumerable goods moves forward the material-oriented economy.

In response to the search for reasons for the phenomenon shown by the huge difference in the income between two groups of people both dwelling near the rivers, several researchers made their effort and gave certain explanations. One attributes 9 ____ to the interesting change claiming that it is not as simple as it seems to be in appearance that the relationship between 10 ____ which is a good example of 11 ____ , which involved in the interaction of separate factors for the processing of information as well as the behavioural adaptation to unstable conditions. As far as the biological transformation is concerned, both 12 ____ and the blend of genres from the last generation brings about the difference. The economic counterpart shows how generating and choosing the 13 ____ of innumerable goods moves forward the material-oriented economy.$md$, NULL, ARRAY['.*complexity.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('43e8e03b-5cb3-55bd-9a36-f1ac0b698292', '46a2debc-6e3c-5597-8ad6-85465eddd18a', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage, using no more than three words from the Reading Passage for each answer. Write your answers in boxes 36-40 on your answer sheet.
In response to the search for reasons for the phenomenon shown by the huge difference in the income between two groups of people both dwelling near the rivers, several researchers made their effort and gave certain explanations. One attributes
9
to the interesting change claiming that it is not as simple as it seems to be in appearance that the relationship between
10
which is a good example of
11
, which involved in the interaction of separate factors for the processing of information as well as the behavioural adaptation to unstable conditions. As far as the biological transformation is concerned, both
12
and the blend of genres from the last generation brings about the difference. The economic counterpart shows how generating and choosing the
13
of innumerable goods moves forward the material-oriented economy.

In response to the search for reasons for the phenomenon shown by the huge difference in the income between two groups of people both dwelling near the rivers, several researchers made their effort and gave certain explanations. One attributes 9 ____ to the interesting change claiming that it is not as simple as it seems to be in appearance that the relationship between 10 ____ which is a good example of 11 ____ , which involved in the interaction of separate factors for the processing of information as well as the behavioural adaptation to unstable conditions. As far as the biological transformation is concerned, both 12 ____ and the blend of genres from the last generation brings about the difference. The economic counterpart shows how generating and choosing the 13 ____ of innumerable goods moves forward the material-oriented economy.$md$, NULL, ARRAY['.*complexity.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('207f8cbc-e5f1-5939-821f-1f4cef274847', '46a2debc-6e3c-5597-8ad6-85465eddd18a', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage, using no more than three words from the Reading Passage for each answer. Write your answers in boxes 36-40 on your answer sheet.
In response to the search for reasons for the phenomenon shown by the huge difference in the income between two groups of people both dwelling near the rivers, several researchers made their effort and gave certain explanations. One attributes
9
to the interesting change claiming that it is not as simple as it seems to be in appearance that the relationship between
10
which is a good example of
11
, which involved in the interaction of separate factors for the processing of information as well as the behavioural adaptation to unstable conditions. As far as the biological transformation is concerned, both
12
and the blend of genres from the last generation brings about the difference. The economic counterpart shows how generating and choosing the
13
of innumerable goods moves forward the material-oriented economy.

In response to the search for reasons for the phenomenon shown by the huge difference in the income between two groups of people both dwelling near the rivers, several researchers made their effort and gave certain explanations. One attributes 9 ____ to the interesting change claiming that it is not as simple as it seems to be in appearance that the relationship between 10 ____ which is a good example of 11 ____ , which involved in the interaction of separate factors for the processing of information as well as the behavioural adaptation to unstable conditions. As far as the biological transformation is concerned, both 12 ____ and the blend of genres from the last generation brings about the difference. The economic counterpart shows how generating and choosing the 13 ____ of innumerable goods moves forward the material-oriented economy.$md$, NULL, ARRAY['.*complexity.*']);

COMMIT;
