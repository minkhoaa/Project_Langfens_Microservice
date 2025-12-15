BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-pollution-in-the-bay-1381'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-pollution-in-the-bay-1381';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-pollution-in-the-bay-1381';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-pollution-in-the-bay-1381';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c8b80e0a-462d-57da-a412-24097d11b1b2', 'ielts-reading-pollution-in-the-bay-1381', $t$Pollution! In the Bay$t$, $md$## Pollution! In the Bay

Nguồn:
- Test: https://mini-ielts.com/1381/reading/pollution-in-the-bay
- Solution: https://mini-ielts.com/1381/view-solution/reading/pollution-in-the-bay$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('27a13050-ebbb-5060-ac54-945e1bc6694c', 'c8b80e0a-462d-57da-a412-24097d11b1b2', 1, $t$Reading — Pollution! In the Bay$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Pollution! In the Bay

A

Pouring water into the sea sounds harmless enough. But in Florida Bay, a large and shallow section of the Gulf of Mexico that lies between the southern end of the Everglades and the Florida Keys, it is proving highly controversial. That is because researchers are divided over whether it will help or hinder the plants and animals that live in the bay.

B

What is at risk is the future of the bay’s extensive beds of seagrasses. These grow on the bay’s muddy floor and act as nurseries for the larvae of shrimps, lobsters and fish – many of the important sport and commercial-fishing species. Also in danger is an impressive range of coral reefs that run the length of the Florida Keys and form the third-largest barrier reef in the world. Since the 1980s, coral cover has dropped by 40%, and a third of the coral species have gone. This has had a damaging effect on the animals that depend on the reef, such as crabs, turtles and nearly 600 species of fish.

C

What is causing such ecological change is a matter of much debate. And the answer is of no small consequence. This is because the American government is planning to devote $8 billion over the next 30 years to revitalise the Everglades. Seasonal freshwater flows into the Everglades are to be restored in order to improve the region’s health. But they will then run off into the bay.

D

Joseph Zieman, a marine ecologist at the University of Virginia, thinks this is a good idea. He believes that a lack of fresh water in the bay is its main problem. The blame, he says, lies with a century of drainage in the Everglades aimed at turning the marshes into farmland and areas for development. This has caused the flow of fresh water into Florida Bay to dwindle, making the water in the bay, overall, more saline. This, he argues, kills the seagrasses, and as these rots, nutrients are released that feed the microscopic plants and animals that live in the water. This, he says, is why the bay’s once crystal-clear waters often resemble pea soup. And in a vicious circle, these turbid blooms block out sunlight, causing more seagrasses to die and yet more turbidity.

E

Brian Lapointe, a marine scientist at the Harbour Branch Oceanographic Institution at Fort Pierce in Florida, disagrees. He thinks seagrasses can tolerate much higher levels of salinity than the bay actually displays. Furthermore, he notes that when freshwater flows through the Everglades were increased experimentally in the 1990s, it led to massive plankton blooms. Freshwater running off from well-fertilised farmlands, he says, caused a fivefold rise in nitrogen levels in the bay. This was like pouring fuel on a fire. The result was mass mortality of seagrasses because of increased turbidity from the plankton. Dr Lapointe adds that, because corals thrive only in waters where nutrient levels are low, restoring freshwater rich in nitrogen will do more damage to the reef.

F

It is a plausible theory. The water flowing off crops that are grown on the750,000 acres of heavily fertilised farmland on the northern edge of the Everglades is rich in nitrogen, half of which ends up in the bay. But Bill Kruczynski, of America’s Environmental Protection Agency, is convinced that nitrogen from farmlands is not the chief problem. Some coral reefs well away from any nitrogen pollution are dying and, curiously, a few are thriving. Dr Kruczynski thinks that increased nutrients arriving from local sewage discharges from the thousands of cesspits along the Florida Keys are part of the problem.

G

Such claims and counterclaims make the impact of the restoration plan difficult to predict. If increased salinity is the main problem, the bay’s ecology will benefit from the Everglades restoration project. If, however, nitrogen is the problem, increasing the flow of freshwater could mate matters much worse.

H

If this second hypothesis proves correct, the cure is to remove nitrogen from farmland or sewage discharges, or perhaps both. Neither will be easy. Man-made wetlands, at present, being built to reduce phosphate runoff into the bay—also from fertilisers—would need an algal culture (a sort of contained algal bloom) added to them to deal with discharges from farmlands. That would be costly. So too would be the replacement of cesspits with proper sewerage—one estimate puts the cost at $650m. Either way, it is clear that when, on December 1st, 3,000 square miles of sea around the reef are designated as a “protective zone” by the deputy secretary of commerce, Sam Bodman, this will do nothing to protect the reef from pollution.

I

Some argue, though, that there is a more fundamental flaw in the plans for the bay: the very idea of returning it to a Utopian ideal before man wrought his damage. Nobody knows what Florida Bay was like before the 1950s when engineers cut the largest canals in the Everglades and took most of the water away. Dr Kruczynski suspects it was more like an estuary. The bay that many people wish to re-create could have been nothing more than a changing phase in the bay’s history.

J

These arguments do not merely threaten to create ecological problems but economic ones as well. The economy of the Florida Keys depends on tourism—the local tourist industry has an annual turnover of $2.5 billion. People come for fishing-boat trips, for manatee watching, or for scuba diving and snorkeling to view the exotically coloured corals. If the plan to restore the Everglades makes problems in the bay and the reef worse, it could prove a very expensive mistake.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4812189e-3617-55d5-89d1-750c4e589d31', '27a13050-ebbb-5060-ac54-945e1bc6694c', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
The reading Passage has seven paragraphs
A-J
.
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-4
on your answer sheet.
1
See grass turned to be more resistant to the saline water level in the Bay.
2
Significance of finding a specific reason in controversy
3
Expensive proposals raised to solve the nitrogen dilemma
4
A statistic of ecological changes in both the coral area and species

1 ____ See grass turned to be more resistant to the saline water level in the Bay.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('870bc5c5-76ec-52ea-a8c7-d4c49918015b', '4812189e-3617-55d5-89d1-750c4e589d31', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49ff1ab2-abab-5276-bbd2-e33c2338ee77', '4812189e-3617-55d5-89d1-750c4e589d31', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('221ab5c1-f956-536b-8720-35ccb325032d', '4812189e-3617-55d5-89d1-750c4e589d31', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('242c6c1f-4ce6-5f00-bad7-1a09ccb029ba', '4812189e-3617-55d5-89d1-750c4e589d31', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b15b4416-b79c-5953-8375-1d58bf461ea9', '4812189e-3617-55d5-89d1-750c4e589d31', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3876159-52cb-5ae4-ae5e-04274f5639ce', '4812189e-3617-55d5-89d1-750c4e589d31', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca52dc18-7ed4-52c9-97ca-8b0fa0a62438', '4812189e-3617-55d5-89d1-750c4e589d31', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c552d2a1-caae-5f54-a31e-ba60aff02357', '4812189e-3617-55d5-89d1-750c4e589d31', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('379050cc-3d95-5f4d-aeef-22dcfc9c61f3', '4812189e-3617-55d5-89d1-750c4e589d31', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8289992-06f4-5b6b-a9ae-45513c151f04', '4812189e-3617-55d5-89d1-750c4e589d31', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2d264ae0-2bf5-5c26-8274-cec19dfb3984', '27a13050-ebbb-5060-ac54-945e1bc6694c', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
The reading Passage has seven paragraphs
A-J
.
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-4
on your answer sheet.
1
See grass turned to be more resistant to the saline water level in the Bay.
2
Significance of finding a specific reason in controversy
3
Expensive proposals raised to solve the nitrogen dilemma
4
A statistic of ecological changes in both the coral area and species

2 ____ Significance of finding a specific reason in controversy$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('398bd46d-a5ad-5d4c-a494-8620ae93b5ec', '2d264ae0-2bf5-5c26-8274-cec19dfb3984', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79f44e28-b7e2-531e-a234-325ebdf19820', '2d264ae0-2bf5-5c26-8274-cec19dfb3984', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('156e2ea0-a252-5ea3-bab8-cf38db91a674', '2d264ae0-2bf5-5c26-8274-cec19dfb3984', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0c73999-b0b4-5f3c-a0f4-bae6048e3f1e', '2d264ae0-2bf5-5c26-8274-cec19dfb3984', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60f6f6d9-b8e7-524f-b75f-0a37609107b8', '2d264ae0-2bf5-5c26-8274-cec19dfb3984', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf04a537-6d01-53b8-ac8c-914f0184a99c', '2d264ae0-2bf5-5c26-8274-cec19dfb3984', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('506ebf24-85d9-5fee-9204-a75285306570', '2d264ae0-2bf5-5c26-8274-cec19dfb3984', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0541d0a2-53b4-5b9f-b741-9b6d3f626529', '2d264ae0-2bf5-5c26-8274-cec19dfb3984', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4410bab8-74cf-51a5-b47c-dbcf3365345c', '2d264ae0-2bf5-5c26-8274-cec19dfb3984', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54631fb9-587c-52bb-a3e4-43b18f93dc8d', '2d264ae0-2bf5-5c26-8274-cec19dfb3984', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f476be23-85b3-55db-a8c2-baa66b669ef1', '27a13050-ebbb-5060-ac54-945e1bc6694c', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
The reading Passage has seven paragraphs
A-J
.
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-4
on your answer sheet.
1
See grass turned to be more resistant to the saline water level in the Bay.
2
Significance of finding a specific reason in controversy
3
Expensive proposals raised to solve the nitrogen dilemma
4
A statistic of ecological changes in both the coral area and species

3 ____ Expensive proposals raised to solve the nitrogen dilemma$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e6fa0f3-7040-54e5-bbdb-88c3569197e1', 'f476be23-85b3-55db-a8c2-baa66b669ef1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3f72f29-8453-5f12-b4f4-570dd26df8b1', 'f476be23-85b3-55db-a8c2-baa66b669ef1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbf241f9-ae79-5a47-8a1d-925609bc4b16', 'f476be23-85b3-55db-a8c2-baa66b669ef1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48f6195e-0dd7-5804-9050-544907e8818c', 'f476be23-85b3-55db-a8c2-baa66b669ef1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb1008eb-8cdb-59c6-9d28-e19d168753f1', 'f476be23-85b3-55db-a8c2-baa66b669ef1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18b2799a-00e7-595a-a0ea-1c95bcc70723', 'f476be23-85b3-55db-a8c2-baa66b669ef1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7937642e-2dbb-59a4-8b96-3a0e072e2352', 'f476be23-85b3-55db-a8c2-baa66b669ef1', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c4252da-f671-59ff-8539-f44ed77f2cfd', 'f476be23-85b3-55db-a8c2-baa66b669ef1', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ed694a3-d14c-5fd8-891b-d6747c922f73', 'f476be23-85b3-55db-a8c2-baa66b669ef1', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ccd3cc2-e577-577b-bc89-fc03448735a4', 'f476be23-85b3-55db-a8c2-baa66b669ef1', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('941cd524-d490-5cca-b695-0faaebaac6d5', '27a13050-ebbb-5060-ac54-945e1bc6694c', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
The reading Passage has seven paragraphs
A-J
.
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-4
on your answer sheet.
1
See grass turned to be more resistant to the saline water level in the Bay.
2
Significance of finding a specific reason in controversy
3
Expensive proposals raised to solve the nitrogen dilemma
4
A statistic of ecological changes in both the coral area and species

4 ____ A statistic of ecological changes in both the coral area and species$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1aafdf0-91a9-5d3d-bd2a-248f84b92739', '941cd524-d490-5cca-b695-0faaebaac6d5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9923bc6-9af6-5ad8-80ef-42d91e462eb4', '941cd524-d490-5cca-b695-0faaebaac6d5', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88f43f7d-d299-51a9-af98-04544af95409', '941cd524-d490-5cca-b695-0faaebaac6d5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66ee1b32-213e-5343-98b6-b897b379aa06', '941cd524-d490-5cca-b695-0faaebaac6d5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c2edcd3-2ca2-5f8d-85b1-f4accd141dd9', '941cd524-d490-5cca-b695-0faaebaac6d5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('436fe81d-42d4-5045-824f-18e9697a5d74', '941cd524-d490-5cca-b695-0faaebaac6d5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35589f7f-fe26-5b81-9245-4a0bba181bdd', '941cd524-d490-5cca-b695-0faaebaac6d5', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba263f54-ffd2-59c6-b6d7-73f1cd76879c', '941cd524-d490-5cca-b695-0faaebaac6d5', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc62c94c-0eef-5609-8bea-a172c06d1b0f', '941cd524-d490-5cca-b695-0faaebaac6d5', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b2fdfd8-672b-590d-88a0-1155acb63e4b', '941cd524-d490-5cca-b695-0faaebaac6d5', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('96831a2e-cf0c-536e-9c4a-a93e854ff6b5', '27a13050-ebbb-5060-ac54-945e1bc6694c', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
5-8
on your answer sheet.
A
Bill Kruczynski
B
Brian Lapointe
C
Joseph Zieman
5
Drainage system in everglades actually results in high salty water in the bay.
6
Restoring water high in nitrogen level will make more ecological side effect
7
High nitrogen levels may be caused by the nearby farmland.
8
Released sewage rather than nutrients from agricultural area increase the level of Nitrogen.

5 ____ Drainage system in everglades actually results in high salty water in the bay.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58402eb7-2685-5c54-9522-68d72b4ccfeb', '96831a2e-cf0c-536e-9c4a-a93e854ff6b5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fbd3133-9d91-5aa4-a4e2-b5e6f0715d8e', '96831a2e-cf0c-536e-9c4a-a93e854ff6b5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10f1ac57-b675-5522-beb1-d4dc7ad6e86d', '96831a2e-cf0c-536e-9c4a-a93e854ff6b5', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b328691b-cae7-5790-ae13-1e7f4de4b9a7', '27a13050-ebbb-5060-ac54-945e1bc6694c', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
5-8
on your answer sheet.
A
Bill Kruczynski
B
Brian Lapointe
C
Joseph Zieman
5
Drainage system in everglades actually results in high salty water in the bay.
6
Restoring water high in nitrogen level will make more ecological side effect
7
High nitrogen levels may be caused by the nearby farmland.
8
Released sewage rather than nutrients from agricultural area increase the level of Nitrogen.

6 ____ Restoring water high in nitrogen level will make more ecological side effect$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b86bd57a-af23-573a-89b1-35e3fac9cc1c', 'b328691b-cae7-5790-ae13-1e7f4de4b9a7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d116274-02e9-507f-82a4-f2528c239dee', 'b328691b-cae7-5790-ae13-1e7f4de4b9a7', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b927538a-0a4b-5f9e-864d-21adc4716223', 'b328691b-cae7-5790-ae13-1e7f4de4b9a7', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('94c62672-5a12-5e27-9aa9-3415c10e3149', '27a13050-ebbb-5060-ac54-945e1bc6694c', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
5-8
on your answer sheet.
A
Bill Kruczynski
B
Brian Lapointe
C
Joseph Zieman
5
Drainage system in everglades actually results in high salty water in the bay.
6
Restoring water high in nitrogen level will make more ecological side effect
7
High nitrogen levels may be caused by the nearby farmland.
8
Released sewage rather than nutrients from agricultural area increase the level of Nitrogen.

7 ____ High nitrogen levels may be caused by the nearby farmland.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30aca3c0-4568-591d-a00d-4e66a83be006', '94c62672-5a12-5e27-9aa9-3415c10e3149', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05726778-3c69-5aef-82df-358a9ba9769d', '94c62672-5a12-5e27-9aa9-3415c10e3149', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bfb0fbe-8bda-5b6f-9000-2c6c172220ab', '94c62672-5a12-5e27-9aa9-3415c10e3149', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('db421843-5493-5df8-aaa0-8a10030b2504', '27a13050-ebbb-5060-ac54-945e1bc6694c', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
5-8
on your answer sheet.
A
Bill Kruczynski
B
Brian Lapointe
C
Joseph Zieman
5
Drainage system in everglades actually results in high salty water in the bay.
6
Restoring water high in nitrogen level will make more ecological side effect
7
High nitrogen levels may be caused by the nearby farmland.
8
Released sewage rather than nutrients from agricultural area increase the level of Nitrogen.

8 ____ Released sewage rather than nutrients from agricultural area increase the level of Nitrogen.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bc1e7f3-16e4-52f8-a163-5fbf44760671', 'db421843-5493-5df8-aaa0-8a10030b2504', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e4f45c9-5173-5a33-af97-b01f8591bdd7', 'db421843-5493-5df8-aaa0-8a10030b2504', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2483f15e-2044-54f3-be7c-b96cf0a74037', 'db421843-5493-5df8-aaa0-8a10030b2504', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('332313d5-2b63-5609-9940-01a589a6a26a', '27a13050-ebbb-5060-ac54-945e1bc6694c', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage 2
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
Everyone agrees with “pouring water into the sea is harmless enough” even in the Florida Bay area.
10
Nitrogen was poured in from different types of crops as water flows through.
11
Everglade restoration project can be effective regardless of the cause of the pollution.
12
Human has changed Florida Bay where old image before 1950s is unrecalled.
13
Tourism contributes fundamentally to the Florida Bay area.

9 ____ Everyone agrees with “pouring water into the sea is harmless enough” even in the Florida Bay area.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae79e189-e290-5908-9eee-564d7fb72700', '332313d5-2b63-5609-9940-01a589a6a26a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79692fd6-977e-5590-8921-d0ae7e8bfd8d', '332313d5-2b63-5609-9940-01a589a6a26a', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb2ce6a5-1cac-5676-bc8b-f3514996417f', '332313d5-2b63-5609-9940-01a589a6a26a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7d739ace-519b-58a3-8e4a-24c0545f52ff', '27a13050-ebbb-5060-ac54-945e1bc6694c', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage 2
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
Everyone agrees with “pouring water into the sea is harmless enough” even in the Florida Bay area.
10
Nitrogen was poured in from different types of crops as water flows through.
11
Everglade restoration project can be effective regardless of the cause of the pollution.
12
Human has changed Florida Bay where old image before 1950s is unrecalled.
13
Tourism contributes fundamentally to the Florida Bay area.

10 ____ Nitrogen was poured in from different types of crops as water flows through.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4be42a2e-35db-56f3-9f3e-19c0497a6201', '7d739ace-519b-58a3-8e4a-24c0545f52ff', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59dfa3ef-3c0c-5e19-83af-f5e079ac1005', '7d739ace-519b-58a3-8e4a-24c0545f52ff', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cf3db63-4ef2-52ba-8195-d1bc2df23e07', '7d739ace-519b-58a3-8e4a-24c0545f52ff', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f5517128-8892-536f-badb-e7a46312d8bb', '27a13050-ebbb-5060-ac54-945e1bc6694c', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage 2
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
Everyone agrees with “pouring water into the sea is harmless enough” even in the Florida Bay area.
10
Nitrogen was poured in from different types of crops as water flows through.
11
Everglade restoration project can be effective regardless of the cause of the pollution.
12
Human has changed Florida Bay where old image before 1950s is unrecalled.
13
Tourism contributes fundamentally to the Florida Bay area.

11 ____ Everglade restoration project can be effective regardless of the cause of the pollution.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb511b43-710e-514a-a0de-7f648c4756ee', 'f5517128-8892-536f-badb-e7a46312d8bb', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('046a499d-1596-53c0-b800-343f599280af', 'f5517128-8892-536f-badb-e7a46312d8bb', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('002f93b3-69e9-5147-8e13-07b66cf8ebff', 'f5517128-8892-536f-badb-e7a46312d8bb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cdbceb97-a659-5a02-83c1-ce23095a8556', '27a13050-ebbb-5060-ac54-945e1bc6694c', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage 2
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
Everyone agrees with “pouring water into the sea is harmless enough” even in the Florida Bay area.
10
Nitrogen was poured in from different types of crops as water flows through.
11
Everglade restoration project can be effective regardless of the cause of the pollution.
12
Human has changed Florida Bay where old image before 1950s is unrecalled.
13
Tourism contributes fundamentally to the Florida Bay area.

12 ____ Human has changed Florida Bay where old image before 1950s is unrecalled.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e463cf3-c63f-55b6-abd2-b15059387a52', 'cdbceb97-a659-5a02-83c1-ce23095a8556', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('396e0a8d-055e-51aa-a4c1-fd9bf2619cf9', 'cdbceb97-a659-5a02-83c1-ce23095a8556', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14ea55ee-d14c-575c-807c-165272494536', 'cdbceb97-a659-5a02-83c1-ce23095a8556', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1cf6839c-e80e-522a-9a9d-771cbcedf0c1', '27a13050-ebbb-5060-ac54-945e1bc6694c', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage 2
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
Everyone agrees with “pouring water into the sea is harmless enough” even in the Florida Bay area.
10
Nitrogen was poured in from different types of crops as water flows through.
11
Everglade restoration project can be effective regardless of the cause of the pollution.
12
Human has changed Florida Bay where old image before 1950s is unrecalled.
13
Tourism contributes fundamentally to the Florida Bay area.

13 ____ Tourism contributes fundamentally to the Florida Bay area.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eda6085d-bfd8-5357-a0a2-aeb5ec1aa97f', '1cf6839c-e80e-522a-9a9d-771cbcedf0c1', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e58abd73-de69-58ad-9492-f4c29a6c2e89', '1cf6839c-e80e-522a-9a9d-771cbcedf0c1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1045f3c4-e89b-56b7-952f-193747234200', '1cf6839c-e80e-522a-9a9d-771cbcedf0c1', 3, $md$NOT GIVEN$md$, false);

COMMIT;
