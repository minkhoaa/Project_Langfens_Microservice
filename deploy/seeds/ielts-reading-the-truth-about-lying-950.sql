BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-truth-about-lying-950'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-truth-about-lying-950';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-truth-about-lying-950';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-truth-about-lying-950';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('dd6bf00a-ed47-509e-94ab-8e969e3a4795', 'ielts-reading-the-truth-about-lying-950', $t$The truth about lying$t$, $md$## The truth about lying

Nguồn:
- Test: https://mini-ielts.com/950/reading/the-truth-about-lying
- Solution: https://mini-ielts.com/950/view-solution/reading/the-truth-about-lying$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 'dd6bf00a-ed47-509e-94ab-8e969e3a4795', 1, $t$Reading — The truth about lying$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The truth about lying

Over the years Richard Wiseman has tried to unravel the truth about deception - investigating the signs that give away a liar.

A - Do only humans lie?

In the 1970s, as part of a large-scale research programme exploring the area of Interspecies communication, Dr Francine Patterson from Stanford University attempted to teach two lowland gorillas called Michael and Koko a simplified version of Sign Language. According to Patterson, the great apes were capable of holding meaningful conversations, and could even reflect upon profound topics, such as love and death. During the project, their trainers believe they uncovered instances where the two gorillas' linguistic skills seemed to provide reliable evidence of intentional deceit. In one example, Koko broke a toy cat , and then signed to indicate that the breakage had been caused by one of her trainers .

In another episode, Michael ripped a jacket belonging to a trainer and, when asked who was responsible for the incident, signed ‘Koko’ . When the trainer expressed some scepticism, Michael appeared to change his mind, and indicated that Dr Patterson was actually responsible, before finally confessing.

B - When do we begin to lie?

Other researchers have explored the development of deception in children. Some of the most interesting experiments have involved asking youngsters not to take a peek at their favourite toys. During these studies, a child is led into a laboratory and asked to face one of the walls. The experimenter then explains that he is going to set up an elaborate toy a few feet behind them. After setting up the toy, the experimenter says that he has to leave the laboratory, and asks the child not to turn around and peek at the toy. The child is secretly filmed by hidden cameras for a few minutes, and then the experimenter returns and asks them whether they peeked. Almost all three-year do , and then half of them lie about it to the experimenter. By the time the children have reached the age of five, all of them peek and all of them lie . The results provide compelling evidence that lying starts to emerge the moment we learn to speak.

C - A public test of our ability to spot a lie

So what are the tell-tale signs that give away a lie? In 1994, the psychologist Richard Wiseman devised a large-scale experiment on a TV programme called Tomorrow's World. As part of the experiment, viewers watched two interviews in which Wiseman asked a presenter in front of the cameras to describe his favourite film. In one interview, the presenter picked Some Like It Hot and he told the truth; in the other interview, he picked Gone with the Wind and lied. The viewers were then invited to make a choice - to telephone in to say which film he was lying about. More than 30,000 calls were received, but viewers were unable to tell the difference and the vote was a 50/50 split. In similar experiments, the results have been remarkably consistent - when it comes to lie detection, people might as well simply toss a coin. It doesn’t matter if you are male or female, young or old; very few people are able to detect deception.

D - Exposing some false beliefs

Why is this? Professor Charles Bond from the Texas Christian University has conducted surveys into the sorts of behaviour people associate with lying. He has interviewed thousands of people from more than 60 countries, asking them to describe how they set about telling whether someone is lying. People’s answers are remarkably consistent. Almost everyone thinks liars tend to avert their gaze, nervously wave their hands around and shift about in their seats. There is, however, one small problem. Researchers have spent hour upon hour carefully comparing films of liars and truth-tellers. The results are clear. Liars do not necessarily look away from you ; they do not appear nervous and move their hands around or shift about in their seats. People fail to detect lies because they are basing their opinions on behaviours that are not actually associated with deception.

E - Some of the things liars really do

So what are we missing? It is obvious that the more information you give away, the greater the chances of some of it coming back to haunt you. As a result, liars tend to say less and provide fewer details than truth-tellers. Looking back at the transcripts of the interviews with the presenter, his lie about Gone with the Wind contained about 40 words, whereas the truth about Some Like It Hot was nearly twice as long. People who lie also try psychologically to keep a distance from their falsehoods, and so tend to include fewer references to themselves in their stories. In his entire interview about Gone with the Wind, the presenter only once mentioned how the film made him feel, compared with the several references to his feelings when he talked about Some Like It Hot.

F - Which form of communication best exposes a lie?

The simple fact is that the real clues to deceit are in the words that people use, not the body language. So do people become better lie detectors when they listen to a liar, or even just read a transcript of their comments? The interviews with the presenter were also broadcast on radio and published in a newspaper, and although the lie-detecting abilities of the television viewers were no better than chance, the newspaper readers were correct 64% of the time, and the radio listeners scored an impressive 73% accuracy rate.

adapted from The National Newspaper$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7a6adfcd-7c66-5e33-a159-3b4aa7712b8c', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
.
Choose the correct heading for each paragraph from the list of headings below.
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
List of headings
i
Some of the things liars really do
ii
When do we begin to lie?
iii
How wrong is it to lie?
iv
Exposing some false beliefs
v
Which form of communication best exposes a lie?
vi
Do only humans lie?
vii
Dealing with known liars
viii
A public test of our ability to spot a lie

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('955ef034-f7df-520b-8fb2-ec578a6fa182', '7a6adfcd-7c66-5e33-a159-3b4aa7712b8c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc59011f-a27b-5899-aebc-0beb23fd7438', '7a6adfcd-7c66-5e33-a159-3b4aa7712b8c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5ffb2c8-285e-536c-81a0-b3ff5c5c5074', '7a6adfcd-7c66-5e33-a159-3b4aa7712b8c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('778c7994-9b7e-5af0-a825-93427e6629df', '7a6adfcd-7c66-5e33-a159-3b4aa7712b8c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68b5f0f7-87c8-52f0-bbb1-826f9d0c18ec', '7a6adfcd-7c66-5e33-a159-3b4aa7712b8c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80b2ce6d-57ba-5e19-88fd-8fd77c8e51fc', '7a6adfcd-7c66-5e33-a159-3b4aa7712b8c', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5276a311-5611-5b1d-b371-6c377688732a', '7a6adfcd-7c66-5e33-a159-3b4aa7712b8c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc58de21-4f23-5044-8c7e-74dabb0cf7d8', '7a6adfcd-7c66-5e33-a159-3b4aa7712b8c', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b501c849-6ad3-550a-a47b-fc4cfc72d06c', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
.
Choose the correct heading for each paragraph from the list of headings below.
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
List of headings
i
Some of the things liars really do
ii
When do we begin to lie?
iii
How wrong is it to lie?
iv
Exposing some false beliefs
v
Which form of communication best exposes a lie?
vi
Do only humans lie?
vii
Dealing with known liars
viii
A public test of our ability to spot a lie

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc0c8d0e-8558-51b9-9878-a2ab2f76c561', 'b501c849-6ad3-550a-a47b-fc4cfc72d06c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ee86317-b0a7-552c-beda-6808f0662742', 'b501c849-6ad3-550a-a47b-fc4cfc72d06c', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49aa6496-0e57-5901-9cbb-a51b392ab4c4', 'b501c849-6ad3-550a-a47b-fc4cfc72d06c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6f7432a-ac46-5edd-b153-f5e45558d9ac', 'b501c849-6ad3-550a-a47b-fc4cfc72d06c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61c56a41-14d1-59f1-afc6-9e462468412c', 'b501c849-6ad3-550a-a47b-fc4cfc72d06c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efb62c1d-7ced-5810-9999-b308a391bfe0', 'b501c849-6ad3-550a-a47b-fc4cfc72d06c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4575305-a601-57ed-b9d2-e5df3ebe14e3', 'b501c849-6ad3-550a-a47b-fc4cfc72d06c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10f92b1b-3b98-5fca-9cee-392647ca0c52', 'b501c849-6ad3-550a-a47b-fc4cfc72d06c', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6d785182-a860-5773-ac29-a70ed13077dc', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
.
Choose the correct heading for each paragraph from the list of headings below.
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
List of headings
i
Some of the things liars really do
ii
When do we begin to lie?
iii
How wrong is it to lie?
iv
Exposing some false beliefs
v
Which form of communication best exposes a lie?
vi
Do only humans lie?
vii
Dealing with known liars
viii
A public test of our ability to spot a lie

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e2da245-2dd7-56ee-a9eb-bdb65037a6bd', '6d785182-a860-5773-ac29-a70ed13077dc', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5df05e33-3cd0-534e-8fee-ac7c3ada6b71', '6d785182-a860-5773-ac29-a70ed13077dc', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47b08f84-c66b-5ee7-a6ee-e6eb21f435b4', '6d785182-a860-5773-ac29-a70ed13077dc', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b501d7d-9cb2-58ca-bb4b-cc01241c767a', '6d785182-a860-5773-ac29-a70ed13077dc', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78c7ea40-ddbe-5a41-b551-6e41a9fc3105', '6d785182-a860-5773-ac29-a70ed13077dc', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e4b426a-395c-5ccf-a9ab-40dbad831723', '6d785182-a860-5773-ac29-a70ed13077dc', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c29cdc6-5044-5ddc-acff-cebcc1ae1ea4', '6d785182-a860-5773-ac29-a70ed13077dc', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fce24e93-8d02-531c-8c3d-8f886e03b716', '6d785182-a860-5773-ac29-a70ed13077dc', 8, $md$viii$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('792924d6-c13e-5f11-aa66-d10147aa8f2a', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
.
Choose the correct heading for each paragraph from the list of headings below.
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
List of headings
i
Some of the things liars really do
ii
When do we begin to lie?
iii
How wrong is it to lie?
iv
Exposing some false beliefs
v
Which form of communication best exposes a lie?
vi
Do only humans lie?
vii
Dealing with known liars
viii
A public test of our ability to spot a lie

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fe65554-7553-5e5c-81e3-aedee6606250', '792924d6-c13e-5f11-aa66-d10147aa8f2a', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf0a86be-51e3-5e64-a039-adf64569b8a0', '792924d6-c13e-5f11-aa66-d10147aa8f2a', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3be0f7e7-8a1a-53d2-9c98-ab0f9dfe5046', '792924d6-c13e-5f11-aa66-d10147aa8f2a', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('219fdc93-e85d-500e-82a7-725e2d60d2bd', '792924d6-c13e-5f11-aa66-d10147aa8f2a', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07b3970e-2507-57c3-81fc-ee61028efaee', '792924d6-c13e-5f11-aa66-d10147aa8f2a', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('537625e8-b15b-5548-8e06-5da088f36723', '792924d6-c13e-5f11-aa66-d10147aa8f2a', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ed25250-b950-557d-8ca7-6dee692d2f74', '792924d6-c13e-5f11-aa66-d10147aa8f2a', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b557a674-5eba-519a-b8f5-0788077d575b', '792924d6-c13e-5f11-aa66-d10147aa8f2a', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f15ce579-8d3b-5f2a-886f-457933d564ea', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
.
Choose the correct heading for each paragraph from the list of headings below.
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
List of headings
i
Some of the things liars really do
ii
When do we begin to lie?
iii
How wrong is it to lie?
iv
Exposing some false beliefs
v
Which form of communication best exposes a lie?
vi
Do only humans lie?
vii
Dealing with known liars
viii
A public test of our ability to spot a lie

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2f46da4-afa0-5ad6-9285-ae0a90630987', 'f15ce579-8d3b-5f2a-886f-457933d564ea', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f887a73-104c-5b05-862c-cc80f0891938', 'f15ce579-8d3b-5f2a-886f-457933d564ea', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2653373-156a-5c4e-9b15-57fb62a330fd', 'f15ce579-8d3b-5f2a-886f-457933d564ea', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9125fdb9-4b62-5a89-a21b-20125451b4da', 'f15ce579-8d3b-5f2a-886f-457933d564ea', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41565af8-7132-5c14-af05-ba778db6337f', 'f15ce579-8d3b-5f2a-886f-457933d564ea', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a125f6ca-d449-5bcf-8b77-d33163af76e7', 'f15ce579-8d3b-5f2a-886f-457933d564ea', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b67ed4ed-7ff6-5516-8758-cb625ee41107', 'f15ce579-8d3b-5f2a-886f-457933d564ea', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('269ca09d-158b-5fa5-ad90-cd1ce204c7b4', 'f15ce579-8d3b-5f2a-886f-457933d564ea', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a7f6a9cc-2b9a-507a-9b3f-a48fa3b33bcf', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
.
Choose the correct heading for each paragraph from the list of headings below.
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
List of headings
i
Some of the things liars really do
ii
When do we begin to lie?
iii
How wrong is it to lie?
iv
Exposing some false beliefs
v
Which form of communication best exposes a lie?
vi
Do only humans lie?
vii
Dealing with known liars
viii
A public test of our ability to spot a lie

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c65c3cd-f28b-5039-b8dd-0395c2192cf5', 'a7f6a9cc-2b9a-507a-9b3f-a48fa3b33bcf', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb13a994-67e0-52cb-9dc4-d27b722dc225', 'a7f6a9cc-2b9a-507a-9b3f-a48fa3b33bcf', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d77b2b3-7aaa-5b6c-9dd2-f3eae9ce8f6d', 'a7f6a9cc-2b9a-507a-9b3f-a48fa3b33bcf', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c549c58b-96cf-5113-b4af-694bfb6d86f3', 'a7f6a9cc-2b9a-507a-9b3f-a48fa3b33bcf', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f80c7bc-7f64-56e5-88a8-c7aa6a93de75', 'a7f6a9cc-2b9a-507a-9b3f-a48fa3b33bcf', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09c0d0a4-387a-5e85-ba62-9a8f2b87ad8d', 'a7f6a9cc-2b9a-507a-9b3f-a48fa3b33bcf', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c05ad6c-9e3a-5f82-8ab3-e3be94ca4f24', 'a7f6a9cc-2b9a-507a-9b3f-a48fa3b33bcf', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e58fb8c2-6789-57da-b6c8-aef636d5cd11', 'a7f6a9cc-2b9a-507a-9b3f-a48fa3b33bcf', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f2f04508-de8c-5429-a4d6-44737d477ca0', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Look at the following statements and the list of experiments below.
Match each statement with the correct experiment,
A-C
.
You may use any letter
more than once
.
7
Someone who was innocent was blamed for something.
8
Those involved knew they were being filmed.
9
Some objects were damaged.
10
Some instructions were ignored.
List of Experiments
A
the gorilla experiment
B
the experiment with children
C
the TV experiment

7 ____ Someone who was innocent was blamed for something.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07318b78-98f2-5d16-b94b-42ad2174f15b', 'f2f04508-de8c-5429-a4d6-44737d477ca0', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('648c12b5-f89d-52f6-af6e-43986a01a494', 'f2f04508-de8c-5429-a4d6-44737d477ca0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8152ffb-5ca6-5e0f-8ab7-ee4aad92273f', 'f2f04508-de8c-5429-a4d6-44737d477ca0', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b6e01c38-934e-5a79-ac48-c12d1d774e76', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Look at the following statements and the list of experiments below.
Match each statement with the correct experiment,
A-C
.
You may use any letter
more than once
.
7
Someone who was innocent was blamed for something.
8
Those involved knew they were being filmed.
9
Some objects were damaged.
10
Some instructions were ignored.
List of Experiments
A
the gorilla experiment
B
the experiment with children
C
the TV experiment

8 ____ Those involved knew they were being filmed.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbe8f328-c5ac-5829-94ef-08e9fe0e26b2', 'b6e01c38-934e-5a79-ac48-c12d1d774e76', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1be827ec-acf0-5d3c-827e-fde64e7f0173', 'b6e01c38-934e-5a79-ac48-c12d1d774e76', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ecb85c1-58dd-5a09-af91-55b07c9d4cdd', 'b6e01c38-934e-5a79-ac48-c12d1d774e76', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6f2ddd0a-f0b5-55c9-9d01-6c75a4f68737', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Look at the following statements and the list of experiments below.
Match each statement with the correct experiment,
A-C
.
You may use any letter
more than once
.
7
Someone who was innocent was blamed for something.
8
Those involved knew they were being filmed.
9
Some objects were damaged.
10
Some instructions were ignored.
List of Experiments
A
the gorilla experiment
B
the experiment with children
C
the TV experiment

9 ____ Some objects were damaged.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c5b8ac5-199d-59ee-9301-0e6e7209bb0d', '6f2ddd0a-f0b5-55c9-9d01-6c75a4f68737', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef4fb1a6-e90c-595a-80c7-280d2af28d93', '6f2ddd0a-f0b5-55c9-9d01-6c75a4f68737', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd835390-78ed-5ef7-a976-0d93eccdb10e', '6f2ddd0a-f0b5-55c9-9d01-6c75a4f68737', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7d406f6d-d01a-5da9-b82e-3a11870db1c8', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Look at the following statements and the list of experiments below.
Match each statement with the correct experiment,
A-C
.
You may use any letter
more than once
.
7
Someone who was innocent was blamed for something.
8
Those involved knew they were being filmed.
9
Some objects were damaged.
10
Some instructions were ignored.
List of Experiments
A
the gorilla experiment
B
the experiment with children
C
the TV experiment

10 ____ Some instructions were ignored.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4168c201-0260-54fb-ad98-a831316576f6', '7d406f6d-d01a-5da9-b82e-3a11870db1c8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a261cf4-daa1-578e-9e9c-cbcb198e0b60', '7d406f6d-d01a-5da9-b82e-3a11870db1c8', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d65b161a-45b6-5d8d-9e77-a75e5e185314', '7d406f6d-d01a-5da9-b82e-3a11870db1c8', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('336fe5e4-8876-578c-9ca3-61e47fd90cf7', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for
each answer.
11
Filming liars has shown that they do not
display
behaviour.
12
Liars tend to avoid talking about their own
13
Signs of lying are exposed in people’s
rather than their movements.

11 Filming liars has shown that they do not display ____ behaviour.$md$, NULL, ARRAY['.*nervous.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a5112d77-74e7-5893-92da-86d7c3c566a7', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for
each answer.
11
Filming liars has shown that they do not
display
behaviour.
12
Liars tend to avoid talking about their own
13
Signs of lying are exposed in people’s
rather than their movements.

12 Liars tend to avoid talking about their own ____$md$, NULL, ARRAY['.*feelings.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3a027b21-4a90-59c5-9078-6284df8c9b76', '1a929fc1-ba19-55d3-8051-fec3c0fbf8a9', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for
each answer.
11
Filming liars has shown that they do not
display
behaviour.
12
Liars tend to avoid talking about their own
13
Signs of lying are exposed in people’s
rather than their movements.

13 Signs of lying are exposed in people’s ____ rather than their movements.$md$, NULL, ARRAY['.*words.*']);

COMMIT;
