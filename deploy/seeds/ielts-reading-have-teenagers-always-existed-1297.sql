BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-have-teenagers-always-existed-1297'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-have-teenagers-always-existed-1297';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-have-teenagers-always-existed-1297';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-have-teenagers-always-existed-1297';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('cd5f7d27-7ca8-521c-b677-354ce53c2f3d', 'ielts-reading-have-teenagers-always-existed-1297', $t$Have teenagers always existed$t$, $md$## Have teenagers always existed

Nguồn:
- Test: https://mini-ielts.com/1297/reading/have-teenagers-always-existed
- Solution: https://mini-ielts.com/1297/view-solution/reading/have-teenagers-always-existed$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('4d80f298-c084-5fee-b4d5-31c2d46406d6', 'cd5f7d27-7ca8-521c-b677-354ce53c2f3d', 1, $t$Reading — Have teenagers always existed$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Have teenagers always existed

Our ancestor, Homo erectus, may not have had culture or even language, but did they have teenagers? That question has been contested in the past few years, with some anthropologists claiming evidence of an adolescent phase in human fossil.This is not merely an academic debate. Humans today are the only animals on Earth to have a teenage phase, yet we have very little idea why. Establishing exactly when adolescence first evolved and finding out what sorts of changes in our bodies and lifestyles it was associated with could help us understand its purpose.Why do we, uniquely, have a growth spurt so late in life? Until recently, the dominant explanation was that physical growth is delayed by our need to grow large brains and to learn all the behaviour patterns associated with humanity – speaking, social interaction and so on. While such behaviour is still developing, humans cannot easily fend for themselves, so it is best to stay small and look youthful.That way your parents and other members of the social group are motivated to continue looking after you.What’s more, studies of mammals show a strong relationship between brain size and the rate of development, with larger-brained animals taking longer to reach adulthood. Humans are at the far end of this spectrum. If this theory is correct, and the development of large brains accounts for the teenage growth spurt, the origin of adolescence should have been with the evolution of our own species (Homo sapiens) and Neanderthals, starting almost 200,000 years ago. The trouble is, some of the fossil evidence seems to tell a different story. The human fossil record is extremely sparse, and the number of fossilised children minuscule. Nevertheless, in the past few years anthropologists have begun to look at what can be learned of the lives of our ancestors from these youngsters. One of the most studied is the famous Turkana boy, an almost complete skeleton of Homo erectus from 1.6 million years ago found in Kenya in 1984. Accurately assessing how old someone is from their skeleton is a tricky business. Even with a modern human, you can only make a rough estimate based on the developmental stage of teeth and bones and the skeleton’s general size. You need as many developmental markers as possible to get an estimate of age.TheTurkana boy’s teeth made him 10 or II years old.The features of his skeleton put him at 13, but he was as tall as a modern 15-year-old. Susan Anton of New York University points to research by Margaret Clegg who studied a collection of 18th- and 19th-century skeletons whose ages at death were known. When she tried to age the skeletons without checking the records, she found similar discrepancies to those of the Turkana boy. One 10-year-old boy, for example, had a dental age of 9, the skeleton of a 6-year-old but was tall enough to be 11. The Turkana kid still has a rounded skull, and needs more growth to reach the adult shape,’ Anton adds. She thinks that Homo erectus had already developed modern human patterns of growth, with a late, if not quite so extreme, adolescent spurt. She believes Turkana boy was just about to enter it. If Anton is right, that theory contradicts the orthodox idea linking late growth with development of a large brain. Anthropologist Steven Leigh from the University of Illinois goes further. He believes the idea of adolescence as catch-up growth does not explain why the growth rate increases so dramatically. He says that many apes have growth spurts in particular body regions that are associated with reaching maturity, and this makes sense because by timing the short but crucial spells of maturation to coincide with the seasons when food is plentiful, they minimise the risk of being without adequate food supplies while growing. What makes humans unique is that the whole skeleton is involved. For Leigh, this is the key. According to his theory, adolescence evolved as an integral part of efficient upright locomotion, as well as to accommodate more complex brains. Fossil evidence suggests that our ancestors first walked on two legs six million years ago. If proficient walking was important for survival, perhaps the teenage growth spurt has very ancient origins. While many anthropologists will consider Leigh’s theory a step too far, he is not the only one with new ideas about the evolution of teenagers. Another approach, which has produced a surprising result, relies on the minute analysis of tooth growth. Every nine days or so the growing teeth of both apes and humans acquire ridges on their enamel surface.These are like rings in a tree trunk: the number of them tells you how long the crown of a tooth took to form. Across mammals, the rate at which teeth develop is closely related to how fast the brain grows and the age you mature. Teeth are good indicators of life history because their growth is less related to the environment and nutrition than is the growth of the skeleton. A more decisive piece of evidence came last year, when researchers in France and Spain published their findings from a study of Neanderthal teeth. Neanderthals had much fester tooth growth than Homo erectus who went before them, and hence, possibly, a shorter childhood. Lead researcher Fernando Ramirez-Rozzi thinks Neanderthals died young – about 25 years old — primarily because of the cold, harsh environment they had to endure in glacial Europe.They evolved to grow up quicker than their immediate ancestors. Neanderthals and Homo erectus probably had to reach adulthood fairly quickly, without delaying for an adolescent growth spurt So it still looks as though we are the original teenagers.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('856c81e4-9a0c-53e9-8aed-9f241012776b', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D
Write the correct letter in boxes 1-4 on your answer sheet.
1) In the first paragraph, why does the writer say ‘This is not merely an academic debate’?
A
Anthropologists’ theories need to be backed up by practical research.
B
There have been some important misunderstandings among anthropologists.
C
The attitudes of anthropologists towards adolescence are changing.
D
The work of anthropologists could inform our understanding of modem adolescence.
2) What was Susan Anton’s opinion of the Turkana boy?
A
He would have experienced an adolescent phase had he lived 2##qi
B
His skull showed he had already reached adulthood 2##qi
C
His skeleton and teeth could not be compared to those from a more modern age.
D
He must have grown much faster than others alive at the time.
3) What point does Steven Leigh make?
A
Different parts of the human skeleton develop at different speeds.
B
The growth period of many apes Is confined to times when there is enough food 3##qi
C
Humans have different rates of development from each other depending on living conditions.
D
The growth phase in most apes lasts longer if more food is available.
4) What can we learn from a mammal’s teeth?
A
A poor diet will cause them to grow more slowly.
B
They are a better indication of lifestyle than a skeleton.
C
Their growing period is difficult to predict accurately.
D
Their speed of growth is directly related to the body’s speed of development.

Choose the correct letter, A, B, C or D Write the correct letter in boxes 1-4 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b5100933-f8be-51ca-829a-abad53cd3b4a', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D
Write the correct letter in boxes 1-4 on your answer sheet.
1) In the first paragraph, why does the writer say ‘This is not merely an academic debate’?
A
Anthropologists’ theories need to be backed up by practical research.
B
There have been some important misunderstandings among anthropologists.
C
The attitudes of anthropologists towards adolescence are changing.
D
The work of anthropologists could inform our understanding of modem adolescence.
2) What was Susan Anton’s opinion of the Turkana boy?
A
He would have experienced an adolescent phase had he lived 2##qi
B
His skull showed he had already reached adulthood 2##qi
C
His skeleton and teeth could not be compared to those from a more modern age.
D
He must have grown much faster than others alive at the time.
3) What point does Steven Leigh make?
A
Different parts of the human skeleton develop at different speeds.
B
The growth period of many apes Is confined to times when there is enough food 3##qi
C
Humans have different rates of development from each other depending on living conditions.
D
The growth phase in most apes lasts longer if more food is available.
4) What can we learn from a mammal’s teeth?
A
A poor diet will cause them to grow more slowly.
B
They are a better indication of lifestyle than a skeleton.
C
Their growing period is difficult to predict accurately.
D
Their speed of growth is directly related to the body’s speed of development.

Choose the correct letter, A, B, C or D Write the correct letter in boxes 1-4 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fd167433-e8a0-5094-8916-720bfb27baca', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D
Write the correct letter in boxes 1-4 on your answer sheet.
1) In the first paragraph, why does the writer say ‘This is not merely an academic debate’?
A
Anthropologists’ theories need to be backed up by practical research.
B
There have been some important misunderstandings among anthropologists.
C
The attitudes of anthropologists towards adolescence are changing.
D
The work of anthropologists could inform our understanding of modem adolescence.
2) What was Susan Anton’s opinion of the Turkana boy?
A
He would have experienced an adolescent phase had he lived 2##qi
B
His skull showed he had already reached adulthood 2##qi
C
His skeleton and teeth could not be compared to those from a more modern age.
D
He must have grown much faster than others alive at the time.
3) What point does Steven Leigh make?
A
Different parts of the human skeleton develop at different speeds.
B
The growth period of many apes Is confined to times when there is enough food 3##qi
C
Humans have different rates of development from each other depending on living conditions.
D
The growth phase in most apes lasts longer if more food is available.
4) What can we learn from a mammal’s teeth?
A
A poor diet will cause them to grow more slowly.
B
They are a better indication of lifestyle than a skeleton.
C
Their growing period is difficult to predict accurately.
D
Their speed of growth is directly related to the body’s speed of development.

Choose the correct letter, A, B, C or D Write the correct letter in boxes 1-4 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d3edb56c-ccee-5987-b1d0-b9db8e73506d', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D
Write the correct letter in boxes 1-4 on your answer sheet.
1) In the first paragraph, why does the writer say ‘This is not merely an academic debate’?
A
Anthropologists’ theories need to be backed up by practical research.
B
There have been some important misunderstandings among anthropologists.
C
The attitudes of anthropologists towards adolescence are changing.
D
The work of anthropologists could inform our understanding of modem adolescence.
2) What was Susan Anton’s opinion of the Turkana boy?
A
He would have experienced an adolescent phase had he lived 2##qi
B
His skull showed he had already reached adulthood 2##qi
C
His skeleton and teeth could not be compared to those from a more modern age.
D
He must have grown much faster than others alive at the time.
3) What point does Steven Leigh make?
A
Different parts of the human skeleton develop at different speeds.
B
The growth period of many apes Is confined to times when there is enough food 3##qi
C
Humans have different rates of development from each other depending on living conditions.
D
The growth phase in most apes lasts longer if more food is available.
4) What can we learn from a mammal’s teeth?
A
A poor diet will cause them to grow more slowly.
B
They are a better indication of lifestyle than a skeleton.
C
Their growing period is difficult to predict accurately.
D
Their speed of growth is directly related to the body’s speed of development.

Choose the correct letter, A, B, C or D Write the correct letter in boxes 1-4 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('947a77ed-1c4d-57cc-9ee6-84374e7be21c', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult for anthropologists to do research on human fossils because they are so rare
6
Modern methods mean it is possible to predict the age of a skeleton with accuracy
7
Susan Anton’s conclusion about the Turkana boy reinforces an established idea
8
Steven Leigh’s ideas are likely to be met with disbelief by many anthropologists
9
Researchers in France and Spain developed a unique method of analysing teeth
10
There has been too little research comparing the brains of Homo erectus and Neanderthals

5 ____ It is difficult for anthropologists to do research on human fossils because they are so rare$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07501d7d-2aa0-5107-923f-c3f87c97105d', '947a77ed-1c4d-57cc-9ee6-84374e7be21c', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc93aec5-fa32-584f-84ad-ac884fb200b4', '947a77ed-1c4d-57cc-9ee6-84374e7be21c', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ade749c-237c-5d30-befb-b5e8b1593539', '947a77ed-1c4d-57cc-9ee6-84374e7be21c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('83f67bd4-68a6-5645-94aa-cbdc480a47fc', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult for anthropologists to do research on human fossils because they are so rare
6
Modern methods mean it is possible to predict the age of a skeleton with accuracy
7
Susan Anton’s conclusion about the Turkana boy reinforces an established idea
8
Steven Leigh’s ideas are likely to be met with disbelief by many anthropologists
9
Researchers in France and Spain developed a unique method of analysing teeth
10
There has been too little research comparing the brains of Homo erectus and Neanderthals

6 ____ Modern methods mean it is possible to predict the age of a skeleton with accuracy$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c11554ea-41e7-5100-9043-ea88f49cc6b6', '83f67bd4-68a6-5645-94aa-cbdc480a47fc', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a33bd0eb-f9e2-57f3-8190-ad3fe69fa551', '83f67bd4-68a6-5645-94aa-cbdc480a47fc', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce3042a4-d00c-5c10-9902-301d9826f5e0', '83f67bd4-68a6-5645-94aa-cbdc480a47fc', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('db10d8ed-b839-5c95-9f43-5d13a91f2273', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult for anthropologists to do research on human fossils because they are so rare
6
Modern methods mean it is possible to predict the age of a skeleton with accuracy
7
Susan Anton’s conclusion about the Turkana boy reinforces an established idea
8
Steven Leigh’s ideas are likely to be met with disbelief by many anthropologists
9
Researchers in France and Spain developed a unique method of analysing teeth
10
There has been too little research comparing the brains of Homo erectus and Neanderthals

7 ____ Susan Anton’s conclusion about the Turkana boy reinforces an established idea$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cf7d69f-9446-57a8-a25b-0f39798f4c5e', 'db10d8ed-b839-5c95-9f43-5d13a91f2273', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1792814f-7916-5016-98b5-d028b21eef03', 'db10d8ed-b839-5c95-9f43-5d13a91f2273', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7b7e6b7-3be7-573f-96c2-3b13fbb72ef2', 'db10d8ed-b839-5c95-9f43-5d13a91f2273', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b27d0512-7151-5f99-b7ff-0d5085f8219f', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult for anthropologists to do research on human fossils because they are so rare
6
Modern methods mean it is possible to predict the age of a skeleton with accuracy
7
Susan Anton’s conclusion about the Turkana boy reinforces an established idea
8
Steven Leigh’s ideas are likely to be met with disbelief by many anthropologists
9
Researchers in France and Spain developed a unique method of analysing teeth
10
There has been too little research comparing the brains of Homo erectus and Neanderthals

8 ____ Steven Leigh’s ideas are likely to be met with disbelief by many anthropologists$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68601fa3-d58b-5cc8-a9f5-5e4e8366eb3b', 'b27d0512-7151-5f99-b7ff-0d5085f8219f', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1563b2d-1426-5de7-8f84-369185379a56', 'b27d0512-7151-5f99-b7ff-0d5085f8219f', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7df6cc1c-f612-525e-afc9-95e97c1af0f3', 'b27d0512-7151-5f99-b7ff-0d5085f8219f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e315b0dc-0f78-54c4-8338-2d5c80709023', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult for anthropologists to do research on human fossils because they are so rare
6
Modern methods mean it is possible to predict the age of a skeleton with accuracy
7
Susan Anton’s conclusion about the Turkana boy reinforces an established idea
8
Steven Leigh’s ideas are likely to be met with disbelief by many anthropologists
9
Researchers in France and Spain developed a unique method of analysing teeth
10
There has been too little research comparing the brains of Homo erectus and Neanderthals

9 ____ Researchers in France and Spain developed a unique method of analysing teeth$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a4aadf6-2593-56ee-87b4-b5bf7a3a457c', 'e315b0dc-0f78-54c4-8338-2d5c80709023', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02cb84b2-8d9a-5494-b356-4c44d9b54f0a', 'e315b0dc-0f78-54c4-8338-2d5c80709023', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4120feb-3a91-5780-8cc5-feb9a0ca4b7f', 'e315b0dc-0f78-54c4-8338-2d5c80709023', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('23d58a49-3801-5162-ba91-1e6a70c1ddaf', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
It is difficult for anthropologists to do research on human fossils because they are so rare
6
Modern methods mean it is possible to predict the age of a skeleton with accuracy
7
Susan Anton’s conclusion about the Turkana boy reinforces an established idea
8
Steven Leigh’s ideas are likely to be met with disbelief by many anthropologists
9
Researchers in France and Spain developed a unique method of analysing teeth
10
There has been too little research comparing the brains of Homo erectus and Neanderthals

10 ____ There has been too little research comparing the brains of Homo erectus and Neanderthals$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('992c3dfb-dde1-5633-8ae3-d35660380fab', '23d58a49-3801-5162-ba91-1e6a70c1ddaf', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1ab2635-3220-59f1-949b-455628dcee8c', '23d58a49-3801-5162-ba91-1e6a70c1ddaf', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e0532e4-384b-51c5-ae18-554dfbdab566', '23d58a49-3801-5162-ba91-1e6a70c1ddaf', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('25099ba2-4deb-57ab-920a-9657f1d6cfe2', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending, A-G, below. Write the correct letter, A-G, in boxes 11-14 on your answer sheet.
11) Until recently, delayed growth in humans until adolescence was felt to be due to
11
12) In her research, Margaret Clegg discovered
12
13) Steven Leigh thought the existence of adolescence is connected to
13
14) Research on Neanderthals suggests that they had short lives because of
14
A.
inconsistencies between height, skeleton and dental evidence.
B.
the fact that human beings walk on two legs.
C.
the way teeth grew.
D.
a need to be dependent on others for survival.
E.
difficult climatic conditions.
F.
increased quantities of food.
G.
the existence of much larger brains than previously.

11) Until recently, delayed growth in humans until adolescence was felt to be due to 11 ____ 12) In her research, Margaret Clegg discovered 12 ____ 13) Steven Leigh thought the existence of adolescence is connected to 13 ____ 14) Research on Neanderthals suggests that they had short lives because of 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fd1a785-eca9-58cf-8b9b-2d5f1fb297cb', '25099ba2-4deb-57ab-920a-9657f1d6cfe2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e4fa2f5-eb72-5273-86be-677a77b2fa94', '25099ba2-4deb-57ab-920a-9657f1d6cfe2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('593be85d-6ac1-585e-8248-abe6497860ff', '25099ba2-4deb-57ab-920a-9657f1d6cfe2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('856d218c-8415-51ed-8a90-3bcf8524508e', '25099ba2-4deb-57ab-920a-9657f1d6cfe2', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12600911-9532-5d24-a342-92588ef99647', '25099ba2-4deb-57ab-920a-9657f1d6cfe2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a652dc2e-22c6-5f58-8f99-8847e7a340f1', '25099ba2-4deb-57ab-920a-9657f1d6cfe2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8fa4ba3-bb9c-5403-b44d-9d1d6ab78580', '25099ba2-4deb-57ab-920a-9657f1d6cfe2', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('83e73b4e-eaee-5921-82f8-8ac7c8d812d0', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending, A-G, below. Write the correct letter, A-G, in boxes 11-14 on your answer sheet.
11) Until recently, delayed growth in humans until adolescence was felt to be due to
11
12) In her research, Margaret Clegg discovered
12
13) Steven Leigh thought the existence of adolescence is connected to
13
14) Research on Neanderthals suggests that they had short lives because of
14
A.
inconsistencies between height, skeleton and dental evidence.
B.
the fact that human beings walk on two legs.
C.
the way teeth grew.
D.
a need to be dependent on others for survival.
E.
difficult climatic conditions.
F.
increased quantities of food.
G.
the existence of much larger brains than previously.

11) Until recently, delayed growth in humans until adolescence was felt to be due to 11 ____ 12) In her research, Margaret Clegg discovered 12 ____ 13) Steven Leigh thought the existence of adolescence is connected to 13 ____ 14) Research on Neanderthals suggests that they had short lives because of 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('958a134d-174f-58bd-9b25-312bf2396d51', '83e73b4e-eaee-5921-82f8-8ac7c8d812d0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29c4caae-1001-5dff-935f-f327853835a3', '83e73b4e-eaee-5921-82f8-8ac7c8d812d0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ec4703c-2bb6-5c2f-bd97-d7295b9b880b', '83e73b4e-eaee-5921-82f8-8ac7c8d812d0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('016dce80-b765-5cd2-b957-6f9b33020cbe', '83e73b4e-eaee-5921-82f8-8ac7c8d812d0', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4e80f8e-078d-583c-bf05-75b4b801cab2', '83e73b4e-eaee-5921-82f8-8ac7c8d812d0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bed778b0-d733-58b5-8445-ee04248ac783', '83e73b4e-eaee-5921-82f8-8ac7c8d812d0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2beb8384-9f46-5a8b-accb-b1262bb9425b', '83e73b4e-eaee-5921-82f8-8ac7c8d812d0', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('443bc5c8-14f1-5ad6-9aea-9f37680d1441', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending, A-G, below. Write the correct letter, A-G, in boxes 11-14 on your answer sheet.
11) Until recently, delayed growth in humans until adolescence was felt to be due to
11
12) In her research, Margaret Clegg discovered
12
13) Steven Leigh thought the existence of adolescence is connected to
13
14) Research on Neanderthals suggests that they had short lives because of
14
A.
inconsistencies between height, skeleton and dental evidence.
B.
the fact that human beings walk on two legs.
C.
the way teeth grew.
D.
a need to be dependent on others for survival.
E.
difficult climatic conditions.
F.
increased quantities of food.
G.
the existence of much larger brains than previously.

11) Until recently, delayed growth in humans until adolescence was felt to be due to 11 ____ 12) In her research, Margaret Clegg discovered 12 ____ 13) Steven Leigh thought the existence of adolescence is connected to 13 ____ 14) Research on Neanderthals suggests that they had short lives because of 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81f47ec3-e714-59ba-a3a4-3747091ba14f', '443bc5c8-14f1-5ad6-9aea-9f37680d1441', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27388d70-1ab3-5fcd-809b-54e2d10ed863', '443bc5c8-14f1-5ad6-9aea-9f37680d1441', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34712974-1784-5da3-ba43-4794fd645d7c', '443bc5c8-14f1-5ad6-9aea-9f37680d1441', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ab0f7bd-019f-5354-b16c-a29257683ec9', '443bc5c8-14f1-5ad6-9aea-9f37680d1441', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b29cd30-2355-5b16-b124-6d8881d7e0ca', '443bc5c8-14f1-5ad6-9aea-9f37680d1441', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2b51c3e-3843-54fb-9682-a825fd6b29a6', '443bc5c8-14f1-5ad6-9aea-9f37680d1441', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3b80703-82fa-53f0-ab06-74366ef6762f', '443bc5c8-14f1-5ad6-9aea-9f37680d1441', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0dfad07a-6747-5cbc-9691-a8abfd174ce7', '4d80f298-c084-5fee-b4d5-31c2d46406d6', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending, A-G, below. Write the correct letter, A-G, in boxes 11-14 on your answer sheet.
11) Until recently, delayed growth in humans until adolescence was felt to be due to
11
12) In her research, Margaret Clegg discovered
12
13) Steven Leigh thought the existence of adolescence is connected to
13
14) Research on Neanderthals suggests that they had short lives because of
14
A.
inconsistencies between height, skeleton and dental evidence.
B.
the fact that human beings walk on two legs.
C.
the way teeth grew.
D.
a need to be dependent on others for survival.
E.
difficult climatic conditions.
F.
increased quantities of food.
G.
the existence of much larger brains than previously.

11) Until recently, delayed growth in humans until adolescence was felt to be due to 11 ____ 12) In her research, Margaret Clegg discovered 12 ____ 13) Steven Leigh thought the existence of adolescence is connected to 13 ____ 14) Research on Neanderthals suggests that they had short lives because of 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('226bd433-daad-524c-8bb6-542a45c2e465', '0dfad07a-6747-5cbc-9691-a8abfd174ce7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7872bb3-f7c0-5849-b422-f5fe9d354989', '0dfad07a-6747-5cbc-9691-a8abfd174ce7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dbcb0df-e781-54d1-9395-f7ae09d4408b', '0dfad07a-6747-5cbc-9691-a8abfd174ce7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b614f5b-00ae-5565-b776-721993650823', '0dfad07a-6747-5cbc-9691-a8abfd174ce7', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ab3d159-e89b-57a3-9903-c01f10a828e5', '0dfad07a-6747-5cbc-9691-a8abfd174ce7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4275e608-fd12-51d9-a673-2a990b64a203', '0dfad07a-6747-5cbc-9691-a8abfd174ce7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9de8518-f26f-59f5-b865-749470f5560e', '0dfad07a-6747-5cbc-9691-a8abfd174ce7', 7, $md$G$md$, false);

COMMIT;
