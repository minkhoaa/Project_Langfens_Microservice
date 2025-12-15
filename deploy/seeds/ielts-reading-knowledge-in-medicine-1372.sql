BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-knowledge-in-medicine-1372'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-knowledge-in-medicine-1372';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-knowledge-in-medicine-1372';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-knowledge-in-medicine-1372';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('e1e16eaa-90f7-5dfe-8515-f8935363afe8', 'ielts-reading-knowledge-in-medicine-1372', $t$Knowledge in medicine$t$, $md$## Knowledge in medicine

Nguồn:
- Test: https://mini-ielts.com/1372/reading/knowledge-in-medicine
- Solution: https://mini-ielts.com/1372/view-solution/reading/knowledge-in-medicine$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('381ddd60-484f-5052-a68c-40b6809a4a78', 'e1e16eaa-90f7-5dfe-8515-f8935363afe8', 1, $t$Reading — Knowledge in medicine$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Knowledge in medicine

A

What counts as knowledge? What do we mean when we say that we know something? What is the status of different kinds of knowledge? In order to explore these questions, we are going to focus on one particular area of knowledge – medicine.

B

How do you know when you are ill? This may seem to be an absurd question. You know you are ill because you feel ill; your body tells you that you are ill. You may know that you feel pain or discomfort but knowing you are ill is a bit more complex. At times, people experience the symptoms of illness, but in fact, they are simply tired or over-worked or they may just have a hangover. At other times, people may be suffering from a disease and fail to be aware of the illness until it has reached a late stage in its development. So how do we know we are ill, and what counts as knowledge?

C

Think about this example. You feel unwell. You have a bad cough and always seem to be tired. Perhaps it could be stress at work, or maybe you should give up smoking. You feel worse. You visit the doctor who listens to your chest and heart, takes your temperature and blood pressure, and then finally prescribes antibiotics for your cough.

D

Things do not improve but you struggle on thinking you should pull yourself together, perhaps things will ease off at work soon. A return visit to your doctor shocks you. This time the doctor, drawing on years of training and experience, diagnoses pneumonia. This means that you will need bed rest and a considerable time off work. The scenario is transformed. Although you still have the same symptoms, you no longer think that these are caused by pressure at work. You know have proof that you are ill. This is the result of the combination of your own subjective experience and the diagnosis of someone who has the status of a medical expert. You have a medically authenticated diagnosis and it appears that you are seriously ill; you know you are ill and have the evidence upon which to base this knowledge.

E

This scenario shows many different sources of knowledge. For example, you decide to consult the doctor in the first place because you feel unwell – this is personal knowledge about your own body. However, the doctor’s expert diagnosis is based on experience and training, with sources of knowledge as diverse as other experts, laboratory reports, medical textbooks and years of experience.

F

One source of knowledge is the experience of our own bodies; the personal knowledge we have of changes that might be significant, as well as the subjective experiences are mediated by other forms of knowledge such as the words we have available to describe our experience, and the common sense of our families and friends as well as that drawn from popular culture. Over the past decade, for example, Western culture has seen a significant emphasis on stress-related illness in the media. Reference to being ‘stressed out’ has become a common response in daily exchanges in the workplace and has become part of popular common-sense knowledge. It is thus not surprising that we might seek such an explanation of physical symptoms of discomfort.

G

We might also rely on the observations of others who know us. Comments from friends and family such as ‘you do look ill’ or ‘that’s a bad cough’ might be another source of knowledge. Complementary health practices, such as holistic medicine, produce their own sets of knowledge upon which we might also draw in deciding the nature and degree of our ill health and about possible treatments.

H

Perhaps the most influential and authoritative source of knowledge is the medical knowledge provided by the general practitioner. We expect the doctor to have access to expert knowledge. This is socially sanctioned. It would not be acceptable to notify our employer that we simply felt too unwell to turn up for work or that our faith healer, astrologer, therapist or even our priest thought it was not a good idea. We need an expert medical diagnosis in order to obtain the necessary certificate if we need to be off work for more than the statutory self-certification period. The knowledge of the medical sciences is privileged in this respect in contemporary Western culture. Medical practitioners are also seen as having the required expert knowledge that permits them legally to prescribe drugs and treatment to which patients would not otherwise have access. However, there is a range of different knowledge upon which we draw when making decisions about our own state of health.

I

However, there is more than existing knowledge in this little story; new knowledge is constructed within it. Given the doctor’s medical training and background, she may hypothesize ‘is this now pneumonia?’ and then proceed to look for evidence about it. She will use observations and instruments to assess the evidence and – critically – interpret it in light of her training and experience. This results in new knowledge and new experience both for you and for the doctor. This will then be added to the doctor’s medical knowledge and may help in the future diagnosis of pneumonia.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b29e8e7d-50ea-560f-8a29-b3c5e1d98574', '381ddd60-484f-5052-a68c-40b6809a4a78', 1, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Complete the table
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-6
on your answer sheet
Source of knowledge
Examples
Personal experience
Symptoms of a
1
and tiredness
Doctor’s measurement by taking
2
and temperature
Common judgment from
3
around you
Scientific evidence
Medical knowledge from the general
4
.
e.g. doctor’s medical
5
Examine the medical hypothesis with the previous drill and
6

Symptoms of a 1 ____ and tiredness$md$, NULL, ARRAY['.*bad.*cough.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d4b91830-9554-58fb-945d-5e1476bcc8de', '381ddd60-484f-5052-a68c-40b6809a4a78', 2, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Complete the table
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-6
on your answer sheet
Source of knowledge
Examples
Personal experience
Symptoms of a
1
and tiredness
Doctor’s measurement by taking
2
and temperature
Common judgment from
3
around you
Scientific evidence
Medical knowledge from the general
4
.
e.g. doctor’s medical
5
Examine the medical hypothesis with the previous drill and
6

Doctor’s measurement by taking 2 ____ and temperature$md$, NULL, ARRAY['.*blood.*pressure.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('81156fe9-3612-5d37-8c30-ce69ac394fd0', '381ddd60-484f-5052-a68c-40b6809a4a78', 3, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Complete the table
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-6
on your answer sheet
Source of knowledge
Examples
Personal experience
Symptoms of a
1
and tiredness
Doctor’s measurement by taking
2
and temperature
Common judgment from
3
around you
Scientific evidence
Medical knowledge from the general
4
.
e.g. doctor’s medical
5
Examine the medical hypothesis with the previous drill and
6

Common judgment from 3 ____ around you$md$, NULL, ARRAY['.*families.*and.*friends.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('203da267-5e4f-5d0c-ace7-b19fe7bd2f98', '381ddd60-484f-5052-a68c-40b6809a4a78', 4, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Complete the table
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-6
on your answer sheet
Source of knowledge
Examples
Personal experience
Symptoms of a
1
and tiredness
Doctor’s measurement by taking
2
and temperature
Common judgment from
3
around you
Scientific evidence
Medical knowledge from the general
4
.
e.g. doctor’s medical
5
Examine the medical hypothesis with the previous drill and
6

Medical knowledge from the general 4 ____ .$md$, NULL, ARRAY['.*practitioner.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f42fd674-2cde-5042-b3ac-e81b1aa5cedd', '381ddd60-484f-5052-a68c-40b6809a4a78', 5, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Complete the table
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-6
on your answer sheet
Source of knowledge
Examples
Personal experience
Symptoms of a
1
and tiredness
Doctor’s measurement by taking
2
and temperature
Common judgment from
3
around you
Scientific evidence
Medical knowledge from the general
4
.
e.g. doctor’s medical
5
Examine the medical hypothesis with the previous drill and
6

e.g. doctor’s medical 5 ____$md$, NULL, ARRAY['.*diagnosis.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('51829ca7-163b-5ae0-b22f-5248db8e57d2', '381ddd60-484f-5052-a68c-40b6809a4a78', 6, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Complete the table
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
1-6
on your answer sheet
Source of knowledge
Examples
Personal experience
Symptoms of a
1
and tiredness
Doctor’s measurement by taking
2
and temperature
Common judgment from
3
around you
Scientific evidence
Medical knowledge from the general
4
.
e.g. doctor’s medical
5
Examine the medical hypothesis with the previous drill and
6

Examine the medical hypothesis with the previous drill and 6 ____$md$, NULL, ARRAY['.*background.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aaee1139-b569-52ac-beed-b3744b07a288', '381ddd60-484f-5052-a68c-40b6809a4a78', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 7-14
Questions 7-14
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
7-14
on your answer sheet.
7
the contrast between the nature of personal judgment and the nature of doctor’s diagnosis
8
a reference of culture about pressure
9
sick leave will not be permitted without the professional diagnosis
10
how doctors’ opinions are regarded in society
11
the illness of patients can become part of new knowledge
12
a description of knowledge drawn from non-specialized sources other than personal knowledge
13
an example of collective judgment from personal experience and professional doctor
14
a reference that some people do not realize they are ill

7 ____ the contrast between the nature of personal judgment and the nature of doctor’s diagnosis$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96476a65-e0ce-591c-98b4-99349a1426e3', 'aaee1139-b569-52ac-beed-b3744b07a288', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75c6178a-1a46-554b-b4bb-2d085823afeb', 'aaee1139-b569-52ac-beed-b3744b07a288', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d06b122e-53f6-549e-89d4-4a1b148674ff', 'aaee1139-b569-52ac-beed-b3744b07a288', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d4a0e63-7b0f-5c7c-9f83-5ef238b1415c', 'aaee1139-b569-52ac-beed-b3744b07a288', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15169041-3d8f-588f-9aa1-8df2f3b211e4', 'aaee1139-b569-52ac-beed-b3744b07a288', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddf201b6-08ba-53ff-9bbe-fc97e4a79d55', 'aaee1139-b569-52ac-beed-b3744b07a288', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2f2b29c-26ff-5e57-8f2d-1216564ab0d4', 'aaee1139-b569-52ac-beed-b3744b07a288', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9f40364-733b-5740-b99a-0ae7a7d7b706', 'aaee1139-b569-52ac-beed-b3744b07a288', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c6ebb86-191f-54f5-8e5c-587820c0beee', 'aaee1139-b569-52ac-beed-b3744b07a288', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4afe3735-f977-530d-be7c-2c711ae1f4ff', '381ddd60-484f-5052-a68c-40b6809a4a78', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 7-14
Questions 7-14
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
7-14
on your answer sheet.
7
the contrast between the nature of personal judgment and the nature of doctor’s diagnosis
8
a reference of culture about pressure
9
sick leave will not be permitted without the professional diagnosis
10
how doctors’ opinions are regarded in society
11
the illness of patients can become part of new knowledge
12
a description of knowledge drawn from non-specialized sources other than personal knowledge
13
an example of collective judgment from personal experience and professional doctor
14
a reference that some people do not realize they are ill

8 ____ a reference of culture about pressure$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08bc639d-7519-5393-a1f5-aabfe59ce9fc', '4afe3735-f977-530d-be7c-2c711ae1f4ff', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d077c4d1-1aaf-5444-a039-bdf2ea9b8005', '4afe3735-f977-530d-be7c-2c711ae1f4ff', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4755435-13ee-5fce-b1cf-b78fb1df7662', '4afe3735-f977-530d-be7c-2c711ae1f4ff', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30f14cea-5cbb-5351-89de-868729c392d6', '4afe3735-f977-530d-be7c-2c711ae1f4ff', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ec8d89b-b346-5c28-a30f-714829d36b0e', '4afe3735-f977-530d-be7c-2c711ae1f4ff', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bec1be31-d7fe-50f0-a610-9df54df2a955', '4afe3735-f977-530d-be7c-2c711ae1f4ff', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('362531c0-dfd1-531b-b349-73ddb87797da', '4afe3735-f977-530d-be7c-2c711ae1f4ff', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b503bb2-4c1a-524b-96f7-e9f26d6cbb3b', '4afe3735-f977-530d-be7c-2c711ae1f4ff', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6592ba0a-576d-5a70-a2b9-785d3683df32', '4afe3735-f977-530d-be7c-2c711ae1f4ff', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('09c361ae-7ef8-53ea-bebc-3d4ca4b88f4e', '381ddd60-484f-5052-a68c-40b6809a4a78', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 7-14
Questions 7-14
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
7-14
on your answer sheet.
7
the contrast between the nature of personal judgment and the nature of doctor’s diagnosis
8
a reference of culture about pressure
9
sick leave will not be permitted without the professional diagnosis
10
how doctors’ opinions are regarded in society
11
the illness of patients can become part of new knowledge
12
a description of knowledge drawn from non-specialized sources other than personal knowledge
13
an example of collective judgment from personal experience and professional doctor
14
a reference that some people do not realize they are ill

9 ____ sick leave will not be permitted without the professional diagnosis$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6b092f5-202f-5515-8001-d5f1a9b3c0e2', '09c361ae-7ef8-53ea-bebc-3d4ca4b88f4e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa502faf-7764-51ed-8830-655849134cf4', '09c361ae-7ef8-53ea-bebc-3d4ca4b88f4e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14ebe9ca-3490-5134-9d31-5703b36c6d02', '09c361ae-7ef8-53ea-bebc-3d4ca4b88f4e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4547b81-f8ef-51d8-96cb-b2d6de8afb8b', '09c361ae-7ef8-53ea-bebc-3d4ca4b88f4e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb2cf96c-5008-5daa-b4db-1343d621a4d1', '09c361ae-7ef8-53ea-bebc-3d4ca4b88f4e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('356b3084-d895-593e-96e5-a6518b26efb0', '09c361ae-7ef8-53ea-bebc-3d4ca4b88f4e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74933935-961a-5005-a51b-340d267481ad', '09c361ae-7ef8-53ea-bebc-3d4ca4b88f4e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6c8baf5-4421-5a4e-a2cf-23d27b96e33e', '09c361ae-7ef8-53ea-bebc-3d4ca4b88f4e', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('052c97ed-55ad-50fd-a027-1f9d649e6832', '09c361ae-7ef8-53ea-bebc-3d4ca4b88f4e', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3311a62b-0c31-5359-9a0f-bc269b4340d1', '381ddd60-484f-5052-a68c-40b6809a4a78', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Questions 7-14
Questions 7-14
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
7-14
on your answer sheet.
7
the contrast between the nature of personal judgment and the nature of doctor’s diagnosis
8
a reference of culture about pressure
9
sick leave will not be permitted without the professional diagnosis
10
how doctors’ opinions are regarded in society
11
the illness of patients can become part of new knowledge
12
a description of knowledge drawn from non-specialized sources other than personal knowledge
13
an example of collective judgment from personal experience and professional doctor
14
a reference that some people do not realize they are ill

10 ____ how doctors’ opinions are regarded in society$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b36ef0e3-8ad2-54b1-8c77-89c9bbcce693', '3311a62b-0c31-5359-9a0f-bc269b4340d1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5183ff2-42b7-5c99-b204-0f8b3ea4cd31', '3311a62b-0c31-5359-9a0f-bc269b4340d1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cdbae0d-c717-5cdc-8243-6ea271f9ffaf', '3311a62b-0c31-5359-9a0f-bc269b4340d1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e01c0f32-d499-5656-b9cd-2633b877f355', '3311a62b-0c31-5359-9a0f-bc269b4340d1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a94e49fd-c021-5a01-bb24-668745a3f420', '3311a62b-0c31-5359-9a0f-bc269b4340d1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42393cb6-7924-5878-933b-dbdd2fd26fa9', '3311a62b-0c31-5359-9a0f-bc269b4340d1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('781d7417-88d4-5382-b739-1b966cc07e00', '3311a62b-0c31-5359-9a0f-bc269b4340d1', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b8e6115-f313-5cad-8b7b-855d684148bd', '3311a62b-0c31-5359-9a0f-bc269b4340d1', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76b55b7a-819c-53b6-85e2-71f89684db06', '3311a62b-0c31-5359-9a0f-bc269b4340d1', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2342d4b4-ae8b-576c-81e8-0d33c2379c14', '381ddd60-484f-5052-a68c-40b6809a4a78', 11, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 11

Questions 7-14
Questions 7-14
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
7-14
on your answer sheet.
7
the contrast between the nature of personal judgment and the nature of doctor’s diagnosis
8
a reference of culture about pressure
9
sick leave will not be permitted without the professional diagnosis
10
how doctors’ opinions are regarded in society
11
the illness of patients can become part of new knowledge
12
a description of knowledge drawn from non-specialized sources other than personal knowledge
13
an example of collective judgment from personal experience and professional doctor
14
a reference that some people do not realize they are ill

11 ____ the illness of patients can become part of new knowledge$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a19d1f2a-ef06-5f2a-9a65-392b1a9406f6', '2342d4b4-ae8b-576c-81e8-0d33c2379c14', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2981038-9f49-523a-b793-b410c6a98033', '2342d4b4-ae8b-576c-81e8-0d33c2379c14', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d698e009-be02-5ea3-a59e-779733f39587', '2342d4b4-ae8b-576c-81e8-0d33c2379c14', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84bde20a-88f9-5f23-8294-b2d4995f3b34', '2342d4b4-ae8b-576c-81e8-0d33c2379c14', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b742ead-1bc9-5a8d-bc10-73228264757c', '2342d4b4-ae8b-576c-81e8-0d33c2379c14', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d8e33dd-d971-5919-accc-d1aa67666b90', '2342d4b4-ae8b-576c-81e8-0d33c2379c14', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c8af7dc-1b3d-5370-bfdc-f419b131bc6d', '2342d4b4-ae8b-576c-81e8-0d33c2379c14', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a4f5eb3-f0c9-54cd-af08-4e3a0b9fc695', '2342d4b4-ae8b-576c-81e8-0d33c2379c14', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27074f8d-783a-5602-8c89-3b7e75ee42ac', '2342d4b4-ae8b-576c-81e8-0d33c2379c14', 9, $md$I$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a0a3a84a-995b-5662-bc14-ce2482e72f4e', '381ddd60-484f-5052-a68c-40b6809a4a78', 12, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 12

Questions 7-14
Questions 7-14
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
7-14
on your answer sheet.
7
the contrast between the nature of personal judgment and the nature of doctor’s diagnosis
8
a reference of culture about pressure
9
sick leave will not be permitted without the professional diagnosis
10
how doctors’ opinions are regarded in society
11
the illness of patients can become part of new knowledge
12
a description of knowledge drawn from non-specialized sources other than personal knowledge
13
an example of collective judgment from personal experience and professional doctor
14
a reference that some people do not realize they are ill

12 ____ a description of knowledge drawn from non-specialized sources other than personal knowledge$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6370614-973b-5c3f-a412-75f3c22bb9be', 'a0a3a84a-995b-5662-bc14-ce2482e72f4e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04bce6f6-0dfa-55e0-b7e3-1386211eda88', 'a0a3a84a-995b-5662-bc14-ce2482e72f4e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93d98a96-09bd-5597-9973-dc621a6faefa', 'a0a3a84a-995b-5662-bc14-ce2482e72f4e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('243a90b6-b84c-56e7-b5c5-924e6e51f767', 'a0a3a84a-995b-5662-bc14-ce2482e72f4e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88e82c65-81a4-5307-a2c3-e9234f054ca2', 'a0a3a84a-995b-5662-bc14-ce2482e72f4e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91297b9c-e6d8-545f-9f24-9d03938192c8', 'a0a3a84a-995b-5662-bc14-ce2482e72f4e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d254033-b527-5bbf-ab21-666648ecdbfb', 'a0a3a84a-995b-5662-bc14-ce2482e72f4e', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('245be025-ae9c-5c01-a36d-66dbd6bf8a15', 'a0a3a84a-995b-5662-bc14-ce2482e72f4e', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ead6da6-e547-5667-bace-cad8a213ea57', 'a0a3a84a-995b-5662-bc14-ce2482e72f4e', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('41ede90e-e0fc-548a-8684-b5a14e809ea0', '381ddd60-484f-5052-a68c-40b6809a4a78', 13, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 13

Questions 7-14
Questions 7-14
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
7-14
on your answer sheet.
7
the contrast between the nature of personal judgment and the nature of doctor’s diagnosis
8
a reference of culture about pressure
9
sick leave will not be permitted without the professional diagnosis
10
how doctors’ opinions are regarded in society
11
the illness of patients can become part of new knowledge
12
a description of knowledge drawn from non-specialized sources other than personal knowledge
13
an example of collective judgment from personal experience and professional doctor
14
a reference that some people do not realize they are ill

13 ____ an example of collective judgment from personal experience and professional doctor$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8aae598-ae5c-59c8-bcd6-801ed263295b', '41ede90e-e0fc-548a-8684-b5a14e809ea0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d31983c-22e1-57ff-907a-2716bac7592c', '41ede90e-e0fc-548a-8684-b5a14e809ea0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96adee73-f8e1-517d-9feb-f2dd00eb68dc', '41ede90e-e0fc-548a-8684-b5a14e809ea0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c433de0-9ac3-525e-90ec-43f7368ff5a9', '41ede90e-e0fc-548a-8684-b5a14e809ea0', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c28bf6d-e6c4-5259-aff1-1126c3b2bbc9', '41ede90e-e0fc-548a-8684-b5a14e809ea0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d524880-e22e-5402-9b36-d158f41b0bf8', '41ede90e-e0fc-548a-8684-b5a14e809ea0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d95d4f8e-7f28-5764-bfc2-d3db9baa72f2', '41ede90e-e0fc-548a-8684-b5a14e809ea0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03d82716-040e-5ee2-b518-63be0f69c3c0', '41ede90e-e0fc-548a-8684-b5a14e809ea0', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fe2b821-c696-535d-9e88-4263766b64b4', '41ede90e-e0fc-548a-8684-b5a14e809ea0', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a41101e1-6e1f-543a-b9e7-8ac49096d725', '381ddd60-484f-5052-a68c-40b6809a4a78', 14, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 14

Questions 7-14
Questions 7-14
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
7-14
on your answer sheet.
7
the contrast between the nature of personal judgment and the nature of doctor’s diagnosis
8
a reference of culture about pressure
9
sick leave will not be permitted without the professional diagnosis
10
how doctors’ opinions are regarded in society
11
the illness of patients can become part of new knowledge
12
a description of knowledge drawn from non-specialized sources other than personal knowledge
13
an example of collective judgment from personal experience and professional doctor
14
a reference that some people do not realize they are ill

14 ____ a reference that some people do not realize they are ill$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5eb856a-60a1-5d00-a9f1-c8f490fe0654', 'a41101e1-6e1f-543a-b9e7-8ac49096d725', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48a06001-5596-56b6-b9f6-5afe0162cf8c', 'a41101e1-6e1f-543a-b9e7-8ac49096d725', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c01757c6-d777-5503-a3da-544b7aecfeed', 'a41101e1-6e1f-543a-b9e7-8ac49096d725', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d281340-c1a8-5cee-b133-40849ecc07d4', 'a41101e1-6e1f-543a-b9e7-8ac49096d725', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93ebaf3d-c79f-5a05-87bb-cc2c0f18e01f', 'a41101e1-6e1f-543a-b9e7-8ac49096d725', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63c10be5-e37d-51c7-919b-4bf05ce47089', 'a41101e1-6e1f-543a-b9e7-8ac49096d725', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dafbaa16-f99b-580b-8ce4-fdb212ad40d8', 'a41101e1-6e1f-543a-b9e7-8ac49096d725', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e81cc67f-1648-5917-b714-786eaac0ec4c', 'a41101e1-6e1f-543a-b9e7-8ac49096d725', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d2d0b28-eb7a-564c-8faf-8e2bdf22f18d', 'a41101e1-6e1f-543a-b9e7-8ac49096d725', 9, $md$I$md$, false);

COMMIT;
