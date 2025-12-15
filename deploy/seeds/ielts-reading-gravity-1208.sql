BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-gravity-1208'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-gravity-1208';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-gravity-1208';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-gravity-1208';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('1c3a625f-f601-5566-8bb8-2f818a5c574c', 'ielts-reading-gravity-1208', $t$GRAVITY$t$, $md$## GRAVITY

Nguồn:
- Test: https://mini-ielts.com/1208/reading/gravity
- Solution: https://mini-ielts.com/1208/view-solution/reading/gravity$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('53e5b012-6b17-5091-9fbf-6379ec18c0f2', '1c3a625f-f601-5566-8bb8-2f818a5c574c', 1, $t$Reading — GRAVITY$t$, $md$Read the passage and answer questions **1–15**.

### Passage: GRAVITY

A. Without forces of gravitation, Earth and other planets would be unable to stay in their orbits around the Sun. the Moon would be unable to orbit the Earth, tidal waves would not occur and the rising of hot air or water convection would be impossible. Gravitation is a phenomenon winch allows objects to attract other matter; the physics behind it have been explained in The Theory of Relativity and Newton’s Law of Universal Gravitation; though attempts to explain gravity hail back to ancient times. In 4th Century B.C. the Greek philosopher Aristotle developed the hypothesis that all objects were drawn into their correct position by crystalline spheres and that a physical mass would fall towards the earth in direct proportion to its weight.

B. In the late 16th century Galileo deduced that while gravitation propels all objects to the ground at the same rate, air resistance resulted in heavier objects appearing to fall more quickly; his theories contradicting earlier belief systems put in place by Aristotle and others; so paving the way for formulation of the modern theories of today. Though the two terms are now used interchangeably in layman use, strictly by scientific definition, there are distinct differences between ‘gravitation’ and ‘gravity’ . The first relates to the influence exerted by different objects which allow them to attract other objects, whereas ‘gravity’ refers specifically to the force possessed by such objects which facilitates gravitation. Certain scientific theories hold that gravitation may be initiated by a combination of factors and not simply the existence of gravity alone; though doubts have been raised regarding some of these theories.

C. Gravity is directly proportional to mass; a smaller object possessing less gravity. To illustrate, the Moon is a quarter of the Earth’s size and possesses only 1/6 of its gravity. The mass of the Earth itself is not spread out proportionally, being flatter at the poles than the equator as a result of its rotation; gravity and gravitational pull in different locations throughout the world also vary . In the 1960s, as a result of research into the worldwide gravity fields, it was discovered that inexplicably areas around and including the Hudson Bay area of Canada appeared to possess significantly lower levels of gravity than other parts of the globe ; the reasons for this dissimilarity have since been extensively investigated resulting in two explanations.

D. The original theory presented attributed this anomaly to activity which occurs 100-200 kilometres below the Earth’s surface within the layer known as the ‘mantle’ . The mantle is comprised of hot molten rock known as magma which flows under the earth’s surface causing convection currents. These convection currents can result in the lowering of the continental plates which make up the Earth’s surface , as a result when this occurs, the mass in that area and its gravity is also reduced. Research findings indicated that such activity had occurred in the Hudson Bay region.

E. More recently a second conjecture suggested that, in fact, lower levels of gravity in the area are a result of occurrences during the Ice Age. The Laurentideicesheet, which covered most of Canada and the northern tip of the USA until it melted 10,000 years ago, is thought to have been 3.2 kms thick in most parts and 3.7 kms thick over two areas of Hudson Bay. The sheer weight of the ice layer weighed down the surface of the earth below, leaving a deep indentation once it had melted, having caused the area around Hudson Bay to become thinner as the earth’s surface was pushed to the edges of the icesheet.

F. Extensive investigation has since been carried out by the Harvard-Smithsonian Center for Astrophysics using data collected by satellites during the Gravity Recovery and Climate Experiment (GRACE) between 2002 and 2006 . The satellites are placed 220kms apart and orbit 500kms above Earth. Being extremely sensitive to even minor differences in gravitational pull of the areas of earth they pass over, as the first satellite enters an area with decreased gravity it moves slightly away from the earth as the gravitational pull is reduced and also moves slightly further away from the sister satellite that follows, such activity allowing scientists to create maps of gravitational fields. The GRACE findings also allowed scientists to estimate the appearance of Hudson Bay over 10,000 years ago, prior to the great thaw. The areas possessing the lowest gravity today correlate with the areas covered in the thickest layers of ice at that time.

G. Researchers now believe that both theories regarding reduced gravity levels in the Hudson Bay region are accurate and that the area’s characteristics are a result of both magma activity and the impact of the Laurentidelcesheet. It has been estimated that the former has resulted in 55-75% of gravity reduction and that pressure resulting from the latter accounts for 25-45% .

H. The effects of the Laurentidelcesheet are reversible due to the earth layer’s capability to ‘rebound’ in response to removal of the weight which once restricted it. Return to the original position, however, is an extremely slow process; it is estimated that the area around Hudson Bay will take a further 5,000 years to recover the altitude it once possessed prior to the Laurentidelcesheet. The rebound activity in the area is also measurable through observation of sea levels; unlike the rest of the world, sea levels are not rising in the area as a result of melting icecaps, but are dropping as the land recovers its previous form

I. Research conducted into the Laurentidelcesheet has significant implications on a global scale. The increased knowledge of how that particular area has changed over time and the long-term implications activity in the Ice Age had, pave the way to a better understanding of how current changes elsewhere will manifest themselves over the long term.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a4829744-5bcb-5454-8abc-0ebf0f360a95', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Choose the correct heading for paragraphs
B, C
and
E-H
from the list of headings below.
Write the correct number
i-x
in boxes
26-31
on your answer sheet.
List of Headings
i.
Return to previous form
ii
. Substantiating a hypothesis
iii
. Historic theories
iv
. The general rule of gravity and an exception
v.
The initial explanation
vi.
How proximity to the poles affected Hudson Bay
vi
. Scientific definition and contemporary views
viii
. Relevance to our future
ix.
An alternative view point
x
. Consolidating theories
Example
Paragraph D
Paragraph I
Answer
v
vii
1
Paragraph B
2
Paragraph C
3
Paragraph E
4
Paragraph F
5
Paragraph G
6
Paragraph H

1 ____ Paragraph B$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fa108ca8-495f-544c-abfb-e030f8a60bd9', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Choose the correct heading for paragraphs
B, C
and
E-H
from the list of headings below.
Write the correct number
i-x
in boxes
26-31
on your answer sheet.
List of Headings
i.
Return to previous form
ii
. Substantiating a hypothesis
iii
. Historic theories
iv
. The general rule of gravity and an exception
v.
The initial explanation
vi.
How proximity to the poles affected Hudson Bay
vi
. Scientific definition and contemporary views
viii
. Relevance to our future
ix.
An alternative view point
x
. Consolidating theories
Example
Paragraph D
Paragraph I
Answer
v
vii
1
Paragraph B
2
Paragraph C
3
Paragraph E
4
Paragraph F
5
Paragraph G
6
Paragraph H

2 ____ Paragraph C$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3b73c3df-c209-5d43-9474-9175bcecd06d', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Choose the correct heading for paragraphs
B, C
and
E-H
from the list of headings below.
Write the correct number
i-x
in boxes
26-31
on your answer sheet.
List of Headings
i.
Return to previous form
ii
. Substantiating a hypothesis
iii
. Historic theories
iv
. The general rule of gravity and an exception
v.
The initial explanation
vi.
How proximity to the poles affected Hudson Bay
vi
. Scientific definition and contemporary views
viii
. Relevance to our future
ix.
An alternative view point
x
. Consolidating theories
Example
Paragraph D
Paragraph I
Answer
v
vii
1
Paragraph B
2
Paragraph C
3
Paragraph E
4
Paragraph F
5
Paragraph G
6
Paragraph H

3 ____ Paragraph E$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fff99d44-3237-5694-b5b7-b583b6a2a72d', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Choose the correct heading for paragraphs
B, C
and
E-H
from the list of headings below.
Write the correct number
i-x
in boxes
26-31
on your answer sheet.
List of Headings
i.
Return to previous form
ii
. Substantiating a hypothesis
iii
. Historic theories
iv
. The general rule of gravity and an exception
v.
The initial explanation
vi.
How proximity to the poles affected Hudson Bay
vi
. Scientific definition and contemporary views
viii
. Relevance to our future
ix.
An alternative view point
x
. Consolidating theories
Example
Paragraph D
Paragraph I
Answer
v
vii
1
Paragraph B
2
Paragraph C
3
Paragraph E
4
Paragraph F
5
Paragraph G
6
Paragraph H

4 ____ Paragraph F$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('69454555-6212-5003-be5e-25c51e05684c', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Choose the correct heading for paragraphs
B, C
and
E-H
from the list of headings below.
Write the correct number
i-x
in boxes
26-31
on your answer sheet.
List of Headings
i.
Return to previous form
ii
. Substantiating a hypothesis
iii
. Historic theories
iv
. The general rule of gravity and an exception
v.
The initial explanation
vi.
How proximity to the poles affected Hudson Bay
vi
. Scientific definition and contemporary views
viii
. Relevance to our future
ix.
An alternative view point
x
. Consolidating theories
Example
Paragraph D
Paragraph I
Answer
v
vii
1
Paragraph B
2
Paragraph C
3
Paragraph E
4
Paragraph F
5
Paragraph G
6
Paragraph H

5 ____ Paragraph G$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('10e92474-6a25-5233-bd60-0a2da5d77984', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Choose the correct heading for paragraphs
B, C
and
E-H
from the list of headings below.
Write the correct number
i-x
in boxes
26-31
on your answer sheet.
List of Headings
i.
Return to previous form
ii
. Substantiating a hypothesis
iii
. Historic theories
iv
. The general rule of gravity and an exception
v.
The initial explanation
vi.
How proximity to the poles affected Hudson Bay
vi
. Scientific definition and contemporary views
viii
. Relevance to our future
ix.
An alternative view point
x
. Consolidating theories
Example
Paragraph D
Paragraph I
Answer
v
vii
1
Paragraph B
2
Paragraph C
3
Paragraph E
4
Paragraph F
5
Paragraph G
6
Paragraph H

6 ____ Paragraph H$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5767ef9-a041-5c53-aac6-2797d014e998', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-11
Questions 7-11
Do the following statements agree with the information given in Reading Passage?
In boxes
7-11
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
7
Differentiation between gravity and gravitational pull is generally only made by academics in the field.
Locate
8
Gravity levels in areas around the equator are significantly higher than around the poles.
Locate
9
It was first believed that lower gravity levels in Hudson Bay could be attributed to its location between the poles and the equator.
Locate
10
Molten rock activity within the magma layer has had less of an impact on gravity levels in the Hudson Bay area than the Laurentidelcesheet.
Locate
11
The GRACE project’s main focus was areas of Canada and North America once thought to be covered by the Laurentidelcesheet.
Locate

7 ____ Differentiation between gravity and gravitational pull is generally only made by academics in the field. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d02137b0-9dc6-52c0-ae28-3906035a3b1e', 'a5767ef9-a041-5c53-aac6-2797d014e998', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5c0aab7-cf93-5b21-b722-ed9b749629ab', 'a5767ef9-a041-5c53-aac6-2797d014e998', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('517c0714-8781-52a9-85cd-09c1e3f76a46', 'a5767ef9-a041-5c53-aac6-2797d014e998', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e6261ad2-0bc3-53f8-b1bf-431a59299327', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-11
Questions 7-11
Do the following statements agree with the information given in Reading Passage?
In boxes
7-11
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
7
Differentiation between gravity and gravitational pull is generally only made by academics in the field.
Locate
8
Gravity levels in areas around the equator are significantly higher than around the poles.
Locate
9
It was first believed that lower gravity levels in Hudson Bay could be attributed to its location between the poles and the equator.
Locate
10
Molten rock activity within the magma layer has had less of an impact on gravity levels in the Hudson Bay area than the Laurentidelcesheet.
Locate
11
The GRACE project’s main focus was areas of Canada and North America once thought to be covered by the Laurentidelcesheet.
Locate

8 ____ Gravity levels in areas around the equator are significantly higher than around the poles. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ce7d1ac-c58f-50bd-b678-d81e89b35024', 'e6261ad2-0bc3-53f8-b1bf-431a59299327', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdb3cc98-c74b-5a37-a1c9-7ae40da3d9cb', 'e6261ad2-0bc3-53f8-b1bf-431a59299327', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8b1a65f-7424-5752-ab6e-0a8cd7e8a5e4', 'e6261ad2-0bc3-53f8-b1bf-431a59299327', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af389720-b4c2-5655-bdfc-74c61407c21f', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-11
Questions 7-11
Do the following statements agree with the information given in Reading Passage?
In boxes
7-11
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
7
Differentiation between gravity and gravitational pull is generally only made by academics in the field.
Locate
8
Gravity levels in areas around the equator are significantly higher than around the poles.
Locate
9
It was first believed that lower gravity levels in Hudson Bay could be attributed to its location between the poles and the equator.
Locate
10
Molten rock activity within the magma layer has had less of an impact on gravity levels in the Hudson Bay area than the Laurentidelcesheet.
Locate
11
The GRACE project’s main focus was areas of Canada and North America once thought to be covered by the Laurentidelcesheet.
Locate

9 ____ It was first believed that lower gravity levels in Hudson Bay could be attributed to its location between the poles and the equator. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfc401c9-8bb3-5262-9e19-9941f5a14944', 'af389720-b4c2-5655-bdfc-74c61407c21f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fc7c19f-a85f-5045-9482-4100a421af57', 'af389720-b4c2-5655-bdfc-74c61407c21f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60b39179-7d9f-52af-8893-ba0fede329e4', 'af389720-b4c2-5655-bdfc-74c61407c21f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dea1e655-8a17-52d5-9eeb-edaf83fc62d7', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 7-11
Questions 7-11
Do the following statements agree with the information given in Reading Passage?
In boxes
7-11
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
7
Differentiation between gravity and gravitational pull is generally only made by academics in the field.
Locate
8
Gravity levels in areas around the equator are significantly higher than around the poles.
Locate
9
It was first believed that lower gravity levels in Hudson Bay could be attributed to its location between the poles and the equator.
Locate
10
Molten rock activity within the magma layer has had less of an impact on gravity levels in the Hudson Bay area than the Laurentidelcesheet.
Locate
11
The GRACE project’s main focus was areas of Canada and North America once thought to be covered by the Laurentidelcesheet.
Locate

10 ____ Molten rock activity within the magma layer has had less of an impact on gravity levels in the Hudson Bay area than the Laurentidelcesheet. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae18d95b-1084-586f-9372-e04e392c15ee', 'dea1e655-8a17-52d5-9eeb-edaf83fc62d7', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c5bb8f4-58dc-5f0f-9691-628a903592e9', 'dea1e655-8a17-52d5-9eeb-edaf83fc62d7', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b19b1584-bd11-53d3-88a5-ceecd50b1345', 'dea1e655-8a17-52d5-9eeb-edaf83fc62d7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0f91ef62-5205-58db-90b4-50d67494f20b', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 7-11
Questions 7-11
Do the following statements agree with the information given in Reading Passage?
In boxes
7-11
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
7
Differentiation between gravity and gravitational pull is generally only made by academics in the field.
Locate
8
Gravity levels in areas around the equator are significantly higher than around the poles.
Locate
9
It was first believed that lower gravity levels in Hudson Bay could be attributed to its location between the poles and the equator.
Locate
10
Molten rock activity within the magma layer has had less of an impact on gravity levels in the Hudson Bay area than the Laurentidelcesheet.
Locate
11
The GRACE project’s main focus was areas of Canada and North America once thought to be covered by the Laurentidelcesheet.
Locate

11 ____ The GRACE project’s main focus was areas of Canada and North America once thought to be covered by the Laurentidelcesheet. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('858b0470-9b04-5899-b479-6a23edb05fbd', '0f91ef62-5205-58db-90b4-50d67494f20b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c6669a6-6d23-59f3-97c3-052fdfbff5e1', '0f91ef62-5205-58db-90b4-50d67494f20b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4400ed1c-8ddc-5593-91b1-8fd60034c4f5', '0f91ef62-5205-58db-90b4-50d67494f20b', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('25c6d5cf-ea1e-52be-bfea-7c11e0af8e10', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 12-15
Questions 12-15
Complete the sentences below with words from the box below.
Write the correct letter
A-J
in boxes
12-15
on your answer sheet.
12
. The impact of
Locate
on objects falling to the ground was not considered by Aristotle.
13
. Investigations of
Locate
first led to the discovery of the unusual levels in Hudson Bay.
14
. The earth’s surface has been observed to sink as a direct result of
Locate
15.
The largest proportion of the Laurentideicesheet was
Locate
in depth.
A. crystalline spheres
C. 3.2kms
E. gravity fields
G. 3.5kms
I. convection currents
B. mass
D. continental plates
F. warming
H. mantle layers
J. air resistance

12 . The impact of ____ Locate on objects falling to the ground was not considered by Aristotle.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('350dd43f-34ef-5cbb-8b03-a7f283222978', '25c6d5cf-ea1e-52be-bfea-7c11e0af8e10', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f9a1630-0347-53a7-805d-6bf7e581a7c4', '25c6d5cf-ea1e-52be-bfea-7c11e0af8e10', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96818cff-7537-59ff-8552-4a81032b21b3', '25c6d5cf-ea1e-52be-bfea-7c11e0af8e10', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('257ada0c-0043-5bf3-9dab-5a16327000a8', '25c6d5cf-ea1e-52be-bfea-7c11e0af8e10', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4efcb097-496b-5002-a922-aaf1ede2c3b6', '25c6d5cf-ea1e-52be-bfea-7c11e0af8e10', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0772629d-6efe-5dac-9e17-4365ec35d301', '25c6d5cf-ea1e-52be-bfea-7c11e0af8e10', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d96948a-e75e-546d-b358-8bedb01ce66c', '25c6d5cf-ea1e-52be-bfea-7c11e0af8e10', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae397748-f455-5867-95b9-02ff75ba3394', '25c6d5cf-ea1e-52be-bfea-7c11e0af8e10', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46d1403f-5497-5a2b-a2e9-040ceea3b266', '25c6d5cf-ea1e-52be-bfea-7c11e0af8e10', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0468974-3f14-53f2-991f-d55ed7be1a4d', '25c6d5cf-ea1e-52be-bfea-7c11e0af8e10', 10, $md$J$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d6f233fc-d848-5f8d-9141-91cf166f5cb2', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 12-15
Questions 12-15
Complete the sentences below with words from the box below.
Write the correct letter
A-J
in boxes
12-15
on your answer sheet.
12
. The impact of
Locate
on objects falling to the ground was not considered by Aristotle.
13
. Investigations of
Locate
first led to the discovery of the unusual levels in Hudson Bay.
14
. The earth’s surface has been observed to sink as a direct result of
Locate
15.
The largest proportion of the Laurentideicesheet was
Locate
in depth.
A. crystalline spheres
C. 3.2kms
E. gravity fields
G. 3.5kms
I. convection currents
B. mass
D. continental plates
F. warming
H. mantle layers
J. air resistance

13 . Investigations of ____ Locate first led to the discovery of the unusual levels in Hudson Bay.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c953a126-c877-5901-93e7-983d36735eae', 'd6f233fc-d848-5f8d-9141-91cf166f5cb2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0442700-df32-52ae-a172-7537b711a9d1', 'd6f233fc-d848-5f8d-9141-91cf166f5cb2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b93663e-e3cf-50e1-ae1b-dabb421a2af3', 'd6f233fc-d848-5f8d-9141-91cf166f5cb2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3265e9a4-baae-5b37-88d8-58fa20569d4b', 'd6f233fc-d848-5f8d-9141-91cf166f5cb2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('407e11cc-abbc-5be9-9ec6-cee9a1c7c03d', 'd6f233fc-d848-5f8d-9141-91cf166f5cb2', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbd6101e-0a34-5b00-b2e6-184d831ea588', 'd6f233fc-d848-5f8d-9141-91cf166f5cb2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86c7bc05-4ae0-515e-af83-fa63aa28b003', 'd6f233fc-d848-5f8d-9141-91cf166f5cb2', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89748324-8985-55fe-9ea5-1b8d31a738e1', 'd6f233fc-d848-5f8d-9141-91cf166f5cb2', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddc4b94f-a88e-525b-933c-9e5e374b379b', 'd6f233fc-d848-5f8d-9141-91cf166f5cb2', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf3e4994-c24e-5df3-b503-05f6a60e3fdb', 'd6f233fc-d848-5f8d-9141-91cf166f5cb2', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7856a3a8-d4f1-5dd7-b8d1-e3a99ffb0383', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 12-15
Questions 12-15
Complete the sentences below with words from the box below.
Write the correct letter
A-J
in boxes
12-15
on your answer sheet.
12
. The impact of
Locate
on objects falling to the ground was not considered by Aristotle.
13
. Investigations of
Locate
first led to the discovery of the unusual levels in Hudson Bay.
14
. The earth’s surface has been observed to sink as a direct result of
Locate
15.
The largest proportion of the Laurentideicesheet was
Locate
in depth.
A. crystalline spheres
C. 3.2kms
E. gravity fields
G. 3.5kms
I. convection currents
B. mass
D. continental plates
F. warming
H. mantle layers
J. air resistance

14 . The earth’s surface has been observed to sink as a direct result of ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ef2559a-16b9-5486-bd39-e3f06e72a400', '7856a3a8-d4f1-5dd7-b8d1-e3a99ffb0383', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('add0d8ad-380d-5615-9683-3b1f8379c7e2', '7856a3a8-d4f1-5dd7-b8d1-e3a99ffb0383', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('201d115e-5258-5d66-8834-db91d3cba5a0', '7856a3a8-d4f1-5dd7-b8d1-e3a99ffb0383', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('723143ab-6918-5761-945a-b376a11445f5', '7856a3a8-d4f1-5dd7-b8d1-e3a99ffb0383', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d17823d6-2877-5f3e-b1fd-d6de252c5cf0', '7856a3a8-d4f1-5dd7-b8d1-e3a99ffb0383', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ebfd8bc-1f3d-5f81-9170-840d91556271', '7856a3a8-d4f1-5dd7-b8d1-e3a99ffb0383', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a3a0a3f-83ed-5da5-81d3-d9d9833a9230', '7856a3a8-d4f1-5dd7-b8d1-e3a99ffb0383', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed278cd7-3ecb-50fd-ba56-baeb25a67dc0', '7856a3a8-d4f1-5dd7-b8d1-e3a99ffb0383', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35677472-13f3-51a9-b8f8-45883ce25c3b', '7856a3a8-d4f1-5dd7-b8d1-e3a99ffb0383', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe43d23e-5aeb-5f49-87f0-e1ce85174e83', '7856a3a8-d4f1-5dd7-b8d1-e3a99ffb0383', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('753e84c3-fdb8-50c9-9092-bbb1517b68eb', '53e5b012-6b17-5091-9fbf-6379ec18c0f2', 15, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 15

Questions 12-15
Questions 12-15
Complete the sentences below with words from the box below.
Write the correct letter
A-J
in boxes
12-15
on your answer sheet.
12
. The impact of
Locate
on objects falling to the ground was not considered by Aristotle.
13
. Investigations of
Locate
first led to the discovery of the unusual levels in Hudson Bay.
14
. The earth’s surface has been observed to sink as a direct result of
Locate
15.
The largest proportion of the Laurentideicesheet was
Locate
in depth.
A. crystalline spheres
C. 3.2kms
E. gravity fields
G. 3.5kms
I. convection currents
B. mass
D. continental plates
F. warming
H. mantle layers
J. air resistance

15. The largest proportion of the Laurentideicesheet was ____ Locate in depth.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8b695af-0603-52be-bf8e-43b950421e67', '753e84c3-fdb8-50c9-9092-bbb1517b68eb', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f5397d2-85bb-53fb-9d9b-dcbc484e5cbe', '753e84c3-fdb8-50c9-9092-bbb1517b68eb', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2aab97a-d32a-5234-95d3-1b56218b995f', '753e84c3-fdb8-50c9-9092-bbb1517b68eb', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a498666-1876-54e8-8867-377120efc718', '753e84c3-fdb8-50c9-9092-bbb1517b68eb', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7bd0dd3-2a5f-5a8e-98ee-84ce31bc8436', '753e84c3-fdb8-50c9-9092-bbb1517b68eb', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7cffcdd4-945e-5254-abb2-b3efd502e79d', '753e84c3-fdb8-50c9-9092-bbb1517b68eb', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('caf54613-5511-503a-ab49-86b996ae0c74', '753e84c3-fdb8-50c9-9092-bbb1517b68eb', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('859dc635-7792-5ca6-89ac-1a6a6f4dac94', '753e84c3-fdb8-50c9-9092-bbb1517b68eb', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84eb7538-cca7-5ee7-9aa6-7fac23d2147c', '753e84c3-fdb8-50c9-9092-bbb1517b68eb', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ca3ca92-a06b-56e1-9bbb-1785cf15897a', '753e84c3-fdb8-50c9-9092-bbb1517b68eb', 10, $md$J$md$, false);

COMMIT;
