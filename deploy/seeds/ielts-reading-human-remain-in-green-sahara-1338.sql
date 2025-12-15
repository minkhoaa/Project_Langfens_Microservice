BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-human-remain-in-green-sahara-1338'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-human-remain-in-green-sahara-1338';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-human-remain-in-green-sahara-1338';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-human-remain-in-green-sahara-1338';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('0d439887-61aa-599c-b4d0-81c1400cdd34', 'ielts-reading-human-remain-in-green-sahara-1338', $t$Human remain in Green Sahara$t$, $md$## Human remain in Green Sahara

Nguồn:
- Test: https://mini-ielts.com/1338/reading/human-remain-in-green-sahara
- Solution: https://mini-ielts.com/1338/view-solution/reading/human-remain-in-green-sahara$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3de127f3-d4c2-5868-80ac-1871ea68b93d', '0d439887-61aa-599c-b4d0-81c1400cdd34', 1, $t$Reading — Human remain in Green Sahara$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Human remain in Green Sahara

{A} On October 13,2,000, a small team of paleontologists led by Paul Sereno of the University of Chicago clambered out of three battered Land Rovers, filled their water bottles, and scattered on foot across the toffee-colored sands of the Tenere desert in northern Niger. The Tenere , on the southern flank of the Sahara, easily ranks among the most desolate landscapes on Earth. The Tuareg , turbaned nomads who for centuries have ruled this barren realm, refer to it as a “desert within a desert”-a California-size ocean of sand and rock, where a single massive dune might stretch a hundred miles, and the combination of 120-degree heat and inexorable winds can wick the water from a human body in less than a day. The harsh conditions, combined with intermittent conflict between the Tuareg and the Niger government, have kept the region largely unexplored.

{B} Mike Hettwer, a photographer accompanying the team, headed off by himself toward a trio of small dunes. He crested the first slope and stared in amazement. The dunes were spilling over with bones. He took a few shots with his digital camera and hurried back to the Land Rovers. “I found some bones:’ Hettwer said, when the team had regrouped. “But they’re not dinosaurs. They’re human.”

{C} In the spring of 2005 Sereno contacted Elena Garcea, an archaeologist at the University of Cassino, in Italy, inviting her to accompany him on a return to the site. Garcea had spent three decades working digs along the Nile in Sudan and in the mountains of the Libyan Desert, and was well acquainted with the ancient peoples of the Sahara. But she had never heard of Paul Sereno. His claim to have found so many skeletons in one place seemed far fetched, given that no other Neolithic cemetery contained more than a dozen or so. Some archaeologists would later be skeptical; one sniped that he was just a “moonlighting paleontologist.” But Garcea was too intrigued to dismiss him as an interloper. She agreed to join him.

{D} Garcea explained that the Kiffian were a fishing-based culture and lived during the earliest wet period, between 8,000 and 10,000 years ago. She held a Kiffian sherd next to a Tenerian one. “What is so amazing is that the people who made these two pots lived more than a thousand years apart.”

{E} Over the next three weeks, Sereno and Garcea-along with five American excavators, five Tuareg guides, and five soldiers from Nigeria’s army, sent to protect the camp from bandits—made a detailed map of the site, which they dubbed Gobero, after the Tuareg name for the area. They exhumed eight burials and collected scores of artifacts from both cultures. In a dry lake bed adjacent to the dunes, they found dozens of fishhooks and harpoons carved from animal bone Apparently the Kiffian fishermen weren’t just going after small fry: Scattered near the dunes were the remains of Nile perch, a beast of a fish that can weigh nearly 300 pounds, as well as crocodile and hippo bones.

{F} Sereno flew home with the most important skeletons and artifacts and immediately began planning for the next field season. In the meantime, he carefully removed one tooth from each of four skulls and sent them to a lab for radiocarbon dating. The results pegged the age of the tightly bundled burials at roughly 9,000 years old, the heart of the Kiffian era. The smaller “sleeping” skeletons turned out to be about 6,000 years old, well within the Tenerian period. At least now the scientists knew who was who.

{G} In the fall of 2006 they returned to Gobero, accompanied by a larger dig crew and six additional scientists. Garcea hoped to excavate some 80 burials, and the team began digging. As the skeletons began to emerge from the dunes, each presented a fresh riddle, especially the Tenerian. A male skeleton had been buried with a finger in his mouth.

{H} Even at the site, Arizona State University bio archaeologist Chris Stojanowski could begin to piece together some clues. Judging by the bones, the Kiffian appeared to be a peaceful, hard working people. “The lack of head and forearm injuries suggests they weren’t doing much fighting,” he told me. “And these guys were strong.” He pointed to a long, narrow ridge running along a femur. “That’s the muscle attachment,” he said. “This individual had huge leg muscles, which means he was eating a lot of protein and had a strenuous lifestyle — both consistent with a fishing way of life.” For contrast, he showed me the femur of a Tenerian male. The ridge was barely perceptible. “This guy had a much less strenuous lifestyle,” he said, “which you might expect of a herder.”

{I} Stojanowski’s assessment that the Tenerian were herders fits the prevailing view among scholars of life in the Sahara 6,000 years ago, when drier conditions favored herding over hunting. But if the Tenerian were herders, Sereno pointed out, where were the herds? Among the hundreds of animal bones that had turned up at the site, none belonged to goats or sheep, and only three came from a cow species. “It’s not unusual for a herding culture not to slaughter their cattle, particularly in a cemetery, M Garcea responded, noting that even modern pastoralists, such as Niger’s Wodaabe, are loath to butcher even one animal in their herd. Perhaps, Sereno reasoned, the Tenerian at Gobero were a transitional group that had not fully adopted herding and still relied heavily on hunting and fishing.

{J} Back in Arizona, Stojanowski continues to analyze the Gobero bones for clues to the Green Saharans’ health and diet. Other scientists are trying to derive DNA from the teeth, which could reveal the genetic origins of the Kiffian and Tenerian- and possibly link them to descendants living today. Sereno and Garcea estimate a hundred burials remain to be excavated. But as the harsh Tenere winds continue to erode the dunes, time is running out. “Every archaeological site has a life cycle,” Garcea said. “It begins when people begin to use the place, followed by disuse, then nature takes over, and finally it is gone. Gobero is at the end of its life.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6f81714b-d96a-5497-acd7-3a1b9ad0a887', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-3
Questions 1-3
Do the following statements agree with the information given in the Reading Passage?
In boxes 1-3 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
1
Hettwer accidentally found human remains in the desert.
2
Sereno and Garcea have cooperated in some archaeological activities before.
3
The pictures of rock engravings found in Green Sahara is similar to other places.

1 ____ Hettwer accidentally found human remains in the desert.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69f17eaf-3bb2-58bb-bfb9-e34b93c913ae', '6f81714b-d96a-5497-acd7-3a1b9ad0a887', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6e45c12-0dc3-5056-9db5-12c4140a3f14', '6f81714b-d96a-5497-acd7-3a1b9ad0a887', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04688d8e-108c-5f8b-9716-b0d3c947cee8', '6f81714b-d96a-5497-acd7-3a1b9ad0a887', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('be2ea06c-3cfd-5e55-904c-daaaeb105a54', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-3
Questions 1-3
Do the following statements agree with the information given in the Reading Passage?
In boxes 1-3 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
1
Hettwer accidentally found human remains in the desert.
2
Sereno and Garcea have cooperated in some archaeological activities before.
3
The pictures of rock engravings found in Green Sahara is similar to other places.

2 ____ Sereno and Garcea have cooperated in some archaeological activities before.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37a72fe8-cfe4-516d-99cc-482adcd46215', 'be2ea06c-3cfd-5e55-904c-daaaeb105a54', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce61fb07-c575-50e8-b85d-c43d21d6ac25', 'be2ea06c-3cfd-5e55-904c-daaaeb105a54', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3049bc5-60ea-5bad-a7c1-a66ae0227206', 'be2ea06c-3cfd-5e55-904c-daaaeb105a54', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1f672104-77d3-5e7e-ac84-c4cd2e924a62', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-3
Questions 1-3
Do the following statements agree with the information given in the Reading Passage?
In boxes 1-3 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
1
Hettwer accidentally found human remains in the desert.
2
Sereno and Garcea have cooperated in some archaeological activities before.
3
The pictures of rock engravings found in Green Sahara is similar to other places.

3 ____ The pictures of rock engravings found in Green Sahara is similar to other places.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a37da693-f57b-5c2f-9342-83965c37f650', '1f672104-77d3-5e7e-ac84-c4cd2e924a62', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0707a004-c6a2-51a2-9a2d-6fc4d7255f5b', '1f672104-77d3-5e7e-ac84-c4cd2e924a62', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31b39461-31e2-5908-935e-5d3e9e4be751', '1f672104-77d3-5e7e-ac84-c4cd2e924a62', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e383016b-7420-535f-9672-3ce5760c6103', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 4, 'SHORT_ANSWER', 'READING', 2, $md$### Question 4

Questions 4-7
Questions 4-7
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
{4}
What did Sereno and Garcea produce in the initial weeks before digging work?
4
{5}
For what purpose did Sereno send one tooth from each of four skulls to the laboratory?
5
{6}
How old are the bigger tightly bundled burials being identified?
6
{7}
What part of the body remains did the scientists send for inspection to find out the genetic origins of the Kiffian and Tenerian?
7

{4} What did Sereno and Garcea produce in the initial weeks before digging work? 4 ____$md$, NULL, ARRAY['.*a.*map.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2c5d73ff-b3cb-52cc-8076-9a4cb6a2e0eb', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 5, 'SHORT_ANSWER', 'READING', 3, $md$### Question 5

Questions 4-7
Questions 4-7
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
{4}
What did Sereno and Garcea produce in the initial weeks before digging work?
4
{5}
For what purpose did Sereno send one tooth from each of four skulls to the laboratory?
5
{6}
How old are the bigger tightly bundled burials being identified?
6
{7}
What part of the body remains did the scientists send for inspection to find out the genetic origins of the Kiffian and Tenerian?
7

{5} For what purpose did Sereno send one tooth from each of four skulls to the laboratory? 5 ____$md$, NULL, ARRAY['.*radiocarbon.*dating.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('21b222aa-aaa4-5524-8318-d6d40adcfff2', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 4-7
Questions 4-7
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
{4}
What did Sereno and Garcea produce in the initial weeks before digging work?
4
{5}
For what purpose did Sereno send one tooth from each of four skulls to the laboratory?
5
{6}
How old are the bigger tightly bundled burials being identified?
6
{7}
What part of the body remains did the scientists send for inspection to find out the genetic origins of the Kiffian and Tenerian?
7

{6} How old are the bigger tightly bundled burials being identified? 6 ____$md$, NULL, ARRAY['.*9000.*years.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4360441c-913a-53c4-b0de-24b6a7eb1b7f', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 4-7
Questions 4-7
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
{4}
What did Sereno and Garcea produce in the initial weeks before digging work?
4
{5}
For what purpose did Sereno send one tooth from each of four skulls to the laboratory?
5
{6}
How old are the bigger tightly bundled burials being identified?
6
{7}
What part of the body remains did the scientists send for inspection to find out the genetic origins of the Kiffian and Tenerian?
7

{7} What part of the body remains did the scientists send for inspection to find out the genetic origins of the Kiffian and Tenerian? 7 ____$md$, NULL, ARRAY['.*teeth.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('58436121-f7b6-5ac6-ab11-38764319a139', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-14
Questions 8-14
Summary Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 8-14 on your answer sheet.
On the basis of bone judgment, kiffican seemed to be
8
hardworking people, because we did not find
9
on head and forearm.
Through observation of the huge leg muscles, it can be inferred that their diet had plenty of
10
and their lifestyle was
11
. All evidence pointed to compliance with a fishing way of life.
On the other hand, Stojanowski presumed that Tenerian preferred to live on herding over
12
,but only some animal bones such as
13
were found, which Sereno supposed that Tenerian at Gobero lived in a
14
group at that time.

On the basis of bone judgment, kiffican seemed to be 8 ____ hardworking people, because we did not find 9 ____ on head and forearm.$md$, NULL, ARRAY['.*peaceful.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a71a6d45-e73b-5a84-bb5a-61824d218f06', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-14
Questions 8-14
Summary Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 8-14 on your answer sheet.
On the basis of bone judgment, kiffican seemed to be
8
hardworking people, because we did not find
9
on head and forearm.
Through observation of the huge leg muscles, it can be inferred that their diet had plenty of
10
and their lifestyle was
11
. All evidence pointed to compliance with a fishing way of life.
On the other hand, Stojanowski presumed that Tenerian preferred to live on herding over
12
,but only some animal bones such as
13
were found, which Sereno supposed that Tenerian at Gobero lived in a
14
group at that time.

On the basis of bone judgment, kiffican seemed to be 8 ____ hardworking people, because we did not find 9 ____ on head and forearm.$md$, NULL, ARRAY['.*peaceful.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3e20d416-7fb9-5417-a94d-1aa63d06499d', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-14
Questions 8-14
Summary Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 8-14 on your answer sheet.
On the basis of bone judgment, kiffican seemed to be
8
hardworking people, because we did not find
9
on head and forearm.
Through observation of the huge leg muscles, it can be inferred that their diet had plenty of
10
and their lifestyle was
11
. All evidence pointed to compliance with a fishing way of life.
On the other hand, Stojanowski presumed that Tenerian preferred to live on herding over
12
,but only some animal bones such as
13
were found, which Sereno supposed that Tenerian at Gobero lived in a
14
group at that time.

Through observation of the huge leg muscles, it can be inferred that their diet had plenty of 10 ____ and their lifestyle was 11 ____ . All evidence pointed to compliance with a fishing way of life.$md$, NULL, ARRAY['.*protein.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('44f70548-db19-51ff-ac59-7ecabe57ae64', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8-14
Questions 8-14
Summary Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 8-14 on your answer sheet.
On the basis of bone judgment, kiffican seemed to be
8
hardworking people, because we did not find
9
on head and forearm.
Through observation of the huge leg muscles, it can be inferred that their diet had plenty of
10
and their lifestyle was
11
. All evidence pointed to compliance with a fishing way of life.
On the other hand, Stojanowski presumed that Tenerian preferred to live on herding over
12
,but only some animal bones such as
13
were found, which Sereno supposed that Tenerian at Gobero lived in a
14
group at that time.

Through observation of the huge leg muscles, it can be inferred that their diet had plenty of 10 ____ and their lifestyle was 11 ____ . All evidence pointed to compliance with a fishing way of life.$md$, NULL, ARRAY['.*protein.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bd312a78-f8a5-57af-bccc-55f908beed6a', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 8-14
Questions 8-14
Summary Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 8-14 on your answer sheet.
On the basis of bone judgment, kiffican seemed to be
8
hardworking people, because we did not find
9
on head and forearm.
Through observation of the huge leg muscles, it can be inferred that their diet had plenty of
10
and their lifestyle was
11
. All evidence pointed to compliance with a fishing way of life.
On the other hand, Stojanowski presumed that Tenerian preferred to live on herding over
12
,but only some animal bones such as
13
were found, which Sereno supposed that Tenerian at Gobero lived in a
14
group at that time.

On the other hand, Stojanowski presumed that Tenerian preferred to live on herding over 12 ____ ,but only some animal bones such as 13 ____ were found, which Sereno supposed that Tenerian at Gobero lived in a 14 ____ group at that time.$md$, NULL, ARRAY['.*hunting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7eaa8dc6-6ebe-51d5-ad36-5e17602f3cfe', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 8-14
Questions 8-14
Summary Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 8-14 on your answer sheet.
On the basis of bone judgment, kiffican seemed to be
8
hardworking people, because we did not find
9
on head and forearm.
Through observation of the huge leg muscles, it can be inferred that their diet had plenty of
10
and their lifestyle was
11
. All evidence pointed to compliance with a fishing way of life.
On the other hand, Stojanowski presumed that Tenerian preferred to live on herding over
12
,but only some animal bones such as
13
were found, which Sereno supposed that Tenerian at Gobero lived in a
14
group at that time.

On the other hand, Stojanowski presumed that Tenerian preferred to live on herding over 12 ____ ,but only some animal bones such as 13 ____ were found, which Sereno supposed that Tenerian at Gobero lived in a 14 ____ group at that time.$md$, NULL, ARRAY['.*hunting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8e54797f-3efe-5953-9c8d-ec35dce0997e', '3de127f3-d4c2-5868-80ac-1871ea68b93d', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 8-14
Questions 8-14
Summary Complete the following summary of the paragraphs of Reading Passage, using
no more than two words
from the Reading Passage for each answer. Write your answers in boxes 8-14 on your answer sheet.
On the basis of bone judgment, kiffican seemed to be
8
hardworking people, because we did not find
9
on head and forearm.
Through observation of the huge leg muscles, it can be inferred that their diet had plenty of
10
and their lifestyle was
11
. All evidence pointed to compliance with a fishing way of life.
On the other hand, Stojanowski presumed that Tenerian preferred to live on herding over
12
,but only some animal bones such as
13
were found, which Sereno supposed that Tenerian at Gobero lived in a
14
group at that time.

On the other hand, Stojanowski presumed that Tenerian preferred to live on herding over 12 ____ ,but only some animal bones such as 13 ____ were found, which Sereno supposed that Tenerian at Gobero lived in a 14 ____ group at that time.$md$, NULL, ARRAY['.*hunting.*']);

COMMIT;
