BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-reclaiming-the-future-of-aral-sea-1481'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-reclaiming-the-future-of-aral-sea-1481';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-reclaiming-the-future-of-aral-sea-1481';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-reclaiming-the-future-of-aral-sea-1481';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('98532354-6021-5a21-bf92-8d961e4e810e', 'ielts-reading-reclaiming-the-future-of-aral-sea-1481', $t$Reclaiming the future of aral sea$t$, $md$## Reclaiming the future of aral sea

Nguồn:
- Test: https://mini-ielts.com/1481/reading/reclaiming-the-future-of-aral-sea
- Solution: https://mini-ielts.com/1481/view-solution/reading/reclaiming-the-future-of-aral-sea$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', '98532354-6021-5a21-bf92-8d961e4e810e', 1, $t$Reading — Reclaiming the future of aral sea$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Reclaiming the future of aral sea

A The Aral Sea gets almost all its water from the Amu and Syr rivers. Over millennium the Amu’s course has drifted away from the sea, causing it to shrink. But the lake always rebounded as the Amu shifted back again. Today heavy irrigation for crops such as cotton and rice siphons off much of the two rivers, severely cutting flow into their deltas and thus into the sea. Evaporation vastly outpaces any rainfall, snowmelt or groundwater supply, reducing water volume and raising salinity. The Soviet Union hid the sea’s demise for decades until 1985, when leader Mikhail Gorbachev revealed the great environmental and human tragedy. By the late 1980s the sea’s level had dropped so much that the water had separated into two distinct bodies: the Small Aral (north) and the Large Aral (south). By 2007 the south had split into a deep western basin, a shallow eastern basin and a small, isolated gulf. The Large Aral’s volume had dropped from 708 to only 75 cubic kilometers (km3), and salinity had risen from 14 to more than 100 grams per liter (g/1). The 1991 dissolution of the Soviet Union divided the lake between newly formed Kazakhstan and Uzbekistan, ending a grand Soviet plan to channel in water from distant Siberian rivers and establishing competition for the dwindling resource.

B Desiccation of the Aral Sea has wrought severe consequences. Greatly reduced river flows ended the spring floods that sustained wetlands with freshwater and enriched sediment. Fish species in the lakes dropped from 32 to 6 because of rising salinity and loss of spawning and feeding grounds (most survived in the river deltas). Commercial fisheries, which caught 40,000 metric tons of fish in 1960, were gone by the mid-1980s; more than 60,000 related jobs were lost. The most common remaining lake occupant was the Black Sea flounder, a saltwater fish introduced in the 1970s, but by 2003 it had disappeared from the southern lakes because salinity was more than 70 g/1, double that of a typical ocean. Shipping on the Aral also ceased because the water receded many kilometers from the major ports of Aralsk to the north and Moynak in the south; keeping increasingly long channels open to the cities became too costly. Groundwater levels dropped with falling lake levels, intensifying desertification.

C The receding sea has exposed and dried 54,000 square kilometers of seabed, which is choked with salt and in some places laced with pesticides and other agricultural chemicals deposited by runoff from area farming. Strong windstorms blow salt, dust and contaminants as far as 500 km. Winds from the north and northeast drive the most severe storms, seriously impacting the Amu delta to the south—the most densely settled and most economically and ecologically important area in the region. Afrbome sodium bicarbonate, sodium chloride and sodium sulfate kill or retard the growth of natural vegetation and crops—a cruel irony given that irrigating those crops starves the sea. Health experts say the local population suffers from high levels of respiratory illnesses, throat and esophageal cancer, and digestive disorders caused by breathing and ingesting salt-laden air and water. Liver and kidney ailments, as well as eye problems, are common. The loss of fish has also greatly reduced dietary variety, worsening malnutrition and anemia, particularly in pregnant women.

D Returning the entire Aral Sea to its 1960s state is unrealistic. The annual inflow from the Syr and Amu rivers would have to be quadrupled from the recent average of 13 km3. The only means would be to curtail irrigation, which accounts for 92 percent of water withdrawals. Yet four of the five former Soviet republics in the Aral Sea basin (Kazakhstan is the exception) intend to expand irrigation, mainly to feed growing populations. Switching to less water- intensive crops, such as replacing cotton with winter wheat, could help, but the two primary irrigating nations, Uzbekistan and Turkmenistan, intend to keep cotton to earn foreign currency. The extensive irrigation canals could be greatly improved; many are simply cuts through sand, and they allow enormous quantities of water to seep away. Modernizing the entire system could save 12 km3 a year but would cost at least $16 billion. The basin states do not have the money or the political will. Kazakhstan has nonetheless tried to partially restore the northern Aral.

E We expect salinities in the Small Aral to settle at three to 14 g/1, depending on location. At these levels many more indigenous species should return, although the saltwater kambala would disappear from most places. Further restoration is possible. For example, if irrigation improvements raised the average annual inflow from the Syr to 4.5 km3, which is entirely feasible, the lake’s level could stabilize at about 47 meters. This change would bring the shoreline to within eight kilometers of Aralsk, the former major port city, close enough to allow recovery of an earlier channel that connected the city to the receding waters. The channel would give large commercial fishing vessels access to the sea, and shipping could restart. Marshlands and fish populations would improve even more because of a further reduction in salinity. Outflow to the southern lakes could also increase, helping then restoration. Such a plan would require a much longer and higher dike, as well as reconstruction of the gate facility, and it is not clear that Kazakhstan has the means or desire to pursue it. The country is, however, now discussing more modest proposals to bring water closer to Aralsk.

F The Large Aral faces a difficult future; it continues to shrink rapidly. Only a long, narrow channel connects the shallow eastern basin and the deeper western basin, and this could close altogether. If countries along the Amu make no changes, we estimate that at current rates of groundwater in and evaporation out, an isolated eastern basin would stabilize at an area of 4,300 square kilometers (km2). But it would average only 2.5 meters deep. Salinity would exceed 100 g/1, possibly reaching 200 g/1; the only creatures that could live in it would be brine shrimp and bacteria. The western basin’s fate depends on ground- water inflow, estimates for which are uncertain. Someone has noted numerous fresh- water springs on the western cliffs. The most reliable calculations indicate that the basin would settle at about 2,100 km2. The lake would still be relatively deep, reaching 37 meters in spots, but salinity would rise well above 100 g/1.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('01d6fe98-b7f7-5456-9941-a83d1dd29e0d', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-F.
Which paragraph contains the following information?
Write the correct letter
A-F,
in boxes
1-6
on your answer sheet.
NB
You may use any letter
more than once.
1
A mission impossible
2
An extremely worrying trend for one main part of Aral Sea
3
An uncompleted project because of political reasons
4
A promising recovery in the future
5
A strongly affected populated district
6
The disclosure of a big secret

1 ____ A mission impossible$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21c1983f-b3c2-5e3a-a967-258d7cb5a0e7', '01d6fe98-b7f7-5456-9941-a83d1dd29e0d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ec972d3-fed1-5b96-98ce-ddf44f112a51', '01d6fe98-b7f7-5456-9941-a83d1dd29e0d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f58a79b-3591-5ec8-9dae-fbf5074bfa2d', '01d6fe98-b7f7-5456-9941-a83d1dd29e0d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('190d4705-27fa-5288-aec9-604a69f0acdd', '01d6fe98-b7f7-5456-9941-a83d1dd29e0d', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2d329ae-3243-5711-9b2e-91c0893208f4', '01d6fe98-b7f7-5456-9941-a83d1dd29e0d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f152d4a-1e7c-58bb-a491-8a32900abc9b', '01d6fe98-b7f7-5456-9941-a83d1dd29e0d', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eec30aa3-5116-5e75-8f7c-642181818760', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-F.
Which paragraph contains the following information?
Write the correct letter
A-F,
in boxes
1-6
on your answer sheet.
NB
You may use any letter
more than once.
1
A mission impossible
2
An extremely worrying trend for one main part of Aral Sea
3
An uncompleted project because of political reasons
4
A promising recovery in the future
5
A strongly affected populated district
6
The disclosure of a big secret

2 ____ An extremely worrying trend for one main part of Aral Sea$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f050311f-e4d2-523a-bbab-c8d9443e3874', 'eec30aa3-5116-5e75-8f7c-642181818760', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('725e17a9-9c04-5eba-b2f0-e4788a78e862', 'eec30aa3-5116-5e75-8f7c-642181818760', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4031cdfc-62e6-5d74-b2a4-575574215024', 'eec30aa3-5116-5e75-8f7c-642181818760', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03ef4636-12c3-54d7-9729-44ee2a68c605', 'eec30aa3-5116-5e75-8f7c-642181818760', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f84abb49-4650-520a-8a7c-7ce643d95d39', 'eec30aa3-5116-5e75-8f7c-642181818760', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c0156e1-cc33-5b99-a182-5495e3d7bb8b', 'eec30aa3-5116-5e75-8f7c-642181818760', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cff57d60-7b1a-59fe-b430-42f14c9de53c', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-F.
Which paragraph contains the following information?
Write the correct letter
A-F,
in boxes
1-6
on your answer sheet.
NB
You may use any letter
more than once.
1
A mission impossible
2
An extremely worrying trend for one main part of Aral Sea
3
An uncompleted project because of political reasons
4
A promising recovery in the future
5
A strongly affected populated district
6
The disclosure of a big secret

3 ____ An uncompleted project because of political reasons$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bb7e793-3e89-5499-a1a1-aad44a89b601', 'cff57d60-7b1a-59fe-b430-42f14c9de53c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('179645dc-7386-5b87-b97f-22d3574e97bb', 'cff57d60-7b1a-59fe-b430-42f14c9de53c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d42b1883-aefe-53a3-bbf1-167ea602a569', 'cff57d60-7b1a-59fe-b430-42f14c9de53c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f00fde5-7af1-5a34-899c-6ee3a3c192a7', 'cff57d60-7b1a-59fe-b430-42f14c9de53c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eaa388f6-2375-5bf2-8ddd-8c569f46b115', 'cff57d60-7b1a-59fe-b430-42f14c9de53c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c0238b1-533d-579e-a9fb-d17d89488bbb', 'cff57d60-7b1a-59fe-b430-42f14c9de53c', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('30b56446-be43-5e83-bcd1-c5ada7f2c8fb', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-F.
Which paragraph contains the following information?
Write the correct letter
A-F,
in boxes
1-6
on your answer sheet.
NB
You may use any letter
more than once.
1
A mission impossible
2
An extremely worrying trend for one main part of Aral Sea
3
An uncompleted project because of political reasons
4
A promising recovery in the future
5
A strongly affected populated district
6
The disclosure of a big secret

4 ____ A promising recovery in the future$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05622dbf-2113-5418-ae3a-47e75a91fd49', '30b56446-be43-5e83-bcd1-c5ada7f2c8fb', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3d5595d-cfec-55e9-b5cb-9972d1c84c6d', '30b56446-be43-5e83-bcd1-c5ada7f2c8fb', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a39fd69a-6859-58d1-8005-ebdd3bfdd05d', '30b56446-be43-5e83-bcd1-c5ada7f2c8fb', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0e106f6-614e-553e-86aa-21a0ad3ab36e', '30b56446-be43-5e83-bcd1-c5ada7f2c8fb', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71a02d28-9fac-5e66-892a-2f936e481e10', '30b56446-be43-5e83-bcd1-c5ada7f2c8fb', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('226e9a57-8899-5be2-a33a-5555db3db161', '30b56446-be43-5e83-bcd1-c5ada7f2c8fb', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f58fe742-6cc6-5fc8-8193-2da5d0f7fb47', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-F.
Which paragraph contains the following information?
Write the correct letter
A-F,
in boxes
1-6
on your answer sheet.
NB
You may use any letter
more than once.
1
A mission impossible
2
An extremely worrying trend for one main part of Aral Sea
3
An uncompleted project because of political reasons
4
A promising recovery in the future
5
A strongly affected populated district
6
The disclosure of a big secret

5 ____ A strongly affected populated district$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e84525d8-5f16-5d25-a88e-d72b8462bd2e', 'f58fe742-6cc6-5fc8-8193-2da5d0f7fb47', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b332ffb9-515c-547c-b0e7-8dfd21ac5b14', 'f58fe742-6cc6-5fc8-8193-2da5d0f7fb47', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1223b5ae-71f7-5fdb-8316-659cace39248', 'f58fe742-6cc6-5fc8-8193-2da5d0f7fb47', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02b369b3-4e3d-54ae-a2be-ad9473ca5567', 'f58fe742-6cc6-5fc8-8193-2da5d0f7fb47', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2aeac5f-b976-5d7a-8d44-a40cd928f8a3', 'f58fe742-6cc6-5fc8-8193-2da5d0f7fb47', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('681be926-72c3-5b0f-8169-5244de8b4cbe', 'f58fe742-6cc6-5fc8-8193-2da5d0f7fb47', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('981b2198-a6bc-5368-bd1e-b2aa795c9c97', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-F.
Which paragraph contains the following information?
Write the correct letter
A-F,
in boxes
1-6
on your answer sheet.
NB
You may use any letter
more than once.
1
A mission impossible
2
An extremely worrying trend for one main part of Aral Sea
3
An uncompleted project because of political reasons
4
A promising recovery in the future
5
A strongly affected populated district
6
The disclosure of a big secret

6 ____ The disclosure of a big secret$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c74b8182-9782-5849-9e21-6fb2dfb1850e', '981b2198-a6bc-5368-bd1e-b2aa795c9c97', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71055dc3-2fe3-5935-843f-cb06af910595', '981b2198-a6bc-5368-bd1e-b2aa795c9c97', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14035c31-b378-5876-8b49-a74fbe2cbc1c', '981b2198-a6bc-5368-bd1e-b2aa795c9c97', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3255d077-bbac-518d-bd9c-8341d69e3f2d', '981b2198-a6bc-5368-bd1e-b2aa795c9c97', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77d6e5eb-05ea-5c5f-8637-fa66788f7cdd', '981b2198-a6bc-5368-bd1e-b2aa795c9c97', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b8c7926-afda-5ff8-8cdd-49ec6192004a', '981b2198-a6bc-5368-bd1e-b2aa795c9c97', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0d4767f7-a384-5134-9c95-3babd04c10b8', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage
?
In boxes 7-9 on your answer sheet, write
TRUE if the statement is true
FALSE if the statement is false
NOT GIVEN if the information is not given in the passage
7
In response to the increasingly growing number in the population, not all nations near the Aral Sea consider plans which will enhance the severity of the problems the Aral Sea is faced with.
8
The willingness for Kazakhstan to take the restoration action to save the Small Aral Sea is somehow not certain.
9
The western basin seems to have a destined future regardless of the influx of the groundwater.

7 ____ In response to the increasingly growing number in the population, not all nations near the Aral Sea consider plans which will enhance the severity of the problems the Aral Sea is faced with.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cbfad58-7bea-5103-bedb-4b48aa715258', '0d4767f7-a384-5134-9c95-3babd04c10b8', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c9a30b9-22ff-5ed4-85fe-fa4a50f7ebf7', '0d4767f7-a384-5134-9c95-3babd04c10b8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2060bd33-e9b7-5803-9b80-b9727ea7ae3a', '0d4767f7-a384-5134-9c95-3babd04c10b8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c4df7635-a436-5761-aa0b-c8c095f0ba53', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage
?
In boxes 7-9 on your answer sheet, write
TRUE if the statement is true
FALSE if the statement is false
NOT GIVEN if the information is not given in the passage
7
In response to the increasingly growing number in the population, not all nations near the Aral Sea consider plans which will enhance the severity of the problems the Aral Sea is faced with.
8
The willingness for Kazakhstan to take the restoration action to save the Small Aral Sea is somehow not certain.
9
The western basin seems to have a destined future regardless of the influx of the groundwater.

8 ____ The willingness for Kazakhstan to take the restoration action to save the Small Aral Sea is somehow not certain.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f9e89ca-34b5-52f9-85ce-4b1d5fc3afba', 'c4df7635-a436-5761-aa0b-c8c095f0ba53', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cdaebfb-ca42-58c9-986d-3dd6ac7cc80a', 'c4df7635-a436-5761-aa0b-c8c095f0ba53', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df5a3b13-4ce4-59ad-80e4-77940c56e439', 'c4df7635-a436-5761-aa0b-c8c095f0ba53', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c88e2aa5-f04e-5793-ab4c-8aa4c5551200', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage
?
In boxes 7-9 on your answer sheet, write
TRUE if the statement is true
FALSE if the statement is false
NOT GIVEN if the information is not given in the passage
7
In response to the increasingly growing number in the population, not all nations near the Aral Sea consider plans which will enhance the severity of the problems the Aral Sea is faced with.
8
The willingness for Kazakhstan to take the restoration action to save the Small Aral Sea is somehow not certain.
9
The western basin seems to have a destined future regardless of the influx of the groundwater.

9 ____ The western basin seems to have a destined future regardless of the influx of the groundwater.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da5f02ac-5af8-5fc9-afd5-257254c9c6b1', 'c88e2aa5-f04e-5793-ab4c-8aa4c5551200', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2e28746-4096-5c94-9db6-6c4c5bbd28be', 'c88e2aa5-f04e-5793-ab4c-8aa4c5551200', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf61625c-9533-5f7a-8221-d9b2707c2ccc', 'c88e2aa5-f04e-5793-ab4c-8aa4c5551200', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3662edd1-cf82-50ee-aaf7-299af6bec6b4', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three
words
from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
The
10
produced by the floodwaters, which were ceased because of the decrease in
11
of the Aral Sea, are main sources to keep the survival of the wetlands. The types of fishes living in it experienced a devastating tragedy out of the increase in
12
and decrease in spots for
13
with a good example of the extinction of a specific fish. What is more, fisheries and shipping suffered greatly from these vast changes.

The 10 ____ produced by the floodwaters, which were ceased because of the decrease in 11 ____ of the Aral Sea, are main sources to keep the survival of the wetlands. The types of fishes living in it experienced a devastating tragedy out of the increase in 12 ____ and decrease in spots for 13 ____ with a good example of the extinction of a specific fish. What is more, fisheries and shipping suffered greatly from these vast changes.$md$, NULL, ARRAY['.*freshwater.*and.*sediment.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4cfa379c-6bd3-597d-82e6-61f712212896', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three
words
from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
The
10
produced by the floodwaters, which were ceased because of the decrease in
11
of the Aral Sea, are main sources to keep the survival of the wetlands. The types of fishes living in it experienced a devastating tragedy out of the increase in
12
and decrease in spots for
13
with a good example of the extinction of a specific fish. What is more, fisheries and shipping suffered greatly from these vast changes.

The 10 ____ produced by the floodwaters, which were ceased because of the decrease in 11 ____ of the Aral Sea, are main sources to keep the survival of the wetlands. The types of fishes living in it experienced a devastating tragedy out of the increase in 12 ____ and decrease in spots for 13 ____ with a good example of the extinction of a specific fish. What is more, fisheries and shipping suffered greatly from these vast changes.$md$, NULL, ARRAY['.*freshwater.*and.*sediment.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b4fffe7d-befa-5c48-94a5-6f70e03049ff', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three
words
from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
The
10
produced by the floodwaters, which were ceased because of the decrease in
11
of the Aral Sea, are main sources to keep the survival of the wetlands. The types of fishes living in it experienced a devastating tragedy out of the increase in
12
and decrease in spots for
13
with a good example of the extinction of a specific fish. What is more, fisheries and shipping suffered greatly from these vast changes.

The 10 ____ produced by the floodwaters, which were ceased because of the decrease in 11 ____ of the Aral Sea, are main sources to keep the survival of the wetlands. The types of fishes living in it experienced a devastating tragedy out of the increase in 12 ____ and decrease in spots for 13 ____ with a good example of the extinction of a specific fish. What is more, fisheries and shipping suffered greatly from these vast changes.$md$, NULL, ARRAY['.*freshwater.*and.*sediment.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('393f3384-4085-5b44-892a-bb73673a05d4', '13b8ff9f-29a4-5d58-bc4e-3cc2cd46fa4d', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three
words
from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
The
10
produced by the floodwaters, which were ceased because of the decrease in
11
of the Aral Sea, are main sources to keep the survival of the wetlands. The types of fishes living in it experienced a devastating tragedy out of the increase in
12
and decrease in spots for
13
with a good example of the extinction of a specific fish. What is more, fisheries and shipping suffered greatly from these vast changes.

The 10 ____ produced by the floodwaters, which were ceased because of the decrease in 11 ____ of the Aral Sea, are main sources to keep the survival of the wetlands. The types of fishes living in it experienced a devastating tragedy out of the increase in 12 ____ and decrease in spots for 13 ____ with a good example of the extinction of a specific fish. What is more, fisheries and shipping suffered greatly from these vast changes.$md$, NULL, ARRAY['.*freshwater.*and.*sediment.*']);

COMMIT;
