BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-value-of-research-into-mite-harvestmen-1283'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-value-of-research-into-mite-harvestmen-1283';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-value-of-research-into-mite-harvestmen-1283';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-value-of-research-into-mite-harvestmen-1283';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('fe8df285-97cf-5cd7-8fb5-657a8edeea6b', 'ielts-reading-the-value-of-research-into-mite-harvestmen-1283', $t$The value of research into mite harvestmen$t$, $md$## The value of research into mite harvestmen

Nguồn:
- Test: https://mini-ielts.com/1283/reading/the-value-of-research-into-mite-harvestmen
- Solution: https://mini-ielts.com/1283/view-solution/reading/the-value-of-research-into-mite-harvestmen$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('b660314d-b491-59c2-a657-c9553a0c4893', 'fe8df285-97cf-5cd7-8fb5-657a8edeea6b', 1, $t$Reading — The value of research into mite harvestmen$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The value of research into mite harvestmen

Few people have heard of the mite harvestman, and fewer still would recognize it at close range. The insect is a relative of the far more familiar daddy longlegs. But its legs are stubby rather than long, and its body is only as big as a sesame seed. To find mite harvestmen, scientists go to dark, humid forests and sift through the leaf litter. The animals respond by turning motionless, making them impossible for even a trained eye to pick out.’ They look like grains of dirt.’ said Gonzalo Giribet, an invertebrate biologist at Harvard University.

Dr Giribet and his colleagues have spent six years searching for mite harvestmen on five continents. The animals have an extraordinary story to tell they carry a record of hundreds of millions of years of geological history, chronicling the journeys that continents have made around the Earth. The Earth’s landmasses have slowly collided and broken apart again several times, carrying animals and plants with them. These species have provided clues to the continents’ paths.

The notion of continental drift originally came from such clues. In 1911, the German scientist Alfred Wegener was struck by the fact that fossils of similar animals and plants could be found on either side of the Atlantic. The ocean was too big for the species to have traveled across it on their own. Wegener speculated correctly, as it turned out that the surrounding continents had originally been welded together in a single landmass, which he called Pangea.

Continental drift, or plate tectonics as it is scientifically known, helped move species around the world. Armadillos and their relatives are found in South America and Africa today because their ancestors evolved when the continents were joined. When South America and North America connected a few million years ago, armadillos spread north, too.

Biogeographers can learn clues about continental drift by comparing related species. However, they must also recognize cases where species have spread for other reasons, such as by crossing great stretches of water. The island of Hawaii, for example, was home to a giant flightless goose that has become extinct. Studies on DNA extracted from its bones show that it evolved from the Canada goose. Having colonized Hawaii, it branched off from that species, losing its ability to fly. This evolution occurred half a million years ago, when geologists estimate that Hawaii emerged from the Pacific.

When species jump around the planet, their histories blur. It is difficult to say much about where cockroaches evolved, for example, because they can move quickly from continent to continent. This process, known as dispersal, limits many studies. ‘Most of them tend to concentrate on particular parts of the world.' Dr Giribet said. I wanted to find a new system for studying biogeography on a global scale.

Dr Giribet realized that mite harvestmen might be that system. The 5,000 or so mite harvestmen species can be found on every continent except Antarctica. Unlike creatures found around the world like cockroaches, mite harvestmen cannot disperse well. The typical harvestman species has a range of fewer than 50 miles. Harvestmen are not found on young islands like Hawaii, as these types of islands emerged long after the break-up of Pangea.

According to Assistant Professor Sarah Boyer, a former student of Dr Giribet. ‘It’s really hard to find a group of species that is distributed all over the world but that also doesn’t disperse very far.'

What mite harvestmen lack in mobility, they make up in age. Their ancestors were among the first land animals, and fossils of daddy longlegs have been found in 400 million-year-ago rocks. Mite harvestmen evolved long before Pangea broke up and have been carried along by continental drift ever since they’ve managed to get themselves around the world only because they’ve been around for hundreds of millions of years, Dr Boyer said. Dr Boyer, Dr Giribet and their colleagues have gathered thousands of mite harvestmen from around the world, from which they extracted DNA. Variations in the genes helped the scientists build an evolutionary tree. By calculating how quickly the DNA mutated, the scientists could estimate when lineages branched off. They then compared the harvestmen's evolution to the movements of the continents. ‘The patterns are remarkably clear.’ Dr Boyer said.

The scientists found that they could trace mite harvestmen from their ancestors on Pangea. One lineage includes species in Chile South Africa, Sri Lanka and other places separated by thousands of miles of ocean. But 150 million years ago, all those sites were in Gondwana which was a region of Pangea.

The harvestmen preserve smaller patterns of continental drift, as well as bigger ones. After analyzing the DNA of a Florida harvestman, Metasiro americanus, the scientists were surprised to find that it was not related to other North American species. Its closet relatives live in West Africa. Dr Boyer then began investigating the geological history of Florida and found recent research to explain the mystery. Florida started out welded to West Africa near Segenal. North America than collied into them Pangea was forming. About 170 million years ago, North America ripped away from West Africa, taking Florida with it. The African ancestors of Florida’s harvestmen came along the ride.

Dr Giribet now hopes to study dozens or even hundreds of species, to find clues about plate tectonics that a single animal could not show.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2604b6d7-0edc-51df-a334-960a56f60220', 'b660314d-b491-59c2-a657-c9553a0c4893', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

QUESTIONS 1-6
QUESTIONS 1-6
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes 1-6 on your answer sheet.
27. Why is it difficult to find mite harvestmen?
A
they are too small to see with naked eye.
B
they can easily be confused with daddy longlegs.
C
they are hard to distinguish from their surroundings.
27##qi they do not exist in large numbers in any one place.
28. Why are mile harvestmen of interest to Dr Giribet and his colleagues?
A
they have been studied far less than most other species.
B
they show the effects of climate on the evolution of animals.
C
they have an unusual relationship with plants and other animals.
D
they provide evidence relating to a field of study other than insects.
29. What factor contributed to Wegener’s idea that present-day continents used to form a single landmass?
A
changes in the level of the ocean
B
the distance that species could travel
C
the lack of certain fossils on one side of the Atlantic
D
similarities in living conditions on both sides of the Atlantic
30. What point is made by the reference to armadillos?
A
regions have both separated and become connected.
B
certain animals could travel longer distances than others.
C
the oldest species of animals are likely to be found in Africa.
D
there is a tendency for animals to spread in a particular direction.
31. Which of the following is stated in the fifth paragraph?
A
Hawaii is a habitat that cannot support large birds.
B
Hawaii is an attractive habitat for certain species of birds.
C
flightless birds are more likely to become extinct than others.
D
the Hawaiian goose became flightless after it had reached Hawaii.
32. Why is evidence from cockroached of limited value?
A
they spread too fast.
B
they multiply too quickly.
C
they are found in too few places.
D
they have divided into too many species.

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c90cd036-aa9e-5b92-8890-ac4810e9159e', 'b660314d-b491-59c2-a657-c9553a0c4893', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

QUESTIONS 1-6
QUESTIONS 1-6
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes 1-6 on your answer sheet.
27. Why is it difficult to find mite harvestmen?
A
they are too small to see with naked eye.
B
they can easily be confused with daddy longlegs.
C
they are hard to distinguish from their surroundings.
27##qi they do not exist in large numbers in any one place.
28. Why are mile harvestmen of interest to Dr Giribet and his colleagues?
A
they have been studied far less than most other species.
B
they show the effects of climate on the evolution of animals.
C
they have an unusual relationship with plants and other animals.
D
they provide evidence relating to a field of study other than insects.
29. What factor contributed to Wegener’s idea that present-day continents used to form a single landmass?
A
changes in the level of the ocean
B
the distance that species could travel
C
the lack of certain fossils on one side of the Atlantic
D
similarities in living conditions on both sides of the Atlantic
30. What point is made by the reference to armadillos?
A
regions have both separated and become connected.
B
certain animals could travel longer distances than others.
C
the oldest species of animals are likely to be found in Africa.
D
there is a tendency for animals to spread in a particular direction.
31. Which of the following is stated in the fifth paragraph?
A
Hawaii is a habitat that cannot support large birds.
B
Hawaii is an attractive habitat for certain species of birds.
C
flightless birds are more likely to become extinct than others.
D
the Hawaiian goose became flightless after it had reached Hawaii.
32. Why is evidence from cockroached of limited value?
A
they spread too fast.
B
they multiply too quickly.
C
they are found in too few places.
D
they have divided into too many species.

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5c4d3580-8e76-5bd0-999d-5c45a2f4af17', 'b660314d-b491-59c2-a657-c9553a0c4893', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

QUESTIONS 1-6
QUESTIONS 1-6
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes 1-6 on your answer sheet.
27. Why is it difficult to find mite harvestmen?
A
they are too small to see with naked eye.
B
they can easily be confused with daddy longlegs.
C
they are hard to distinguish from their surroundings.
27##qi they do not exist in large numbers in any one place.
28. Why are mile harvestmen of interest to Dr Giribet and his colleagues?
A
they have been studied far less than most other species.
B
they show the effects of climate on the evolution of animals.
C
they have an unusual relationship with plants and other animals.
D
they provide evidence relating to a field of study other than insects.
29. What factor contributed to Wegener’s idea that present-day continents used to form a single landmass?
A
changes in the level of the ocean
B
the distance that species could travel
C
the lack of certain fossils on one side of the Atlantic
D
similarities in living conditions on both sides of the Atlantic
30. What point is made by the reference to armadillos?
A
regions have both separated and become connected.
B
certain animals could travel longer distances than others.
C
the oldest species of animals are likely to be found in Africa.
D
there is a tendency for animals to spread in a particular direction.
31. Which of the following is stated in the fifth paragraph?
A
Hawaii is a habitat that cannot support large birds.
B
Hawaii is an attractive habitat for certain species of birds.
C
flightless birds are more likely to become extinct than others.
D
the Hawaiian goose became flightless after it had reached Hawaii.
32. Why is evidence from cockroached of limited value?
A
they spread too fast.
B
they multiply too quickly.
C
they are found in too few places.
D
they have divided into too many species.

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e633f851-c355-5ef8-a917-82f8d2d094cc', 'b660314d-b491-59c2-a657-c9553a0c4893', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

QUESTIONS 1-6
QUESTIONS 1-6
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes 1-6 on your answer sheet.
27. Why is it difficult to find mite harvestmen?
A
they are too small to see with naked eye.
B
they can easily be confused with daddy longlegs.
C
they are hard to distinguish from their surroundings.
27##qi they do not exist in large numbers in any one place.
28. Why are mile harvestmen of interest to Dr Giribet and his colleagues?
A
they have been studied far less than most other species.
B
they show the effects of climate on the evolution of animals.
C
they have an unusual relationship with plants and other animals.
D
they provide evidence relating to a field of study other than insects.
29. What factor contributed to Wegener’s idea that present-day continents used to form a single landmass?
A
changes in the level of the ocean
B
the distance that species could travel
C
the lack of certain fossils on one side of the Atlantic
D
similarities in living conditions on both sides of the Atlantic
30. What point is made by the reference to armadillos?
A
regions have both separated and become connected.
B
certain animals could travel longer distances than others.
C
the oldest species of animals are likely to be found in Africa.
D
there is a tendency for animals to spread in a particular direction.
31. Which of the following is stated in the fifth paragraph?
A
Hawaii is a habitat that cannot support large birds.
B
Hawaii is an attractive habitat for certain species of birds.
C
flightless birds are more likely to become extinct than others.
D
the Hawaiian goose became flightless after it had reached Hawaii.
32. Why is evidence from cockroached of limited value?
A
they spread too fast.
B
they multiply too quickly.
C
they are found in too few places.
D
they have divided into too many species.

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6ab7dd8f-9f4e-584b-a4b5-1dd85e66c160', 'b660314d-b491-59c2-a657-c9553a0c4893', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

QUESTIONS 1-6
QUESTIONS 1-6
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes 1-6 on your answer sheet.
27. Why is it difficult to find mite harvestmen?
A
they are too small to see with naked eye.
B
they can easily be confused with daddy longlegs.
C
they are hard to distinguish from their surroundings.
27##qi they do not exist in large numbers in any one place.
28. Why are mile harvestmen of interest to Dr Giribet and his colleagues?
A
they have been studied far less than most other species.
B
they show the effects of climate on the evolution of animals.
C
they have an unusual relationship with plants and other animals.
D
they provide evidence relating to a field of study other than insects.
29. What factor contributed to Wegener’s idea that present-day continents used to form a single landmass?
A
changes in the level of the ocean
B
the distance that species could travel
C
the lack of certain fossils on one side of the Atlantic
D
similarities in living conditions on both sides of the Atlantic
30. What point is made by the reference to armadillos?
A
regions have both separated and become connected.
B
certain animals could travel longer distances than others.
C
the oldest species of animals are likely to be found in Africa.
D
there is a tendency for animals to spread in a particular direction.
31. Which of the following is stated in the fifth paragraph?
A
Hawaii is a habitat that cannot support large birds.
B
Hawaii is an attractive habitat for certain species of birds.
C
flightless birds are more likely to become extinct than others.
D
the Hawaiian goose became flightless after it had reached Hawaii.
32. Why is evidence from cockroached of limited value?
A
they spread too fast.
B
they multiply too quickly.
C
they are found in too few places.
D
they have divided into too many species.

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('02fb96bd-5129-533d-a88c-7f765c26e09c', 'b660314d-b491-59c2-a657-c9553a0c4893', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

QUESTIONS 1-6
QUESTIONS 1-6
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes 1-6 on your answer sheet.
27. Why is it difficult to find mite harvestmen?
A
they are too small to see with naked eye.
B
they can easily be confused with daddy longlegs.
C
they are hard to distinguish from their surroundings.
27##qi they do not exist in large numbers in any one place.
28. Why are mile harvestmen of interest to Dr Giribet and his colleagues?
A
they have been studied far less than most other species.
B
they show the effects of climate on the evolution of animals.
C
they have an unusual relationship with plants and other animals.
D
they provide evidence relating to a field of study other than insects.
29. What factor contributed to Wegener’s idea that present-day continents used to form a single landmass?
A
changes in the level of the ocean
B
the distance that species could travel
C
the lack of certain fossils on one side of the Atlantic
D
similarities in living conditions on both sides of the Atlantic
30. What point is made by the reference to armadillos?
A
regions have both separated and become connected.
B
certain animals could travel longer distances than others.
C
the oldest species of animals are likely to be found in Africa.
D
there is a tendency for animals to spread in a particular direction.
31. Which of the following is stated in the fifth paragraph?
A
Hawaii is a habitat that cannot support large birds.
B
Hawaii is an attractive habitat for certain species of birds.
C
flightless birds are more likely to become extinct than others.
D
the Hawaiian goose became flightless after it had reached Hawaii.
32. Why is evidence from cockroached of limited value?
A
they spread too fast.
B
they multiply too quickly.
C
they are found in too few places.
D
they have divided into too many species.

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ee92d482-180f-5b87-b5c0-87a78662a962', 'b660314d-b491-59c2-a657-c9553a0c4893', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

QUESTIONS 7-10
QUESTIONS 7-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 7-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
7
The colonization of Hawaii by geese provides evidence of continental drift.
8
The reason why mite harvestmen don’t exist on Hawaii can be explained.
9
The DNA of certain species has evolved more quickly than that of others.
10
Dr Boyer’s theory concerning the origins of Florida is widely accepted.

7 ____ The colonization of Hawaii by geese provides evidence of continental drift.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe86f011-ae63-5114-a44f-127108653aa6', 'ee92d482-180f-5b87-b5c0-87a78662a962', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d799812f-fc63-5a8d-b24e-03a101ddc481', 'ee92d482-180f-5b87-b5c0-87a78662a962', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8849f308-7c8c-5b40-a184-c812043a3360', 'ee92d482-180f-5b87-b5c0-87a78662a962', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bbbc5829-3066-5d92-8ec0-42361cfe3d84', 'b660314d-b491-59c2-a657-c9553a0c4893', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

QUESTIONS 7-10
QUESTIONS 7-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 7-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
7
The colonization of Hawaii by geese provides evidence of continental drift.
8
The reason why mite harvestmen don’t exist on Hawaii can be explained.
9
The DNA of certain species has evolved more quickly than that of others.
10
Dr Boyer’s theory concerning the origins of Florida is widely accepted.

8 ____ The reason why mite harvestmen don’t exist on Hawaii can be explained.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3fc071c3-5b89-5a91-8b74-91d29a831a1d', 'bbbc5829-3066-5d92-8ec0-42361cfe3d84', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('193f4844-085e-5283-b7e4-00e5f736b1ac', 'bbbc5829-3066-5d92-8ec0-42361cfe3d84', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e081e71-e8db-5635-b97a-2e1344b1c819', 'bbbc5829-3066-5d92-8ec0-42361cfe3d84', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f55f038f-8232-5886-a53a-3ff64673fa0e', 'b660314d-b491-59c2-a657-c9553a0c4893', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

QUESTIONS 7-10
QUESTIONS 7-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 7-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
7
The colonization of Hawaii by geese provides evidence of continental drift.
8
The reason why mite harvestmen don’t exist on Hawaii can be explained.
9
The DNA of certain species has evolved more quickly than that of others.
10
Dr Boyer’s theory concerning the origins of Florida is widely accepted.

9 ____ The DNA of certain species has evolved more quickly than that of others.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7225d53-38bd-5e82-96b5-b6ef85dfb824', 'f55f038f-8232-5886-a53a-3ff64673fa0e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0953ca09-9d07-52d2-87cd-50227ff22fe3', 'f55f038f-8232-5886-a53a-3ff64673fa0e', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6890459-7d68-55c0-a309-ed3fcbf0354c', 'f55f038f-8232-5886-a53a-3ff64673fa0e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ee9c1e99-c615-5292-abd5-7ae150bd8660', 'b660314d-b491-59c2-a657-c9553a0c4893', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

QUESTIONS 7-10
QUESTIONS 7-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 7-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
7
The colonization of Hawaii by geese provides evidence of continental drift.
8
The reason why mite harvestmen don’t exist on Hawaii can be explained.
9
The DNA of certain species has evolved more quickly than that of others.
10
Dr Boyer’s theory concerning the origins of Florida is widely accepted.

10 ____ Dr Boyer’s theory concerning the origins of Florida is widely accepted.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81acfafc-dcaf-5efb-b159-2e1cf8b5cb56', 'ee9c1e99-c615-5292-abd5-7ae150bd8660', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fba132a6-0e48-586e-bf9a-10a75c9d12ca', 'ee9c1e99-c615-5292-abd5-7ae150bd8660', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0572cbea-53d1-5215-90ae-41b098a2cda0', 'ee9c1e99-c615-5292-abd5-7ae150bd8660', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('230171f0-2695-5bd8-80e9-19b4e943cc3f', 'b660314d-b491-59c2-a657-c9553a0c4893', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

QUESTIONS 11-14
QUESTIONS 11-14
Complete the summary using the list of words
A-I
below.
Write the correct letter
A-I
in boxes 11-14 on your answer sheet.
List of words
A
branches
B
fossils
C
drift
D
DNA
E
evolution
F
Pangea
G
dispersal
H
ancestors
I
continents
The age and evolution of mite harvestmen
Some of the first creatures to live on land were the
11
of mite harvestmen. Boyer, Giribet and others study differences in the
12
of these insects, and trace the development of a number of
13
of the species.
Their evolution appears to reflect changes in the location of
14
. For example, the same type of mite harvestman is found in places that are now far apart but used to form Gondwana, part of a huge landmass.

Some of the first creatures to live on land were the 11 ____ of mite harvestmen. Boyer, Giribet and others study differences in the 12 ____ of these insects, and trace the development of a number of 13 ____ of the species.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01ba0c5b-6568-5573-965e-0e155d8a6658', '230171f0-2695-5bd8-80e9-19b4e943cc3f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f62c3339-7aca-518d-ba34-22fddaf08de0', '230171f0-2695-5bd8-80e9-19b4e943cc3f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a7cbd5e-8f11-52f8-a9d3-39a5e297e80f', '230171f0-2695-5bd8-80e9-19b4e943cc3f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73b3410b-cdda-5045-bc89-a48b7be3b001', '230171f0-2695-5bd8-80e9-19b4e943cc3f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c48225c-0d8c-52fa-87a9-46955a3e6e86', '230171f0-2695-5bd8-80e9-19b4e943cc3f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bb5b64d-0af5-5418-8a34-83f2277a7152', '230171f0-2695-5bd8-80e9-19b4e943cc3f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb0e9ba4-35f7-5a7f-8534-df3e72dc9788', '230171f0-2695-5bd8-80e9-19b4e943cc3f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('993f23b6-ff8b-5b7e-825a-cb313c970d3e', '230171f0-2695-5bd8-80e9-19b4e943cc3f', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd4c7849-cbfb-5229-8bea-3b2d685fc13a', '230171f0-2695-5bd8-80e9-19b4e943cc3f', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac136b7a-a034-50d3-b895-f40ff0e49f0b', 'b660314d-b491-59c2-a657-c9553a0c4893', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

QUESTIONS 11-14
QUESTIONS 11-14
Complete the summary using the list of words
A-I
below.
Write the correct letter
A-I
in boxes 11-14 on your answer sheet.
List of words
A
branches
B
fossils
C
drift
D
DNA
E
evolution
F
Pangea
G
dispersal
H
ancestors
I
continents
The age and evolution of mite harvestmen
Some of the first creatures to live on land were the
11
of mite harvestmen. Boyer, Giribet and others study differences in the
12
of these insects, and trace the development of a number of
13
of the species.
Their evolution appears to reflect changes in the location of
14
. For example, the same type of mite harvestman is found in places that are now far apart but used to form Gondwana, part of a huge landmass.

Some of the first creatures to live on land were the 11 ____ of mite harvestmen. Boyer, Giribet and others study differences in the 12 ____ of these insects, and trace the development of a number of 13 ____ of the species.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b50a7a41-698f-5c8e-befd-41b4b25115b7', 'ac136b7a-a034-50d3-b895-f40ff0e49f0b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2497f52-42eb-5311-b9c4-3763f66f4cd5', 'ac136b7a-a034-50d3-b895-f40ff0e49f0b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f67619a-0c4c-52f4-bdd0-98387e3d3088', 'ac136b7a-a034-50d3-b895-f40ff0e49f0b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe66b40a-1712-5736-89be-02e9692d7e56', 'ac136b7a-a034-50d3-b895-f40ff0e49f0b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('beb2ce10-54f1-57b6-ab8e-6db19d1d21cd', 'ac136b7a-a034-50d3-b895-f40ff0e49f0b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b86c6a1-a63a-5f8f-829c-9e8a52b613c9', 'ac136b7a-a034-50d3-b895-f40ff0e49f0b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b8083fb-d527-53cb-87c8-d5c258f0c123', 'ac136b7a-a034-50d3-b895-f40ff0e49f0b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c78270f5-a64d-5e5d-ae27-7ce440b72916', 'ac136b7a-a034-50d3-b895-f40ff0e49f0b', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3f5c900-4216-510e-882d-e1b43b9cc80e', 'ac136b7a-a034-50d3-b895-f40ff0e49f0b', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('079a820c-e5c7-5b9d-b431-ca8d54a4f7f6', 'b660314d-b491-59c2-a657-c9553a0c4893', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

QUESTIONS 11-14
QUESTIONS 11-14
Complete the summary using the list of words
A-I
below.
Write the correct letter
A-I
in boxes 11-14 on your answer sheet.
List of words
A
branches
B
fossils
C
drift
D
DNA
E
evolution
F
Pangea
G
dispersal
H
ancestors
I
continents
The age and evolution of mite harvestmen
Some of the first creatures to live on land were the
11
of mite harvestmen. Boyer, Giribet and others study differences in the
12
of these insects, and trace the development of a number of
13
of the species.
Their evolution appears to reflect changes in the location of
14
. For example, the same type of mite harvestman is found in places that are now far apart but used to form Gondwana, part of a huge landmass.

Some of the first creatures to live on land were the 11 ____ of mite harvestmen. Boyer, Giribet and others study differences in the 12 ____ of these insects, and trace the development of a number of 13 ____ of the species.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60dce147-27a2-5d52-9c27-958a71c447f4', '079a820c-e5c7-5b9d-b431-ca8d54a4f7f6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('faca652e-75ff-5b93-a876-bb8695f9dbd9', '079a820c-e5c7-5b9d-b431-ca8d54a4f7f6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f21300d7-16bf-588b-a758-1f589f842a4a', '079a820c-e5c7-5b9d-b431-ca8d54a4f7f6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('321d5feb-54af-5c0f-97b4-ff380e01af20', '079a820c-e5c7-5b9d-b431-ca8d54a4f7f6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b31fd742-3334-5d93-af8a-af9e8043fce7', '079a820c-e5c7-5b9d-b431-ca8d54a4f7f6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5331abf-61ac-57e0-87ad-8606331ae2b7', '079a820c-e5c7-5b9d-b431-ca8d54a4f7f6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f48f72f2-2b82-5807-a1e5-825f59b68851', '079a820c-e5c7-5b9d-b431-ca8d54a4f7f6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da85d8f5-b8be-5bbd-9b28-022d0f1f05db', '079a820c-e5c7-5b9d-b431-ca8d54a4f7f6', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0089daa4-716b-503e-b28b-a7cac294ad3c', '079a820c-e5c7-5b9d-b431-ca8d54a4f7f6', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e25b73dc-0fdd-5bd7-aa36-24f7fc524509', 'b660314d-b491-59c2-a657-c9553a0c4893', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

QUESTIONS 11-14
QUESTIONS 11-14
Complete the summary using the list of words
A-I
below.
Write the correct letter
A-I
in boxes 11-14 on your answer sheet.
List of words
A
branches
B
fossils
C
drift
D
DNA
E
evolution
F
Pangea
G
dispersal
H
ancestors
I
continents
The age and evolution of mite harvestmen
Some of the first creatures to live on land were the
11
of mite harvestmen. Boyer, Giribet and others study differences in the
12
of these insects, and trace the development of a number of
13
of the species.
Their evolution appears to reflect changes in the location of
14
. For example, the same type of mite harvestman is found in places that are now far apart but used to form Gondwana, part of a huge landmass.

Their evolution appears to reflect changes in the location of 14 ____ . For example, the same type of mite harvestman is found in places that are now far apart but used to form Gondwana, part of a huge landmass.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96d23776-4198-5df4-b881-73263b7415cf', 'e25b73dc-0fdd-5bd7-aa36-24f7fc524509', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3824e131-0a52-5821-b0b1-20e16aaa20e4', 'e25b73dc-0fdd-5bd7-aa36-24f7fc524509', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd4f9ffd-08ff-5acb-97ed-b9efd8444eee', 'e25b73dc-0fdd-5bd7-aa36-24f7fc524509', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('351b8b10-a480-59b5-a648-3003e77a2d2d', 'e25b73dc-0fdd-5bd7-aa36-24f7fc524509', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4921a60b-7adf-5990-909f-c83572ed3aa1', 'e25b73dc-0fdd-5bd7-aa36-24f7fc524509', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6114b5b-9435-5053-a666-3c038ff9d6af', 'e25b73dc-0fdd-5bd7-aa36-24f7fc524509', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87deb8f7-cdd6-535f-a2fd-ee1a97f711a9', 'e25b73dc-0fdd-5bd7-aa36-24f7fc524509', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a99fc9e-f742-5d16-aaf9-ca110ad95442', 'e25b73dc-0fdd-5bd7-aa36-24f7fc524509', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8765032-641b-550c-b340-a7f74262c279', 'e25b73dc-0fdd-5bd7-aa36-24f7fc524509', 9, $md$I$md$, true);

COMMIT;
