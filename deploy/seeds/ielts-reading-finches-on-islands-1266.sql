BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-finches-on-islands-1266'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-finches-on-islands-1266';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-finches-on-islands-1266';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-finches-on-islands-1266';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('cc5e1c73-9386-58d1-99ce-caa6cc5a18b3', 'ielts-reading-finches-on-islands-1266', $t$Finches on Islands$t$, $md$## Finches on Islands

Nguồn:
- Test: https://mini-ielts.com/1266/reading/finches-on-islands
- Solution: https://mini-ielts.com/1266/view-solution/reading/finches-on-islands$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 'cc5e1c73-9386-58d1-99ce-caa6cc5a18b3', 1, $t$Reading — Finches on Islands$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Finches on Islands

A

B

The Grants’ most dramatic insights have come from watching the evolving bill of the medium ground finch. The plumage of this sparrow-sized bird ranges from dull brown to jet black. At first glance, it may not seem particularly striking, but among scientists who study evolutionary biology, the medium ground finch is a superstar. Its bill is a middling example in the array of shapes and sizes found among Galápagos finches: heftier than that of the small ground finch, which specializes in eating small, soft seeds, but petite compared to that of the large ground finch, an expert at cracking and devouring big, hard seeds.

C

When the Grants began their study in the 1970s, only two species of finch lived on Daphne Major, the medium ground finch and the cactus finch. The island is so small that the researchers were able to count and catalogue every bird. When a severe drought hit in 1977, the birds soon devoured the last of the small, easily eaten seeds. Smaller members of the medium ground finch population, lacking the bill strength to crack large seeds, died out.

D

Bill and body size are inherited traits, and the next generation had a high proportion of big-billed individuals. The Grants had documented natural selection at work-the same process that, over many millennia, directed the evolution of the Galápagos’ 14 unique finch species, all descended from a common ancestor that reached the islands a few million years ago.

E

Eight years later, heavy rains brought by an El Nino transformed the normally meager vegetation on Daphne Major. Vines and other plants that in most years struggle for survival suddenly flourished, choking out the plants that provide large seeds to the finches. Small seeds came to dominate the food supply, and big birds with big bills died out at a higher rate than smaller ones. ‘Natural selection is observable,’ Rosemary Grant says. ‘It happens when the environment changes. When local conditions reverse themselves, so does the direction of adaptation.

F

Recently, the Grants witnessed another form of natural selection acting on the medium ground finch: competition from bigger, stronger cousins. In 1982, a third finch, the large ground finch, came to live on Daphne Major. The stout bills of these birds resemble the business end of a crescent wrench. Their arrival was the first such colonization recorded on the Galápagos in nearly a century of scientific observation. ‘We realized,’ Peter Grant says, ‘we had a very unusual and potentially important event to follow.’ For 20 years, the large ground finch coexisted with the medium ground finch, which shared the supply of large seeds with its bigger-billed relative. Then, in 2002 and 2003, another drought struck. None of the birds nested that year, and many died out. Medium ground finches with large bills, crowded out of feeding areas by the more powerful large ground finches, were hit particularly hard.

G

When wetter weather returned in 2004, and the finches nested again, the new generation of the medium ground finch was dominated by smaller birds with smaller bills, able to survive on smaller seeds. This situation, says Peter Grant, marked the first time that biologists have been able to follow the complete process of an evolutionary change due to competition between species and the strongest response to natural selection that he had seen in 33 years of tracking Galápagos finches.

H

On the inhabited island of Santa Cruz, just south of Daphne Major, Andrew Hendry of McGill University and Jeffrey Podos of the University of Massachusetts at Amherst have discovered a new, man-made twist in finch evolution. Their study focused on birds living near the Academy Bay research station, on the fringe of the town of Puerto Ayora. The human population of the area has been growing fast-from 900 people in 1974 to 9,582 in 2001. Today Puerto Ayora is full of hotels and mai tai bars,’ Hendry says. ‘People have taken this extremely arid place and tried to turn it into a Caribbean resort.’

I

Academy Bay records dating back to the early 1960s show that medium ground finches captured there had either small or large bills. Very few of the birds had mid-size bills. The finches appeared to be in the early stages of a new adaptive radiation: If the trend continued, the medium ground finch on Santa Cruz could split into two distinct subspecies, specializing in different types of seeds. But in the late 1960s and early 70s, medium ground finches with medium-sized bills began to thrive at Academy Bay along with small and large-billed birds. The booming human population had introduced new food sources, including exotic plants and bird feeding stations stocked with rice. Billsize, once critical to the finches’ survival, no longer made any difference. ‘Now an intermediate bill can do fine,’ Hendry says.

J

At a control site distant from Puerto Ayora, and relatively untouched by humans, the medium ground finch population remains split between large- and small-billed birds. On undisturbed parts of Santa Cruz, there is no ecological niche for a middling medium ground finch, and the birds continue to diversify. In town, though there are still many finches, once-distinct populations are merging.

K

The finches of Santa Cruz demonstrate a subtle process in which human meddling can stop evolution in its tracks, ending the formation of new species. In a time when global biodiversity continues its downhill slide, Darwin’s finches have yet another unexpected lesson to teach. ‘If we hope to regain some of the diversity that’s already been lost/ Hendry says, ‘we need to protect not just existing creatures, but also the processes that drive the origin of new species.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9080ec2f-c146-5d09-b1f6-db8a5ea48665', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 1, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Complete the table now.
Choose
NO MORE THAN TWO WORDS
from Reading Passage 1 for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Year
Climate
Finch’s condition
1977
1
small-beak birds failing to survive, without the power to open
2
1985
3
brought by El Nino
big-beak birds dying out, with
4
as the main food resource

1 ____$md$, NULL, ARRAY['.*drought.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1fae1cc0-3767-559a-aa44-9c1ab735cfe5', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 2, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Complete the table now.
Choose
NO MORE THAN TWO WORDS
from Reading Passage 1 for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Year
Climate
Finch’s condition
1977
1
small-beak birds failing to survive, without the power to open
2
1985
3
brought by El Nino
big-beak birds dying out, with
4
as the main food resource

small-beak birds failing to survive, without the power to open 2 ____$md$, NULL, ARRAY['.*large.*seeds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e2dc22dd-0bd0-53e7-bc86-61fe3dff4524', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 3, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Complete the table now.
Choose
NO MORE THAN TWO WORDS
from Reading Passage 1 for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Year
Climate
Finch’s condition
1977
1
small-beak birds failing to survive, without the power to open
2
1985
3
brought by El Nino
big-beak birds dying out, with
4
as the main food resource

3 ____ brought by El Nino$md$, NULL, ARRAY['.*heavy.*rains.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e174a74c-84d1-5905-980b-70bad7284993', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 4, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Complete the table now.
Choose
NO MORE THAN TWO WORDS
from Reading Passage 1 for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Year
Climate
Finch’s condition
1977
1
small-beak birds failing to survive, without the power to open
2
1985
3
brought by El Nino
big-beak birds dying out, with
4
as the main food resource

big-beak birds dying out, with 4 ____ as the main food resource$md$, NULL, ARRAY['.*small.*seeds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3087a463-a57c-55ea-b24c-5ad3c43f2db2', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage 1
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
On the remote island of Santa Cruz, Andrew Hendry and Jeffrey Podos conducted a study on reversal
5
due to human activity. In the early 1960s medium ground finches were found to have a larger or smaller beak. But in the late 1960s and early 70s, finches with
6
flourished. The study speculates that it is due to the growing
7
who brought in alien plants with intermediate-size seeds into the area and the birds ate
8
sometimes.

On the remote island of Santa Cruz, Andrew Hendry and Jeffrey Podos conducted a study on reversal 5 ____ due to human activity. In the early 1960s medium ground finches were found to have a larger or smaller beak. But in the late 1960s and early 70s, finches with 6 ____ flourished. The study speculates that it is due to the growing 7 ____ who brought in alien plants with intermediate-size seeds into the area and the birds ate 8 ____ sometimes.$md$, NULL, ARRAY['.*finch.*evolution.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('29bfdc6d-9ff0-531c-b06e-6d1ba28ae848', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage 1
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
On the remote island of Santa Cruz, Andrew Hendry and Jeffrey Podos conducted a study on reversal
5
due to human activity. In the early 1960s medium ground finches were found to have a larger or smaller beak. But in the late 1960s and early 70s, finches with
6
flourished. The study speculates that it is due to the growing
7
who brought in alien plants with intermediate-size seeds into the area and the birds ate
8
sometimes.

On the remote island of Santa Cruz, Andrew Hendry and Jeffrey Podos conducted a study on reversal 5 ____ due to human activity. In the early 1960s medium ground finches were found to have a larger or smaller beak. But in the late 1960s and early 70s, finches with 6 ____ flourished. The study speculates that it is due to the growing 7 ____ who brought in alien plants with intermediate-size seeds into the area and the birds ate 8 ____ sometimes.$md$, NULL, ARRAY['.*finch.*evolution.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4d75447c-69b8-55fb-93bd-925cd18465d8', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage 1
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
On the remote island of Santa Cruz, Andrew Hendry and Jeffrey Podos conducted a study on reversal
5
due to human activity. In the early 1960s medium ground finches were found to have a larger or smaller beak. But in the late 1960s and early 70s, finches with
6
flourished. The study speculates that it is due to the growing
7
who brought in alien plants with intermediate-size seeds into the area and the birds ate
8
sometimes.

On the remote island of Santa Cruz, Andrew Hendry and Jeffrey Podos conducted a study on reversal 5 ____ due to human activity. In the early 1960s medium ground finches were found to have a larger or smaller beak. But in the late 1960s and early 70s, finches with 6 ____ flourished. The study speculates that it is due to the growing 7 ____ who brought in alien plants with intermediate-size seeds into the area and the birds ate 8 ____ sometimes.$md$, NULL, ARRAY['.*finch.*evolution.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ac2e8dee-357a-54f7-bd52-0d9024cdb8ef', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage 1
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
On the remote island of Santa Cruz, Andrew Hendry and Jeffrey Podos conducted a study on reversal
5
due to human activity. In the early 1960s medium ground finches were found to have a larger or smaller beak. But in the late 1960s and early 70s, finches with
6
flourished. The study speculates that it is due to the growing
7
who brought in alien plants with intermediate-size seeds into the area and the birds ate
8
sometimes.

On the remote island of Santa Cruz, Andrew Hendry and Jeffrey Podos conducted a study on reversal 5 ____ due to human activity. In the early 1960s medium ground finches were found to have a larger or smaller beak. But in the late 1960s and early 70s, finches with 6 ____ flourished. The study speculates that it is due to the growing 7 ____ who brought in alien plants with intermediate-size seeds into the area and the birds ate 8 ____ sometimes.$md$, NULL, ARRAY['.*finch.*evolution.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('94261edd-c23c-5deb-9a77-bd034f23778a', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the claims of the writer in Reading Passage1?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
Grants’ discovery has questioned Darwin’s theory.
10
The cactus finches are less affected by food than the medium ground finch.
11
In 2002 and 2003, all the birds were affected by the drought.
12
The discovery of Andrew Hendry and Jeffrey Podos was the same as that of the previous studies.
13
It is shown that the revolution in finches on Santa Cruz is likely a response to human intervention.

9 ____ Grants’ discovery has questioned Darwin’s theory.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e2689c8-fd50-5f41-816d-ca21cb14763b', '94261edd-c23c-5deb-9a77-bd034f23778a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98fd2be5-fbea-53df-9649-e2a63d2c90b1', '94261edd-c23c-5deb-9a77-bd034f23778a', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2835bfe-3244-51f9-812e-8d402c38910f', '94261edd-c23c-5deb-9a77-bd034f23778a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('45d92da1-2412-51f8-8c71-f51ff68cc2f4', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the claims of the writer in Reading Passage1?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
Grants’ discovery has questioned Darwin’s theory.
10
The cactus finches are less affected by food than the medium ground finch.
11
In 2002 and 2003, all the birds were affected by the drought.
12
The discovery of Andrew Hendry and Jeffrey Podos was the same as that of the previous studies.
13
It is shown that the revolution in finches on Santa Cruz is likely a response to human intervention.

10 ____ The cactus finches are less affected by food than the medium ground finch.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a66149c5-53d4-58b6-a224-1f39c16a8e02', '45d92da1-2412-51f8-8c71-f51ff68cc2f4', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae968f34-229f-5037-9e6c-1a784c9cefc6', '45d92da1-2412-51f8-8c71-f51ff68cc2f4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68ef2394-c8e2-59e3-88e9-24b4a3b1ce29', '45d92da1-2412-51f8-8c71-f51ff68cc2f4', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d7b8773a-72ff-575e-ac93-2be5958d8a49', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the claims of the writer in Reading Passage1?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
Grants’ discovery has questioned Darwin’s theory.
10
The cactus finches are less affected by food than the medium ground finch.
11
In 2002 and 2003, all the birds were affected by the drought.
12
The discovery of Andrew Hendry and Jeffrey Podos was the same as that of the previous studies.
13
It is shown that the revolution in finches on Santa Cruz is likely a response to human intervention.

11 ____ In 2002 and 2003, all the birds were affected by the drought.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bd68616-a9ef-576b-a6d5-5395f86b1158', 'd7b8773a-72ff-575e-ac93-2be5958d8a49', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca66ec76-15d8-559b-ae94-bbc3888d6edf', 'd7b8773a-72ff-575e-ac93-2be5958d8a49', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55300802-687a-59c0-a682-48e688aa6641', 'd7b8773a-72ff-575e-ac93-2be5958d8a49', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dcffb9be-6d63-5eda-97cf-660c34818003', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the claims of the writer in Reading Passage1?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
Grants’ discovery has questioned Darwin’s theory.
10
The cactus finches are less affected by food than the medium ground finch.
11
In 2002 and 2003, all the birds were affected by the drought.
12
The discovery of Andrew Hendry and Jeffrey Podos was the same as that of the previous studies.
13
It is shown that the revolution in finches on Santa Cruz is likely a response to human intervention.

12 ____ The discovery of Andrew Hendry and Jeffrey Podos was the same as that of the previous studies.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb379282-d1c5-539c-9f6d-a2ea399e953c', 'dcffb9be-6d63-5eda-97cf-660c34818003', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c66e97f2-d83f-564e-a0e5-068636aa8638', 'dcffb9be-6d63-5eda-97cf-660c34818003', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd4903cf-9c91-5583-9489-1cbe997fc9a2', 'dcffb9be-6d63-5eda-97cf-660c34818003', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('973501ab-de22-5681-8eec-11962b53960c', '3bd8c52e-f8f8-560d-9fb0-12e7fee78013', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the claims of the writer in Reading Passage1?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
Grants’ discovery has questioned Darwin’s theory.
10
The cactus finches are less affected by food than the medium ground finch.
11
In 2002 and 2003, all the birds were affected by the drought.
12
The discovery of Andrew Hendry and Jeffrey Podos was the same as that of the previous studies.
13
It is shown that the revolution in finches on Santa Cruz is likely a response to human intervention.

13 ____ It is shown that the revolution in finches on Santa Cruz is likely a response to human intervention.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('636b7d37-9a9c-5f58-9318-94131e4a8dc2', '973501ab-de22-5681-8eec-11962b53960c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9463368f-4b31-5e48-b039-8b51d37fed0d', '973501ab-de22-5681-8eec-11962b53960c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1769a454-c612-59dc-b41a-a2d67bb16f38', '973501ab-de22-5681-8eec-11962b53960c', 3, $md$NOT GIVEN$md$, false);

COMMIT;
