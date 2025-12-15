BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-pesticide-free-village-1447'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-pesticide-free-village-1447';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-pesticide-free-village-1447';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-pesticide-free-village-1447';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('81ff8365-e73e-528e-802e-063e70a08a8b', 'ielts-reading-the-pesticide-free-village-1447', $t$The pesticide-free village$t$, $md$## The pesticide-free village

Nguồn:
- Test: https://mini-ielts.com/1447/reading/the-pesticide-free-village
- Solution: https://mini-ielts.com/1447/view-solution/reading/the-pesticide-free-village$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('0b457673-6878-5b5e-a6ae-5fc7dbea72aa', '81ff8365-e73e-528e-802e-063e70a08a8b', 1, $t$Reading — The pesticide-free village$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The pesticide-free village

Gerry Marten and Dona Glee Williams report on reliance on the Indian village of Punukula, so nearly destroyed by reliance on pesticides.

Around 20 years ago, a handful of families migrated from the Guntur district of Andhra Pradesh, south-east India, into Punukula, a community of around 900 people farming plots of between two and ten acres. The outsiders from Guntur brought cotton culture with them, and this attracted resident farmers by promising to bring in more hard cash than the mixed crops they were already growing to eat and sell, such as millet, mung beans, chilli and rice. But growing cotton meant using pesticides and fertilisers - until then a mystery to the mostly illiterate farmers of the community.

Local agro-chemical dealers obligingly filled the need for information and supplies. These'middlemen' sold commercial seeds, fertilisers and insecticides on credit, and guaranteed purchase of the crop. They offered technical advice provided by the companies that supplied their products. The farmers depend on the dealers. If they wanted to grow cotton - and they did - it seemed they had no choice.

A quick ‘high’ of booming yields and incomes hooked growers during the early years of cotton in the region. Outlay on insecticides was fairly low because cotton pests hadn't moved in yet. Many farmers were so impressed with the chemicals that they started using them on their other crops as well. The immediate payoffs from chemically-dependent cotton agriculture both ensured and obscured the fact that the black dirt fields had gone into a freefall of environmental degradation, dragged down by a chain of cause and effect.

Soon cotton-eaters, such as bollworms and aphids, plagued the fields. Repeated spraying killed off the most susceptible pests and left the strongest to reproduce and pass on their resistance to generations of ever-hardier offspring. As the bugs grew tougher and more abundant, farmers applied a greater variety and quantity of poisons, something mixing 'cocktails' of as many as ten insecticides. At the same time, cotton was gobbling up the nutrients in the soil, leaving the growers no option but to invest in chemical fertilisers.

By the time some farmers tried to break free of their chemical dependence, insecticides had already decimated the birds, wasps, beetles, and other predators that had once provided natural control of crop pests. Without their balancing presence, pests ran riot if insecticide was cut back. As outlays for fertilisers and insecticides escalated, the cost of producing cotton mounted. Eventually the expense of chemical inputs outgrew the cash value of the crop, and farmers fell further and further into debt and poverty.

Their vicious cycle was only broken by the willingness of a prominent village elder to experiment with something different. He had been among the first villagers to grow cotton, and he would be the first to try it without chemicals, as set out by a programme in Non-Pesticide Management (NPM). This had been devised for Punukala with the help of a Non-Government Organisation called SECURE that had become aware of the hardships caused by the pesticide trap.

It involved turning to neem, a fast-growing, broad-leaved evergreen tree related to mahogany. Neem protects itself against insects by producing a multitude of natural pesticides that have evolved specifically to defeat plant-eating insects. Thus they are generally harmless to human and other animals, including birds and insects that eat pests.

The plant is native to India and Burma, where it has been used for centuries to control pests and to promote health. To protect cotton, neem seeds are simply ground into a powder, soaked overnight in water, and sprayed onto the crop at least every 10 days. Neem cake applied to the soil kills insect pests and doubles as an organic fertiliser high in nitrogen. As neem grows locally and is easy to process, it is much less expensive than the chemical insecticides sold for profit by the dealers and their corporate suppliers.

Quick, short-term gains had once pushed Punukula into chemical-dependent agriculture. Now they found that similar immediate rewards were helping to speed change in the other direction: the harvest of the next 20 NPM farmers was as good as the harvest of farmers using insecticides, and they came out ahead because they weren't buying insecticides, instead of investing cash (in short supply) in chemicals, they invested time and labour in NPM practices.

By the end of 2000, all the farmers in Punukula village were using NPM rather than chemicals for cotton, and they began to use it on other crops as well. The was using it. The status and economic opportunities of women improved - neem change gathered momentum as NPM became even more effective once everyone became a source of income for some of them, as they gathered seeds from the surrounding area to sell for NPM in other villages. The improve situation meant that families could afford to put more land under cultivation.

In 2004, the panchayat (village government) formally declared Punukula to be a pesticide-free village. And they have big plans for the future, such as water purification. The village now serves as a model for disseminating NPM to other communities, with around 2000 farmers visiting each year.

What began as a few farmers desperate to find a way to farm without poisons has become a movement with the potential to pull an entire region back from ecological disaster.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('94b2525f-93bc-5dbc-95a6-31f2387b298d', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cotton growing was expected to raise more money than other crop.
2
Some of the local agro-chemical dealers had been farmers in the past.
3
Initially the farmers’ cotton yields were low.
4
At first, the farmers failed to notice the negative effects on their fields of pesticide use.

1 ____ Cotton growing was expected to raise more money than other crop.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b23ea50-c463-5b15-ac85-a778c8c4fe32', '94b2525f-93bc-5dbc-95a6-31f2387b298d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f690250b-af80-5982-b43c-367f95d2fde9', '94b2525f-93bc-5dbc-95a6-31f2387b298d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('674308b9-bc5c-56b5-aedd-3d8c3a1f627d', '94b2525f-93bc-5dbc-95a6-31f2387b298d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e8f68762-782d-5dbf-b857-d836b2109bc4', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cotton growing was expected to raise more money than other crop.
2
Some of the local agro-chemical dealers had been farmers in the past.
3
Initially the farmers’ cotton yields were low.
4
At first, the farmers failed to notice the negative effects on their fields of pesticide use.

2 ____ Some of the local agro-chemical dealers had been farmers in the past.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('041a9b86-c373-544e-8fe1-b8318af538de', 'e8f68762-782d-5dbf-b857-d836b2109bc4', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5c45b5e-f6e6-5760-b669-f6227097732e', 'e8f68762-782d-5dbf-b857-d836b2109bc4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38e53927-cf71-5a25-b8cd-f911b7a0e527', 'e8f68762-782d-5dbf-b857-d836b2109bc4', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('711d24db-f46f-59d8-b119-6bedeeec5a7d', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cotton growing was expected to raise more money than other crop.
2
Some of the local agro-chemical dealers had been farmers in the past.
3
Initially the farmers’ cotton yields were low.
4
At first, the farmers failed to notice the negative effects on their fields of pesticide use.

3 ____ Initially the farmers’ cotton yields were low.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4569b08c-ff88-55cc-bf0d-ce101a205001', '711d24db-f46f-59d8-b119-6bedeeec5a7d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af21b3aa-c95d-5ec4-b31f-c5bc12f78e34', '711d24db-f46f-59d8-b119-6bedeeec5a7d', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50371748-aff1-5e75-9342-d00aa29d19b3', '711d24db-f46f-59d8-b119-6bedeeec5a7d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('35be00e5-1284-55f8-8446-a1e1e1a40d19', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Cotton growing was expected to raise more money than other crop.
2
Some of the local agro-chemical dealers had been farmers in the past.
3
Initially the farmers’ cotton yields were low.
4
At first, the farmers failed to notice the negative effects on their fields of pesticide use.

4 ____ At first, the farmers failed to notice the negative effects on their fields of pesticide use.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d4634e2-0d98-5a85-a80a-1270fd52d195', '35be00e5-1284-55f8-8446-a1e1e1a40d19', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0e1b73a-8b34-5971-99f3-50d0bad87712', '35be00e5-1284-55f8-8446-a1e1e1a40d19', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2f5de48-de12-512e-9990-98c8168f4baf', '35be00e5-1284-55f8-8446-a1e1e1a40d19', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7fb31a26-8779-5a51-8670-a5550b0de949', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 5, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 5 -10 on your answer sheet.
Non-Pesticide-Management Programme
Developed with the aid of SECURE
Based on use of an
5
called neem
Neem contains many
6
that target plant-eating predators
Neem
Used as a pesticide
7
formed by grinding seeds
left
8
to soak in water
Sprayed regularly
Used as a pesticide and as a fertilizer
added in
9
form to soil
contains a lot of
10

Based on use of an 5 ____ called neem$md$, NULL, ARRAY['.*evergreen.*tree.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5dd71a44-ac27-5424-ada6-2939744867a5', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 5 -10 on your answer sheet.
Non-Pesticide-Management Programme
Developed with the aid of SECURE
Based on use of an
5
called neem
Neem contains many
6
that target plant-eating predators
Neem
Used as a pesticide
7
formed by grinding seeds
left
8
to soak in water
Sprayed regularly
Used as a pesticide and as a fertilizer
added in
9
form to soil
contains a lot of
10

Neem contains many 6 ____ that target plant-eating predators$md$, NULL, ARRAY['.*natural.*pesticides.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('57737e04-d4d7-51a2-a8d7-9e25bae36882', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 5 -10 on your answer sheet.
Non-Pesticide-Management Programme
Developed with the aid of SECURE
Based on use of an
5
called neem
Neem contains many
6
that target plant-eating predators
Neem
Used as a pesticide
7
formed by grinding seeds
left
8
to soak in water
Sprayed regularly
Used as a pesticide and as a fertilizer
added in
9
form to soil
contains a lot of
10

7 ____ formed by grinding seeds$md$, NULL, ARRAY['.*a.*powder.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ef7fee99-920e-58b1-b616-790115e9cf75', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 5 -10 on your answer sheet.
Non-Pesticide-Management Programme
Developed with the aid of SECURE
Based on use of an
5
called neem
Neem contains many
6
that target plant-eating predators
Neem
Used as a pesticide
7
formed by grinding seeds
left
8
to soak in water
Sprayed regularly
Used as a pesticide and as a fertilizer
added in
9
form to soil
contains a lot of
10

left 8 ____ to soak in water$md$, NULL, ARRAY['.*overnight.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('159d5aa2-8c92-562b-9387-eced787c4bc4', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 5 -10 on your answer sheet.
Non-Pesticide-Management Programme
Developed with the aid of SECURE
Based on use of an
5
called neem
Neem contains many
6
that target plant-eating predators
Neem
Used as a pesticide
7
formed by grinding seeds
left
8
to soak in water
Sprayed regularly
Used as a pesticide and as a fertilizer
added in
9
form to soil
contains a lot of
10

added in 9 ____ form to soil$md$, NULL, ARRAY['.*cake.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('36275e0b-533d-500b-b0f0-424a4a8f1b51', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Complete the notes below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 5 -10 on your answer sheet.
Non-Pesticide-Management Programme
Developed with the aid of SECURE
Based on use of an
5
called neem
Neem contains many
6
that target plant-eating predators
Neem
Used as a pesticide
7
formed by grinding seeds
left
8
to soak in water
Sprayed regularly
Used as a pesticide and as a fertilizer
added in
9
form to soil
contains a lot of
10

contains a lot of 10 ____$md$, NULL, ARRAY['.*nitrogen.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('65ceb1c0-6978-5f27-8b39-186c70536d8d', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Choose NO MORE THAN TWO WORDS AND/OR A NUMBER from the
passage for each answer. Write your answers in boxes 11 -13 on your answer sheet.
11 .In which year did farmers finally stop using chemicals on cotton crops in Punukula?
11
What did the women of Punukula collect to make money?
12
What project do the authorities in Punukula hope to set up in the future?
13

11 .In which year did farmers finally stop using chemicals on cotton crops in Punukula? 11 ____$md$, NULL, ARRAY['.*2000.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0357769d-ae02-54a5-aba7-65c84a6340cc', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Choose NO MORE THAN TWO WORDS AND/OR A NUMBER from the
passage for each answer. Write your answers in boxes 11 -13 on your answer sheet.
11 .In which year did farmers finally stop using chemicals on cotton crops in Punukula?
11
What did the women of Punukula collect to make money?
12
What project do the authorities in Punukula hope to set up in the future?
13

What did the women of Punukula collect to make money? 12 ____$md$, NULL, ARRAY['.*neem.*seeds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('89b9fc96-c58e-587a-b8c4-093d5f4ac3a9', '0b457673-6878-5b5e-a6ae-5fc7dbea72aa', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Choose NO MORE THAN TWO WORDS AND/OR A NUMBER from the
passage for each answer. Write your answers in boxes 11 -13 on your answer sheet.
11 .In which year did farmers finally stop using chemicals on cotton crops in Punukula?
11
What did the women of Punukula collect to make money?
12
What project do the authorities in Punukula hope to set up in the future?
13

What project do the authorities in Punukula hope to set up in the future? 13 ____$md$, NULL, ARRAY['.*water.*purification.*']);

COMMIT;
