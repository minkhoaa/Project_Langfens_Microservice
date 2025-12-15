BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-ecological-importance-of-bees-1531'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-ecological-importance-of-bees-1531';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-ecological-importance-of-bees-1531';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-ecological-importance-of-bees-1531';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4af2003d-60a6-5f5c-90be-1d019d0e3b62', 'ielts-reading-the-ecological-importance-of-bees-1531', $t$The Ecological Importance of Bees$t$, $md$## The Ecological Importance of Bees

Nguồn:
- Test: https://mini-ielts.com/1531/reading/the-ecological-importance-of-bees
- Solution: https://mini-ielts.com/1531/view-solution/reading/the-ecological-importance-of-bees$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('4119e5ca-262b-59b2-bb60-95357071abb9', '4af2003d-60a6-5f5c-90be-1d019d0e3b62', 1, $t$Reading — The Ecological Importance of Bees$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Ecological Importance of Bees

A Sometime in the early Cretaceous period of the Earth's history, hunting wasps of a certain type became bees by adopting a vegetarian diet: they began to rely more and more on the pollen of plants as a source of protein for themselves and their offspring, as an alternative to insects. In so doing, they accidentally transported pollen on their bodies to other plants of the same species, bringing about pollination. The stage was thus set for a succession of ever-closer mutual adaptations of bees and flowering plants. In particular, flowers began to reward bees for their unwitting role in their reproduction by providing richer sources of pollen and another source of nutrition, nectar.

B Today about 15 per cent of our diet consists of crops which are pollinated by bees. The meat and other animal products we consume are ultimately derived from bee- pollinated forage crops, and account for another 15 per cent. It follows that around one third of our food is directly or indirectly dependent on the pollinating services of bees. On a global basis, the annual value of agricultural crops dependent on the pollination services of bees is estimated at £1,000 million (US$1,590 million). Much of this pollination is due to honey bees, and in monetary terms it exceeds the value of the annual honey crop by a factor of fifty.

C But the apparently harmonious relationship between bees and plants conceals a conflict of interests. Although flowers need bees and vice versa, it pays each partner to minimise its costs and maximise its profits. This may sound like an extreme case of attributing human qualities to non-human species, but using the marketplace and the principles of double-entry book keeping as metaphors may give US some insights into what is really going on between bees and flowering plants. In the real world, both flower and bee operate in a competitive marketplace. A community of retailers, the flowers, seek to attract more or less discriminating consumers, the bees. Each flower has to juggle the costs and benefits of investing in advertising, by colour and scent, and providing rewards, nectar and pollen, clearly a species which depends on cross-pollination is on a knife-edge: it must provide sufficient nectar to attract the interest of a bee, but not enough to satisfy all of its needs in one visit. A satiated bee would return to its nest rather than visit another flower. The bee, on the other hand, is out to get the maximum amount of pollen and nectar. It must assess the quality and quantity of rewards which are on offer and juggle its energy costs so that it makes a calorific profit on each foraging trip. The apparent harmony between plants and bees is therefore not all that it seems. Instead, it is an equilibrium based on compromises between the competing interests of the protagonists.

D This sounds remarkably like the ideas of the 18th-century economist Adam Smith. In his book, The Wealth of Nations, Smith postulated that in human society the competitive interactions of different ‘economic units' eventually resulted in a balanced, or ‘harmonious’ society. One might predict, therefore, that economists would find the relationships between bees and plants of some interest. This is the case in Israel, where economists are collaborating with botanists and entomologists in a long-term study of the pollination biology of the native flora, in an attempt to understand the dynamics of the relationship between communities of bees and plants.

E This sort of study is of more than passing academic interest. It is important that authorities understand the dynamic relationships between plants and their pollinators. This is especially true when, say, devising conservation policies. A good example comes from the forests of tropical South America. Here, as in all rainforests, there is a high diversity of tree species. There may be more than 120 per acre, but in a given acre there may only be one or two individuals of any one species: These trees are pollinated by large, fast-flying bees. There is evidence that certain types of bees learn the distribution of these scattered trees and forage regularly along the same routes. This is called ‘trap-lining’ and the bees forage for up to 23 km from their nests. The bees are therefore acting as long distance pollinators.

F An issue of current concern in tropical forest conservation is that of trying to estimate the minimum sustainable size of islands' of forest reserve in areas where large-scale felling is taking place. There is much discussion on seed dispersal distances. But this is only one half of the equation, so far as the reproduction of trees is concerned. There is another question that must be addressed in order to calculate whether proposed forest reserves are close enough to the nearest large tract of forest: ‘what is the flight range of these long-distance foragers?' We need to know much more about bees and their relationships with plants before this question can be answered.

G Bees, then, are vital to our survival. Furthermore, much of the visual impact of human environments derives from vegetation, and most vegetation is dependent on bees for pollination. Thus, as pollinators of crops and natural vegetation, bees occupy key positions in the web of relationships which sustain the living architecture of our planet.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('03648d02-0a0c-5cac-9091-e17fc0f840ed', '4119e5ca-262b-59b2-bb60-95357071abb9', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A,
B, D, E
and
F
from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-5
on your answer sheet.
List of Headings
i
Parallels between bee and human activities
ii
An evolutionary turning point
iii
A lack of total co-operation
iv
The preservation of individual plant species
v
The commercial value of bees
vi
The structure of flowering plants
vii
The pursuit of self-interest
viii
The need for further research
1
Paragraph
A
2
Paragraph
B
Example
Paragraph C
vii
3
Paragraph
D
4
Paragraph
E
5
Paragraph
F

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5d3823e-eeb8-519b-ac57-34ba6fd7d747', '03648d02-0a0c-5cac-9091-e17fc0f840ed', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9152d79f-654e-56d1-8afe-6e687bd3d617', '03648d02-0a0c-5cac-9091-e17fc0f840ed', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40ef1abf-abe5-5c86-96db-d935ca3e17c0', '03648d02-0a0c-5cac-9091-e17fc0f840ed', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0131f6ea-0c47-5e27-b7e7-2c3412da81a4', '03648d02-0a0c-5cac-9091-e17fc0f840ed', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7973ed13-f808-50c3-bc11-b74da43a330e', '03648d02-0a0c-5cac-9091-e17fc0f840ed', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43320c13-0b26-578d-88af-941e72102f24', '03648d02-0a0c-5cac-9091-e17fc0f840ed', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98ddf80d-db8a-5607-8a1f-abe85915e194', '03648d02-0a0c-5cac-9091-e17fc0f840ed', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ccc751b-d232-58c7-8fab-3f13a1256c58', '03648d02-0a0c-5cac-9091-e17fc0f840ed', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e2875de3-1eb9-5a7b-b37f-3e97a4bd5eb5', '4119e5ca-262b-59b2-bb60-95357071abb9', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A,
B, D, E
and
F
from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-5
on your answer sheet.
List of Headings
i
Parallels between bee and human activities
ii
An evolutionary turning point
iii
A lack of total co-operation
iv
The preservation of individual plant species
v
The commercial value of bees
vi
The structure of flowering plants
vii
The pursuit of self-interest
viii
The need for further research
1
Paragraph
A
2
Paragraph
B
Example
Paragraph C
vii
3
Paragraph
D
4
Paragraph
E
5
Paragraph
F

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ab2b0c6-42d6-5ff6-be28-a9d15d01691f', 'e2875de3-1eb9-5a7b-b37f-3e97a4bd5eb5', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20e5af62-ad06-57b2-a51c-0212423a53cc', 'e2875de3-1eb9-5a7b-b37f-3e97a4bd5eb5', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d90f4789-153a-535c-b689-a10fd0e4acfb', 'e2875de3-1eb9-5a7b-b37f-3e97a4bd5eb5', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43ea3bc8-bf2e-5c42-82b3-dca25765a8bc', 'e2875de3-1eb9-5a7b-b37f-3e97a4bd5eb5', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('228ba6bb-5328-570c-aa77-37152ce0da71', 'e2875de3-1eb9-5a7b-b37f-3e97a4bd5eb5', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c362722-b41e-5d56-90cd-24b4b068b437', 'e2875de3-1eb9-5a7b-b37f-3e97a4bd5eb5', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('938d9d57-3d8d-5475-8f27-ee9aec1ffdc6', 'e2875de3-1eb9-5a7b-b37f-3e97a4bd5eb5', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c641a804-4ebe-5c43-a470-e43e0562dba0', 'e2875de3-1eb9-5a7b-b37f-3e97a4bd5eb5', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a87f2c09-e588-5141-8bff-0c8afae3f005', '4119e5ca-262b-59b2-bb60-95357071abb9', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A,
B, D, E
and
F
from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-5
on your answer sheet.
List of Headings
i
Parallels between bee and human activities
ii
An evolutionary turning point
iii
A lack of total co-operation
iv
The preservation of individual plant species
v
The commercial value of bees
vi
The structure of flowering plants
vii
The pursuit of self-interest
viii
The need for further research
1
Paragraph
A
2
Paragraph
B
Example
Paragraph C
vii
3
Paragraph
D
4
Paragraph
E
5
Paragraph
F

3 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d588b3d-7b10-504b-afa4-7b972ede0ee9', 'a87f2c09-e588-5141-8bff-0c8afae3f005', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74d460dd-8d02-532f-b808-9e70a0a13e66', 'a87f2c09-e588-5141-8bff-0c8afae3f005', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d044179-5bd0-5f94-97c8-701ec7b5753c', 'a87f2c09-e588-5141-8bff-0c8afae3f005', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db4dbf81-7bcc-57b8-9491-b46e85c93b1f', 'a87f2c09-e588-5141-8bff-0c8afae3f005', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8de74437-ed90-5633-9f75-54f2628d72f7', 'a87f2c09-e588-5141-8bff-0c8afae3f005', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b030979-02fe-526d-ae50-b6bea0c4b8b4', 'a87f2c09-e588-5141-8bff-0c8afae3f005', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2249bbfc-65ad-5bca-9e71-ec11a07699ee', 'a87f2c09-e588-5141-8bff-0c8afae3f005', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e55d227-c44a-512e-aedd-ae870dfa0532', 'a87f2c09-e588-5141-8bff-0c8afae3f005', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('84cf0755-6ef8-5103-aa00-dcd31deed02f', '4119e5ca-262b-59b2-bb60-95357071abb9', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A,
B, D, E
and
F
from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-5
on your answer sheet.
List of Headings
i
Parallels between bee and human activities
ii
An evolutionary turning point
iii
A lack of total co-operation
iv
The preservation of individual plant species
v
The commercial value of bees
vi
The structure of flowering plants
vii
The pursuit of self-interest
viii
The need for further research
1
Paragraph
A
2
Paragraph
B
Example
Paragraph C
vii
3
Paragraph
D
4
Paragraph
E
5
Paragraph
F

4 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c29457d-d149-52d3-9863-187d183c78ce', '84cf0755-6ef8-5103-aa00-dcd31deed02f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('685bd740-087c-5a9a-bf30-1b12ac436222', '84cf0755-6ef8-5103-aa00-dcd31deed02f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b92b7a86-096e-5cf3-9ffb-ca3764dd7855', '84cf0755-6ef8-5103-aa00-dcd31deed02f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da91a25a-fd3c-5a7f-b359-99c5ef3c654b', '84cf0755-6ef8-5103-aa00-dcd31deed02f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea20200f-1064-5ee4-9d67-4a23cd74c377', '84cf0755-6ef8-5103-aa00-dcd31deed02f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e929b3da-05f6-53b2-a554-e27e56f4f738', '84cf0755-6ef8-5103-aa00-dcd31deed02f', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54fe73ef-f02e-5126-983b-cdb82a0c2827', '84cf0755-6ef8-5103-aa00-dcd31deed02f', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e139af44-7f4a-5919-ac0d-7b1d03c11b1b', '84cf0755-6ef8-5103-aa00-dcd31deed02f', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f259367e-a2d1-5c39-abec-03e4e0dd620f', '4119e5ca-262b-59b2-bb60-95357071abb9', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A,
B, D, E
and
F
from the list of headings below.
Write the correct number,
i-viii,
in boxes
1-5
on your answer sheet.
List of Headings
i
Parallels between bee and human activities
ii
An evolutionary turning point
iii
A lack of total co-operation
iv
The preservation of individual plant species
v
The commercial value of bees
vi
The structure of flowering plants
vii
The pursuit of self-interest
viii
The need for further research
1
Paragraph
A
2
Paragraph
B
Example
Paragraph C
vii
3
Paragraph
D
4
Paragraph
E
5
Paragraph
F

5 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec9beb51-affe-5931-a8ea-8a9604aaca81', 'f259367e-a2d1-5c39-abec-03e4e0dd620f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37e24bd5-bec6-5f12-b95f-1cb83beb42b5', 'f259367e-a2d1-5c39-abec-03e4e0dd620f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('606f3033-1501-5a85-8235-c70f4ea95949', 'f259367e-a2d1-5c39-abec-03e4e0dd620f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eac1fce8-f5be-5390-8203-ef32dd23087a', 'f259367e-a2d1-5c39-abec-03e4e0dd620f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c750f2c-f54e-5101-b32d-d7aa2ef49f5f', 'f259367e-a2d1-5c39-abec-03e4e0dd620f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8afdcdcc-4c5c-5200-a177-b17fad829665', 'f259367e-a2d1-5c39-abec-03e4e0dd620f', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b49725b7-895e-5fd5-9454-a7970e60d6f1', 'f259367e-a2d1-5c39-abec-03e4e0dd620f', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('090d1735-bdde-5914-8a02-dad077e3f452', 'f259367e-a2d1-5c39-abec-03e4e0dd620f', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7cdc664b-d77b-5d0b-bee1-885af1bb0485', '4119e5ca-262b-59b2-bb60-95357071abb9', 6, 'FORM_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-12
Questions 6-12
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-12 on your answer sheet.
6.
Hunting wasps used to feed on other
6
, rather than on vegetation.
7.
Flowering plants started to reward bees with rich pollen and an additional food in the form of
7
8.
Approximately
8
of human food production relies on the activity of bees.
9.
If the process of
9
is to take place effectively, bees need to travel from one flower to another before going back to the nest.
10.
Bees need to balance the
10
of each trip against the calorific rewards they obtain.
11.
There can be over 120 different
11
in. an acre of rainforest.
12.
The bees that pollinate large forests regularly practise an activity known as
12

6. Hunting wasps used to feed on other 6 ____ , rather than on vegetation.$md$, NULL, ARRAY['.*insects.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('05123193-7c31-539f-a36e-117c9942c126', '4119e5ca-262b-59b2-bb60-95357071abb9', 7, 'FORM_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-12
Questions 6-12
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-12 on your answer sheet.
6.
Hunting wasps used to feed on other
6
, rather than on vegetation.
7.
Flowering plants started to reward bees with rich pollen and an additional food in the form of
7
8.
Approximately
8
of human food production relies on the activity of bees.
9.
If the process of
9
is to take place effectively, bees need to travel from one flower to another before going back to the nest.
10.
Bees need to balance the
10
of each trip against the calorific rewards they obtain.
11.
There can be over 120 different
11
in. an acre of rainforest.
12.
The bees that pollinate large forests regularly practise an activity known as
12

7. Flowering plants started to reward bees with rich pollen and an additional food in the form of 7 ____$md$, NULL, ARRAY['.*nectar.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7e37d8f6-a6a0-58bc-9b3e-0be8473d783b', '4119e5ca-262b-59b2-bb60-95357071abb9', 8, 'FORM_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-12
Questions 6-12
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-12 on your answer sheet.
6.
Hunting wasps used to feed on other
6
, rather than on vegetation.
7.
Flowering plants started to reward bees with rich pollen and an additional food in the form of
7
8.
Approximately
8
of human food production relies on the activity of bees.
9.
If the process of
9
is to take place effectively, bees need to travel from one flower to another before going back to the nest.
10.
Bees need to balance the
10
of each trip against the calorific rewards they obtain.
11.
There can be over 120 different
11
in. an acre of rainforest.
12.
The bees that pollinate large forests regularly practise an activity known as
12

8. Approximately 8 ____ of human food production relies on the activity of bees.$md$, NULL, ARRAY['.*one.*third.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e3923b4f-4c81-5272-9ff7-2ecaf6f40507', '4119e5ca-262b-59b2-bb60-95357071abb9', 9, 'FORM_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-12
Questions 6-12
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-12 on your answer sheet.
6.
Hunting wasps used to feed on other
6
, rather than on vegetation.
7.
Flowering plants started to reward bees with rich pollen and an additional food in the form of
7
8.
Approximately
8
of human food production relies on the activity of bees.
9.
If the process of
9
is to take place effectively, bees need to travel from one flower to another before going back to the nest.
10.
Bees need to balance the
10
of each trip against the calorific rewards they obtain.
11.
There can be over 120 different
11
in. an acre of rainforest.
12.
The bees that pollinate large forests regularly practise an activity known as
12

9. If the process of 9 ____ is to take place effectively, bees need to travel from one flower to another before going back to the nest.$md$, NULL, ARRAY['.*cross.*pollination.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a1175f25-0e28-5140-a979-baace8020866', '4119e5ca-262b-59b2-bb60-95357071abb9', 10, 'FORM_COMPLETION', 'READING', 4, $md$### Question 10

Questions 6-12
Questions 6-12
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-12 on your answer sheet.
6.
Hunting wasps used to feed on other
6
, rather than on vegetation.
7.
Flowering plants started to reward bees with rich pollen and an additional food in the form of
7
8.
Approximately
8
of human food production relies on the activity of bees.
9.
If the process of
9
is to take place effectively, bees need to travel from one flower to another before going back to the nest.
10.
Bees need to balance the
10
of each trip against the calorific rewards they obtain.
11.
There can be over 120 different
11
in. an acre of rainforest.
12.
The bees that pollinate large forests regularly practise an activity known as
12

10. Bees need to balance the 10 ____ of each trip against the calorific rewards they obtain.$md$, NULL, ARRAY['.*energy.*costs.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e33511c5-c308-5776-9ef7-72d6233b0593', '4119e5ca-262b-59b2-bb60-95357071abb9', 11, 'FORM_COMPLETION', 'READING', 4, $md$### Question 11

Questions 6-12
Questions 6-12
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-12 on your answer sheet.
6.
Hunting wasps used to feed on other
6
, rather than on vegetation.
7.
Flowering plants started to reward bees with rich pollen and an additional food in the form of
7
8.
Approximately
8
of human food production relies on the activity of bees.
9.
If the process of
9
is to take place effectively, bees need to travel from one flower to another before going back to the nest.
10.
Bees need to balance the
10
of each trip against the calorific rewards they obtain.
11.
There can be over 120 different
11
in. an acre of rainforest.
12.
The bees that pollinate large forests regularly practise an activity known as
12

11. There can be over 120 different 11 ____ in. an acre of rainforest.$md$, NULL, ARRAY['.*tree.*species.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('68a76fbf-bcfe-52c1-aaf0-fbb9e5549ec6', '4119e5ca-262b-59b2-bb60-95357071abb9', 12, 'FORM_COMPLETION', 'READING', 4, $md$### Question 12

Questions 6-12
Questions 6-12
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-12 on your answer sheet.
6.
Hunting wasps used to feed on other
6
, rather than on vegetation.
7.
Flowering plants started to reward bees with rich pollen and an additional food in the form of
7
8.
Approximately
8
of human food production relies on the activity of bees.
9.
If the process of
9
is to take place effectively, bees need to travel from one flower to another before going back to the nest.
10.
Bees need to balance the
10
of each trip against the calorific rewards they obtain.
11.
There can be over 120 different
11
in. an acre of rainforest.
12.
The bees that pollinate large forests regularly practise an activity known as
12

12. The bees that pollinate large forests regularly practise an activity known as 12 ____$md$, NULL, ARRAY['.*trap.*lining.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('18d75771-efb7-58f4-9e6e-036026a5f0c3', '4119e5ca-262b-59b2-bb60-95357071abb9', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Question 13
Question 13
Choose the correct letter , A, B, C or D. Write the correct letter in box 13 on your answer sheet. Which is the best title for Reading Passage ?
A
The Ecological Importance of Bees
B
The Evolutionary History of Bees
C
The Social Behaviour of Bees
D
The Geographical Distribution of Bees

Choose the correct letter , A, B, C or D. Write the correct letter in box 13 on your answer sheet. Which is the best title for Reading Passage ?$md$, NULL);

COMMIT;
