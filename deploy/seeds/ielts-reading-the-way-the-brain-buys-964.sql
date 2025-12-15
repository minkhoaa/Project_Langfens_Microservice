BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-way-the-brain-buys-964'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-way-the-brain-buys-964';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-way-the-brain-buys-964';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-way-the-brain-buys-964';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('23990feb-a7b7-5819-b77f-e04f2d9d978e', 'ielts-reading-the-way-the-brain-buys-964', $t$The way the brain buys$t$, $md$## The way the brain buys

Nguồn:
- Test: https://mini-ielts.com/964/reading/the-way-the-brain-buys
- Solution: https://mini-ielts.com/964/view-solution/reading/the-way-the-brain-buys$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6cc24698-dbce-5274-abfa-959dbdfac8b5', '23990feb-a7b7-5819-b77f-e04f2d9d978e', 1, $t$Reading — The way the brain buys$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The way the brain buys

Supermarkets take great care over the way the goods they sell are arranged. This is because they know a lot about how to persuade people to buy things.

When yon enter a supermarket, it takes some time for the mind to get into a shopping mode. This is why the area immediately inside the entrance of a supermarket is known as the ‘decompression zone’. People need to slow down and take stock of the surroundings, even if they are regulars. Supermarkets do not expect to sell much here, so it tends to be used more for promotion . So the large items piled up here are designed to suggest that there are bargains further inside the store, and shoppers are not necessarily expected to buy them. Walmart, the world’s biggest retailer, famously employs ‘greeters’ at the entrance to its stores. A friendly welcome is said to cut shoplifting. It is harder to steal from nice people.

Immediately to the left in many supermarkets is a ‘chill zone’, where customers can enjoy browsing magazines, books and DVDs. This is intended to tempt unplanned purchases and slow customers down. But people who just want to do their shopping quickly will keep walking ahead, and the first thing they come to is the fresh fruit and vegetables section. However, for shoppers, this makes no sense. Fruit and vegetables can be easily damaged, so they should be bought at the end , not the beginning, of a shopping trip. But psychology is at work here: selecting these items makes people feel good, so they feel less guilty about reaching for less healthy food later on .

Shoppers already know that everyday items, like milk, arc invariably placed towards the back of a store to provide more opportunity to tempt customers to buy things which are not on their shopping list. This is why pharmacies are also generally at the back. But supermarkets know shoppers know this, so they use other tricks, like placing popular items halfway along a section so that people have to walk all along the aisle looking for them. The idea is to boost ‘dwell time’: the length of time people spend in a store.

Having walked to the end of the fruit-and-vegetable aisle, shoppers arrive at counters of prepared food, the fishmonger, the butcher and the deli. Then there is the in-store bakery, which can be smelt before it is seen. Even small supermarkets now use in store bakeries. Mostly these bake pre-prepared items and frozen ingredients which have been delivered to the supermarket previously, and their numbers have increased, even though central bakeries that deliver to a number of stores are much more efficient. They do it for the smell of freshly baked bread, which arouses people’s appetites and thus encourages them to purchase not just bread but also other food, including ready meals .

Retailers and producers talk a lot about the ‘moment of truth’. This is not a philosophical idea, but the point when people standing in the aisle decide to buy something and reach to get it. At the instant coffee section, for example, branded products from the big producers are arranged at eye level while cheaper ones are lower down, along with the supermarket’s own label products.

But shelf positioning is fiercely fought over, not just by those trying to sell goods, but also by those arguing over how best to manipulate shoppers. While many stores reckon eye level is the top spot, some think a little higher is better. Others think goods displayed at the end of aisles sell the most because they have the greatest visibility. To be on the right-hand side of an eye-level selection is often considered the very best place, because most people are right-handed and most people’s eyes drift rightwards. Some supermarkets reserve that for their most expensive own-label goods.

Scott Bearse, a retail expert with Deloitte Consulting in Boston, Massachusetts, has led projects observing and questioning tens of thousands of customers about how they feel about shopping. People say they leave shops empty- handed more often because they are ‘unable to decide’ than because prices are too high , says Mr Bearse. Getting customers to try something is one of the best ways of getting them to buy, adds Mr Bearse. Deloitte found that customers who use fitting rooms in order to try on clothes buy the product they are considering at a rate of 8 j% compared with 58 % for those that do not do so.

Often a customer struggling to decide which of two items is best ends up not buying either. In order to avoid a situation where a customer decides not to buy either product, a third ‘decoy’ item, which is not quite as good as the other two, is placed beside them to make the choice easier and more pleasurable . Happier customers are more likely to buy.

adapted from The Economis$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('330d0236-8ae9-5704-914b-39427da0c185', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 1, 'SHORT_ANSWER', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Label the diagram below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Layout of typical supermarket
1
Locate
2
Locate
3
Locate
4
Locate

1 ____ Locate$md$, NULL, ARRAY['.*promotion.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2bde746c-d31b-5bf5-8eca-7ed4249345d3', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 2, 'SHORT_ANSWER', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Label the diagram below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Layout of typical supermarket
1
Locate
2
Locate
3
Locate
4
Locate

2 ____ Locate$md$, NULL, ARRAY['.*unplanned.*purchases.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('83aba7be-b90b-54cf-924a-6300dc2e9f5b', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 3, 'SHORT_ANSWER', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Label the diagram below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Layout of typical supermarket
1
Locate
2
Locate
3
Locate
4
Locate

3 ____ Locate$md$, NULL, ARRAY['.*fruit.*and.*vegetables.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('064278f9-1b0a-50b2-8318-682343b2a89b', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 4, 'SHORT_ANSWER', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Label the diagram below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Layout of typical supermarket
1
Locate
2
Locate
3
Locate
4
Locate

4 ____ Locate$md$, NULL, ARRAY['.*popular.*items.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('42738749-4d09-5e45-aa58-29141f52e478', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Do the following statements agree with the
information given in the reading passage?
Write
TRUE
if the statement agrees with the
information
FALSE
if the statement contradicts the
information
NOT GIVEN
if there is no information on this
5
The ‘greeters’ at Walmart increase sales.
6
People feel better about their shopping if they buy fruit and vegetables before they buy other food.
Locate
7
In-store bakeries produce a wider range of products than central bakeries.
8
Supermarkets find right-handed people easier to persuade than left-handed people.
9
The most frequent reason for leaving shops without buying something is price.
Locate
10
‘Decoy’ items are products which the store expects customers to choose.
Locate

5 ____ The ‘greeters’ at Walmart increase sales.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6dc20f2c-b84a-541d-a67f-6af3867f51e9', '42738749-4d09-5e45-aa58-29141f52e478', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3054d077-aeca-5056-ad7d-ad81421e31de', '42738749-4d09-5e45-aa58-29141f52e478', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56b9570f-ed50-549e-91c6-dc2add153795', '42738749-4d09-5e45-aa58-29141f52e478', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('db171ef2-4678-56fb-960b-dea2ebcdf459', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Do the following statements agree with the
information given in the reading passage?
Write
TRUE
if the statement agrees with the
information
FALSE
if the statement contradicts the
information
NOT GIVEN
if there is no information on this
5
The ‘greeters’ at Walmart increase sales.
6
People feel better about their shopping if they buy fruit and vegetables before they buy other food.
Locate
7
In-store bakeries produce a wider range of products than central bakeries.
8
Supermarkets find right-handed people easier to persuade than left-handed people.
9
The most frequent reason for leaving shops without buying something is price.
Locate
10
‘Decoy’ items are products which the store expects customers to choose.
Locate

6 ____ People feel better about their shopping if they buy fruit and vegetables before they buy other food. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd201a78-8ec4-5d50-9063-00b70dba33ae', 'db171ef2-4678-56fb-960b-dea2ebcdf459', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fe4c297-5f49-5256-94a8-afb72d726d56', 'db171ef2-4678-56fb-960b-dea2ebcdf459', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8b22789-e9e7-586c-80eb-4e6abb9ffd93', 'db171ef2-4678-56fb-960b-dea2ebcdf459', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('543070b4-149c-50a7-9ba7-273ee252b833', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Do the following statements agree with the
information given in the reading passage?
Write
TRUE
if the statement agrees with the
information
FALSE
if the statement contradicts the
information
NOT GIVEN
if there is no information on this
5
The ‘greeters’ at Walmart increase sales.
6
People feel better about their shopping if they buy fruit and vegetables before they buy other food.
Locate
7
In-store bakeries produce a wider range of products than central bakeries.
8
Supermarkets find right-handed people easier to persuade than left-handed people.
9
The most frequent reason for leaving shops without buying something is price.
Locate
10
‘Decoy’ items are products which the store expects customers to choose.
Locate

7 ____ In-store bakeries produce a wider range of products than central bakeries.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bc043d2-b3c7-5a17-b0c6-24737ecee0b7', '543070b4-149c-50a7-9ba7-273ee252b833', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd23447a-ed3e-533a-94c0-32eb74035771', '543070b4-149c-50a7-9ba7-273ee252b833', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ea45140-ff2f-570c-accd-e89b6d7a9e82', '543070b4-149c-50a7-9ba7-273ee252b833', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4196d732-d94a-50f2-81af-212e3f4f9bcd', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Do the following statements agree with the
information given in the reading passage?
Write
TRUE
if the statement agrees with the
information
FALSE
if the statement contradicts the
information
NOT GIVEN
if there is no information on this
5
The ‘greeters’ at Walmart increase sales.
6
People feel better about their shopping if they buy fruit and vegetables before they buy other food.
Locate
7
In-store bakeries produce a wider range of products than central bakeries.
8
Supermarkets find right-handed people easier to persuade than left-handed people.
9
The most frequent reason for leaving shops without buying something is price.
Locate
10
‘Decoy’ items are products which the store expects customers to choose.
Locate

8 ____ Supermarkets find right-handed people easier to persuade than left-handed people.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7aea16b2-ab13-593a-a35f-df61942951d3', '4196d732-d94a-50f2-81af-212e3f4f9bcd', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('154c6a23-687e-5eb4-a57d-cef7e8c5cad1', '4196d732-d94a-50f2-81af-212e3f4f9bcd', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f5014a6-5e19-5cd5-82b5-01cb41a2f5a0', '4196d732-d94a-50f2-81af-212e3f4f9bcd', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a4e08882-0398-5d36-9109-9d6fbb846289', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Do the following statements agree with the
information given in the reading passage?
Write
TRUE
if the statement agrees with the
information
FALSE
if the statement contradicts the
information
NOT GIVEN
if there is no information on this
5
The ‘greeters’ at Walmart increase sales.
6
People feel better about their shopping if they buy fruit and vegetables before they buy other food.
Locate
7
In-store bakeries produce a wider range of products than central bakeries.
8
Supermarkets find right-handed people easier to persuade than left-handed people.
9
The most frequent reason for leaving shops without buying something is price.
Locate
10
‘Decoy’ items are products which the store expects customers to choose.
Locate

9 ____ The most frequent reason for leaving shops without buying something is price. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1b28477-d63c-526d-886b-f1005d5460bb', 'a4e08882-0398-5d36-9109-9d6fbb846289', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30ab0d6a-ed7d-57d9-8c9f-20d5babddf48', 'a4e08882-0398-5d36-9109-9d6fbb846289', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f2938ca-5d26-555d-b597-ebbd62b0c3e1', 'a4e08882-0398-5d36-9109-9d6fbb846289', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c0ea25b0-c2b5-53c7-b6a0-42e575df0d66', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Do the following statements agree with the
information given in the reading passage?
Write
TRUE
if the statement agrees with the
information
FALSE
if the statement contradicts the
information
NOT GIVEN
if there is no information on this
5
The ‘greeters’ at Walmart increase sales.
6
People feel better about their shopping if they buy fruit and vegetables before they buy other food.
Locate
7
In-store bakeries produce a wider range of products than central bakeries.
8
Supermarkets find right-handed people easier to persuade than left-handed people.
9
The most frequent reason for leaving shops without buying something is price.
Locate
10
‘Decoy’ items are products which the store expects customers to choose.
Locate

10 ____ ‘Decoy’ items are products which the store expects customers to choose. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('474154d3-092c-5e8d-8f23-4ea066ae2619', 'c0ea25b0-c2b5-53c7-b6a0-42e575df0d66', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e338e4f4-307c-591c-8500-6e99036dbaa5', 'c0ea25b0-c2b5-53c7-b6a0-42e575df0d66', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80bbd3ca-8cf3-54b1-ae84-a31e56240dd7', 'c0ea25b0-c2b5-53c7-b6a0-42e575df0d66', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('978e1a85-d657-5fba-b015-1338db9f15bc', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the flow chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
In-store bread production process
The supermarket is sent
11
and other items which have been prepared earlier.
Locate
Baking bread in-store produces an aroma.
Shoppers’
12
are stimulated.
Locate
They are then keener to buy food, including bread and
13
Locate

The supermarket is sent 11 ____ and other items which have been prepared earlier. Locate$md$, NULL, ARRAY['.*frozen.*ingredients.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fd2058db-909c-5968-8888-4158b2d85f18', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the flow chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
In-store bread production process
The supermarket is sent
11
and other items which have been prepared earlier.
Locate
Baking bread in-store produces an aroma.
Shoppers’
12
are stimulated.
Locate
They are then keener to buy food, including bread and
13
Locate

Shoppers’ 12 ____ are stimulated. Locate$md$, NULL, ARRAY['.*appetites.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b0aae883-e032-5f59-8152-dd5af0ae42ca', '6cc24698-dbce-5274-abfa-959dbdfac8b5', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the flow chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
In-store bread production process
The supermarket is sent
11
and other items which have been prepared earlier.
Locate
Baking bread in-store produces an aroma.
Shoppers’
12
are stimulated.
Locate
They are then keener to buy food, including bread and
13
Locate

They are then keener to buy food, including bread and 13 ____ Locate$md$, NULL, ARRAY['.*ready.*meals.*']);

COMMIT;
