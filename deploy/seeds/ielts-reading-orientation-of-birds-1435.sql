BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-orientation-of-birds-1435'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-orientation-of-birds-1435';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-orientation-of-birds-1435';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-orientation-of-birds-1435';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d07d37c2-0d58-5930-a5b8-b7ee5a055641', 'ielts-reading-orientation-of-birds-1435', $t$Orientation of birds$t$, $md$## Orientation of birds

Nguồn:
- Test: https://mini-ielts.com/1435/reading/orientation-of-birds
- Solution: https://mini-ielts.com/1435/view-solution/reading/orientation-of-birds$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('195bf218-4f7e-5d40-9a32-81304a1203c9', 'd07d37c2-0d58-5930-a5b8-b7ee5a055641', 1, $t$Reading — Orientation of birds$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Orientation of birds

A For many of US, the way birds are able to orientate is both astounding and difficult to appreciate fully. For instance, the annual migration of tire golden plover of the Pacific takes it from Alaska to Hawaii on a flight of well over 3000 kilometres, and if it were to deviate by only one degree, it would miss the island on which it nests.

B The first systematic studies on orientation in birds were made possible by the ‘homing instinct’ exhibited by so many species. Birds are caught at a time when they show an attachment to their territory, especially during the nesting season. They are taken to some spot, released, and the percentage of returns is recorded. The distance can be varied, and the direction, as well as the method of transporting them, and then the influence of climatic and other factors on their ability to find their way home can be studied. These experiments have shown a wide variation in ability to home, and three types of homing behaviour have been identified.

C In the first type, birds methodically explore the area in which they are released until they pick up some familiar feature, and then they quickly find their way back to the nest. Such birds possess a highly developed visual memory, as experiments with pigeons have shown. Domestic pigeons have been trained to peck at a certain point on an aerial photograph, with a system of rewards, and four years later the birds were still able to respond to this training when placed on the aerial photograph. Birds’ eyes have a power of resolution two to three times greater than ours, enabling them to pick up very fine details. If a bird uses only this type of homing behaviour, however, it can only succeed if the point of release is not too far away. If the birds are transported 800 kilometres from their nest, it is only by good fortune that they find their way back as a result of long exploratory flights. Usually, the area known to a bird is its feeding territory. Released within this area, the birds soon make their return; release them outside it and far fewer return. However, if a bird is released for a second time in the same place, its visual memory comes into play, and the bird, no longer requiring tedious exploratory flights, will return much more quickly.

D The second type of homing behaviour is shown by birds that are capable of choosing their flight direction and holding to it for the rest of their journey. How do they decide what direction to take? They appear to choose their normal migration direction even if they are released in a different place from their usual stalling point. If, for example, birds which normally fly to the north-east to reach latitude 45 degrees north are released at that latitude, they will immediately start flying north-east anyway. So if they’re released further to the west, they’ll maintain the correct direction, but fly west of their destination, and so fail to arrive.

E The third type of homing behaviour shows the highest degree of orientation. Released at one point, the birds immediately take stock of it, compare its position with that of the nest, decide on the direction and fly off. This happens even if the birds are in a country right off their migration routes, where they have never been before. In one example, a laysan albatross returned to its nesting area on Midway Island in the middle of the Pacific, having flown over 5000 kilometres from the west coastal of the USA in just over ten days. This is a perfect example of the third type of homing, for the albatross clearly couldn’t rely on any landmarks over the vast expanse of the Pacific Ocean.

F The percentage of successful birds varies greatly, being highest in those species with a strong migratory behaviour. Thus the lesser black-backed gull is more migratory than the herring gull and more often reaches ‘home’. Great migrants such as the swift have the highest percentage of returns. In one case, seven out of nine alpine swifts were recaptured at their nests after being displaced some 1400 kilometres; one made the journey in three days.

G What part does heredity play in all this? Two research studies suggest that instinctive, i.e. genetically inherited, behaviour patterns play a part in navigation. The first was carried out by Ernst Schuz and it is highly significant. Schuz caught first year European storks and released them later, after the departure of the adult storks at a time when they normally make their south-west autumn migration to Africa. The recaptures showed that, in spite of thefact that there were no adults to guide them, the birds unanimously headed south-west. This was a most striking finding, for it showed that the birds had an innate and unlearned attraction for the African wintering area that they have occupied for thousands of years.

H The case of starlings is a little different. These birds have a great aptitude for homing, but this behaviour differs in the different age groups. Birds that were shifted to the south-east of their normal migration route split into two lots. The adults, in full possession of their gift for orientation, found their wintering area by modifying their direction by 90 degrees, whereas the juveniles sought their winter quarters to the south-east of their real position.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d9483744-1d99-5cf6-a505-b21c0665d51e', '195bf218-4f7e-5d40-9a32-81304a1203c9', 1, 'SHORT_ANSWER', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the summery below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Types of homing behaviour
First type:
Birds rely on their sophisticated
1
. However, they are generally most successful if they are released within their feeding territory.
Second type:
Birds select their accustomed
2
, no matter where they are released. As a result, they may miss their
3
Third type:
Birds orientate correctly, even when they are released in an unfamiliar place and have no
4
to make use of. One bird with this type of skill is the
5

Birds rely on their sophisticated 1 ____ . However, they are generally most successful if they are released within their feeding territory.$md$, NULL, ARRAY['.*visual.*memory.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c273aad0-3212-5471-bdd0-1f303deb816a', '195bf218-4f7e-5d40-9a32-81304a1203c9', 2, 'SHORT_ANSWER', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the summery below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Types of homing behaviour
First type:
Birds rely on their sophisticated
1
. However, they are generally most successful if they are released within their feeding territory.
Second type:
Birds select their accustomed
2
, no matter where they are released. As a result, they may miss their
3
Third type:
Birds orientate correctly, even when they are released in an unfamiliar place and have no
4
to make use of. One bird with this type of skill is the
5

Birds select their accustomed 2 ____ , no matter where they are released. As a result, they may miss their 3 ____$md$, NULL, ARRAY['.*migration.*direction.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ad3d9e2a-69b4-581b-9f79-0ee667191e93', '195bf218-4f7e-5d40-9a32-81304a1203c9', 3, 'SHORT_ANSWER', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the summery below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Types of homing behaviour
First type:
Birds rely on their sophisticated
1
. However, they are generally most successful if they are released within their feeding territory.
Second type:
Birds select their accustomed
2
, no matter where they are released. As a result, they may miss their
3
Third type:
Birds orientate correctly, even when they are released in an unfamiliar place and have no
4
to make use of. One bird with this type of skill is the
5

Birds select their accustomed 2 ____ , no matter where they are released. As a result, they may miss their 3 ____$md$, NULL, ARRAY['.*migration.*direction.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c79d5f63-facd-58e4-839a-01e039ce2304', '195bf218-4f7e-5d40-9a32-81304a1203c9', 4, 'SHORT_ANSWER', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the summery below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Types of homing behaviour
First type:
Birds rely on their sophisticated
1
. However, they are generally most successful if they are released within their feeding territory.
Second type:
Birds select their accustomed
2
, no matter where they are released. As a result, they may miss their
3
Third type:
Birds orientate correctly, even when they are released in an unfamiliar place and have no
4
to make use of. One bird with this type of skill is the
5

Birds orientate correctly, even when they are released in an unfamiliar place and have no 4 ____ to make use of. One bird with this type of skill is the 5 ____$md$, NULL, ARRAY['.*landmarks.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1bdc015a-2e5d-51d5-a674-38aca0f39d1a', '195bf218-4f7e-5d40-9a32-81304a1203c9', 5, 'SHORT_ANSWER', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the summery below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 1-5 on your answer sheet.
Types of homing behaviour
First type:
Birds rely on their sophisticated
1
. However, they are generally most successful if they are released within their feeding territory.
Second type:
Birds select their accustomed
2
, no matter where they are released. As a result, they may miss their
3
Third type:
Birds orientate correctly, even when they are released in an unfamiliar place and have no
4
to make use of. One bird with this type of skill is the
5

Birds orientate correctly, even when they are released in an unfamiliar place and have no 4 ____ to make use of. One bird with this type of skill is the 5 ____$md$, NULL, ARRAY['.*landmarks.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b6fc9e41-7506-581a-9db3-6e3c382eb8f0', '195bf218-4f7e-5d40-9a32-81304a1203c9', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 7-9
Questions 7-9
Reading Passage has eight paragraphs,
A-H
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 7-9 on your answer sheet.
NB
You may use any letter more than once.
6
the effects of distance on some birds’ ability to find their nests
7
a methodology for testing the general ability of birds to find their nests
8
one aspect of physical ability in humans and birds
9
how some birds’ migration was delayed for experimental purposes

6 ____ the effects of distance on some birds’ ability to find their nests$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1fd3d4d-5cb9-55a3-80da-187411b852f0', 'b6fc9e41-7506-581a-9db3-6e3c382eb8f0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('869e20f2-760d-5078-8f0d-edd5e1bb5411', 'b6fc9e41-7506-581a-9db3-6e3c382eb8f0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9278d841-7eee-52b0-8cea-7239a0546c02', 'b6fc9e41-7506-581a-9db3-6e3c382eb8f0', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59f51886-a05c-5506-babe-3740b3e8e900', 'b6fc9e41-7506-581a-9db3-6e3c382eb8f0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2a17312-5a81-5413-8369-1d2be7c821b0', 'b6fc9e41-7506-581a-9db3-6e3c382eb8f0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17a2d2d8-0feb-5d29-a7db-bd13e7f34395', 'b6fc9e41-7506-581a-9db3-6e3c382eb8f0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f62f6b8d-9494-5d4f-8cd9-989be8098ce6', 'b6fc9e41-7506-581a-9db3-6e3c382eb8f0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb5d1092-4cbf-5462-aaf0-7f2c4a9a6bce', 'b6fc9e41-7506-581a-9db3-6e3c382eb8f0', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ed764bb3-d2ab-5c5f-9f63-9dd2ae770028', '195bf218-4f7e-5d40-9a32-81304a1203c9', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Reading Passage has eight paragraphs,
A-H
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 7-9 on your answer sheet.
NB
You may use any letter more than once.
6
the effects of distance on some birds’ ability to find their nests
7
a methodology for testing the general ability of birds to find their nests
8
one aspect of physical ability in humans and birds
9
how some birds’ migration was delayed for experimental purposes

7 ____ a methodology for testing the general ability of birds to find their nests$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ef33a52-dfd5-5f79-8dea-010492fb3953', 'ed764bb3-d2ab-5c5f-9f63-9dd2ae770028', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d202123-bc82-54a3-8b41-cb0a1b1a156e', 'ed764bb3-d2ab-5c5f-9f63-9dd2ae770028', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e06867f-9c94-5506-8c0c-a753926d9beb', 'ed764bb3-d2ab-5c5f-9f63-9dd2ae770028', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74d52bfd-5d78-55e7-a50f-f0292bfaf6ab', 'ed764bb3-d2ab-5c5f-9f63-9dd2ae770028', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f37e1b2-c35f-5a99-b749-83a308745d0d', 'ed764bb3-d2ab-5c5f-9f63-9dd2ae770028', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3bb27f7-31f6-5040-a9a8-0c02f8caec56', 'ed764bb3-d2ab-5c5f-9f63-9dd2ae770028', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82be03f2-efc0-5fa7-9c32-eeb9db3ee4a7', 'ed764bb3-d2ab-5c5f-9f63-9dd2ae770028', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca507cf3-8f1c-5856-a164-171e78143831', 'ed764bb3-d2ab-5c5f-9f63-9dd2ae770028', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0cede6cf-7f5f-5f91-8058-1085bfc72dac', '195bf218-4f7e-5d40-9a32-81304a1203c9', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Reading Passage has eight paragraphs,
A-H
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 7-9 on your answer sheet.
NB
You may use any letter more than once.
6
the effects of distance on some birds’ ability to find their nests
7
a methodology for testing the general ability of birds to find their nests
8
one aspect of physical ability in humans and birds
9
how some birds’ migration was delayed for experimental purposes

8 ____ one aspect of physical ability in humans and birds$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0401947-686f-56f5-9b34-d2710e0cd116', '0cede6cf-7f5f-5f91-8058-1085bfc72dac', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffc69497-d6ab-50a0-85c4-9593764c303b', '0cede6cf-7f5f-5f91-8058-1085bfc72dac', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a964c157-1cee-5507-abbd-39485ac17e82', '0cede6cf-7f5f-5f91-8058-1085bfc72dac', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('672ff6fa-3fd1-5ab4-bf02-7f9c888382f2', '0cede6cf-7f5f-5f91-8058-1085bfc72dac', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c70d84b0-27d7-5e7d-a84d-8e88a2c9235c', '0cede6cf-7f5f-5f91-8058-1085bfc72dac', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b004987-b863-50f2-a6f6-b0da8be69a1f', '0cede6cf-7f5f-5f91-8058-1085bfc72dac', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc34d5d6-975f-5d1f-ba25-6d3225ab5d31', '0cede6cf-7f5f-5f91-8058-1085bfc72dac', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8a7bc57-3717-51d4-bb1a-5aa4ba41f5db', '0cede6cf-7f5f-5f91-8058-1085bfc72dac', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dbf68d79-948a-50cd-bd51-5695735f7224', '195bf218-4f7e-5d40-9a32-81304a1203c9', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Reading Passage has eight paragraphs,
A-H
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 7-9 on your answer sheet.
NB
You may use any letter more than once.
6
the effects of distance on some birds’ ability to find their nests
7
a methodology for testing the general ability of birds to find their nests
8
one aspect of physical ability in humans and birds
9
how some birds’ migration was delayed for experimental purposes

9 ____ how some birds’ migration was delayed for experimental purposes$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14c72db3-94ed-59d0-9af0-241a973f8808', 'dbf68d79-948a-50cd-bd51-5695735f7224', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce643757-105e-5796-925c-191c425a2975', 'dbf68d79-948a-50cd-bd51-5695735f7224', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7066ceeb-5f49-52ff-a7e9-299b6940dd10', 'dbf68d79-948a-50cd-bd51-5695735f7224', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc00c559-74f4-5828-916e-ccff57e163bb', 'dbf68d79-948a-50cd-bd51-5695735f7224', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b4a75e5-3bef-5023-b803-15a239fbad09', 'dbf68d79-948a-50cd-bd51-5695735f7224', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f54522ed-dd8e-57b7-935e-875ecc5218ea', 'dbf68d79-948a-50cd-bd51-5695735f7224', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1f15493-cf20-5eed-ada0-127f30a85339', 'dbf68d79-948a-50cd-bd51-5695735f7224', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63cea128-cf13-5236-8188-39500dbab0e4', 'dbf68d79-948a-50cd-bd51-5695735f7224', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3abc19d3-b731-5471-baf1-a7203a081350', '195bf218-4f7e-5d40-9a32-81304a1203c9', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Look at the following types of birds (Questions 10-13) and the list of points which the author wishes to illustrate below.
Match each bird with the point which it illustrates, A-G.
Write the correct letter, A-G, in boxes 10-13 on your answer sheet.
10
domestic pigeon
11
alpine swift
12
European stork
13
starling
List of points which the author wishes to illustrate
A
an ability to orientate without previous training
B
the speed at which birds can fly
C
the ability to remember things seen previously
D
the effect of age on homing ability
E
the strength required to fly a great distance
F
a high success rate in finding nests
G
the importance of seasonal cues for migrating birds

10 ____ domestic pigeon$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a67a095e-085b-55ba-9ea6-3cc845b4663b', '3abc19d3-b731-5471-baf1-a7203a081350', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a0b85a9-639e-5898-845a-6592093fd548', '3abc19d3-b731-5471-baf1-a7203a081350', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbed21d5-daf9-504b-b263-baf0509614b4', '3abc19d3-b731-5471-baf1-a7203a081350', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4206d3e3-ddaa-5ef7-b43a-185020780be2', '3abc19d3-b731-5471-baf1-a7203a081350', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39598b6f-0d74-5249-863d-e375f3ddbb23', '3abc19d3-b731-5471-baf1-a7203a081350', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ecbb4f3-b978-5ff6-a964-9c26fa573494', '3abc19d3-b731-5471-baf1-a7203a081350', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebd73345-305d-53ff-9d62-4bb81516e63d', '3abc19d3-b731-5471-baf1-a7203a081350', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('581bdaee-5df7-527e-8f73-954b48c2b6be', '195bf218-4f7e-5d40-9a32-81304a1203c9', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Look at the following types of birds (Questions 10-13) and the list of points which the author wishes to illustrate below.
Match each bird with the point which it illustrates, A-G.
Write the correct letter, A-G, in boxes 10-13 on your answer sheet.
10
domestic pigeon
11
alpine swift
12
European stork
13
starling
List of points which the author wishes to illustrate
A
an ability to orientate without previous training
B
the speed at which birds can fly
C
the ability to remember things seen previously
D
the effect of age on homing ability
E
the strength required to fly a great distance
F
a high success rate in finding nests
G
the importance of seasonal cues for migrating birds

11 ____ alpine swift$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eda5f377-0a2e-568d-b3db-2ff6cdb1685c', '581bdaee-5df7-527e-8f73-954b48c2b6be', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ed844bc-dbad-5cd0-9ad7-5ca348704b8d', '581bdaee-5df7-527e-8f73-954b48c2b6be', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b4c77ec-94b6-55b2-9d4a-6ec93e72db44', '581bdaee-5df7-527e-8f73-954b48c2b6be', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca4defaa-3457-5aba-8938-9528b3c73511', '581bdaee-5df7-527e-8f73-954b48c2b6be', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5e6648c-9c52-5062-8a94-38d5698ed21e', '581bdaee-5df7-527e-8f73-954b48c2b6be', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ab27eb7-74a1-5e85-acb5-1f6132584509', '581bdaee-5df7-527e-8f73-954b48c2b6be', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38524026-1dc3-544f-bb2e-9c9577bc81b4', '581bdaee-5df7-527e-8f73-954b48c2b6be', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9cd8f6ad-017f-536a-997b-ca73cbf3007f', '195bf218-4f7e-5d40-9a32-81304a1203c9', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Look at the following types of birds (Questions 10-13) and the list of points which the author wishes to illustrate below.
Match each bird with the point which it illustrates, A-G.
Write the correct letter, A-G, in boxes 10-13 on your answer sheet.
10
domestic pigeon
11
alpine swift
12
European stork
13
starling
List of points which the author wishes to illustrate
A
an ability to orientate without previous training
B
the speed at which birds can fly
C
the ability to remember things seen previously
D
the effect of age on homing ability
E
the strength required to fly a great distance
F
a high success rate in finding nests
G
the importance of seasonal cues for migrating birds

12 ____ European stork$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0214af1-ce3b-5d81-b5c1-59689f0cf6b3', '9cd8f6ad-017f-536a-997b-ca73cbf3007f', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9802fa9-7aa2-54a0-a00c-ee32ee5937ee', '9cd8f6ad-017f-536a-997b-ca73cbf3007f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d743dd8-03f2-5cb9-bd73-a3c54043dc4d', '9cd8f6ad-017f-536a-997b-ca73cbf3007f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41ee6427-b65d-533d-a0c3-4b98089e0b83', '9cd8f6ad-017f-536a-997b-ca73cbf3007f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5dd8fb5a-ed39-552b-8d5b-c1db252f00b8', '9cd8f6ad-017f-536a-997b-ca73cbf3007f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00311b85-5c52-5e92-8431-12055bedca26', '9cd8f6ad-017f-536a-997b-ca73cbf3007f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f0564be-a084-54c9-8758-aada9c7d9e55', '9cd8f6ad-017f-536a-997b-ca73cbf3007f', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1003eece-42f4-559d-8d83-027880aa07ce', '195bf218-4f7e-5d40-9a32-81304a1203c9', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Look at the following types of birds (Questions 10-13) and the list of points which the author wishes to illustrate below.
Match each bird with the point which it illustrates, A-G.
Write the correct letter, A-G, in boxes 10-13 on your answer sheet.
10
domestic pigeon
11
alpine swift
12
European stork
13
starling
List of points which the author wishes to illustrate
A
an ability to orientate without previous training
B
the speed at which birds can fly
C
the ability to remember things seen previously
D
the effect of age on homing ability
E
the strength required to fly a great distance
F
a high success rate in finding nests
G
the importance of seasonal cues for migrating birds

13 ____ starling$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fa02ee7-42d9-58ab-95fd-4f76d17181c3', '1003eece-42f4-559d-8d83-027880aa07ce', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db0bcb1b-16c4-5322-828f-d22696d7dd94', '1003eece-42f4-559d-8d83-027880aa07ce', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8566d5c-eeba-593c-9fe7-72e5af813760', '1003eece-42f4-559d-8d83-027880aa07ce', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e45e232-9438-5cb3-8c4d-3cbe61abddf3', '1003eece-42f4-559d-8d83-027880aa07ce', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4d5161a-1852-5e2d-9bbb-3aadc6d1b3c4', '1003eece-42f4-559d-8d83-027880aa07ce', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a19decb1-fe67-5b84-b147-7f10ae493735', '1003eece-42f4-559d-8d83-027880aa07ce', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc2af6cb-7cf7-58d7-b4f2-cebefdde2648', '1003eece-42f4-559d-8d83-027880aa07ce', 7, $md$G$md$, false);

COMMIT;
