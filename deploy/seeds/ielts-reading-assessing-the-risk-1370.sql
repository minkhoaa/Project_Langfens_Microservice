BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-assessing-the-risk-1370'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-assessing-the-risk-1370';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-assessing-the-risk-1370';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-assessing-the-risk-1370';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('6ee8f33a-ed25-5a00-af29-2a42e7373d69', 'ielts-reading-assessing-the-risk-1370', $t$Assessing the risk$t$, $md$## Assessing the risk

Nguồn:
- Test: https://mini-ielts.com/1370/reading/assessing-the-risk
- Solution: https://mini-ielts.com/1370/view-solution/reading/assessing-the-risk$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7099d338-753e-53c5-87e8-7c0744bf7f4d', '6ee8f33a-ed25-5a00-af29-2a42e7373d69', 1, $t$Reading — Assessing the risk$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Assessing the risk

A

As a title for a supposedly unprejudiced debate on scientific progress, “Panic attack: interrogating our obsession with risk” did not bode well. Held last week at the Royal Institution in London, the event brought together scientists from across the world to ask why society is so obsessed with risk and to call for a “more rational” approach. “We seem to be organising society around the grandmotherly maxim of ‘better safe than sorry’,” exclaimed Spiked, the online publication that organised the event. “What are the consequences of this overbearing concern with risks?”

B

The debate was preceded by a survey of 40 scientists who were invited to describe how awful our lives would be if the “precautionary principle” had been allowed to prevail in the past. Their response was: no heart surgery or antibiotics, and hardly any drugs at all; no aeroplanes, bicycles or high-voltage power grids; no pasteurisation, pesticides or biotechnology; no quantum mechanics; no wheel; no “discovery” of America. In short, their message was: no risk, no gain.

C

They have absolutely missed the point. The precautionary principle is a subtle idea. It has various forms, but all of them generally include some notion of cost-effectiveness. Thus the point is not simply to ban things that are not known to be absolutely safe. Rather, it says: “Of course you can make no progress without risk. But if there is no obvious gain from taking the risk, then don’t take it.”

D

Clearly, all the technologies listed by the 40 well-chosen savants were innately risky at their inception, as all technologies are. But all of them would have received the green light under the precautionary principle because they all had the potential to offer tremendous benefits – the solutions to very big problems – if only the snags could be overcome.

E

If the precautionary principle had been in place, the scientists tell us, we would not have antibiotics. But of course, we would – if the version of the principle that sensible people now understand had been applied. When penicillin was discovered in the 1920s, infective bacteria were laying waste to the world. Children died from diphtheria and whooping cough, every open-drain brought the threat of typhoid, and any wound could lead to septicaemia and even gangrene.

F

Penicillin was turned into a practical drug during the Second World War when the many pestilences that result from were threatened to kill more people than the bombs. Of course antibiotics were a priority. Of course, the risks, such as they could be perceived, were worth taking.

G

And so with the other items on the scientists’ list: electric light bulbs, blood transfusions. CAT scans, knives, the measles vaccine – the precautionary principle would have prevented all of them, they tell us. But this is just plain wrong. If the precautionary principle had been applied properly, all these creations would have passed muster, because all offered incomparable advantages compared to the risks perceived at the time.

H

Another issue is at stake here. Statistics are not the only concept people use when weighing up risk. Human beings, subtle and evolved creatures that we are, do not survive to three-score years and ten simply by thinking like pocket calculators. A crucial issue is the consumer’s choice. In deciding whether to pursue the development of new technology, the consumer’s right to choose should be considered alongside considerations of risk and benefit. Clearly, skiing is more dangerous than genetically modified tomatoes. But people who ski choose to do so; they do not have skiing thrust upon them by portentous experts of the kind who now feel they have the right to reconstruct our crops. Even with skiing, there is the matter of cost-effectiveness to consider: skiing, I am told, is exhilarating. Where is the exhilaration in GM soya?

I

Indeed, in contrast to all the other items on Spiked’s list, GM crops stand out as an example of a technology whose benefits are far from clear. Some of the risks can at least be defined. But in the present economic climate, the benefits that might accrue from them seem dubious. Promoters of GM crops believe that the future population of the world cannot be fed without them. That is untrue. The crops that really matter are wheat and rice, and there is no GM research in the pipeline that will seriously affect the yield of either. GM is used to make production cheaper and hence more profitable, which is an extremely questionable ambition.

J

The precautionary principle provides the world with a very important safeguard. If it had been in place in the past it might, for example, have prevented insouciant miners from polluting major rivers with mercury. We have come to a sorry pass when scientists, who should above all be dispassionate scholars, feel they should misrepresent such a principle for the purposes of commercial and political propaganda. People at large continue to mistrust science and the high technologies it produces partly because they doubt the wisdom of scientists. On such evidence as this, these doubts are fully justified.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5d9809d-7793-54f8-83ed-630f0abe58e0', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The title of the debate is not unbiased.
2
All the scientists invited to the debate were from the field of medicine.
3
The message those scientists who conducted the survey were sending was people shouldn’t take risks.
4
All the 40 listed technologies are riskier than other technologies.
5
It was worth taking the risks to invent antibiotics.
6
All the other inventions on the list were also judged by the precautionary principle.

1 ____ The title of the debate is not unbiased.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89322f93-e9fc-5cb2-8933-fb49e19ba4f3', 'a5d9809d-7793-54f8-83ed-630f0abe58e0', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9110fe3d-c17f-5ac1-a6ce-18eff8f4da1d', 'a5d9809d-7793-54f8-83ed-630f0abe58e0', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63e1414c-6207-5817-872d-59523f5ee399', 'a5d9809d-7793-54f8-83ed-630f0abe58e0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eafda164-9a68-5b2f-8e8d-c63cf14b00bb', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The title of the debate is not unbiased.
2
All the scientists invited to the debate were from the field of medicine.
3
The message those scientists who conducted the survey were sending was people shouldn’t take risks.
4
All the 40 listed technologies are riskier than other technologies.
5
It was worth taking the risks to invent antibiotics.
6
All the other inventions on the list were also judged by the precautionary principle.

2 ____ All the scientists invited to the debate were from the field of medicine.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('088b2eea-ccf1-54e1-bd2d-fc4817cc61c5', 'eafda164-9a68-5b2f-8e8d-c63cf14b00bb', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90484f3f-9f3f-5e6b-97f6-cdff7c9ae0c5', 'eafda164-9a68-5b2f-8e8d-c63cf14b00bb', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e902c73d-1772-59c0-840a-a553eae5cdb8', 'eafda164-9a68-5b2f-8e8d-c63cf14b00bb', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('433a6cbe-e877-551e-8e45-ac13a40b3c56', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The title of the debate is not unbiased.
2
All the scientists invited to the debate were from the field of medicine.
3
The message those scientists who conducted the survey were sending was people shouldn’t take risks.
4
All the 40 listed technologies are riskier than other technologies.
5
It was worth taking the risks to invent antibiotics.
6
All the other inventions on the list were also judged by the precautionary principle.

3 ____ The message those scientists who conducted the survey were sending was people shouldn’t take risks.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d354386-d7ab-5a8b-bf73-e2b483a4ae9f', '433a6cbe-e877-551e-8e45-ac13a40b3c56', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b98e5a2c-3edb-561c-a306-3437fd58817a', '433a6cbe-e877-551e-8e45-ac13a40b3c56', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4efd1acb-1aa4-5e19-a762-045ba64462a7', '433a6cbe-e877-551e-8e45-ac13a40b3c56', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d06a3f6e-1474-5ebe-ad25-ca03f31f2f18', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The title of the debate is not unbiased.
2
All the scientists invited to the debate were from the field of medicine.
3
The message those scientists who conducted the survey were sending was people shouldn’t take risks.
4
All the 40 listed technologies are riskier than other technologies.
5
It was worth taking the risks to invent antibiotics.
6
All the other inventions on the list were also judged by the precautionary principle.

4 ____ All the 40 listed technologies are riskier than other technologies.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff82ccb8-6ff7-57d3-ba39-3abd9936ff72', 'd06a3f6e-1474-5ebe-ad25-ca03f31f2f18', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39b0c7cf-e91f-59bc-a3b6-e2918d146d50', 'd06a3f6e-1474-5ebe-ad25-ca03f31f2f18', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1af27cb9-9d1d-5b65-a2a5-fa81c7f48777', 'd06a3f6e-1474-5ebe-ad25-ca03f31f2f18', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('31b05d26-e138-5296-a38e-e117eb38786b', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The title of the debate is not unbiased.
2
All the scientists invited to the debate were from the field of medicine.
3
The message those scientists who conducted the survey were sending was people shouldn’t take risks.
4
All the 40 listed technologies are riskier than other technologies.
5
It was worth taking the risks to invent antibiotics.
6
All the other inventions on the list were also judged by the precautionary principle.

5 ____ It was worth taking the risks to invent antibiotics.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0c7bc40-fd5f-52ed-aab7-f84ca734fdfd', '31b05d26-e138-5296-a38e-e117eb38786b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eacec67a-c7ad-5180-9cfb-e9540e1fb9a6', '31b05d26-e138-5296-a38e-e117eb38786b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc8d38d1-1aa9-547e-9ecf-e07e18c3ed8b', '31b05d26-e138-5296-a38e-e117eb38786b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('579cea89-f7a2-5ea5-aa57-3cf5bb57f366', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The title of the debate is not unbiased.
2
All the scientists invited to the debate were from the field of medicine.
3
The message those scientists who conducted the survey were sending was people shouldn’t take risks.
4
All the 40 listed technologies are riskier than other technologies.
5
It was worth taking the risks to invent antibiotics.
6
All the other inventions on the list were also judged by the precautionary principle.

6 ____ All the other inventions on the list were also judged by the precautionary principle.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eab2fecd-708f-5765-bd76-0c5072a78a81', '579cea89-f7a2-5ea5-aa57-3cf5bb57f366', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85d632a3-d3c1-5061-9d7f-fc97578dd279', '579cea89-f7a2-5ea5-aa57-3cf5bb57f366', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11a39526-fd97-5f8d-94bd-18287978fe79', '579cea89-f7a2-5ea5-aa57-3cf5bb57f366', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('174a6ac4-6fd6-548c-aae0-a75aed5d5968', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the
7
, along with the usual consideration of
8
. For example, though risky and dangerous enough, people still enjoy
9
for the excitement it provides. On the other hand, experts believe that future population desperately needs
10
in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of
11
, but to reduce the cost of
12
and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to
13
science for they believe scientists are not to be trusted.

When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the 7 ____ , along with the usual consideration of 8 ____ . For example, though risky and dangerous enough, people still enjoy 9 ____ for the excitement it provides. On the other hand, experts believe that future population desperately needs 10 ____ in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of 11 ____ , but to reduce the cost of 12 ____ and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to 13 ____ science for they believe scientists are not to be trusted.$md$, NULL, ARRAY['.*consumer.*s.*right.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d3f2402b-c853-510f-a914-f718e3fce6cd', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the
7
, along with the usual consideration of
8
. For example, though risky and dangerous enough, people still enjoy
9
for the excitement it provides. On the other hand, experts believe that future population desperately needs
10
in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of
11
, but to reduce the cost of
12
and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to
13
science for they believe scientists are not to be trusted.

When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the 7 ____ , along with the usual consideration of 8 ____ . For example, though risky and dangerous enough, people still enjoy 9 ____ for the excitement it provides. On the other hand, experts believe that future population desperately needs 10 ____ in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of 11 ____ , but to reduce the cost of 12 ____ and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to 13 ____ science for they believe scientists are not to be trusted.$md$, NULL, ARRAY['.*consumer.*s.*right.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('43e749c8-d129-5fe4-9d67-be3cb5b3916d', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the
7
, along with the usual consideration of
8
. For example, though risky and dangerous enough, people still enjoy
9
for the excitement it provides. On the other hand, experts believe that future population desperately needs
10
in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of
11
, but to reduce the cost of
12
and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to
13
science for they believe scientists are not to be trusted.

When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the 7 ____ , along with the usual consideration of 8 ____ . For example, though risky and dangerous enough, people still enjoy 9 ____ for the excitement it provides. On the other hand, experts believe that future population desperately needs 10 ____ in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of 11 ____ , but to reduce the cost of 12 ____ and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to 13 ____ science for they believe scientists are not to be trusted.$md$, NULL, ARRAY['.*consumer.*s.*right.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d927f168-5083-5aeb-8d8e-4ba3006ffe7c', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the
7
, along with the usual consideration of
8
. For example, though risky and dangerous enough, people still enjoy
9
for the excitement it provides. On the other hand, experts believe that future population desperately needs
10
in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of
11
, but to reduce the cost of
12
and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to
13
science for they believe scientists are not to be trusted.

When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the 7 ____ , along with the usual consideration of 8 ____ . For example, though risky and dangerous enough, people still enjoy 9 ____ for the excitement it provides. On the other hand, experts believe that future population desperately needs 10 ____ in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of 11 ____ , but to reduce the cost of 12 ____ and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to 13 ____ science for they believe scientists are not to be trusted.$md$, NULL, ARRAY['.*consumer.*s.*right.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d7b60e11-f1c8-55c3-8596-0a44b8622040', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the
7
, along with the usual consideration of
8
. For example, though risky and dangerous enough, people still enjoy
9
for the excitement it provides. On the other hand, experts believe that future population desperately needs
10
in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of
11
, but to reduce the cost of
12
and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to
13
science for they believe scientists are not to be trusted.

When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the 7 ____ , along with the usual consideration of 8 ____ . For example, though risky and dangerous enough, people still enjoy 9 ____ for the excitement it provides. On the other hand, experts believe that future population desperately needs 10 ____ in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of 11 ____ , but to reduce the cost of 12 ____ and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to 13 ____ science for they believe scientists are not to be trusted.$md$, NULL, ARRAY['.*consumer.*s.*right.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3dad73a3-845d-52f9-88bd-b86a21e9a54e', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the
7
, along with the usual consideration of
8
. For example, though risky and dangerous enough, people still enjoy
9
for the excitement it provides. On the other hand, experts believe that future population desperately needs
10
in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of
11
, but to reduce the cost of
12
and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to
13
science for they believe scientists are not to be trusted.

When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the 7 ____ , along with the usual consideration of 8 ____ . For example, though risky and dangerous enough, people still enjoy 9 ____ for the excitement it provides. On the other hand, experts believe that future population desperately needs 10 ____ in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of 11 ____ , but to reduce the cost of 12 ____ and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to 13 ____ science for they believe scientists are not to be trusted.$md$, NULL, ARRAY['.*consumer.*s.*right.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('eb56a26d-204a-5b8e-9bbf-cce011864df7', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-13
on your answer sheet.
When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the
7
, along with the usual consideration of
8
. For example, though risky and dangerous enough, people still enjoy
9
for the excitement it provides. On the other hand, experts believe that future population desperately needs
10
in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of
11
, but to reduce the cost of
12
and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to
13
science for they believe scientists are not to be trusted.

When applying the precautionary principle to decide whether to invent a new technology, people should also the consideration of the 7 ____ , along with the usual consideration of 8 ____ . For example, though risky and dangerous enough, people still enjoy 9 ____ for the excitement it provides. On the other hand, experts believe that future population desperately needs 10 ____ in spite of their undefined risks. However, the researchers conducted so far have not been directed towards increasing the yield of 11 ____ , but to reduce the cost of 12 ____ and to bring more profit out of it. In the end, such selfish use of the precautionary principle for business and political gain has often led people to 13 ____ science for they believe scientists are not to be trusted.$md$, NULL, ARRAY['.*consumer.*s.*right.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fd8049cd-4ee0-5b8b-a052-76692551f5b8', '7099d338-753e-53c5-87e8-7c0744bf7f4d', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Question 14
Question 14
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
14
on your answer sheet.
14.
What is the main theme of the passage?
A
people have the right to doubt science and technologies
B
the precautionary principle could have prevented the development of science and technology
C
there are not enough people who truly understand the precautionary principle
D
the precautionary principle bids us take risks at all costs

Choose the correct letter, A , B , C or D .$md$, NULL);

COMMIT;
