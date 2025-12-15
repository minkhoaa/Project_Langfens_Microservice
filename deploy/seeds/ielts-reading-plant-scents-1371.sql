BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-plant-scents-1371'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-plant-scents-1371';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-plant-scents-1371';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-plant-scents-1371';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('8115a525-2da2-58fa-9cdc-803bd2e03544', 'ielts-reading-plant-scents-1371', $t$Plant Scents$t$, $md$## Plant Scents

Nguồn:
- Test: https://mini-ielts.com/1371/reading/plant-scents
- Solution: https://mini-ielts.com/1371/view-solution/reading/plant-scents$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7070e00c-a9e3-5311-8193-3afe234be386', '8115a525-2da2-58fa-9cdc-803bd2e03544', 1, $t$Reading — Plant Scents$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Plant Scents

A

Everyone is familiar with scented flowers, and many people have heard that floral odors help the plant attract pollinators. This common notion is mostly correct, but it is surprising how little scientific proof of it exists. Of course, not all flowers are pollinated by biological agents – for example, many grasses are wind-pollinated – but the flowers of the grasses may still emit volatiles. In fact, plants emit organic molecules all the time, although they may not be obvious to the human nose. As for flower scents that we can detect with our noses, bouquets that attract moths and butterflies generally smell “sweet,” and those that attract certain flies seem “rotten” to us.

B

The release of volatiles from vegetative parts of the plant is familiar, although until recently the physiological functions of these chemicals were less clear and had received much less attention from scientists. When the trunk of a pine tree is injured – for example, when a beetle tries to burrow into it – it exudes a very smelly resin. This resin consists mostly of terpenes – hydrocarbons with a backbone of 10, 15 or 20 carbons that may also contain atoms of oxygen. The heavier C20 terpenes, called diterpenes, are glue-like and can cover and immobilize insects as they plug the hole. This defense mechanism is as ancient as it is effective: Many samples of fossilized resin, or amber, contain the remains of insects trapped inside. Many other plants emit volatiles when injured, and in some cases the emitted signal helps defend the plant. For example, (Z)-3-hexenyl acetate, which is known as a “green leaf volatile” because it is emitted by many plants upon injury, deters females of the moth Heliothis virescens from laying eggs on injured tobacco plants. Interestingly, the profile of emitted tobacco volatiles is different at night than during the day, and it is the nocturnal blend, rich in several (Z)-3-hexen-1-olesters, that is most effective in repelling the night-active H. virescens moths.

C

Herbivore induced volatiles often serve as indirect defenses. These bulwarks exist in a variety of plant species, including corn, beans, and the model plant species Arabidopsis thaliana. Plants not only emit volatiles acutely, at the site where caterpillars, mites, aphids or similar insects are eating them but also generally from non-damaged parts of the plant. These signals attract a variety of predatory insects that prey on the plant-eaters. For example, some parasitic wasps can detect the volatile signature of a damaged plant and will lay their eggs inside the offending caterpillar; eventually, the wasp eggs hatch, and the emerging larvae feed on the caterpillar from the inside hatch, and the emerging larvae feed on the caterpillar from the inside out. The growth of infected caterpillars is retarded considerably, to the benefit of the plant. Similarly, volatiles released by plants in response to herbivore egg laying can attract parasites of the eggs, thereby preventing them from hatching and avoiding the onslaught of hungry herbivores that would have emerged. Plant volatiles can also be used as a kind of currency in some very indirect defensive schemes. In the rainforest understory tree Leonardoxa Africana, ants of the species Petalomyrmex phylax patrol young leaves and attack any herbivorous insects that they encounter. The young leaves emit high levels of the volatile compound methyl salicylate, a compound that the ants use either as a pheromone or as an antiseptic in their nests. It appears that methyl salicylate is both an attractant and a reward offered by the tree to get the ants to perform this valuable deterrent role.

D

Floral scent has a strong impact on the economic success of many agricultural crops that rely on insect pollinators, including fruit trees such as the bee-pollinated cherry, apple, apricot and peach, as well as vegetables and tropical plants such as papaya. Pollination not only affects crop yield, but also the quality and efficiency of crop production. Many crops require most, if not all, ovules to be fertilized for optimum fruit size and shape. A decrease in fragrance emission reduces the ability of flowers to attract pollinators and results in considerable losses for growers, particularly for introduced species that had a specialized pollinator in their place of origin. This problem has been exacerbated by recent disease epidemics that have killed many honeybees, the major insect pollinators in the United States.

E

One means by which plant breeders circumvent the pollination problem is by breeding self-compatible, or apomictic, varieties that do not require fertilization. Although this solution is adequate, its drawbacks include near genetic uniformity and consequent susceptibility to pathogens. Some growers have attempted to enhance honeybee foraging by spraying scent compounds on orchard trees, but this approach was costly, had to be repeated, had potentially toxic effects on the soil or local biota, and, in the end, proved to be inefficient. The poor effectiveness of this strategy probably reflects inherent limitations of the artificial, topically applied compounds, which clearly fail to convey the appropriate message to the bees. For example, general spraying of the volatile mixture cannot tell the insects where exactly the blossoms are. Clearly, a more refined strategy is needed. The ability to enhance existing floral scent, which could all be accomplished by genetic engineering, would allow us to manipulate the types of insect pollinators and the frequency of their visits. Moreover, the metabolic engineering of fragrance could increase crop protection against pathogens and pests.

F

Genetic manipulation of the scent will also benefit the floriculture industry. Ornamentals, including cut flowers, foliage and potted plants, play an important aesthetic role in human life. Unfortunately, traditional breeding has often produced cultivars with improved vase life, shipping characteristics, color and shape while sacrificing desirable perfumes. The loss of scent among ornamentals, which have a worldwide value of more than $30 billion, makes them important targets for the genetic manipulation of flower fragrance. Some work has already begun in this area, as several groups have created petunia and carnation plants that express the linalool synthase gene from C. Breweri. These experiments are still preliminary: For technical reasons, the gene was expressed everywhere in the plant, and although the transgenic plants did create small amounts of linalool, the level was below the threshold of detection for the human nose. Similar experiments in tobacco used genes for other monoterpene synthases, such as the one that produces limonene, but gave similar results.

G

The next generation of experiments, already in progress, includes sophisticated schemes that target the expression of scent genes specifically to flowers or other organs – such as special glands that can store antimicrobial or herbivore-repellent compounds.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a04d8c8-ad16-5ab6-ac66-f52e7d54c247', '7070e00c-a9e3-5311-8193-3afe234be386', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
1
Substance released to help plants themselves.
2
Scent helps plant’s pollination.
3
Practice on genetic experiment of fragrance.
4
Plant’s scent attracts herbivore’s enemy for protection.

1 ____ Substance released to help plants themselves.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b32f3db9-8324-5f85-8f29-e0198cfd2bd8', '9a04d8c8-ad16-5ab6-ac66-f52e7d54c247', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('235af328-7782-5899-a7c9-13c9b74e08c2', '9a04d8c8-ad16-5ab6-ac66-f52e7d54c247', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28dff625-b646-53f5-b701-51cb72e90ca5', '9a04d8c8-ad16-5ab6-ac66-f52e7d54c247', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0819062-ba35-5e77-ab0e-3782b72e5e7f', '9a04d8c8-ad16-5ab6-ac66-f52e7d54c247', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe8b67a3-5540-5237-a587-23795e8ef111', '9a04d8c8-ad16-5ab6-ac66-f52e7d54c247', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac864337-eebf-5a6a-87b8-0e8b9a416e0e', '9a04d8c8-ad16-5ab6-ac66-f52e7d54c247', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('839b8fb2-07be-529d-8c67-c500a23ac61f', '9a04d8c8-ad16-5ab6-ac66-f52e7d54c247', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9fbb8cf2-1e94-5dae-9430-99cb3d213fc9', '7070e00c-a9e3-5311-8193-3afe234be386', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
1
Substance released to help plants themselves.
2
Scent helps plant’s pollination.
3
Practice on genetic experiment of fragrance.
4
Plant’s scent attracts herbivore’s enemy for protection.

2 ____ Scent helps plant’s pollination.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae6d406e-3aec-5783-bf3f-df488313281f', '9fbb8cf2-1e94-5dae-9430-99cb3d213fc9', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('738081f0-097c-5581-851a-dc5476418f50', '9fbb8cf2-1e94-5dae-9430-99cb3d213fc9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95ec0eea-a5d3-56ce-9195-7a826da03584', '9fbb8cf2-1e94-5dae-9430-99cb3d213fc9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('506116df-23a5-5eb3-aa0c-1e9d60908729', '9fbb8cf2-1e94-5dae-9430-99cb3d213fc9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('939157ac-3bdc-5d84-b82d-2c352b5ec054', '9fbb8cf2-1e94-5dae-9430-99cb3d213fc9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13323107-5971-5ea1-b66d-8beabe27c598', '9fbb8cf2-1e94-5dae-9430-99cb3d213fc9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b77575fc-59cb-547f-8fb1-8ab0be1760ff', '9fbb8cf2-1e94-5dae-9430-99cb3d213fc9', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a706b44-b919-5e57-908c-cf4b3fcde724', '7070e00c-a9e3-5311-8193-3afe234be386', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
1
Substance released to help plants themselves.
2
Scent helps plant’s pollination.
3
Practice on genetic experiment of fragrance.
4
Plant’s scent attracts herbivore’s enemy for protection.

3 ____ Practice on genetic experiment of fragrance.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1df03e9b-1924-58ed-a6a8-7bd7b144c5e0', '9a706b44-b919-5e57-908c-cf4b3fcde724', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6a59361-7f00-508c-a7d6-54d65d7fd5c4', '9a706b44-b919-5e57-908c-cf4b3fcde724', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9affce09-4c2c-5fc7-9b99-9ac0479944b3', '9a706b44-b919-5e57-908c-cf4b3fcde724', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03666f5a-3fe2-5936-af18-94e0bb5c6035', '9a706b44-b919-5e57-908c-cf4b3fcde724', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4594859b-864f-5ea7-91d9-c85457724853', '9a706b44-b919-5e57-908c-cf4b3fcde724', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a6e4866-b787-5174-976b-96e61018f607', '9a706b44-b919-5e57-908c-cf4b3fcde724', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60b3d631-17b9-5cb8-8d87-d22cb9f55f68', '9a706b44-b919-5e57-908c-cf4b3fcde724', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1d152622-7396-5408-9447-6cbcf945ae9d', '7070e00c-a9e3-5311-8193-3afe234be386', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
1
Substance released to help plants themselves.
2
Scent helps plant’s pollination.
3
Practice on genetic experiment of fragrance.
4
Plant’s scent attracts herbivore’s enemy for protection.

4 ____ Plant’s scent attracts herbivore’s enemy for protection.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff4c4b6a-a97c-50b9-b79b-e16b14535494', '1d152622-7396-5408-9447-6cbcf945ae9d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('413661aa-d7ab-5796-a0bf-d61fd637e31e', '1d152622-7396-5408-9447-6cbcf945ae9d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbba2e99-de61-5a54-8974-50308743c65b', '1d152622-7396-5408-9447-6cbcf945ae9d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6581670-5998-57fd-a079-bdcac82b058c', '1d152622-7396-5408-9447-6cbcf945ae9d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('276f777c-400e-5561-adba-78118344386f', '1d152622-7396-5408-9447-6cbcf945ae9d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf46e1a8-f376-58af-9005-41b82013a682', '1d152622-7396-5408-9447-6cbcf945ae9d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efa854e4-e482-54c8-afbd-c68c783e5946', '1d152622-7396-5408-9447-6cbcf945ae9d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('30606739-1e42-5395-8fdb-e945cddc65d2', '7070e00c-a9e3-5311-8193-3afe234be386', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage 1?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
5
We have few evidence to support the idea that scent attracts pollinators.
6
Heliothis virescens
won’t eat those tobacco leaves on which they laid eggs.
7
Certain ants are attracted by volatiles to guard plants in rainforest.
8
Pollination only affects fruit trees’ production rather than other crop trees.

5 ____ We have few evidence to support the idea that scent attracts pollinators.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d582023a-5cf7-5ba0-b6c0-8237cd6bd42a', '30606739-1e42-5395-8fdb-e945cddc65d2', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0dc203be-9b18-5df6-9d0d-574cbbc43c36', '30606739-1e42-5395-8fdb-e945cddc65d2', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('189ea07c-89c3-51d4-8d93-57042e2221fa', '30606739-1e42-5395-8fdb-e945cddc65d2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('717fd16c-41c5-50bb-99be-d5fbbe41be78', '7070e00c-a9e3-5311-8193-3afe234be386', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage 1?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
5
We have few evidence to support the idea that scent attracts pollinators.
6
Heliothis virescens
won’t eat those tobacco leaves on which they laid eggs.
7
Certain ants are attracted by volatiles to guard plants in rainforest.
8
Pollination only affects fruit trees’ production rather than other crop trees.

6 ____ Heliothis virescens won’t eat those tobacco leaves on which they laid eggs.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6010735-8fde-5657-9385-426d67f3cc93', '717fd16c-41c5-50bb-99be-d5fbbe41be78', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df859c43-ac43-551e-9eda-b056dc4a16c9', '717fd16c-41c5-50bb-99be-d5fbbe41be78', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('045805f2-1161-5f5f-b638-687173e2b3ce', '717fd16c-41c5-50bb-99be-d5fbbe41be78', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6a9cbaea-c948-50a7-9eea-fd2a653fce2d', '7070e00c-a9e3-5311-8193-3afe234be386', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage 1?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
5
We have few evidence to support the idea that scent attracts pollinators.
6
Heliothis virescens
won’t eat those tobacco leaves on which they laid eggs.
7
Certain ants are attracted by volatiles to guard plants in rainforest.
8
Pollination only affects fruit trees’ production rather than other crop trees.

7 ____ Certain ants are attracted by volatiles to guard plants in rainforest.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ad3b1cd-429b-5153-b51d-4584d4a0c0a8', '6a9cbaea-c948-50a7-9eea-fd2a653fce2d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e851040b-d65b-5579-becf-c91ad2087818', '6a9cbaea-c948-50a7-9eea-fd2a653fce2d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a08cbdaa-f784-5d3c-9079-3ab29dc639ed', '6a9cbaea-c948-50a7-9eea-fd2a653fce2d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('61112cf7-093f-5250-8143-0f2a4a48f2ab', '7070e00c-a9e3-5311-8193-3afe234be386', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage 1?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
5
We have few evidence to support the idea that scent attracts pollinators.
6
Heliothis virescens
won’t eat those tobacco leaves on which they laid eggs.
7
Certain ants are attracted by volatiles to guard plants in rainforest.
8
Pollination only affects fruit trees’ production rather than other crop trees.

8 ____ Pollination only affects fruit trees’ production rather than other crop trees.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05819d05-f920-5579-b2c2-8135fc6be8e9', '61112cf7-093f-5250-8143-0f2a4a48f2ab', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6a6593e-7da5-5844-b520-f5f07ab25788', '61112cf7-093f-5250-8143-0f2a4a48f2ab', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11869dbd-a3c9-59ae-b4bf-5323708b4953', '61112cf7-093f-5250-8143-0f2a4a48f2ab', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6cfb8124-4e25-5783-83b0-a80cf4a95bfb', '7070e00c-a9e3-5311-8193-3afe234be386', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
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
9-13
on your answer sheet.
9
How do
wasps
protect plants when they are attracted by scents according to the passage?
A
plants induce wasps to prey herbivore.
B
wasps lay eggs into caterpillars.
C
wasps laid eggs on plants to expel herbivore.
D
offending caterpillars and wasp eggs coexist well.
10
What reason caused a number of honeybees decline in the United States.
A
pollination process
B
spread illness
C
crop trees are poisonous
D
grower’s overlook
11
Which of the following drawbacks about artificial fragrance is
NOT
mentioned in the passage?
A
it’s very expensive
B
it can’t tell correct information to pollinators.
C
it needs massive manual labour
D
it poisons local environment
12
The number of
$30 billion
quoted in the passage is to illustrate the fact that:
A
favorable perfumes are made from ornamental flowers.
B
traditional floriculture industry needs reform.
C
genetic operation on scent can make a vast profit.
D
Scent plays a significant role in Ornamental industry.
13
What is
weakness
of genetic experiments on fragrance?
A
Linalool level is too low to be smelt by nose
B
no progress made in linalool emission.
C
experiment on tobacco has a better result
D
transgenic plants produce intense scent

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0305ec46-cb71-5c8f-bbf7-e5c8b1d960d8', '7070e00c-a9e3-5311-8193-3afe234be386', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
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
9-13
on your answer sheet.
9
How do
wasps
protect plants when they are attracted by scents according to the passage?
A
plants induce wasps to prey herbivore.
B
wasps lay eggs into caterpillars.
C
wasps laid eggs on plants to expel herbivore.
D
offending caterpillars and wasp eggs coexist well.
10
What reason caused a number of honeybees decline in the United States.
A
pollination process
B
spread illness
C
crop trees are poisonous
D
grower’s overlook
11
Which of the following drawbacks about artificial fragrance is
NOT
mentioned in the passage?
A
it’s very expensive
B
it can’t tell correct information to pollinators.
C
it needs massive manual labour
D
it poisons local environment
12
The number of
$30 billion
quoted in the passage is to illustrate the fact that:
A
favorable perfumes are made from ornamental flowers.
B
traditional floriculture industry needs reform.
C
genetic operation on scent can make a vast profit.
D
Scent plays a significant role in Ornamental industry.
13
What is
weakness
of genetic experiments on fragrance?
A
Linalool level is too low to be smelt by nose
B
no progress made in linalool emission.
C
experiment on tobacco has a better result
D
transgenic plants produce intense scent

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('259080fb-9dfe-5dfd-81a9-d87189a9035f', '7070e00c-a9e3-5311-8193-3afe234be386', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
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
9-13
on your answer sheet.
9
How do
wasps
protect plants when they are attracted by scents according to the passage?
A
plants induce wasps to prey herbivore.
B
wasps lay eggs into caterpillars.
C
wasps laid eggs on plants to expel herbivore.
D
offending caterpillars and wasp eggs coexist well.
10
What reason caused a number of honeybees decline in the United States.
A
pollination process
B
spread illness
C
crop trees are poisonous
D
grower’s overlook
11
Which of the following drawbacks about artificial fragrance is
NOT
mentioned in the passage?
A
it’s very expensive
B
it can’t tell correct information to pollinators.
C
it needs massive manual labour
D
it poisons local environment
12
The number of
$30 billion
quoted in the passage is to illustrate the fact that:
A
favorable perfumes are made from ornamental flowers.
B
traditional floriculture industry needs reform.
C
genetic operation on scent can make a vast profit.
D
Scent plays a significant role in Ornamental industry.
13
What is
weakness
of genetic experiments on fragrance?
A
Linalool level is too low to be smelt by nose
B
no progress made in linalool emission.
C
experiment on tobacco has a better result
D
transgenic plants produce intense scent

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5007ff8d-ff7e-5f9b-bf2c-623d9d88eea0', '7070e00c-a9e3-5311-8193-3afe234be386', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
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
9-13
on your answer sheet.
9
How do
wasps
protect plants when they are attracted by scents according to the passage?
A
plants induce wasps to prey herbivore.
B
wasps lay eggs into caterpillars.
C
wasps laid eggs on plants to expel herbivore.
D
offending caterpillars and wasp eggs coexist well.
10
What reason caused a number of honeybees decline in the United States.
A
pollination process
B
spread illness
C
crop trees are poisonous
D
grower’s overlook
11
Which of the following drawbacks about artificial fragrance is
NOT
mentioned in the passage?
A
it’s very expensive
B
it can’t tell correct information to pollinators.
C
it needs massive manual labour
D
it poisons local environment
12
The number of
$30 billion
quoted in the passage is to illustrate the fact that:
A
favorable perfumes are made from ornamental flowers.
B
traditional floriculture industry needs reform.
C
genetic operation on scent can make a vast profit.
D
Scent plays a significant role in Ornamental industry.
13
What is
weakness
of genetic experiments on fragrance?
A
Linalool level is too low to be smelt by nose
B
no progress made in linalool emission.
C
experiment on tobacco has a better result
D
transgenic plants produce intense scent

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('94763136-4b9f-582e-8f4b-abd4ca4d01ee', '7070e00c-a9e3-5311-8193-3afe234be386', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
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
9-13
on your answer sheet.
9
How do
wasps
protect plants when they are attracted by scents according to the passage?
A
plants induce wasps to prey herbivore.
B
wasps lay eggs into caterpillars.
C
wasps laid eggs on plants to expel herbivore.
D
offending caterpillars and wasp eggs coexist well.
10
What reason caused a number of honeybees decline in the United States.
A
pollination process
B
spread illness
C
crop trees are poisonous
D
grower’s overlook
11
Which of the following drawbacks about artificial fragrance is
NOT
mentioned in the passage?
A
it’s very expensive
B
it can’t tell correct information to pollinators.
C
it needs massive manual labour
D
it poisons local environment
12
The number of
$30 billion
quoted in the passage is to illustrate the fact that:
A
favorable perfumes are made from ornamental flowers.
B
traditional floriculture industry needs reform.
C
genetic operation on scent can make a vast profit.
D
Scent plays a significant role in Ornamental industry.
13
What is
weakness
of genetic experiments on fragrance?
A
Linalool level is too low to be smelt by nose
B
no progress made in linalool emission.
C
experiment on tobacco has a better result
D
transgenic plants produce intense scent

Choose the correct letter, A , B , C or D .$md$, NULL);

COMMIT;
