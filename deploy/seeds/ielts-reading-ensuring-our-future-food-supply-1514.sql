BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ensuring-our-future-food-supply-1514'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ensuring-our-future-food-supply-1514';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ensuring-our-future-food-supply-1514';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-ensuring-our-future-food-supply-1514';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('264660f8-aaa3-584a-a2c7-f22a8d47783b', 'ielts-reading-ensuring-our-future-food-supply-1514', $t$Ensuring our future food supply$t$, $md$## Ensuring our future food supply

Nguồn:
- Test: https://mini-ielts.com/1514/reading/ensuring-our-future-food-supply
- Solution: https://mini-ielts.com/1514/view-solution/reading/ensuring-our-future-food-supply$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1336069e-6bcd-57d1-9fd8-261709f7aec5', '264660f8-aaa3-584a-a2c7-f22a8d47783b', 1, $t$Reading — Ensuring our future food supply$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Ensuring our future food supply

Climate change and new diseases threaten the limited varieties of seeds we depend on for food. Luckily, we still have many of the seeds used in the past-but we must take steps to save them.

Six miles outside the town of Decorah, Iowa in the USA, an 890-acre stretch of rolling fields and woods called Heritage Farm is letting its crops go to seed. Everything about Heritage Farm is in stark contrast to the surrounding acres of intensively farmed fields of corn and soybean that are typical of modern agriculture. Heritage Farm is devoted to collecting rather than growing seeds. It is home to the Seed Savers Exchange, one of the largest non government-owned seed banks in the United States.

In 1975 Diane Ott Whealy was given the seedlings of two plant varieties that her great grandfather had brought to America from Bavaria in 1870: Grandpa Ott’s morning glory and his German Pink tomato. Wanting to preserve similar traditional varieties, known as heirloom plants, Diane and her husband, Kent, decided to establish a place where the seeds of the past could be kept and traded. The exchange now has more than 13,000 members, and the many thousands of heirloom varieties they have donated are kept in its walk-in coolers, freezers, and root cellars the seeds of many thousands of heirloom varieties and, as you walk around an old red barn that is covered in Grandpa Ott’s beautiful morning glory blossoms, you come across the different vegetables, herbs, and flowers they have planted there.

"Each year our members list their seeds in this,"Diane Ott Whealy says, handing over a copy of the Seed Savers Exchange 2010 Yearbook. It is as thick as a big-city telephone directory, with page after page of exotic beans, garlic, potatoes, peppers, apples, pears, and plums-each with its own name and personal history .For example, there’s an Estonian Yellow Cherry tomato, which was brought to the seed bank by “an elderly Russian lady” who lived in Tallinn, and a Persian Star garlic from “a bazaar in Samarkand.”There’s also a bean donated by archaeologists searching for pygmy elephant fossils in New Mexico.

Heirloom vegetables have become fashionable in the United States and Europe over the past decade, prized by a food movement that emphasizes eating locally and preserving the flavor and uniqueness of heirloom varieties. Found mostly in farmers' markets and boutique groceries, heirloom varieties have been squeezed out of supermarkets in favor of modern single-variety fruits and vegetables bred to ship well and have a uniform appearance, not to enhance flavor. But the movement to preserve heirloom varieties goes way beyond the current interest in North America and Europe in tasty, locally grown food. It’s also a campaign to protect the world’s future food supply.Most people in the well-fed world give little thought to where their food comes from or how it’s grown. They wander through well-stocked supermarkets without realizing that there may be problem ahead.We’ve been hearing for some time about the loss of flora and fauna in our rainforests.Very little,by contrast,is being said or done about the parallel decline in the diversity of the foods we eat.

Food variety extinction is happening all over the world - and it's happening fast. In the United States an estimated 90 percent of historic fruit and vegetable varieties are no longer grown. Of the 7,000 different apple varieties that were grown in the 1800s, fewer than a hundred remain. In the Philippines thousands of varieties of rice once thrived; now only about a hundred are grown there. In China 90 percent of the wheat varieties cultivated just a hundred years ago have disappeared. Experts estimate that in total we have lost more than 50 percent of the world's food varieties over the past century.

Why is this a problem? Because if disease or future climate change affects one of the handful of plants we've come to depend on to feed our growing planet, we might desperately need one of those varieties we've let become extinct. The loss of the world's cereal diversity is a particular cause for concern. A fungus called Ug99, which was first identified in Uganda in 1999, is spreading across the world's wheat crops. From Uganda it moved to Kenya, Ethiopia, Sudan, and Yemen. By 2007 it had jumped the Persian Gulf into Iran. Scientists predict that the fungus will soon make its way into India and Pakistan, then spread to Russia and China, and eventually the USA.

Roughly 90 percent of the world's wheat has no defense against this particular fungus. If it reached the USA, an estimated one billion dollars' worth of crops would be at risk. Scientists believe that in Asia and Africa alone, the portion currently in danger could leave one billion people without their primary food source. A famine with significant humanitarian consequences could follow, according to Rick Ward of Cornell University.

The population of the world is expected to reach nine billion by 2045. Some experts say we’ll need to double our food production to keep up with this growth. Given the added challenge of climate change and disease, it is becoming ever more urgent to find ways to increase food yield. The world has become increasingly dependent upon a technology-driven, one-size-fits-all approach to food supply. Yet the best hope for securing our food's future may depend on our ability to preserve the locally cultivated foods of the past.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('58d434c8-52bb-5910-b5f7-e9aa8dcd1764', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Do the following statements agree with the views of the writer in Reading Passage? In boxes 1 -7 on your answer sheet, write.
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Heritage Farm is different from most other nearby farms.
2
Most nongovernment-owned seed banks are bigger than Seed Savers Exchange.
3
Diane Ott Whealy's grandfather taught her a lot about seed varieties.
4
The seeds people give to the Seed Savers Exchange are stored outdoors.
5
Diane and her husband choose which heirloom seeds to grow on Heritage Farm.
6
The seeds are listed in alphabetical order in The Seed Savers Exchange Yearbook.
7
The Seed Savers Exchange Yearbook describes how each seed was obtained.

1 ____ Heritage Farm is different from most other nearby farms.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('117faa87-0a79-5066-b38d-bf51983c411a', '58d434c8-52bb-5910-b5f7-e9aa8dcd1764', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59c0978f-9285-5085-9bf7-1fa9da8a251d', '58d434c8-52bb-5910-b5f7-e9aa8dcd1764', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27173c42-9f9e-5586-a0cf-8890698b4143', '58d434c8-52bb-5910-b5f7-e9aa8dcd1764', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aaf7dce2-d5c0-577b-ad2b-9e9287e68666', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Do the following statements agree with the views of the writer in Reading Passage? In boxes 1 -7 on your answer sheet, write.
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Heritage Farm is different from most other nearby farms.
2
Most nongovernment-owned seed banks are bigger than Seed Savers Exchange.
3
Diane Ott Whealy's grandfather taught her a lot about seed varieties.
4
The seeds people give to the Seed Savers Exchange are stored outdoors.
5
Diane and her husband choose which heirloom seeds to grow on Heritage Farm.
6
The seeds are listed in alphabetical order in The Seed Savers Exchange Yearbook.
7
The Seed Savers Exchange Yearbook describes how each seed was obtained.

2 ____ Most nongovernment-owned seed banks are bigger than Seed Savers Exchange.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a59475a-b20f-5fdc-a07a-db922cdc2892', 'aaf7dce2-d5c0-577b-ad2b-9e9287e68666', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('134d980f-7ad8-590c-8fc5-72afdb98a265', 'aaf7dce2-d5c0-577b-ad2b-9e9287e68666', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65fd5a03-1b5a-51d9-82a2-30a1147530aa', 'aaf7dce2-d5c0-577b-ad2b-9e9287e68666', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('160fcf07-3362-5000-ab0f-8956ca9cba76', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Do the following statements agree with the views of the writer in Reading Passage? In boxes 1 -7 on your answer sheet, write.
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Heritage Farm is different from most other nearby farms.
2
Most nongovernment-owned seed banks are bigger than Seed Savers Exchange.
3
Diane Ott Whealy's grandfather taught her a lot about seed varieties.
4
The seeds people give to the Seed Savers Exchange are stored outdoors.
5
Diane and her husband choose which heirloom seeds to grow on Heritage Farm.
6
The seeds are listed in alphabetical order in The Seed Savers Exchange Yearbook.
7
The Seed Savers Exchange Yearbook describes how each seed was obtained.

3 ____ Diane Ott Whealy's grandfather taught her a lot about seed varieties.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('353a1e82-f3d6-556b-8beb-0aa1f9ca66e3', '160fcf07-3362-5000-ab0f-8956ca9cba76', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73d6b1a3-ef94-59d0-93cd-eee4a9f4e389', '160fcf07-3362-5000-ab0f-8956ca9cba76', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc06f5a8-a9c6-5bed-82b6-b0a2aefd0641', '160fcf07-3362-5000-ab0f-8956ca9cba76', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4052e865-4504-50dd-b2cb-09f700ebcb91', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Do the following statements agree with the views of the writer in Reading Passage? In boxes 1 -7 on your answer sheet, write.
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Heritage Farm is different from most other nearby farms.
2
Most nongovernment-owned seed banks are bigger than Seed Savers Exchange.
3
Diane Ott Whealy's grandfather taught her a lot about seed varieties.
4
The seeds people give to the Seed Savers Exchange are stored outdoors.
5
Diane and her husband choose which heirloom seeds to grow on Heritage Farm.
6
The seeds are listed in alphabetical order in The Seed Savers Exchange Yearbook.
7
The Seed Savers Exchange Yearbook describes how each seed was obtained.

4 ____ The seeds people give to the Seed Savers Exchange are stored outdoors.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5268206-c215-5bb5-b21e-71c9b0a5f37a', '4052e865-4504-50dd-b2cb-09f700ebcb91', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1f52419-9ed2-5e1a-9daa-d8da2edf1f0b', '4052e865-4504-50dd-b2cb-09f700ebcb91', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad64fe0e-2968-521f-8de1-6dfff25f3321', '4052e865-4504-50dd-b2cb-09f700ebcb91', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0758256c-82e1-563c-920c-0203fbbfef33', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Do the following statements agree with the views of the writer in Reading Passage? In boxes 1 -7 on your answer sheet, write.
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Heritage Farm is different from most other nearby farms.
2
Most nongovernment-owned seed banks are bigger than Seed Savers Exchange.
3
Diane Ott Whealy's grandfather taught her a lot about seed varieties.
4
The seeds people give to the Seed Savers Exchange are stored outdoors.
5
Diane and her husband choose which heirloom seeds to grow on Heritage Farm.
6
The seeds are listed in alphabetical order in The Seed Savers Exchange Yearbook.
7
The Seed Savers Exchange Yearbook describes how each seed was obtained.

5 ____ Diane and her husband choose which heirloom seeds to grow on Heritage Farm.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d44c563-8aee-5bd3-98d3-d4b071735e6d', '0758256c-82e1-563c-920c-0203fbbfef33', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6adbc77e-b010-5f61-96bf-717d76a20000', '0758256c-82e1-563c-920c-0203fbbfef33', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ecb0961-6874-5c5c-9fab-ba7533e769f2', '0758256c-82e1-563c-920c-0203fbbfef33', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('83fa8fa8-54e9-5811-8d18-8b9bba5b317f', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Do the following statements agree with the views of the writer in Reading Passage? In boxes 1 -7 on your answer sheet, write.
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Heritage Farm is different from most other nearby farms.
2
Most nongovernment-owned seed banks are bigger than Seed Savers Exchange.
3
Diane Ott Whealy's grandfather taught her a lot about seed varieties.
4
The seeds people give to the Seed Savers Exchange are stored outdoors.
5
Diane and her husband choose which heirloom seeds to grow on Heritage Farm.
6
The seeds are listed in alphabetical order in The Seed Savers Exchange Yearbook.
7
The Seed Savers Exchange Yearbook describes how each seed was obtained.

6 ____ The seeds are listed in alphabetical order in The Seed Savers Exchange Yearbook.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d0f36f5-7c3c-5385-94bf-fc007a867997', '83fa8fa8-54e9-5811-8d18-8b9bba5b317f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c4dd5cb-5b31-5c11-a94f-c5fc3ee7f4e6', '83fa8fa8-54e9-5811-8d18-8b9bba5b317f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b10260b7-7101-5f70-944e-6854ac0c7f91', '83fa8fa8-54e9-5811-8d18-8b9bba5b317f', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('db58ba27-192a-58f6-b42a-2e9f1a643034', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Do the following statements agree with the views of the writer in Reading Passage? In boxes 1 -7 on your answer sheet, write.
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Heritage Farm is different from most other nearby farms.
2
Most nongovernment-owned seed banks are bigger than Seed Savers Exchange.
3
Diane Ott Whealy's grandfather taught her a lot about seed varieties.
4
The seeds people give to the Seed Savers Exchange are stored outdoors.
5
Diane and her husband choose which heirloom seeds to grow on Heritage Farm.
6
The seeds are listed in alphabetical order in The Seed Savers Exchange Yearbook.
7
The Seed Savers Exchange Yearbook describes how each seed was obtained.

7 ____ The Seed Savers Exchange Yearbook describes how each seed was obtained.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09dc568d-7dfb-5799-928b-f2de362cd798', 'db58ba27-192a-58f6-b42a-2e9f1a643034', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ff973a0-16b6-5395-b822-8ecb30b18fcb', 'db58ba27-192a-58f6-b42a-2e9f1a643034', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3c64566-1dda-50e0-8d01-1f922c14462c', 'db58ba27-192a-58f6-b42a-2e9f1a643034', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1551354e-27ed-588c-b5c0-dd8d4affa325', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
The food we grow and eat
Supermarkets
sell fruit and vegetables that transport well
want fruit and vegetables to be standard in their
8
Public awareness
while people know about plants disappearing from
9
very few know about the decline in fruit and vegetable varieties
Extinction of food varieties
less than 100 of the types of
10
once available in the USA are still grown
over
11
of food varieties around the world have disappeared in the last 100 years
Current problems in food production
a particular fungus is attacking wheat in various countries
Rick Ward believes the threat to food supplies in Asia and Africa might lead to a
12
Food production in the future
climate change and disease may put pressure on food production
twice the amount of food
may be needed because of an
increase
in
13

want fruit and vegetables to be standard in their 8 ____$md$, NULL, ARRAY['.*appearance.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('be88a706-2589-5ff1-be21-6ff87d5aebab', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
The food we grow and eat
Supermarkets
sell fruit and vegetables that transport well
want fruit and vegetables to be standard in their
8
Public awareness
while people know about plants disappearing from
9
very few know about the decline in fruit and vegetable varieties
Extinction of food varieties
less than 100 of the types of
10
once available in the USA are still grown
over
11
of food varieties around the world have disappeared in the last 100 years
Current problems in food production
a particular fungus is attacking wheat in various countries
Rick Ward believes the threat to food supplies in Asia and Africa might lead to a
12
Food production in the future
climate change and disease may put pressure on food production
twice the amount of food
may be needed because of an
increase
in
13

while people know about plants disappearing from 9 ____ very few know about the decline in fruit and vegetable varieties$md$, NULL, ARRAY['.*rainforests.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c4ee8b8f-020c-58e2-90d6-2f89363b7e5b', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
The food we grow and eat
Supermarkets
sell fruit and vegetables that transport well
want fruit and vegetables to be standard in their
8
Public awareness
while people know about plants disappearing from
9
very few know about the decline in fruit and vegetable varieties
Extinction of food varieties
less than 100 of the types of
10
once available in the USA are still grown
over
11
of food varieties around the world have disappeared in the last 100 years
Current problems in food production
a particular fungus is attacking wheat in various countries
Rick Ward believes the threat to food supplies in Asia and Africa might lead to a
12
Food production in the future
climate change and disease may put pressure on food production
twice the amount of food
may be needed because of an
increase
in
13

less than 100 of the types of 10 ____ once available in the USA are still grown$md$, NULL, ARRAY['.*apples.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ddae1150-4afb-5de9-b64e-f98c1f8d49f6', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
The food we grow and eat
Supermarkets
sell fruit and vegetables that transport well
want fruit and vegetables to be standard in their
8
Public awareness
while people know about plants disappearing from
9
very few know about the decline in fruit and vegetable varieties
Extinction of food varieties
less than 100 of the types of
10
once available in the USA are still grown
over
11
of food varieties around the world have disappeared in the last 100 years
Current problems in food production
a particular fungus is attacking wheat in various countries
Rick Ward believes the threat to food supplies in Asia and Africa might lead to a
12
Food production in the future
climate change and disease may put pressure on food production
twice the amount of food
may be needed because of an
increase
in
13

over 11 ____ of food varieties around the world have disappeared in the last 100 years$md$, NULL, ARRAY['.*50.*percent.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('603ea779-a769-5746-a279-2e81e22b3e13', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
The food we grow and eat
Supermarkets
sell fruit and vegetables that transport well
want fruit and vegetables to be standard in their
8
Public awareness
while people know about plants disappearing from
9
very few know about the decline in fruit and vegetable varieties
Extinction of food varieties
less than 100 of the types of
10
once available in the USA are still grown
over
11
of food varieties around the world have disappeared in the last 100 years
Current problems in food production
a particular fungus is attacking wheat in various countries
Rick Ward believes the threat to food supplies in Asia and Africa might lead to a
12
Food production in the future
climate change and disease may put pressure on food production
twice the amount of food
may be needed because of an
increase
in
13

Rick Ward believes the threat to food supplies in Asia and Africa might lead to a 12 ____$md$, NULL, ARRAY['.*famine.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b893d39c-68c6-5ef6-8c74-7b6c3a928a78', '1336069e-6bcd-57d1-9fd8-261709f7aec5', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Complete the notes below.
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer. Write your answers in boxes 8-13 on your answer sheet.
The food we grow and eat
Supermarkets
sell fruit and vegetables that transport well
want fruit and vegetables to be standard in their
8
Public awareness
while people know about plants disappearing from
9
very few know about the decline in fruit and vegetable varieties
Extinction of food varieties
less than 100 of the types of
10
once available in the USA are still grown
over
11
of food varieties around the world have disappeared in the last 100 years
Current problems in food production
a particular fungus is attacking wheat in various countries
Rick Ward believes the threat to food supplies in Asia and Africa might lead to a
12
Food production in the future
climate change and disease may put pressure on food production
twice the amount of food
may be needed because of an
increase
in
13

twice the amount of food may be needed because of an increase in 13 ____$md$, NULL, ARRAY['.*population.*']);

COMMIT;
