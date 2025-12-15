BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-return-of-monkey-life-1426'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-return-of-monkey-life-1426';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-return-of-monkey-life-1426';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-return-of-monkey-life-1426';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('674921cc-5a9a-5ae0-899f-95678e3d9830', 'ielts-reading-the-return-of-monkey-life-1426', $t$The return of monkey life$t$, $md$## The return of monkey life

Nguồn:
- Test: https://mini-ielts.com/1426/reading/the-return-of-monkey-life
- Solution: https://mini-ielts.com/1426/view-solution/reading/the-return-of-monkey-life$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f5d10cd5-6d57-5cf8-b300-35339cda6589', '674921cc-5a9a-5ae0-899f-95678e3d9830', 1, $t$Reading — The return of monkey life$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The return of monkey life

Rain forest trees growing anew on Central American farmland are helping scientists find ways for monkey and agriculture to benefit one another.

A. Hacienda La Pacifica, a remote working cattle ranch in Guanacaste province of northern Costa Rica, has for decades been home to a community of mantled howler monkeys. Other native primates- white-faced capuchin monkeys and spider monkeys were once common in this area, too, but vanished after the Pan-American Highway was built nearby in the 1950s and most of the surrounding land was cleared for cattle-raising. At Hacienda La Pacifica, however, an enlightened ranch owner chose to leave some strips of native trees growing. He used these as windbreaks to protect both cattle and their food crops from dry-season winds. In the process, the farmer unwittingly founded a unique laboratory for the study of monkeys.

B . Ken Glander, a primatologist from Duke University in the USA, is studying La Pacifica’s monkeys in an effort to understand the relationship between howlers and regenerating forests at the edges of grazing lands. Studying such disturbed woodlands is increasingly important because throughout much of the New World Tropics, these are the only forests left. In the 18 th century, tropical dry forests once covered most of Central America, but by the 1980s less than two percent remained undisturbed, and less than one percent was protected.

C . Howlers persists at La Pacifica, Glander explains, because they are leaf-eaters. They eat fruit when it is available but, unlike capuchin and spider monkeys, do not depend on large areas of fruiting trees. Glander is particularly interested in howlers’ ability to thrive on leaves loaded with toxins- poisonous substances designed to protect the plants. For leaf-eaters, long-term exposure to a specific plant toxin can increase their ability to neutralize the poisonous substances and absorb the leaf nutrients. Watching generations of howlers at La Pacifica has shown Glander that the monkeys keep their systems primed by sampling a variety of plants and then focusing on a small number of the most nutritious food items. The leaves that grow in regenerating forests, like those at La Pacifica, are actually more howler-friendly than those produced by the centuries-old trees that survive farther south. In younger forests, trees put most of their limited energy into growing wood, leaves, and fruit, so they produce much lower levels of toxin than do well-established, old-growth trees.

D. The value of maturing forests to primates is also a subject of study at Santa Rosa National Park, about 35 miles northwest of La Pacifica. Large areas of Santa Rosa’s forests had at one time been burnt to make space for cattle ranching and coffee farming, thereby devastating local monkey habitat. But in 1971 the government protected the area by designating it a National Park, and species of Indigenous Lees which had been absent for decades began to invade the abandoned pastures. Capuchins were the first to begin using the reborn forests, followed by howlers. Eventually, even spider monkeys, fruit-eaters that need large areas of continuous forest, returned. In the first 28 years following protection of the area, the capuchin population doubled, while the number of howlers increased sevenfold.

E. Some of the same traits that allow howlers to survive at La Pacifica also explain their population boom in Santa Rosa, Howler reproduction is faster than that of other native monkey species. They give birth for the first time at about 3.5 years of age, compared with seven years for capuchins, and eight or more for spider monkeys. Also, while a female spider monkey will have a baby about once every four years, well-fed howlers can produce an infant every two years. Another factor is diet. Howlers are very adaptable feeders, and only need a comparatively small home range. Spider monkeys, on the other hand, need to occupy a huge home range. Also crucial is fact that the leaves howlers eat hold plenty of water, so the monkeys can survive away from open streams and water holes. This ability gives them a real advantage over capuchin and spider monkeys, which have suffered during the long, ongoing drought in the area.

F. Alejandro Estrada, an ecologist at Estacion de Biologia Los Tuxtlas in Veracruz, Mexico, has been studying the ecology of a group of howler monkeys that thrive in a habitat totally altered by humans: a cacao plantation in Tabasco state, Mexico. Cacao plants need shade to grow, so 40 years ago the owners of Cholula Cacao Farm planted figs, monkeypod and other tall trees to form a protective canopy over their crop. The howlers moved in about 25 years ago after nearby forests were cut. This strange habitat seems to support about as many monkeys as would a same-sized patch of wild forest. The howlers eat the leaves and fruit of the shade trees, leaving the valuable cacao pods alone.

G. Estrada believes the monkeys bring underappreciated benefits to such plantations, dispersing the seeds of fruits such as fig and other shade trees, and fertilizing the soil. Spider monkeys also forage for fruit here, though they need nearby areas of forest to survive in the long term. He hopes that farmers will begin to see the advantages of associating with wild monkeys, which could include potential ecotourism projects, ‘Conservation is usually viewed as a conflict between farming practices and the need to preserve nature,’ Estrada says. ‘We’re moving away from that vision and beginning to consider ways in which commercial activities may become a tool for the conservation of primates in human-modified landscapes.’$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('34fd4780-12e0-5fc5-9488-ced1204e6648', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

QUESTIONS 1-4
QUESTIONS 1-4
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes 1-4 on your answer sheet.
NB
You may use any letter more than once
1
a reason why newer forests provide howlers with better feeding opportunities than older forests
2
a reference to a change in farmers’ attitudes towards wildlife
3
a description of the means by which howlers select the best available diet for themselves
4
figures relating to the reduction of natural wildlife habitat over a period of time

1 ____ a reason why newer forests provide howlers with better feeding opportunities than older forests$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16db1edf-0c38-551f-ab5d-200414de17e3', '34fd4780-12e0-5fc5-9488-ced1204e6648', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97ac355e-dbfd-5317-b8d8-cb49fb6c5d09', '34fd4780-12e0-5fc5-9488-ced1204e6648', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f15a34c-6adb-50ae-9212-2483e34cda92', '34fd4780-12e0-5fc5-9488-ced1204e6648', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dee12331-c699-5900-a1b8-3cfdafe56ba3', '34fd4780-12e0-5fc5-9488-ced1204e6648', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f54e3c3c-ade9-50a5-83dd-52d62e4ff9b5', '34fd4780-12e0-5fc5-9488-ced1204e6648', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58d97ca6-c50e-5f13-a7ba-f2258417f7d0', '34fd4780-12e0-5fc5-9488-ced1204e6648', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('783bc39b-2f74-5b55-9865-ee92e986c516', '34fd4780-12e0-5fc5-9488-ced1204e6648', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1cb9c130-96e1-5c93-9002-f0c0cf1053bd', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

QUESTIONS 1-4
QUESTIONS 1-4
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes 1-4 on your answer sheet.
NB
You may use any letter more than once
1
a reason why newer forests provide howlers with better feeding opportunities than older forests
2
a reference to a change in farmers’ attitudes towards wildlife
3
a description of the means by which howlers select the best available diet for themselves
4
figures relating to the reduction of natural wildlife habitat over a period of time

2 ____ a reference to a change in farmers’ attitudes towards wildlife$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2a17b3c-3ca7-500d-8122-0dd7bff81e92', '1cb9c130-96e1-5c93-9002-f0c0cf1053bd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0c04342-a12d-54ae-a5db-3310a0a3bb49', '1cb9c130-96e1-5c93-9002-f0c0cf1053bd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('caf6b5a0-8c2d-5343-9b5d-04f0d2e483c9', '1cb9c130-96e1-5c93-9002-f0c0cf1053bd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fafedfe2-e012-5e07-ac63-08cc33c35d98', '1cb9c130-96e1-5c93-9002-f0c0cf1053bd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf707ddc-e687-5b3f-ac36-f13558f68726', '1cb9c130-96e1-5c93-9002-f0c0cf1053bd', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44327f0a-28a1-5d15-a0a1-a526c0cb3b3b', '1cb9c130-96e1-5c93-9002-f0c0cf1053bd', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fb29a10-9f81-51d4-89eb-dfd18b77f6ba', '1cb9c130-96e1-5c93-9002-f0c0cf1053bd', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('806e2b6c-53c5-5ee0-a3f8-c9598df89d79', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

QUESTIONS 1-4
QUESTIONS 1-4
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes 1-4 on your answer sheet.
NB
You may use any letter more than once
1
a reason why newer forests provide howlers with better feeding opportunities than older forests
2
a reference to a change in farmers’ attitudes towards wildlife
3
a description of the means by which howlers select the best available diet for themselves
4
figures relating to the reduction of natural wildlife habitat over a period of time

3 ____ a description of the means by which howlers select the best available diet for themselves$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fb9aaca-397e-5a86-a9d2-351764c4a0f3', '806e2b6c-53c5-5ee0-a3f8-c9598df89d79', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e15bff7-2a65-5b47-9be4-889a48d20445', '806e2b6c-53c5-5ee0-a3f8-c9598df89d79', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25397bf5-3f67-516e-9252-1f4fde8427aa', '806e2b6c-53c5-5ee0-a3f8-c9598df89d79', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51f05549-7b30-5f54-8036-c06e291c4aa8', '806e2b6c-53c5-5ee0-a3f8-c9598df89d79', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04355e72-fb1f-533c-871a-e7d6ba5637d6', '806e2b6c-53c5-5ee0-a3f8-c9598df89d79', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88fcbdcf-9d7e-553a-9833-2f0b176af011', '806e2b6c-53c5-5ee0-a3f8-c9598df89d79', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('642151be-1938-5326-b008-34b9e864ad25', '806e2b6c-53c5-5ee0-a3f8-c9598df89d79', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('80fc656c-9a5c-5818-8158-ac47610a3987', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

QUESTIONS 1-4
QUESTIONS 1-4
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes 1-4 on your answer sheet.
NB
You may use any letter more than once
1
a reason why newer forests provide howlers with better feeding opportunities than older forests
2
a reference to a change in farmers’ attitudes towards wildlife
3
a description of the means by which howlers select the best available diet for themselves
4
figures relating to the reduction of natural wildlife habitat over a period of time

4 ____ figures relating to the reduction of natural wildlife habitat over a period of time$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1772f42-2f40-58b1-82fb-c5a5e542f821', '80fc656c-9a5c-5818-8158-ac47610a3987', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cf58f53-93a7-5814-8e3f-235ab1d30df9', '80fc656c-9a5c-5818-8158-ac47610a3987', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d0d5b6f-4ee4-5b57-b13e-789d70fa9c5a', '80fc656c-9a5c-5818-8158-ac47610a3987', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a56c520-ca51-585c-af21-87a411319eec', '80fc656c-9a5c-5818-8158-ac47610a3987', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('563f8bb1-7e23-56ad-8446-063e39b136bf', '80fc656c-9a5c-5818-8158-ac47610a3987', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a320607-7537-5625-894c-53217d053a75', '80fc656c-9a5c-5818-8158-ac47610a3987', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('862680b6-1499-579b-a1b9-bcfbc1b844b4', '80fc656c-9a5c-5818-8158-ac47610a3987', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f3f3e91b-2a6b-55d1-8275-d598b61003ff', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

QUESTIONS 5-8
QUESTIONS 5-8
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 5-8 on your answer sheet.
Why do howlers have an advantage over other
Central American monkeys?
Howler monkeys have a more rapid rate of
5
than either capuchin of spider monkeys.
Unlike the other local monkey species, howlers can survive without eating
6
,
and so can live inside a relatively small habitat area. Their diet is more flexible, and they are able to tolerate leaves with high levels of
7
.
Howlers can also survive periods of
8
better than the other monkey species can.

Howler monkeys have a more rapid rate of 5 ____ than either capuchin of spider monkeys.$md$, NULL, ARRAY['.*reproduction.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0fe139fe-585a-5b10-87c7-936b24a3575c', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

QUESTIONS 5-8
QUESTIONS 5-8
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 5-8 on your answer sheet.
Why do howlers have an advantage over other
Central American monkeys?
Howler monkeys have a more rapid rate of
5
than either capuchin of spider monkeys.
Unlike the other local monkey species, howlers can survive without eating
6
,
and so can live inside a relatively small habitat area. Their diet is more flexible, and they are able to tolerate leaves with high levels of
7
.
Howlers can also survive periods of
8
better than the other monkey species can.

Unlike the other local monkey species, howlers can survive without eating 6 ____ ,$md$, NULL, ARRAY['.*fruit.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c10a3581-8e16-55f5-8553-cd6797c062c4', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

QUESTIONS 5-8
QUESTIONS 5-8
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 5-8 on your answer sheet.
Why do howlers have an advantage over other
Central American monkeys?
Howler monkeys have a more rapid rate of
5
than either capuchin of spider monkeys.
Unlike the other local monkey species, howlers can survive without eating
6
,
and so can live inside a relatively small habitat area. Their diet is more flexible, and they are able to tolerate leaves with high levels of
7
.
Howlers can also survive periods of
8
better than the other monkey species can.

and so can live inside a relatively small habitat area. Their diet is more flexible, and they are able to tolerate leaves with high levels of 7 ____ .$md$, NULL, ARRAY['.*toxics.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('683ecbe6-775d-5fd0-919b-bfc26d8e0238', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

QUESTIONS 5-8
QUESTIONS 5-8
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 5-8 on your answer sheet.
Why do howlers have an advantage over other
Central American monkeys?
Howler monkeys have a more rapid rate of
5
than either capuchin of spider monkeys.
Unlike the other local monkey species, howlers can survive without eating
6
,
and so can live inside a relatively small habitat area. Their diet is more flexible, and they are able to tolerate leaves with high levels of
7
.
Howlers can also survive periods of
8
better than the other monkey species can.

Howlers can also survive periods of 8 ____ better than the other monkey species can.$md$, NULL, ARRAY['.*drought.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('62a217f0-a18b-5556-a87f-779293288216', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

QUESTIONS 9-13
QUESTIONS 9-13
Look at the following features (Questions 9-13) and the list of locations below.
Match each feature with the correct location,
A
,
B
or
C
.
Write the correct letter,
A
,
B
or
C
, in boxes 9-13 on your answer sheet.
NB
You may use any letter more than once.
List of Locations
A
Hacienda La Pacifica
B
Santa Rosa National Park
C
Cholula Cacao Farm
9
It has seen the return of native tree species.
10
It supports only one species of native monkey.
11
Its monkey population helps the agriculture of the area.
12
It is home to populations of all three local monkey species.
13
Its landscape was altered by the construction of a transport link.

9 ____ It has seen the return of native tree species.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('830812ad-7ed5-59b9-a5d0-51ccd17cfc97', '62a217f0-a18b-5556-a87f-779293288216', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2017966f-18cb-5596-86f3-6774cd7f38b6', '62a217f0-a18b-5556-a87f-779293288216', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14739c42-ac16-5b83-9f5d-ea467ef2f9b9', '62a217f0-a18b-5556-a87f-779293288216', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('82d6d935-f2ee-50a1-b357-431eb3100cad', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

QUESTIONS 9-13
QUESTIONS 9-13
Look at the following features (Questions 9-13) and the list of locations below.
Match each feature with the correct location,
A
,
B
or
C
.
Write the correct letter,
A
,
B
or
C
, in boxes 9-13 on your answer sheet.
NB
You may use any letter more than once.
List of Locations
A
Hacienda La Pacifica
B
Santa Rosa National Park
C
Cholula Cacao Farm
9
It has seen the return of native tree species.
10
It supports only one species of native monkey.
11
Its monkey population helps the agriculture of the area.
12
It is home to populations of all three local monkey species.
13
Its landscape was altered by the construction of a transport link.

10 ____ It supports only one species of native monkey.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c9e32c0-266f-549b-be8f-28c0d033b0de', '82d6d935-f2ee-50a1-b357-431eb3100cad', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce9adc20-5fc2-5b64-816d-2bbd1795e395', '82d6d935-f2ee-50a1-b357-431eb3100cad', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc7bf1ae-cbed-5b30-a0e5-51d0ad7b810f', '82d6d935-f2ee-50a1-b357-431eb3100cad', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('06469c48-05ea-5583-89d8-d29a345dc86a', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

QUESTIONS 9-13
QUESTIONS 9-13
Look at the following features (Questions 9-13) and the list of locations below.
Match each feature with the correct location,
A
,
B
or
C
.
Write the correct letter,
A
,
B
or
C
, in boxes 9-13 on your answer sheet.
NB
You may use any letter more than once.
List of Locations
A
Hacienda La Pacifica
B
Santa Rosa National Park
C
Cholula Cacao Farm
9
It has seen the return of native tree species.
10
It supports only one species of native monkey.
11
Its monkey population helps the agriculture of the area.
12
It is home to populations of all three local monkey species.
13
Its landscape was altered by the construction of a transport link.

11 ____ Its monkey population helps the agriculture of the area.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbe64de0-4295-5944-8771-4d8e518b5648', '06469c48-05ea-5583-89d8-d29a345dc86a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('861b0a3a-7e74-539e-a8bc-ec485d5c6fab', '06469c48-05ea-5583-89d8-d29a345dc86a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cac903fb-deb3-538f-b966-5b511d5e26a1', '06469c48-05ea-5583-89d8-d29a345dc86a', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a353e401-64c4-5ee5-88c5-b898196a2ab8', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

QUESTIONS 9-13
QUESTIONS 9-13
Look at the following features (Questions 9-13) and the list of locations below.
Match each feature with the correct location,
A
,
B
or
C
.
Write the correct letter,
A
,
B
or
C
, in boxes 9-13 on your answer sheet.
NB
You may use any letter more than once.
List of Locations
A
Hacienda La Pacifica
B
Santa Rosa National Park
C
Cholula Cacao Farm
9
It has seen the return of native tree species.
10
It supports only one species of native monkey.
11
Its monkey population helps the agriculture of the area.
12
It is home to populations of all three local monkey species.
13
Its landscape was altered by the construction of a transport link.

12 ____ It is home to populations of all three local monkey species.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a2f7d99-78f2-50d1-93e2-45c41c749b08', 'a353e401-64c4-5ee5-88c5-b898196a2ab8', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e8f660b-2038-56cb-bab5-8b8faff8fe63', 'a353e401-64c4-5ee5-88c5-b898196a2ab8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f00a3a36-b03b-5eeb-8cc5-8838247a8c20', 'a353e401-64c4-5ee5-88c5-b898196a2ab8', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f7b74aed-e60f-51f5-bdf5-d2c52eab7942', 'f5d10cd5-6d57-5cf8-b300-35339cda6589', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

QUESTIONS 9-13
QUESTIONS 9-13
Look at the following features (Questions 9-13) and the list of locations below.
Match each feature with the correct location,
A
,
B
or
C
.
Write the correct letter,
A
,
B
or
C
, in boxes 9-13 on your answer sheet.
NB
You may use any letter more than once.
List of Locations
A
Hacienda La Pacifica
B
Santa Rosa National Park
C
Cholula Cacao Farm
9
It has seen the return of native tree species.
10
It supports only one species of native monkey.
11
Its monkey population helps the agriculture of the area.
12
It is home to populations of all three local monkey species.
13
Its landscape was altered by the construction of a transport link.

13 ____ Its landscape was altered by the construction of a transport link.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71c05b37-45e0-5759-8e70-2ebacf10e955', 'f7b74aed-e60f-51f5-bdf5-d2c52eab7942', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e02aa75-c5e1-58fc-b86a-b0e431e0d5ae', 'f7b74aed-e60f-51f5-bdf5-d2c52eab7942', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28cae8f9-5069-52c7-9280-ca83587c7a2a', 'f7b74aed-e60f-51f5-bdf5-d2c52eab7942', 3, $md$C$md$, false);

COMMIT;
