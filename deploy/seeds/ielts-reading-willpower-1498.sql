BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-willpower-1498'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-willpower-1498';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-willpower-1498';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-willpower-1498';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('8185f2c6-c6d5-5332-9f0d-bbb79f355286', 'ielts-reading-willpower-1498', $t$Willpower$t$, $md$## Willpower

Nguồn:
- Test: https://mini-ielts.com/1498/reading/willpower
- Solution: https://mini-ielts.com/1498/view-solution/reading/willpower$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('d31e9e6f-bea9-518c-b845-ba0b212e361b', '8185f2c6-c6d5-5332-9f0d-bbb79f355286', 1, $t$Reading — Willpower$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Willpower

A

Although willpower does not shape our decisions, it determines whether and how long we can follow through on them. It almost single-handedly determines life outcomes. Interestingly, research suggests the general population is indeed aware of how essential willpower is to their wellbeing; survey participants routinely identify a ‘lack of willpower’ as the major impediment to making beneficial life changes. There are, however, misunderstandings surrounding the nature of willpower and how we can acquire more of it. There is a widespread misperception, for example, that increased leisure time would lead to subsequent increases in willpower.

B

Although the concept of willpower is often explained through single-word terms, such as ‘resolve’ or ‘drive’, it refers in fact to a variety of behaviours and situations. There is a common perception that willpower entails resisting some kind of a ‘treat’, such as a sugary drink or a lazy morning in bed, in favour of decisions that we know are better for us, such as drinking water or going to the gym. Of course this is a familiar phenomenon for all. Yet willpower also involves elements such as overriding negative thought processes, biting your tongue in social situations, or persevering through a difficult activity. At the heart of any exercise of willpower, however, is the notion of ‘delayed gratification’, which involves resisting immediate satisfaction for a course that will yield greater or more permanent satisfaction in the long run.

C

Scientists are making general investigations into why some individuals are better able than others to delay gratification and thus employ their willpower, but the genetic or environmental origins of this ability remain a mystery for now. Some groups who are particularly vulnerable to reduced willpower capacity, such as those with addictive personalities, may claim a biological origin for their problems. What is clear is that levels of willpower typically remain consistent over time (studies tracking individuals from early childhood to their adult years demonstrate a remarkable consistency in willpower abilities). In the short term, however, our ability to draw on willpower can fluctuate dramatically due to factors such as fatigue, diet and stress. Indeed, research by Matthew Gailliot suggests that willpower, even in the absence of physical activity, both requires and drains blood glucose levels, suggesting that willpower operates more or less like a ‘muscle’, and, like a muscle, requires fuel for optimum functioning.

D

These observations lead to an important question: if the strength of our willpower at the age of thirty-five is somehow pegged to our ability at the age of four, are all efforts to improve our willpower certain to prove futile? According to newer research, this is not necessarily the case. Gregory M. Walton, for example, found that a single verbal cue – telling research participants how strenuous mental tasks could ‘energise’ them for further challenging activities – made a profound difference in terms of how much willpower participants could draw upon to complete the activity. Just as our willpower is easily drained by negative influences, it appears that willpower can also be boosted by other prompts, such as encouragement or optimistic self-talk.

E

Strengthening willpower thus relies on a two-pronged approach: reducing negative influences and improving positive ones. One of the most popular and effective methods simply involves avoiding willpower depletion triggers, and is based on the old adage, ‘out of sight, out of mind’. In one study, workers who kept a bowl of enticing candy on their desks were far more likely to indulge than those who placed it in a desk drawer. It also appears that finding sources of motivation from within us may be important. In another study, Mark Muraven found that those who felt compelled by an external authority to exert self-control experienced far greater rates of willpower depletion than those who identified their own reasons for taking a particular course of action. This idea that our mental convictions can influence willpower was borne out by Veronika Job. Her research indicates that those who think that willpower is a finite resource exhaust their supplies of this commodity long before those who do not hold this opinion.

F

Willpower is clearly fundamental to our ability to follow through on our decisions but, as psychologist Roy Baumeister has discovered, a lack of willpower may not be the sole impediment every time our good intentions fail to manifest themselves. A critical precursor, he suggests, is motivation – if we are only mildly invested in the change we are trying to make, our efforts are bound to fall short. This may be why so many of us abandon our New Year’s Resolutions – if these were actions we really wanted to take, rather than things we felt we ought to be doing, we would probably be doing them already. In addition, Muraven emphasises the value of monitoring progress towards a desired result, such as by using a fitness journal, or keeping a record of savings toward a new purchase. The importance of motivation and monitoring cannot be overstated. Indeed, it appears that, even when our willpower reserves are entirely depleted, motivation alone may be sufficient to keep us on the course we originally chose.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1aaef535-9c99-5975-b00a-ebfab9c3f8b5', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Willpower is the most significant factor in determining success in life.
2
People with more free time typically have better willpower.
3
Willpower mostly applies to matters of diet and exercise.
4
The strongest indicator of willpower is the ability to choose long-term rather than short-term rewards.
5
Researchers have studied the genetic basis of willpower.
6
Levels of willpower usually stay the same throughout our lives.
7
Regular physical exercise improves our willpower ability.

1 ____ Willpower is the most significant factor in determining success in life.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7742a7e-3910-53df-8ea0-d90de866c03f', '1aaef535-9c99-5975-b00a-ebfab9c3f8b5', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da48c3bb-4dcd-59bd-8293-7f9dc675938d', '1aaef535-9c99-5975-b00a-ebfab9c3f8b5', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcdd9448-20dc-5f2d-80d5-a6b0d08e58aa', '1aaef535-9c99-5975-b00a-ebfab9c3f8b5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('023982c7-51f7-5c83-bfe3-7be4b5e844bb', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Willpower is the most significant factor in determining success in life.
2
People with more free time typically have better willpower.
3
Willpower mostly applies to matters of diet and exercise.
4
The strongest indicator of willpower is the ability to choose long-term rather than short-term rewards.
5
Researchers have studied the genetic basis of willpower.
6
Levels of willpower usually stay the same throughout our lives.
7
Regular physical exercise improves our willpower ability.

2 ____ People with more free time typically have better willpower.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b1e9a37-12de-56d9-92b7-2bbeadf12ce2', '023982c7-51f7-5c83-bfe3-7be4b5e844bb', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1f2c3fb-6324-5a34-ae55-b144e23b2335', '023982c7-51f7-5c83-bfe3-7be4b5e844bb', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8deb4b35-bdb5-58b3-be6c-84e92c9e2a1c', '023982c7-51f7-5c83-bfe3-7be4b5e844bb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('11b8b67d-587a-5773-9de9-d02192cef654', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Willpower is the most significant factor in determining success in life.
2
People with more free time typically have better willpower.
3
Willpower mostly applies to matters of diet and exercise.
4
The strongest indicator of willpower is the ability to choose long-term rather than short-term rewards.
5
Researchers have studied the genetic basis of willpower.
6
Levels of willpower usually stay the same throughout our lives.
7
Regular physical exercise improves our willpower ability.

3 ____ Willpower mostly applies to matters of diet and exercise.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('261fb657-295c-5928-ae8b-f59aff3c39f6', '11b8b67d-587a-5773-9de9-d02192cef654', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fec31b0-6c5b-5ac3-8e84-79cf4385a660', '11b8b67d-587a-5773-9de9-d02192cef654', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8be3e744-7f43-5c9b-a58c-1a566965d582', '11b8b67d-587a-5773-9de9-d02192cef654', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7e55d547-5dd2-54a9-883f-40f2722cc6de', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Willpower is the most significant factor in determining success in life.
2
People with more free time typically have better willpower.
3
Willpower mostly applies to matters of diet and exercise.
4
The strongest indicator of willpower is the ability to choose long-term rather than short-term rewards.
5
Researchers have studied the genetic basis of willpower.
6
Levels of willpower usually stay the same throughout our lives.
7
Regular physical exercise improves our willpower ability.

4 ____ The strongest indicator of willpower is the ability to choose long-term rather than short-term rewards.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04dbad60-d2a7-55d2-8a60-173e1f48d536', '7e55d547-5dd2-54a9-883f-40f2722cc6de', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2fb5938-ed50-5f7f-911c-39399b9ee160', '7e55d547-5dd2-54a9-883f-40f2722cc6de', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c8b5d04-26c7-577b-bb20-0636342873fa', '7e55d547-5dd2-54a9-883f-40f2722cc6de', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bf320d43-cb5c-543a-a894-9a63c9be35bc', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Willpower is the most significant factor in determining success in life.
2
People with more free time typically have better willpower.
3
Willpower mostly applies to matters of diet and exercise.
4
The strongest indicator of willpower is the ability to choose long-term rather than short-term rewards.
5
Researchers have studied the genetic basis of willpower.
6
Levels of willpower usually stay the same throughout our lives.
7
Regular physical exercise improves our willpower ability.

5 ____ Researchers have studied the genetic basis of willpower.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbd31265-64f2-5f16-929c-f4b466059941', 'bf320d43-cb5c-543a-a894-9a63c9be35bc', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae2431b1-3aac-5dae-b07a-0653301e1ef2', 'bf320d43-cb5c-543a-a894-9a63c9be35bc', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e23d0903-b99e-5b62-9324-860edbea34a9', 'bf320d43-cb5c-543a-a894-9a63c9be35bc', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d76b8984-8e0c-5c27-aa98-69d5038f0f27', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Willpower is the most significant factor in determining success in life.
2
People with more free time typically have better willpower.
3
Willpower mostly applies to matters of diet and exercise.
4
The strongest indicator of willpower is the ability to choose long-term rather than short-term rewards.
5
Researchers have studied the genetic basis of willpower.
6
Levels of willpower usually stay the same throughout our lives.
7
Regular physical exercise improves our willpower ability.

6 ____ Levels of willpower usually stay the same throughout our lives.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c26c8448-dbbc-54b2-83a4-9ffcf6a863e9', 'd76b8984-8e0c-5c27-aa98-69d5038f0f27', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed8226d1-f4c8-58dd-ace9-0ba2fe2a4b73', 'd76b8984-8e0c-5c27-aa98-69d5038f0f27', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba018819-a4c0-5070-884d-1a6585195095', 'd76b8984-8e0c-5c27-aa98-69d5038f0f27', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a4591be8-2496-56d9-a82f-73e526463a40', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Willpower is the most significant factor in determining success in life.
2
People with more free time typically have better willpower.
3
Willpower mostly applies to matters of diet and exercise.
4
The strongest indicator of willpower is the ability to choose long-term rather than short-term rewards.
5
Researchers have studied the genetic basis of willpower.
6
Levels of willpower usually stay the same throughout our lives.
7
Regular physical exercise improves our willpower ability.

7 ____ Regular physical exercise improves our willpower ability.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4bedc9de-eca5-5bfa-8bff-6dd210f8f15c', 'a4591be8-2496-56d9-a82f-73e526463a40', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b571dbf0-cc3f-5d9b-9775-6f2ef61bede1', 'a4591be8-2496-56d9-a82f-73e526463a40', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a758337-1d24-5e77-ad5b-2e4e0c250c70', 'a4591be8-2496-56d9-a82f-73e526463a40', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ff03102b-6264-56da-b869-0725e5f10de5', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of researchers below.
Match each statement with the correct person,
A–D
.
Write the correct letter,
A–D
, in boxes
8-13
on your answer sheet.
NB
You may use some letters more than once.
This researcher …
8
identified a key factor that is necessary for willpower to function.
9
suggested that willpower is affected by our beliefs.
10
examined how our body responds to the use of willpower.
11
discovered how important it is to make and track goals.
12
found that taking actions to please others decreases our willpower.
13
found that willpower can increase through simple positive thoughts.
List of People
A
Matthew Gailliot
B
Gregory M. Walton
C
Mark Muraven
D
Veronika Job
E
Roy Baumeister

8 ____ identified a key factor that is necessary for willpower to function.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd161728-13d7-57ab-9251-fedf6b3c6b46', 'ff03102b-6264-56da-b869-0725e5f10de5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80233d48-b3af-506f-aa7f-c4714e2019ed', 'ff03102b-6264-56da-b869-0725e5f10de5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a3067f0-0c6e-5d2e-b3af-65e9e4507bfe', 'ff03102b-6264-56da-b869-0725e5f10de5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c44297cd-22d5-5d72-ae92-2d04f2cebd54', 'ff03102b-6264-56da-b869-0725e5f10de5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22b14b23-d1ce-5073-842a-460b4c9de072', 'ff03102b-6264-56da-b869-0725e5f10de5', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8610bc02-e19e-523f-8922-1268711a1a56', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of researchers below.
Match each statement with the correct person,
A–D
.
Write the correct letter,
A–D
, in boxes
8-13
on your answer sheet.
NB
You may use some letters more than once.
This researcher …
8
identified a key factor that is necessary for willpower to function.
9
suggested that willpower is affected by our beliefs.
10
examined how our body responds to the use of willpower.
11
discovered how important it is to make and track goals.
12
found that taking actions to please others decreases our willpower.
13
found that willpower can increase through simple positive thoughts.
List of People
A
Matthew Gailliot
B
Gregory M. Walton
C
Mark Muraven
D
Veronika Job
E
Roy Baumeister

9 ____ suggested that willpower is affected by our beliefs.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('412a062f-34f4-5b58-a8e2-16d2773fd07d', '8610bc02-e19e-523f-8922-1268711a1a56', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('351fccf9-c643-5d90-8196-35029e479b91', '8610bc02-e19e-523f-8922-1268711a1a56', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae8656be-7f6d-5317-8a3b-626da158ddd2', '8610bc02-e19e-523f-8922-1268711a1a56', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('082310d5-c8a4-58dc-ab49-fc8ad928fb44', '8610bc02-e19e-523f-8922-1268711a1a56', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f2854b2-650d-5a4d-9c2c-18a7514b3408', '8610bc02-e19e-523f-8922-1268711a1a56', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bfc7e715-18c4-50cd-8207-eb4d8bc16403', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of researchers below.
Match each statement with the correct person,
A–D
.
Write the correct letter,
A–D
, in boxes
8-13
on your answer sheet.
NB
You may use some letters more than once.
This researcher …
8
identified a key factor that is necessary for willpower to function.
9
suggested that willpower is affected by our beliefs.
10
examined how our body responds to the use of willpower.
11
discovered how important it is to make and track goals.
12
found that taking actions to please others decreases our willpower.
13
found that willpower can increase through simple positive thoughts.
List of People
A
Matthew Gailliot
B
Gregory M. Walton
C
Mark Muraven
D
Veronika Job
E
Roy Baumeister

10 ____ examined how our body responds to the use of willpower.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a32ab7da-e524-54a1-b466-61c7a397b8a4', 'bfc7e715-18c4-50cd-8207-eb4d8bc16403', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdf140a1-9235-50d6-8e4b-c9595aad2f24', 'bfc7e715-18c4-50cd-8207-eb4d8bc16403', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a52d1018-67bd-525c-854a-8339b8db14cc', 'bfc7e715-18c4-50cd-8207-eb4d8bc16403', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51d39235-b753-53a2-83dc-59d39934f941', 'bfc7e715-18c4-50cd-8207-eb4d8bc16403', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ba58801-e73c-5904-b6f7-a9df0bc1dd44', 'bfc7e715-18c4-50cd-8207-eb4d8bc16403', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cdeb41da-b667-5b77-bf39-95e5c403b1c6', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of researchers below.
Match each statement with the correct person,
A–D
.
Write the correct letter,
A–D
, in boxes
8-13
on your answer sheet.
NB
You may use some letters more than once.
This researcher …
8
identified a key factor that is necessary for willpower to function.
9
suggested that willpower is affected by our beliefs.
10
examined how our body responds to the use of willpower.
11
discovered how important it is to make and track goals.
12
found that taking actions to please others decreases our willpower.
13
found that willpower can increase through simple positive thoughts.
List of People
A
Matthew Gailliot
B
Gregory M. Walton
C
Mark Muraven
D
Veronika Job
E
Roy Baumeister

11 ____ discovered how important it is to make and track goals.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2d6192d-8ac3-5558-875a-87a3925294c7', 'cdeb41da-b667-5b77-bf39-95e5c403b1c6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fad7ed2a-c0df-562b-a137-2dafbeac8452', 'cdeb41da-b667-5b77-bf39-95e5c403b1c6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e20d4fe7-9cf9-54cb-8b57-918bede950ad', 'cdeb41da-b667-5b77-bf39-95e5c403b1c6', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c45347b-159d-54c1-acae-e808b75fd344', 'cdeb41da-b667-5b77-bf39-95e5c403b1c6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed96694e-cb54-51dc-80e8-30b1a3450a5f', 'cdeb41da-b667-5b77-bf39-95e5c403b1c6', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cc75a7cb-1396-5a82-94ca-03d76d8ac338', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of researchers below.
Match each statement with the correct person,
A–D
.
Write the correct letter,
A–D
, in boxes
8-13
on your answer sheet.
NB
You may use some letters more than once.
This researcher …
8
identified a key factor that is necessary for willpower to function.
9
suggested that willpower is affected by our beliefs.
10
examined how our body responds to the use of willpower.
11
discovered how important it is to make and track goals.
12
found that taking actions to please others decreases our willpower.
13
found that willpower can increase through simple positive thoughts.
List of People
A
Matthew Gailliot
B
Gregory M. Walton
C
Mark Muraven
D
Veronika Job
E
Roy Baumeister

12 ____ found that taking actions to please others decreases our willpower.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dabeb0fe-c706-5f31-b579-f490a97263bd', 'cc75a7cb-1396-5a82-94ca-03d76d8ac338', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d071222e-6f6a-5d8e-bc05-7a7965ec7055', 'cc75a7cb-1396-5a82-94ca-03d76d8ac338', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0a59bbc-d821-5dab-9ad7-30549abc246b', 'cc75a7cb-1396-5a82-94ca-03d76d8ac338', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fc6342c-973c-5d0d-9638-a93521a6cbee', 'cc75a7cb-1396-5a82-94ca-03d76d8ac338', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48e2cb31-5dc3-5c93-b405-58d352217dbe', 'cc75a7cb-1396-5a82-94ca-03d76d8ac338', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('51005a23-59a6-5223-bcea-2095d0c6300b', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Look at the following statements (Questions 8-13) and the list of researchers below.
Match each statement with the correct person,
A–D
.
Write the correct letter,
A–D
, in boxes
8-13
on your answer sheet.
NB
You may use some letters more than once.
This researcher …
8
identified a key factor that is necessary for willpower to function.
9
suggested that willpower is affected by our beliefs.
10
examined how our body responds to the use of willpower.
11
discovered how important it is to make and track goals.
12
found that taking actions to please others decreases our willpower.
13
found that willpower can increase through simple positive thoughts.
List of People
A
Matthew Gailliot
B
Gregory M. Walton
C
Mark Muraven
D
Veronika Job
E
Roy Baumeister

13 ____ found that willpower can increase through simple positive thoughts.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e67a244c-312d-5bbf-af58-9e1ab5e0b038', '51005a23-59a6-5223-bcea-2095d0c6300b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('924d2dd7-c5ad-598a-ac4c-3da5151474f3', '51005a23-59a6-5223-bcea-2095d0c6300b', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1692f77-f855-5510-a2c8-3de60cf67230', '51005a23-59a6-5223-bcea-2095d0c6300b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af959649-6a3b-50e4-a90a-58309e4c2a04', '51005a23-59a6-5223-bcea-2095d0c6300b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8da6eb63-5d97-5c8e-881e-317d3e2b7c8b', '51005a23-59a6-5223-bcea-2095d0c6300b', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('640a057a-b305-5c0f-82ed-78d08568f4de', 'd31e9e6f-bea9-518c-b845-ba0b212e361b', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Question 14
Question 14
Which of the following is
NOT
mentioned as a factor in willpower?
Willpower is affected by:
A
physical factors such as tiredness
B
our fundamental ability to delay pleasure
C
the levels of certain chemicals in our brains
D
environmental cues such as the availability of a trigger

Which of the following is NOT mentioned as a factor in willpower?$md$, NULL);

COMMIT;
