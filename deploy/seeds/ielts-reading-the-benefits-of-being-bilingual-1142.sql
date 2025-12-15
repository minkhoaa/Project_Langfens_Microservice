BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-benefits-of-being-bilingual-1142'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-benefits-of-being-bilingual-1142';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-benefits-of-being-bilingual-1142';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-benefits-of-being-bilingual-1142';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('640823d8-7e0d-5589-bea9-a7829f2fd3a7', 'ielts-reading-the-benefits-of-being-bilingual-1142', $t$The Benefits of Being Bilingual$t$, $md$## The Benefits of Being Bilingual

Nguồn:
- Test: https://mini-ielts.com/1142/reading/the-benefits-of-being-bilingual
- Solution: https://mini-ielts.com/1142/view-solution/reading/the-benefits-of-being-bilingual$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e1591bc4-b4a3-506e-9842-e674af731c3c', '640823d8-7e0d-5589-bea9-a7829f2fd3a7', 1, $t$Reading — The Benefits of Being Bilingual$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Benefits of Being Bilingual

A

According to the latest figures, the majority of the world’s population is now bilingual or multilingual, having grown up speaking two or more languages. In the past, such children were considered to be at a disadvantage compared with their monolingual peers. Over the past few decades, however, technological advances have allowed researchers to look more deeply at how bilingualism interacts with and changes the cognitive and neurological systems, thereby identifying several clear benefits of being bilingual.

B

Research shows that when a bilingual person uses one language, the other is active at the same time. When we hear a word, we don’t hear the entire word all at once: the sounds arrive in sequential order. Long before the word is finished, the brain’s language system begins to guess what that word might be. If you hear ‘can’, you will likely activate words like ‘candy’ and ‘candle’ as well, at least during the earlier stages of word recognition. For bilingual people, this activation is not limited to a single language; auditory input activates corresponding words regardless of the language to which they belong. Some of the most compelling evidence for this phenomenon, called ‘ language co-activation ’, comes from studying eye movements . A Russian-English bilingual asked to ‘pick up a marker’ from a set of objects would look more at a stamp than someone who doesn’t know Russian, because the Russian word for ‘stamp’, marka, sounds like the English word he or she heard, ‘marker’. In cases like this, language co-activation occurs because what the listener hears could map onto words in either language.

C

Having to deal with this persistent linguistic competition can result in difficulties, however. For instance, knowing more than one language can cause speakers to name pictures more slowly, and can increase ‘tip-of-the-tongue states’, when you can almost, but not quite, bring a word to mind. As a result, the constant juggling of two languages creates a need to control how much a person accesses a language at any given time. For this reason, bilingual people often perform better on tasks that require conflict management . In the classic Stroop Task , people see a word and are asked to name the colour of the word’s font. When the colour and the word match (i., the word ‘red’ printed in red), people correctly name the colour more quickly than when the colour and the word don’t match (i., the word ‘red’ printed in blue). This occurs because the word itself (‘red’) and its font colour (blue) conflict. Bilingual people often excel at tasks such as this, which tap into the ability to ignore competing perceptual information and focus on the relevant aspects of the input. Bilinguals are also better at switching between two tasks; for example, when bilinguals have to switch from categorizing objects by colour (red or green) to categorizing them by shape (circle or triangle), they do so more quickly than monolingual people, reflecting better cognitive control when having to make rapid changes of strategy.

D

It also seems that the neurological roots of the bilingual advantage extend to brain areas more traditionally associated with sensory processing. When monolingual and bilingual adolescents listen to simple speech sounds without any intervening background noise, they show highly similar brain stem responses. When researchers play the same sound to both groups in the presence of background noise, however, the bilingual listeners’ neural response is considerably larger, reflecting better encoding of the sound’s fundamental frequency, a feature of sound closely related to pitch perception.

E

Such improvements in cognitive and sensory processing may help a bilingual person to process information in the environment, and help explain why bilingual adults acquire a third language better than monolingual adults master a second language. This advantage may be rooted in the skill of focussing on information about the new language while reducing interference from the languages they already know.

F

Research also indicates that bilingual experience may help to keep the cognitive mechanisms sharp by recruiting alternate brain networks to compensate for those that become damaged during aging. Older bilinguals enjoy improved memory relative to monolingual people, which can lead to real-world health benefits. In a study of over 200 patients with Alzheimer’s disease, a degenerative brain disease, bilingual patients reported showing initial symptoms of the disease an average of five years later than monolingual patients. In a follow-up study, researchers compared the brains of bilingual and monolingual patients matched on the severity of Alzheimer’s symptoms. Surprisingly, the bilinguals’ brains had more physical signs of disease than their monolingual counterparts, even though their outward behaviour and abilities were the same. If the brain is an engine, bilingualism may help it to go farther on the same amount of fuel.

G

Furthermore, the benefits associated with bilingual experience seem to start very early. In one study, researchers taught seven-month-old babies growing up in monolingual or bilingual homes that when they heard a tinkling sound, a puppet appeared on one side of a screen. Halfway through the study, the puppet began appearing on the opposite side of the screen. In order to get a reward, the infants had to adjust the rule they’d learned; only the bilingual babies were able to successfully learn the new rule. This suggests that for very young children, as well as for older people, navigating a multilingual environment imparts advantages that transfer far beyond language.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8a09ae2c-19f9-5e9b-a95e-d04720313451', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 1, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the table below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
Test
Findings
Observing the
1
of Russian- English bilingual people when asked to select certain objects
Locate
Bilingual people engage both languages simultaneously: a mechanism known as
2
Locate
A test called the
3
, focusing on naming colours
Locate
Bilingual people are more able to handle tasks involving a skill called
4
Locate
A test involving switching between tasks
When changing strategies, bilingual people have superior
5
Locate

Observing the 1 ____ of Russian- English bilingual people when asked to select certain objects Locate$md$, NULL, ARRAY['.*eye.*movements.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b0abd118-2430-55d0-9622-4222fd76439f', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 2, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the table below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
Test
Findings
Observing the
1
of Russian- English bilingual people when asked to select certain objects
Locate
Bilingual people engage both languages simultaneously: a mechanism known as
2
Locate
A test called the
3
, focusing on naming colours
Locate
Bilingual people are more able to handle tasks involving a skill called
4
Locate
A test involving switching between tasks
When changing strategies, bilingual people have superior
5
Locate

Bilingual people engage both languages simultaneously: a mechanism known as 2 ____ Locate$md$, NULL, ARRAY['.*language.*co.*activation.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d252551c-9d37-5251-b032-45046c67ec43', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 3, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the table below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
Test
Findings
Observing the
1
of Russian- English bilingual people when asked to select certain objects
Locate
Bilingual people engage both languages simultaneously: a mechanism known as
2
Locate
A test called the
3
, focusing on naming colours
Locate
Bilingual people are more able to handle tasks involving a skill called
4
Locate
A test involving switching between tasks
When changing strategies, bilingual people have superior
5
Locate

A test called the 3 ____ , focusing on naming colours Locate$md$, NULL, ARRAY['.*stroop.*task.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e25c6627-eee7-5e68-bfa1-1846ffad7384', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 4, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the table below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
Test
Findings
Observing the
1
of Russian- English bilingual people when asked to select certain objects
Locate
Bilingual people engage both languages simultaneously: a mechanism known as
2
Locate
A test called the
3
, focusing on naming colours
Locate
Bilingual people are more able to handle tasks involving a skill called
4
Locate
A test involving switching between tasks
When changing strategies, bilingual people have superior
5
Locate

Bilingual people are more able to handle tasks involving a skill called 4 ____ Locate$md$, NULL, ARRAY['.*conflict.*management.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('81955323-0350-55a4-b269-1a7dbd1722f8', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 5, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the table below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
Test
Findings
Observing the
1
of Russian- English bilingual people when asked to select certain objects
Locate
Bilingual people engage both languages simultaneously: a mechanism known as
2
Locate
A test called the
3
, focusing on naming colours
Locate
Bilingual people are more able to handle tasks involving a skill called
4
Locate
A test involving switching between tasks
When changing strategies, bilingual people have superior
5
Locate

When changing strategies, bilingual people have superior 5 ____ Locate$md$, NULL, ARRAY['.*cognitive.*control.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2973eef7-9b95-5766-88df-9dc0b4d0099d', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
6-10
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
Attitudes towards bilingualism have changed in recent years.
7
Bilingual people are better than monolingual people at guessing correctly what words are before they are finished.
8
Bilingual people consistently name images faster than monolingual people.
9
Bilingual people’s brains process single sounds more efficiently than monolingual people in all situations.
10
Fewer bilingual people than monolingual people suffer from brain disease in old age.

6 ____ Attitudes towards bilingualism have changed in recent years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70905348-bf2b-5e81-8d72-56d94611ae10', '2973eef7-9b95-5766-88df-9dc0b4d0099d', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ace59986-496f-502c-95e5-7f94d87be44f', '2973eef7-9b95-5766-88df-9dc0b4d0099d', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d930e8df-f87e-54c3-a517-99468a814f0d', '2973eef7-9b95-5766-88df-9dc0b4d0099d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3e47453a-b2ea-53e2-a7d8-29cfa3975582', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
6-10
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
Attitudes towards bilingualism have changed in recent years.
7
Bilingual people are better than monolingual people at guessing correctly what words are before they are finished.
8
Bilingual people consistently name images faster than monolingual people.
9
Bilingual people’s brains process single sounds more efficiently than monolingual people in all situations.
10
Fewer bilingual people than monolingual people suffer from brain disease in old age.

7 ____ Bilingual people are better than monolingual people at guessing correctly what words are before they are finished.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c8221e0-9990-5762-b2d1-37be73f4b841', '3e47453a-b2ea-53e2-a7d8-29cfa3975582', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d550822-0642-52a3-bde8-7cd4823e54f9', '3e47453a-b2ea-53e2-a7d8-29cfa3975582', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e36721a8-c67e-5f67-970d-b13a14024ca6', '3e47453a-b2ea-53e2-a7d8-29cfa3975582', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('23961905-06ef-5d3c-bab6-aa5742006c85', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
6-10
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
Attitudes towards bilingualism have changed in recent years.
7
Bilingual people are better than monolingual people at guessing correctly what words are before they are finished.
8
Bilingual people consistently name images faster than monolingual people.
9
Bilingual people’s brains process single sounds more efficiently than monolingual people in all situations.
10
Fewer bilingual people than monolingual people suffer from brain disease in old age.

8 ____ Bilingual people consistently name images faster than monolingual people.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('837652e9-3dc5-5a25-b5dd-14ad2733e67b', '23961905-06ef-5d3c-bab6-aa5742006c85', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80c9c894-056c-515a-9c3c-64273db8abb6', '23961905-06ef-5d3c-bab6-aa5742006c85', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72f4ae6e-7709-5772-8fbe-275c7c041501', '23961905-06ef-5d3c-bab6-aa5742006c85', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('751d7e29-742e-5dc4-81fd-910e9f12a485', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
6-10
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
Attitudes towards bilingualism have changed in recent years.
7
Bilingual people are better than monolingual people at guessing correctly what words are before they are finished.
8
Bilingual people consistently name images faster than monolingual people.
9
Bilingual people’s brains process single sounds more efficiently than monolingual people in all situations.
10
Fewer bilingual people than monolingual people suffer from brain disease in old age.

9 ____ Bilingual people’s brains process single sounds more efficiently than monolingual people in all situations.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f081c46-3b00-5a0a-9a1c-95cf35b524d1', '751d7e29-742e-5dc4-81fd-910e9f12a485', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71d80f0e-46ee-5532-8fdc-c92195e4ebd7', '751d7e29-742e-5dc4-81fd-910e9f12a485', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc476810-d010-5ddf-bc92-4873a7c78a38', '751d7e29-742e-5dc4-81fd-910e9f12a485', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1fb5cde6-b94f-5247-a326-c272158456c9', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
6-10
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
Attitudes towards bilingualism have changed in recent years.
7
Bilingual people are better than monolingual people at guessing correctly what words are before they are finished.
8
Bilingual people consistently name images faster than monolingual people.
9
Bilingual people’s brains process single sounds more efficiently than monolingual people in all situations.
10
Fewer bilingual people than monolingual people suffer from brain disease in old age.

10 ____ Fewer bilingual people than monolingual people suffer from brain disease in old age.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('919c53bd-fee4-5baf-a4c0-07bad35fbe90', '1fb5cde6-b94f-5247-a326-c272158456c9', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64329406-f80a-5508-97c1-7c9d6c40153d', '1fb5cde6-b94f-5247-a326-c272158456c9', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f4d07a6-1b1d-5130-a2c8-ac01085ee2d3', '1fb5cde6-b94f-5247-a326-c272158456c9', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df3d04e3-eede-5972-a776-fad865be288d', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 11, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
11-14
on your answer sheet.
11
an example of how bilingual and monolingual people’s brains respond differently to a certain type of non-verbal auditory input
12
a demonstration of how a bilingual upbringing has benefits even before we learn to speak
13
a description of the process by which people identify words that they hear
14
reference to some negative consequences of being bilingual

11 ____ an example of how bilingual and monolingual people’s brains respond differently to a certain type of non-verbal auditory input$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40eed747-35a5-5974-a608-d09dfaf7a2cb', 'df3d04e3-eede-5972-a776-fad865be288d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db133241-743b-5293-83ee-8157f7dd10f7', 'df3d04e3-eede-5972-a776-fad865be288d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3615d5fd-e693-5245-bbcb-2b273ee6bf8c', 'df3d04e3-eede-5972-a776-fad865be288d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35ef1776-2422-52c5-84ff-ba37633fa3fc', 'df3d04e3-eede-5972-a776-fad865be288d', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79e1ba85-c094-5cfd-9d22-03603f60d564', 'df3d04e3-eede-5972-a776-fad865be288d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('360ef54d-6575-54f1-a943-6e227ca820f1', 'df3d04e3-eede-5972-a776-fad865be288d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa31d5a8-0164-5b5e-ba3f-71f08cec59f8', 'df3d04e3-eede-5972-a776-fad865be288d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6bc9a8d2-10c9-505d-acc4-6c0d52fd5654', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 12, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
11-14
on your answer sheet.
11
an example of how bilingual and monolingual people’s brains respond differently to a certain type of non-verbal auditory input
12
a demonstration of how a bilingual upbringing has benefits even before we learn to speak
13
a description of the process by which people identify words that they hear
14
reference to some negative consequences of being bilingual

12 ____ a demonstration of how a bilingual upbringing has benefits even before we learn to speak$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ee9dc90-7254-5fa7-a34d-6cb71ab54a49', '6bc9a8d2-10c9-505d-acc4-6c0d52fd5654', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddc128dd-150c-5eaa-b611-498939d6cc4c', '6bc9a8d2-10c9-505d-acc4-6c0d52fd5654', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a079ecaf-026b-50de-a3a8-d13822dc632c', '6bc9a8d2-10c9-505d-acc4-6c0d52fd5654', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fbb35ae-b91e-5646-8c74-9e84e9200d4a', '6bc9a8d2-10c9-505d-acc4-6c0d52fd5654', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9cb3fecc-18b9-539f-896c-9a9a4ec6fb32', '6bc9a8d2-10c9-505d-acc4-6c0d52fd5654', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('976b2464-326a-585d-a0f7-6fd3ab59d5fb', '6bc9a8d2-10c9-505d-acc4-6c0d52fd5654', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c763a868-2f6f-526a-bce9-e86c9176e9b2', '6bc9a8d2-10c9-505d-acc4-6c0d52fd5654', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1cfce35b-cfc3-5fdf-9f91-aa52ca34ea29', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 13, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
11-14
on your answer sheet.
11
an example of how bilingual and monolingual people’s brains respond differently to a certain type of non-verbal auditory input
12
a demonstration of how a bilingual upbringing has benefits even before we learn to speak
13
a description of the process by which people identify words that they hear
14
reference to some negative consequences of being bilingual

13 ____ a description of the process by which people identify words that they hear$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e924a5fe-0f20-5cfb-976d-f228cd81e5f3', '1cfce35b-cfc3-5fdf-9f91-aa52ca34ea29', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4147113f-fd34-570d-9234-bdb6c7dbeec3', '1cfce35b-cfc3-5fdf-9f91-aa52ca34ea29', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('802b2dbb-ec12-5d8a-80f4-01c9520fd058', '1cfce35b-cfc3-5fdf-9f91-aa52ca34ea29', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d8b3028-6a97-5dc1-8f60-fd656f3b39c6', '1cfce35b-cfc3-5fdf-9f91-aa52ca34ea29', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('004f3307-8280-534b-9dd7-862fab36a5e3', '1cfce35b-cfc3-5fdf-9f91-aa52ca34ea29', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2105bfbc-5853-5075-8335-77f2ab15e8f2', '1cfce35b-cfc3-5fdf-9f91-aa52ca34ea29', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4697a64f-2085-50d5-a79b-63b8797a1575', '1cfce35b-cfc3-5fdf-9f91-aa52ca34ea29', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9b6efea3-9f91-5a8e-ac98-57bf76e60e03', 'e1591bc4-b4a3-506e-9842-e674af731c3c', 14, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Reading Passage has seven paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes
11-14
on your answer sheet.
11
an example of how bilingual and monolingual people’s brains respond differently to a certain type of non-verbal auditory input
12
a demonstration of how a bilingual upbringing has benefits even before we learn to speak
13
a description of the process by which people identify words that they hear
14
reference to some negative consequences of being bilingual

14 ____ reference to some negative consequences of being bilingual$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc6bd53b-cf34-5b5b-a763-cface973098a', '9b6efea3-9f91-5a8e-ac98-57bf76e60e03', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9cca798-11fd-586d-bf9c-82f41d63a2be', '9b6efea3-9f91-5a8e-ac98-57bf76e60e03', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfaa262d-cedf-5a07-bfbb-1ac79b650568', '9b6efea3-9f91-5a8e-ac98-57bf76e60e03', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2e2d711-9ec9-521f-9b5d-fafeb3797a77', '9b6efea3-9f91-5a8e-ac98-57bf76e60e03', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16e6e798-51f7-5a51-8153-4c212d0bc272', '9b6efea3-9f91-5a8e-ac98-57bf76e60e03', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d316714b-db40-5d9c-933f-c1a4bfacc19a', '9b6efea3-9f91-5a8e-ac98-57bf76e60e03', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2de94d84-c4df-5809-b3e7-1ff8eb6fb461', '9b6efea3-9f91-5a8e-ac98-57bf76e60e03', 7, $md$G$md$, false);

COMMIT;
