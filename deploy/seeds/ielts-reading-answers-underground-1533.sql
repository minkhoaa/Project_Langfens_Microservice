BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-answers-underground-1533'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-answers-underground-1533';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-answers-underground-1533';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-answers-underground-1533';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2a35e903-d0b7-56f6-af5d-f11178e64316', 'ielts-reading-answers-underground-1533', $t$Answers Underground$t$, $md$## Answers Underground

Nguồn:
- Test: https://mini-ielts.com/1533/reading/answers-underground
- Solution: https://mini-ielts.com/1533/view-solution/reading/answers-underground$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', '2a35e903-d0b7-56f6-af5d-f11178e64316', 1, $t$Reading — Answers Underground$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Answers Underground

Burying greenhouse gases to slow global warming$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ed0ea554-fa81-5236-a0e2-dbe7500b8894', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Look at the following issues (Questions 1-6) and the list of people and organisations below.
Match each issue with the correct person or organization,
A-F.
Write the correct letter,
A-F,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
The cost implications of fitting plants with the necessary equipment.
2
The effects of sequestration could have on sea creatures.
3
The reasons why products such as oil and gas continue to be popular energy sources.
4
The need for industrialised countries to give aid to less wealthy countries.
5
The significant increase in carbon dioxide concentrations in the air over the last 100 years.
6
The potential for sequestration to harm human life.
List of People and organisations
A
Scott Klara
B
Intergovernmental Panel on Climate Change
C
International Energy Agency
D
Klaus Lackner
E
David Hawkins
F
World Wide Fund for Nature Australia

1 ____ The cost implications of fitting plants with the necessary equipment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24341213-1209-5c3b-b46a-bc72dd3d6ddf', 'ed0ea554-fa81-5236-a0e2-dbe7500b8894', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26b3ba4d-ff48-58c5-bf78-e0a76fb35c66', 'ed0ea554-fa81-5236-a0e2-dbe7500b8894', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4582c106-ffcc-5882-8897-78dfdf8299ca', 'ed0ea554-fa81-5236-a0e2-dbe7500b8894', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1758dca2-a28c-5158-b937-66ca67d4466c', 'ed0ea554-fa81-5236-a0e2-dbe7500b8894', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32f16f7d-16d6-52cc-a372-3d4bc14f7c21', 'ed0ea554-fa81-5236-a0e2-dbe7500b8894', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ead80d3-ff4e-5d1b-94b1-7d81fdfc7a56', 'ed0ea554-fa81-5236-a0e2-dbe7500b8894', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3fe27bb9-2226-50a1-83dd-5c52e83fc16f', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Look at the following issues (Questions 1-6) and the list of people and organisations below.
Match each issue with the correct person or organization,
A-F.
Write the correct letter,
A-F,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
The cost implications of fitting plants with the necessary equipment.
2
The effects of sequestration could have on sea creatures.
3
The reasons why products such as oil and gas continue to be popular energy sources.
4
The need for industrialised countries to give aid to less wealthy countries.
5
The significant increase in carbon dioxide concentrations in the air over the last 100 years.
6
The potential for sequestration to harm human life.
List of People and organisations
A
Scott Klara
B
Intergovernmental Panel on Climate Change
C
International Energy Agency
D
Klaus Lackner
E
David Hawkins
F
World Wide Fund for Nature Australia

2 ____ The effects of sequestration could have on sea creatures.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d06df4b2-284e-5108-acd5-a062cb0d7a98', '3fe27bb9-2226-50a1-83dd-5c52e83fc16f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc736062-0c35-5236-90f4-c2f2488ae82f', '3fe27bb9-2226-50a1-83dd-5c52e83fc16f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4b3c23a-9aa4-5e1f-8069-daf304eea753', '3fe27bb9-2226-50a1-83dd-5c52e83fc16f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87546b19-f65f-522d-af34-da99c271febd', '3fe27bb9-2226-50a1-83dd-5c52e83fc16f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1203b3a7-90a7-5264-a4a0-6268b88ec25f', '3fe27bb9-2226-50a1-83dd-5c52e83fc16f', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('364ecf9c-54bb-557d-adfd-6ac1ea8f2845', '3fe27bb9-2226-50a1-83dd-5c52e83fc16f', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7a04507b-e071-543f-84a2-118973d61af5', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Look at the following issues (Questions 1-6) and the list of people and organisations below.
Match each issue with the correct person or organization,
A-F.
Write the correct letter,
A-F,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
The cost implications of fitting plants with the necessary equipment.
2
The effects of sequestration could have on sea creatures.
3
The reasons why products such as oil and gas continue to be popular energy sources.
4
The need for industrialised countries to give aid to less wealthy countries.
5
The significant increase in carbon dioxide concentrations in the air over the last 100 years.
6
The potential for sequestration to harm human life.
List of People and organisations
A
Scott Klara
B
Intergovernmental Panel on Climate Change
C
International Energy Agency
D
Klaus Lackner
E
David Hawkins
F
World Wide Fund for Nature Australia

3 ____ The reasons why products such as oil and gas continue to be popular energy sources.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1f6c53b-29c4-542c-8dc1-125394bcc490', '7a04507b-e071-543f-84a2-118973d61af5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69dd43d3-0d89-5e5b-a9ed-4401736f0a18', '7a04507b-e071-543f-84a2-118973d61af5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a8656eb-5767-5efc-bd2a-d06f87abcb55', '7a04507b-e071-543f-84a2-118973d61af5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79975ec6-fb54-55f8-9124-75043bac2e26', '7a04507b-e071-543f-84a2-118973d61af5', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8cefd076-269b-5696-89b3-479d49907132', '7a04507b-e071-543f-84a2-118973d61af5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('879b6edf-baaf-5445-ba47-a9f7b3218bb1', '7a04507b-e071-543f-84a2-118973d61af5', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('40754349-5853-57b2-92c1-750d336c2344', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Look at the following issues (Questions 1-6) and the list of people and organisations below.
Match each issue with the correct person or organization,
A-F.
Write the correct letter,
A-F,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
The cost implications of fitting plants with the necessary equipment.
2
The effects of sequestration could have on sea creatures.
3
The reasons why products such as oil and gas continue to be popular energy sources.
4
The need for industrialised countries to give aid to less wealthy countries.
5
The significant increase in carbon dioxide concentrations in the air over the last 100 years.
6
The potential for sequestration to harm human life.
List of People and organisations
A
Scott Klara
B
Intergovernmental Panel on Climate Change
C
International Energy Agency
D
Klaus Lackner
E
David Hawkins
F
World Wide Fund for Nature Australia

4 ____ The need for industrialised countries to give aid to less wealthy countries.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cab52b3-dc6f-5acd-ad39-187d0748b49f', '40754349-5853-57b2-92c1-750d336c2344', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f93bcd75-8baa-55cf-9152-38c95d0e29a6', '40754349-5853-57b2-92c1-750d336c2344', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc0f31dd-3396-590b-878c-f65d961e499d', '40754349-5853-57b2-92c1-750d336c2344', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6c85e01-5c67-5b92-ac9b-12fc12d216c1', '40754349-5853-57b2-92c1-750d336c2344', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa21e682-037f-536e-b1ec-ea965bd581fd', '40754349-5853-57b2-92c1-750d336c2344', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3430fb40-b4ff-5dbc-b816-acc77aec464e', '40754349-5853-57b2-92c1-750d336c2344', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('85e63af5-aedd-582e-b317-26f25ae5605b', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Look at the following issues (Questions 1-6) and the list of people and organisations below.
Match each issue with the correct person or organization,
A-F.
Write the correct letter,
A-F,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
The cost implications of fitting plants with the necessary equipment.
2
The effects of sequestration could have on sea creatures.
3
The reasons why products such as oil and gas continue to be popular energy sources.
4
The need for industrialised countries to give aid to less wealthy countries.
5
The significant increase in carbon dioxide concentrations in the air over the last 100 years.
6
The potential for sequestration to harm human life.
List of People and organisations
A
Scott Klara
B
Intergovernmental Panel on Climate Change
C
International Energy Agency
D
Klaus Lackner
E
David Hawkins
F
World Wide Fund for Nature Australia

5 ____ The significant increase in carbon dioxide concentrations in the air over the last 100 years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a7d5400-7c57-5966-9add-8533f92f4ac4', '85e63af5-aedd-582e-b317-26f25ae5605b', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf88e054-d554-5c4b-ae6c-7c85c44b5683', '85e63af5-aedd-582e-b317-26f25ae5605b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d79ad538-b7ce-5da0-98a9-174efd1ef820', '85e63af5-aedd-582e-b317-26f25ae5605b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ddcec3f-c755-5326-8c27-d5e5624ed79c', '85e63af5-aedd-582e-b317-26f25ae5605b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43c7a12b-de4d-5ca5-9acc-dcc463e322e7', '85e63af5-aedd-582e-b317-26f25ae5605b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('630fa331-ac2c-5755-9195-d994cb94932f', '85e63af5-aedd-582e-b317-26f25ae5605b', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d6acb407-595c-5af1-9755-36968880ff95', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Look at the following issues (Questions 1-6) and the list of people and organisations below.
Match each issue with the correct person or organization,
A-F.
Write the correct letter,
A-F,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
The cost implications of fitting plants with the necessary equipment.
2
The effects of sequestration could have on sea creatures.
3
The reasons why products such as oil and gas continue to be popular energy sources.
4
The need for industrialised countries to give aid to less wealthy countries.
5
The significant increase in carbon dioxide concentrations in the air over the last 100 years.
6
The potential for sequestration to harm human life.
List of People and organisations
A
Scott Klara
B
Intergovernmental Panel on Climate Change
C
International Energy Agency
D
Klaus Lackner
E
David Hawkins
F
World Wide Fund for Nature Australia

6 ____ The potential for sequestration to harm human life.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16b743c9-3f9d-5ada-b145-826953833504', 'd6acb407-595c-5af1-9755-36968880ff95', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9ed7076-b4e7-5870-a0c7-29923ba5b62b', 'd6acb407-595c-5af1-9755-36968880ff95', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66094291-19cb-599e-89da-9b6fadee8258', 'd6acb407-595c-5af1-9755-36968880ff95', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebf59aa1-6364-5562-8c31-41ca09d8d380', 'd6acb407-595c-5af1-9755-36968880ff95', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d9039db-c056-5492-acce-e3c9a0b7814f', 'd6acb407-595c-5af1-9755-36968880ff95', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f19f371-14bb-59c1-a994-08f93ccda86a', 'd6acb407-595c-5af1-9755-36968880ff95', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('81159408-e6ba-5f61-964f-4a09554020cd', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 7- 9
Questions 7- 9
Reading Passage has ten paragraphs, A-J.
Which paragraph contains the following information?
Write the correct letter, A-J, in boxes 7-9 on your answer sheet.
7
Examples of sequestration already in use in several parts of the world
8
An example of putting carbon dioxide emissions to use in the food and beverage industry
9
Current examples of the environmental harm attributed to carbon dioxide in the air

7 ____ Examples of sequestration already in use in several parts of the world$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('454ece2a-1131-54f3-a0ff-072eb215f23a', '81159408-e6ba-5f61-964f-4a09554020cd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('578cc693-acf7-5a44-b277-c0225acf6604', '81159408-e6ba-5f61-964f-4a09554020cd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbd1a55d-3d8b-5fea-a597-73d9dbc55f2f', '81159408-e6ba-5f61-964f-4a09554020cd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a50c117-f6db-59ac-ad6d-e2654724f705', '81159408-e6ba-5f61-964f-4a09554020cd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('362da8cd-d332-5623-9705-4e631a4110b3', '81159408-e6ba-5f61-964f-4a09554020cd', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0195148-40a3-5296-8d02-4e4de8b193a0', '81159408-e6ba-5f61-964f-4a09554020cd', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b34c0cf1-284a-5fec-b4b2-3cdd33e539cb', '81159408-e6ba-5f61-964f-4a09554020cd', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d1ecc23-bb2f-5755-89d4-b936341c036e', '81159408-e6ba-5f61-964f-4a09554020cd', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1db4efa-b23d-58b6-898d-cec06556c68c', '81159408-e6ba-5f61-964f-4a09554020cd', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a46baeec-6428-5fce-b900-b74cd533d1ad', '81159408-e6ba-5f61-964f-4a09554020cd', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c39fa900-5625-515e-93c8-493862a1a7ca', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 7- 9
Questions 7- 9
Reading Passage has ten paragraphs, A-J.
Which paragraph contains the following information?
Write the correct letter, A-J, in boxes 7-9 on your answer sheet.
7
Examples of sequestration already in use in several parts of the world
8
An example of putting carbon dioxide emissions to use in the food and beverage industry
9
Current examples of the environmental harm attributed to carbon dioxide in the air

8 ____ An example of putting carbon dioxide emissions to use in the food and beverage industry$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72b1e66a-986d-58da-869c-71c0340469c0', 'c39fa900-5625-515e-93c8-493862a1a7ca', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86047b25-507b-5907-a36b-964fedb13bf7', 'c39fa900-5625-515e-93c8-493862a1a7ca', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc5c9191-7464-5080-89e3-dc797fbfe19b', 'c39fa900-5625-515e-93c8-493862a1a7ca', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f9f5d04-2ee7-5f0b-a7d4-098d5eccc495', 'c39fa900-5625-515e-93c8-493862a1a7ca', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3301d317-3ca9-559e-9060-259eeecf1422', 'c39fa900-5625-515e-93c8-493862a1a7ca', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3a08e5a-4182-58b2-bb6f-0603565c35a4', 'c39fa900-5625-515e-93c8-493862a1a7ca', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f027a7bf-23ad-511c-be6e-c364083dd0e6', 'c39fa900-5625-515e-93c8-493862a1a7ca', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30fb7671-6f2e-5d87-bb06-da58274a8bbf', 'c39fa900-5625-515e-93c8-493862a1a7ca', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d7874ba-a125-5e5c-bd13-58d307710fab', 'c39fa900-5625-515e-93c8-493862a1a7ca', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d20d1135-997f-507b-967a-bc46b1c40703', 'c39fa900-5625-515e-93c8-493862a1a7ca', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('39ef1ead-b631-5f50-9492-da3cf281e6a3', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 7- 9
Questions 7- 9
Reading Passage has ten paragraphs, A-J.
Which paragraph contains the following information?
Write the correct letter, A-J, in boxes 7-9 on your answer sheet.
7
Examples of sequestration already in use in several parts of the world
8
An example of putting carbon dioxide emissions to use in the food and beverage industry
9
Current examples of the environmental harm attributed to carbon dioxide in the air

9 ____ Current examples of the environmental harm attributed to carbon dioxide in the air$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0aaf7866-afe9-5f12-a77a-667f3e545f64', '39ef1ead-b631-5f50-9492-da3cf281e6a3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0701dc65-ff43-5377-b620-b58e747cbba6', '39ef1ead-b631-5f50-9492-da3cf281e6a3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f4ac7a3-1339-5a2c-a99c-ec191bc1baaf', '39ef1ead-b631-5f50-9492-da3cf281e6a3', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0952434-eaf3-50f3-b7bf-732b0d91cf0f', '39ef1ead-b631-5f50-9492-da3cf281e6a3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e01dc6ea-cad7-5cad-bbbe-99a1e6dbf9f2', '39ef1ead-b631-5f50-9492-da3cf281e6a3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f3e4b75-f9d7-575c-a59d-4ac145da9e66', '39ef1ead-b631-5f50-9492-da3cf281e6a3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb78bfa0-4386-50b1-b5dd-8eca7cb0b66d', '39ef1ead-b631-5f50-9492-da3cf281e6a3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7565eb9c-fe6d-512b-bb92-48daa22c4917', '39ef1ead-b631-5f50-9492-da3cf281e6a3', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e348bab6-2c0c-5d3e-9e2b-c9bfdb18d77e', '39ef1ead-b631-5f50-9492-da3cf281e6a3', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df80e60d-e371-516c-af68-dcf3da854903', '39ef1ead-b631-5f50-9492-da3cf281e6a3', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fe84bada-7ce4-569f-8149-332e4ce81c4b', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes 10-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Both developing and developed nations have decided to investigate carbon dioxide sequestration.
11
A growing
economy will use more power.
12
Capturing
carbon dioxide has become financially attractive.
13
More
forests need to be planted to improve the atmosphere.

10 ____ Both developing and developed nations have decided to investigate carbon dioxide sequestration.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3605b130-4799-54ee-a8d5-a4a029b18eac', 'fe84bada-7ce4-569f-8149-332e4ce81c4b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e40fe8f3-ba09-5ef3-8cfd-61cd830aaffb', 'fe84bada-7ce4-569f-8149-332e4ce81c4b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('caa03853-a2f7-5ed7-be96-565639c24062', 'fe84bada-7ce4-569f-8149-332e4ce81c4b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3e1f8e04-f0ee-5d89-a3e2-00eac5e12001', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes 10-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Both developing and developed nations have decided to investigate carbon dioxide sequestration.
11
A growing
economy will use more power.
12
Capturing
carbon dioxide has become financially attractive.
13
More
forests need to be planted to improve the atmosphere.

11 ____ A growing economy will use more power.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7faf34b-45b1-50eb-96d3-662990b167d1', '3e1f8e04-f0ee-5d89-a3e2-00eac5e12001', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b4d5d6f-7f76-5cf7-8870-ba70930a615a', '3e1f8e04-f0ee-5d89-a3e2-00eac5e12001', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fcdde64-4ffc-5faa-a7c3-097464bb2c99', '3e1f8e04-f0ee-5d89-a3e2-00eac5e12001', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('acba553f-56f1-5a12-9824-e060baf91e10', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes 10-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Both developing and developed nations have decided to investigate carbon dioxide sequestration.
11
A growing
economy will use more power.
12
Capturing
carbon dioxide has become financially attractive.
13
More
forests need to be planted to improve the atmosphere.

12 ____ Capturing carbon dioxide has become financially attractive.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85ea29d0-f602-5bcc-86e8-262e9f280101', 'acba553f-56f1-5a12-9824-e060baf91e10', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f0b3814-0f86-5fc0-9296-6635b1446841', 'acba553f-56f1-5a12-9824-e060baf91e10', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b2fb010-3b8c-57da-a5d6-aa4550ad0e22', 'acba553f-56f1-5a12-9824-e060baf91e10', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('102ad6c3-509f-5159-b9f4-b83da1f2a066', 'e8a7c5f0-63c7-541a-9e65-9b56e8e4ff80', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes 10-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
Both developing and developed nations have decided to investigate carbon dioxide sequestration.
11
A growing
economy will use more power.
12
Capturing
carbon dioxide has become financially attractive.
13
More
forests need to be planted to improve the atmosphere.

13 ____ More forests need to be planted to improve the atmosphere.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30de470b-c624-534a-a838-17e3e618799e', '102ad6c3-509f-5159-b9f4-b83da1f2a066', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c7e8013-d609-5d7b-8824-488c2403e1d9', '102ad6c3-509f-5159-b9f4-b83da1f2a066', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9244083-e2d1-5bc7-bdbc-ce4f31176b40', '102ad6c3-509f-5159-b9f4-b83da1f2a066', 3, $md$NOT GIVEN$md$, true);

COMMIT;
