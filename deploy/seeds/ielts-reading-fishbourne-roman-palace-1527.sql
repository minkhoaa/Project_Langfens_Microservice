BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-fishbourne-roman-palace-1527'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-fishbourne-roman-palace-1527';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-fishbourne-roman-palace-1527';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-fishbourne-roman-palace-1527';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('053ce4aa-2821-5c9e-aaa7-148d9760f738', 'ielts-reading-fishbourne-roman-palace-1527', $t$Fishbourne Roman Palace$t$, $md$## Fishbourne Roman Palace

Nguồn:
- Test: https://mini-ielts.com/1527/reading/fishbourne-roman-palace
- Solution: https://mini-ielts.com/1527/view-solution/reading/fishbourne-roman-palace$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('4abc0595-42b6-5c07-9503-6bc60e0f5de3', '053ce4aa-2821-5c9e-aaa7-148d9760f738', 1, $t$Reading — Fishbourne Roman Palace$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Fishbourne Roman Palace

Fishbourne Roman Palace is in the village of Fishbourne in West Sussex, England. This large palace was built in the 1 st century AD, around thirty years after the Roman conquest of Britain ,on the site of Roman army grain stores which had been established after the invasion, in the reign of the Roman Emperor Claudius in 43 AD. The rectangular palace was built around formal gardens, the northern half of which have been reconstructed. There were extensive alterations in the 2 nd and 3 rd centuries AD, with many of the original black and white mosaic floors being overlaid with more sophisticated coloured ones , including a perfectly preserved mosaic of a dolphin in the north wing. More alterations were in progress when the palace burnt down in around 270AD,after which it was abandoned.

Local people had long believed that a Roman palace once existed in the area .However, it was not until 1960 that the archaeologist Barry Cunliffe, of Oxford University, first systematically excavated the site, after workmen had accidentally uncovered a wall while they were laying a water main .The Roman villa excavated by Cunliffe's team was so grand that it became known as Fishbourne Roman Palace ,and a museum was erected to preserve some of the remains .This is administered by the Sussex Archaeological Society.

In its day, the completed palace would have comprised four large wings with colonnaded fronts. The north and east wings consisted of suites of private rooms built around courtyards, with a monumental entrance in the middle of the east wing. In the north-east corner there was an assembly hall. The west wing contained state rooms, a large ceremonial reception room, and a gallery. The south wing contained the owner’s private apartments. The palace included as many as 50 mosaic floors, under-floor central heating and a bathhouse. In size, Fishbourne Palace would have been approximately equivalent to some of the great Roman palaces of Italy, and was by far the largest known Roman residence north of the European Alps, at about 500 feet (150m)square. A team of volunteers and professional archaeologists are involved in an ongoing archaeological excavation on the site of nearby, possibly military, buildings.

The first buildings to be erected on the site were constructed in the early part of the conquest in 43 AD. Later, two timber buildings were constructed, one with clay and mortar floors and plaster walls, which appears to have been a house of some comfort. These buildings were demolished in the 60s AD and replaced by a substantial stone house, which included colonnades, and a bath suite. It has been suggested that the palaces itself, incorporating the previous house in its south-east corner, was constructed around 73-75 AD. However, Dr Miles Russell, of Bournemouth University, reinterpreted the ground plan and the collection of objects found and has suggested that, given the extremely close parallels with the imperial palace of Domitian in Rome, its construction may more plausibly date to after 92 AD.

With regard to who lived in Fishbourne Palace, there are a number of theories; for example ,one proposed by Professor Cunliffe is that ,in its early phase, the palace was the residence of Tiberius

Claudius Cogidubnus ,a local chieftain who supported the Romans ,and who may have been installed as king of a number of territories following the first stage of the conquest. Cogidubnus is known from a reference to his loyalty in Agricola, a work by the Roman writer Tacitus, and from an inscription commemorating a temple dedicated to the gods Neptune and Minerva found in the nearby city of Chichester. Another theory is that it was built for Sallustius Lucullus, a Roman governor of Britain of the late 1 st century, who may have been the son of the British prince Adminius. Two inscriptions recording the presence of Lucullus have been found in Chichester, and the redating by Miles Russell of the palace was designed for Lucullus, then it may have only been in use for a few years, as the Roman historian Suetonius records that Lucullus was executed by the Emperor Domitian in or shortly after 93 AD.

Additional theories suggest that either Verica, a British king of the Roman Empire in the years preceding the Claudian invasion, was owner of the palace, or Tiberius Claudius Catuarus , following the recent discovery of a gold ring belonging to him. The palace outlasted the original owner, whoever he was, and was extensively re-planned early in the 2 nd century AD, and subdivided into a series of lesser apartments. Further redevelopment was begun in the late 3 rd century AD, but these alterations were incomplete when the north wing was destroyed in a fire in around 270 AD. The damage was too great repair, and the palace was abandoned and later dismantled.

A modern museum had been built by the Sussex Archaeological Society, incorporating most of the visible remains , including one wing of the palace. The gardens have been re-planted using authentic plants from the Roman period.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7b41826c-0008-5011-9a66-f5bcad309789', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ?
In boxes 1-6 on your answer sheet,write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Fishbourne Palace was the first structure to be built on its site.
2
Fishbourne Palace was renovated more than once
3
Fishbourne Palace was large in comparison with Roman palaces in Italy.
4
Research is continuing in the area clos to Fishbourne Palace.
5
Researches agree on the identity of the person for whom Fishbourne Palace was constructed.
6
Fishbourne Palace was burnt down by local people.

1 ____ Fishbourne Palace was the first structure to be built on its site.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('feb7c435-db05-5e79-8db0-f158381f074c', '7b41826c-0008-5011-9a66-f5bcad309789', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24b0a510-b1ca-5248-8725-6457758de0aa', '7b41826c-0008-5011-9a66-f5bcad309789', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54df2f23-9dbc-5b77-877d-f4001c64f85f', '7b41826c-0008-5011-9a66-f5bcad309789', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('347f48ed-8499-5bac-9f54-aaa1d2a9326c', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ?
In boxes 1-6 on your answer sheet,write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Fishbourne Palace was the first structure to be built on its site.
2
Fishbourne Palace was renovated more than once
3
Fishbourne Palace was large in comparison with Roman palaces in Italy.
4
Research is continuing in the area clos to Fishbourne Palace.
5
Researches agree on the identity of the person for whom Fishbourne Palace was constructed.
6
Fishbourne Palace was burnt down by local people.

2 ____ Fishbourne Palace was renovated more than once$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10a9e6ee-7391-5570-be7b-50f654c0e169', '347f48ed-8499-5bac-9f54-aaa1d2a9326c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93d045fd-c75f-519d-95a1-57c147866ee1', '347f48ed-8499-5bac-9f54-aaa1d2a9326c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbf1f259-038f-58a8-a267-5c58f4a7356a', '347f48ed-8499-5bac-9f54-aaa1d2a9326c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fdfbbcca-2489-5f94-a3c0-eb07f73ffa2c', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ?
In boxes 1-6 on your answer sheet,write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Fishbourne Palace was the first structure to be built on its site.
2
Fishbourne Palace was renovated more than once
3
Fishbourne Palace was large in comparison with Roman palaces in Italy.
4
Research is continuing in the area clos to Fishbourne Palace.
5
Researches agree on the identity of the person for whom Fishbourne Palace was constructed.
6
Fishbourne Palace was burnt down by local people.

3 ____ Fishbourne Palace was large in comparison with Roman palaces in Italy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9391024-b86f-5ed0-9cb9-0d117dba6265', 'fdfbbcca-2489-5f94-a3c0-eb07f73ffa2c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('762ff2d6-6f39-51da-8c27-03e712c1164b', 'fdfbbcca-2489-5f94-a3c0-eb07f73ffa2c', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('810cec03-94bd-5949-9f10-71746d289aca', 'fdfbbcca-2489-5f94-a3c0-eb07f73ffa2c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7de875b0-49df-50a5-87ca-145e74058730', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ?
In boxes 1-6 on your answer sheet,write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Fishbourne Palace was the first structure to be built on its site.
2
Fishbourne Palace was renovated more than once
3
Fishbourne Palace was large in comparison with Roman palaces in Italy.
4
Research is continuing in the area clos to Fishbourne Palace.
5
Researches agree on the identity of the person for whom Fishbourne Palace was constructed.
6
Fishbourne Palace was burnt down by local people.

4 ____ Research is continuing in the area clos to Fishbourne Palace.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5dc402b7-fe3c-53b4-a81a-c5fd04b4693d', '7de875b0-49df-50a5-87ca-145e74058730', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fe0b37f-3710-56a7-8b71-a2e95f743cb1', '7de875b0-49df-50a5-87ca-145e74058730', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff8d0c44-099a-5b03-8d80-4788357679f0', '7de875b0-49df-50a5-87ca-145e74058730', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0be0b94f-5137-5f87-aced-6b1829d878a4', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ?
In boxes 1-6 on your answer sheet,write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Fishbourne Palace was the first structure to be built on its site.
2
Fishbourne Palace was renovated more than once
3
Fishbourne Palace was large in comparison with Roman palaces in Italy.
4
Research is continuing in the area clos to Fishbourne Palace.
5
Researches agree on the identity of the person for whom Fishbourne Palace was constructed.
6
Fishbourne Palace was burnt down by local people.

5 ____ Researches agree on the identity of the person for whom Fishbourne Palace was constructed.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9eda9422-8ad1-52ce-8571-b8edf639c2de', '0be0b94f-5137-5f87-aced-6b1829d878a4', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eeeff90d-078a-5df8-89b3-0b637d5c262d', '0be0b94f-5137-5f87-aced-6b1829d878a4', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cbccb13-3667-5101-83df-6e26a1eaa436', '0be0b94f-5137-5f87-aced-6b1829d878a4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dfdabed9-9c55-5b61-abab-80978c9d701a', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage ?
In boxes 1-6 on your answer sheet,write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Fishbourne Palace was the first structure to be built on its site.
2
Fishbourne Palace was renovated more than once
3
Fishbourne Palace was large in comparison with Roman palaces in Italy.
4
Research is continuing in the area clos to Fishbourne Palace.
5
Researches agree on the identity of the person for whom Fishbourne Palace was constructed.
6
Fishbourne Palace was burnt down by local people.

6 ____ Fishbourne Palace was burnt down by local people.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd04b8f5-3cd3-5413-9068-0fe717e0ff64', 'dfdabed9-9c55-5b61-abab-80978c9d701a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6dc3e600-05ec-5a80-b89e-6a920b6ce681', 'dfdabed9-9c55-5b61-abab-80978c9d701a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a38cf9d-d9b7-57c8-b4b3-218da03c9d8a', 'dfdabed9-9c55-5b61-abab-80978c9d701a', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('818c637e-3294-5407-897c-aa14d4a69230', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Fishbourne Palace
Costruction
The first buildings on the site contained food for the
7
The palace building surrounded
8
In the 2
nd
and 3
rd
centuries colour was added to the
9
of the palace.
Discovery
The first part of the palace to the found was part of a
10
Possible inhabitants
Congidubnus -he is named in several writings
Sallustius Lucullu-he may have lived there until approximately
11
AD
Verica -a British king
Catuarus-his
12
was found there
Present Day
•
A
13
has
been built on the site to help protect it.

The first buildings on the site contained food for the 7 ____$md$, NULL, ARRAY['.*roman.*army.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('763dc397-b7dd-5827-9f65-2e6efce58f61', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Fishbourne Palace
Costruction
The first buildings on the site contained food for the
7
The palace building surrounded
8
In the 2
nd
and 3
rd
centuries colour was added to the
9
of the palace.
Discovery
The first part of the palace to the found was part of a
10
Possible inhabitants
Congidubnus -he is named in several writings
Sallustius Lucullu-he may have lived there until approximately
11
AD
Verica -a British king
Catuarus-his
12
was found there
Present Day
•
A
13
has
been built on the site to help protect it.

The palace building surrounded 8 ____$md$, NULL, ARRAY['.*gardens.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5ac04616-c557-5d09-9af3-8caa5ccee25f', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Fishbourne Palace
Costruction
The first buildings on the site contained food for the
7
The palace building surrounded
8
In the 2
nd
and 3
rd
centuries colour was added to the
9
of the palace.
Discovery
The first part of the palace to the found was part of a
10
Possible inhabitants
Congidubnus -he is named in several writings
Sallustius Lucullu-he may have lived there until approximately
11
AD
Verica -a British king
Catuarus-his
12
was found there
Present Day
•
A
13
has
been built on the site to help protect it.

centuries colour was added to the 9 ____ of the palace.$md$, NULL, ARRAY['.*floors.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f5295f5a-b85f-5a53-bd52-6b566f60df0f', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Fishbourne Palace
Costruction
The first buildings on the site contained food for the
7
The palace building surrounded
8
In the 2
nd
and 3
rd
centuries colour was added to the
9
of the palace.
Discovery
The first part of the palace to the found was part of a
10
Possible inhabitants
Congidubnus -he is named in several writings
Sallustius Lucullu-he may have lived there until approximately
11
AD
Verica -a British king
Catuarus-his
12
was found there
Present Day
•
A
13
has
been built on the site to help protect it.

The first part of the palace to the found was part of a 10 ____$md$, NULL, ARRAY['.*wall.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ac44b6e4-55f5-5fd7-aad5-712e099cca47', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Fishbourne Palace
Costruction
The first buildings on the site contained food for the
7
The palace building surrounded
8
In the 2
nd
and 3
rd
centuries colour was added to the
9
of the palace.
Discovery
The first part of the palace to the found was part of a
10
Possible inhabitants
Congidubnus -he is named in several writings
Sallustius Lucullu-he may have lived there until approximately
11
AD
Verica -a British king
Catuarus-his
12
was found there
Present Day
•
A
13
has
been built on the site to help protect it.

Sallustius Lucullu-he may have lived there until approximately 11 ____ AD$md$, NULL, ARRAY['.*93.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5f9e1515-fdd6-5598-8641-2b55aac095ff', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Fishbourne Palace
Costruction
The first buildings on the site contained food for the
7
The palace building surrounded
8
In the 2
nd
and 3
rd
centuries colour was added to the
9
of the palace.
Discovery
The first part of the palace to the found was part of a
10
Possible inhabitants
Congidubnus -he is named in several writings
Sallustius Lucullu-he may have lived there until approximately
11
AD
Verica -a British king
Catuarus-his
12
was found there
Present Day
•
A
13
has
been built on the site to help protect it.

Catuarus-his 12 ____ was found there$md$, NULL, ARRAY['.*gold.*ring.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ce704bef-8d02-5d66-85a8-6713a7f68cf8', '4abc0595-42b6-5c07-9503-6bc60e0f5de3', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Fishbourne Palace
Costruction
The first buildings on the site contained food for the
7
The palace building surrounded
8
In the 2
nd
and 3
rd
centuries colour was added to the
9
of the palace.
Discovery
The first part of the palace to the found was part of a
10
Possible inhabitants
Congidubnus -he is named in several writings
Sallustius Lucullu-he may have lived there until approximately
11
AD
Verica -a British king
Catuarus-his
12
was found there
Present Day
•
A
13
has
been built on the site to help protect it.

• A 13 ____ has been built on the site to help protect it.$md$, NULL, ARRAY['.*modern.*museum.*']);

COMMIT;
