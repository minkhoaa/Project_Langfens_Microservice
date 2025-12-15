BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-hidden-lives-of-solitary-bees-1485'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-hidden-lives-of-solitary-bees-1485';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-hidden-lives-of-solitary-bees-1485';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-hidden-lives-of-solitary-bees-1485';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('8bb0075c-7fe3-5555-8820-7e3273ce1d8d', 'ielts-reading-the-hidden-lives-of-solitary-bees-1485', $t$The hidden lives of solitary bees$t$, $md$## The hidden lives of solitary bees

Nguồn:
- Test: https://mini-ielts.com/1485/reading/the-hidden-lives-of-solitary-bees
- Solution: https://mini-ielts.com/1485/view-solution/reading/the-hidden-lives-of-solitary-bees$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('d0d0b499-55e2-5fa1-9551-fb33bd76426d', '8bb0075c-7fe3-5555-8820-7e3273ce1d8d', 1, $t$Reading — The hidden lives of solitary bees$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The hidden lives of solitary bees

There are 275 different species of bee in Great Britain and Ireland. Apart from the familiar honeybee and 25 species of bumblebee, the rest are known as solitary bees.

Solitary bees are unlike 'social' honeybees and bumblebees, which live in large colonies consisting of a queen whose function is to lay the eggs, while the workers gather pollen and nectar to feed the tiny grubs With solitary bees, there are typically just males and females. They mate, the mate dies and the female makes a nest.

Ian Beavis is a naturalist and blogger with a mission to raise the profile of the many solitary bees, whose pollinating services are so important, yet so little recognised, Solitary bees inhabit gardens, parks, woodlands, fields and cliffs. In fact they represent 95% of the world's bee species. Leading wildlife illustrator Richard Lewington. best known for his beautiful paintings of butterflies, says, 'Solitary bees are so useful to gardeners and commercially valuable. Yet until recently they barely registered in the public consciousness. I wanted to help publicise their vital role in our lives' The problem with solitary bees has long been one of identification - with more than 240 species to choose from, and no accessible guidebook, where do people start? So Richard Lewington has spent any spare time over the past few years working on a new guide to the bees of Great Britain and Ireland. This, amazingly, is the first book of its kind to be published for over a century.

How do solitary bees live? A female solitary bee constructs a nest and then lays her eggs in individual cells, lining or sealing them with various materials depending on the species of bee - red mason bees use mud leafcutter bees use sections of leaf The female leaves what naturalists call a 'parcel' of pollen and nectar for each other little grubs to feed on When the female has laid all her eggs, she dies The emerging grubs eat. grow and develop into adults the following year.

While some bees are plentiful and widespread, others have been designated as rare. Or are very local in distribution. In 2013. Ian Beavis came across what has long been known as one of Britain's rarest species, the banded mining bee. An impressive species with white hairs on its face, the banded mining bee nests in the ground, typically on steep banks. Ian Beavis explains that it always chooses bare earth because it doesn't like having to eat through plant roots to make its nest Females feed on a variety of plants, but seem particularly fond of yellow dandelions that bloom from spring to autumn.

Another bee that has attracted naturalists' attention is the ivy bee. It was only identified as a distinct species in 1993. It is one of a number of bees that have been able to establish themselves in Britain due to the recent warmer winters. About the same size as a with distinctive orange-yellow banding on its abdomen, it was initially thought to feed on y on ivy, but has since been seen visiting other plants.

The discoveries about ivy bees show how rewarding the study of solitary bees can be but it's not the only species whose habits are changing. Ian Beavis believes we can see in solitary bees the beginning of social behaviour. He explains that many species make their nests close to each other in huge groups, and there are some, like Andrena scotica, where several bees use the same entrance without becoming aggressive. It's not difficult to see how this behaviour, which could be seen as the foundation of social behaviour, might evolve in future into worker bees sharing care of the grubs. Indeed some of Britain's solitary bees, Lasioglossum malachurum for example, are already demonstrating this type of social behaviour. So will all solitary bees evolve into social insects? Not necessarily. According to Ian Beavis, there are advantages to social behaviour but there are also advantages to nesting alone. Bees that nest socially are a target for predators, diseases and parasites.

Pesticides can also pose a threat to solitary bees. At the University of Sussex in England. Beth Nicholls is conducting research into the effects of certain pesticides on the red mason bee. She explains. 'We know that pesticides harm social bees, but very little research has been done into solitary bees.’ Honeybees fly throughout the summer, so they may be exposed to different levels of pesticides. But if the shorter flight period of solitary bees - the red mason bee only flies from March to May - coincides with peak pesticide levels, that might be disastrous. If the red mason bee declines dramatically, it could affect the fruit growing industry. According to Beth Nicholls, it is much more efficient at pollinating orchard trees. Social bees carry pollen in ‘baskets' on their back legs, but a female red mason bee carries it on the underside of her abdomen. This is a messier way of transporting it, and so more pollen is transferred to other flowers. The social bees' method is much 'tidier’, so once they have collected the pollen and tucked it away behind their legs, it won't be dropped.

Solitary bees are all around us. We need to start paying attention to them before it’s too late.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9b389a8d-3f99-5a07-85cb-bb92ddbd21e2', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Choose the correct letter. A,B,C or D
Write the correct letter in boxes 1-4 on your answer sheet.
1. Ian Beavis and Richard Lewlngton both believe that solitary bees
A
are as interesting as many butterfly species.
B
have an extremely varied range of habitats,
C
should be appreciated much more widely.
D
are valued by many gardeners.
2. What does the writer think is surprising about the new book on bees?
A
There is such a wide range of species in it.
B
Some of the species in it are hard to differentiate.
C
Richard Lewington chose to give up his main work to write It.
D
It was so long since a guide like this had been produced.
3. Beth Nicholls explains that red mason bees
A
have had more studies into their behaviour than others.
B
may suffer more from pesticides than social bees,
C
have an advantage because of when they fly.
D
have certain similarities with honey bees.
4. Why does Beth Nicholls consider red mason bees to be valuable pollinators?
A
They regularly lose some of the pollen they are carrying.
B
They transport pollen with great care.
C
Their pollination season is longer than that of social bees.
D
The females do most of the pollen collection.

Choose the correct letter. A,B,C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fea314d5-fd44-551d-a9da-8e3b6013a27c', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Choose the correct letter. A,B,C or D
Write the correct letter in boxes 1-4 on your answer sheet.
1. Ian Beavis and Richard Lewlngton both believe that solitary bees
A
are as interesting as many butterfly species.
B
have an extremely varied range of habitats,
C
should be appreciated much more widely.
D
are valued by many gardeners.
2. What does the writer think is surprising about the new book on bees?
A
There is such a wide range of species in it.
B
Some of the species in it are hard to differentiate.
C
Richard Lewington chose to give up his main work to write It.
D
It was so long since a guide like this had been produced.
3. Beth Nicholls explains that red mason bees
A
have had more studies into their behaviour than others.
B
may suffer more from pesticides than social bees,
C
have an advantage because of when they fly.
D
have certain similarities with honey bees.
4. Why does Beth Nicholls consider red mason bees to be valuable pollinators?
A
They regularly lose some of the pollen they are carrying.
B
They transport pollen with great care.
C
Their pollination season is longer than that of social bees.
D
The females do most of the pollen collection.

Choose the correct letter. A,B,C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ee74b2c7-df1d-5bf3-b528-3d59d76ffccb', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Choose the correct letter. A,B,C or D
Write the correct letter in boxes 1-4 on your answer sheet.
1. Ian Beavis and Richard Lewlngton both believe that solitary bees
A
are as interesting as many butterfly species.
B
have an extremely varied range of habitats,
C
should be appreciated much more widely.
D
are valued by many gardeners.
2. What does the writer think is surprising about the new book on bees?
A
There is such a wide range of species in it.
B
Some of the species in it are hard to differentiate.
C
Richard Lewington chose to give up his main work to write It.
D
It was so long since a guide like this had been produced.
3. Beth Nicholls explains that red mason bees
A
have had more studies into their behaviour than others.
B
may suffer more from pesticides than social bees,
C
have an advantage because of when they fly.
D
have certain similarities with honey bees.
4. Why does Beth Nicholls consider red mason bees to be valuable pollinators?
A
They regularly lose some of the pollen they are carrying.
B
They transport pollen with great care.
C
Their pollination season is longer than that of social bees.
D
The females do most of the pollen collection.

Choose the correct letter. A,B,C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('89f7ebe1-789f-5812-9eec-81bb5880ec97', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Choose the correct letter. A,B,C or D
Write the correct letter in boxes 1-4 on your answer sheet.
1. Ian Beavis and Richard Lewlngton both believe that solitary bees
A
are as interesting as many butterfly species.
B
have an extremely varied range of habitats,
C
should be appreciated much more widely.
D
are valued by many gardeners.
2. What does the writer think is surprising about the new book on bees?
A
There is such a wide range of species in it.
B
Some of the species in it are hard to differentiate.
C
Richard Lewington chose to give up his main work to write It.
D
It was so long since a guide like this had been produced.
3. Beth Nicholls explains that red mason bees
A
have had more studies into their behaviour than others.
B
may suffer more from pesticides than social bees,
C
have an advantage because of when they fly.
D
have certain similarities with honey bees.
4. Why does Beth Nicholls consider red mason bees to be valuable pollinators?
A
They regularly lose some of the pollen they are carrying.
B
They transport pollen with great care.
C
Their pollination season is longer than that of social bees.
D
The females do most of the pollen collection.

Choose the correct letter. A,B,C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('447857fa-0753-533f-ac46-a00157144550', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Look at the following statements (Questions 5-8) and the list of solitary bees below.
Match each statement with the correct bee, A-E
Write the correct letter. A-E, in boxes 5-8 on your answer sheet
NB:
You may use any letter
more than once.
5
Some members of this species have started to contribute more to the care of the young
6
This species avoids areas covered with vegetation when selecting nest sites.
7
This species has a favourite flower that it feeds on.
8
This species has only been found in Britain in the past few years.
List of Solitary Bees
A The banded mining bee
B The ivy bee
C Andrena scotica
D Lasrogfossum malachurum
E The red mason bee

5 ____ Some members of this species have started to contribute more to the care of the young$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31924346-0fc7-5eb8-ae3a-ded8914e2f0a', '447857fa-0753-533f-ac46-a00157144550', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d1ab88f-e872-50c9-8b56-551359687d5e', '447857fa-0753-533f-ac46-a00157144550', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b27f15f-f803-5cb9-a3c6-65cc049214c3', '447857fa-0753-533f-ac46-a00157144550', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76c64108-cc95-5d9a-87ce-fc9712cf2825', '447857fa-0753-533f-ac46-a00157144550', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f8ada7d-b1c8-5763-bdc8-d40376d2ab95', '447857fa-0753-533f-ac46-a00157144550', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eff44c50-6b33-5e24-afa1-94e2285df5e4', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Look at the following statements (Questions 5-8) and the list of solitary bees below.
Match each statement with the correct bee, A-E
Write the correct letter. A-E, in boxes 5-8 on your answer sheet
NB:
You may use any letter
more than once.
5
Some members of this species have started to contribute more to the care of the young
6
This species avoids areas covered with vegetation when selecting nest sites.
7
This species has a favourite flower that it feeds on.
8
This species has only been found in Britain in the past few years.
List of Solitary Bees
A The banded mining bee
B The ivy bee
C Andrena scotica
D Lasrogfossum malachurum
E The red mason bee

6 ____ This species avoids areas covered with vegetation when selecting nest sites.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3ac37d5-6ecc-5187-82d9-ff70bd9dde08', 'eff44c50-6b33-5e24-afa1-94e2285df5e4', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38147ab3-c57e-5d89-8561-40a0cf0747a8', 'eff44c50-6b33-5e24-afa1-94e2285df5e4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e54a282b-f1b2-5e85-a1c6-9b23e34a8ffe', 'eff44c50-6b33-5e24-afa1-94e2285df5e4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3e5a3f8-b9a8-5b1e-8630-6102746f31da', 'eff44c50-6b33-5e24-afa1-94e2285df5e4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82964771-ac7a-559e-89cb-510ab54c84b2', 'eff44c50-6b33-5e24-afa1-94e2285df5e4', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ffa3af1f-7075-54ed-8a77-63752195b904', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Look at the following statements (Questions 5-8) and the list of solitary bees below.
Match each statement with the correct bee, A-E
Write the correct letter. A-E, in boxes 5-8 on your answer sheet
NB:
You may use any letter
more than once.
5
Some members of this species have started to contribute more to the care of the young
6
This species avoids areas covered with vegetation when selecting nest sites.
7
This species has a favourite flower that it feeds on.
8
This species has only been found in Britain in the past few years.
List of Solitary Bees
A The banded mining bee
B The ivy bee
C Andrena scotica
D Lasrogfossum malachurum
E The red mason bee

7 ____ This species has a favourite flower that it feeds on.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b610b06-4895-54d7-ae12-922c731eb2a6', 'ffa3af1f-7075-54ed-8a77-63752195b904', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99bad5bd-64c7-5648-a95a-1c2611b5a200', 'ffa3af1f-7075-54ed-8a77-63752195b904', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ae51da7-8c84-5146-9993-780b88429472', 'ffa3af1f-7075-54ed-8a77-63752195b904', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a291f6cc-6051-59bc-a47b-db7a5bf50b2e', 'ffa3af1f-7075-54ed-8a77-63752195b904', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('235d99b7-ce54-58ac-8c87-bf0db1298fce', 'ffa3af1f-7075-54ed-8a77-63752195b904', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5bca7918-93ad-58ee-a64e-cfcf4029bff3', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Look at the following statements (Questions 5-8) and the list of solitary bees below.
Match each statement with the correct bee, A-E
Write the correct letter. A-E, in boxes 5-8 on your answer sheet
NB:
You may use any letter
more than once.
5
Some members of this species have started to contribute more to the care of the young
6
This species avoids areas covered with vegetation when selecting nest sites.
7
This species has a favourite flower that it feeds on.
8
This species has only been found in Britain in the past few years.
List of Solitary Bees
A The banded mining bee
B The ivy bee
C Andrena scotica
D Lasrogfossum malachurum
E The red mason bee

8 ____ This species has only been found in Britain in the past few years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35181f15-c6e0-5a0d-a674-846f5ccfb94e', '5bca7918-93ad-58ee-a64e-cfcf4029bff3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5137a4a-20a8-5d02-a5e7-57118303eb7a', '5bca7918-93ad-58ee-a64e-cfcf4029bff3', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('899a30a8-96be-57b5-9d3b-94e8a588f3cf', '5bca7918-93ad-58ee-a64e-cfcf4029bff3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b34a2545-0d94-551c-9ba5-59601f0e9eab', '5bca7918-93ad-58ee-a64e-cfcf4029bff3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abf30550-79ed-5d21-9566-de7afe698a2c', '5bca7918-93ad-58ee-a64e-cfcf4029bff3', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('512a4793-515d-5987-8677-942fb69712db', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 9, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Complete the summary below.
Choose
ONE WORD ONLY
from the text for each answer
Write your answers in boxes 9-13 on your answer sheet.
The life of the solitary bee
Female solitary bees make their nests with separate
9
where single eggs are deposited. Females try to ensure the survival of all their
10
. They do this by providing suitable food in what is referred to as a
11
. Solitarybees use a range of substances to make their nests comfortable and secure, such as plant material or
12
.
Although some solitary bees are common, certain species are thought to be
13
.
The different solitary bees vary widely in their distribution, some being found all over Britain while others are much more restricted geographically.

Female solitary bees make their nests with separate 9 ____ where single eggs are deposited. Females try to ensure the survival of all their 10 ____ . They do this by providing suitable food in what is referred to as a 11 ____ . Solitarybees use a range of substances to make their nests comfortable and secure, such as plant material or 12 ____ .$md$, NULL, ARRAY['.*cells.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('52a9ccfc-fc79-5a6b-94d4-72b5cf3113c8', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 10, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Complete the summary below.
Choose
ONE WORD ONLY
from the text for each answer
Write your answers in boxes 9-13 on your answer sheet.
The life of the solitary bee
Female solitary bees make their nests with separate
9
where single eggs are deposited. Females try to ensure the survival of all their
10
. They do this by providing suitable food in what is referred to as a
11
. Solitarybees use a range of substances to make their nests comfortable and secure, such as plant material or
12
.
Although some solitary bees are common, certain species are thought to be
13
.
The different solitary bees vary widely in their distribution, some being found all over Britain while others are much more restricted geographically.

Female solitary bees make their nests with separate 9 ____ where single eggs are deposited. Females try to ensure the survival of all their 10 ____ . They do this by providing suitable food in what is referred to as a 11 ____ . Solitarybees use a range of substances to make their nests comfortable and secure, such as plant material or 12 ____ .$md$, NULL, ARRAY['.*cells.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('072aaba6-fb06-52b1-b914-e7cf96397a2d', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Complete the summary below.
Choose
ONE WORD ONLY
from the text for each answer
Write your answers in boxes 9-13 on your answer sheet.
The life of the solitary bee
Female solitary bees make their nests with separate
9
where single eggs are deposited. Females try to ensure the survival of all their
10
. They do this by providing suitable food in what is referred to as a
11
. Solitarybees use a range of substances to make their nests comfortable and secure, such as plant material or
12
.
Although some solitary bees are common, certain species are thought to be
13
.
The different solitary bees vary widely in their distribution, some being found all over Britain while others are much more restricted geographically.

Female solitary bees make their nests with separate 9 ____ where single eggs are deposited. Females try to ensure the survival of all their 10 ____ . They do this by providing suitable food in what is referred to as a 11 ____ . Solitarybees use a range of substances to make their nests comfortable and secure, such as plant material or 12 ____ .$md$, NULL, ARRAY['.*cells.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2ad67e6e-dfd3-5f8f-996b-2e7b2e098ba3', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Complete the summary below.
Choose
ONE WORD ONLY
from the text for each answer
Write your answers in boxes 9-13 on your answer sheet.
The life of the solitary bee
Female solitary bees make their nests with separate
9
where single eggs are deposited. Females try to ensure the survival of all their
10
. They do this by providing suitable food in what is referred to as a
11
. Solitarybees use a range of substances to make their nests comfortable and secure, such as plant material or
12
.
Although some solitary bees are common, certain species are thought to be
13
.
The different solitary bees vary widely in their distribution, some being found all over Britain while others are much more restricted geographically.

Female solitary bees make their nests with separate 9 ____ where single eggs are deposited. Females try to ensure the survival of all their 10 ____ . They do this by providing suitable food in what is referred to as a 11 ____ . Solitarybees use a range of substances to make their nests comfortable and secure, such as plant material or 12 ____ .$md$, NULL, ARRAY['.*cells.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5114e5a8-f82d-51d2-8a1e-11602a843382', 'd0d0b499-55e2-5fa1-9551-fb33bd76426d', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Complete the summary below.
Choose
ONE WORD ONLY
from the text for each answer
Write your answers in boxes 9-13 on your answer sheet.
The life of the solitary bee
Female solitary bees make their nests with separate
9
where single eggs are deposited. Females try to ensure the survival of all their
10
. They do this by providing suitable food in what is referred to as a
11
. Solitarybees use a range of substances to make their nests comfortable and secure, such as plant material or
12
.
Although some solitary bees are common, certain species are thought to be
13
.
The different solitary bees vary widely in their distribution, some being found all over Britain while others are much more restricted geographically.

Although some solitary bees are common, certain species are thought to be 13 ____ .$md$, NULL, ARRAY['.*rare.*']);

COMMIT;
