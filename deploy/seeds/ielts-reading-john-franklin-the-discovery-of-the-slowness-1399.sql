BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-john-franklin-the-discovery-of-the-slowness-1399'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-john-franklin-the-discovery-of-the-slowness-1399';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-john-franklin-the-discovery-of-the-slowness-1399';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-john-franklin-the-discovery-of-the-slowness-1399';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('b95b4392-a8c4-574f-8410-d439f2a065a9', 'ielts-reading-john-franklin-the-discovery-of-the-slowness-1399', $t$John Franklin: “the discovery of the slowness”$t$, $md$## John Franklin: “the discovery of the slowness”

Nguồn:
- Test: https://mini-ielts.com/1399/reading/john-franklin-the-discovery-of-the-slowness
- Solution: https://mini-ielts.com/1399/view-solution/reading/john-franklin-the-discovery-of-the-slowness$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('8d66dfc6-e688-5e75-b652-5f865a5c0a00', 'b95b4392-a8c4-574f-8410-d439f2a065a9', 1, $t$Reading — John Franklin: “the discovery of the slowness”$t$, $md$Read the passage and answer questions **1–14**.

### Passage: John Franklin: “the discovery of the slowness”

A

John Franklin (1786-1847) was the most famous vanisher of the Victorian era. He joined the Navy as a midshipman at the age of 14 and fought in the battles of Copenhagen and Trafalgar. When peace with the French broke out. he turned his attention to, and in particular to solve the conundrum of the Northwest Passage, the mythical clear-water route which would, if it existed, link the Atlantic and the Pacific Oceans above the northern coast of the American continent. The first expedition Franklin led to the Arctic was an arduous overland journey from Hudson Bay to the shores of the so-called Polar Ocean east of the Coppermine River. Between 1819 and 1822. Franklin and his twenty-strong team covered 5550 miles on foot. Their expedition was a triumph of surveying – they managed to chart hundreds of miles of previously unknown coastline.

B

There followed a career as a travel writer and salon-goer {‘the man who ate his boots’ was Franklin’s tag-line), a second long Arctic expedition, and a controversial spell as Governor of Van Diemen’s Land. Then, in May 1845, Franklin set off with two ships – the Erebus and the Terror – and 129 men on the voyage that would kill him. In July, the convoy was seen by two whalers, entering Lancaster Sound. Nothing more would be heard of it for 14 years. Had the ships sunk or been iced in? Were the men dead, or in need of rescue? Or had they broken through to the legendary open polar sea, beyond the ‘ice barrier’?

C

In his personal correspondence and in his published memoirs. Franklin comes across as a man dedicated to the external duties of war and exploration, who kept introspection and self-analysis to a minimum. His blandness makes him an amenably malleable subject for a novelist, and Sten Nadolny has taken full advantage of this licence. Most important, he has endowed his John Franklin with a defining character trait for which there is no historical evidence: (‘slowness’, or ‘calmness’).

D

Slowness influences not only Franklin’s behaviour but also his vision, his thought and his speech. The opening scene of The Discovery of Slowness (The Discovery of Slowness by Sten Nadolny) – depicts Franklin as a young boy. playing catch badly because his reaction time is too slow. Despite the bullying of his peers, Franklin resolves not to fall into step with ‘their way of doing things’. For Nadolny. Franklin’s fated fascination with the Arctic stems from his desire to find an environment suited to his peculiar slowness.

E

He describes Franklin as a boy dreaming of the ‘open water and the time without hours and days’ which exist in the far north, and of finding in the Arctic a place ‘where nobody would find him too slow’. Ice is a slow mover. Ice demands a corresponding patience from those who venture onto it. The explorers who have thrived at high latitude and at high altitudes haven’t usually been men of great speed. They have tended instead to demonstrate unusual self-possession, a considerable capacity for boredom, and a talent for what the Scots call ‘tholing’, the uncomplaining endurance of suffering.

F

These were all qualities which the historical Franklin possessed in abundance, and so Nadolny’s concentration and exaggeration of them isn’t unreasonable. Even as an adult, his slowness of thought means that he is unable to speak fluently, so he memorises ‘entire fleets of words and batteries of response’, and speaks a languid, bric-a-brac language. In the Navy, his method of thinking first and acting later initially provokes mockery from his fellow sailors. But Franklin persists in doing things his way. and gradually earns the respect of those around him. To a commodore who tells him to speed up his report of an engagement, he replies: ‘When I tell something, sir. I use my own rhythm.’ A lieutenant says approvingly of him: ’Because Franklin is so slow, he never loses time.’

G

Since it was first published in Germany in 1983. The Discovery of Slowness has sold more than a million copies and been translated into 13 languages. It has been named as one of German literature’s twenty ‘contemporary classics’, and it has been as a manual and by European pressure groups and institutions representing causes as diverse as sustainable development, the Protestant Church, management science, motoring policy and pacifism.

H

The various groups that have taken the novel up have one thing in common: a dislike of the high-speed culture of Postmodernity. Nadolny’s Franklin appeals to them because he is immune to ‘the compulsion to be constantly occupied’, and to the idea that ‘someone was better if he could do the same thing fast.’ Several German churches have used him in their symposia and focus groups as an example of peacefulness, piety and self-confidence. A centre scheme (a ‘march of slowness’ or ‘of the slow’), inspired by the novel. Nadolny has appeared as a guest speaker for RIO, a Lucerne-based organisation which aims to reconcile management principles with ideas of environmental sustainability. The novel has even become involved in the debate about speed limits on German roads. Drive down an autobahn today, and you will see large road-side signs proclaiming ‘unhurriedness’ a slogan which deliberately plays off the title of the novel.

I

A management journal in the US described The Discovery of Slowness is a ‘major event not only for connoisseurs of fine historical fiction but also for those of us who concern themselves with leadership, communication and systems-thinking, issues’. It’s easy to see where the attraction lies for the management crowd. The novel is crammed with quotations about time-efficiency, punctiliousness and profitability: ‘As a rule, there are always three points in time: the right one. the lost one and the premature one’. ‘What did too late mean? They hadn’t waited for it long enough, that’s what it meant.’$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('376adcb4-f4b5-507f-982d-a107c00edf56', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage 3 has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
What was Sir John Franklin’s occupation before he went on a career of the arctic exploration?
2
A story John Franklin reacted strangely when he met bullies by other children.
3
Reason of popularity for the book
The Discovery of Slowness.
4
A depiction that Sten Nadolny’s biography on John Franklin is not much based on facts.
5
The particular career Sir John Franklin took after his expedition unmatched before.
6
what is the central scheme and environment conveyed by the book
The Discovery of Slowness.

1 ____ What was Sir John Franklin’s occupation before he went on a career of the arctic exploration?$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0000ef9-0994-5a46-b84d-ccd9012fa879', '376adcb4-f4b5-507f-982d-a107c00edf56', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa4d26e3-249c-51b1-a208-a7550ef7f56b', '376adcb4-f4b5-507f-982d-a107c00edf56', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab9be734-0fca-5dfd-bf22-a2e3534e4d11', '376adcb4-f4b5-507f-982d-a107c00edf56', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9ed7dab-afeb-5970-bf99-2dfe82dd670b', '376adcb4-f4b5-507f-982d-a107c00edf56', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84d8e852-ae40-5929-a0a4-5de0e10dd658', '376adcb4-f4b5-507f-982d-a107c00edf56', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b51f358-de04-5681-b5ca-30dd2f73c84a', '376adcb4-f4b5-507f-982d-a107c00edf56', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84b8e3b2-bbab-5e81-8269-7834045b2b9a', '376adcb4-f4b5-507f-982d-a107c00edf56', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b74dc90-5efc-52f7-b9bc-944b14d6d6bb', '376adcb4-f4b5-507f-982d-a107c00edf56', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1e841e41-09a5-5578-b887-62b0d19f7ca1', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage 3 has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
What was Sir John Franklin’s occupation before he went on a career of the arctic exploration?
2
A story John Franklin reacted strangely when he met bullies by other children.
3
Reason of popularity for the book
The Discovery of Slowness.
4
A depiction that Sten Nadolny’s biography on John Franklin is not much based on facts.
5
The particular career Sir John Franklin took after his expedition unmatched before.
6
what is the central scheme and environment conveyed by the book
The Discovery of Slowness.

2 ____ A story John Franklin reacted strangely when he met bullies by other children.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffd8bf7e-b02b-5cfc-8e63-58e00a9d2d07', '1e841e41-09a5-5578-b887-62b0d19f7ca1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b7b2fce-478f-5e1c-a87f-2e3d8131267c', '1e841e41-09a5-5578-b887-62b0d19f7ca1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72d086b6-2ccb-55e7-a73d-9cb0a4d2fe6e', '1e841e41-09a5-5578-b887-62b0d19f7ca1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f644c8eb-d464-5926-9062-34bf29e12072', '1e841e41-09a5-5578-b887-62b0d19f7ca1', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f756941-c0ca-5f5f-8631-5cdc1693b6a1', '1e841e41-09a5-5578-b887-62b0d19f7ca1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbfcc90e-0d5f-5e87-afc1-75a2e8fae369', '1e841e41-09a5-5578-b887-62b0d19f7ca1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('056aefb9-c49b-5570-a050-847a66c022a2', '1e841e41-09a5-5578-b887-62b0d19f7ca1', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('538b26ad-1dfa-54da-a94f-1427e2e9b7b3', '1e841e41-09a5-5578-b887-62b0d19f7ca1', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5fcd7a39-963d-5a8d-8236-cde20a69965e', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage 3 has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
What was Sir John Franklin’s occupation before he went on a career of the arctic exploration?
2
A story John Franklin reacted strangely when he met bullies by other children.
3
Reason of popularity for the book
The Discovery of Slowness.
4
A depiction that Sten Nadolny’s biography on John Franklin is not much based on facts.
5
The particular career Sir John Franklin took after his expedition unmatched before.
6
what is the central scheme and environment conveyed by the book
The Discovery of Slowness.

3 ____ Reason of popularity for the book The Discovery of Slowness.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('412a31e5-0e9a-5c5d-aa7e-9a5d4cd482d2', '5fcd7a39-963d-5a8d-8236-cde20a69965e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26b19d6a-05f4-5508-a66b-7636f1db2804', '5fcd7a39-963d-5a8d-8236-cde20a69965e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('043d352b-5c3b-58db-974c-719b8dd2bd48', '5fcd7a39-963d-5a8d-8236-cde20a69965e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d29cc4a4-034f-5913-ae34-4304bf12e723', '5fcd7a39-963d-5a8d-8236-cde20a69965e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('959632c9-f00b-5858-835b-f1744dad8605', '5fcd7a39-963d-5a8d-8236-cde20a69965e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d29d9c0-b92c-5888-974b-20d55fe3b4c4', '5fcd7a39-963d-5a8d-8236-cde20a69965e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('369806b1-d527-5d7a-b3a8-60ad524924da', '5fcd7a39-963d-5a8d-8236-cde20a69965e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0dbcb67-817d-58e2-b79b-9e131b3d4be4', '5fcd7a39-963d-5a8d-8236-cde20a69965e', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8c682b1d-1327-5a48-9efb-6bbfd23049ec', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage 3 has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
What was Sir John Franklin’s occupation before he went on a career of the arctic exploration?
2
A story John Franklin reacted strangely when he met bullies by other children.
3
Reason of popularity for the book
The Discovery of Slowness.
4
A depiction that Sten Nadolny’s biography on John Franklin is not much based on facts.
5
The particular career Sir John Franklin took after his expedition unmatched before.
6
what is the central scheme and environment conveyed by the book
The Discovery of Slowness.

4 ____ A depiction that Sten Nadolny’s biography on John Franklin is not much based on facts.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2e22695-689c-5c84-9799-913f1be2776a', '8c682b1d-1327-5a48-9efb-6bbfd23049ec', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c1db0d1-c977-5d25-8021-7b8d9bf2f22f', '8c682b1d-1327-5a48-9efb-6bbfd23049ec', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef874e21-df31-5ea7-ae81-126545b99d2b', '8c682b1d-1327-5a48-9efb-6bbfd23049ec', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a466688f-1bbe-524e-ab4a-a8beac7ad43a', '8c682b1d-1327-5a48-9efb-6bbfd23049ec', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84eaa03d-043d-5c44-9a67-626edf7a6f80', '8c682b1d-1327-5a48-9efb-6bbfd23049ec', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('513ef517-fcd6-57fc-8822-45ec0e3d475b', '8c682b1d-1327-5a48-9efb-6bbfd23049ec', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c91dc02d-935b-5761-be76-8c9b355a306f', '8c682b1d-1327-5a48-9efb-6bbfd23049ec', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60475c88-7c8f-5a4c-ab7c-2aa073439267', '8c682b1d-1327-5a48-9efb-6bbfd23049ec', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f5b5d830-4dc0-5a1e-9c85-dd26f0591918', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage 3 has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
What was Sir John Franklin’s occupation before he went on a career of the arctic exploration?
2
A story John Franklin reacted strangely when he met bullies by other children.
3
Reason of popularity for the book
The Discovery of Slowness.
4
A depiction that Sten Nadolny’s biography on John Franklin is not much based on facts.
5
The particular career Sir John Franklin took after his expedition unmatched before.
6
what is the central scheme and environment conveyed by the book
The Discovery of Slowness.

5 ____ The particular career Sir John Franklin took after his expedition unmatched before.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('901b4751-d140-51aa-bace-d28df0d7cb04', 'f5b5d830-4dc0-5a1e-9c85-dd26f0591918', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81236d75-2929-5182-b3a4-4273043fa1a9', 'f5b5d830-4dc0-5a1e-9c85-dd26f0591918', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bfdeaa6-f1f0-5321-899f-4adbdb9772ab', 'f5b5d830-4dc0-5a1e-9c85-dd26f0591918', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0ead92e-591f-548a-9cc3-713420470afd', 'f5b5d830-4dc0-5a1e-9c85-dd26f0591918', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1999ea7-c3a4-59da-8cd5-536985bd408f', 'f5b5d830-4dc0-5a1e-9c85-dd26f0591918', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe9e0417-dbc9-543a-ae56-cc46e4710ee1', 'f5b5d830-4dc0-5a1e-9c85-dd26f0591918', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d6d76ed-ae7a-5eeb-99f9-9341d37b41e4', 'f5b5d830-4dc0-5a1e-9c85-dd26f0591918', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f09467e-5ea3-574e-a00d-37ac7ab49171', 'f5b5d830-4dc0-5a1e-9c85-dd26f0591918', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2d3e1406-f157-557f-9af9-eca5e90a0463', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage 3 has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once
.
1
What was Sir John Franklin’s occupation before he went on a career of the arctic exploration?
2
A story John Franklin reacted strangely when he met bullies by other children.
3
Reason of popularity for the book
The Discovery of Slowness.
4
A depiction that Sten Nadolny’s biography on John Franklin is not much based on facts.
5
The particular career Sir John Franklin took after his expedition unmatched before.
6
what is the central scheme and environment conveyed by the book
The Discovery of Slowness.

6 ____ what is the central scheme and environment conveyed by the book The Discovery of Slowness.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8882f34b-19e0-5b8a-b80a-f2ff1ad287da', '2d3e1406-f157-557f-9af9-eca5e90a0463', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09cdf4f0-839d-5558-8f7b-1ce1b2c5497e', '2d3e1406-f157-557f-9af9-eca5e90a0463', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe86cbb9-756b-57b6-b778-2dad8beff7ad', '2d3e1406-f157-557f-9af9-eca5e90a0463', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d842f995-5744-5b33-b9d4-d45a542e752a', '2d3e1406-f157-557f-9af9-eca5e90a0463', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83ee53b5-ac47-5244-a6ba-8b1e1003d928', '2d3e1406-f157-557f-9af9-eca5e90a0463', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('926bbe25-2852-58a0-a80b-47fb3dc40891', '2d3e1406-f157-557f-9af9-eca5e90a0463', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85cbb604-9f91-5d31-936c-2228be6bce54', '2d3e1406-f157-557f-9af9-eca5e90a0463', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa664688-4d04-5d16-bd0b-c7649becc064', '2d3e1406-f157-557f-9af9-eca5e90a0463', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d3cad5fc-98d6-5847-abc1-55b50e324b60', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Complete the Summary paragraph described below.
In boxes
7-10
on your answer sheet
Write the correct answer with
ONE WORD
chosen from the box below
In his personal correspondence to and in his published memoirs by Sten Nadolny, John Franklin was depicted as a man dedicated to the exploration, and the word of “slowness” was used to define his
7
when Franklin was in his childhood, his determination to the
8
of the schoolboys was too slow for him to fall into step. And Franklin was said to be a boy dreaming finding in a place he could enjoy the
9
in the Arctic. Later in 20th, His biography of the discovery of slowness has been adopted as a
10
as for the movement such as sustainable development, or management science, motoring policy.
A
exploration
B
blandness
C
personality
D
policy
E
pressure
F
guidebook
G
management
H
timelessness
I
sports
J
bully
K
evidence

In his personal correspondence to and in his published memoirs by Sten Nadolny, John Franklin was depicted as a man dedicated to the exploration, and the word of “slowness” was used to define his 7 ____ when Franklin was in his childhood, his determination to the 8 ____ of the schoolboys was too slow for him to fall into step. And Franklin was said to be a boy dreaming finding in a place he could enjoy the 9 ____ in the Arctic. Later in 20th, His biography of the discovery of slowness has been adopted as a 10 ____ as for the movement such as sustainable development, or management science, motoring policy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4311a92a-269e-5dd8-a615-f8a6b8bbff69', 'd3cad5fc-98d6-5847-abc1-55b50e324b60', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a14dd3c-2bd5-5c53-8126-0d6ab4327ab1', 'd3cad5fc-98d6-5847-abc1-55b50e324b60', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9599a04b-80f8-5cc5-b5f3-48bf1d443328', 'd3cad5fc-98d6-5847-abc1-55b50e324b60', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62205f0f-db20-559c-b3c2-da1b51e10939', 'd3cad5fc-98d6-5847-abc1-55b50e324b60', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad9be0c2-a783-51ae-b44c-e063ad67eec8', 'd3cad5fc-98d6-5847-abc1-55b50e324b60', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('764dab5f-2421-5265-939d-adb9e21ad0bd', 'd3cad5fc-98d6-5847-abc1-55b50e324b60', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45c83d50-9d1a-591d-8376-a688f7790f66', 'd3cad5fc-98d6-5847-abc1-55b50e324b60', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed58169b-c236-5876-9ccc-ef7661ad57cb', 'd3cad5fc-98d6-5847-abc1-55b50e324b60', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f608cbf3-b77c-589f-8ff7-5a7c4c6dc0d5', 'd3cad5fc-98d6-5847-abc1-55b50e324b60', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8cc48f9-f07f-5c49-bd48-e9c2d94c9377', 'd3cad5fc-98d6-5847-abc1-55b50e324b60', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73a8f7ef-2eb9-57e2-a501-ef619c7924ce', 'd3cad5fc-98d6-5847-abc1-55b50e324b60', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Complete the Summary paragraph described below.
In boxes
7-10
on your answer sheet
Write the correct answer with
ONE WORD
chosen from the box below
In his personal correspondence to and in his published memoirs by Sten Nadolny, John Franklin was depicted as a man dedicated to the exploration, and the word of “slowness” was used to define his
7
when Franklin was in his childhood, his determination to the
8
of the schoolboys was too slow for him to fall into step. And Franklin was said to be a boy dreaming finding in a place he could enjoy the
9
in the Arctic. Later in 20th, His biography of the discovery of slowness has been adopted as a
10
as for the movement such as sustainable development, or management science, motoring policy.
A
exploration
B
blandness
C
personality
D
policy
E
pressure
F
guidebook
G
management
H
timelessness
I
sports
J
bully
K
evidence

In his personal correspondence to and in his published memoirs by Sten Nadolny, John Franklin was depicted as a man dedicated to the exploration, and the word of “slowness” was used to define his 7 ____ when Franklin was in his childhood, his determination to the 8 ____ of the schoolboys was too slow for him to fall into step. And Franklin was said to be a boy dreaming finding in a place he could enjoy the 9 ____ in the Arctic. Later in 20th, His biography of the discovery of slowness has been adopted as a 10 ____ as for the movement such as sustainable development, or management science, motoring policy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('205a7b85-5a6f-5e8b-bcd8-a155ad54927b', '4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d728d8b0-7f13-5018-8e01-869d2bfd18c2', '4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1d70994-559c-587a-94b7-69072a70c98e', '4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9196b7e-8796-58b5-adac-f14ac2fa90e9', '4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5610daf-9535-584d-96ed-152fcb392633', '4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2696837c-f86d-5e3e-922f-6675197148f5', '4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8027287a-5e56-59aa-ae5e-e187cc7cb469', '4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fac7ed3c-deec-5e88-8b5e-d15bceb50736', '4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9c8d48f-9f7c-5aff-bef2-d9f85f6eae32', '4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71b76891-711c-57ad-8a91-535e7b44de45', '4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67e2baff-5658-5e43-a897-ca430f077925', '4ea67a61-5bf2-5636-9b06-8a5d2ec84fc6', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Complete the Summary paragraph described below.
In boxes
7-10
on your answer sheet
Write the correct answer with
ONE WORD
chosen from the box below
In his personal correspondence to and in his published memoirs by Sten Nadolny, John Franklin was depicted as a man dedicated to the exploration, and the word of “slowness” was used to define his
7
when Franklin was in his childhood, his determination to the
8
of the schoolboys was too slow for him to fall into step. And Franklin was said to be a boy dreaming finding in a place he could enjoy the
9
in the Arctic. Later in 20th, His biography of the discovery of slowness has been adopted as a
10
as for the movement such as sustainable development, or management science, motoring policy.
A
exploration
B
blandness
C
personality
D
policy
E
pressure
F
guidebook
G
management
H
timelessness
I
sports
J
bully
K
evidence

In his personal correspondence to and in his published memoirs by Sten Nadolny, John Franklin was depicted as a man dedicated to the exploration, and the word of “slowness” was used to define his 7 ____ when Franklin was in his childhood, his determination to the 8 ____ of the schoolboys was too slow for him to fall into step. And Franklin was said to be a boy dreaming finding in a place he could enjoy the 9 ____ in the Arctic. Later in 20th, His biography of the discovery of slowness has been adopted as a 10 ____ as for the movement such as sustainable development, or management science, motoring policy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3c31f3a-2a04-5408-a058-df83f7ccd7f1', '01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44c0e124-fc0f-5097-be49-6c0d547b756e', '01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c49bde0-bc7d-5d13-9b24-945081c98e5f', '01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27f8bbca-be93-560a-855a-18b5f875a2f0', '01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a278fece-93cd-5f7c-8cd4-4984e93aea52', '01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f6bb492-f8e3-5f9a-9eb2-dc5a92fc76cc', '01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79bf08d6-f129-5f72-8964-cb961025e760', '01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be70657a-5f3a-5ec6-a343-8f1f34a6c753', '01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a9d646a-f00f-5e3a-948a-bb8c8372fe2b', '01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e26f132-0da2-5364-9523-0e6256c77358', '01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcf14b6c-3f4d-537f-a5fe-51817fc742f1', '01f6efc7-f85e-5c94-b3eb-fa3741ac87e8', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9e240ddb-22fa-54d7-853e-0d617e297983', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Complete the Summary paragraph described below.
In boxes
7-10
on your answer sheet
Write the correct answer with
ONE WORD
chosen from the box below
In his personal correspondence to and in his published memoirs by Sten Nadolny, John Franklin was depicted as a man dedicated to the exploration, and the word of “slowness” was used to define his
7
when Franklin was in his childhood, his determination to the
8
of the schoolboys was too slow for him to fall into step. And Franklin was said to be a boy dreaming finding in a place he could enjoy the
9
in the Arctic. Later in 20th, His biography of the discovery of slowness has been adopted as a
10
as for the movement such as sustainable development, or management science, motoring policy.
A
exploration
B
blandness
C
personality
D
policy
E
pressure
F
guidebook
G
management
H
timelessness
I
sports
J
bully
K
evidence

In his personal correspondence to and in his published memoirs by Sten Nadolny, John Franklin was depicted as a man dedicated to the exploration, and the word of “slowness” was used to define his 7 ____ when Franklin was in his childhood, his determination to the 8 ____ of the schoolboys was too slow for him to fall into step. And Franklin was said to be a boy dreaming finding in a place he could enjoy the 9 ____ in the Arctic. Later in 20th, His biography of the discovery of slowness has been adopted as a 10 ____ as for the movement such as sustainable development, or management science, motoring policy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e05734b6-53d1-52d5-a8eb-f7b87bf808d6', '9e240ddb-22fa-54d7-853e-0d617e297983', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c6585f5-b360-5d58-a447-ac6d1038e828', '9e240ddb-22fa-54d7-853e-0d617e297983', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e73dd1e8-2ae3-59e9-8856-853dc262d019', '9e240ddb-22fa-54d7-853e-0d617e297983', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42840785-42b9-5986-a699-90b1c5f3324e', '9e240ddb-22fa-54d7-853e-0d617e297983', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1eca73ae-cad4-569a-8ef5-a21e6fd226a8', '9e240ddb-22fa-54d7-853e-0d617e297983', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('367f06d8-bfc6-5658-a74a-8f92490e1c33', '9e240ddb-22fa-54d7-853e-0d617e297983', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b198fbc7-de97-5efd-a0fc-3fe9648bbb84', '9e240ddb-22fa-54d7-853e-0d617e297983', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f598cb3a-7605-5089-9ef0-ea86ee472854', '9e240ddb-22fa-54d7-853e-0d617e297983', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73097ada-6fa6-5522-87a7-af7bf6e3a4e6', '9e240ddb-22fa-54d7-853e-0d617e297983', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ebec238-b419-5923-bb6d-f28cc992313e', '9e240ddb-22fa-54d7-853e-0d617e297983', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7998cad5-bb58-55b2-8059-df0e5d86f942', '9e240ddb-22fa-54d7-853e-0d617e297983', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cdaca282-c9b7-5ed2-980d-f4294129a812', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
11-14
on your answer sheet
11.
Why does the author mention
“the ice is a slow mover”
in the geological arctic, to demonstrate the idea
A
of the difficulties Franklin conquered
B
that Franklin had a dream since his childhood
C
of fascination with the Arctic exploration
D
that explorer like Franklin should possess the quality of being patient
12.
When Franklin was on board with sailors, how did he speak to his follow sailors
A
he spoke in a way mocking his followers
B
he spoke a bric-a-brac language to show his languish attitude
C
he spoke in the words and phrases he previously memorized
D
he spoke in a rhythmical tune to save chatting time
13.
His effort to overcome his slowness in marine time life had finally won the
A
understanding of his personality better
B
capacity for coping with boredom
C
respect for him as he insisted to overcome his difficulties
D
valuable time he can use to finish a report
14.
Why is the book
The Discovery of Slowness
sold more than a million copies
A
it contains aspects of the life people would like to enjoy
B
it contains the information for the flag language applied in ships
C
it induces a debate about speed limits German
D
it contains the technique for symposia German churches

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1152faa-cc21-5d23-8186-993daa8b56fe', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
11-14
on your answer sheet
11.
Why does the author mention
“the ice is a slow mover”
in the geological arctic, to demonstrate the idea
A
of the difficulties Franklin conquered
B
that Franklin had a dream since his childhood
C
of fascination with the Arctic exploration
D
that explorer like Franklin should possess the quality of being patient
12.
When Franklin was on board with sailors, how did he speak to his follow sailors
A
he spoke in a way mocking his followers
B
he spoke a bric-a-brac language to show his languish attitude
C
he spoke in the words and phrases he previously memorized
D
he spoke in a rhythmical tune to save chatting time
13.
His effort to overcome his slowness in marine time life had finally won the
A
understanding of his personality better
B
capacity for coping with boredom
C
respect for him as he insisted to overcome his difficulties
D
valuable time he can use to finish a report
14.
Why is the book
The Discovery of Slowness
sold more than a million copies
A
it contains aspects of the life people would like to enjoy
B
it contains the information for the flag language applied in ships
C
it induces a debate about speed limits German
D
it contains the technique for symposia German churches

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c349669a-50eb-5074-ae51-71ecde090e2f', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
11-14
on your answer sheet
11.
Why does the author mention
“the ice is a slow mover”
in the geological arctic, to demonstrate the idea
A
of the difficulties Franklin conquered
B
that Franklin had a dream since his childhood
C
of fascination with the Arctic exploration
D
that explorer like Franklin should possess the quality of being patient
12.
When Franklin was on board with sailors, how did he speak to his follow sailors
A
he spoke in a way mocking his followers
B
he spoke a bric-a-brac language to show his languish attitude
C
he spoke in the words and phrases he previously memorized
D
he spoke in a rhythmical tune to save chatting time
13.
His effort to overcome his slowness in marine time life had finally won the
A
understanding of his personality better
B
capacity for coping with boredom
C
respect for him as he insisted to overcome his difficulties
D
valuable time he can use to finish a report
14.
Why is the book
The Discovery of Slowness
sold more than a million copies
A
it contains aspects of the life people would like to enjoy
B
it contains the information for the flag language applied in ships
C
it induces a debate about speed limits German
D
it contains the technique for symposia German churches

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2e1e911e-1cea-5715-810e-bfb6464e2472', '8d66dfc6-e688-5e75-b652-5f865a5c0a00', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
11-14
on your answer sheet
11.
Why does the author mention
“the ice is a slow mover”
in the geological arctic, to demonstrate the idea
A
of the difficulties Franklin conquered
B
that Franklin had a dream since his childhood
C
of fascination with the Arctic exploration
D
that explorer like Franklin should possess the quality of being patient
12.
When Franklin was on board with sailors, how did he speak to his follow sailors
A
he spoke in a way mocking his followers
B
he spoke a bric-a-brac language to show his languish attitude
C
he spoke in the words and phrases he previously memorized
D
he spoke in a rhythmical tune to save chatting time
13.
His effort to overcome his slowness in marine time life had finally won the
A
understanding of his personality better
B
capacity for coping with boredom
C
respect for him as he insisted to overcome his difficulties
D
valuable time he can use to finish a report
14.
Why is the book
The Discovery of Slowness
sold more than a million copies
A
it contains aspects of the life people would like to enjoy
B
it contains the information for the flag language applied in ships
C
it induces a debate about speed limits German
D
it contains the technique for symposia German churches

Choose the correct letter, A , B , C or D .$md$, NULL);

COMMIT;
