BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-copy-your-neighbor-1328'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-copy-your-neighbor-1328';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-copy-your-neighbor-1328';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-copy-your-neighbor-1328';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('25287906-a876-58d4-ad59-d2c21a8c5b52', 'ielts-reading-copy-your-neighbor-1328', $t$Copy your neighbor$t$, $md$## Copy your neighbor

Nguồn:
- Test: https://mini-ielts.com/1328/reading/copy-your-neighbor
- Solution: https://mini-ielts.com/1328/view-solution/reading/copy-your-neighbor$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('eda3d3a6-2c73-5361-917a-287af63a8f97', '25287906-a876-58d4-ad59-d2c21a8c5b52', 1, $t$Reading — Copy your neighbor$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Copy your neighbor

A

THERE’S no animal that symbolises rainforest diversity quite as spectacularly as the tropical butterfly. Anyone lucky enough to see these creatures flitting between patches of sunlight cannot fail to be impressed by the variety of their patterns. But why do they display such colourful exuberance? Until recently, this was almost as pertinent a question as it had been when the 19th-century naturalists, armed only with butterfly nets and insatiable curiosity, battle through the rainforests. These early explorers soon realised that although some of the butterflies’ bright colours are there to attract a mate, others are warning signals. They send out a message to any predators: “Keep off, we’re poisonous.” And because wearing certain patterns affords protection, other species copy them. Biologists use the term “mimicry rings” for these clusters of impostors and their evolutionary idol.

B

But here’s the conundrum. “Classical mimicry theory says that only a single ring should be found in any one area,” explains George Beccaloni of the Natural History Museum, London. The idea is that in each locality there should be just the one pattern that best protects its wearers. Predators would quickly learn to avoid it and eventually, all mimetic species in a region should converge upon it. “The fact that this is patently not the case has been one of the major problems in mimicry research,” says Beccaloni. In pursuit of a solution to the mystery of mimetic exuberance, Beccaloni set off for one of the mega centres for butterfly diversity, the point where the western edge of the Amazon basin meets the foothills of the Andes in Ecuador. “It’s exceptionally rich, but comparatively well collected, so I pretty much knew what was there, says Beccaloni.” The trick was to work out how all the butterflies were organised and how this related to mimicry.

C

Working at the Jatun Sach Biological Research Station on the banks of the Rio Napo, Beccaloni focused his attention on a group of butterflies called ithomiines. These distant relatives of Britain’s Camberwell Beauty are abundant throughout Central and South America and the Caribbean. They are famous for their bright colours, toxic bodies and complex mimetic relationships. “They can comprise up to 85 per cent of the individuals in a mimicry ring and their patterns are mimicked not just by butterflies, but by other insects as diverse as damselflies and true bugs,” says Philip DeVries of the Milwaukee Public Museum’s Center for Biodiversity Studies.

D

Even though all ithomiines are poisonous, it is in their interests to evolve to look like one another because predators that learn to avoid one species will also avoid others that resemble it. This is known as Müllerian mimicry. Mimicry rings may also contain insects that are not toxic but gain protection by looking likes a model species that is: an adaptation called Batesian mimicry. So strong is an experienced predator’s avoidance response that even quite inept resemblance gives some protection. “Often there will be a whole series of species that mimic, with varying degrees of verisimilitude, a focal or model species,” says John Turner from the University of Leeds. “The results of these deceptions are some of the most exquisite examples of evolution known to science.” In addition to colour, many mimics copy behaviours and even the flight pattern of their model species.

E

But why are there so many different mimicry rings? One idea is that species flying at the same height in the forest canopy evolve to look like one another. “It had been suggested since the 1970s that mimicry complexes were stratified by flight height,” says DeVries. The idea is that wing colour patterns are camouflaged against the different patterns of light and shadow at each level in the canopy, providing the first line of defence against predators.” But the light patterns and wing patterns don’t match very well,” he says. And observations show that the insects do not shift in height as the day progresses and the light patterns change. Worse still, according to DeVries, this theory doesn’t explain why the model species is flying at that particular height in the first place.

F

“When I first went out to Ecuador, I didn’t believe the flight height hypothesis and set out to test it,” says Beccaloni. “A few weeks with the collecting net convinced me otherwise. They really flew that way.” What he didn’t accept, however, was the explanation about light patterns. “I thought if this idea really is true, can I can work out why it could help explain why there are so many different warning patterns in any not place. Then we might finally understand how they could evolve in such a complex way.” The job was complicated by the sheer diversity of species involved at Jatun Sach. Not only were there 56 ithomiine butterfly species divided among eight mimicry rings, but there were also 69 other insect species, including 34 day-flying moths and a damselfly, all in a 200-hectare study area. Like many entomologists before him, Beccaloni used a large bag-like net to capture his prey. This allowed him to sample the 2.5 metres immediately above the forest floor. Unlike many previous workers, he kept very precise notes on exactly where he caught his specimens.

G

The attention to detail paid off. Beccaloni found that the mimicry rings were flying at two quite separate altitudes. “Their use of the forest was quite distinctive,” he recalls. “For example, most members of the clear-winged mimicry ring would fly close to the forest floor, while the majority of the 12 species in the tiger-winged ring fly high up.” Each mimicry wing had its own characteristic flight height.

H

However, this being practice rather than theory, things were a bit fuzzy. “They’d spend the majority of their time flying at a certain height. But they’d also spend a smaller proportion of their time flying at other heights,” Beccaloni admits. Species weren’t stacked rigidly like passenger jets waiting to land, but they did appear to have preferred airspace in the forest. So far, so good, but he still hadn’t explained what causes the various groups of ithomiines and their chromatic consorts to fly in formations at these particular heights.

I

Then Beccaloni had a bright idea. “I started looking at the distribution of ithomiine larval food plants within the canopy,” he says. “For each one, I’d record the height to which the host plant grew and the height above the ground at which the eggs or larvae were found. Once I got them back to the field station’s lab, it was just a matter of keeping them alive until they pupated and then hatched into adults which I could identify.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('06be707e-6704-5bea-88f2-8fee87818012', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once
.
1
Criticism against flight height theory of butterfly
2
Explained why Beccaloni carried out research in Ecuador.
3
Different mimicry ring flies at different height
4
The method of catching butterfly by Beccaloni
5
Not all Mimicry patterns are toxic information sent out from insects.

1 ____ Criticism against flight height theory of butterfly$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45aa5539-2ce4-565e-b95e-b751ac971ee6', '06be707e-6704-5bea-88f2-8fee87818012', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd577b2d-dfae-5e77-87be-fd8c0cc3efe8', '06be707e-6704-5bea-88f2-8fee87818012', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('506e3f78-7b98-5322-8886-a5d7a3886485', '06be707e-6704-5bea-88f2-8fee87818012', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2eca196-c2b1-52ad-aaef-a194aba0bdb5', '06be707e-6704-5bea-88f2-8fee87818012', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('457ccbc0-b992-5547-90a6-cb20ac9dd711', '06be707e-6704-5bea-88f2-8fee87818012', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('837d111c-4bb3-5a89-865e-23ab1f653f1f', '06be707e-6704-5bea-88f2-8fee87818012', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fec3c7e4-15b7-5f8b-b02d-a0a08a8bf0a9', '06be707e-6704-5bea-88f2-8fee87818012', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c9acd1a-b1a2-50f0-b008-2f3d4d2674c3', '06be707e-6704-5bea-88f2-8fee87818012', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82ffc1ce-784f-561f-a552-97aad4fb50df', '06be707e-6704-5bea-88f2-8fee87818012', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('de995a66-1776-5c6a-b5e7-437f55fc239f', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once
.
1
Criticism against flight height theory of butterfly
2
Explained why Beccaloni carried out research in Ecuador.
3
Different mimicry ring flies at different height
4
The method of catching butterfly by Beccaloni
5
Not all Mimicry patterns are toxic information sent out from insects.

2 ____ Explained why Beccaloni carried out research in Ecuador.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('751b0c68-aad6-5e94-a8ec-213a28252d89', 'de995a66-1776-5c6a-b5e7-437f55fc239f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('985cfc5e-a8ad-5a4c-876b-fed60edb6aa8', 'de995a66-1776-5c6a-b5e7-437f55fc239f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d4662f4-dec5-5b24-919e-e36785a0635b', 'de995a66-1776-5c6a-b5e7-437f55fc239f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbbf4d57-089b-5254-8943-2a58fcc73471', 'de995a66-1776-5c6a-b5e7-437f55fc239f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5147a2a8-3f5a-55ff-9762-be04a3f2d951', 'de995a66-1776-5c6a-b5e7-437f55fc239f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('783ab33a-0101-523e-9514-52be306fc167', 'de995a66-1776-5c6a-b5e7-437f55fc239f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53440ca6-a0d2-52fa-abd3-7418735b3898', 'de995a66-1776-5c6a-b5e7-437f55fc239f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9587271-8fa4-548b-89a0-304aded26fca', 'de995a66-1776-5c6a-b5e7-437f55fc239f', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d699af77-7a4f-5de7-8bb5-fe2c499bc53c', 'de995a66-1776-5c6a-b5e7-437f55fc239f', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ec9a3db7-50a6-5356-96f7-326b892eec19', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once
.
1
Criticism against flight height theory of butterfly
2
Explained why Beccaloni carried out research in Ecuador.
3
Different mimicry ring flies at different height
4
The method of catching butterfly by Beccaloni
5
Not all Mimicry patterns are toxic information sent out from insects.

3 ____ Different mimicry ring flies at different height$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af8eb43a-d915-5485-b864-e66bc94af8b9', 'ec9a3db7-50a6-5356-96f7-326b892eec19', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3fe4751e-f885-5e9c-a825-02e2260cd8e2', 'ec9a3db7-50a6-5356-96f7-326b892eec19', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b58b563f-3fea-5735-92f0-8b3251e716de', 'ec9a3db7-50a6-5356-96f7-326b892eec19', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfb2dc66-2cb6-585c-b648-d06e227fb926', 'ec9a3db7-50a6-5356-96f7-326b892eec19', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb0267a6-b767-557e-9426-019f88d930fd', 'ec9a3db7-50a6-5356-96f7-326b892eec19', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('500e8bca-efcd-589e-a224-d4ee4a49a6a4', 'ec9a3db7-50a6-5356-96f7-326b892eec19', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c12b8c38-442d-536e-b677-8d354f0f0bc9', 'ec9a3db7-50a6-5356-96f7-326b892eec19', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ca02375-a836-5314-a686-86b78d851d07', 'ec9a3db7-50a6-5356-96f7-326b892eec19', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc6883c5-7877-5b16-a8a8-c15d69cd5488', 'ec9a3db7-50a6-5356-96f7-326b892eec19', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b23d91d4-3c67-54a0-8e4a-29f90e90d772', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once
.
1
Criticism against flight height theory of butterfly
2
Explained why Beccaloni carried out research in Ecuador.
3
Different mimicry ring flies at different height
4
The method of catching butterfly by Beccaloni
5
Not all Mimicry patterns are toxic information sent out from insects.

4 ____ The method of catching butterfly by Beccaloni$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22082c8e-55e0-5e37-bc60-dc2313000163', 'b23d91d4-3c67-54a0-8e4a-29f90e90d772', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7584e962-8c31-51e3-b464-c5d24e27cc2d', 'b23d91d4-3c67-54a0-8e4a-29f90e90d772', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9c5bdfa-effc-5dcc-91b0-f5efe9d9a712', 'b23d91d4-3c67-54a0-8e4a-29f90e90d772', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7cecc55-9f68-5256-bf55-56853a1228df', 'b23d91d4-3c67-54a0-8e4a-29f90e90d772', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97dfb58d-4a1c-541b-a72b-97af7fe72e31', 'b23d91d4-3c67-54a0-8e4a-29f90e90d772', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('526b8fa9-2230-5e5d-969d-5647201e0979', 'b23d91d4-3c67-54a0-8e4a-29f90e90d772', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('511af0e0-026e-5c16-924d-061fd1527dfb', 'b23d91d4-3c67-54a0-8e4a-29f90e90d772', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2556ab4d-80d8-5037-9667-df3e65b6246c', 'b23d91d4-3c67-54a0-8e4a-29f90e90d772', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9dca78c-605f-5170-9388-779b3e98d433', 'b23d91d4-3c67-54a0-8e4a-29f90e90d772', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('555213f2-b06b-508b-890f-25278447f30f', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once
.
1
Criticism against flight height theory of butterfly
2
Explained why Beccaloni carried out research in Ecuador.
3
Different mimicry ring flies at different height
4
The method of catching butterfly by Beccaloni
5
Not all Mimicry patterns are toxic information sent out from insects.

5 ____ Not all Mimicry patterns are toxic information sent out from insects.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e5ddf50-a96c-5bb6-bfdf-bf7e8fac6a8c', '555213f2-b06b-508b-890f-25278447f30f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98b671b9-3710-5503-a728-e62fa2880368', '555213f2-b06b-508b-890f-25278447f30f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db1652ba-a5de-56b4-8328-f21a5c228db1', '555213f2-b06b-508b-890f-25278447f30f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f48675c0-1ba7-5d37-a63f-9ddfd04e75c7', '555213f2-b06b-508b-890f-25278447f30f', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61774243-fbd8-53ac-9292-bbd861ab61ca', '555213f2-b06b-508b-890f-25278447f30f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5700206-e6ae-5f20-870f-a15fd1c0f70f', '555213f2-b06b-508b-890f-25278447f30f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77fe51b0-31cb-5b0b-9dad-70e29b75987b', '555213f2-b06b-508b-890f-25278447f30f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3afa3fc-0f18-529c-b718-02a0d75fc221', '555213f2-b06b-508b-890f-25278447f30f', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a48ddf6d-8e37-560f-a685-b42bd920a05d', '555213f2-b06b-508b-890f-25278447f30f', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a562ddd3-9d66-551e-88c7-b8b0ba7cb81d', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-11
Questions 6-11
Do the following statements agree with the information given in Reading Passage 1?
In boxes
6-11
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
All butterflies’ colours of wings reflect the sense of warning to other predators.
7
Insects may imitate butterflies’ wing pattern as well.
8
Flying Altitude of the butterfly is determined by their food.
9
Beccaloni agreed with the flight height hypothesis and decided to reassure its validity.
10
Jatun Sacha has the richest diversity of breeds in the world.
11
Beccaloni has more detailed records on the location of butterfly collection than others.

6 ____ All butterflies’ colours of wings reflect the sense of warning to other predators.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff3f198d-97b5-5fc6-868f-71ed936b85b6', 'a562ddd3-9d66-551e-88c7-b8b0ba7cb81d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f27ea0ac-4d9d-5fcf-8ad3-61d7c71e4d6f', 'a562ddd3-9d66-551e-88c7-b8b0ba7cb81d', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e767098-4d10-5ddc-bf7a-043f0125e276', 'a562ddd3-9d66-551e-88c7-b8b0ba7cb81d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('35fa0e98-a0b5-55e5-8b03-28a482c74bfe', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-11
Questions 6-11
Do the following statements agree with the information given in Reading Passage 1?
In boxes
6-11
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
All butterflies’ colours of wings reflect the sense of warning to other predators.
7
Insects may imitate butterflies’ wing pattern as well.
8
Flying Altitude of the butterfly is determined by their food.
9
Beccaloni agreed with the flight height hypothesis and decided to reassure its validity.
10
Jatun Sacha has the richest diversity of breeds in the world.
11
Beccaloni has more detailed records on the location of butterfly collection than others.

7 ____ Insects may imitate butterflies’ wing pattern as well.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf58c446-8c62-51fd-aa24-815fefeb7970', '35fa0e98-a0b5-55e5-8b03-28a482c74bfe', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f63a8642-9403-556d-862b-74567f490fcc', '35fa0e98-a0b5-55e5-8b03-28a482c74bfe', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16cf1684-fc94-5b11-83d5-ebd062fd3f12', '35fa0e98-a0b5-55e5-8b03-28a482c74bfe', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7447bba6-a30f-55bb-8eef-bdad2ac74af3', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-11
Questions 6-11
Do the following statements agree with the information given in Reading Passage 1?
In boxes
6-11
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
All butterflies’ colours of wings reflect the sense of warning to other predators.
7
Insects may imitate butterflies’ wing pattern as well.
8
Flying Altitude of the butterfly is determined by their food.
9
Beccaloni agreed with the flight height hypothesis and decided to reassure its validity.
10
Jatun Sacha has the richest diversity of breeds in the world.
11
Beccaloni has more detailed records on the location of butterfly collection than others.

8 ____ Flying Altitude of the butterfly is determined by their food.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bfcd542-ac99-5d4d-bd4d-0d997b26a9db', '7447bba6-a30f-55bb-8eef-bdad2ac74af3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd2936f0-488d-5625-89b7-f64912008d0a', '7447bba6-a30f-55bb-8eef-bdad2ac74af3', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49d0cab2-76ee-52ba-92c8-0219527f97c2', '7447bba6-a30f-55bb-8eef-bdad2ac74af3', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7bda441f-dce6-52c0-ada2-9afa2df0fabb', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-11
Questions 6-11
Do the following statements agree with the information given in Reading Passage 1?
In boxes
6-11
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
All butterflies’ colours of wings reflect the sense of warning to other predators.
7
Insects may imitate butterflies’ wing pattern as well.
8
Flying Altitude of the butterfly is determined by their food.
9
Beccaloni agreed with the flight height hypothesis and decided to reassure its validity.
10
Jatun Sacha has the richest diversity of breeds in the world.
11
Beccaloni has more detailed records on the location of butterfly collection than others.

9 ____ Beccaloni agreed with the flight height hypothesis and decided to reassure its validity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd940ef1-5eac-5269-bddf-1b45d9990f9c', '7bda441f-dce6-52c0-ada2-9afa2df0fabb', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78ecb289-d6a2-5696-8c4f-3cfb20c78bbc', '7bda441f-dce6-52c0-ada2-9afa2df0fabb', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93a4e04a-97a6-54a6-b240-4f904c1040a1', '7bda441f-dce6-52c0-ada2-9afa2df0fabb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c54efcf7-2385-5188-acb5-5868d3e1b1af', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-11
Questions 6-11
Do the following statements agree with the information given in Reading Passage 1?
In boxes
6-11
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
All butterflies’ colours of wings reflect the sense of warning to other predators.
7
Insects may imitate butterflies’ wing pattern as well.
8
Flying Altitude of the butterfly is determined by their food.
9
Beccaloni agreed with the flight height hypothesis and decided to reassure its validity.
10
Jatun Sacha has the richest diversity of breeds in the world.
11
Beccaloni has more detailed records on the location of butterfly collection than others.

10 ____ Jatun Sacha has the richest diversity of breeds in the world.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4315b8a8-da1b-579c-a10e-18ebd328e7ca', 'c54efcf7-2385-5188-acb5-5868d3e1b1af', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('427515da-55a8-5271-8d5a-3da20d76081e', 'c54efcf7-2385-5188-acb5-5868d3e1b1af', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfd99b34-f754-5bf4-ac9c-c046a9df1d25', 'c54efcf7-2385-5188-acb5-5868d3e1b1af', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5e6d02f7-b822-553c-9a49-e67cf7ab0a76', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 6-11
Questions 6-11
Do the following statements agree with the information given in Reading Passage 1?
In boxes
6-11
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
All butterflies’ colours of wings reflect the sense of warning to other predators.
7
Insects may imitate butterflies’ wing pattern as well.
8
Flying Altitude of the butterfly is determined by their food.
9
Beccaloni agreed with the flight height hypothesis and decided to reassure its validity.
10
Jatun Sacha has the richest diversity of breeds in the world.
11
Beccaloni has more detailed records on the location of butterfly collection than others.

11 ____ Beccaloni has more detailed records on the location of butterfly collection than others.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e204116-a3f2-509d-a20d-4aa2a8cea6c7', '5e6d02f7-b822-553c-9a49-e67cf7ab0a76', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26a97ff8-073f-51d9-9e88-ee78628f7bf4', '5e6d02f7-b822-553c-9a49-e67cf7ab0a76', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ea4cbb0-e447-53b5-b3a6-1c29d00ecd89', '5e6d02f7-b822-553c-9a49-e67cf7ab0a76', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b18ea9de-6bfb-5377-b1aa-7a7195341e8d', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 12-13
Questions 12-13
Choose the correct letter
A
,
B
,
C
or
D
Write your answers in boxes
12-13
on your answer sheet.
12
Which is correct about butterflies flight altitude?
A
Flight height theory already established
B
Butterfly always flies at a certain height
C
It is like the airplane’s flying phenomenon
D
Each butterfly has its own favorable height
13
Which is correct about Beccaloni next investigation after flight height?
A
Some certain statistics have already been collected
B
Try to find connections between larval height and adult ones
C
It’s very difficult to raise butterfly larval
D
Different larval favors different kinds of trees

Choose the correct letter A , B , C or D Write your answers in boxes 12-13 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9f78f53d-c98a-59b1-93ef-e1c1e8f2eb20', 'eda3d3a6-2c73-5361-917a-287af63a8f97', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 12-13
Questions 12-13
Choose the correct letter
A
,
B
,
C
or
D
Write your answers in boxes
12-13
on your answer sheet.
12
Which is correct about butterflies flight altitude?
A
Flight height theory already established
B
Butterfly always flies at a certain height
C
It is like the airplane’s flying phenomenon
D
Each butterfly has its own favorable height
13
Which is correct about Beccaloni next investigation after flight height?
A
Some certain statistics have already been collected
B
Try to find connections between larval height and adult ones
C
It’s very difficult to raise butterfly larval
D
Different larval favors different kinds of trees

Choose the correct letter A , B , C or D Write your answers in boxes 12-13 on your answer sheet.$md$, NULL);

COMMIT;
