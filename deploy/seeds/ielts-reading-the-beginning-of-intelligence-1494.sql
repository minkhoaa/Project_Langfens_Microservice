BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-beginning-of-intelligence-1494'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-beginning-of-intelligence-1494';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-beginning-of-intelligence-1494';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-beginning-of-intelligence-1494';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('da96671f-acfd-54b3-bc28-274a54d94570', 'ielts-reading-the-beginning-of-intelligence-1494', $t$The beginning of intelligence$t$, $md$## The beginning of intelligence

Nguồn:
- Test: https://mini-ielts.com/1494/reading/the-beginning-of-intelligence
- Solution: https://mini-ielts.com/1494/view-solution/reading/the-beginning-of-intelligence$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 'da96671f-acfd-54b3-bc28-274a54d94570', 1, $t$Reading — The beginning of intelligence$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The beginning of intelligence

A No one doubts that intelligence develops as children grow older. Yet the concept of intelligence has proved both quite difficult to define in unambiguous terms and unexpectedly controversial in some respects. Although, at one level, there seem to be almost as many definitions of intelligence as people who have tried to define it, there is broad agreement on two key features. That is, intelligence involves the capacity not only to learn from experience but also to adapt to one’s environment. However, we cannot leave the concept there. Before turning to what is known about the development of intelligence, it is necessary to consider whether we are considering the growth of one or many skills. That question has been tackled in rather different ways by psychometricians and by developmentalists.

B The former group has examined the issue by determining how children’s abilities on a wide range of tasks intercorrelate, or go together. Statistical techniques have been used to find out whether the patterns are best explained by one broad underlying capacity, general intelligence, or by a set of multiple, relatively separate, special skills in domains such as verbal and visuospatial ability. While it cannot be claimed that everyone agrees on what the results mean, most people now accept that for practical purposes it is reasonable to suppose that both are involved. In brief, the evidence in favour of some kind of general intellectual capacity is that people who are superior (or inferior) on one type of task tend also to be superior (or inferior) on others. Moreover, general measures of intelligence tend to have considerable powers to predict a person’s performance on a wide range of tasks requiring special skills. Nevertheless, it is plain that it is not at all uncommon for individuals to be very good at some sorts of task and yet quite poor at some others.

C Furthermore the influences that affect verbal skills are not quite the same as those that affect other skills. This approach to investigating intelligence is based on the nature of the task involved, but studies of age-related changes show that this is not the only, or necessarily the most important, approach. For instance, some decades ago, Horn and Cattell argued for a differentiation between what they termed‘fluid’ and‘crystallised’ intelligence. Fluid abilities are best assessed by tests that require mental manipulation of abstract symbols. Crystallised abilities, by contrast, reflect knowledge of the environment in which we live and past experience of similar tasks; they may be assessed by tests of comprehension and information. It seems that fluid abilities peak in early adult life, whereas crystallised abilities increase up to advanced old.

D Developmental studies also show that the interconnections between different skills vary with age. Thus in the first year of life an interest in perceptual patterns is a major contributor to cognitive abilities, whereas verbal abilities are more important later on. These findings seemed to suggest a substantial lack of continuity between infancy and middle childhood. However, it is important to realise that the apparent discontinuity will vary according to which of the cognitive skills were assessed in infancy. It has been found that tests of coping with novelty do predict later intelligence. These findings reinforce the view that young children’s intellectual performance needs to be assessed from their interest in and curiosity about the environment, and the extent to which this is applied to new situations, as well as by standardised intelligence testing.

E These psychometric approaches have focused on children’s increase in cognitive skills as they grow older. Piaget brought about a revolution in the approach to cognitive development through his arguments ( backed up by observations) that the focus should be on the thinking processes involved rather than on levels of cognitive achievement These ideas of Piaget gave rise to an immense body of research and it would be true to say that subsequent thinking has been heavily dependent on his genius in opening up new ways of thinking about cognitive development. Nevertheless, most of his concepts have had to be so radically revised, or rejected, that his theory no longer provides an appropriate basis for thinking about cognitive development To appreciate why that is so, we need to focus on some rather different elements of Piaget’s theorising.

F The first element, which has stood the test of time, is his view that the child is nactive agent of learning and of the importance of this activity in cognitive development Numerous studies have shown how infants actively scan their environment; how they prefer patterned to non-patterned objects, how they choose novel over familiar stimuli, and how they explore their environment as if to see how it works. Children’s questions and comments vividly illustrate the ways in which they are constantly constructing schemes of what they know and trying out their ideas of how to fit new knowledge into those schemes or deciding that the schemes need modification. Moreover, a variety of studies have shown that active experiences have a greater effect on learning than comparable passive experiences. However, a second element concerns the notion that development proceeds through a series of separate stages that have to be gone through step-by-step, in a set order, each of which is characterised by a particular cognitive structure. That has turned out to be a rather misleading way of thinking about cognitive development, although it is not wholly wrong.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d705a21-371b-5cf2-8492-de9529cdcac6', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D. Write your answers in boxes
1-4
on your answer sheet
1. Most researchers accept that one feature of intelligence is the ability to
A
change our behaviour according to our situation.
B
react to others’ behaviour patterns.
C
experiment with environmental features.
D
cope with unexpected setbacks.
2. What have psychometricians used statistics for?
A
to find out if cooperative tasks are a useful tool in measuring certain skills
B
to explore whether several abilities are involved in the development of intelligence
C
to demonstrate that mathematical models can predict test results for different skills
D
to discover whether common sense is fundamental to developing children’s abilities
3. Why are Horn and Cattell mentioned?
A
They disagreed about the interpretation of different intelligence tests.
B
Their research concerned both linguistic and mathematical abilities.
C
They were the first to prove that intelligence can be measured by testing a range of special skills.
D
Their work was an example of research into how people’s cognitive skills vary with age.
4. What was innovative about Piaget’s research?
A
He refused to accept that children developed according to a set pattern.
B
He emphasised the way children thought more than how well they did in tests.
C
He used visually appealing materials instead of traditional intelligence tests.
D
He studied children of all ages and levels of intelligence.

Choose the correct letter, A, B, C or D. Write your answers in boxes 1-4 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('187b9ad7-825b-5275-a503-219509e6c589', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D. Write your answers in boxes
1-4
on your answer sheet
1. Most researchers accept that one feature of intelligence is the ability to
A
change our behaviour according to our situation.
B
react to others’ behaviour patterns.
C
experiment with environmental features.
D
cope with unexpected setbacks.
2. What have psychometricians used statistics for?
A
to find out if cooperative tasks are a useful tool in measuring certain skills
B
to explore whether several abilities are involved in the development of intelligence
C
to demonstrate that mathematical models can predict test results for different skills
D
to discover whether common sense is fundamental to developing children’s abilities
3. Why are Horn and Cattell mentioned?
A
They disagreed about the interpretation of different intelligence tests.
B
Their research concerned both linguistic and mathematical abilities.
C
They were the first to prove that intelligence can be measured by testing a range of special skills.
D
Their work was an example of research into how people’s cognitive skills vary with age.
4. What was innovative about Piaget’s research?
A
He refused to accept that children developed according to a set pattern.
B
He emphasised the way children thought more than how well they did in tests.
C
He used visually appealing materials instead of traditional intelligence tests.
D
He studied children of all ages and levels of intelligence.

Choose the correct letter, A, B, C or D. Write your answers in boxes 1-4 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d9231d1f-c6f7-53a1-96a8-e6d805d7ba99', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D. Write your answers in boxes
1-4
on your answer sheet
1. Most researchers accept that one feature of intelligence is the ability to
A
change our behaviour according to our situation.
B
react to others’ behaviour patterns.
C
experiment with environmental features.
D
cope with unexpected setbacks.
2. What have psychometricians used statistics for?
A
to find out if cooperative tasks are a useful tool in measuring certain skills
B
to explore whether several abilities are involved in the development of intelligence
C
to demonstrate that mathematical models can predict test results for different skills
D
to discover whether common sense is fundamental to developing children’s abilities
3. Why are Horn and Cattell mentioned?
A
They disagreed about the interpretation of different intelligence tests.
B
Their research concerned both linguistic and mathematical abilities.
C
They were the first to prove that intelligence can be measured by testing a range of special skills.
D
Their work was an example of research into how people’s cognitive skills vary with age.
4. What was innovative about Piaget’s research?
A
He refused to accept that children developed according to a set pattern.
B
He emphasised the way children thought more than how well they did in tests.
C
He used visually appealing materials instead of traditional intelligence tests.
D
He studied children of all ages and levels of intelligence.

Choose the correct letter, A, B, C or D. Write your answers in boxes 1-4 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8dc883c-31c2-584e-93ef-61984532ce1d', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D. Write your answers in boxes
1-4
on your answer sheet
1. Most researchers accept that one feature of intelligence is the ability to
A
change our behaviour according to our situation.
B
react to others’ behaviour patterns.
C
experiment with environmental features.
D
cope with unexpected setbacks.
2. What have psychometricians used statistics for?
A
to find out if cooperative tasks are a useful tool in measuring certain skills
B
to explore whether several abilities are involved in the development of intelligence
C
to demonstrate that mathematical models can predict test results for different skills
D
to discover whether common sense is fundamental to developing children’s abilities
3. Why are Horn and Cattell mentioned?
A
They disagreed about the interpretation of different intelligence tests.
B
Their research concerned both linguistic and mathematical abilities.
C
They were the first to prove that intelligence can be measured by testing a range of special skills.
D
Their work was an example of research into how people’s cognitive skills vary with age.
4. What was innovative about Piaget’s research?
A
He refused to accept that children developed according to a set pattern.
B
He emphasised the way children thought more than how well they did in tests.
C
He used visually appealing materials instead of traditional intelligence tests.
D
He studied children of all ages and levels of intelligence.

Choose the correct letter, A, B, C or D. Write your answers in boxes 1-4 on your answer sheet$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e2ba3ae-5a97-5153-a7d0-62cd357736ce', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage? In boxes 5-10
on your answer sheet, write
YES
if the sataement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
A surprising number of academics have come to the same conclusion about what the term intelligence means.
6
A general test of intelligence is unlikely to indicate the level of performance in every type of task.
7
The elderly perform less well on comprehension tests than young adults.
8
We must take into account which skills are tested when comparing intelligence at different ages.
9
Piaget’s work influenced theoretical studies more than practical research.
10
Piaget’s emphasis on active learning has been discredited by later researchers.

5 ____ A surprising number of academics have come to the same conclusion about what the term intelligence means.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a53bd6a-fd15-5762-9a58-bafb2b168b7d', '4e2ba3ae-5a97-5153-a7d0-62cd357736ce', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a9ef172-1e8f-57ee-8513-528331a06d34', '4e2ba3ae-5a97-5153-a7d0-62cd357736ce', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b0a1f06-0f9c-554e-9682-6cb19479b10b', '4e2ba3ae-5a97-5153-a7d0-62cd357736ce', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4d7e11e3-751c-5c76-9c83-9738685f8748', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage? In boxes 5-10
on your answer sheet, write
YES
if the sataement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
A surprising number of academics have come to the same conclusion about what the term intelligence means.
6
A general test of intelligence is unlikely to indicate the level of performance in every type of task.
7
The elderly perform less well on comprehension tests than young adults.
8
We must take into account which skills are tested when comparing intelligence at different ages.
9
Piaget’s work influenced theoretical studies more than practical research.
10
Piaget’s emphasis on active learning has been discredited by later researchers.

6 ____ A general test of intelligence is unlikely to indicate the level of performance in every type of task.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53ede7c9-fa3d-5bec-b7cf-eb7952d8e3eb', '4d7e11e3-751c-5c76-9c83-9738685f8748', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3dd38b1c-51a0-559e-8434-7621acdbe7cc', '4d7e11e3-751c-5c76-9c83-9738685f8748', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ce07755-1ff6-5cfa-b384-3356d19d371b', '4d7e11e3-751c-5c76-9c83-9738685f8748', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af2aca0d-72cc-5b95-9009-5d81f06e9c4d', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage? In boxes 5-10
on your answer sheet, write
YES
if the sataement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
A surprising number of academics have come to the same conclusion about what the term intelligence means.
6
A general test of intelligence is unlikely to indicate the level of performance in every type of task.
7
The elderly perform less well on comprehension tests than young adults.
8
We must take into account which skills are tested when comparing intelligence at different ages.
9
Piaget’s work influenced theoretical studies more than practical research.
10
Piaget’s emphasis on active learning has been discredited by later researchers.

7 ____ The elderly perform less well on comprehension tests than young adults.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e331a8dd-a854-5544-90fc-09e3c0367388', 'af2aca0d-72cc-5b95-9009-5d81f06e9c4d', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bccb391-46d2-5a63-bc6b-90e17a78f9ad', 'af2aca0d-72cc-5b95-9009-5d81f06e9c4d', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb2f9edd-a73b-5044-a843-f708918d2f6d', 'af2aca0d-72cc-5b95-9009-5d81f06e9c4d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6596775f-ba31-5195-80cc-ffb5aec3e5a9', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage? In boxes 5-10
on your answer sheet, write
YES
if the sataement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
A surprising number of academics have come to the same conclusion about what the term intelligence means.
6
A general test of intelligence is unlikely to indicate the level of performance in every type of task.
7
The elderly perform less well on comprehension tests than young adults.
8
We must take into account which skills are tested when comparing intelligence at different ages.
9
Piaget’s work influenced theoretical studies more than practical research.
10
Piaget’s emphasis on active learning has been discredited by later researchers.

8 ____ We must take into account which skills are tested when comparing intelligence at different ages.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d111adc-6327-5119-9f93-096bfa1eaa0a', '6596775f-ba31-5195-80cc-ffb5aec3e5a9', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5ff0de3-789a-5a73-bd34-6097fbcab839', '6596775f-ba31-5195-80cc-ffb5aec3e5a9', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2aaf77ce-4ec3-58d2-aa53-acb4f13a0662', '6596775f-ba31-5195-80cc-ffb5aec3e5a9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3361ffde-eefe-546b-a4be-e870e2610d64', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage? In boxes 5-10
on your answer sheet, write
YES
if the sataement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
A surprising number of academics have come to the same conclusion about what the term intelligence means.
6
A general test of intelligence is unlikely to indicate the level of performance in every type of task.
7
The elderly perform less well on comprehension tests than young adults.
8
We must take into account which skills are tested when comparing intelligence at different ages.
9
Piaget’s work influenced theoretical studies more than practical research.
10
Piaget’s emphasis on active learning has been discredited by later researchers.

9 ____ Piaget’s work influenced theoretical studies more than practical research.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b55c715f-94d8-52f2-a906-eafe2cfbef65', '3361ffde-eefe-546b-a4be-e870e2610d64', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7a904f7-b477-5ea2-9bf9-e61910d56efd', '3361ffde-eefe-546b-a4be-e870e2610d64', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23beef59-2364-5691-86cc-26e452728dbb', '3361ffde-eefe-546b-a4be-e870e2610d64', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f1199451-a155-5253-870d-666e5ccc1c6f', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Do the following statements agree with the information given in Reading Passage? In boxes 5-10
on your answer sheet, write
YES
if the sataement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
A surprising number of academics have come to the same conclusion about what the term intelligence means.
6
A general test of intelligence is unlikely to indicate the level of performance in every type of task.
7
The elderly perform less well on comprehension tests than young adults.
8
We must take into account which skills are tested when comparing intelligence at different ages.
9
Piaget’s work influenced theoretical studies more than practical research.
10
Piaget’s emphasis on active learning has been discredited by later researchers.

10 ____ Piaget’s emphasis on active learning has been discredited by later researchers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7db8323-6fd7-5938-a502-f068953fdecf', 'f1199451-a155-5253-870d-666e5ccc1c6f', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7514bb7f-a88d-5af6-870f-c4a0e7100f8f', 'f1199451-a155-5253-870d-666e5ccc1c6f', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e5f65d8-6f1b-5590-8b0f-98af77392925', 'f1199451-a155-5253-870d-666e5ccc1c6f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('022e9146-ff74-566c-963f-36e43849bcc0', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete the summary using the list of words, A-I, below. Write your answers in boxes
11-14
on your answer sheet.
Researchers investigating the development of intelligence have shown that
11
skills become more significant with age. One good predictor of
12
intelligence is the degree to which small children are
13
about their surroundings and how much interest they show on finding themselves in an
14
setting.
A adult
B practical
C verbal
D spatial
E inquisitive
F uncertain
G academic
H plentiful
I unfamiliar

Researchers investigating the development of intelligence have shown that 11 ____ skills become more significant with age. One good predictor of 12 ____ intelligence is the degree to which small children are 13 ____ about their surroundings and how much interest they show on finding themselves in an 14 ____ setting.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30e240fe-f85b-553b-8753-4323fd8a5e9a', '022e9146-ff74-566c-963f-36e43849bcc0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d22bce65-261e-5352-abdb-7afcf3e3b214', '022e9146-ff74-566c-963f-36e43849bcc0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f0fb60b-4506-56ff-83f5-b763c661382b', '022e9146-ff74-566c-963f-36e43849bcc0', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edc14d57-7ef9-5220-bbfe-41a00237d30c', '022e9146-ff74-566c-963f-36e43849bcc0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee5e1ad4-7fe9-5b61-be9d-9b0a68942355', '022e9146-ff74-566c-963f-36e43849bcc0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95ce4ec9-030f-570e-8e8c-ce292febc6a5', '022e9146-ff74-566c-963f-36e43849bcc0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2706862-f3fa-5570-a488-f41a972b54de', '022e9146-ff74-566c-963f-36e43849bcc0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b27175b-4a48-57d5-b9b6-b89dc107b3ca', '022e9146-ff74-566c-963f-36e43849bcc0', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('011d0c98-f798-55cc-bc69-19a75864e17b', '022e9146-ff74-566c-963f-36e43849bcc0', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('41beb68c-0f33-563c-8bc3-814af4dc789d', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete the summary using the list of words, A-I, below. Write your answers in boxes
11-14
on your answer sheet.
Researchers investigating the development of intelligence have shown that
11
skills become more significant with age. One good predictor of
12
intelligence is the degree to which small children are
13
about their surroundings and how much interest they show on finding themselves in an
14
setting.
A adult
B practical
C verbal
D spatial
E inquisitive
F uncertain
G academic
H plentiful
I unfamiliar

Researchers investigating the development of intelligence have shown that 11 ____ skills become more significant with age. One good predictor of 12 ____ intelligence is the degree to which small children are 13 ____ about their surroundings and how much interest they show on finding themselves in an 14 ____ setting.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('593c9ba6-5adc-5043-a489-ce1d5870329c', '41beb68c-0f33-563c-8bc3-814af4dc789d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95a5aa1c-71ad-5079-93f0-d940d154fd75', '41beb68c-0f33-563c-8bc3-814af4dc789d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e686ff6-a581-57ad-81b9-7d5a0ccae4e4', '41beb68c-0f33-563c-8bc3-814af4dc789d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9403ef1-920b-5e8b-b843-74ee2073b0d4', '41beb68c-0f33-563c-8bc3-814af4dc789d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f1069da-b8e5-5a17-bf69-6230ac660b9e', '41beb68c-0f33-563c-8bc3-814af4dc789d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2419f15f-5d44-504a-bfd8-c055963bf12c', '41beb68c-0f33-563c-8bc3-814af4dc789d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5b7c164-a914-5ac6-969e-b1e88f754cc7', '41beb68c-0f33-563c-8bc3-814af4dc789d', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b163cd6-98bc-50f6-bab6-1857fc2d8ca9', '41beb68c-0f33-563c-8bc3-814af4dc789d', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56b66e5b-ac32-5b91-a10f-feac2f43b30f', '41beb68c-0f33-563c-8bc3-814af4dc789d', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5590e958-d566-57cd-b582-3de45d79c540', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete the summary using the list of words, A-I, below. Write your answers in boxes
11-14
on your answer sheet.
Researchers investigating the development of intelligence have shown that
11
skills become more significant with age. One good predictor of
12
intelligence is the degree to which small children are
13
about their surroundings and how much interest they show on finding themselves in an
14
setting.
A adult
B practical
C verbal
D spatial
E inquisitive
F uncertain
G academic
H plentiful
I unfamiliar

Researchers investigating the development of intelligence have shown that 11 ____ skills become more significant with age. One good predictor of 12 ____ intelligence is the degree to which small children are 13 ____ about their surroundings and how much interest they show on finding themselves in an 14 ____ setting.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('074b62dc-d332-5cf4-8d56-aed9bb114e3d', '5590e958-d566-57cd-b582-3de45d79c540', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fa3b756-959c-5a92-9c8f-8309a78ed79b', '5590e958-d566-57cd-b582-3de45d79c540', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fa235cc-00df-56b8-8a20-ab98f9fcddf0', '5590e958-d566-57cd-b582-3de45d79c540', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed3ceac4-5e79-552e-8382-453d8c9b0224', '5590e958-d566-57cd-b582-3de45d79c540', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc5d269b-3b71-5322-be84-6fb9dc9e2d5c', '5590e958-d566-57cd-b582-3de45d79c540', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f68e7c3-188b-5c93-98b5-8946217b9e72', '5590e958-d566-57cd-b582-3de45d79c540', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61f93958-4277-51ba-b905-fa34e7a058ba', '5590e958-d566-57cd-b582-3de45d79c540', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbddb73d-a053-51da-8c95-ca64f88e9581', '5590e958-d566-57cd-b582-3de45d79c540', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2c5556a-56be-52fa-8007-a121b2b05909', '5590e958-d566-57cd-b582-3de45d79c540', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('33a04bfe-3eef-57db-b5d5-913b22ab7d53', 'ac6946bc-04ac-5c5c-bb07-c20d6fb9b494', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete the summary using the list of words, A-I, below. Write your answers in boxes
11-14
on your answer sheet.
Researchers investigating the development of intelligence have shown that
11
skills become more significant with age. One good predictor of
12
intelligence is the degree to which small children are
13
about their surroundings and how much interest they show on finding themselves in an
14
setting.
A adult
B practical
C verbal
D spatial
E inquisitive
F uncertain
G academic
H plentiful
I unfamiliar

Researchers investigating the development of intelligence have shown that 11 ____ skills become more significant with age. One good predictor of 12 ____ intelligence is the degree to which small children are 13 ____ about their surroundings and how much interest they show on finding themselves in an 14 ____ setting.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6000be88-70c0-5575-94dd-a7bb47fa671b', '33a04bfe-3eef-57db-b5d5-913b22ab7d53', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9f0afe2-a4da-5be3-bb7e-76082ea60b1e', '33a04bfe-3eef-57db-b5d5-913b22ab7d53', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9c12a24-2151-5e97-817c-5f9d2f4a41ba', '33a04bfe-3eef-57db-b5d5-913b22ab7d53', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('199e4a74-4252-541e-b5a1-b7eb5c9cf239', '33a04bfe-3eef-57db-b5d5-913b22ab7d53', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a2e7cd1-4575-5d09-98d0-1c5b64228966', '33a04bfe-3eef-57db-b5d5-913b22ab7d53', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4b1b2c3-d5cd-59da-9e4e-29fde4acf857', '33a04bfe-3eef-57db-b5d5-913b22ab7d53', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8babe697-c57f-5bd8-83f3-de66e5adbe38', '33a04bfe-3eef-57db-b5d5-913b22ab7d53', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('705bd2ad-d875-557b-aee6-cabc3d6055aa', '33a04bfe-3eef-57db-b5d5-913b22ab7d53', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac33b9f8-54bb-5ade-97a2-089d48992617', '33a04bfe-3eef-57db-b5d5-913b22ab7d53', 9, $md$I$md$, false);

COMMIT;
