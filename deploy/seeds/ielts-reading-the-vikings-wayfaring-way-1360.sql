BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-vikings-wayfaring-way-1360'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-vikings-wayfaring-way-1360';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-vikings-wayfaring-way-1360';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-vikings-wayfaring-way-1360';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2a74b221-ac3e-5fc8-ab4b-cb367f9cef01', 'ielts-reading-the-vikings-wayfaring-way-1360', $t$The vikings wayfaring way$t$, $md$## The vikings wayfaring way

Nguồn:
- Test: https://mini-ielts.com/1360/reading/the-vikings-wayfaring-way
- Solution: https://mini-ielts.com/1360/view-solution/reading/the-vikings-wayfaring-way$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7d40c492-f869-5b9f-967d-11c0b1a8759d', '2a74b221-ac3e-5fc8-ab4b-cb367f9cef01', 1, $t$Reading — The vikings wayfaring way$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The vikings wayfaring way

In the last century, Vikings have been perceived in numerous diﬀerent ways – vilified as conquerors and romanticised as adventurers. How Vikings have been employed in nation-building is a topic of some interest.

In English, Vikings are also known as Norse or Norsemen. Their language greatly inﬂuenced English, with the nouns, ‘Hell’, ‘husband’, ‘law’, and ‘window’, and the verbs, ‘blunder’, ‘snub’, ‘take’, and ‘want’, all coming from Old Norse. However, the origins of the word ‘Viking’, itself, are obscure: it may mean ‘a Scandinavian pirate’, or it may refer to ‘an inlet’, or a place called Vik, in modem-day Norway, from where the pirates came. These various names – Vikings, Norse, or Norsemen, and doubts about the very word ‘Viking’ suggest historical confusion.

Loosely speaking, the Viking Age endured from the late eighth to the mid-eleventh centuries. Vikings sailed to England in AD 793 to storm coastal monasteries, and subsequently, large swathes of England fell under Viking rule – indeed several Viking kings sat on the English throne. It is generally agreed that the Battle of Hastings, in 1066, when the Norman French invaded, marks the end of the English Viking Age, but the Irish Viking age ended earlier, while Viking colonies in Iceland and Greenland did not dissolve until around AD 1500.

How much territory Vikings controlled is also in dispute – Scandinavia and Western Europe certainly, but their reach east and south is uncertain. They plundered and settled down the Volga and Dnieper rivers, and traded with modem-day Istanbul, but the archaeological record has yet to verify that Vikings raided as far away as Northwest Africa, as some writers claim.

The issue of control and extent is complex because many Vikings did not return to Scandinavia after raiding but assimilated into local populations, often becoming Christian. To some degree, the Viking Age is defined by religion. Initially, Vikings were polytheists, believing in many gods, but by the end of the age, they had permanently accepted a new monotheistic religious system – Christianity.

This transition from so-called pagan plunderers to civilised Christians is significant and is the view promulgated throughout much of recent history. In the UK, in the 1970s for example, schoolchildren were taught that until the Vikings accepted Christianity they were nasty heathens who rampaged throughout Britain. By contrast, today’s children can visit museums where Vikings are celebrated as merchants, pastoralists, and artists with a unique worldview as well as conquerors.

What are some other interpretations of Vikings? In the nineteenth century, historians in Denmark, Norway, and Sweden constructed their own Viking ages for nationalistic reasons. At that time, all three countries were in crisis. Denmark had been beaten in war and ceded territory to what is now Germany. Norway had become independent from Sweden in 1905 but was economically vulnerable, so Norwegians sought to create a separate identity for themselves in the past as well as the present. The Norwegian historian, Gustav Storm, was adamant it was his forebears and not the Swedes’ or Danes’ who had colonised Iceland, Greenland, and Vinland, in what is now Canada. Sweden, meanwhile, had relinquished Norway to the Norwegians and Finland to the Russians; thus, in the late nineteenth century, Sweden was keen to boost its image with rich archaeological finds to show the glory of its Viking past.

In addition to augmenting nationalism, nineteenth-century thinkers were influenced by an Englishman, Herbert Spencer, who described peoples and cultures in evolutionary terms similar to those of Charles Darwin. Spencer coined the phrase ‘survival of the fittest’, which includes the notion that, over time, there is not only technological but also moral progress. Therefore, Viking heathens’ adoption of Christianity was considered an advantageous move. These days, historians do not compare cultures in the same way, especially since, in this case, the archaeological record seems to show that heathen Vikings and Christian Europeans were equally brutal.

Views of Vikings change according to not only to forces aﬀecting historians at the time of their research but also according to the materials they read. Since much knowledge of Vikings comes from literature composed up to 300 years after the events they chronicle, some Danish historians cal1 these sources ‘mere legends’.

Vikings did have a written language carved on large stones, but as few of these survive today, the most reliable contemporary sources on Vikings come from writers from other cultures, like the ninth-century Persian geographer, Ibn Khordadbeh.

In the last four decades, there have been wildly varying interpretations of the Viking inﬂuence in Russia. Most non-Russian scholars believe the Vikings created a kingdom in western Russia and modern-day Ukraine led by a man called Rurik. After AD 862, Rurik’s descendants continued to rule. There is considerable evidence of this colonisation: in Sweden, carved stones, still standing, describe the conquerors’ journeys; both Russian and Ukrainian have loan words from Old Norse; and, Scandinavian first names, like Igor and Olga, are still popular. However, during the Soviet period, there was an emphasis on the Slavic origins of most Russians. (Appearing in the historical record around the sixth century AD, the Slavs are thought to have originated in Eastern Europe.) This Slavic identity was promoted to contrast with that of the neighbouring Viking Swedes, who were enemies during the Cold War.

These days, many Russians consider themselves hybrids. Indeed recent genetic studies support a Norse-colonisation theory: western Russian DNA is consistent with that of the inhabitants of a region north of Stockholm in Sweden.

The tools available to modern historians are many and varied, and their findings may seem less open to debate. There are linguistics, numismatics, dendrochronology, archaeozoology, palaeobotany, ice crystallography, climate and DNA analysis to add to the translation of runes and the raising of mighty warships. Despite these, historians remain children of their times.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('051bcdd2-85e3-583b-b06f-eb3e5f0f8e8a', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 1, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the notes below.
Write
NO MORE THAN TWO WORDS OR A NUMBER
for each answer
Write your answers in boxes
1-5
on your answer sheet.
Origins:
• Word ‘Viking’ is
1
• Vikings came from Scandinavia.
Dates of the Viking Age
• In Britain: AD
2
-1066
• Length varies elsewhere
Territorial extent:
• In doubt – but most of Europe
• Possibly raided as far away as
3
End of the Viking Age:
• Vikings had assimilated into
4
, & adopted a new
5
system.

• Word ‘Viking’ is 1 ____ • Vikings came from Scandinavia.$md$, NULL, ARRAY['.*obscure.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c7ddc22f-4303-5e6a-aaf4-d172f09e6cf7', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 2, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the notes below.
Write
NO MORE THAN TWO WORDS OR A NUMBER
for each answer
Write your answers in boxes
1-5
on your answer sheet.
Origins:
• Word ‘Viking’ is
1
• Vikings came from Scandinavia.
Dates of the Viking Age
• In Britain: AD
2
-1066
• Length varies elsewhere
Territorial extent:
• In doubt – but most of Europe
• Possibly raided as far away as
3
End of the Viking Age:
• Vikings had assimilated into
4
, & adopted a new
5
system.

• In Britain: AD 2 ____ -1066 • Length varies elsewhere$md$, NULL, ARRAY['.*793.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('40417a6f-1a72-5681-b625-09ce55e53051', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 3, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the notes below.
Write
NO MORE THAN TWO WORDS OR A NUMBER
for each answer
Write your answers in boxes
1-5
on your answer sheet.
Origins:
• Word ‘Viking’ is
1
• Vikings came from Scandinavia.
Dates of the Viking Age
• In Britain: AD
2
-1066
• Length varies elsewhere
Territorial extent:
• In doubt – but most of Europe
• Possibly raided as far away as
3
End of the Viking Age:
• Vikings had assimilated into
4
, & adopted a new
5
system.

• Possibly raided as far away as 3 ____$md$, NULL, ARRAY['.*northwest.*africa.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b4c7b617-5eee-5c55-8901-ab2f1518ba21', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 4, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the notes below.
Write
NO MORE THAN TWO WORDS OR A NUMBER
for each answer
Write your answers in boxes
1-5
on your answer sheet.
Origins:
• Word ‘Viking’ is
1
• Vikings came from Scandinavia.
Dates of the Viking Age
• In Britain: AD
2
-1066
• Length varies elsewhere
Territorial extent:
• In doubt – but most of Europe
• Possibly raided as far away as
3
End of the Viking Age:
• Vikings had assimilated into
4
, & adopted a new
5
system.

• Vikings had assimilated into 4 ____ , & adopted a new 5 ____ system.$md$, NULL, ARRAY['.*local.*populations.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('17271f7c-8417-567d-a098-73e852353bfb', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 5, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the notes below.
Write
NO MORE THAN TWO WORDS OR A NUMBER
for each answer
Write your answers in boxes
1-5
on your answer sheet.
Origins:
• Word ‘Viking’ is
1
• Vikings came from Scandinavia.
Dates of the Viking Age
• In Britain: AD
2
-1066
• Length varies elsewhere
Territorial extent:
• In doubt – but most of Europe
• Possibly raided as far away as
3
End of the Viking Age:
• Vikings had assimilated into
4
, & adopted a new
5
system.

• Vikings had assimilated into 4 ____ , & adopted a new 5 ____ system.$md$, NULL, ARRAY['.*local.*populations.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a915d4c2-da78-5b9b-ab6b-627fde219ed7', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-13
Questions 6-13
Look at the following statements and the list of times and places below.
Match each statement with the correct place or time:
A-H
.
Write the correct letter,
A-H
, in boxes
6-13
on your answer sheet.
6
A geographer documents Viking culture as it happens.
7
A philosopher classifies cultures hierarchically.
8
Historians assert that Viking history is based more on legends than facts.
9
Young people learn about Viking cultural and economic activities.
10
People see themselves as unrelated to Vikings.
11
An historian claims Viking colonists to modem-day Canada came from his land.
12
Viking conquests are exaggerated to bolster the country’s ego after a territorial loss.
13
DNA tests show locals are closely related to Swedes.
List of times
& places
A
In the UK today
B
In 19th-century Norway
C
In 19th-century Sweden
D
In 19th-century England
E
In Denmark today
F
In 9th-century Persia
G
In mid-20th century Soviet Union
H
In Russia today

6 ____ A geographer documents Viking culture as it happens.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f92acb04-edc7-5b8c-a800-8036796404b0', 'a915d4c2-da78-5b9b-ab6b-627fde219ed7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7b8b603-648f-5320-9891-c91735daf48d', 'a915d4c2-da78-5b9b-ab6b-627fde219ed7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a8f30da-2e1d-5cbe-bd6c-34d4439ea9c0', 'a915d4c2-da78-5b9b-ab6b-627fde219ed7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76b83993-dce3-559d-a189-8afdcb84b4a1', 'a915d4c2-da78-5b9b-ab6b-627fde219ed7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d529960-f326-5bea-8749-40f5a2ed57bc', 'a915d4c2-da78-5b9b-ab6b-627fde219ed7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61102d8c-52b9-58e4-9479-f204cedbc06a', 'a915d4c2-da78-5b9b-ab6b-627fde219ed7', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f8bcfc0-4012-5b52-a98e-bdac935cec34', 'a915d4c2-da78-5b9b-ab6b-627fde219ed7', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ea02f7a-194a-530b-b0cd-c6d425418b06', 'a915d4c2-da78-5b9b-ab6b-627fde219ed7', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dc564997-b8e1-52b0-b54f-588026e1c44d', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-13
Questions 6-13
Look at the following statements and the list of times and places below.
Match each statement with the correct place or time:
A-H
.
Write the correct letter,
A-H
, in boxes
6-13
on your answer sheet.
6
A geographer documents Viking culture as it happens.
7
A philosopher classifies cultures hierarchically.
8
Historians assert that Viking history is based more on legends than facts.
9
Young people learn about Viking cultural and economic activities.
10
People see themselves as unrelated to Vikings.
11
An historian claims Viking colonists to modem-day Canada came from his land.
12
Viking conquests are exaggerated to bolster the country’s ego after a territorial loss.
13
DNA tests show locals are closely related to Swedes.
List of times
& places
A
In the UK today
B
In 19th-century Norway
C
In 19th-century Sweden
D
In 19th-century England
E
In Denmark today
F
In 9th-century Persia
G
In mid-20th century Soviet Union
H
In Russia today

7 ____ A philosopher classifies cultures hierarchically.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e81b2a59-7763-5b2d-be31-b54b7f293b32', 'dc564997-b8e1-52b0-b54f-588026e1c44d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64ff8eac-6f24-53fb-b668-d2b8fea8eaf8', 'dc564997-b8e1-52b0-b54f-588026e1c44d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9fe2522-c1bd-509d-b99a-e04efd44d210', 'dc564997-b8e1-52b0-b54f-588026e1c44d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b92ebf3-22e9-5a47-b2aa-efa8b37a2e37', 'dc564997-b8e1-52b0-b54f-588026e1c44d', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('919b4af9-05fd-5356-a1a3-c63d29dce6ea', 'dc564997-b8e1-52b0-b54f-588026e1c44d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c927d12-3406-5404-be34-67816bd714dd', 'dc564997-b8e1-52b0-b54f-588026e1c44d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8782966-2194-5f49-8ca3-53ec3df87993', 'dc564997-b8e1-52b0-b54f-588026e1c44d', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d68fa8a-48dd-5997-a987-602f86f95806', 'dc564997-b8e1-52b0-b54f-588026e1c44d', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f8ea4479-d60d-5f6f-9e46-25a601b11ccd', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-13
Questions 6-13
Look at the following statements and the list of times and places below.
Match each statement with the correct place or time:
A-H
.
Write the correct letter,
A-H
, in boxes
6-13
on your answer sheet.
6
A geographer documents Viking culture as it happens.
7
A philosopher classifies cultures hierarchically.
8
Historians assert that Viking history is based more on legends than facts.
9
Young people learn about Viking cultural and economic activities.
10
People see themselves as unrelated to Vikings.
11
An historian claims Viking colonists to modem-day Canada came from his land.
12
Viking conquests are exaggerated to bolster the country’s ego after a territorial loss.
13
DNA tests show locals are closely related to Swedes.
List of times
& places
A
In the UK today
B
In 19th-century Norway
C
In 19th-century Sweden
D
In 19th-century England
E
In Denmark today
F
In 9th-century Persia
G
In mid-20th century Soviet Union
H
In Russia today

8 ____ Historians assert that Viking history is based more on legends than facts.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3f35d4a-5e24-5be5-a5c9-036f44b3a427', 'f8ea4479-d60d-5f6f-9e46-25a601b11ccd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d4a272c-4b4d-5605-b094-eeced2b29b62', 'f8ea4479-d60d-5f6f-9e46-25a601b11ccd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91073eaa-78b8-5dea-9402-3df974e8465d', 'f8ea4479-d60d-5f6f-9e46-25a601b11ccd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33e0f1fd-ea20-52fc-8fe7-845441c877d1', 'f8ea4479-d60d-5f6f-9e46-25a601b11ccd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3d91443-41db-50c2-b9f2-487ad55071da', 'f8ea4479-d60d-5f6f-9e46-25a601b11ccd', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d8a62c3-6f0c-58ac-9964-69ecf9a342f7', 'f8ea4479-d60d-5f6f-9e46-25a601b11ccd', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38321a4d-e67c-5304-9582-688390692a81', 'f8ea4479-d60d-5f6f-9e46-25a601b11ccd', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d418186-a954-5b03-9aa9-eeac64a651a3', 'f8ea4479-d60d-5f6f-9e46-25a601b11ccd', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c8ca1877-cb47-5726-afdd-c9b543a2859a', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-13
Questions 6-13
Look at the following statements and the list of times and places below.
Match each statement with the correct place or time:
A-H
.
Write the correct letter,
A-H
, in boxes
6-13
on your answer sheet.
6
A geographer documents Viking culture as it happens.
7
A philosopher classifies cultures hierarchically.
8
Historians assert that Viking history is based more on legends than facts.
9
Young people learn about Viking cultural and economic activities.
10
People see themselves as unrelated to Vikings.
11
An historian claims Viking colonists to modem-day Canada came from his land.
12
Viking conquests are exaggerated to bolster the country’s ego after a territorial loss.
13
DNA tests show locals are closely related to Swedes.
List of times
& places
A
In the UK today
B
In 19th-century Norway
C
In 19th-century Sweden
D
In 19th-century England
E
In Denmark today
F
In 9th-century Persia
G
In mid-20th century Soviet Union
H
In Russia today

9 ____ Young people learn about Viking cultural and economic activities.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4476ba6-c91b-56c7-ba78-6ea6ce642a88', 'c8ca1877-cb47-5726-afdd-c9b543a2859a', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89d58db7-0963-5f9e-bb1b-01540a07d8b2', 'c8ca1877-cb47-5726-afdd-c9b543a2859a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14074d8c-8361-5ab9-b43a-ffc833bc40e2', 'c8ca1877-cb47-5726-afdd-c9b543a2859a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a9f1508-a460-51a7-89a0-138c384746fa', 'c8ca1877-cb47-5726-afdd-c9b543a2859a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a5789f1-07a2-590c-921b-9b00f4f3bab7', 'c8ca1877-cb47-5726-afdd-c9b543a2859a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d459766f-98a2-56aa-9946-527ebd107b25', 'c8ca1877-cb47-5726-afdd-c9b543a2859a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e27c755e-6f92-516f-bc07-89aa2fbcb4a1', 'c8ca1877-cb47-5726-afdd-c9b543a2859a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd3c6a5f-447b-5cd7-8cf8-59d086c0a000', 'c8ca1877-cb47-5726-afdd-c9b543a2859a', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e6d45eaf-157e-5145-a2aa-7d0ba16d15ab', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-13
Questions 6-13
Look at the following statements and the list of times and places below.
Match each statement with the correct place or time:
A-H
.
Write the correct letter,
A-H
, in boxes
6-13
on your answer sheet.
6
A geographer documents Viking culture as it happens.
7
A philosopher classifies cultures hierarchically.
8
Historians assert that Viking history is based more on legends than facts.
9
Young people learn about Viking cultural and economic activities.
10
People see themselves as unrelated to Vikings.
11
An historian claims Viking colonists to modem-day Canada came from his land.
12
Viking conquests are exaggerated to bolster the country’s ego after a territorial loss.
13
DNA tests show locals are closely related to Swedes.
List of times
& places
A
In the UK today
B
In 19th-century Norway
C
In 19th-century Sweden
D
In 19th-century England
E
In Denmark today
F
In 9th-century Persia
G
In mid-20th century Soviet Union
H
In Russia today

10 ____ People see themselves as unrelated to Vikings.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ce201b4-d92f-54a1-95fb-b151695e083e', 'e6d45eaf-157e-5145-a2aa-7d0ba16d15ab', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee695679-2e2d-54fb-9f44-8550832a0bd2', 'e6d45eaf-157e-5145-a2aa-7d0ba16d15ab', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a2aa3c4-3731-5c06-bca4-5d3a085f7132', 'e6d45eaf-157e-5145-a2aa-7d0ba16d15ab', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5b62415-b7f4-5349-a578-e3beed1e2f3c', 'e6d45eaf-157e-5145-a2aa-7d0ba16d15ab', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0055b5c4-bea2-577b-8a78-9496fb1c593e', 'e6d45eaf-157e-5145-a2aa-7d0ba16d15ab', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c52e4eb2-9c3a-5465-919f-b833559dcf23', 'e6d45eaf-157e-5145-a2aa-7d0ba16d15ab', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf014d8b-1f81-519a-b8b3-577d40a016e8', 'e6d45eaf-157e-5145-a2aa-7d0ba16d15ab', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b61e2aa-92b2-577f-9ce8-0333660a1a11', 'e6d45eaf-157e-5145-a2aa-7d0ba16d15ab', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('43591407-da98-5bd7-ad47-9f9c6fd980e3', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 6-13
Questions 6-13
Look at the following statements and the list of times and places below.
Match each statement with the correct place or time:
A-H
.
Write the correct letter,
A-H
, in boxes
6-13
on your answer sheet.
6
A geographer documents Viking culture as it happens.
7
A philosopher classifies cultures hierarchically.
8
Historians assert that Viking history is based more on legends than facts.
9
Young people learn about Viking cultural and economic activities.
10
People see themselves as unrelated to Vikings.
11
An historian claims Viking colonists to modem-day Canada came from his land.
12
Viking conquests are exaggerated to bolster the country’s ego after a territorial loss.
13
DNA tests show locals are closely related to Swedes.
List of times
& places
A
In the UK today
B
In 19th-century Norway
C
In 19th-century Sweden
D
In 19th-century England
E
In Denmark today
F
In 9th-century Persia
G
In mid-20th century Soviet Union
H
In Russia today

11 ____ An historian claims Viking colonists to modem-day Canada came from his land.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd9087ce-5d15-5108-8233-1b5535ab28c3', '43591407-da98-5bd7-ad47-9f9c6fd980e3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d907c6b-675c-55c9-98ae-211a87f04cfd', '43591407-da98-5bd7-ad47-9f9c6fd980e3', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee88d820-bf8c-5ecb-9a81-2e3839de862c', '43591407-da98-5bd7-ad47-9f9c6fd980e3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a2c001a-acf7-5142-913e-4605e897ca7c', '43591407-da98-5bd7-ad47-9f9c6fd980e3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba56b934-1c3e-5a4f-83f2-6c3d9eb83cc3', '43591407-da98-5bd7-ad47-9f9c6fd980e3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5899fe7f-c133-57b0-9f76-88587f05bd5b', '43591407-da98-5bd7-ad47-9f9c6fd980e3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fb50dea-deb4-5471-8220-6a5bd6fd6033', '43591407-da98-5bd7-ad47-9f9c6fd980e3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97a60651-6849-57aa-b3a3-92bfac6909c5', '43591407-da98-5bd7-ad47-9f9c6fd980e3', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f7596f22-b027-52b8-88d3-e724cca6d0cd', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 6-13
Questions 6-13
Look at the following statements and the list of times and places below.
Match each statement with the correct place or time:
A-H
.
Write the correct letter,
A-H
, in boxes
6-13
on your answer sheet.
6
A geographer documents Viking culture as it happens.
7
A philosopher classifies cultures hierarchically.
8
Historians assert that Viking history is based more on legends than facts.
9
Young people learn about Viking cultural and economic activities.
10
People see themselves as unrelated to Vikings.
11
An historian claims Viking colonists to modem-day Canada came from his land.
12
Viking conquests are exaggerated to bolster the country’s ego after a territorial loss.
13
DNA tests show locals are closely related to Swedes.
List of times
& places
A
In the UK today
B
In 19th-century Norway
C
In 19th-century Sweden
D
In 19th-century England
E
In Denmark today
F
In 9th-century Persia
G
In mid-20th century Soviet Union
H
In Russia today

12 ____ Viking conquests are exaggerated to bolster the country’s ego after a territorial loss.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de24f118-3ff4-568d-8625-98f428ac9e57', 'f7596f22-b027-52b8-88d3-e724cca6d0cd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9f26d80-f1d7-53b1-b123-5cb2920086fd', 'f7596f22-b027-52b8-88d3-e724cca6d0cd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15cc8c6f-e464-5cdf-a43f-ef43a08b4f6e', 'f7596f22-b027-52b8-88d3-e724cca6d0cd', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6264949f-f95d-5b0e-b0b2-bc9366902fac', 'f7596f22-b027-52b8-88d3-e724cca6d0cd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04eb612e-beaa-5bb0-9f30-6ec33726ae59', 'f7596f22-b027-52b8-88d3-e724cca6d0cd', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4769f3d-90d4-59bd-8f16-c6e36044422c', 'f7596f22-b027-52b8-88d3-e724cca6d0cd', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('328c54a4-581c-5ba1-ba2d-5f3752bc2279', 'f7596f22-b027-52b8-88d3-e724cca6d0cd', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b3256d8-7c31-5e92-8250-9d470e9727c7', 'f7596f22-b027-52b8-88d3-e724cca6d0cd', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f7b3cb31-d4e4-5c27-99b5-8f272bd00057', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 6-13
Questions 6-13
Look at the following statements and the list of times and places below.
Match each statement with the correct place or time:
A-H
.
Write the correct letter,
A-H
, in boxes
6-13
on your answer sheet.
6
A geographer documents Viking culture as it happens.
7
A philosopher classifies cultures hierarchically.
8
Historians assert that Viking history is based more on legends than facts.
9
Young people learn about Viking cultural and economic activities.
10
People see themselves as unrelated to Vikings.
11
An historian claims Viking colonists to modem-day Canada came from his land.
12
Viking conquests are exaggerated to bolster the country’s ego after a territorial loss.
13
DNA tests show locals are closely related to Swedes.
List of times
& places
A
In the UK today
B
In 19th-century Norway
C
In 19th-century Sweden
D
In 19th-century England
E
In Denmark today
F
In 9th-century Persia
G
In mid-20th century Soviet Union
H
In Russia today

13 ____ DNA tests show locals are closely related to Swedes.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21f04683-bd66-5d86-92ae-ab5173dd012f', 'f7b3cb31-d4e4-5c27-99b5-8f272bd00057', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58c6f3ef-6b57-5c54-afc7-76390d8cd263', 'f7b3cb31-d4e4-5c27-99b5-8f272bd00057', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('401049f1-2976-55e3-a5d6-757de31955cb', 'f7b3cb31-d4e4-5c27-99b5-8f272bd00057', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8866143-6fb1-50b1-9b42-f4ba17ed8ba9', 'f7b3cb31-d4e4-5c27-99b5-8f272bd00057', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc2d4c1a-8dc4-5529-92d7-5c25855a6670', 'f7b3cb31-d4e4-5c27-99b5-8f272bd00057', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78aa75f1-b91d-5bfa-bba7-2ec49d35a8a7', 'f7b3cb31-d4e4-5c27-99b5-8f272bd00057', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3447734-dd8f-5b16-bf54-f63dff3ee1c1', 'f7b3cb31-d4e4-5c27-99b5-8f272bd00057', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12977cc6-6ea1-5eb9-9db1-23937ac5b66d', 'f7b3cb31-d4e4-5c27-99b5-8f272bd00057', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('074a349a-9e59-566d-9693-3d2f0cc874ea', '7d40c492-f869-5b9f-967d-11c0b1a8759d', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Question 14
Question 14
Which might be a suitable title for passage?
Choose the correct letter
A-E
.
Write the correct letter in box
14
on your answer sheet.
A
A brief history of Vikings
B
Recent Viking discoveries
C
A modem fascination with Vikings
D
Interpretations of Viking history
E
Viking history and nationalism

Which might be a suitable title for passage?$md$, NULL);

COMMIT;
