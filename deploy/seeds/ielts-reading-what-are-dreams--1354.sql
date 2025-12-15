BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-what-are-dreams--1354'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-what-are-dreams--1354';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-what-are-dreams--1354';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-what-are-dreams--1354';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('5446d322-ff5e-5c4c-9fff-1b45597a0269', 'ielts-reading-what-are-dreams--1354', $t$What Are Dreams ?$t$, $md$## What Are Dreams ?

Nguồn:
- Test: https://mini-ielts.com/1354/reading/what-are-dreams-
- Solution: https://mini-ielts.com/1354/view-solution/reading/what-are-dreams-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('ace3b777-9e75-5d15-9d62-fb1759ae92e3', '5446d322-ff5e-5c4c-9fff-1b45597a0269', 1, $t$Reading — What Are Dreams ?$t$, $md$Read the passage and answer questions **1–14**.

### Passage: What Are Dreams ?

A

Thousands of years ago, dreams were seen as messages from the gods, and in many cultures, they are still considered prophetic. In ancient Greece, sick people slept at the temples of Asclepius, the god of medicine, in order to receive dreams that would heal them. Modern dream science really begins at the end of the 19th century with Sigmund Feud, who theorized that dreams were the expression of unconscious desires often stemming from childhood. He believed that exploring these hidden emotions through analysis could help cure mental illness. The Freudian model of psychoanalysis dominated until the 1970s when new research into the chemistry of the brain showed that emotional problems could have biological or chemical roots, as well as environmental ones. In other words, we weren’t sick just because of something our mothers did (or didn’t do), but because of some imbalance that might be cured with medication.

B

After Freud, the most important event in dream science was the discovery in the early 1950s of a phase of sleep characterized by intense brain activity and rapid eye movement (REM). People awakened in the midst of REM sleep reported vivid dreams, which led researchers to conclude that most dreaming took place during REM. Using the electroencephalograph (EEG), researchers could see that brain activity during REM resembled that of the waking brain. That old them that a lot more was going on at night than anyone had suspected. But what, exactly?

C

Scientists still don’t know for sure, although they have lots of theories. On one side are scientists like Harvard’s Allan Hobson, who believes that dreams are essentially random. In the 1970s, Hobson and his colleague Robert McCarley proposed what they called the “activation-synthesis hypothesis’” which describes how dreams are formed by nerve signals sent out during REM sleep from a small area at the base of the brain called the pons. These signals, the researchers said, activate the images that we call dreams. That put a crimp in dream research; if dreams were meaningless nocturnal firings, what was the point of studying them?

D

Adult humans spend about a quarter of their sleep time in REM, much of it dreaming. During that time, the body is essentially paralyzed but the brain is buzzing. Scientists using PET and fMRI technology to watch the dreaming brain have found that one of the most active areas during REM is the limbic system, which controls our emotions. Much less active is the prefrontal cortex, which is associated with logical thinking. That could explain why dreams in REM sleep often lack a coherent storyline (some researchers have also found that people dream in non-REM sleep as well, although those dreams generally are less vivid.) Another active part of the brain in REM sleep is the anterior cingulate cortex, which detects discrepancies. Eric Nofzinger, director of the Sleep Neuroimaging Program at the University of Pittsburgh Medical Center, thinks that could be why people often figure out thorny problems in their dreams. “As if the brain surveys the internal milieu and tries to figure out what it should be doing, and whether our actions conflict with who we are,” he says.

E

These may seem like vital mental functions, but no one has yet been able to say that REM sleep or dreaming is essential to life or even sanity. MAO inhibitors, an older class of antidepressants, essentially block REM sleep without any detectable effects, although people do get a “REM rebound” – extra REM – if they stop the medication. That’s also true of selective serotonin reuptake inhibitors (SSRIs) like Prozac, which reduce dreaming by a third to a half. Even permanently losing the ability to dream doesn’t have to be disabling. Israeli researcher Peretz Lavie has been observing a patient named Yuval Chamtzani, who was injured by a fragment of shrapnel that penetrated his brain when he was 19. As a result, he gets no REM sleep and doesn’t remember any dreams. But Lavie says that Chamtzani, now 55, “is probably the most normal person I know and one of the most successful ones.” He’s a lawyer, a painter and the editor of a puzzle column in a popular Israeli newspaper.

F

The mystery of REM sleep is that even though it may not be essential, it is ubiquitous – at least in mammals and birds. But that doesn’t mean all mammals and birds dream (or if they do, they’re certainly not – talking about it). Some researchers think REM may have evolved for physiological reasons. “One thing that’s unique about mammals and birds is that they regulate body temperature”, says neuroscientist Jerry Siegel, director of UCLA’s Center for Sleep Research. “There’s no good evidence that any coldblooded animal has REM sleep.” REM sleep heats up the brain and non-REM cools it off, Siegel says, and that could mean that the changing sleep cycles allow the brain to repair itself. “It seems likely that REM sleep is filling a basic physiological function and that dreams are a kind of epiphenomenon,” Siegel says – an extraneous byproduct; like foam on beer.

G

Whatever the function of dreams at night, they clearly can play a role in therapy during the day. The University of Maryland’s Clara Hill, who has studied the use of dreams in therapy, says that dreams are a ‘backdoor’, into a patient’s thinking. “Dreams reveal stuff about you that you didn’t know was there,” she says. The therapists she trains to work with patients’ dreams are, in essence, heirs to Freud, using dream imagery to uncover hidden emotions and feelings. Dreams provide clues to the nature of the more serious mental illness. Schizophrenics, for example, have poor-quality dreams, usually about objects rather than people. “If you’re going to understand human behavior,” says Rosalind Cartwright, a chairman of psychology at Rush University Medical Center in Chicago, “here’s a big piece of it. Dreaming is our own storytelling time – to help us know who we are, where we’re going and how we’re going to get there.” Cartwright has been studying depression in divorced men and women, and she is finding that “good dreamers,” people who have vivid dreams with strong storylines, are less likely to remain depressed. She thinks that dreaming helps diffuse strong emotions. “Dreaming is a mental-health activity,” she says.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3f9b09aa-6d39-5fe7-958c-bb600cf4e722', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct number,
A-G
, in boxes
1-5
on your answer sheet.
1
Reference of an artist’s dreams who has versatile talents
2
The dream actually happens to many animals
3
Dreams are related to benefit and happiness
4
advanced scientific technology applied in the investigation of the REM stage.
5
questioning concern raised about the usefulness of investigation on dreams

1 ____ Reference of an artist’s dreams who has versatile talents$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15ff7de7-d635-569d-a0fc-061147dee860', '3f9b09aa-6d39-5fe7-958c-bb600cf4e722', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3825cfe2-d1da-5eb6-ac59-e4e0980158d7', '3f9b09aa-6d39-5fe7-958c-bb600cf4e722', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('536d415d-51e9-58f7-ad1c-6e1226bd5551', '3f9b09aa-6d39-5fe7-958c-bb600cf4e722', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51e81d57-dff0-53ed-813c-d9386dd02b91', '3f9b09aa-6d39-5fe7-958c-bb600cf4e722', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9124b089-8c62-5fd7-bdb9-349a36c6aa8e', '3f9b09aa-6d39-5fe7-958c-bb600cf4e722', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8de15cef-133d-55f3-9558-ade39e3f2428', '3f9b09aa-6d39-5fe7-958c-bb600cf4e722', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6637073-054f-52c3-a758-250220b0e432', '3f9b09aa-6d39-5fe7-958c-bb600cf4e722', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('59c4cbca-8f22-5c93-a883-4cfe7c29a46c', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct number,
A-G
, in boxes
1-5
on your answer sheet.
1
Reference of an artist’s dreams who has versatile talents
2
The dream actually happens to many animals
3
Dreams are related to benefit and happiness
4
advanced scientific technology applied in the investigation of the REM stage.
5
questioning concern raised about the usefulness of investigation on dreams

2 ____ The dream actually happens to many animals$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b810a5e4-cd0c-5e09-aa17-6fa2585d8b53', '59c4cbca-8f22-5c93-a883-4cfe7c29a46c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95b953a0-5e27-5a4d-b3ba-9ae1dc12773d', '59c4cbca-8f22-5c93-a883-4cfe7c29a46c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3117ba76-ed3e-57ec-b0bd-1a6c7faad6d1', '59c4cbca-8f22-5c93-a883-4cfe7c29a46c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72b13188-c583-5c00-bcec-d9881aea8a33', '59c4cbca-8f22-5c93-a883-4cfe7c29a46c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57940d3a-5cfd-54b4-a73b-9f2d62d36698', '59c4cbca-8f22-5c93-a883-4cfe7c29a46c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5966750a-be02-5ef3-8bdc-432de3a71cf8', '59c4cbca-8f22-5c93-a883-4cfe7c29a46c', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eec4f83d-c28c-5468-b360-0607a6e5d19d', '59c4cbca-8f22-5c93-a883-4cfe7c29a46c', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('baa53e98-effb-5c17-b6e3-6cff5ff93f37', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct number,
A-G
, in boxes
1-5
on your answer sheet.
1
Reference of an artist’s dreams who has versatile talents
2
The dream actually happens to many animals
3
Dreams are related to benefit and happiness
4
advanced scientific technology applied in the investigation of the REM stage.
5
questioning concern raised about the usefulness of investigation on dreams

3 ____ Dreams are related to benefit and happiness$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5768fc06-a749-5243-a699-1d851c614b13', 'baa53e98-effb-5c17-b6e3-6cff5ff93f37', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c4c9aa1-f034-5087-8548-b6a2e348c318', 'baa53e98-effb-5c17-b6e3-6cff5ff93f37', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1633912f-2630-5fb6-908c-a59db2e51337', 'baa53e98-effb-5c17-b6e3-6cff5ff93f37', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24825a80-7f19-5902-bd8a-7bc787fa30ac', 'baa53e98-effb-5c17-b6e3-6cff5ff93f37', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0695e072-9f81-5b07-b750-f82335cf59fc', 'baa53e98-effb-5c17-b6e3-6cff5ff93f37', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e823fd2-5641-5681-8019-3ef07d4f81e9', 'baa53e98-effb-5c17-b6e3-6cff5ff93f37', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75e78190-82fc-5cb1-adbf-1ccb35686848', 'baa53e98-effb-5c17-b6e3-6cff5ff93f37', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('18e8a7a0-9217-5e80-aec8-44abe18e304a', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct number,
A-G
, in boxes
1-5
on your answer sheet.
1
Reference of an artist’s dreams who has versatile talents
2
The dream actually happens to many animals
3
Dreams are related to benefit and happiness
4
advanced scientific technology applied in the investigation of the REM stage.
5
questioning concern raised about the usefulness of investigation on dreams

4 ____ advanced scientific technology applied in the investigation of the REM stage.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8806a681-8bc8-56cb-8cac-20c882d63054', '18e8a7a0-9217-5e80-aec8-44abe18e304a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c1832ac-07e0-5186-b643-39461322c238', '18e8a7a0-9217-5e80-aec8-44abe18e304a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('115a604c-d79b-5e7e-b716-db3de55052e5', '18e8a7a0-9217-5e80-aec8-44abe18e304a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c589c68-fe20-5f2f-8e76-1b68a6ba8482', '18e8a7a0-9217-5e80-aec8-44abe18e304a', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb31467e-07a3-5f23-ab33-b9381d3f609d', '18e8a7a0-9217-5e80-aec8-44abe18e304a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cdbc2d5-2f03-5a70-9597-8f4a97598e90', '18e8a7a0-9217-5e80-aec8-44abe18e304a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f15238f3-f64e-5605-818d-b293a3217882', '18e8a7a0-9217-5e80-aec8-44abe18e304a', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a1b175b6-c4ec-56ae-afce-71e335dd813d', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct number,
A-G
, in boxes
1-5
on your answer sheet.
1
Reference of an artist’s dreams who has versatile talents
2
The dream actually happens to many animals
3
Dreams are related to benefit and happiness
4
advanced scientific technology applied in the investigation of the REM stage.
5
questioning concern raised about the usefulness of investigation on dreams

5 ____ questioning concern raised about the usefulness of investigation on dreams$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('381e7f75-3fca-5705-915f-fc7321b55427', 'a1b175b6-c4ec-56ae-afce-71e335dd813d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b922e1b1-06e6-568b-93e8-c37b3e64b2a4', 'a1b175b6-c4ec-56ae-afce-71e335dd813d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd76d350-7234-5084-b109-f05b37d543b5', 'a1b175b6-c4ec-56ae-afce-71e335dd813d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23790e54-3d65-5542-b1a0-2c7cdfe29f5f', 'a1b175b6-c4ec-56ae-afce-71e335dd813d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df9eea1a-bacf-5050-a1c3-ebbbe5c6688b', 'a1b175b6-c4ec-56ae-afce-71e335dd813d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c37187de-7a2d-525f-82a4-bc24a97fb98f', 'a1b175b6-c4ec-56ae-afce-71e335dd813d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab0daeed-f524-535c-a068-123984bcd9bb', 'a1b175b6-c4ec-56ae-afce-71e335dd813d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('62260f3f-a2d6-5686-bc3e-d1c8afe77c48', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-8
Questions 6-8
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
6-8
on your answer sheet.
6.
What were dreams regarded as by ancient people?
A
superstitious and unreliable
B
communication with gods and chance to predict the future
C
medical relief for children with an ill desire
D
rules to follow as they fell asleep in a temple
7.
According to Paragraph D, which part of the brain controls reasoning?
A
anterior cingulate cortex
B
internal cortex
C
limbic system
D
prefrontal cortex
8.
What can we conclude when the author cited a reference for dreams in animals?
A
Brain temperature rises when REM pattern happens.
B
The reason why mammals are warm-blooded
C
mammals are bound to appear with more frequent REM.
D
REM makes people want to drink beer with more foam.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2595370b-6ef0-50a8-a420-2e946c4e9a8e', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-8
Questions 6-8
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
6-8
on your answer sheet.
6.
What were dreams regarded as by ancient people?
A
superstitious and unreliable
B
communication with gods and chance to predict the future
C
medical relief for children with an ill desire
D
rules to follow as they fell asleep in a temple
7.
According to Paragraph D, which part of the brain controls reasoning?
A
anterior cingulate cortex
B
internal cortex
C
limbic system
D
prefrontal cortex
8.
What can we conclude when the author cited a reference for dreams in animals?
A
Brain temperature rises when REM pattern happens.
B
The reason why mammals are warm-blooded
C
mammals are bound to appear with more frequent REM.
D
REM makes people want to drink beer with more foam.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5dd9580c-829b-50f5-aea7-c97ceeaddede', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-8
Questions 6-8
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
6-8
on your answer sheet.
6.
What were dreams regarded as by ancient people?
A
superstitious and unreliable
B
communication with gods and chance to predict the future
C
medical relief for children with an ill desire
D
rules to follow as they fell asleep in a temple
7.
According to Paragraph D, which part of the brain controls reasoning?
A
anterior cingulate cortex
B
internal cortex
C
limbic system
D
prefrontal cortex
8.
What can we conclude when the author cited a reference for dreams in animals?
A
Brain temperature rises when REM pattern happens.
B
The reason why mammals are warm-blooded
C
mammals are bound to appear with more frequent REM.
D
REM makes people want to drink beer with more foam.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fdd97ca5-b7a0-52de-aa1b-e2ebd5315aaf', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-14
Questions 9-14
Look at the following people and the list of statements below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
9-14
on your answer sheet.
List of people
A
Sigmund Freud
B
Allan Hobson (Harvard)
C
Robert McCarley
D
Eric Nofzinger
E
Jerry Siegel
F
Clara Hill
G
Rosalind Cartwright
9
Dreams sometimes come along with REM as no more than a trivial attachment
10
Exploring patients’ dreams would be beneficial for treatment as it reveals the unconscious thinking
11
Dreams help people cope with the difficulties they meet in the daytime
12
Decoding dreams would provide a reminder to human desire in the early days
13
Dreams are a body function to control strong emotion
14
Dreams seem to be as randomly occurring and have limited research significance.

9 ____ Dreams sometimes come along with REM as no more than a trivial attachment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26ad18be-3fac-5e78-9099-8521371ef9bb', 'fdd97ca5-b7a0-52de-aa1b-e2ebd5315aaf', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c67a141-9692-5222-850d-35c1d09a332f', 'fdd97ca5-b7a0-52de-aa1b-e2ebd5315aaf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e778de12-d993-5e29-9c2e-0a2db1f6ce16', 'fdd97ca5-b7a0-52de-aa1b-e2ebd5315aaf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d179e42-618c-585d-91ff-016c397a881e', 'fdd97ca5-b7a0-52de-aa1b-e2ebd5315aaf', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67a84d49-e50d-52c5-ba5b-076bc947ab3b', 'fdd97ca5-b7a0-52de-aa1b-e2ebd5315aaf', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d149d27-14c1-553f-9f39-f8deee90a7b1', 'fdd97ca5-b7a0-52de-aa1b-e2ebd5315aaf', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b0983ea-0ebc-545f-a6f1-15272dd9fade', 'fdd97ca5-b7a0-52de-aa1b-e2ebd5315aaf', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1f71c646-3441-5891-88f5-f3e02de0a065', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-14
Questions 9-14
Look at the following people and the list of statements below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
9-14
on your answer sheet.
List of people
A
Sigmund Freud
B
Allan Hobson (Harvard)
C
Robert McCarley
D
Eric Nofzinger
E
Jerry Siegel
F
Clara Hill
G
Rosalind Cartwright
9
Dreams sometimes come along with REM as no more than a trivial attachment
10
Exploring patients’ dreams would be beneficial for treatment as it reveals the unconscious thinking
11
Dreams help people cope with the difficulties they meet in the daytime
12
Decoding dreams would provide a reminder to human desire in the early days
13
Dreams are a body function to control strong emotion
14
Dreams seem to be as randomly occurring and have limited research significance.

10 ____ Exploring patients’ dreams would be beneficial for treatment as it reveals the unconscious thinking$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bd86f15-bd43-5dde-9aee-9558cc6dd14f', '1f71c646-3441-5891-88f5-f3e02de0a065', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdc76127-aec5-554f-b3b1-61917a776c9b', '1f71c646-3441-5891-88f5-f3e02de0a065', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce082d44-3c7c-54b7-a02f-8af0dfa31018', '1f71c646-3441-5891-88f5-f3e02de0a065', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2eb8416-fb99-542d-8344-36a317409272', '1f71c646-3441-5891-88f5-f3e02de0a065', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a55b6194-f8bb-5755-bb0f-28b69bec5f80', '1f71c646-3441-5891-88f5-f3e02de0a065', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66310910-af52-5086-93dc-6bd0eee2e77a', '1f71c646-3441-5891-88f5-f3e02de0a065', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4623cc68-cdfa-5e76-b627-d30f85971e42', '1f71c646-3441-5891-88f5-f3e02de0a065', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c2a76f21-bcb4-5a83-b3f6-c55dcfd6e5e6', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-14
Questions 9-14
Look at the following people and the list of statements below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
9-14
on your answer sheet.
List of people
A
Sigmund Freud
B
Allan Hobson (Harvard)
C
Robert McCarley
D
Eric Nofzinger
E
Jerry Siegel
F
Clara Hill
G
Rosalind Cartwright
9
Dreams sometimes come along with REM as no more than a trivial attachment
10
Exploring patients’ dreams would be beneficial for treatment as it reveals the unconscious thinking
11
Dreams help people cope with the difficulties they meet in the daytime
12
Decoding dreams would provide a reminder to human desire in the early days
13
Dreams are a body function to control strong emotion
14
Dreams seem to be as randomly occurring and have limited research significance.

11 ____ Dreams help people cope with the difficulties they meet in the daytime$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41155014-2837-5773-9854-b475ddf30802', 'c2a76f21-bcb4-5a83-b3f6-c55dcfd6e5e6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4275772c-e098-5a8a-a411-2adb58b8558c', 'c2a76f21-bcb4-5a83-b3f6-c55dcfd6e5e6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9b26708-9116-5be1-9afd-4b5a581831ac', 'c2a76f21-bcb4-5a83-b3f6-c55dcfd6e5e6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00b9d2a6-8ae5-5e54-a2c5-4cca0b4f1718', 'c2a76f21-bcb4-5a83-b3f6-c55dcfd6e5e6', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7c5ad61-25ae-5440-9094-616ac6f7b276', 'c2a76f21-bcb4-5a83-b3f6-c55dcfd6e5e6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c10df2de-979c-5e13-809d-24a9ea236832', 'c2a76f21-bcb4-5a83-b3f6-c55dcfd6e5e6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbb174bf-1779-58cf-b87a-4ea9d0014bb2', 'c2a76f21-bcb4-5a83-b3f6-c55dcfd6e5e6', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('64d0dddd-7d5f-5527-b97d-d04e2ef206ff', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-14
Questions 9-14
Look at the following people and the list of statements below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
9-14
on your answer sheet.
List of people
A
Sigmund Freud
B
Allan Hobson (Harvard)
C
Robert McCarley
D
Eric Nofzinger
E
Jerry Siegel
F
Clara Hill
G
Rosalind Cartwright
9
Dreams sometimes come along with REM as no more than a trivial attachment
10
Exploring patients’ dreams would be beneficial for treatment as it reveals the unconscious thinking
11
Dreams help people cope with the difficulties they meet in the daytime
12
Decoding dreams would provide a reminder to human desire in the early days
13
Dreams are a body function to control strong emotion
14
Dreams seem to be as randomly occurring and have limited research significance.

12 ____ Decoding dreams would provide a reminder to human desire in the early days$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1031b348-fde9-5af2-a2b5-6468ff0c0e5a', '64d0dddd-7d5f-5527-b97d-d04e2ef206ff', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96ca799f-96d0-5c10-92ae-16f154628d1e', '64d0dddd-7d5f-5527-b97d-d04e2ef206ff', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('694934f7-8334-53a9-8e4b-81927e3c816b', '64d0dddd-7d5f-5527-b97d-d04e2ef206ff', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94a8f1df-6eb2-5511-8c83-73c0ce5e4267', '64d0dddd-7d5f-5527-b97d-d04e2ef206ff', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('556ebe24-76b8-532c-8dd6-975674198b82', '64d0dddd-7d5f-5527-b97d-d04e2ef206ff', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a9b7281-9051-5c29-99f2-0605bb68b90d', '64d0dddd-7d5f-5527-b97d-d04e2ef206ff', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee586541-e59a-5c2c-a684-c64b41a08fc5', '64d0dddd-7d5f-5527-b97d-d04e2ef206ff', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c1d16ddf-a4fd-5924-b64c-5a395983fb8b', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 9-14
Questions 9-14
Look at the following people and the list of statements below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
9-14
on your answer sheet.
List of people
A
Sigmund Freud
B
Allan Hobson (Harvard)
C
Robert McCarley
D
Eric Nofzinger
E
Jerry Siegel
F
Clara Hill
G
Rosalind Cartwright
9
Dreams sometimes come along with REM as no more than a trivial attachment
10
Exploring patients’ dreams would be beneficial for treatment as it reveals the unconscious thinking
11
Dreams help people cope with the difficulties they meet in the daytime
12
Decoding dreams would provide a reminder to human desire in the early days
13
Dreams are a body function to control strong emotion
14
Dreams seem to be as randomly occurring and have limited research significance.

13 ____ Dreams are a body function to control strong emotion$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cda3481f-68d6-5bc9-92c6-e88d78826682', 'c1d16ddf-a4fd-5924-b64c-5a395983fb8b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f06573c5-2e72-5ee8-83d3-7e784db3396a', 'c1d16ddf-a4fd-5924-b64c-5a395983fb8b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c31baf0-5389-5b4a-9234-d388d393d543', 'c1d16ddf-a4fd-5924-b64c-5a395983fb8b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c74d3815-f877-5dc3-9cde-1ff2d4b4307b', 'c1d16ddf-a4fd-5924-b64c-5a395983fb8b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8462db0c-b5fb-5003-853a-86dbdd7f6d9a', 'c1d16ddf-a4fd-5924-b64c-5a395983fb8b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('581a4ee6-cca1-50db-8038-668ee17305f2', 'c1d16ddf-a4fd-5924-b64c-5a395983fb8b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67e6f2d5-1653-5c35-ad54-1481642cad57', 'c1d16ddf-a4fd-5924-b64c-5a395983fb8b', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b7f31082-afb0-5377-8470-521410f20941', 'ace3b777-9e75-5d15-9d62-fb1759ae92e3', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 9-14
Questions 9-14
Look at the following people and the list of statements below.
Match each statement with the correct person,
A-G
.
Write the correct letter,
A-G
, in boxes
9-14
on your answer sheet.
List of people
A
Sigmund Freud
B
Allan Hobson (Harvard)
C
Robert McCarley
D
Eric Nofzinger
E
Jerry Siegel
F
Clara Hill
G
Rosalind Cartwright
9
Dreams sometimes come along with REM as no more than a trivial attachment
10
Exploring patients’ dreams would be beneficial for treatment as it reveals the unconscious thinking
11
Dreams help people cope with the difficulties they meet in the daytime
12
Decoding dreams would provide a reminder to human desire in the early days
13
Dreams are a body function to control strong emotion
14
Dreams seem to be as randomly occurring and have limited research significance.

14 ____ Dreams seem to be as randomly occurring and have limited research significance.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('268da56d-b3cc-5f45-9286-b073c4824d46', 'b7f31082-afb0-5377-8470-521410f20941', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b12c20e2-153e-5f0c-a7a7-c8c2892ce875', 'b7f31082-afb0-5377-8470-521410f20941', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6493c574-0c85-5646-afbb-6beab8fe740a', 'b7f31082-afb0-5377-8470-521410f20941', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a97cbbbc-f9a8-5e61-8c77-95841e884fed', 'b7f31082-afb0-5377-8470-521410f20941', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5e25d89-37b7-5260-a908-4950ba44d887', 'b7f31082-afb0-5377-8470-521410f20941', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('971aa1be-9b58-56d8-9197-c1e20aeb4213', 'b7f31082-afb0-5377-8470-521410f20941', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34127a08-736e-52c1-9457-734c54ccb054', 'b7f31082-afb0-5377-8470-521410f20941', 7, $md$G$md$, false);

COMMIT;
