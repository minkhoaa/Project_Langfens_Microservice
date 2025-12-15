BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-what-are-you-laughing-at-1333'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-what-are-you-laughing-at-1333';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-what-are-you-laughing-at-1333';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-what-are-you-laughing-at-1333';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('fa6cdcc0-e716-57ef-9833-8d97bff3c60a', 'ielts-reading-what-are-you-laughing-at-1333', $t$What are you laughing at?$t$, $md$## What are you laughing at?

Nguồn:
- Test: https://mini-ielts.com/1333/reading/what-are-you-laughing-at
- Solution: https://mini-ielts.com/1333/view-solution/reading/what-are-you-laughing-at$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('76299ee9-f224-5ab0-9001-ba48685e804f', 'fa6cdcc0-e716-57ef-9833-8d97bff3c60a', 1, $t$Reading — What are you laughing at?$t$, $md$Read the passage and answer questions **1–13**.

### Passage: What are you laughing at?

A

We like to think that laughing is the height of human sophistication. Our big brains let us see the humour in a strategically positioned pun, an unexpected plot twist or a clever piece of wordplay. But while joking and wit are uniquely human inventions, laughter certainly is not. Other creatures, including chimpanzees, gorillas and even rats, chuckle. Obviously, they don’t crack up at Homer Simpson or titter at the boss’s dreadful jokes, but the fact that they laugh in the first place suggests that sniggers and chortles have been around for a lot longer than we have. It points the way to the origins of laughter, suggesting a much more practical purpose than you might think.

B

There is no doubt that laughing typical involves groups of people. ‘Laughter evolved as a signal to others – it almost disappears when we are alone,’ says Robert Provine, a neuroscientist at the University of Maryland. Provine found that most laughter comes as a polite reaction to everyday remarks such as ‘see you later’, rather than anything particularly funny. And the way we laugh depends on the company we’re keeping. Men tend to laugh longer and harder when they are with other men, perhaps as a way of bonding. Women tend to laugh more and at a higher pitch when men are present, possibly indicating flirtation or even submission.

C

To find the origins of laughter, Provine believes we need to look at the play. He points out that the masters of laughing are children, and nowhere is their talent more obvious than in the boisterous antics, and the original context plays,’ he says. Well-known primate watchers, including Dian Fossey and Jane Goodall, have long argued that chimps laugh while at play. The sound they produce is known as a panting laugh. It seems obvious when you watch their behavior – they even have the same ticklish spots as we do. But remove the context, and the parallel between human laughter and a chimp’s characteristic pant laugh is not so clear. When Provine played a tape of the pant laughs to 119 of his students, for example, only two guessed correctly what it was.

D

These findings underline how chimp and human laughter vary. When we laugh the sound is usually produced by chopping up a single exhalation into a series of shorter with one sound produced on each inward and outward breath. The question is: does this pant laughter have the same source as our own laughter? New research lends weight to the idea that it does. The findings come from Elke Zimmerman, head of the Institute for Zoology in Germany, who compared the sounds made by babies and chimpanzees in response to tickling during the first year of their life. Using sound spectrographs to reveal the pitch and intensity of vocalizations, she discovered that chimp and human baby laughter follow broadly the same pattern. Zimmerman believes the closeness of baby laughter to chimp laughter supports the idea that laughter was around long before humans arrived on the scene. What started simply as a modification of breathing associated with enjoyable and playful interactions has acquired a symbolic meaning as an indicator of pleasure.

E

Pinpointing when laughter developed is another matter. Humans and chimps share a common ancestor that lived perhaps 8 million years ago, but animals might have been laughing long before that. More distantly related primates, including gorillas, laugh, and anecdotal evidence suggests that other social mammals nay do too. Scientists are currently testing such stories with a comparative analysis of just how common laughter is among animals. So far, though, the most compelling evidence for laughter beyond primates comes from research done by Jaak Panksepp from Bowling Green State University, Ohio, into the ultrasonic chirps produced by rats during play and in response to tickling.

F

All this still doesn’t answer the question of why we laugh at all. One idea is that laughter and tickling originated as a way of sealing the relationship between mother and child. Another is that the reflex response to tickling is protective, alerting us to the presence of crawling creatures that might harm us or compelling us to defend the parts of our bodies that are most vulnerable in hand-to-hand combat. But the idea that has gained most popularity in recent years is that laughter in response to tickling is a way for two individuals to signal and test their trust in one another. This hypothesis starts from the observation that although a little tickle can be enjoyable if it goes on too long it can be torture. By engaging in a bout of tickling, we put ourselves at the mercy of another individual, and laughing is a signal that we laughter is what makes it a reliable signal of trust according to Tom Flamson, a laughter researcher at the University of California, Los Angels. ‘Even in rats, laughter, tickle, play and trust are linked. Rats chirp a lot when they play,’ says Flamson. ‘These chirps can be aroused by tickling. And they get bonded to us as a result, which certainly seems like a show of trust.’

G

We’ll never know which animal laughed the first laugh, or why. But we can be sure it wasn’t in response to a prehistoric joke. The funny thing is that while the origins of laughter are probably quite serious, we owe human laughter and our language-based humor to the same unique skill. While other animals pant, we alone can control our breath well enough to produce the sound of laughter. Without that control, there would also be no speech – and no jokes to endure.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a2152cac-81af-575d-a29b-c68a7add15e8', '76299ee9-f224-5ab0-9001-ba48685e804f', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Look at the following research findings (questions
1-6
) and the list of people below.
Match each finding with the correct person
A
,
B
,
C
or
D
.
Write the correct letter,
A
,
B
,
C
or
D
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
A
Tom Flamson
B
Elke Zimmerman
C
Robert Provine
D
Jaak Panksepp
1
Babies and chimps produce similar sounds of laughter.
2
Primates are not the only animals who produce laughter Pan.
3
Laughter also suggests that we feel safe and easy with others.
4
Laughter is a response to a polite situation instead of humour.
5
Animal laughter evolved before human laughter
6
Laughter is a social activity.

1 ____ Babies and chimps produce similar sounds of laughter.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03085ff3-5b03-527e-a8c5-8471020f3ec3', 'a2152cac-81af-575d-a29b-c68a7add15e8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7679616-a2e7-5429-9e2f-1c67467f5e07', 'a2152cac-81af-575d-a29b-c68a7add15e8', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('450644d5-d250-5e18-8261-f5b8b3efbed0', 'a2152cac-81af-575d-a29b-c68a7add15e8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('037ed755-8094-514a-8c25-5b2c405f2d83', 'a2152cac-81af-575d-a29b-c68a7add15e8', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ba0da2cd-f71a-55da-9ecb-78e246da6b6b', '76299ee9-f224-5ab0-9001-ba48685e804f', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Look at the following research findings (questions
1-6
) and the list of people below.
Match each finding with the correct person
A
,
B
,
C
or
D
.
Write the correct letter,
A
,
B
,
C
or
D
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
A
Tom Flamson
B
Elke Zimmerman
C
Robert Provine
D
Jaak Panksepp
1
Babies and chimps produce similar sounds of laughter.
2
Primates are not the only animals who produce laughter Pan.
3
Laughter also suggests that we feel safe and easy with others.
4
Laughter is a response to a polite situation instead of humour.
5
Animal laughter evolved before human laughter
6
Laughter is a social activity.

2 ____ Primates are not the only animals who produce laughter Pan.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac18c7d1-5bd8-5ba8-93e1-0102bb1f597f', 'ba0da2cd-f71a-55da-9ecb-78e246da6b6b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfc1d8b0-8090-5c73-9ef8-3f68d3cf2af0', 'ba0da2cd-f71a-55da-9ecb-78e246da6b6b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8cffcda4-fc6f-5ddb-b7f0-2b67cd194489', 'ba0da2cd-f71a-55da-9ecb-78e246da6b6b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07ad09e0-880b-5fcd-bc25-63e50a979928', 'ba0da2cd-f71a-55da-9ecb-78e246da6b6b', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e04114ed-eeeb-57a2-b62a-4a733860c72c', '76299ee9-f224-5ab0-9001-ba48685e804f', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Look at the following research findings (questions
1-6
) and the list of people below.
Match each finding with the correct person
A
,
B
,
C
or
D
.
Write the correct letter,
A
,
B
,
C
or
D
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
A
Tom Flamson
B
Elke Zimmerman
C
Robert Provine
D
Jaak Panksepp
1
Babies and chimps produce similar sounds of laughter.
2
Primates are not the only animals who produce laughter Pan.
3
Laughter also suggests that we feel safe and easy with others.
4
Laughter is a response to a polite situation instead of humour.
5
Animal laughter evolved before human laughter
6
Laughter is a social activity.

3 ____ Laughter also suggests that we feel safe and easy with others.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b8530c8-488c-513a-8012-231a42fed66d', 'e04114ed-eeeb-57a2-b62a-4a733860c72c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c06b383b-51d9-5360-89d3-a6abd548e743', 'e04114ed-eeeb-57a2-b62a-4a733860c72c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa14163f-bae3-5a2c-a21b-3e0d87f033d5', 'e04114ed-eeeb-57a2-b62a-4a733860c72c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9c146a1-b437-5cc5-8859-0e3dcef5376d', 'e04114ed-eeeb-57a2-b62a-4a733860c72c', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e06500bd-3177-5fa2-b61e-d8fc5f5c9868', '76299ee9-f224-5ab0-9001-ba48685e804f', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Look at the following research findings (questions
1-6
) and the list of people below.
Match each finding with the correct person
A
,
B
,
C
or
D
.
Write the correct letter,
A
,
B
,
C
or
D
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
A
Tom Flamson
B
Elke Zimmerman
C
Robert Provine
D
Jaak Panksepp
1
Babies and chimps produce similar sounds of laughter.
2
Primates are not the only animals who produce laughter Pan.
3
Laughter also suggests that we feel safe and easy with others.
4
Laughter is a response to a polite situation instead of humour.
5
Animal laughter evolved before human laughter
6
Laughter is a social activity.

4 ____ Laughter is a response to a polite situation instead of humour.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70859646-5ca3-543e-8f4b-718e59daffce', 'e06500bd-3177-5fa2-b61e-d8fc5f5c9868', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4205d94c-9ca1-5eb2-a8e0-da294b35eb6e', 'e06500bd-3177-5fa2-b61e-d8fc5f5c9868', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ad3a5c2-d955-589b-b3b5-0fdd5f1389ef', 'e06500bd-3177-5fa2-b61e-d8fc5f5c9868', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('989ccaf5-e78b-5714-858f-3cac4e542c3f', 'e06500bd-3177-5fa2-b61e-d8fc5f5c9868', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('02baae96-83a5-5225-b748-7b6f342a382d', '76299ee9-f224-5ab0-9001-ba48685e804f', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Look at the following research findings (questions
1-6
) and the list of people below.
Match each finding with the correct person
A
,
B
,
C
or
D
.
Write the correct letter,
A
,
B
,
C
or
D
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
A
Tom Flamson
B
Elke Zimmerman
C
Robert Provine
D
Jaak Panksepp
1
Babies and chimps produce similar sounds of laughter.
2
Primates are not the only animals who produce laughter Pan.
3
Laughter also suggests that we feel safe and easy with others.
4
Laughter is a response to a polite situation instead of humour.
5
Animal laughter evolved before human laughter
6
Laughter is a social activity.

5 ____ Animal laughter evolved before human laughter$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0872a552-8a56-548f-a162-df49eedc6fe4', '02baae96-83a5-5225-b748-7b6f342a382d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72cfdf3d-4d40-5108-84de-a823d7503d75', '02baae96-83a5-5225-b748-7b6f342a382d', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae586253-6419-5e69-91f9-849e433a3591', '02baae96-83a5-5225-b748-7b6f342a382d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b6b60ec-db01-5c94-9c7e-12834a334605', '02baae96-83a5-5225-b748-7b6f342a382d', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('14937194-3005-57da-a594-b8c9976f0806', '76299ee9-f224-5ab0-9001-ba48685e804f', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Look at the following research findings (questions
1-6
) and the list of people below.
Match each finding with the correct person
A
,
B
,
C
or
D
.
Write the correct letter,
A
,
B
,
C
or
D
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
A
Tom Flamson
B
Elke Zimmerman
C
Robert Provine
D
Jaak Panksepp
1
Babies and chimps produce similar sounds of laughter.
2
Primates are not the only animals who produce laughter Pan.
3
Laughter also suggests that we feel safe and easy with others.
4
Laughter is a response to a polite situation instead of humour.
5
Animal laughter evolved before human laughter
6
Laughter is a social activity.

6 ____ Laughter is a social activity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3661503d-44fe-5323-a294-49798e4b4213', '14937194-3005-57da-a594-b8c9976f0806', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86e02bac-eee3-5a0e-9458-dfee160dd1b7', '14937194-3005-57da-a594-b8c9976f0806', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71b5d517-5393-50e4-be8c-d79faf404bef', '14937194-3005-57da-a594-b8c9976f0806', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51560194-472e-5d99-a3fc-fefffdf6e311', '14937194-3005-57da-a594-b8c9976f0806', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f41acb9c-8a95-50d2-80a6-4c38a49efc3a', '76299ee9-f224-5ab0-9001-ba48685e804f', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Complete the summary using the list of words,
A-K
, below.
Write the correct letter,
A-K
, in boxes
7-10
on your answer sheet.
Some researchers believe that laughter first evolved out of
7
. The investigation has revealed that human and chimp laughter may have the same
8
. Besides, scientists have been aware that
9
laugh, however, it now seems that laughter might be more widespread than once we thought. Although the reasons why humans started to laugh are still unknown, it seems that laughter may result from the
10
we feel with another person.
A
evolution
B
chirps
C
origins
D
voice
E
confidence
F
rats
G
primates
H
response
I
play
J
children
K
tickling

Some researchers believe that laughter first evolved out of 7 ____ . The investigation has revealed that human and chimp laughter may have the same 8 ____ . Besides, scientists have been aware that 9 ____ laugh, however, it now seems that laughter might be more widespread than once we thought. Although the reasons why humans started to laugh are still unknown, it seems that laughter may result from the 10 ____ we feel with another person.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4aae5bd3-80fb-5e83-a1be-8197dddd29d6', 'f41acb9c-8a95-50d2-80a6-4c38a49efc3a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('188aee7f-c342-5f11-9a81-2b4933a9bcef', 'f41acb9c-8a95-50d2-80a6-4c38a49efc3a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ee02891-1dd1-5eb9-b1cb-127e707051f8', 'f41acb9c-8a95-50d2-80a6-4c38a49efc3a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7741fa6e-679c-5491-9c96-d63f377a35f4', 'f41acb9c-8a95-50d2-80a6-4c38a49efc3a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fb5250a-6f7a-5463-abd3-7f8a4d49aac7', 'f41acb9c-8a95-50d2-80a6-4c38a49efc3a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3173cc65-39af-569d-89ea-3af953487fbd', 'f41acb9c-8a95-50d2-80a6-4c38a49efc3a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b74b76a-10ef-538f-a88d-9f6625fccb66', 'f41acb9c-8a95-50d2-80a6-4c38a49efc3a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdf0a9d1-0bd2-55a3-b333-e28ab7bb6310', 'f41acb9c-8a95-50d2-80a6-4c38a49efc3a', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea454043-04fb-50ac-a3cd-031368443e19', 'f41acb9c-8a95-50d2-80a6-4c38a49efc3a', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c95d028e-3f55-5a9e-8752-280b33bb1423', 'f41acb9c-8a95-50d2-80a6-4c38a49efc3a', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd53c6e0-deaa-5f4e-a19c-b6c21081a47c', 'f41acb9c-8a95-50d2-80a6-4c38a49efc3a', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('11ffe261-4077-5f60-b472-b60725a75271', '76299ee9-f224-5ab0-9001-ba48685e804f', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Complete the summary using the list of words,
A-K
, below.
Write the correct letter,
A-K
, in boxes
7-10
on your answer sheet.
Some researchers believe that laughter first evolved out of
7
. The investigation has revealed that human and chimp laughter may have the same
8
. Besides, scientists have been aware that
9
laugh, however, it now seems that laughter might be more widespread than once we thought. Although the reasons why humans started to laugh are still unknown, it seems that laughter may result from the
10
we feel with another person.
A
evolution
B
chirps
C
origins
D
voice
E
confidence
F
rats
G
primates
H
response
I
play
J
children
K
tickling

Some researchers believe that laughter first evolved out of 7 ____ . The investigation has revealed that human and chimp laughter may have the same 8 ____ . Besides, scientists have been aware that 9 ____ laugh, however, it now seems that laughter might be more widespread than once we thought. Although the reasons why humans started to laugh are still unknown, it seems that laughter may result from the 10 ____ we feel with another person.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc888b68-b4ab-5709-adbb-e3e39ef65f2f', '11ffe261-4077-5f60-b472-b60725a75271', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc85e061-816f-5823-83a8-0177b51cb5ed', '11ffe261-4077-5f60-b472-b60725a75271', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33e40bfe-533c-5fd5-961f-d6ddad5ca7d5', '11ffe261-4077-5f60-b472-b60725a75271', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('169174d6-3c9a-5c66-bc7d-89a88b83bf31', '11ffe261-4077-5f60-b472-b60725a75271', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1e2eb46-df00-5e87-ab9f-2e95b4b7eafa', '11ffe261-4077-5f60-b472-b60725a75271', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90884434-9660-54ee-9f88-8a781ea0079f', '11ffe261-4077-5f60-b472-b60725a75271', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d106759-89bd-5db4-b165-b86c7dc5f14a', '11ffe261-4077-5f60-b472-b60725a75271', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b472f989-1046-5595-8ad0-4a6bff276cc8', '11ffe261-4077-5f60-b472-b60725a75271', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa9d8d53-5bd4-563d-abb8-452a11714d3b', '11ffe261-4077-5f60-b472-b60725a75271', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7406ea45-338c-50bb-9ba2-66585d73e48f', '11ffe261-4077-5f60-b472-b60725a75271', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10de6666-33e5-58fc-a73f-efcdc18306d1', '11ffe261-4077-5f60-b472-b60725a75271', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('47865e78-8206-5b46-8b5e-81da317229fb', '76299ee9-f224-5ab0-9001-ba48685e804f', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Complete the summary using the list of words,
A-K
, below.
Write the correct letter,
A-K
, in boxes
7-10
on your answer sheet.
Some researchers believe that laughter first evolved out of
7
. The investigation has revealed that human and chimp laughter may have the same
8
. Besides, scientists have been aware that
9
laugh, however, it now seems that laughter might be more widespread than once we thought. Although the reasons why humans started to laugh are still unknown, it seems that laughter may result from the
10
we feel with another person.
A
evolution
B
chirps
C
origins
D
voice
E
confidence
F
rats
G
primates
H
response
I
play
J
children
K
tickling

Some researchers believe that laughter first evolved out of 7 ____ . The investigation has revealed that human and chimp laughter may have the same 8 ____ . Besides, scientists have been aware that 9 ____ laugh, however, it now seems that laughter might be more widespread than once we thought. Although the reasons why humans started to laugh are still unknown, it seems that laughter may result from the 10 ____ we feel with another person.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a67bfd34-3793-5b4b-ba87-caedc238fa8d', '47865e78-8206-5b46-8b5e-81da317229fb', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6246d26a-cf05-587f-bc69-e14967827462', '47865e78-8206-5b46-8b5e-81da317229fb', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6aeadd1-8d76-54c0-ac76-364da660ea8a', '47865e78-8206-5b46-8b5e-81da317229fb', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c671ef3c-2422-5da8-8d6b-b723f2f34e94', '47865e78-8206-5b46-8b5e-81da317229fb', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33e3ca9e-81ef-56ba-a247-0a7bdcbea0fa', '47865e78-8206-5b46-8b5e-81da317229fb', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3142e89-aaa0-58c3-b3bc-0adae04013ce', '47865e78-8206-5b46-8b5e-81da317229fb', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be67a3be-fad6-55d3-ba80-4f4cf0c3a8b7', '47865e78-8206-5b46-8b5e-81da317229fb', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('573e975f-6aff-580f-856c-0307e6bcf1a5', '47865e78-8206-5b46-8b5e-81da317229fb', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d47187c0-dc45-5cc7-87cc-f2659b434a98', '47865e78-8206-5b46-8b5e-81da317229fb', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a66026e7-55e6-50f0-8c88-67454e6ac748', '47865e78-8206-5b46-8b5e-81da317229fb', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e69a30f-4c4e-5269-8a52-e189c8de425d', '47865e78-8206-5b46-8b5e-81da317229fb', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fb015715-8419-526c-bbb0-61681001ccd0', '76299ee9-f224-5ab0-9001-ba48685e804f', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Complete the summary using the list of words,
A-K
, below.
Write the correct letter,
A-K
, in boxes
7-10
on your answer sheet.
Some researchers believe that laughter first evolved out of
7
. The investigation has revealed that human and chimp laughter may have the same
8
. Besides, scientists have been aware that
9
laugh, however, it now seems that laughter might be more widespread than once we thought. Although the reasons why humans started to laugh are still unknown, it seems that laughter may result from the
10
we feel with another person.
A
evolution
B
chirps
C
origins
D
voice
E
confidence
F
rats
G
primates
H
response
I
play
J
children
K
tickling

Some researchers believe that laughter first evolved out of 7 ____ . The investigation has revealed that human and chimp laughter may have the same 8 ____ . Besides, scientists have been aware that 9 ____ laugh, however, it now seems that laughter might be more widespread than once we thought. Although the reasons why humans started to laugh are still unknown, it seems that laughter may result from the 10 ____ we feel with another person.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27d061c4-c2b7-5277-a13b-782ed3328816', 'fb015715-8419-526c-bbb0-61681001ccd0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75a770b6-cf24-5c18-b679-3869ed63cd98', 'fb015715-8419-526c-bbb0-61681001ccd0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79930196-4730-5dd7-a4f0-78dc240ad6da', 'fb015715-8419-526c-bbb0-61681001ccd0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31674023-1f79-5101-a7b5-054df8b2c052', 'fb015715-8419-526c-bbb0-61681001ccd0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('921518e8-a9c9-5e49-a107-8ce67b60cc13', 'fb015715-8419-526c-bbb0-61681001ccd0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5ffb634-1a4f-5fcc-aef1-b2f2adf2f355', 'fb015715-8419-526c-bbb0-61681001ccd0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65115770-63f6-5696-a53c-e972fadfd0de', 'fb015715-8419-526c-bbb0-61681001ccd0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5afec84-b8da-542a-9b6e-3c8015e5e65f', 'fb015715-8419-526c-bbb0-61681001ccd0', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fec4a4ce-9c23-5ce6-b4ed-cfcb1b1cab85', 'fb015715-8419-526c-bbb0-61681001ccd0', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9576c156-5993-5ea8-bdae-990db19d2626', 'fb015715-8419-526c-bbb0-61681001ccd0', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce944178-add7-5c6b-8618-ddae73e5c811', 'fb015715-8419-526c-bbb0-61681001ccd0', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ed327b7f-aab3-508d-8ca7-76e54258d76a', '76299ee9-f224-5ab0-9001-ba48685e804f', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
11-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
11
Both men and women laugh more when they are with members of the same sex.
12
Primates lack sufficient breath control to be able to produce laughs the way humans do.
13
Chimpanzees produce laughter in a wider range of situations than rats do.

11 ____ Both men and women laugh more when they are with members of the same sex.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3ce9721-1e3c-50e1-9e3d-169850b491db', 'ed327b7f-aab3-508d-8ca7-76e54258d76a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e72ea4a9-806d-53f8-b8af-06b962c6ac6b', 'ed327b7f-aab3-508d-8ca7-76e54258d76a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7324c0a6-7a03-5ab5-9ab8-59ff2fb2b245', 'ed327b7f-aab3-508d-8ca7-76e54258d76a', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7fe1306c-a314-5c2b-b759-44ab4c0e2851', '76299ee9-f224-5ab0-9001-ba48685e804f', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
11-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
11
Both men and women laugh more when they are with members of the same sex.
12
Primates lack sufficient breath control to be able to produce laughs the way humans do.
13
Chimpanzees produce laughter in a wider range of situations than rats do.

12 ____ Primates lack sufficient breath control to be able to produce laughs the way humans do.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('565adaee-2967-5b25-9408-abeca9bb9c45', '7fe1306c-a314-5c2b-b759-44ab4c0e2851', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0754907-ee09-54ff-83d3-d36cdbff3d09', '7fe1306c-a314-5c2b-b759-44ab4c0e2851', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95fe6135-9555-54fd-b51e-d6f170c4a443', '7fe1306c-a314-5c2b-b759-44ab4c0e2851', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4827ebe4-dbfb-5ca4-9872-d1f9533e58e8', '76299ee9-f224-5ab0-9001-ba48685e804f', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
11-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
11
Both men and women laugh more when they are with members of the same sex.
12
Primates lack sufficient breath control to be able to produce laughs the way humans do.
13
Chimpanzees produce laughter in a wider range of situations than rats do.

13 ____ Chimpanzees produce laughter in a wider range of situations than rats do.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd3f3e84-eec5-55f5-9654-a5aad21ab352', '4827ebe4-dbfb-5ca4-9872-d1f9533e58e8', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('645e67bd-5d8c-5d02-8858-e8c4ca5d850e', '4827ebe4-dbfb-5ca4-9872-d1f9533e58e8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e19a66ed-e9e5-5ea7-8534-471213e4ef6f', '4827ebe4-dbfb-5ca4-9872-d1f9533e58e8', 3, $md$NOT GIVEN$md$, true);

COMMIT;
