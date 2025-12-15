BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-undersea-movement-1388'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-undersea-movement-1388';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-undersea-movement-1388';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-undersea-movement-1388';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('7d8f016e-bbd0-53e5-97b8-acb6b27353c1', 'ielts-reading-undersea-movement-1388', $t$Undersea Movement$t$, $md$## Undersea Movement

Nguồn:
- Test: https://mini-ielts.com/1388/reading/undersea-movement
- Solution: https://mini-ielts.com/1388/view-solution/reading/undersea-movement$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('5915166a-e4f2-5736-ab67-9fa35aa2c12c', '7d8f016e-bbd0-53e5-97b8-acb6b27353c1', 1, $t$Reading — Undersea Movement$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Undersea Movement

A

The underwater world holds many challenges. The most basic of these is movement. The density of water makes it difficult for animals to move. Forward movement is a complex interaction of underwater forces. Additionally, water itself has movement. Strong currents carry incredible power that can easily sweep creatures away. The challenges to aquatic movement result in a variety of swimming methods, used by a wide range of animals. The result is a dazzling underwater ballet.

B

Fish rely on their skeleton, fins, and muscles to move. The primary function of the skeleton is to aid movement of other parts. Their skull acts as a fulcrum and their vertebrae act as levers. The vertebral column consists of a series of vertebrae held together by ligaments, but not so tightly as to prevent slight sideways movement between each pair of vertebrae. The whole spine is, therefore, flexible. The skull is the only truly fixed part of a fish. It does not move in and off itself but acts as a point of stability for other bones. These other bones act as levers that cause movement of the fish’s body.

C

While the bones provide the movement, the muscles supply the power. A typical fish has hundreds of muscles running in all directions around its body. This is why a fish can turn and twist and change directions quickly. The muscles on each side of the spine contract in a series from head to tail and down each side alternately, causing a wave-like movement to pass down the body. Such a movement may be very pronounced in fish such as eels, but hardly perceptible in others, e.g. mackerel. The frequency of the waves varies from about 50/min in the dogfish to 170/min in the mackerel. The sideways and backward thrust of the head and body against the water results in the resistance of the water pushing the fish sideways and forwards in a direction opposed to the thrust. When the corresponding set of muscles on the other side contracts, the fish experiences a similar force from the water on that side. The two sideways forces are equal and opposite unless the fish is making a turn, so they cancel out, leaving the sum of the two forward forces

D

The muscles involved in swimming are of two main types. The bulk of a fish’s body is composed of the so-called white muscle, while the much smaller areas at the roots of the fins and in a strip along the centre of each flank comprise red muscle. The red muscle receives a good supply of blood and contains ampler quantities of fat and glycogen, the storage form of glucose, which is used for most day-to-day swimming movements. In contrast, the white muscle has a poor blood supply and few energy stores, and it is used largely for short-term, fast swimming. It might seem odd that the body of an animal which adapts adapted so efficiently to its environment should be composed almost entirely of a type of muscle it rarely uses. However, this huge auxiliary power pack carried by a fish is of crucial significance if the life of the fish is threatened-by a predator, for instance-because it enables the fish to swim rapidly away from danger.

E

The fins are the most distinctive features of a fish, composed of bony spines protruding from the body with skin covering them and joining them together, either in a webbed fashion, as seen in most bony fish, or more similar to a flipper, as seen in sharks. These usually serve as a means for the fish to swim. But it must be emphasized that the swimming movements are produced by the whole of the muscular body, and in only a few fish do the fins contribute any propulsive force! Their main function is to control the stability and direction of the fish: as water passes over its body, a fish uses its fins to thrust in the direction it wishes to go.

F

Fins located in different places on a fish serve different purposes, such as moving forward, turning, and keeping an upright position. The tail fin, in its final lash may contribute as much as 40 per cent of the forward thrust. The median fins, that is, the dorsal, anal and ventral fins, control the rolling and yawing movements of the fish by increasing the vertical surface area presented to the water. The paired fins, pectoral and pelvic act as hydroplanes and control the pitch of the ash, causing it to swim downwards or upwards according to the angle to the water at which they are held by their muscles. The pectoral fins lie in front of the centre of gravity and, being readily mobile, are chiefly responsible for sending the ash up or down. The paired ins are also the means by which the fish slows down and stops.

G

The swimming speed of fish is not so fast as one would expect from watching their rapid movements in aquaria or ponds. Tuna seems to be the fastest at 44 mph, trout are recorded as doing 23 mph, pike 20 mph for short bursts and roach about 10 mph, while the majority of small fish probably do not exceed 2 or 3 mph. Many people have attempted to make accurate measurements of the speed at which various fish swim, either by timing them over known distances in their natural environment or by determining their performance in man-made swimming channels. From these studies, we can broadly categorise fish into four groups: “sneakers”, such as eels that are only capable of slow speeds but possess some staying power; “stayers”, that can swim quite fast over long periods; “sprinters” that can generate fast bursts of speed (e.g. pike); and “crawlers” that are sluggish swimmers, although they can accelerate slightly (bream, for example).

H

One type of sailfish is considered to be the fastest species of fish over short distances, achieving 68 mph over a three-second period, and anglers have recorded speeds in excess of 40 mph over longer periods for several species of tuna. One is likely to consider a fish’s swimming capabilities in relation to its size. However, it is generally true that a small fish is a more able swimmer than a much larger one. On the other hand in terms of speed in miles per hour, a big fish will, all other things being equal, be able to swim faster than a smaller fish.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5a430841-2e5d-5367-a99c-5fffc5571474', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The Passage has 8 paragraphs
A-H
.
Which paragraph contains the following information?
Write the appropriate letter,
A-H
, in boxes
1-6
on your answer sheet.
1
categorizations of fish by swimming speed
2
an example of fish capable of maintaining fast swimming for a long time
3
how fish control stability
4
frequency of the muscle movement of fish
5
a mechanical model of fish skeleton
6
energy storage devices in a fish

1 ____ categorizations of fish by swimming speed$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7e90b80-ebb9-53c7-ab68-ba296b201ca4', '5a430841-2e5d-5367-a99c-5fffc5571474', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da13638c-97f3-52e8-96b0-7e02e7c633bd', '5a430841-2e5d-5367-a99c-5fffc5571474', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c444871-fffa-596d-985c-68374b27f59b', '5a430841-2e5d-5367-a99c-5fffc5571474', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04f51d5a-620a-5c17-a40c-dc0dd976d917', '5a430841-2e5d-5367-a99c-5fffc5571474', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfc62590-6183-5e07-a131-58252c18610b', '5a430841-2e5d-5367-a99c-5fffc5571474', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17d23aac-10ee-54f1-b3e5-3b45a750849e', '5a430841-2e5d-5367-a99c-5fffc5571474', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b66576b5-30da-5432-944d-2bc656b80730', '5a430841-2e5d-5367-a99c-5fffc5571474', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9ab8ca8-8cbc-5359-8734-931a46985f0b', '5a430841-2e5d-5367-a99c-5fffc5571474', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('37e29ab7-fe1a-5f68-bd5b-cffb6cc4ead6', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The Passage has 8 paragraphs
A-H
.
Which paragraph contains the following information?
Write the appropriate letter,
A-H
, in boxes
1-6
on your answer sheet.
1
categorizations of fish by swimming speed
2
an example of fish capable of maintaining fast swimming for a long time
3
how fish control stability
4
frequency of the muscle movement of fish
5
a mechanical model of fish skeleton
6
energy storage devices in a fish

2 ____ an example of fish capable of maintaining fast swimming for a long time$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6171ed8f-6747-5546-9e73-33eb10c50129', '37e29ab7-fe1a-5f68-bd5b-cffb6cc4ead6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebebcde6-5e93-56b5-8b62-545051d5136d', '37e29ab7-fe1a-5f68-bd5b-cffb6cc4ead6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cca9da4d-87d2-57b3-9145-ec17e673147b', '37e29ab7-fe1a-5f68-bd5b-cffb6cc4ead6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2886bfe6-4db4-5f6a-bc13-d5dcf748d1b6', '37e29ab7-fe1a-5f68-bd5b-cffb6cc4ead6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b309baa0-6f82-5987-a481-52ad663ddded', '37e29ab7-fe1a-5f68-bd5b-cffb6cc4ead6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75e4c61c-6b5c-5ca6-950c-e53dcd650c4a', '37e29ab7-fe1a-5f68-bd5b-cffb6cc4ead6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('953b4845-3167-5720-8aeb-87d8941fba86', '37e29ab7-fe1a-5f68-bd5b-cffb6cc4ead6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2efe6c4b-5a5e-5b93-96e6-92295d96652b', '37e29ab7-fe1a-5f68-bd5b-cffb6cc4ead6', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('482874a6-4643-5b89-911e-5d191a7ce01a', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The Passage has 8 paragraphs
A-H
.
Which paragraph contains the following information?
Write the appropriate letter,
A-H
, in boxes
1-6
on your answer sheet.
1
categorizations of fish by swimming speed
2
an example of fish capable of maintaining fast swimming for a long time
3
how fish control stability
4
frequency of the muscle movement of fish
5
a mechanical model of fish skeleton
6
energy storage devices in a fish

3 ____ how fish control stability$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('193635cd-6a67-5525-9c53-2d1546c95577', '482874a6-4643-5b89-911e-5d191a7ce01a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f031050-3c10-53d5-aa30-6924750df00d', '482874a6-4643-5b89-911e-5d191a7ce01a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56585ab3-802d-54fe-9b20-227c7db8b33d', '482874a6-4643-5b89-911e-5d191a7ce01a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45e1ce2f-e49e-5980-b891-224b8f25e85b', '482874a6-4643-5b89-911e-5d191a7ce01a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17f1fb90-5088-52d8-ae80-3ff4aedfe802', '482874a6-4643-5b89-911e-5d191a7ce01a', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c1523df-07c0-51c7-80ba-4848a34b74e6', '482874a6-4643-5b89-911e-5d191a7ce01a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0dd0e8c8-cb16-5d2e-8a77-35acb3c93401', '482874a6-4643-5b89-911e-5d191a7ce01a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0bef37a-b1b7-56b9-9aea-aa4d52b8050e', '482874a6-4643-5b89-911e-5d191a7ce01a', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6853caff-8b1b-5771-878a-47809fc0fb66', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The Passage has 8 paragraphs
A-H
.
Which paragraph contains the following information?
Write the appropriate letter,
A-H
, in boxes
1-6
on your answer sheet.
1
categorizations of fish by swimming speed
2
an example of fish capable of maintaining fast swimming for a long time
3
how fish control stability
4
frequency of the muscle movement of fish
5
a mechanical model of fish skeleton
6
energy storage devices in a fish

4 ____ frequency of the muscle movement of fish$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e68d6a84-56c6-5b3d-b047-240021f9cd72', '6853caff-8b1b-5771-878a-47809fc0fb66', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e8d6afd-e4e5-5fc8-bb63-1137e8652261', '6853caff-8b1b-5771-878a-47809fc0fb66', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44de315f-ac7c-5517-8038-36c9fb015762', '6853caff-8b1b-5771-878a-47809fc0fb66', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91d50513-87e5-5b1b-b18d-81b5e1b8d551', '6853caff-8b1b-5771-878a-47809fc0fb66', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('682979bc-575e-57f9-8cfc-b27fbc512c6c', '6853caff-8b1b-5771-878a-47809fc0fb66', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3923e3f8-fac0-593e-839c-049b84edd5da', '6853caff-8b1b-5771-878a-47809fc0fb66', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebed30e8-31b2-5b80-bca2-c90c6ebb4907', '6853caff-8b1b-5771-878a-47809fc0fb66', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4098d24d-84a3-5a96-81ef-c18b0ab7e598', '6853caff-8b1b-5771-878a-47809fc0fb66', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('86f4b90e-953b-523d-af81-c6fc5a1d68c6', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The Passage has 8 paragraphs
A-H
.
Which paragraph contains the following information?
Write the appropriate letter,
A-H
, in boxes
1-6
on your answer sheet.
1
categorizations of fish by swimming speed
2
an example of fish capable of maintaining fast swimming for a long time
3
how fish control stability
4
frequency of the muscle movement of fish
5
a mechanical model of fish skeleton
6
energy storage devices in a fish

5 ____ a mechanical model of fish skeleton$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eaca5c74-21b7-5040-a86c-a950e974f488', '86f4b90e-953b-523d-af81-c6fc5a1d68c6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f8005b7-03ef-5d81-a263-70e1e00fb81a', '86f4b90e-953b-523d-af81-c6fc5a1d68c6', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bed2ea41-0da6-575c-a641-da5bc4dda1ec', '86f4b90e-953b-523d-af81-c6fc5a1d68c6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46918d37-ed92-5da0-8663-bb098b9eeb4d', '86f4b90e-953b-523d-af81-c6fc5a1d68c6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16d33f86-82ba-5c76-a7ba-05ddb9c6149a', '86f4b90e-953b-523d-af81-c6fc5a1d68c6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3179fc52-50ab-5e2e-814e-da769683403c', '86f4b90e-953b-523d-af81-c6fc5a1d68c6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c9b18d9-93ea-53bf-836a-fe12c2ae1146', '86f4b90e-953b-523d-af81-c6fc5a1d68c6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58586b4b-9ddb-5722-9b0a-b899bd97ca6e', '86f4b90e-953b-523d-af81-c6fc5a1d68c6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c44e2433-29a2-5e61-b86a-92bfb426a6bd', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The Passage has 8 paragraphs
A-H
.
Which paragraph contains the following information?
Write the appropriate letter,
A-H
, in boxes
1-6
on your answer sheet.
1
categorizations of fish by swimming speed
2
an example of fish capable of maintaining fast swimming for a long time
3
how fish control stability
4
frequency of the muscle movement of fish
5
a mechanical model of fish skeleton
6
energy storage devices in a fish

6 ____ energy storage devices in a fish$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24a4fcdf-2413-505b-bc34-08a147973b7e', 'c44e2433-29a2-5e61-b86a-92bfb426a6bd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84cb3133-f6cb-531b-a654-33052fcaa066', 'c44e2433-29a2-5e61-b86a-92bfb426a6bd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b176d324-0791-5671-9ff2-d6b3c1c533b1', 'c44e2433-29a2-5e61-b86a-92bfb426a6bd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae8a66d3-9328-50c1-9c97-58d78d035d39', 'c44e2433-29a2-5e61-b86a-92bfb426a6bd', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46a1cb11-90b6-529d-84b4-4a4d6e6388c7', 'c44e2433-29a2-5e61-b86a-92bfb426a6bd', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdc0843f-fcd2-5895-8518-d862bd08fb30', 'c44e2433-29a2-5e61-b86a-92bfb426a6bd', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a374fad3-c62a-58f5-a651-db8e39b621a2', 'c44e2433-29a2-5e61-b86a-92bfb426a6bd', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b2d8ac5-b0d0-5013-9e25-ec7a5d9c605b', 'c44e2433-29a2-5e61-b86a-92bfb426a6bd', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('32881bf6-58fd-5b67-87fe-7fafc25b7cb6', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 7, 'FORM_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
The diagram below gives information about fish fins and their purposes.
Complete the diagram with
NO MORE THAN THREE WORDS
from the passage for each blank
Write your answers in boxes
7-10
on your answer sheet.
7
8
9
10

7 ____$md$, NULL, ARRAY['.*forward.*thrust.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5c6d5b50-8bec-5d76-849c-4a09f746031e', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 8, 'FORM_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
The diagram below gives information about fish fins and their purposes.
Complete the diagram with
NO MORE THAN THREE WORDS
from the passage for each blank
Write your answers in boxes
7-10
on your answer sheet.
7
8
9
10

8 ____$md$, NULL, ARRAY['.*rolling.*and.*yawing.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3abad69c-2bd5-5a29-8aec-76cd734db362', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 9, 'FORM_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
The diagram below gives information about fish fins and their purposes.
Complete the diagram with
NO MORE THAN THREE WORDS
from the passage for each blank
Write your answers in boxes
7-10
on your answer sheet.
7
8
9
10

9 ____$md$, NULL, ARRAY['.*pectoral.*and.*pelvic.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a45828d4-78e2-5970-acac-651b63a802aa', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 10, 'FORM_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
The diagram below gives information about fish fins and their purposes.
Complete the diagram with
NO MORE THAN THREE WORDS
from the passage for each blank
Write your answers in boxes
7-10
on your answer sheet.
7
8
9
10

10 ____$md$, NULL, ARRAY['.*slows.*and.*stops.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e333e8b1-14f8-598f-bc03-55d17138986f', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the summary below using
NO MORE THAN THREE WORDS
from the passage for each blank.
Write your answers in boxes
11-13
on your answer sheet.
Two types of muscles are involved in fish swimming. The majority of a fish’s body comprises the
11
, and the red muscle is found only at the roots of the fins and in a strip along the centre of each flank. For most of its routine movements, the fish uses a lot of its
12
saved in body, and white muscle is mostly used for short-term, fast swimming, such as escaping from
13
.

Two types of muscles are involved in fish swimming. The majority of a fish’s body comprises the 11 ____ , and the red muscle is found only at the roots of the fins and in a strip along the centre of each flank. For most of its routine movements, the fish uses a lot of its 12 ____ saved in body, and white muscle is mostly used for short-term, fast swimming, such as escaping from 13 ____ .$md$, NULL, ARRAY['.*white.*muscle.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8cbbde25-c67d-5e2f-b3b5-51b34da1f276', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the summary below using
NO MORE THAN THREE WORDS
from the passage for each blank.
Write your answers in boxes
11-13
on your answer sheet.
Two types of muscles are involved in fish swimming. The majority of a fish’s body comprises the
11
, and the red muscle is found only at the roots of the fins and in a strip along the centre of each flank. For most of its routine movements, the fish uses a lot of its
12
saved in body, and white muscle is mostly used for short-term, fast swimming, such as escaping from
13
.

Two types of muscles are involved in fish swimming. The majority of a fish’s body comprises the 11 ____ , and the red muscle is found only at the roots of the fins and in a strip along the centre of each flank. For most of its routine movements, the fish uses a lot of its 12 ____ saved in body, and white muscle is mostly used for short-term, fast swimming, such as escaping from 13 ____ .$md$, NULL, ARRAY['.*white.*muscle.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('803e25ce-fc1c-5d77-b5eb-43d2114d481b', '5915166a-e4f2-5736-ab67-9fa35aa2c12c', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the summary below using
NO MORE THAN THREE WORDS
from the passage for each blank.
Write your answers in boxes
11-13
on your answer sheet.
Two types of muscles are involved in fish swimming. The majority of a fish’s body comprises the
11
, and the red muscle is found only at the roots of the fins and in a strip along the centre of each flank. For most of its routine movements, the fish uses a lot of its
12
saved in body, and white muscle is mostly used for short-term, fast swimming, such as escaping from
13
.

Two types of muscles are involved in fish swimming. The majority of a fish’s body comprises the 11 ____ , and the red muscle is found only at the roots of the fins and in a strip along the centre of each flank. For most of its routine movements, the fish uses a lot of its 12 ____ saved in body, and white muscle is mostly used for short-term, fast swimming, such as escaping from 13 ____ .$md$, NULL, ARRAY['.*white.*muscle.*']);

COMMIT;
