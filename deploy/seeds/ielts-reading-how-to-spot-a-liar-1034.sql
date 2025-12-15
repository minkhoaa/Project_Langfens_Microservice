BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-how-to-spot-a-liar-1034'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-to-spot-a-liar-1034';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-to-spot-a-liar-1034';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-how-to-spot-a-liar-1034';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('99e821a0-064f-5ae3-8e5c-a138a48203c0', 'ielts-reading-how-to-spot-a-liar-1034', $t$How to Spot a Liar$t$, $md$## How to Spot a Liar

Nguồn:
- Test: https://mini-ielts.com/1034/reading/how-to-spot-a-liar
- Solution: https://mini-ielts.com/1034/view-solution/reading/how-to-spot-a-liar$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('582a4237-52c3-50c6-97fc-8d918e2d06bd', '99e821a0-064f-5ae3-8e5c-a138a48203c0', 1, $t$Reading — How to Spot a Liar$t$, $md$Read the passage and answer questions **1–13**.

### Passage: How to Spot a Liar

However much we may abhor it, deception comes naturally to all living things . Birds do it by feigning injury to lead hungry predators away from nesting young. Spider crabs do it by disguise: adorning themselves with strips of kelp and other debris, they pretend to be something they are not – and so escape their enemies. Nature amply rewards successful deceivers by allowing them to survive long enough to mate and reproduce. So it may come as no surprise to learn that human beings- who, according to psychologist Gerald Johnson of the University of South California, or lied to about 200 times a day, roughly one untruth every 5 minutes- often deceive for exactly the same reasons: to save their own skins or to get something they can’t get by other means.

But knowing how to catch deceit can be just as important a survival skill as knowing how to tell a lie and get away with it . A person able to spot falsehood quickly is unlikely to be swindled by an unscrupulous business associate or hoodwinked by a devious spouse. Luckily, nature provides more than enough clues to trap dissemblers in their own tangled webs- if you know where to look. By closely observing facial expressions, body language and tone of voice, practically anyone can recognise the tell-tale signs of lying. Researchers are even programming computers – like those used on Lie Detector -to get at the truth by analysing the same physical cues available to the naked eye and ear. “With the proper training, many people can learn to reliably detect lies,” says Paul Ekman, professor of psychology at the University of California, San Francisco, who has spent the past 15 years studying the secret art of deception.

In order to know what kind of Lies work best, successful liars need to accurately assess other people’s emotional states . Ackman’s research shows that this same emotional intelligence is essential for good lie detectors, too. The emotional state to watch out for is stress, the conflict most liars feel between the truth and what they actually say and do.

Even high-tech lie detectors don’t detect lies as such; they merely detect the physical cues of emotions, which may or may not correspond to what the person being tested is saying . Polygraphs, for instance, measure respiration, heart rate and skin conductivity, which tend to increase when people are nervous – as they usually are when lying. Nervous people typically perspire, and the salts contained in perspiration conducts electricity. That’s why sudden leap in skin conductivity indicates nervousness -about getting caught, perhaps -which makes, in turn, suggest that someone is being economical with the truth. On the other hand, it might also mean that the lights in the television. Studio are too hot- which is one reason polygraph tests are inadmissible in court . “Good lie detectors don’t rely on a single thing” says Ekma ,but interpret clusters of verbal and non-verbal clues that suggest someone might be lying.”

The clues are written all over the face. Because the musculature of the face is directly connected to the areas of the brain that processes emotion, the countenance can be a window to the soul. Neurological studies even suggest that genuine emotions travel different pathways through the brain than insincere ones. If a patient paralyzed by stroke on one side of the face, for example, is asked to smile deliberately, only the mobile side of the mouth is raised. But tell that same person a funny joke, and the patient breaks into a full and spontaneous smile. Very few people -most notably, actors and politicians- are able to consciously control all of their facial expressions . Lies can often be caught when the liars true feelings briefly leak through the mask of deception. We don’t think before we feel, Ekman says. “Expressions tend to show up on the face before we’re even conscious of experiencing an emotion.”

One of the most difficult facial expressions to fake- or conceal, if it’s genuinely felt - is sadness. When someone is truly sad, the forehead wrinkles with grief and the inner corners of the eyebrows are pulled up . Fewer than 15% of the people Ekman tested were able to produce this eyebrow movement voluntarily. By contrast, the lowering of the eyebrows associated with an angry scowl can be replicated at will but almost everybody. “ If someone claims they are sad and the inner corners of their eyebrows don’t go up, Ekmam says, the sadness is probably false.”

The smile, on the other hand, is one of the easiest facial expressions to counterfeit. It takes just two muscles -the zygomaticus major muscles that extend from the cheekbones to the corners of the lips- to produce a grin. But there’s a catch. A genuine smile affects not only the corners of the lips but also the orbicularis oculi, the muscle around the eye that produces the distinctive “crow’s feet” associated with people who laugh a lot. A counterfeit grin can be unmasked if the corners of the lips go up, the eyes crinkle, but the inner corners of the eyebrows are not lowered, a movement controlled by the orbicularis oculi that is difficult to fake. The absence of lowered eyebrows is one reason why the smile looks so strained and stiff.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d89d4548-e799-5071-bee2-644b035b2097', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 1, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
1
All living animals can lie.
Locate
2
Some people tell lies for self-preservation.
Locate
3
Scientists have used computers to analyze which part of the brain is responsible for telling lies.
4
Lying as a survival skill is more important than detecting a lie.
Locate
5
To be a good liar, one has to understand other people's emotions.
Locate

1 ____ All living animals can lie. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3a7ebee-93a6-540b-958a-3c24ac17b5c8', 'd89d4548-e799-5071-bee2-644b035b2097', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f1c7677-c64b-543f-b722-5344cdd5e7f0', 'd89d4548-e799-5071-bee2-644b035b2097', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45bcbc17-15c6-5dce-bfae-d07760b38bed', 'd89d4548-e799-5071-bee2-644b035b2097', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8778707-08f2-588c-8f9f-2ddab84e7d5e', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 2, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
1
All living animals can lie.
Locate
2
Some people tell lies for self-preservation.
Locate
3
Scientists have used computers to analyze which part of the brain is responsible for telling lies.
4
Lying as a survival skill is more important than detecting a lie.
Locate
5
To be a good liar, one has to understand other people's emotions.
Locate

2 ____ Some people tell lies for self-preservation. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4559055-0a6b-581e-8f56-ff4c99c68c1f', 'd8778707-08f2-588c-8f9f-2ddab84e7d5e', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e8f3af6-3312-5147-b0d4-0af5c164abf3', 'd8778707-08f2-588c-8f9f-2ddab84e7d5e', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3cd7d76-94f0-50ef-9f71-ce6620419d1c', 'd8778707-08f2-588c-8f9f-2ddab84e7d5e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('94d53bab-2dbb-5d11-bf45-0e73cf05f042', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 3, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
1
All living animals can lie.
Locate
2
Some people tell lies for self-preservation.
Locate
3
Scientists have used computers to analyze which part of the brain is responsible for telling lies.
4
Lying as a survival skill is more important than detecting a lie.
Locate
5
To be a good liar, one has to understand other people's emotions.
Locate

3 ____ Scientists have used computers to analyze which part of the brain is responsible for telling lies.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a55c340-fa1c-5c1c-a9ae-cfc4c02e3c70', '94d53bab-2dbb-5d11-bf45-0e73cf05f042', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('445304d6-1945-5b16-8ed1-1f99aae2fe93', '94d53bab-2dbb-5d11-bf45-0e73cf05f042', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a734d3a-d490-5dfe-9765-d770da7c70c0', '94d53bab-2dbb-5d11-bf45-0e73cf05f042', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dc2c56dc-8d48-503c-a3e6-0341861ab5c9', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
1
All living animals can lie.
Locate
2
Some people tell lies for self-preservation.
Locate
3
Scientists have used computers to analyze which part of the brain is responsible for telling lies.
4
Lying as a survival skill is more important than detecting a lie.
Locate
5
To be a good liar, one has to understand other people's emotions.
Locate

4 ____ Lying as a survival skill is more important than detecting a lie. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b63573ee-cf4e-5640-8a32-57037a4f64b0', 'dc2c56dc-8d48-503c-a3e6-0341861ab5c9', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f679a347-22c2-57f0-b74b-bb906a34b341', 'dc2c56dc-8d48-503c-a3e6-0341861ab5c9', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3ae2088-975f-593b-96a9-91f3b311b7c9', 'dc2c56dc-8d48-503c-a3e6-0341861ab5c9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bbf52e1f-4cd4-5614-82ec-af1fc43fdadb', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
YES
- if the statement agrees with the information
NO
- if the statement contradicts the information
NOT GIVEN
- if there is no information on this
1
All living animals can lie.
Locate
2
Some people tell lies for self-preservation.
Locate
3
Scientists have used computers to analyze which part of the brain is responsible for telling lies.
4
Lying as a survival skill is more important than detecting a lie.
Locate
5
To be a good liar, one has to understand other people's emotions.
Locate

5 ____ To be a good liar, one has to understand other people's emotions. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20301636-19a7-5677-9028-2ed384de7fae', 'bbf52e1f-4cd4-5614-82ec-af1fc43fdadb', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56a491bf-0224-5253-8d3b-ac72fe6739f0', 'bbf52e1f-4cd4-5614-82ec-af1fc43fdadb', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3c93696-23db-58e0-a143-949662af509c', 'bbf52e1f-4cd4-5614-82ec-af1fc43fdadb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('75ce9704-d7ca-57e5-8a53-8e56cb17a874', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
6-9
.
6
. How does the lie detector work?
A
It detects whether one's emotional state is stable.
B
It detects one’s brain activity level.
C
It detects body behavior during one's verbal response.
D
It analyses one's verbal response word by word.
Locate
7.
Lie detectors can't be used as evidence in a court of law because
A
Lights often cause lie detectors to malfunction.
B
They are based on too many verbal and non-verbal clues.
C
Polygraph tests are often inaccurate.
D
There may be many causes of certain body behavior.
Locate
8.
Why does the author mention the paralyzed patients?
A
To demonstrate how a paralyzed patient smiles
B
To show the relation between true emotions and body behavior
C
To examine how they were paralyzed
D
To show the importance of happiness from recovery
Locate
9.
The author uses politicians to exemplify that they can
A
Have emotions.
B
Imitate actors.
C
Detect other people's lives.
D
Mask their true feelings.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5b5b6b6-60f0-584b-b96d-333ea9e18df3', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
6-9
.
6
. How does the lie detector work?
A
It detects whether one's emotional state is stable.
B
It detects one’s brain activity level.
C
It detects body behavior during one's verbal response.
D
It analyses one's verbal response word by word.
Locate
7.
Lie detectors can't be used as evidence in a court of law because
A
Lights often cause lie detectors to malfunction.
B
They are based on too many verbal and non-verbal clues.
C
Polygraph tests are often inaccurate.
D
There may be many causes of certain body behavior.
Locate
8.
Why does the author mention the paralyzed patients?
A
To demonstrate how a paralyzed patient smiles
B
To show the relation between true emotions and body behavior
C
To examine how they were paralyzed
D
To show the importance of happiness from recovery
Locate
9.
The author uses politicians to exemplify that they can
A
Have emotions.
B
Imitate actors.
C
Detect other people's lives.
D
Mask their true feelings.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7b5ed7de-4998-5589-951c-9d8d3050dd1f', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
6-9
.
6
. How does the lie detector work?
A
It detects whether one's emotional state is stable.
B
It detects one’s brain activity level.
C
It detects body behavior during one's verbal response.
D
It analyses one's verbal response word by word.
Locate
7.
Lie detectors can't be used as evidence in a court of law because
A
Lights often cause lie detectors to malfunction.
B
They are based on too many verbal and non-verbal clues.
C
Polygraph tests are often inaccurate.
D
There may be many causes of certain body behavior.
Locate
8.
Why does the author mention the paralyzed patients?
A
To demonstrate how a paralyzed patient smiles
B
To show the relation between true emotions and body behavior
C
To examine how they were paralyzed
D
To show the importance of happiness from recovery
Locate
9.
The author uses politicians to exemplify that they can
A
Have emotions.
B
Imitate actors.
C
Detect other people's lives.
D
Mask their true feelings.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('91459856-30ee-5f2b-967a-8917689ecb58', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
6-9
.
6
. How does the lie detector work?
A
It detects whether one's emotional state is stable.
B
It detects one’s brain activity level.
C
It detects body behavior during one's verbal response.
D
It analyses one's verbal response word by word.
Locate
7.
Lie detectors can't be used as evidence in a court of law because
A
Lights often cause lie detectors to malfunction.
B
They are based on too many verbal and non-verbal clues.
C
Polygraph tests are often inaccurate.
D
There may be many causes of certain body behavior.
Locate
8.
Why does the author mention the paralyzed patients?
A
To demonstrate how a paralyzed patient smiles
B
To show the relation between true emotions and body behavior
C
To examine how they were paralyzed
D
To show the importance of happiness from recovery
Locate
9.
The author uses politicians to exemplify that they can
A
Have emotions.
B
Imitate actors.
C
Detect other people's lives.
D
Mask their true feelings.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d6415091-8f50-5473-9032-f55e3917c147', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Classify the following facial traits as referring to
A
sadness
B
anger
C
happiness
Write the correct letter
A, B
or
C
in boxes
10-13
.
10
Inner corners of eyebrows raised
Locate
11
The whole eyebrows lowered
Locate
12
Lines formed around
Locate
13
Lines form above eyebrows
Locate

10 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26153d9a-37ae-5e98-b9de-0ca929ee08bb', 'd6415091-8f50-5473-9032-f55e3917c147', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ce3536a-9ac5-53b9-9d17-4458733e8788', 'd6415091-8f50-5473-9032-f55e3917c147', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2abccd98-25ea-5eed-9799-31858e0ab880', 'd6415091-8f50-5473-9032-f55e3917c147', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('48431e37-155d-5fae-b159-802cb02fcf7b', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Classify the following facial traits as referring to
A
sadness
B
anger
C
happiness
Write the correct letter
A, B
or
C
in boxes
10-13
.
10
Inner corners of eyebrows raised
Locate
11
The whole eyebrows lowered
Locate
12
Lines formed around
Locate
13
Lines form above eyebrows
Locate

11 ____ The whole eyebrows lowered Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6f0f3b7-c01b-5d8b-8ddc-a159635a75c4', '48431e37-155d-5fae-b159-802cb02fcf7b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17b36a42-ed36-53b0-a3dc-0dea0f001ff8', '48431e37-155d-5fae-b159-802cb02fcf7b', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1446e42d-c003-5128-993e-e0dc42280c58', '48431e37-155d-5fae-b159-802cb02fcf7b', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cab7dd10-7edb-5e18-a5df-fefd75635e99', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Classify the following facial traits as referring to
A
sadness
B
anger
C
happiness
Write the correct letter
A, B
or
C
in boxes
10-13
.
10
Inner corners of eyebrows raised
Locate
11
The whole eyebrows lowered
Locate
12
Lines formed around
Locate
13
Lines form above eyebrows
Locate

12 ____ Lines formed around Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fda2dc6e-8244-5901-b308-00871c0c563a', 'cab7dd10-7edb-5e18-a5df-fefd75635e99', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b971b33f-549b-527f-8612-0c79a3a37160', 'cab7dd10-7edb-5e18-a5df-fefd75635e99', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9d72842-6f79-59dc-b772-8ab4c1993cd9', 'cab7dd10-7edb-5e18-a5df-fefd75635e99', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d0470a2a-227a-5479-a2e5-1b1a842b684e', '582a4237-52c3-50c6-97fc-8d918e2d06bd', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Classify the following facial traits as referring to
A
sadness
B
anger
C
happiness
Write the correct letter
A, B
or
C
in boxes
10-13
.
10
Inner corners of eyebrows raised
Locate
11
The whole eyebrows lowered
Locate
12
Lines formed around
Locate
13
Lines form above eyebrows
Locate

13 ____ Lines form above eyebrows Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c4bdb5d-2a2a-528a-8700-1ae0b85832ff', 'd0470a2a-227a-5479-a2e5-1b1a842b684e', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('629863b1-b025-5718-8bcb-30bc625dcf08', 'd0470a2a-227a-5479-a2e5-1b1a842b684e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39d1b5ca-bf91-5e7c-862e-60f49bf7bea0', 'd0470a2a-227a-5479-a2e5-1b1a842b684e', 3, $md$C$md$, false);

COMMIT;
