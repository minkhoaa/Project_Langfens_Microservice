BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-natural-pesticide-in-india-1325'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-natural-pesticide-in-india-1325';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-natural-pesticide-in-india-1325';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-natural-pesticide-in-india-1325';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('fb5f1852-d6ee-5002-9776-802f1ad6425f', 'ielts-reading-natural-pesticide-in-india-1325', $t$Natural pesticide in India$t$, $md$## Natural pesticide in India

Nguồn:
- Test: https://mini-ielts.com/1325/reading/natural-pesticide-in-india
- Solution: https://mini-ielts.com/1325/view-solution/reading/natural-pesticide-in-india$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('265c9604-b294-51ce-8871-ed59e1905e73', 'fb5f1852-d6ee-5002-9776-802f1ad6425f', 1, $t$Reading — Natural pesticide in India$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Natural pesticide in India

A

A dramatic story about cotton farmers in India shows how destructive pesticides can be for people and the environment; and why today’s agriculture is so dependent on pesticides. This story also shows that it’s possible to stop using chemical pesticides without losing a crop to ravaging insects, and it explains how to do it.

B

The story began about 30 years ago, a handful of families migrated from the Guntur district of Andhra Pradesh, southeast India, into Punukula, a community of around 900 people farming plots of between two and 10 acres. The outsiders from Guntur brought cotton-culture with them. Cotton wooed farmers by promising to bring in more hard cash than the mixed crops they were already growing to eat and sell: millet, sorghum, groundnuts, pigeon peas, mung beans, chili and rice. But raising cotton meant using pesticides and fertilizers – until then a mystery to the mostly illiterate farmers of the community. When cotton production started spreading through Andhra Pradesh state. The high value of cotton made it an exceptionally attractive crop, but growing cotton required chemical fertilizers and pesticides. As most of the farmers were poor, illiterate, and without previous experience using agricultural chemicals, they were forced to rely on local, small-scale agricultural dealers for advice. The dealers sold them seeds, fertilizers, and pesticides on credit and also guaranteed the purchase of their crop. The dealers themselves had little technical knowledge about pesticides. They merely passed on promotional information from multinational chemical companies that supplied their products.

C

At first, cotton yields were high, and expenses for pesticides were low because cotton pests had not yet moved in. The farmers had never earned so much! But within a few years, cotton pests like bollworms and aphids plagued the fields, and the farmers saw how rapid insect evolution can be. Repeated spraying killed off the weaker pests, but left the ones most resistant to pesticides to multiply. As pesticide resistance mounted, the farmers had to apply more and more of the pesticides to get the same results. At the same time, the pesticides killed off birds, wasps, beetles, spiders, and other predators that had once provided natural control of pest insects. Without these predators, the pests could destroy the entire crop if pesticides were not used. Eventually, farmers were mixing sometimes having to spray their cotton as frequently as two times a week. They were really hooked!

D

The villagers were hesitant, but one of Punukula’s village elders decided to risk trying the natural methods instead of pesticides. His son had collapsed with acute pesticide poisoning and survived but the hospital bill was staggering. SECURE’s staff coached this villager on how to protect his cotton crop by using a toolkit of natural methods chat India’s Center for Sustainable Agriculture put together in collaboration with scientists at Andhra Pradesh’s state university. They called the toolkit “Non-Pesticide Management” – or “NPM.”

E

The most important resource in the NPM toolkit was the neem tree (Azadirachta indica) which is common throughout much of India. Neem tree is a broad-leaved evergreen tree related to mahogany. It protects itself against insects by producing a multitude of natural pesticides that work in a variety of ways: with an arsenal of chemical defenses that repel egg-laying, interfere with insect growth, and most important, disrupt the ability of crop-eating insects to sense their food.

F

In fact, neem has been used traditionally in India to protect stored grains from insects and to produce soaps, skin lotions, and other health products. To protect crops from insects, neem seeds are simply ground into a powder that is soaked overnight in water. The solution is then sprayed onto the crop. Another preparation, neem cake, can be mixed into the soil to kill pests and diseases in the soil, and it doubles as an organic fertilizer high in nitrogen. Neem trees grow locally, so the only “cost” is the labor to prepare neem for application to fields.

G

The first farmer’s trial with NPM was a complete success! His harvest was as good as the harvests of farmers that were using pesticides, and he earned much more because he did not spend a single rupee on pesticides. Inspired by this success, 20 farmers tried NPM the next year. SECURE posted two well-trained staff in Punukula to teach and help everyone in the village, and the village women put pressure on their husbands to stop using toxic chemicals. Families that were no longer exposing themselves to pesticides began to feel much better, and the rapid improvement in income, health, and general wellbeing quickly sold everyone on the value of NPM. By 2000, all the farmers in Punukula were using NPM, not only for cotton but for their other crops as well.

H

The suicide epidemic came to an end. And with the cash, health, and energy that returned when they stopped poisoning themselves with pesticides, the villagers were inspired to start more community and business projects. The women of Punukula created a new source of income by collecting, grinding, and selling neem seeds for NPM in other villages. The villagers rescued their indentured children and gave them special six-month “catch-up,” courses to return to school.

I

Fighting against pesticides, and winning, increased village solidarity, self-confidence, and optimism about the future. When dealers tried to punish NPM users by paying less for NPM cotton, the farmers united to form a marketing cooperative that found fairer prices elsewhere. The leadership and collaboration skills that the citizens of Punukula developed in the NPM struggle have helped them to take on other challenges, like water purification, building a cotton gin to add value to the cotton before they sell it, and convincing the state government to support NPM over the objection of multi-national pesticide corporations.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f2912cdd-bc3a-567b-8f31-848f3fc93498', '265c9604-b294-51ce-8871-ed59e1905e73', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-4
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cotton in Andhra Pradesh state could really bring more income to the local farmers than traditional farming.
2
The majority of farmers had used agricultural pesticides before 30 years ago.
3
The yield of cotton is relatively lower than that of other agricultural crops.
4
The farmers didn’t realize the spread of the pests was so fast.

1 ____ Cotton in Andhra Pradesh state could really bring more income to the local farmers than traditional farming.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e4b034d-1f6c-5130-803b-57c8fe329da5', 'f2912cdd-bc3a-567b-8f31-848f3fc93498', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57a6a986-84c8-5167-9dee-82305ecf54ab', 'f2912cdd-bc3a-567b-8f31-848f3fc93498', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fab23626-e605-508d-82a6-ffce4957ce13', 'f2912cdd-bc3a-567b-8f31-848f3fc93498', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('134000ca-e278-5e81-9776-9a5b89106ee2', '265c9604-b294-51ce-8871-ed59e1905e73', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-4
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cotton in Andhra Pradesh state could really bring more income to the local farmers than traditional farming.
2
The majority of farmers had used agricultural pesticides before 30 years ago.
3
The yield of cotton is relatively lower than that of other agricultural crops.
4
The farmers didn’t realize the spread of the pests was so fast.

2 ____ The majority of farmers had used agricultural pesticides before 30 years ago.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfd8966d-cba4-50de-abbd-d69b6069679f', '134000ca-e278-5e81-9776-9a5b89106ee2', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f28801c-0be3-5bcf-8a25-9e2bca5f0407', '134000ca-e278-5e81-9776-9a5b89106ee2', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e9c17c1-255b-5608-b780-ecc5bdf84fd4', '134000ca-e278-5e81-9776-9a5b89106ee2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f111b5bc-fc42-567d-b02a-54f3df3fc075', '265c9604-b294-51ce-8871-ed59e1905e73', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-4
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cotton in Andhra Pradesh state could really bring more income to the local farmers than traditional farming.
2
The majority of farmers had used agricultural pesticides before 30 years ago.
3
The yield of cotton is relatively lower than that of other agricultural crops.
4
The farmers didn’t realize the spread of the pests was so fast.

3 ____ The yield of cotton is relatively lower than that of other agricultural crops.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30db58c8-f830-532a-a601-30090202e7a6', 'f111b5bc-fc42-567d-b02a-54f3df3fc075', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20c06713-c34e-59f8-b41d-f3954f0f08b4', 'f111b5bc-fc42-567d-b02a-54f3df3fc075', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34f1e8a9-a05d-5f7e-af02-ca53660678e0', 'f111b5bc-fc42-567d-b02a-54f3df3fc075', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('08398c6f-4280-5f37-a051-9b6cb8fd04f7', '265c9604-b294-51ce-8871-ed59e1905e73', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-4
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cotton in Andhra Pradesh state could really bring more income to the local farmers than traditional farming.
2
The majority of farmers had used agricultural pesticides before 30 years ago.
3
The yield of cotton is relatively lower than that of other agricultural crops.
4
The farmers didn’t realize the spread of the pests was so fast.

4 ____ The farmers didn’t realize the spread of the pests was so fast.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7f08589-0c7a-57aa-b9bd-b9ebf8faaca8', '08398c6f-4280-5f37-a051-9b6cb8fd04f7', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6e6ec4c-77d9-5dcd-874b-d96c651e6a7f', '08398c6f-4280-5f37-a051-9b6cb8fd04f7', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3e2cd85-7210-5a7c-a75d-1de2185d4a28', '08398c6f-4280-5f37-a051-9b6cb8fd04f7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0f537e89-63f9-5bbe-85c5-9da63c106759', '265c9604-b294-51ce-8871-ed59e1905e73', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-11
Questions 5-11
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer
Write your answers in boxes
5-11
on your answer sheet.
The Making of pesticide protecting crops against insects
The broad-leaved neem tree was chosen. It is a fast-growing and
5
tree and produces an amount of
6
for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into
7
form, which is left behind
8
in water. Then we need to spray the solution onto the crop. A special
9
is used when mixing with soil in order to eliminate bugs and bacteria, and its effect
10
when it adds the level of
11
1
in this organic fertilizer meanwhile.

The broad-leaved neem tree was chosen. It is a fast-growing and 5 ____ tree and produces an amount of 6 ____ for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into 7 ____ form, which is left behind 8 ____ in water. Then we need to spray the solution onto the crop. A special 9 ____ is used when mixing with soil in order to eliminate bugs and bacteria, and its effect 10 ____ when it adds the level of 11 ____ 1 in this organic fertilizer meanwhile.$md$, NULL, ARRAY['.*evergreen.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ed1c035a-b113-58ff-8869-0c8c904106f1', '265c9604-b294-51ce-8871-ed59e1905e73', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-11
Questions 5-11
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer
Write your answers in boxes
5-11
on your answer sheet.
The Making of pesticide protecting crops against insects
The broad-leaved neem tree was chosen. It is a fast-growing and
5
tree and produces an amount of
6
for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into
7
form, which is left behind
8
in water. Then we need to spray the solution onto the crop. A special
9
is used when mixing with soil in order to eliminate bugs and bacteria, and its effect
10
when it adds the level of
11
1
in this organic fertilizer meanwhile.

The broad-leaved neem tree was chosen. It is a fast-growing and 5 ____ tree and produces an amount of 6 ____ for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into 7 ____ form, which is left behind 8 ____ in water. Then we need to spray the solution onto the crop. A special 9 ____ is used when mixing with soil in order to eliminate bugs and bacteria, and its effect 10 ____ when it adds the level of 11 ____ 1 in this organic fertilizer meanwhile.$md$, NULL, ARRAY['.*evergreen.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b19de9eb-851a-56f3-9c04-a9e5ae33f18d', '265c9604-b294-51ce-8871-ed59e1905e73', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-11
Questions 5-11
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer
Write your answers in boxes
5-11
on your answer sheet.
The Making of pesticide protecting crops against insects
The broad-leaved neem tree was chosen. It is a fast-growing and
5
tree and produces an amount of
6
for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into
7
form, which is left behind
8
in water. Then we need to spray the solution onto the crop. A special
9
is used when mixing with soil in order to eliminate bugs and bacteria, and its effect
10
when it adds the level of
11
1
in this organic fertilizer meanwhile.

The broad-leaved neem tree was chosen. It is a fast-growing and 5 ____ tree and produces an amount of 6 ____ for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into 7 ____ form, which is left behind 8 ____ in water. Then we need to spray the solution onto the crop. A special 9 ____ is used when mixing with soil in order to eliminate bugs and bacteria, and its effect 10 ____ when it adds the level of 11 ____ 1 in this organic fertilizer meanwhile.$md$, NULL, ARRAY['.*evergreen.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ec8258e1-9f8f-53fb-a7de-3e278477fb5e', '265c9604-b294-51ce-8871-ed59e1905e73', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-11
Questions 5-11
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer
Write your answers in boxes
5-11
on your answer sheet.
The Making of pesticide protecting crops against insects
The broad-leaved neem tree was chosen. It is a fast-growing and
5
tree and produces an amount of
6
for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into
7
form, which is left behind
8
in water. Then we need to spray the solution onto the crop. A special
9
is used when mixing with soil in order to eliminate bugs and bacteria, and its effect
10
when it adds the level of
11
1
in this organic fertilizer meanwhile.

The broad-leaved neem tree was chosen. It is a fast-growing and 5 ____ tree and produces an amount of 6 ____ for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into 7 ____ form, which is left behind 8 ____ in water. Then we need to spray the solution onto the crop. A special 9 ____ is used when mixing with soil in order to eliminate bugs and bacteria, and its effect 10 ____ when it adds the level of 11 ____ 1 in this organic fertilizer meanwhile.$md$, NULL, ARRAY['.*evergreen.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('50871c0a-3921-58ed-bc20-dd39949e436f', '265c9604-b294-51ce-8871-ed59e1905e73', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 5-11
Questions 5-11
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer
Write your answers in boxes
5-11
on your answer sheet.
The Making of pesticide protecting crops against insects
The broad-leaved neem tree was chosen. It is a fast-growing and
5
tree and produces an amount of
6
for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into
7
form, which is left behind
8
in water. Then we need to spray the solution onto the crop. A special
9
is used when mixing with soil in order to eliminate bugs and bacteria, and its effect
10
when it adds the level of
11
1
in this organic fertilizer meanwhile.

The broad-leaved neem tree was chosen. It is a fast-growing and 5 ____ tree and produces an amount of 6 ____ for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into 7 ____ form, which is left behind 8 ____ in water. Then we need to spray the solution onto the crop. A special 9 ____ is used when mixing with soil in order to eliminate bugs and bacteria, and its effect 10 ____ when it adds the level of 11 ____ 1 in this organic fertilizer meanwhile.$md$, NULL, ARRAY['.*evergreen.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('76f7a92e-1d08-5cbe-950e-76c4458e6232', '265c9604-b294-51ce-8871-ed59e1905e73', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 5-11
Questions 5-11
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer
Write your answers in boxes
5-11
on your answer sheet.
The Making of pesticide protecting crops against insects
The broad-leaved neem tree was chosen. It is a fast-growing and
5
tree and produces an amount of
6
for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into
7
form, which is left behind
8
in water. Then we need to spray the solution onto the crop. A special
9
is used when mixing with soil in order to eliminate bugs and bacteria, and its effect
10
when it adds the level of
11
1
in this organic fertilizer meanwhile.

The broad-leaved neem tree was chosen. It is a fast-growing and 5 ____ tree and produces an amount of 6 ____ for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into 7 ____ form, which is left behind 8 ____ in water. Then we need to spray the solution onto the crop. A special 9 ____ is used when mixing with soil in order to eliminate bugs and bacteria, and its effect 10 ____ when it adds the level of 11 ____ 1 in this organic fertilizer meanwhile.$md$, NULL, ARRAY['.*evergreen.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c1b8b84b-4885-58e7-9bf1-1b7cdf210b28', '265c9604-b294-51ce-8871-ed59e1905e73', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 5-11
Questions 5-11
Complete the summary below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer
Write your answers in boxes
5-11
on your answer sheet.
The Making of pesticide protecting crops against insects
The broad-leaved neem tree was chosen. It is a fast-growing and
5
tree and produces an amount of
6
for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into
7
form, which is left behind
8
in water. Then we need to spray the solution onto the crop. A special
9
is used when mixing with soil in order to eliminate bugs and bacteria, and its effect
10
when it adds the level of
11
1
in this organic fertilizer meanwhile.

The broad-leaved neem tree was chosen. It is a fast-growing and 5 ____ tree and produces an amount of 6 ____ for itself that can be effective like insects repellent. Firstly, neem seeds need to be crushed into 7 ____ form, which is left behind 8 ____ in water. Then we need to spray the solution onto the crop. A special 9 ____ is used when mixing with soil in order to eliminate bugs and bacteria, and its effect 10 ____ when it adds the level of 11 ____ 1 in this organic fertilizer meanwhile.$md$, NULL, ARRAY['.*evergreen.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('75c8bd37-db4a-5865-b255-79f169020708', '265c9604-b294-51ce-8871-ed59e1905e73', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 12-13
Questions 12-13
Answer the questions below
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes
12-13
on your answer sheet.
12
In which year did all the farmers use NPM for their crops in Punukala?
12
13
What gave the women of Punukula a business opportunity to NPMs?
13

12 In which year did all the farmers use NPM for their crops in Punukala? 12 ____$md$, NULL, ARRAY['.*in.*2000.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4ecd5dce-e622-5163-965e-9c4b812451a5', '265c9604-b294-51ce-8871-ed59e1905e73', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 12-13
Questions 12-13
Answer the questions below
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes
12-13
on your answer sheet.
12
In which year did all the farmers use NPM for their crops in Punukala?
12
13
What gave the women of Punukula a business opportunity to NPMs?
13

13 What gave the women of Punukula a business opportunity to NPMs? 13 ____$md$, NULL, ARRAY['.*neem.*seeds.*']);

COMMIT;
