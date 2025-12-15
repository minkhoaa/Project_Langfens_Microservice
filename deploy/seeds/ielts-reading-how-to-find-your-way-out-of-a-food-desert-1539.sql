BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-how-to-find-your-way-out-of-a-food-desert-1539'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-to-find-your-way-out-of-a-food-desert-1539';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-to-find-your-way-out-of-a-food-desert-1539';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-how-to-find-your-way-out-of-a-food-desert-1539';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('cd935f97-52fd-5e8b-b594-812717331ce7', 'ielts-reading-how-to-find-your-way-out-of-a-food-desert-1539', $t$How to find your way out of a food desert$t$, $md$## How to find your way out of a food desert

Nguồn:
- Test: https://mini-ielts.com/1539/reading/how-to-find-your-way-out-of-a-food-desert
- Solution: https://mini-ielts.com/1539/view-solution/reading/how-to-find-your-way-out-of-a-food-desert$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('43967008-4aed-5517-b1e2-abfcbf64a0cc', 'cd935f97-52fd-5e8b-b594-812717331ce7', 1, $t$Reading — How to find your way out of a food desert$t$, $md$Read the passage and answer questions **1–13**.

### Passage: How to find your way out of a food desert

Ordinary citizens have been using the internet to draw attention to the lack of healthy eating options in inner cities

Over the last few months, a survey has been carried out of over 200 greengrocers and convenience stores in Crown Heights, a neighborhood in Brooklyn, New York. As researchers from the Brooklyn Food Association enter the details, colorful dots appear on their online map, which display the specific location of each of the food stores in a handful of central Brooklyn neighborhoods. Clicking on a dot will show you the store's name and whether it carries fresh fruit and vegetables, wholegrain bread, low-fat dairy and other healthy options.

The researchers plan eventually to survey the entire borough of Brooklyn. ‘We want to get to a more specific and detailed description of what that looks like’, says Jeffrey Heehs, who leads the project. He hopes it will help residents find fresh food in urban areas where the stores sell mostly packaged snacks or fast food, areas otherwise known as food deserts. The aim of the project is also to assist government officials in assessing food availability, and in forming future policies about what kind of food should be sold and where.

In fact, the Brooklyn project represents the intersection of two growing trends: mapping fresh food markets in US cities, and private citizens creating online maps of local neighborhood features. According to Michael Goodchild, a geographer at the University of California at Santa Barbara, citizen map makers may make maps because there is no good government map, or to record problems such as burned-out traffic lights.

According to recent studies, people at higher risk of chronic disease and who receive minimal incomes for the work they do, frequently live in neighborhoods located in food deserts. But how did these food deserts arise? Linda Alwitt and Thomas Donley, marketing researchers at DePaul University in Chicago, found that supermarkets often can’t afford the amount of land required for their stores in cities. City planning researcher Cliff Guy and colleagues at the University of Leeds in the UK found in 2004 that smaller urban groceries tend to close due to competition from suburban supermarkets.

As fresh food stores leave a neighborhood, residents find it harder to eat well and stay healthy. Food deserts are linked with lower local health outcomes, and they may be a driving force in the health disparities between lower-income and affluent people in the US. Until recently, the issue attracted little national attention, and received no ongoing funding for research.

Now, more US cities are becoming aware of their food landscapes. Last year, the United States Department of Agriculture launched a map of where food stores are located in all the US counties. Mari Gallagher, who runs a private consulting firm, says her researchers have mapped food stores and related them to health statistics for the cities of Detroit, Chicago, Cincinnati and Washington, D.c. These maps help cities identify where food deserts are and, occasionally, have documented that people living in food deserts have higher rates of diet-related diseases.

The Brooklyn project differs in that it’s run by a local core of five volunteers who have worked on the project for the past year, rather than trained, academic researchers. To gather data, they simply go to individual stores with pre-printed surveys in hand, and once the storekeeper's permission has been obtained, check off boxes on their list against the products for sole in the store. Their approach to data collection and research has been made possible by technologies such as mapping software and GPS-related smart phones, Google Maps and OpenStreeMap, an open-source online map with a history of involvement in social issues. Like Brooklyn Food Association volunteers, many citizen online map makers use maps to bring local problems to official attention, Goodchild says. Heehs, the mapping project leader, says that after his group gathers more data, it will compare neighborhoods, come up with solutions to address local needs, and then present them to New York City officials. Their website hasn’t caught them much local or official attention yet, however. It was launched only recently, but its creators haven’t yet set up systems to see who’s looking at it.

Experts who visited the Brooklyn group’s site were optimistic but cautious. ‘This kind of detailed information could be very useful’ says Michele Ver Ploeg, an economist for the Department of Agriculture. To make the map more helpful to both residents and policy makers, she would like to see price data for healthy products, too. Karen Ansel, a registered dietician and a spokesperson for the American Dietetic Association, found the site confusing to navigate. ‘That said, with this information in place the group has the tools to build a more user-friendly site that could be ... very helpful to consumers’, she says. ‘The group also should ensure their map is available to those who don’t have internet access at home’, she adds. In fact, a significant proportion of Brooklyn residents don’t have internet access at home and 8 percent rely on dial-up service, instead of high-speed internet access, according to Gretchen Maneval, director of Brooklyn College’s Center for the study of Brooklyn. ‘It’s still very much a work in progress’, Heehs says of the online map. They’ll start advertising it online and by email to other community groups, such as urban food garden associations, next month. He also hopes warmer days in the spring will draw out fresh volunteers to spread awareness and to finish surveying, as they have about two-thirds of Brooklyn left to cover.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7d1eb8e6-faf5-59c4-93e2-69ea9de39344', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 1, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-6 on your answer sheet.
Data on food deserts and their effects on health
The Brooklyn Food Association
The online map provides users with a store’s name,
1
and details of its produce
One goal of the mapping project is to help develop new
2
on food.
Citizen maps are sometimes made when
3
maps are unsatisfactory.
Reasons
for the development
of
food deserts
New research suggests that people living in food deserts often have low
4
Some supermarkets are unable to buy enough
5
inside cities for their stores
Small grocery stores in cities often cannot cope with supermarket
6

The online map provides users with a store’s name, 1 ____ and details of its produce$md$, NULL, ARRAY['.*location.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('306fcd79-0989-58a9-abff-c852d6c83748', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 2, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-6 on your answer sheet.
Data on food deserts and their effects on health
The Brooklyn Food Association
The online map provides users with a store’s name,
1
and details of its produce
One goal of the mapping project is to help develop new
2
on food.
Citizen maps are sometimes made when
3
maps are unsatisfactory.
Reasons
for the development
of
food deserts
New research suggests that people living in food deserts often have low
4
Some supermarkets are unable to buy enough
5
inside cities for their stores
Small grocery stores in cities often cannot cope with supermarket
6

One goal of the mapping project is to help develop new 2 ____ on food.$md$, NULL, ARRAY['.*policies.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('212c09cf-778e-523f-a0cc-cb6bad436a8e', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 3, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-6 on your answer sheet.
Data on food deserts and their effects on health
The Brooklyn Food Association
The online map provides users with a store’s name,
1
and details of its produce
One goal of the mapping project is to help develop new
2
on food.
Citizen maps are sometimes made when
3
maps are unsatisfactory.
Reasons
for the development
of
food deserts
New research suggests that people living in food deserts often have low
4
Some supermarkets are unable to buy enough
5
inside cities for their stores
Small grocery stores in cities often cannot cope with supermarket
6

Citizen maps are sometimes made when 3 ____ maps are unsatisfactory.$md$, NULL, ARRAY['.*government.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fddf4e48-d333-5d8a-93d1-43cb5936c055', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 4, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-6 on your answer sheet.
Data on food deserts and their effects on health
The Brooklyn Food Association
The online map provides users with a store’s name,
1
and details of its produce
One goal of the mapping project is to help develop new
2
on food.
Citizen maps are sometimes made when
3
maps are unsatisfactory.
Reasons
for the development
of
food deserts
New research suggests that people living in food deserts often have low
4
Some supermarkets are unable to buy enough
5
inside cities for their stores
Small grocery stores in cities often cannot cope with supermarket
6

New research suggests that people living in food deserts often have low 4 ____$md$, NULL, ARRAY['.*incomes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('293becfb-6307-5a8b-a2fc-cf15fcc30662', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 5, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-6 on your answer sheet.
Data on food deserts and their effects on health
The Brooklyn Food Association
The online map provides users with a store’s name,
1
and details of its produce
One goal of the mapping project is to help develop new
2
on food.
Citizen maps are sometimes made when
3
maps are unsatisfactory.
Reasons
for the development
of
food deserts
New research suggests that people living in food deserts often have low
4
Some supermarkets are unable to buy enough
5
inside cities for their stores
Small grocery stores in cities often cannot cope with supermarket
6

Some supermarkets are unable to buy enough 5 ____ inside cities for their stores$md$, NULL, ARRAY['.*land.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('74e79a40-d32d-50a0-a0ef-01ab3aac9dd3', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-6 on your answer sheet.
Data on food deserts and their effects on health
The Brooklyn Food Association
The online map provides users with a store’s name,
1
and details of its produce
One goal of the mapping project is to help develop new
2
on food.
Citizen maps are sometimes made when
3
maps are unsatisfactory.
Reasons
for the development
of
food deserts
New research suggests that people living in food deserts often have low
4
Some supermarkets are unable to buy enough
5
inside cities for their stores
Small grocery stores in cities often cannot cope with supermarket
6

Small grocery stores in cities often cannot cope with supermarket 6 ____$md$, NULL, ARRAY['.*suburban.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('869ca047-ecd2-58f9-a8cc-b4a64b937c75', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Do the
following statements agree with the information given in Reading
Passage ?
In boxes
7-13 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
7
A group of professional researchers are in charge of the Brooklyn project.
8
The Brooklyn project team carries out their assessment of stores without the owner’s knowledge
9
The Brooklyn project has experienced technical difficulties setting up the website
10
The city government has taken a considerable interest in the Brooklyn project website
11
Michele Ver Ploeg believes the Brooklyn project website should contain additional information
12
The rate of internet use in Brooklyn is unlikely to increase in the near future
13
Jeffrey Heehs would like more people to assist with the Brooklyn project research

7 ____ A group of professional researchers are in charge of the Brooklyn project.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4630c25-5a89-5e98-a6c0-076c1413bd1b', '869ca047-ecd2-58f9-a8cc-b4a64b937c75', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6519adb-aecf-54cf-adbf-2b3782b522d4', '869ca047-ecd2-58f9-a8cc-b4a64b937c75', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db0473f0-8b94-52bf-84cd-cddb32cb54f4', '869ca047-ecd2-58f9-a8cc-b4a64b937c75', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9ed4d93a-4a48-5931-b5f8-174d34336754', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Do the
following statements agree with the information given in Reading
Passage ?
In boxes
7-13 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
7
A group of professional researchers are in charge of the Brooklyn project.
8
The Brooklyn project team carries out their assessment of stores without the owner’s knowledge
9
The Brooklyn project has experienced technical difficulties setting up the website
10
The city government has taken a considerable interest in the Brooklyn project website
11
Michele Ver Ploeg believes the Brooklyn project website should contain additional information
12
The rate of internet use in Brooklyn is unlikely to increase in the near future
13
Jeffrey Heehs would like more people to assist with the Brooklyn project research

8 ____ The Brooklyn project team carries out their assessment of stores without the owner’s knowledge$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb0a644e-7a02-5494-ac87-7ca585b58793', '9ed4d93a-4a48-5931-b5f8-174d34336754', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df83ce23-dae4-590b-857b-3bb5e1b10fbf', '9ed4d93a-4a48-5931-b5f8-174d34336754', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad85f540-5299-52d4-9f1d-ccc945909ebf', '9ed4d93a-4a48-5931-b5f8-174d34336754', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('be1d4641-fbe1-5ed3-b2b6-01392974667d', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Do the
following statements agree with the information given in Reading
Passage ?
In boxes
7-13 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
7
A group of professional researchers are in charge of the Brooklyn project.
8
The Brooklyn project team carries out their assessment of stores without the owner’s knowledge
9
The Brooklyn project has experienced technical difficulties setting up the website
10
The city government has taken a considerable interest in the Brooklyn project website
11
Michele Ver Ploeg believes the Brooklyn project website should contain additional information
12
The rate of internet use in Brooklyn is unlikely to increase in the near future
13
Jeffrey Heehs would like more people to assist with the Brooklyn project research

9 ____ The Brooklyn project has experienced technical difficulties setting up the website$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('784bc251-880d-5578-88d3-b7777ea6e185', 'be1d4641-fbe1-5ed3-b2b6-01392974667d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4b1c367-9835-5575-a909-3d88801990c2', 'be1d4641-fbe1-5ed3-b2b6-01392974667d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ac4f692-5d31-5c97-a669-b5b7e8ffe422', 'be1d4641-fbe1-5ed3-b2b6-01392974667d', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('168207be-5a55-5530-aeb1-c90b4147898c', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Do the
following statements agree with the information given in Reading
Passage ?
In boxes
7-13 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
7
A group of professional researchers are in charge of the Brooklyn project.
8
The Brooklyn project team carries out their assessment of stores without the owner’s knowledge
9
The Brooklyn project has experienced technical difficulties setting up the website
10
The city government has taken a considerable interest in the Brooklyn project website
11
Michele Ver Ploeg believes the Brooklyn project website should contain additional information
12
The rate of internet use in Brooklyn is unlikely to increase in the near future
13
Jeffrey Heehs would like more people to assist with the Brooklyn project research

10 ____ The city government has taken a considerable interest in the Brooklyn project website$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03cba237-c011-52a5-a0ab-f80301a2f1d5', '168207be-5a55-5530-aeb1-c90b4147898c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38bd5c61-2d1a-56e6-8793-412003d6b210', '168207be-5a55-5530-aeb1-c90b4147898c', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5d6a4ad-1102-571b-bd1f-9a3fd8d41d28', '168207be-5a55-5530-aeb1-c90b4147898c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dacd5ce9-9e8a-591e-a79c-b8e57392144c', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Do the
following statements agree with the information given in Reading
Passage ?
In boxes
7-13 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
7
A group of professional researchers are in charge of the Brooklyn project.
8
The Brooklyn project team carries out their assessment of stores without the owner’s knowledge
9
The Brooklyn project has experienced technical difficulties setting up the website
10
The city government has taken a considerable interest in the Brooklyn project website
11
Michele Ver Ploeg believes the Brooklyn project website should contain additional information
12
The rate of internet use in Brooklyn is unlikely to increase in the near future
13
Jeffrey Heehs would like more people to assist with the Brooklyn project research

11 ____ Michele Ver Ploeg believes the Brooklyn project website should contain additional information$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e13c1076-8111-54d3-b0e6-f1c309d7e88f', 'dacd5ce9-9e8a-591e-a79c-b8e57392144c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce55d563-c09b-5e17-8719-084d0c80623c', 'dacd5ce9-9e8a-591e-a79c-b8e57392144c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f274c96f-ee2c-5f40-b591-099c7e82bdbc', 'dacd5ce9-9e8a-591e-a79c-b8e57392144c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('057c3d5e-2b04-5471-adc5-6d0eccc02b57', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Do the
following statements agree with the information given in Reading
Passage ?
In boxes
7-13 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
7
A group of professional researchers are in charge of the Brooklyn project.
8
The Brooklyn project team carries out their assessment of stores without the owner’s knowledge
9
The Brooklyn project has experienced technical difficulties setting up the website
10
The city government has taken a considerable interest in the Brooklyn project website
11
Michele Ver Ploeg believes the Brooklyn project website should contain additional information
12
The rate of internet use in Brooklyn is unlikely to increase in the near future
13
Jeffrey Heehs would like more people to assist with the Brooklyn project research

12 ____ The rate of internet use in Brooklyn is unlikely to increase in the near future$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f187731-50cd-522a-9132-03922aded8bd', '057c3d5e-2b04-5471-adc5-6d0eccc02b57', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b73480b1-1dbe-5285-9c50-b5be0ab4c1dc', '057c3d5e-2b04-5471-adc5-6d0eccc02b57', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3bae95f-168d-5e59-bc3c-658ae82190a6', '057c3d5e-2b04-5471-adc5-6d0eccc02b57', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('340349f9-8828-541c-bde4-7c13081ecc2e', '43967008-4aed-5517-b1e2-abfcbf64a0cc', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Do the
following statements agree with the information given in Reading
Passage ?
In boxes
7-13 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
7
A group of professional researchers are in charge of the Brooklyn project.
8
The Brooklyn project team carries out their assessment of stores without the owner’s knowledge
9
The Brooklyn project has experienced technical difficulties setting up the website
10
The city government has taken a considerable interest in the Brooklyn project website
11
Michele Ver Ploeg believes the Brooklyn project website should contain additional information
12
The rate of internet use in Brooklyn is unlikely to increase in the near future
13
Jeffrey Heehs would like more people to assist with the Brooklyn project research

13 ____ Jeffrey Heehs would like more people to assist with the Brooklyn project research$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a28c3ff-1681-55e3-a504-e9d5e1f5b2ad', '340349f9-8828-541c-bde4-7c13081ecc2e', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d6a6b49-7ec0-51b9-9e38-83820df18ff6', '340349f9-8828-541c-bde4-7c13081ecc2e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bfec0ee-1bfe-5012-b7e8-b9a94bc82dda', '340349f9-8828-541c-bde4-7c13081ecc2e', 3, $md$NOT GIVEN$md$, false);

COMMIT;
