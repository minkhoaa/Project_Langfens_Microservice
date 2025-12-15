BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-ant-and-the-mandarin-1056'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-ant-and-the-mandarin-1056';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-ant-and-the-mandarin-1056';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-ant-and-the-mandarin-1056';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4f529a01-8463-50bd-a7d8-5d7122e3edad', 'ielts-reading-the-ant-and-the-mandarin-1056', $t$The Ant and the Mandarin$t$, $md$## The Ant and the Mandarin

Nguồn:
- Test: https://mini-ielts.com/1056/reading/the-ant-and-the-mandarin
- Solution: https://mini-ielts.com/1056/view-solution/reading/the-ant-and-the-mandarin$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3c3bc4ab-ab3a-5d82-8399-527df17cd722', '4f529a01-8463-50bd-a7d8-5d7122e3edad', 1, $t$Reading — The Ant and the Mandarin$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Ant and the Mandarin

In 1476, the farmers of Berne in Switzerland decided there was only one way to rid their fields of the cutworms attacking their crops. They took the pests to court. The worms were tried, found guilty and excommunicated by the arch­bishop. In China, farmers had a more practical approach to pest control. Rather than relying on divine intervention, they put their faith in frogs, ducks and ants. Frogs and ducks were encouraged to snap up the pests in the paddies and the occasional plague of locusts. But the notion of biological control began with an ant. More specifically, it started with the predatory yellow citrus ant Oeco-phylla smaragdina, which has been polishing off pests in the orange groves of southern China for at least 1,700 years. The yellow citrus ant is a type of weaver ant, which binds leaves and twigs with silk to form a neat, tent-like nest. In the beginning, farmers made do with the odd ants' nests here and there. But it wasn't long before growing demand led to the development of a thriving trade in nests and a new type of agriculture - ant farming.

For an insect that bites, the yellow citrus ant is remarkably popular. Even by ant standards, Oecophylla smaragdina is a fearsome predator. It's big, runs fast and has a powerful nip - painful to humans but lethal to many of the insects that plague the orange groves of Guangdong and Guangxi in southern China. And for at least 17 centuries, Chinese orange growers have harnessed these six-legged killing machines to keep their fruit groves healthy and productive.

Citrus fruits evolved in the Far East and the Chinese discovered the delights of their flesh early on. As the ancestral home of oranges, lemons and pomelos, China also has the greatest diversity of citrus pests . And the trees that produce the sweetest fruits, the mandarins - or kan - attract a host of plant-eating in­sects, from black ants and sap-sucking mealy bugs to leaf-devouring caterpil­lars. With so many enemies, fruit growers clearly had to have some way of pro­tecting their orchards.

The West did not discover the Chinese orange growers' secret weapon until 1 the early 20th century. At the time, Florida was suffering an epidemic of citrus canker and in 1915 Walter Swingle, a plant physiologist working for the US Department of Agriculture, was sent to China in search of varieties of orange that were resistant to the disease . Swingle spent some time studying the citrus orchards around Guangzhou, and there he came across the story of the culti­vated ant. These ants, he was told, were "grown'' by the people of a small village nearby who sold them to the orange growers by the nestful.

The earliest report of citrus ants at work among the orange trees appeared in a book on tropical and subtropical botany written by Hsi Han in AD 304 . "The people of Chiao-Chih sell in their markets ants in bags of rush matting. The nests are like silk. The bags are all attached to twigs and leaves which, with the i ants inside the nests, are for sale. The ants are reddish-yellow in colour, bigger than ordinary ants. In the south, if the kan trees do not have this kind of ant, the fruits will all be damaged by many harmful insects, and not a single fruit will be perfect."

Initially, farmers relied on nests which they collected from the wild or bought in the market where trade in nests was brisk. "It is said that in the south orange trees which are free of ants will have wormy fruits. Therefore, people race to buy nests for their orange trees," wrote Liu Hsun in Strange Things Noted in the South in about 890.

The business guickly became more sophisticated. From the 10th century, coun­try people began to trap ants in artificial nests baited with fat. "Fruit-growing families buy these ants from vendors who make a business of collecting and selling such creatures," wrote Chuang Chi-Yu in 1130. "They trap them by fill­ing hogs' or sheep's bladders with fat and placing them with the cavities open next to the ants' nests. They wait until the ants have migrated into the bladders and take them away. This is known as 'rearing orange ants'." Farmers attached k the bladders to their trees, and in time the ants spread to other trees and built new nests.

By the 17th century, growers were building bamboo walkways between their trees to speed the colonisation of their orchards. The ants ran along these narrow bridges from one tree to another and established nests "by the hundreds of thousands”.

Did it work? The orange growers clearly thought so. One authority, Chhii Ta-Chun, writing in 1700, stressed how important it was to keep the fruit trees free of insect pests, especially caterpillars. "It is essential to eliminate them so that the trees are not injured. But hand labour is not nearly as efficient as ant power..."

Swingle was just as impressed. Yet despite his reports, many Western biologists were sceptical . In the West, the idea of using one insect to destroy another was new and highly controversial. The first breakthrough had come in 1888 , when the infant orange industry in California had been saved from extinction by the Australian vedalia beetle. This beetle was the only thing that had made any in- T roads into the explosion of cottony cushion scale that was threatening to destroy the state's citrus crops. But, as Swingle now knew, California's "first'' was noth­ing of the sort. The Chinese had been expert in biocontrol for many centuries.

The long tradition of ants in the Chinese orchards only began to waver in the 1950s and 1960s with the introduction of powerful organic insecticides. Although most fruit growers switched to chemicals, a few hung onto their ants. Those who abandoned ants in favour of chemicals quickly became disillusioned. As costs soared and pests began to develop resistance to the chem­icals, growers began to revive the old ant patrols in the late 1960s . They had good reason to have faith in their insect workforce.

Research in the early 1960s showed that as long as there were enough ants in the trees, they did an excellent job of dispatching some pests - mainly the larger insects - and had modest success against others. Trees with yellow ants produced almost 20 per cent more healthy leaves than those without . More recent trials have shown that these trees yield just as big a crop as those protected by expensive chemical sprays .

One apparent drawback of using ants - and one of the main reasons for the early scepticism by Western scientists - was that citrus ants do nothing to control mealy bugs, waxy-coated scale insects which can do considerable damage to fruit trees. In fact, the ants protect mealy bugs in exchange for the sweet honey-dew they secrete. The orange growers always denied this was a problem but Western scientists thought they knew better.

Research in the 1980s suggests that the growers were right all along. Where X mealy bugs proliferate under the ants' protection, they are usually heavily parasitised and this limits the harm they can do.

Orange growers who rely on carnivorous ants rather than poisonous chemicals maintain a better balance of species in their orchards. While the ants deal with the bigger insect pests, other predatory species keep down the numbers of smaller pests such as scale insects and aphids. In the long run, ants do a lot less damage than chemicals - and they're certainly more effective than excommunication .

----------

Great thanks to volunteer Ngoc Nguyen has contributed these explanations and question markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b943c940-029c-570e-955f-2076104e7b30', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Look at the following events (Questions
1-5
) and the list of dates below.
Match each event with the correct time
A-G
.
Write the correct letter
A-G
in boxes
1-5
on your answer sheet.
1
The first description of citrus ants is traded in the marketplace.
Locate
2
Swingle came to Asia for research.
Locate
3
The first record of one insect is used to tackle other insects in the western world.
Locate
4
Chinese fruit growers started to use pesticides in place of citrus ants.
Locate
5
Some Chinese farmers returned to the traditional bio-method
Locate
List of Dates
A
1888
B
AD 890
C
AD 304
D
1950s
E
1960s
F
1915
G
1130

1 ____ The first description of citrus ants is traded in the marketplace. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acb95dc4-bbc4-53e3-a04b-a048a512aecb', 'b943c940-029c-570e-955f-2076104e7b30', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e629a08e-1cb9-5fae-8b2a-1367f572a250', 'b943c940-029c-570e-955f-2076104e7b30', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d17ee6dd-e19d-590a-8999-387c08f75615', 'b943c940-029c-570e-955f-2076104e7b30', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99fa68da-7f3c-5738-9331-dfb38573d09b', 'b943c940-029c-570e-955f-2076104e7b30', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de4ccc61-1fee-50f5-851f-966dc372651b', 'b943c940-029c-570e-955f-2076104e7b30', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77a4c5e8-8825-5045-8628-8121b102674b', 'b943c940-029c-570e-955f-2076104e7b30', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d95e583-291d-553a-b919-499a795f6e5b', 'b943c940-029c-570e-955f-2076104e7b30', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('15f4f927-29a1-5771-8df6-37199da5638e', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Look at the following events (Questions
1-5
) and the list of dates below.
Match each event with the correct time
A-G
.
Write the correct letter
A-G
in boxes
1-5
on your answer sheet.
1
The first description of citrus ants is traded in the marketplace.
Locate
2
Swingle came to Asia for research.
Locate
3
The first record of one insect is used to tackle other insects in the western world.
Locate
4
Chinese fruit growers started to use pesticides in place of citrus ants.
Locate
5
Some Chinese farmers returned to the traditional bio-method
Locate
List of Dates
A
1888
B
AD 890
C
AD 304
D
1950s
E
1960s
F
1915
G
1130

2 ____ Swingle came to Asia for research. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b119c3a-aa3b-530b-9046-5b8c625b1eff', '15f4f927-29a1-5771-8df6-37199da5638e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8775351b-e5c5-501b-a2bd-f933c35b4196', '15f4f927-29a1-5771-8df6-37199da5638e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f42b3ee-7775-5840-a8ba-116499320973', '15f4f927-29a1-5771-8df6-37199da5638e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5139e0fb-7d65-5c35-872f-40e4f109d9f0', '15f4f927-29a1-5771-8df6-37199da5638e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5046340e-fc54-55d4-9e7d-aa86875874f9', '15f4f927-29a1-5771-8df6-37199da5638e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00a17a73-69fb-5a3b-805d-0fcfd4ccd4f1', '15f4f927-29a1-5771-8df6-37199da5638e', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1ba7f50-9b32-5049-9dbe-118497ef4e09', '15f4f927-29a1-5771-8df6-37199da5638e', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0fd9cf08-5667-5fda-ba26-0051b97a8ba6', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Look at the following events (Questions
1-5
) and the list of dates below.
Match each event with the correct time
A-G
.
Write the correct letter
A-G
in boxes
1-5
on your answer sheet.
1
The first description of citrus ants is traded in the marketplace.
Locate
2
Swingle came to Asia for research.
Locate
3
The first record of one insect is used to tackle other insects in the western world.
Locate
4
Chinese fruit growers started to use pesticides in place of citrus ants.
Locate
5
Some Chinese farmers returned to the traditional bio-method
Locate
List of Dates
A
1888
B
AD 890
C
AD 304
D
1950s
E
1960s
F
1915
G
1130

3 ____ The first record of one insect is used to tackle other insects in the western world. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dda06cbd-d27f-51f2-a697-3e24c3a5f191', '0fd9cf08-5667-5fda-ba26-0051b97a8ba6', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ccb1509e-5c4d-526f-be79-28ef3502797b', '0fd9cf08-5667-5fda-ba26-0051b97a8ba6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b0ad155-ce23-55d6-9ac2-395a628035ca', '0fd9cf08-5667-5fda-ba26-0051b97a8ba6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6dd6c412-f3ee-5897-a401-f2160faf2dbd', '0fd9cf08-5667-5fda-ba26-0051b97a8ba6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e54bff6-4356-520f-a913-48943d5cb52d', '0fd9cf08-5667-5fda-ba26-0051b97a8ba6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('985ab83b-6cd0-5ed7-a07b-4a2dd50f08a7', '0fd9cf08-5667-5fda-ba26-0051b97a8ba6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6dfc232d-20d3-5df7-8f56-ba5e13578e33', '0fd9cf08-5667-5fda-ba26-0051b97a8ba6', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8dbd53b-bfaa-514b-a994-19b0f43f62be', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Look at the following events (Questions
1-5
) and the list of dates below.
Match each event with the correct time
A-G
.
Write the correct letter
A-G
in boxes
1-5
on your answer sheet.
1
The first description of citrus ants is traded in the marketplace.
Locate
2
Swingle came to Asia for research.
Locate
3
The first record of one insect is used to tackle other insects in the western world.
Locate
4
Chinese fruit growers started to use pesticides in place of citrus ants.
Locate
5
Some Chinese farmers returned to the traditional bio-method
Locate
List of Dates
A
1888
B
AD 890
C
AD 304
D
1950s
E
1960s
F
1915
G
1130

4 ____ Chinese fruit growers started to use pesticides in place of citrus ants. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdb443d1-6456-5a2e-b703-6781ea5d85dd', 'd8dbd53b-bfaa-514b-a994-19b0f43f62be', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62d6e538-d134-555a-a717-7f46c3d99efb', 'd8dbd53b-bfaa-514b-a994-19b0f43f62be', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ae9daf2-8a48-506f-aabc-c2d65316aebd', 'd8dbd53b-bfaa-514b-a994-19b0f43f62be', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da374b1e-4e65-5681-99a9-ee788ce5b944', 'd8dbd53b-bfaa-514b-a994-19b0f43f62be', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('997f3a45-2214-5840-b758-d78d703befe5', 'd8dbd53b-bfaa-514b-a994-19b0f43f62be', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b9576db-a12e-53c5-915c-11cfbc4a9121', 'd8dbd53b-bfaa-514b-a994-19b0f43f62be', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d422aaf6-126a-5fbf-afa8-f62059399481', 'd8dbd53b-bfaa-514b-a994-19b0f43f62be', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7b09d030-51f0-561b-897e-b4e40f55d7a6', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Look at the following events (Questions
1-5
) and the list of dates below.
Match each event with the correct time
A-G
.
Write the correct letter
A-G
in boxes
1-5
on your answer sheet.
1
The first description of citrus ants is traded in the marketplace.
Locate
2
Swingle came to Asia for research.
Locate
3
The first record of one insect is used to tackle other insects in the western world.
Locate
4
Chinese fruit growers started to use pesticides in place of citrus ants.
Locate
5
Some Chinese farmers returned to the traditional bio-method
Locate
List of Dates
A
1888
B
AD 890
C
AD 304
D
1950s
E
1960s
F
1915
G
1130

5 ____ Some Chinese farmers returned to the traditional bio-method Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01854c8e-bdca-5f7e-ab97-e42ca2a4a284', '7b09d030-51f0-561b-897e-b4e40f55d7a6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc32abc1-fe1f-5ed0-a674-4bff1c54c846', '7b09d030-51f0-561b-897e-b4e40f55d7a6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c3a5548-f6e8-5917-98b8-702a6db770d1', '7b09d030-51f0-561b-897e-b4e40f55d7a6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c98da05f-1bd3-53d5-914b-c3b891293ca0', '7b09d030-51f0-561b-897e-b4e40f55d7a6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('074e118a-ca92-5a85-9338-c5670689f856', '7b09d030-51f0-561b-897e-b4e40f55d7a6', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c9370f7-7332-5a4c-b0cc-21abd60b2e71', '7b09d030-51f0-561b-897e-b4e40f55d7a6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d93f3653-93f1-5d0f-a75b-20aeaeac09e7', '7b09d030-51f0-561b-897e-b4e40f55d7a6', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9f6173a7-f69e-5456-b30d-64bf340092a7', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-13
Questions 6-13
Do the following statements agree with the information given in Reading Passage?
In boxes
6-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
China has more citrus pests than any other country in the world.
Locate
7
Swingle came to China to search for an insect to bring back to the US.
Locate
8
Many people were very impressed by Swingle's discovery.
Locate
9
Chinese farmers found that pesticides became increasingly expensive.
Locate
10
Some Chinese farmers abandoned the use of pesticide.
Locate
11
Trees with ants had more leaves fall than those without.
Locate
12
Fields using ants yield as large a crop as fields using chemical pesticides.
Locate
13
Citrus ants often cause considerable damage to the bio-environment of the orchards.
Locate

6 ____ China has more citrus pests than any other country in the world. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4fbac660-de36-57cc-a36f-0dd44b194ae0', '9f6173a7-f69e-5456-b30d-64bf340092a7', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9dfda1a-6e1d-51fc-b651-fc61dd705881', '9f6173a7-f69e-5456-b30d-64bf340092a7', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('367f0af0-c4b6-5905-a43b-e8b10f421894', '9f6173a7-f69e-5456-b30d-64bf340092a7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c0bdf54b-75cb-5309-8e69-49fe9b38d585', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-13
Questions 6-13
Do the following statements agree with the information given in Reading Passage?
In boxes
6-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
China has more citrus pests than any other country in the world.
Locate
7
Swingle came to China to search for an insect to bring back to the US.
Locate
8
Many people were very impressed by Swingle's discovery.
Locate
9
Chinese farmers found that pesticides became increasingly expensive.
Locate
10
Some Chinese farmers abandoned the use of pesticide.
Locate
11
Trees with ants had more leaves fall than those without.
Locate
12
Fields using ants yield as large a crop as fields using chemical pesticides.
Locate
13
Citrus ants often cause considerable damage to the bio-environment of the orchards.
Locate

7 ____ Swingle came to China to search for an insect to bring back to the US. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85b0f03f-7d6e-5020-b74a-63386da9de8b', 'c0bdf54b-75cb-5309-8e69-49fe9b38d585', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77f6bb2c-01f3-5020-b07f-24a9997b6477', 'c0bdf54b-75cb-5309-8e69-49fe9b38d585', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85465ff4-83e0-537f-95a0-f6c5b5c72bee', 'c0bdf54b-75cb-5309-8e69-49fe9b38d585', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('99d74c92-4036-5bc3-90fe-07b76f517119', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-13
Questions 6-13
Do the following statements agree with the information given in Reading Passage?
In boxes
6-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
China has more citrus pests than any other country in the world.
Locate
7
Swingle came to China to search for an insect to bring back to the US.
Locate
8
Many people were very impressed by Swingle's discovery.
Locate
9
Chinese farmers found that pesticides became increasingly expensive.
Locate
10
Some Chinese farmers abandoned the use of pesticide.
Locate
11
Trees with ants had more leaves fall than those without.
Locate
12
Fields using ants yield as large a crop as fields using chemical pesticides.
Locate
13
Citrus ants often cause considerable damage to the bio-environment of the orchards.
Locate

8 ____ Many people were very impressed by Swingle's discovery. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b65b6dbc-2b4e-5357-aeb3-122ce1b1a361', '99d74c92-4036-5bc3-90fe-07b76f517119', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77583790-d970-5c4a-b879-a78c12619b64', '99d74c92-4036-5bc3-90fe-07b76f517119', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6bd1d46-9ceb-5722-99d5-36ba41b4b6f9', '99d74c92-4036-5bc3-90fe-07b76f517119', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fcb96196-2598-55b9-9889-9eb8d78328a3', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-13
Questions 6-13
Do the following statements agree with the information given in Reading Passage?
In boxes
6-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
China has more citrus pests than any other country in the world.
Locate
7
Swingle came to China to search for an insect to bring back to the US.
Locate
8
Many people were very impressed by Swingle's discovery.
Locate
9
Chinese farmers found that pesticides became increasingly expensive.
Locate
10
Some Chinese farmers abandoned the use of pesticide.
Locate
11
Trees with ants had more leaves fall than those without.
Locate
12
Fields using ants yield as large a crop as fields using chemical pesticides.
Locate
13
Citrus ants often cause considerable damage to the bio-environment of the orchards.
Locate

9 ____ Chinese farmers found that pesticides became increasingly expensive. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c483030-60ac-5b7e-b5b4-302acdb92c07', 'fcb96196-2598-55b9-9889-9eb8d78328a3', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22724caf-4577-578e-91ef-22431bfe5dc2', 'fcb96196-2598-55b9-9889-9eb8d78328a3', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d629db7-d5d5-5aab-9554-51866a07e9e0', 'fcb96196-2598-55b9-9889-9eb8d78328a3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fe164746-7d4c-5a4b-bcde-92b8fa34b294', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-13
Questions 6-13
Do the following statements agree with the information given in Reading Passage?
In boxes
6-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
China has more citrus pests than any other country in the world.
Locate
7
Swingle came to China to search for an insect to bring back to the US.
Locate
8
Many people were very impressed by Swingle's discovery.
Locate
9
Chinese farmers found that pesticides became increasingly expensive.
Locate
10
Some Chinese farmers abandoned the use of pesticide.
Locate
11
Trees with ants had more leaves fall than those without.
Locate
12
Fields using ants yield as large a crop as fields using chemical pesticides.
Locate
13
Citrus ants often cause considerable damage to the bio-environment of the orchards.
Locate

10 ____ Some Chinese farmers abandoned the use of pesticide. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5616a781-bd6f-5528-9594-92c442ec340f', 'fe164746-7d4c-5a4b-bcde-92b8fa34b294', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3e3ff6c-58c9-5a51-9d3a-345832f716c4', 'fe164746-7d4c-5a4b-bcde-92b8fa34b294', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eec01018-e51e-5f94-858d-0c41fbf3325c', 'fe164746-7d4c-5a4b-bcde-92b8fa34b294', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ffb9e2ed-e53b-5341-bb3f-cc7778a9b716', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 6-13
Questions 6-13
Do the following statements agree with the information given in Reading Passage?
In boxes
6-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
China has more citrus pests than any other country in the world.
Locate
7
Swingle came to China to search for an insect to bring back to the US.
Locate
8
Many people were very impressed by Swingle's discovery.
Locate
9
Chinese farmers found that pesticides became increasingly expensive.
Locate
10
Some Chinese farmers abandoned the use of pesticide.
Locate
11
Trees with ants had more leaves fall than those without.
Locate
12
Fields using ants yield as large a crop as fields using chemical pesticides.
Locate
13
Citrus ants often cause considerable damage to the bio-environment of the orchards.
Locate

11 ____ Trees with ants had more leaves fall than those without. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0386d782-93de-5096-911c-7226a0c6079f', 'ffb9e2ed-e53b-5341-bb3f-cc7778a9b716', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('380b1f63-a5a8-5e6c-a9e8-2707c879a801', 'ffb9e2ed-e53b-5341-bb3f-cc7778a9b716', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea85cef6-ca30-5b01-aaae-e0fb6acdeb57', 'ffb9e2ed-e53b-5341-bb3f-cc7778a9b716', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2a586e21-40e9-5cc2-a753-6131faf26fe1', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 6-13
Questions 6-13
Do the following statements agree with the information given in Reading Passage?
In boxes
6-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
China has more citrus pests than any other country in the world.
Locate
7
Swingle came to China to search for an insect to bring back to the US.
Locate
8
Many people were very impressed by Swingle's discovery.
Locate
9
Chinese farmers found that pesticides became increasingly expensive.
Locate
10
Some Chinese farmers abandoned the use of pesticide.
Locate
11
Trees with ants had more leaves fall than those without.
Locate
12
Fields using ants yield as large a crop as fields using chemical pesticides.
Locate
13
Citrus ants often cause considerable damage to the bio-environment of the orchards.
Locate

12 ____ Fields using ants yield as large a crop as fields using chemical pesticides. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a29d391-8437-5ee4-826d-41065cec054a', '2a586e21-40e9-5cc2-a753-6131faf26fe1', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d382a30f-5579-5411-a796-27e43c76ee99', '2a586e21-40e9-5cc2-a753-6131faf26fe1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1de9691b-2342-59c7-b9d9-d9d2cb4d8143', '2a586e21-40e9-5cc2-a753-6131faf26fe1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fe19026a-6d03-5ee9-8d4e-3e2941aa1a9d', '3c3bc4ab-ab3a-5d82-8399-527df17cd722', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 6-13
Questions 6-13
Do the following statements agree with the information given in Reading Passage?
In boxes
6-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
China has more citrus pests than any other country in the world.
Locate
7
Swingle came to China to search for an insect to bring back to the US.
Locate
8
Many people were very impressed by Swingle's discovery.
Locate
9
Chinese farmers found that pesticides became increasingly expensive.
Locate
10
Some Chinese farmers abandoned the use of pesticide.
Locate
11
Trees with ants had more leaves fall than those without.
Locate
12
Fields using ants yield as large a crop as fields using chemical pesticides.
Locate
13
Citrus ants often cause considerable damage to the bio-environment of the orchards.
Locate

13 ____ Citrus ants often cause considerable damage to the bio-environment of the orchards. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a13db9ef-2b68-5506-9168-2ca2d97e79cd', 'fe19026a-6d03-5ee9-8d4e-3e2941aa1a9d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b4ca314-af32-50ef-a75e-ada0351dd1fa', 'fe19026a-6d03-5ee9-8d4e-3e2941aa1a9d', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('144a0894-8963-5f2f-8676-0676b8be8ee6', 'fe19026a-6d03-5ee9-8d4e-3e2941aa1a9d', 3, $md$NOT GIVEN$md$, false);

COMMIT;
