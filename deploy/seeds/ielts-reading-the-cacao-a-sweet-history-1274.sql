BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-cacao-a-sweet-history-1274'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-cacao-a-sweet-history-1274';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-cacao-a-sweet-history-1274';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-cacao-a-sweet-history-1274';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2cc6944a-f136-5a8e-bf9d-0f0e3ba09c81', 'ielts-reading-the-cacao-a-sweet-history-1274', $t$The Cacao: A Sweet history$t$, $md$## The Cacao: A Sweet history

Nguồn:
- Test: https://mini-ielts.com/1274/reading/the-cacao-a-sweet-history
- Solution: https://mini-ielts.com/1274/view-solution/reading/the-cacao-a-sweet-history$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('026f2189-2b79-5d52-afdb-7ebb759f0294', '2cc6944a-f136-5a8e-bf9d-0f0e3ba09c81', 1, $t$Reading — The Cacao: A Sweet history$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Cacao: A Sweet history

A Chapter 1

Most people today think of chocolate as something sweet to eat or drink that can be easily found in stores around the world. It might surprise you that chocolate was once highly treasured. The tasty secret of the cacao (Kah Kow) tree was discovered 2,000 years ago in the tropical rainforests of the Americas. The story of how chocolate grew from a local Mesoamerican beverage into a global sweet encompasses many cultures and continents.

B Chapter 2

Historians believe the Maya people of Central America first learned to farm cacao plants around two thousand years ago. The Maya took cacao trees from the rainforests and grew them in their gardens. They cooked cacao seeds, the crushed them into a soft paste. They mixed the paste with water and flavorful spices to make an unsweetened chocolate drink. The Maya poured the chocolate drink back and forth between two containers so that the liquid would have a layer of bubbles or foam.

Cacao and chocolate were an important part of Maya culture. There are often images of cacao plants on Maya buildings and art objects. Ruling families drank chocolate at special ceremonies. And, even poorer members of society could enjoy the drink once in a while. Historians believe that cacao seeds were also used in marriage ceremonies as a sign of the union between a husband and a wife.

The Aztec culture in current-day Mexico also prized chocolate. But, cacao plants could not grow in the area where the Aztecs lived. So, they traded to get cacao. They even used cacao seeds as a form of money to pay taxes. Chocolate also played a special role in both Maya and Aztec royal and religious events. Priests presented cacao seeds and offerings to the gods and served chocolate drinks during sacred ceremonies. Only the very wealthy in Aztec societies could afford to drink chocolate because cacao was so valuable. The Aztec ruler Montezuma was believed to drink fifty cups of chocolate every day. Some experts believe the word for chocolate came from the Aztec word “xocolatl” which in the Nahuatl language means “bitter water.” Others believe the word “chocolate” was created by combining Mayan and Nahuatl words.

C Chapter 3

The explorer Christopher Columbus brought cacao seeds to Spain after his trip to Central America in 1502. But it was the Spanish explorer Hernando Cortes who understood that chocolate could be a valuable investment. In 1519, Cortes arrived in current-day Mexico. He believed the chocolate drink would become popular with Spaniards. After the Spanish soldiers defeated the Aztec empire, they were able to seize the supplies of cacao and send them home. Spain later began planting cacao in its colonies in the Americans in order to satisfy the large demand for chocolate. The wealthy people of Spain first enjoyed a sweetened version of chocolate drink. Later, the popularity of the drink spread throughout Europe. The English, Dutch and French began to plant cacao trees in their own colonies. Chocolate remained a drink that only wealthy people could afford to drink until the eighteenth century. During the period known as the Industrial Revolution, new technologies helped make chocolate less costly to produce.

D Chapter 4

Farmers grow cacao trees in many countries in Africa, Central and South America. The trees grow in the shady areas of the rainforests near the Earth’s equator. But these trees can be difficult to grow. They require an exact amount of water, warmth, soil and protection. After about five years, cacao trees start producing large fruits called pods, which grow near the trunk of the tree. The seeds inside the pods are harvested to make chocolate. There are several kinds of cacao trees. Most of the world’s chocolate is made from the seed of the forastero tree. But farmers can also grow criollo or trinitario cacao plants. Cacao trees grown on farms are much more easily threatened by diseases and insects than wild trees. Growing cacao is very hard work for farmers. They sell their harvest on a futures market. This means that economic conditions beyond their control can affect the amount of money they will earn. Today, chocolate industry officials, activists, and scientists are working with farmers. They are trying to make sure that cacao can be grown in a way that is fair to the timers and safe for the environment.

E Chapter 5

To become chocolate, cacao seeds go through a long production process in a factory. Workers must sort, clean and cook the seeds. Then they break off the covering of the seeds so that only the inside fruit, or nibs, remain. Workers crush the nibs into a soft substance called chocolate liquor. This gets separated into cocoa solids and fat called cocoa butter. Chocolate makers have their own special recipes in which they combine chocolate liquor with exact amounts of sugar, milk and cocoa fat. They finely crush this “crumb” mixture in order to make it smooth. The mixture then goes through two more processes before it is shaped into a mold form.

Chocolate making is big business. The market value of the yearly cacao crop around the world is more than five billion dollars. Chocolate is especially popular in Europe and the United States. For example, in 2005, the United States bought 1.4 billion dollars worth of cocoa products. Each year, Americans eat an average of more than five kilograms of chocolate per person. Speciality shops that sell costly chocolates are also very popular. Many offer chocolate lovers the chance to taste chocolates grown in different areas of the world.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d3efad4d-39b2-522a-8cbd-aa6b9902381e', '026f2189-2b79-5d52-afdb-7ebb759f0294', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading passage 1 has 5 chapters. Which chapter contains the following information?
Write your answers in boxes
1-5
on your answer sheet
1
the part of cacao trees used to produce chocolate
2
average chocolate consumption by people in the US per person per year
3
risks faced by fanners in the cacao business
4
where the first sweetened chocolate drink appeared
5
how ancient American civilizations obtained cacao

1 ____ the part of cacao trees used to produce chocolate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6dbddd3-2499-5a22-a42a-d1e08550a11a', 'd3efad4d-39b2-522a-8cbd-aa6b9902381e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e547b522-f3a0-5321-838a-c5ce57d531d3', 'd3efad4d-39b2-522a-8cbd-aa6b9902381e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c76e345-1a2c-5827-a415-91e76211a012', 'd3efad4d-39b2-522a-8cbd-aa6b9902381e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80d10477-3ec6-5c3b-ab19-5b49aba283b3', 'd3efad4d-39b2-522a-8cbd-aa6b9902381e', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('520088a8-7467-50d1-a47c-44d008f7ca8c', 'd3efad4d-39b2-522a-8cbd-aa6b9902381e', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('48ee04a2-e4b9-5d9e-91cb-5743077516ed', '026f2189-2b79-5d52-afdb-7ebb759f0294', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading passage 1 has 5 chapters. Which chapter contains the following information?
Write your answers in boxes
1-5
on your answer sheet
1
the part of cacao trees used to produce chocolate
2
average chocolate consumption by people in the US per person per year
3
risks faced by fanners in the cacao business
4
where the first sweetened chocolate drink appeared
5
how ancient American civilizations obtained cacao

2 ____ average chocolate consumption by people in the US per person per year$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c5c6cfc-6d30-54fe-8f15-93f45fdcf863', '48ee04a2-e4b9-5d9e-91cb-5743077516ed', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad2a61ff-3713-50de-9549-baed596cc09f', '48ee04a2-e4b9-5d9e-91cb-5743077516ed', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c719c30e-cfea-55b7-84ca-22f7dd714ee1', '48ee04a2-e4b9-5d9e-91cb-5743077516ed', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2da002c8-2066-5977-93e5-77c57d3be904', '48ee04a2-e4b9-5d9e-91cb-5743077516ed', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('498f3e8e-bf9a-5bce-9533-5a58deb3c37f', '48ee04a2-e4b9-5d9e-91cb-5743077516ed', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ad509575-571d-5c02-a963-cf7c48aa5a49', '026f2189-2b79-5d52-afdb-7ebb759f0294', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading passage 1 has 5 chapters. Which chapter contains the following information?
Write your answers in boxes
1-5
on your answer sheet
1
the part of cacao trees used to produce chocolate
2
average chocolate consumption by people in the US per person per year
3
risks faced by fanners in the cacao business
4
where the first sweetened chocolate drink appeared
5
how ancient American civilizations obtained cacao

3 ____ risks faced by fanners in the cacao business$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14059ece-3759-5e80-8306-71d136a8f2fe', 'ad509575-571d-5c02-a963-cf7c48aa5a49', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('800f4103-0d2c-559e-9ae0-a6a1d34c1d51', 'ad509575-571d-5c02-a963-cf7c48aa5a49', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7849a3b0-b13a-55b8-ab3f-0e0a445bb3b3', 'ad509575-571d-5c02-a963-cf7c48aa5a49', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09e8f425-588c-5f55-b3bc-fed02f9cd02a', 'ad509575-571d-5c02-a963-cf7c48aa5a49', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ab8ad16-8a1c-5ce1-8c8b-2ca12db1f3a2', 'ad509575-571d-5c02-a963-cf7c48aa5a49', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('11835fcf-7564-5afb-9b8b-0353c5da955d', '026f2189-2b79-5d52-afdb-7ebb759f0294', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading passage 1 has 5 chapters. Which chapter contains the following information?
Write your answers in boxes
1-5
on your answer sheet
1
the part of cacao trees used to produce chocolate
2
average chocolate consumption by people in the US per person per year
3
risks faced by fanners in the cacao business
4
where the first sweetened chocolate drink appeared
5
how ancient American civilizations obtained cacao

4 ____ where the first sweetened chocolate drink appeared$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40995f31-bc87-5732-af0e-0c2d0b507d7d', '11835fcf-7564-5afb-9b8b-0353c5da955d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c2e64dc-7e59-5261-8c7c-1163b94809ca', '11835fcf-7564-5afb-9b8b-0353c5da955d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('260c733b-42c2-5c3e-b880-16c839068e2d', '11835fcf-7564-5afb-9b8b-0353c5da955d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5660442-2c15-527a-9bfc-9f770e467a9a', '11835fcf-7564-5afb-9b8b-0353c5da955d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1438fd84-f575-5f24-97b6-fc9e6db2e0dd', '11835fcf-7564-5afb-9b8b-0353c5da955d', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('58410fd8-08be-5ca2-a809-4c3ea2d26bde', '026f2189-2b79-5d52-afdb-7ebb759f0294', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading passage 1 has 5 chapters. Which chapter contains the following information?
Write your answers in boxes
1-5
on your answer sheet
1
the part of cacao trees used to produce chocolate
2
average chocolate consumption by people in the US per person per year
3
risks faced by fanners in the cacao business
4
where the first sweetened chocolate drink appeared
5
how ancient American civilizations obtained cacao

5 ____ how ancient American civilizations obtained cacao$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff515d4f-f221-5be0-a827-5a92765c1d25', '58410fd8-08be-5ca2-a809-4c3ea2d26bde', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02918496-0a79-5f73-884c-1f0d848eb293', '58410fd8-08be-5ca2-a809-4c3ea2d26bde', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24173fc6-a999-5ce1-acdb-a83862e4b701', '58410fd8-08be-5ca2-a809-4c3ea2d26bde', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a0b4608-7663-5492-9cd0-f5c0ac573d87', '58410fd8-08be-5ca2-a809-4c3ea2d26bde', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7860abff-a278-5b1d-9a41-c7012d84bdf2', '58410fd8-08be-5ca2-a809-4c3ea2d26bde', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('94d743ab-0633-528c-8c4a-4a0c5b2f7246', '026f2189-2b79-5d52-afdb-7ebb759f0294', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in Reading Passage 1?
In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
use cacao and chocolate in ceremonies were restricted Maya royal families
7
The Spanish explorer Hernando Cortes invested in chocolate and chocolate drinks.
8
The forastero tree produces the best chocolate.
9
some parts in cacao seed are get rid of during the chocolate process
10
Chocolate is welcomed more in some countries or continents than other parts around the world.

6 ____ use cacao and chocolate in ceremonies were restricted Maya royal families$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60a64832-fa2d-549f-9a61-498ffc90f8f3', '94d743ab-0633-528c-8c4a-4a0c5b2f7246', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8013bb79-78cd-5837-95c9-6561c4aca6c5', '94d743ab-0633-528c-8c4a-4a0c5b2f7246', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c035702-f9b5-5e28-a561-5300e8fa976c', '94d743ab-0633-528c-8c4a-4a0c5b2f7246', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('485ebc6a-56fe-5f4e-95c6-b07476b30cc9', '026f2189-2b79-5d52-afdb-7ebb759f0294', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in Reading Passage 1?
In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
use cacao and chocolate in ceremonies were restricted Maya royal families
7
The Spanish explorer Hernando Cortes invested in chocolate and chocolate drinks.
8
The forastero tree produces the best chocolate.
9
some parts in cacao seed are get rid of during the chocolate process
10
Chocolate is welcomed more in some countries or continents than other parts around the world.

7 ____ The Spanish explorer Hernando Cortes invested in chocolate and chocolate drinks.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ca4734d-0916-530d-bf45-fd3ec7c76382', '485ebc6a-56fe-5f4e-95c6-b07476b30cc9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6891fa23-01c9-5c26-aafa-581b8b47727a', '485ebc6a-56fe-5f4e-95c6-b07476b30cc9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ad8cfe6-08f5-581b-86e9-b4f41345d01d', '485ebc6a-56fe-5f4e-95c6-b07476b30cc9', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c6bd280d-3ae0-54b7-af73-eab40bac84c9', '026f2189-2b79-5d52-afdb-7ebb759f0294', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in Reading Passage 1?
In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
use cacao and chocolate in ceremonies were restricted Maya royal families
7
The Spanish explorer Hernando Cortes invested in chocolate and chocolate drinks.
8
The forastero tree produces the best chocolate.
9
some parts in cacao seed are get rid of during the chocolate process
10
Chocolate is welcomed more in some countries or continents than other parts around the world.

8 ____ The forastero tree produces the best chocolate.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e24ad026-75a3-5fcf-b23f-2eec490744a7', 'c6bd280d-3ae0-54b7-af73-eab40bac84c9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f15fc148-9e04-57e7-8c17-0c048710e7b2', 'c6bd280d-3ae0-54b7-af73-eab40bac84c9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6abdd127-fe54-5e16-8c7b-2aa0b54dd827', 'c6bd280d-3ae0-54b7-af73-eab40bac84c9', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2aae88be-c34e-5acc-9e96-ce3e923c7a99', '026f2189-2b79-5d52-afdb-7ebb759f0294', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in Reading Passage 1?
In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
use cacao and chocolate in ceremonies were restricted Maya royal families
7
The Spanish explorer Hernando Cortes invested in chocolate and chocolate drinks.
8
The forastero tree produces the best chocolate.
9
some parts in cacao seed are get rid of during the chocolate process
10
Chocolate is welcomed more in some countries or continents than other parts around the world.

9 ____ some parts in cacao seed are get rid of during the chocolate process$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64e507bc-9962-5d91-ad62-41c99002094d', '2aae88be-c34e-5acc-9e96-ce3e923c7a99', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49273ef2-269a-52d5-9bef-dc1d0ea40960', '2aae88be-c34e-5acc-9e96-ce3e923c7a99', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a415277-84cd-5f62-b2c0-297f526b780f', '2aae88be-c34e-5acc-9e96-ce3e923c7a99', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72bdc742-fe2f-5d2c-8388-de1bcfcc2da5', '026f2189-2b79-5d52-afdb-7ebb759f0294', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in Reading Passage 1?
In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
use cacao and chocolate in ceremonies were restricted Maya royal families
7
The Spanish explorer Hernando Cortes invested in chocolate and chocolate drinks.
8
The forastero tree produces the best chocolate.
9
some parts in cacao seed are get rid of during the chocolate process
10
Chocolate is welcomed more in some countries or continents than other parts around the world.

10 ____ Chocolate is welcomed more in some countries or continents than other parts around the world.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ed36e4b-8d46-5d3c-aa36-16c3594ae5ab', '72bdc742-fe2f-5d2c-8388-de1bcfcc2da5', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8443059-c203-558a-b251-90ac03523251', '72bdc742-fe2f-5d2c-8388-de1bcfcc2da5', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea52dabd-a92d-558e-b526-b41a99b3274e', '72bdc742-fe2f-5d2c-8388-de1bcfcc2da5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b50a27c9-55f5-5114-afd1-418d65aa87a1', '026f2189-2b79-5d52-afdb-7ebb759f0294', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
The flow chart below shows the steps in chocolate making.
Complete the flow chart using
NO MORE THAN THREE WORDS
from the passage for each blank
Write your answers in boxes
11-14
on your answer sheet.
Cacao seeds
↓ sorting, cleaning and cooking ridding seeds of their
11
.
Nibs
↓ crushing
12
↓ Add sugar, milk and
13
.
Crumb mixture
↓ Crush finely then come into a shape in a
14
.
chocolate

↓ sorting, cleaning and cooking ridding seeds of their 11 ____ .$md$, NULL, ARRAY['.*covering.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9e4684f0-fd83-50da-ae7e-0519f6126b73', '026f2189-2b79-5d52-afdb-7ebb759f0294', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
The flow chart below shows the steps in chocolate making.
Complete the flow chart using
NO MORE THAN THREE WORDS
from the passage for each blank
Write your answers in boxes
11-14
on your answer sheet.
Cacao seeds
↓ sorting, cleaning and cooking ridding seeds of their
11
.
Nibs
↓ crushing
12
↓ Add sugar, milk and
13
.
Crumb mixture
↓ Crush finely then come into a shape in a
14
.
chocolate

12 ____$md$, NULL, ARRAY['.*chocolate.*liquor.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7e3ec1d8-e8e7-548a-963d-7a4636b61a68', '026f2189-2b79-5d52-afdb-7ebb759f0294', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
The flow chart below shows the steps in chocolate making.
Complete the flow chart using
NO MORE THAN THREE WORDS
from the passage for each blank
Write your answers in boxes
11-14
on your answer sheet.
Cacao seeds
↓ sorting, cleaning and cooking ridding seeds of their
11
.
Nibs
↓ crushing
12
↓ Add sugar, milk and
13
.
Crumb mixture
↓ Crush finely then come into a shape in a
14
.
chocolate

↓ Add sugar, milk and 13 ____ .$md$, NULL, ARRAY['.*cocoa.*fat.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2fa2a289-7040-59c7-a79d-0870062eb337', '026f2189-2b79-5d52-afdb-7ebb759f0294', 14, 'SHORT_ANSWER', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
The flow chart below shows the steps in chocolate making.
Complete the flow chart using
NO MORE THAN THREE WORDS
from the passage for each blank
Write your answers in boxes
11-14
on your answer sheet.
Cacao seeds
↓ sorting, cleaning and cooking ridding seeds of their
11
.
Nibs
↓ crushing
12
↓ Add sugar, milk and
13
.
Crumb mixture
↓ Crush finely then come into a shape in a
14
.
chocolate

↓ Crush finely then come into a shape in a 14 ____ .$md$, NULL, ARRAY['.*mold.*form.*']);

COMMIT;
