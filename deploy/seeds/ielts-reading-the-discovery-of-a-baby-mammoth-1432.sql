BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-discovery-of-a-baby-mammoth-1432'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-discovery-of-a-baby-mammoth-1432';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-discovery-of-a-baby-mammoth-1432';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-discovery-of-a-baby-mammoth-1432';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('325f5364-b9bf-59ce-9b3f-45967a7197a6', 'ielts-reading-the-discovery-of-a-baby-mammoth-1432', $t$The discovery of a baby mammoth$t$, $md$## The discovery of a baby mammoth

Nguồn:
- Test: https://mini-ielts.com/1432/reading/the-discovery-of-a-baby-mammoth
- Solution: https://mini-ielts.com/1432/view-solution/reading/the-discovery-of-a-baby-mammoth$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('43511e96-ecaa-59a6-8477-013dea67d555', '325f5364-b9bf-59ce-9b3f-45967a7197a6', 1, $t$Reading — The discovery of a baby mammoth$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The discovery of a baby mammoth

A near-perfect frozen mammoth offers clues to a great vanished species

A On a May morning in 2007, on the Yamal Peninsula in northwestern Siberia, a Nenets reindeer herder named Yuri Khudi stood on a sandbar on the Yuribey River, looking carefully at a diminutive corpse. Although he'd never seen such an animal before, Khudi had seen many mammoth tusks, the thick corkscrew shafts that his people found each summer, and this persuaded him the corpse was a baby mammoth. It was eerily well preserved. Apart from its missing hair and toenails, it was perfectly intact. Khudi realised the find might be significant and he knew he couldn't just return home and forget all about it. He therefore decided to travel to the small town of Yar Sale to consult an old friend named Kirill Serotetto. His friend took him to meet the director of the local museum, who persuaded the local authorities to fly Khudi and Serotetto back to the Yuribey River to collect the baby mammoth.

B Mammoths became extinct between 14,000 and 10,000 years ago and since the extinctions coincided with the end of the most recent Ice age, many researchers believe that the primary cause of the great die-off was the sharp rise in temperature, which dramatically altered the vegetation. 'We have strong evidence that the temperature rise played a significant part in their extinction.’ says Adrian Lister, a palaeontologist and mammoth expert at London's Natural History Museum. 'In Eurasia, the timing of the two events matches closely.' The extinctions also coincided, however, with the arrival of modern humans. In addition to exploiting mammoths for food, they used their bones and tusks to make weapons, tools, and even dwellings. Some scientists believe humans were as much to blame as the temperature rise for the great die-off. Some say they caused it.

C The body of the baby mammoth was eventually sent to the st Petersburg Zoological Museum in Russia. Alexei Tikhonov, the museum's director, was one of the first scientists to view the baby, a female. According to Tikhonov, Khudi had rescued 'the best preserved mammoth to come down to US from the Ice Age', and he gratefully named her Lyuba, after Khudi's wife. Tikhonov knew that no-one would be more excited by the find than Dan Fisher, an American colleague at the University of Michigan who had spent 30 years researching the lives of mammoths. Tikhonov invited Fisher, along with Bernard Buigues, a French mammoth hunter, to come and view the baby mammoth. Fisher and Buigues had examined other specimens together, including infants, but these had been in a relatively poor state. Lyuba was another story entirely, other than the missing hair and toenails, the only flaw in her pristine appearance was a curious dent above the trunk.

D Fisher was particularly excited about one specific part of Lyuba's anatomy: her milk tusks. Through his career, Fisher has taken hundreds of tusk samples. Most of these came from the Great Lakes region of North America, and his research showed that these animals continued to thrive, despite the late Pleistocene* temperature change. On the other hand, Pleistocene era: the time between roughly 2.6 million years ago and 10.000 years ago to Fisher the tusks often revealed telltale evidence of human hunting. His samples frequently came from animals that had died in the autumn, when they should have been at their peak after summer grazing, and less likely to die of natural causes, but also when humans would have been most eager to stockpile meat for the coming winter. He has done limited work in Siberia, but his analysis of tusks from Wrangel Island, off the coast of Siberia, suggests the same conclusion.

E In December 2007, Buigues arranged for the specimen to be transported to Japan to undergo a CT scan by Naoki Suzuki of the Jikei University School of Medicine. The test confirmed her skeleton was undamaged, and her internal organs seemed largely intact. It also showed that the end of her trunk, and her throat, mouth, and windpipe were filled with dense sediment. Six months later, in a laboratory in st Petersburg, Fisher, Buigues, Suzuki, Tikhonov and other colleagues began a three-day series of tests on Lyuba. During these, Fisher noted a dense mix of clay and sand in her trunk, mouth and throat, which had been indicated earlier by the scan. In fact, the sediment in Lyuba's trunk was packed so tightly that Fisher saw it as a possible explanation for the dent above her trunk. If she was frantically fighting for breath and inhaled convulsively, perhaps a partial vacuum was created in the base of her trunk, which would have flattened surrounding soft tissue. To Fisher, the circumstances of Lyuba's death were clear: she had asphyxiated. Suzuki, however, proposed a different interpretation, seeing more evidence for drowning than asphyxiation.

F Studies are ongoing, but Lyuba has begun to shed the secrets of her short life and some clues to the fate of her kind. Her good general health was shown in the record of her dental development, a confirmation for Fisher that dental research is useful for evaluating health and thus key to investigating the causes of mammoth extinction. Analysis of her well- preserved DNA has revealed that she belonged to a distinct population of Mammuthus primigenius and that, soon after her time, another population migrating to Siberia from North America would take their place. Finally, Lyuba's premolars and tusks revealed that she had been born in late spring and was only a month old when she died.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ab0917bc-8954-598b-afb0-3af82906cd30', '43511e96-ecaa-59a6-8477-013dea67d555', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage has six paragraphs,
A-F.
Which paragraph contains the following information?
Write the correct letter, A-F, in boxes 1-5 on your answer sheet.
1
Similarities between studies of mammoth remains from different parts of the world.
2
Details of the uses to which mammoth body parts were put.
3
A theory that accounts for the damage to lyuba’s face.
4
An explanation of how an individual was able to identify a small corpse.
5
A comparison between lyuba and other young mammoth corpses.

1 ____ Similarities between studies of mammoth remains from different parts of the world.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cdb83f2-d8f9-5293-a72c-6b335b449347', 'ab0917bc-8954-598b-afb0-3af82906cd30', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fea3d11f-2006-53c5-a4fb-786c0652a6b2', 'ab0917bc-8954-598b-afb0-3af82906cd30', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0419c6b-25ae-50b7-8faf-110cd18c5446', 'ab0917bc-8954-598b-afb0-3af82906cd30', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('884dd554-5c3b-53fc-b246-84a2b5921029', 'ab0917bc-8954-598b-afb0-3af82906cd30', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48775fcb-e16b-599e-83ae-1ba7f8c1a47e', 'ab0917bc-8954-598b-afb0-3af82906cd30', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d69e970a-a422-5846-b2bc-d85455832c88', 'ab0917bc-8954-598b-afb0-3af82906cd30', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('db9709a9-0e48-5feb-ba38-ce01de4c33b2', '43511e96-ecaa-59a6-8477-013dea67d555', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage has six paragraphs,
A-F.
Which paragraph contains the following information?
Write the correct letter, A-F, in boxes 1-5 on your answer sheet.
1
Similarities between studies of mammoth remains from different parts of the world.
2
Details of the uses to which mammoth body parts were put.
3
A theory that accounts for the damage to lyuba’s face.
4
An explanation of how an individual was able to identify a small corpse.
5
A comparison between lyuba and other young mammoth corpses.

2 ____ Details of the uses to which mammoth body parts were put.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef531125-b2d9-5984-a7a1-38188f33dce1', 'db9709a9-0e48-5feb-ba38-ce01de4c33b2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc538d1b-240e-50ea-8522-5978fc6b9706', 'db9709a9-0e48-5feb-ba38-ce01de4c33b2', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8138938-e87c-514d-9d63-51edda92735d', 'db9709a9-0e48-5feb-ba38-ce01de4c33b2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e65c6ae5-74f6-550f-9606-0b11d6b5ebb0', 'db9709a9-0e48-5feb-ba38-ce01de4c33b2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3967838f-15f9-55f3-be06-237aa4e9d767', 'db9709a9-0e48-5feb-ba38-ce01de4c33b2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a3f95c2-35b6-5910-a30f-c22e8fa66155', 'db9709a9-0e48-5feb-ba38-ce01de4c33b2', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('04df62e2-dfb8-5539-be43-971d435f04ef', '43511e96-ecaa-59a6-8477-013dea67d555', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage has six paragraphs,
A-F.
Which paragraph contains the following information?
Write the correct letter, A-F, in boxes 1-5 on your answer sheet.
1
Similarities between studies of mammoth remains from different parts of the world.
2
Details of the uses to which mammoth body parts were put.
3
A theory that accounts for the damage to lyuba’s face.
4
An explanation of how an individual was able to identify a small corpse.
5
A comparison between lyuba and other young mammoth corpses.

3 ____ A theory that accounts for the damage to lyuba’s face.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cede627-22e7-5330-a370-29ddf9cfc48e', '04df62e2-dfb8-5539-be43-971d435f04ef', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddf7fcd9-9ed0-5d1f-904d-3b9ba2d460c7', '04df62e2-dfb8-5539-be43-971d435f04ef', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50c1de8d-4e6c-5cdf-9c0b-2883427b8188', '04df62e2-dfb8-5539-be43-971d435f04ef', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b9b7af2-b6f6-5645-86f9-c2f2845b3c01', '04df62e2-dfb8-5539-be43-971d435f04ef', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af6a175d-d69c-5e84-864d-4aa1c608ad60', '04df62e2-dfb8-5539-be43-971d435f04ef', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fffc31b-d127-5d58-8c81-4bf4cee29ae1', '04df62e2-dfb8-5539-be43-971d435f04ef', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5720f40a-9450-5ce6-aa8f-630718bf31c9', '43511e96-ecaa-59a6-8477-013dea67d555', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage has six paragraphs,
A-F.
Which paragraph contains the following information?
Write the correct letter, A-F, in boxes 1-5 on your answer sheet.
1
Similarities between studies of mammoth remains from different parts of the world.
2
Details of the uses to which mammoth body parts were put.
3
A theory that accounts for the damage to lyuba’s face.
4
An explanation of how an individual was able to identify a small corpse.
5
A comparison between lyuba and other young mammoth corpses.

4 ____ An explanation of how an individual was able to identify a small corpse.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d0af50e-1a36-559d-9241-b65b6555c532', '5720f40a-9450-5ce6-aa8f-630718bf31c9', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e05ee0d4-8dff-5fbd-b7e0-9f992ad56590', '5720f40a-9450-5ce6-aa8f-630718bf31c9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14916bbd-5269-5478-ad5a-1c9889481400', '5720f40a-9450-5ce6-aa8f-630718bf31c9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7d87579-c814-5887-80e4-0761e0e3e12b', '5720f40a-9450-5ce6-aa8f-630718bf31c9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa6be32b-118b-545a-8a14-57786d5d1387', '5720f40a-9450-5ce6-aa8f-630718bf31c9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3166f091-862f-5370-bf09-2a80efe404cc', '5720f40a-9450-5ce6-aa8f-630718bf31c9', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bffe9f09-8986-5e5e-9682-9efd252e696d', '43511e96-ecaa-59a6-8477-013dea67d555', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage has six paragraphs,
A-F.
Which paragraph contains the following information?
Write the correct letter, A-F, in boxes 1-5 on your answer sheet.
1
Similarities between studies of mammoth remains from different parts of the world.
2
Details of the uses to which mammoth body parts were put.
3
A theory that accounts for the damage to lyuba’s face.
4
An explanation of how an individual was able to identify a small corpse.
5
A comparison between lyuba and other young mammoth corpses.

5 ____ A comparison between lyuba and other young mammoth corpses.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5dd242d-dfc8-5e6f-a604-3cf56f6328ca', 'bffe9f09-8986-5e5e-9682-9efd252e696d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9a5ba11-28b4-5953-942d-3b37456a40b4', 'bffe9f09-8986-5e5e-9682-9efd252e696d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('630512ac-0401-522e-b92e-2235df4cd993', 'bffe9f09-8986-5e5e-9682-9efd252e696d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36732eef-036c-529d-8d84-a90ff6aec601', 'bffe9f09-8986-5e5e-9682-9efd252e696d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4d86b67-a5c5-571a-88ef-81bd0a35cc82', 'bffe9f09-8986-5e5e-9682-9efd252e696d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fb33c74-3026-5713-8cde-2e06e16527b4', 'bffe9f09-8986-5e5e-9682-9efd252e696d', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cccb3d1b-3a45-5779-be07-0bd4426e7b1c', '43511e96-ecaa-59a6-8477-013dea67d555', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Look at the following statements (Questions 6-10) and the list of people below.
Match each statement with the correct person, A-G.
Write the correct letter, A-G, in boxes 6-10 on your answer sheet.
NB
You may use any letter more than once.
6
The indications are that mammoths died as a result of climate change.
7
Teeth analysis is important in discovering why mammoths died out.
8
The corpse of the baby mammoth is in better condition than any other that has been discovered.
9
It would be a mistake to ignore the baby mammoth’s discovery, because of its potential importance.
10
Mammoths often died at a time of year when they should have been in good physical condition.
List of People
A
Yuri Khudi
B
Kirill Serotetto
c
Adrian Lister
D
Alexei Tikhonov
E
Dan Fisher
F
Bermard Buigues
G
Naoki Suzuki

6 ____ The indications are that mammoths died as a result of climate change.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9201d0b2-20e9-5b9a-b3bd-10ca894a58f2', 'cccb3d1b-3a45-5779-be07-0bd4426e7b1c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d68e6bc-4ea8-5e0e-93ee-58c8c46ed401', 'cccb3d1b-3a45-5779-be07-0bd4426e7b1c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ddd1bdb-f529-5e4e-9842-295d441ace6d', 'cccb3d1b-3a45-5779-be07-0bd4426e7b1c', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5bda7eb-b20d-5f0c-97ba-d6fb152bf880', 'cccb3d1b-3a45-5779-be07-0bd4426e7b1c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3720a73-2979-57cc-a011-2ec3e2d3372e', 'cccb3d1b-3a45-5779-be07-0bd4426e7b1c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcc02c20-092c-54e8-942f-f65810e4ed73', 'cccb3d1b-3a45-5779-be07-0bd4426e7b1c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d85f08c-d751-5135-a9f0-e5a6111f0e57', 'cccb3d1b-3a45-5779-be07-0bd4426e7b1c', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a86fdd94-8873-5b14-bf5f-b5c792d03bd4', '43511e96-ecaa-59a6-8477-013dea67d555', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Look at the following statements (Questions 6-10) and the list of people below.
Match each statement with the correct person, A-G.
Write the correct letter, A-G, in boxes 6-10 on your answer sheet.
NB
You may use any letter more than once.
6
The indications are that mammoths died as a result of climate change.
7
Teeth analysis is important in discovering why mammoths died out.
8
The corpse of the baby mammoth is in better condition than any other that has been discovered.
9
It would be a mistake to ignore the baby mammoth’s discovery, because of its potential importance.
10
Mammoths often died at a time of year when they should have been in good physical condition.
List of People
A
Yuri Khudi
B
Kirill Serotetto
c
Adrian Lister
D
Alexei Tikhonov
E
Dan Fisher
F
Bermard Buigues
G
Naoki Suzuki

7 ____ Teeth analysis is important in discovering why mammoths died out.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92558b96-5415-564c-a4c9-73a8b6d02a2e', 'a86fdd94-8873-5b14-bf5f-b5c792d03bd4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9cd5bc7-62d2-5c9b-8d0d-a966ba649762', 'a86fdd94-8873-5b14-bf5f-b5c792d03bd4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c9c937f-095c-5035-ac50-2c823bafc7ee', 'a86fdd94-8873-5b14-bf5f-b5c792d03bd4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4925a90-de1b-59b5-87f0-6e5a79063c9d', 'a86fdd94-8873-5b14-bf5f-b5c792d03bd4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90e8e0c8-0e55-5ed6-8660-786696176278', 'a86fdd94-8873-5b14-bf5f-b5c792d03bd4', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c61fd06c-0634-511b-84b7-1efb33b53fa3', 'a86fdd94-8873-5b14-bf5f-b5c792d03bd4', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cc494bd-5d84-5005-a4d7-80062aeb3542', 'a86fdd94-8873-5b14-bf5f-b5c792d03bd4', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ffff580d-d0b4-50bd-8eda-8b20a58737e5', '43511e96-ecaa-59a6-8477-013dea67d555', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Look at the following statements (Questions 6-10) and the list of people below.
Match each statement with the correct person, A-G.
Write the correct letter, A-G, in boxes 6-10 on your answer sheet.
NB
You may use any letter more than once.
6
The indications are that mammoths died as a result of climate change.
7
Teeth analysis is important in discovering why mammoths died out.
8
The corpse of the baby mammoth is in better condition than any other that has been discovered.
9
It would be a mistake to ignore the baby mammoth’s discovery, because of its potential importance.
10
Mammoths often died at a time of year when they should have been in good physical condition.
List of People
A
Yuri Khudi
B
Kirill Serotetto
c
Adrian Lister
D
Alexei Tikhonov
E
Dan Fisher
F
Bermard Buigues
G
Naoki Suzuki

8 ____ The corpse of the baby mammoth is in better condition than any other that has been discovered.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cec6c210-3311-5ef6-8015-f17eb5aca978', 'ffff580d-d0b4-50bd-8eda-8b20a58737e5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1499b17c-cc7f-5546-b438-a5e3423194b5', 'ffff580d-d0b4-50bd-8eda-8b20a58737e5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('642402e6-d60b-5ee7-9c61-f56f66e17747', 'ffff580d-d0b4-50bd-8eda-8b20a58737e5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e329ead2-5ecc-5f1f-97a6-81f84ef8e229', 'ffff580d-d0b4-50bd-8eda-8b20a58737e5', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d0aa83f-a0c1-545f-9d74-0269e66973cd', 'ffff580d-d0b4-50bd-8eda-8b20a58737e5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bcad15d-b984-52fc-a942-d338877344eb', 'ffff580d-d0b4-50bd-8eda-8b20a58737e5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d453b29-6a84-52b2-a357-52c1cd2bdae2', 'ffff580d-d0b4-50bd-8eda-8b20a58737e5', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e07043cc-c1f8-5c6e-9e69-030da3f73bbf', '43511e96-ecaa-59a6-8477-013dea67d555', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Look at the following statements (Questions 6-10) and the list of people below.
Match each statement with the correct person, A-G.
Write the correct letter, A-G, in boxes 6-10 on your answer sheet.
NB
You may use any letter more than once.
6
The indications are that mammoths died as a result of climate change.
7
Teeth analysis is important in discovering why mammoths died out.
8
The corpse of the baby mammoth is in better condition than any other that has been discovered.
9
It would be a mistake to ignore the baby mammoth’s discovery, because of its potential importance.
10
Mammoths often died at a time of year when they should have been in good physical condition.
List of People
A
Yuri Khudi
B
Kirill Serotetto
c
Adrian Lister
D
Alexei Tikhonov
E
Dan Fisher
F
Bermard Buigues
G
Naoki Suzuki

9 ____ It would be a mistake to ignore the baby mammoth’s discovery, because of its potential importance.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f912a7d1-d77c-523d-a048-6ea46ef54495', 'e07043cc-c1f8-5c6e-9e69-030da3f73bbf', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7bf4484-b0a8-54a4-8987-508f23d9a0da', 'e07043cc-c1f8-5c6e-9e69-030da3f73bbf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4792242c-69eb-565e-96fc-d0e7597650e5', 'e07043cc-c1f8-5c6e-9e69-030da3f73bbf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52e8c5ad-7424-5dc9-9c4e-e4e924250788', 'e07043cc-c1f8-5c6e-9e69-030da3f73bbf', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fa6f0fb-4248-53b8-963d-093474728853', 'e07043cc-c1f8-5c6e-9e69-030da3f73bbf', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98dca2fd-fc9c-5154-97fd-f3e0bd12b7be', 'e07043cc-c1f8-5c6e-9e69-030da3f73bbf', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('238c9844-124f-5729-b6d6-c69d5a08d245', 'e07043cc-c1f8-5c6e-9e69-030da3f73bbf', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('52aad317-c58b-5808-b2e9-ac25ce45ccc2', '43511e96-ecaa-59a6-8477-013dea67d555', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Look at the following statements (Questions 6-10) and the list of people below.
Match each statement with the correct person, A-G.
Write the correct letter, A-G, in boxes 6-10 on your answer sheet.
NB
You may use any letter more than once.
6
The indications are that mammoths died as a result of climate change.
7
Teeth analysis is important in discovering why mammoths died out.
8
The corpse of the baby mammoth is in better condition than any other that has been discovered.
9
It would be a mistake to ignore the baby mammoth’s discovery, because of its potential importance.
10
Mammoths often died at a time of year when they should have been in good physical condition.
List of People
A
Yuri Khudi
B
Kirill Serotetto
c
Adrian Lister
D
Alexei Tikhonov
E
Dan Fisher
F
Bermard Buigues
G
Naoki Suzuki

10 ____ Mammoths often died at a time of year when they should have been in good physical condition.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98eca312-25a6-55c3-806a-9f8c998824b0', '52aad317-c58b-5808-b2e9-ac25ce45ccc2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2d02df0-a09d-540a-92ae-f1384b8ae645', '52aad317-c58b-5808-b2e9-ac25ce45ccc2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8db559ee-a711-5744-a492-04cc8d25adfa', '52aad317-c58b-5808-b2e9-ac25ce45ccc2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34a5cf66-d509-56a5-8553-ca947556df1d', '52aad317-c58b-5808-b2e9-ac25ce45ccc2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1afe53b7-9df5-5bba-a748-eb20680e5930', '52aad317-c58b-5808-b2e9-ac25ce45ccc2', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eaf130e6-a961-5fde-8b8c-f71765aecba7', '52aad317-c58b-5808-b2e9-ac25ce45ccc2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aaa9dfe8-677a-5a82-815d-6ddeca1096cc', '52aad317-c58b-5808-b2e9-ac25ce45ccc2', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3568ff91-84f8-5eed-9d53-3a3cc787e702', '43511e96-ecaa-59a6-8477-013dea67d555', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
11. Some researchers say that a marked rise in temperature impacted on mammoths by changing the type of
11
available.
12. Fisher concluded that many of the mammoth tusks he looked at displayed signs of
12
.
13. Not long after Lyuba’s death, the
Mammuthus primigenius
group she belonged to was replaced by another group that came from
13
.

11. Some researchers say that a marked rise in temperature impacted on mammoths by changing the type of 11 ____ available.$md$, NULL, ARRAY['.*vegetable.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1450ecc5-9dfe-5469-8a40-1f8cd42647b2', '43511e96-ecaa-59a6-8477-013dea67d555', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
11. Some researchers say that a marked rise in temperature impacted on mammoths by changing the type of
11
available.
12. Fisher concluded that many of the mammoth tusks he looked at displayed signs of
12
.
13. Not long after Lyuba’s death, the
Mammuthus primigenius
group she belonged to was replaced by another group that came from
13
.

12. Fisher concluded that many of the mammoth tusks he looked at displayed signs of 12 ____ .$md$, NULL, ARRAY['.*human.*hunting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0d90a496-5e85-5559-ace1-940c7785522c', '43511e96-ecaa-59a6-8477-013dea67d555', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
11. Some researchers say that a marked rise in temperature impacted on mammoths by changing the type of
11
available.
12. Fisher concluded that many of the mammoth tusks he looked at displayed signs of
12
.
13. Not long after Lyuba’s death, the
Mammuthus primigenius
group she belonged to was replaced by another group that came from
13
.

13. Not long after Lyuba’s death, the Mammuthus primigenius group she belonged to was replaced by another group that came from 13 ____ .$md$, NULL, ARRAY['.*north.*america.*']);

COMMIT;
