BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-secret-of-the-yawn-1295'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-secret-of-the-yawn-1295';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-secret-of-the-yawn-1295';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-secret-of-the-yawn-1295';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('1ed39113-4409-5c26-bc57-b9d2164f8cac', 'ielts-reading-the-secret-of-the-yawn-1295', $t$The secret of the Yawn$t$, $md$## The secret of the Yawn

Nguồn:
- Test: https://mini-ielts.com/1295/reading/the-secret-of-the-yawn
- Solution: https://mini-ielts.com/1295/view-solution/reading/the-secret-of-the-yawn$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('129a28ab-7aeb-5347-8718-86a9b46aca4a', '1ed39113-4409-5c26-bc57-b9d2164f8cac', 1, $t$Reading — The secret of the Yawn$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The secret of the Yawn

A

When a scientist began to study yawning in the 1980s, it was difficult to convince some of his research students of the merits of “yawning science.” Although it may appear quirky, his decision to study yawning was a logical extension to human beings of my research in developmental neuroscience, reported in such papers as “Wing-flapping during Development and Evolution.” As a neurobehavioral problem, there is not much difference between the wing-flapping of birds and the face – and body-flapping of human yawners.

B

Yawning is an ancient, primitive act. Humans do it even before they are born, opening wide in the womb. Some snakes unhinge their jaws to do it. One species of penguins yawns as part of mating. Only now are researchers beginning to understand why we yawn, when we yawn and why we yawn back. A professor of cognitive neuroscience at Drexel University in Philadelphia, Steven Platek, studies the act of contagious yawning, something done only by people and other primates.

C

In his first experiment, he used a psychological test to rank people on their empathic feelings. He found that participants who did not score high on compassion did not yawn back. “We literally had people saying, ‘Why am I looking at people yawning?’” Professor Platek said. “It just had no effect.”

D

For his second experiment, he put 10 students in a magnetic resonance imaging machine as they watched video tapes of people yawning. When the students watched the videos, the part of the brain which reacted was the part scientists believe controls empathy – the posterior cingulate, in the brain’s middle rear.” I don’t know if it’s necessarily that nice people yawn more, but I think it’s a good indicator of a state of mind,” said Professor Platek. “It’s also a good indicator if you’re empathizing with me and paying attention.”

E

His third experiment is studying yawning in those with brain disorders, such as autism and schizophrenia, in which victims have difficulty connecting emotionally with others. A psychology professor at the University of Maryland, Robert Provine, is one of the few other researchers into yawning. He found the basic yawn lasts about six seconds and they come in bouts with an interval of about 68 seconds. Men and women yawn or half-yawn equally often, but men are significantly less likely to cover their mouths which may indicate complex distinction in genders.” A watched yawner never yawns,” Professor Provine said. However, the physical root of yawning remains a mystery. Some researchers say it’s coordinated within the hypothalamus of the brain, the area that also controls breathing.

F

Yawning and stretching also share properties and may be performed together as parts of a global motor complex. But they do not always co-occur – people usually yawn when we stretch, but we don’t always stretch when we yawn, especially before bedtime. Studies by J.I.P, G.H.A. Visser and H.F. Prechtl in the early 1980s, charting movement in the developing fetus using ultrasound, observed not just yawning but a link between yawning and stretching as early as the end of the first prenatal trimester.

G

The most extraordinary demonstration of the yawn-stretch linkage occurs in many people paralyzed on one side of their body because of brain damage caused by a stroke. The prominent British neurologist Sir Francis Walshe noted in 1923 what when these hemiplegics yawn, they are startled and mystified to observe that their otherwise paralyzed arm rises and flexes automatically in what neurologists term an “associated response.” Yawning apparently activates undamaged, unconsciously controlled connections between the brain and the cord motor system innervating the paralyzed limb. It is not known whether the associated response is a positive prognosis for recovery, nor whether yawning is therapeutic for reinnervation or prevention of muscular atrophy.

H

Clinical neurology offers other surprises. Some patients with “locked-in” syndrome, who are almost totally deprived of the ability to move voluntarily, can yawn normally. The neural circuits for spontaneous yawning must exist in the brain stem near other respiratory and vasomotor centers, because yawning is performed by anencephalic who possess only the medulla oblongata. The multiplicity of stimuli of contagious yawning, by contrast, implicates many higher brain regions.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b6bd9079-af8c-5139-aaae-af30c1b8d664', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the Summary paragraph described below.
In boxes
1-5
on your answer sheet, write the correct answer with
NO MORE THAN THREE WORDS.
A psychology professor drew a conclusion after observation that it takes about six seconds to complete average yawning which needs
1
before the following yawning comes. It is almost at the same frequency that male and female yawn or half, yet behavior accompanied with yawning showing a
2
in genders. Some parts within the brain may affect the movement which also has something to do with
3
another finding also finds there is a link between a yawn and
4
before a baby was born, which two can be automatically co-operating even among people whose
5
is damaged.

A psychology professor drew a conclusion after observation that it takes about six seconds to complete average yawning which needs 1 ____ before the following yawning comes. It is almost at the same frequency that male and female yawn or half, yet behavior accompanied with yawning showing a 2 ____ in genders. Some parts within the brain may affect the movement which also has something to do with 3 ____ another finding also finds there is a link between a yawn and 4 ____ before a baby was born, which two can be automatically co-operating even among people whose 5 ____ is damaged.$md$, NULL, ARRAY['.*68.*seconds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f25f83d3-6c01-5c12-a796-96455a371a59', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the Summary paragraph described below.
In boxes
1-5
on your answer sheet, write the correct answer with
NO MORE THAN THREE WORDS.
A psychology professor drew a conclusion after observation that it takes about six seconds to complete average yawning which needs
1
before the following yawning comes. It is almost at the same frequency that male and female yawn or half, yet behavior accompanied with yawning showing a
2
in genders. Some parts within the brain may affect the movement which also has something to do with
3
another finding also finds there is a link between a yawn and
4
before a baby was born, which two can be automatically co-operating even among people whose
5
is damaged.

A psychology professor drew a conclusion after observation that it takes about six seconds to complete average yawning which needs 1 ____ before the following yawning comes. It is almost at the same frequency that male and female yawn or half, yet behavior accompanied with yawning showing a 2 ____ in genders. Some parts within the brain may affect the movement which also has something to do with 3 ____ another finding also finds there is a link between a yawn and 4 ____ before a baby was born, which two can be automatically co-operating even among people whose 5 ____ is damaged.$md$, NULL, ARRAY['.*68.*seconds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('36edf9e4-3f7e-570a-9b1e-915e7128b0ca', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the Summary paragraph described below.
In boxes
1-5
on your answer sheet, write the correct answer with
NO MORE THAN THREE WORDS.
A psychology professor drew a conclusion after observation that it takes about six seconds to complete average yawning which needs
1
before the following yawning comes. It is almost at the same frequency that male and female yawn or half, yet behavior accompanied with yawning showing a
2
in genders. Some parts within the brain may affect the movement which also has something to do with
3
another finding also finds there is a link between a yawn and
4
before a baby was born, which two can be automatically co-operating even among people whose
5
is damaged.

A psychology professor drew a conclusion after observation that it takes about six seconds to complete average yawning which needs 1 ____ before the following yawning comes. It is almost at the same frequency that male and female yawn or half, yet behavior accompanied with yawning showing a 2 ____ in genders. Some parts within the brain may affect the movement which also has something to do with 3 ____ another finding also finds there is a link between a yawn and 4 ____ before a baby was born, which two can be automatically co-operating even among people whose 5 ____ is damaged.$md$, NULL, ARRAY['.*68.*seconds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('49702feb-8c33-511b-ab3c-82538c5a7612', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the Summary paragraph described below.
In boxes
1-5
on your answer sheet, write the correct answer with
NO MORE THAN THREE WORDS.
A psychology professor drew a conclusion after observation that it takes about six seconds to complete average yawning which needs
1
before the following yawning comes. It is almost at the same frequency that male and female yawn or half, yet behavior accompanied with yawning showing a
2
in genders. Some parts within the brain may affect the movement which also has something to do with
3
another finding also finds there is a link between a yawn and
4
before a baby was born, which two can be automatically co-operating even among people whose
5
is damaged.

A psychology professor drew a conclusion after observation that it takes about six seconds to complete average yawning which needs 1 ____ before the following yawning comes. It is almost at the same frequency that male and female yawn or half, yet behavior accompanied with yawning showing a 2 ____ in genders. Some parts within the brain may affect the movement which also has something to do with 3 ____ another finding also finds there is a link between a yawn and 4 ____ before a baby was born, which two can be automatically co-operating even among people whose 5 ____ is damaged.$md$, NULL, ARRAY['.*68.*seconds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c9a223a4-e9de-5bd7-9e4d-e500038c4c64', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the Summary paragraph described below.
In boxes
1-5
on your answer sheet, write the correct answer with
NO MORE THAN THREE WORDS.
A psychology professor drew a conclusion after observation that it takes about six seconds to complete average yawning which needs
1
before the following yawning comes. It is almost at the same frequency that male and female yawn or half, yet behavior accompanied with yawning showing a
2
in genders. Some parts within the brain may affect the movement which also has something to do with
3
another finding also finds there is a link between a yawn and
4
before a baby was born, which two can be automatically co-operating even among people whose
5
is damaged.

A psychology professor drew a conclusion after observation that it takes about six seconds to complete average yawning which needs 1 ____ before the following yawning comes. It is almost at the same frequency that male and female yawn or half, yet behavior accompanied with yawning showing a 2 ____ in genders. Some parts within the brain may affect the movement which also has something to do with 3 ____ another finding also finds there is a link between a yawn and 4 ____ before a baby was born, which two can be automatically co-operating even among people whose 5 ____ is damaged.$md$, NULL, ARRAY['.*68.*seconds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4da65f81-80aa-5e40-b628-77dab3fc1cdd', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Read paragraph
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
for questions 6-10
NB
You may use any letter more than once.
6
The rate for yawning shows some regular pattern.
7
Yawning is an inherent ability that appears in both animals and humans.
8
Stretching and yawning is not always going together.
9
Yawning may suggest people are having positive notice or response in communicating.
10
Some superior areas in the brain may deal with the infectious feature of yawning.

6 ____ The rate for yawning shows some regular pattern.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed993b84-068f-597a-aed2-021b31e2223b', '4da65f81-80aa-5e40-b628-77dab3fc1cdd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e2cf3e4-5fbe-57f3-8951-afdafcfcbf5a', '4da65f81-80aa-5e40-b628-77dab3fc1cdd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b62354df-6af0-544a-ad14-de5717256bf4', '4da65f81-80aa-5e40-b628-77dab3fc1cdd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71a7887c-562d-5128-aa55-f32212f64737', '4da65f81-80aa-5e40-b628-77dab3fc1cdd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36dc291d-8e7d-591d-8562-93c4c3383664', '4da65f81-80aa-5e40-b628-77dab3fc1cdd', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c35d037-30de-53a3-88e1-92a9291b2cf0', '4da65f81-80aa-5e40-b628-77dab3fc1cdd', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e3f5d05-33c6-5fd6-ae0b-0bba25194b26', '4da65f81-80aa-5e40-b628-77dab3fc1cdd', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76cd6410-9521-5193-aa20-7966c69f9f40', '4da65f81-80aa-5e40-b628-77dab3fc1cdd', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c40fa32e-441b-518e-8666-e48145dd1208', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Read paragraph
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
for questions 6-10
NB
You may use any letter more than once.
6
The rate for yawning shows some regular pattern.
7
Yawning is an inherent ability that appears in both animals and humans.
8
Stretching and yawning is not always going together.
9
Yawning may suggest people are having positive notice or response in communicating.
10
Some superior areas in the brain may deal with the infectious feature of yawning.

7 ____ Yawning is an inherent ability that appears in both animals and humans.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfd2a2a6-0830-52da-b91b-3fd620346b24', 'c40fa32e-441b-518e-8666-e48145dd1208', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b65c64c-484f-5df1-951f-6c0a661aa305', 'c40fa32e-441b-518e-8666-e48145dd1208', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cd46c47-427d-53dd-9a8d-52837b2c667d', 'c40fa32e-441b-518e-8666-e48145dd1208', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('568036ad-e015-50c0-b415-6426e61cdf77', 'c40fa32e-441b-518e-8666-e48145dd1208', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a45e7c20-1000-5a41-b08f-87d6e052b62b', 'c40fa32e-441b-518e-8666-e48145dd1208', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ea06864-bb86-54a3-93b8-d8ff82d598b6', 'c40fa32e-441b-518e-8666-e48145dd1208', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1b1ab70-7f84-5f7d-9df9-e95feb577079', 'c40fa32e-441b-518e-8666-e48145dd1208', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d753c32-4367-585b-8991-b964028f1a27', 'c40fa32e-441b-518e-8666-e48145dd1208', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e7f7477a-13ed-509c-bad8-b9282d6a576e', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Read paragraph
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
for questions 6-10
NB
You may use any letter more than once.
6
The rate for yawning shows some regular pattern.
7
Yawning is an inherent ability that appears in both animals and humans.
8
Stretching and yawning is not always going together.
9
Yawning may suggest people are having positive notice or response in communicating.
10
Some superior areas in the brain may deal with the infectious feature of yawning.

8 ____ Stretching and yawning is not always going together.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('638a6b00-297e-5da0-beda-0996f99fbbbb', 'e7f7477a-13ed-509c-bad8-b9282d6a576e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d059172-cb4a-5d7e-943d-7ca7c4a6afdf', 'e7f7477a-13ed-509c-bad8-b9282d6a576e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca28711f-6c41-583e-bc32-0f972c0f767b', 'e7f7477a-13ed-509c-bad8-b9282d6a576e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71a85f0a-601e-5636-91f9-6ecfac3a1984', 'e7f7477a-13ed-509c-bad8-b9282d6a576e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8236acc-c1e5-56e2-8e33-f3a4f214316e', 'e7f7477a-13ed-509c-bad8-b9282d6a576e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3719814-e987-5cfb-8e7c-75b8db00b459', 'e7f7477a-13ed-509c-bad8-b9282d6a576e', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efbaa22a-d316-5542-b24c-53c7ae72b9b2', 'e7f7477a-13ed-509c-bad8-b9282d6a576e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf0ff8d3-a0b5-5402-8782-13df44a54692', 'e7f7477a-13ed-509c-bad8-b9282d6a576e', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('016a5352-8a93-5452-bf38-f04ee95f95bc', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Read paragraph
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
for questions 6-10
NB
You may use any letter more than once.
6
The rate for yawning shows some regular pattern.
7
Yawning is an inherent ability that appears in both animals and humans.
8
Stretching and yawning is not always going together.
9
Yawning may suggest people are having positive notice or response in communicating.
10
Some superior areas in the brain may deal with the infectious feature of yawning.

9 ____ Yawning may suggest people are having positive notice or response in communicating.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb38be56-c62d-57ce-8d67-614c8b4f200c', '016a5352-8a93-5452-bf38-f04ee95f95bc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70abeddd-4f04-5cc9-8d0a-c5eb32e125c1', '016a5352-8a93-5452-bf38-f04ee95f95bc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('820df96c-f8c8-568b-bfc1-379d0bb64e99', '016a5352-8a93-5452-bf38-f04ee95f95bc', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('905b5fdc-906f-5c23-8094-f4ca064e8273', '016a5352-8a93-5452-bf38-f04ee95f95bc', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c82f1206-e087-5d0b-ac4f-4431330be21a', '016a5352-8a93-5452-bf38-f04ee95f95bc', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('715393b4-5508-5bcd-a99f-efb31967b952', '016a5352-8a93-5452-bf38-f04ee95f95bc', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5232dab4-140b-5058-9492-c14bb77ca5f8', '016a5352-8a93-5452-bf38-f04ee95f95bc', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0389815-287f-5547-a679-0c7ca0c9462d', '016a5352-8a93-5452-bf38-f04ee95f95bc', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('28e0b361-5446-5fcd-a163-54b224ae9a53', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Read paragraph
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
for questions 6-10
NB
You may use any letter more than once.
6
The rate for yawning shows some regular pattern.
7
Yawning is an inherent ability that appears in both animals and humans.
8
Stretching and yawning is not always going together.
9
Yawning may suggest people are having positive notice or response in communicating.
10
Some superior areas in the brain may deal with the infectious feature of yawning.

10 ____ Some superior areas in the brain may deal with the infectious feature of yawning.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b47890aa-b577-5289-b8fa-90a65d05fdeb', '28e0b361-5446-5fcd-a163-54b224ae9a53', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43d67633-c6d5-510f-96ff-2a2b67dc1a16', '28e0b361-5446-5fcd-a163-54b224ae9a53', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8394a46-4874-52cb-ab24-5e8097581c18', '28e0b361-5446-5fcd-a163-54b224ae9a53', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26fdd185-4eea-5eae-aece-314d74f5d613', '28e0b361-5446-5fcd-a163-54b224ae9a53', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('822201da-e43b-5b91-a07c-24b586502457', '28e0b361-5446-5fcd-a163-54b224ae9a53', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2ef9b03-9780-5add-84ed-aff9c465bb0c', '28e0b361-5446-5fcd-a163-54b224ae9a53', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e698b512-9095-5642-be5a-acfd880df5a9', '28e0b361-5446-5fcd-a163-54b224ae9a53', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19ca404e-30ef-5f62-83da-c331b6cd0972', '28e0b361-5446-5fcd-a163-54b224ae9a53', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('07831ad2-b659-5e24-85c4-e2cced5b5650', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage?
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
Several students in Platek’s experiment did not comprehend why their tutor ask them to yawn back.
12
Some results from the certain experiment indicate the link between yawning and compassion.
13
Yawning can show an affirmative impact on the recovery from brain damage brought by s stroke.

11 ____ Several students in Platek’s experiment did not comprehend why their tutor ask them to yawn back.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29ac4eba-9949-5739-8fc8-d5347905b418', '07831ad2-b659-5e24-85c4-e2cced5b5650', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99066af1-ce16-576b-88c5-48b46456cab8', '07831ad2-b659-5e24-85c4-e2cced5b5650', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3293954-9e9f-526b-8828-403f7f984fa9', '07831ad2-b659-5e24-85c4-e2cced5b5650', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('14136644-a45f-573c-94a8-a0991f3430ab', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage?
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
Several students in Platek’s experiment did not comprehend why their tutor ask them to yawn back.
12
Some results from the certain experiment indicate the link between yawning and compassion.
13
Yawning can show an affirmative impact on the recovery from brain damage brought by s stroke.

12 ____ Some results from the certain experiment indicate the link between yawning and compassion.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01e5b06f-3a81-567d-a36e-6062ec5410ed', '14136644-a45f-573c-94a8-a0991f3430ab', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ad0edba-2ebd-5e19-bf84-38518a97a507', '14136644-a45f-573c-94a8-a0991f3430ab', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb271b3f-26d3-5b4c-8891-045078cfbd5d', '14136644-a45f-573c-94a8-a0991f3430ab', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4a1edffa-ee5b-5227-b223-8f41fb48608c', '129a28ab-7aeb-5347-8718-86a9b46aca4a', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage?
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
Several students in Platek’s experiment did not comprehend why their tutor ask them to yawn back.
12
Some results from the certain experiment indicate the link between yawning and compassion.
13
Yawning can show an affirmative impact on the recovery from brain damage brought by s stroke.

13 ____ Yawning can show an affirmative impact on the recovery from brain damage brought by s stroke.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('daf7cdd5-4017-5b9c-bc1c-83f9f13224ad', '4a1edffa-ee5b-5227-b223-8f41fb48608c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba869fda-5839-544c-b056-a4bbc7829c40', '4a1edffa-ee5b-5227-b223-8f41fb48608c', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3e8ad3f-e9ae-5b80-b02a-b6e8aae7519d', '4a1edffa-ee5b-5227-b223-8f41fb48608c', 3, $md$NOT GIVEN$md$, false);

COMMIT;
