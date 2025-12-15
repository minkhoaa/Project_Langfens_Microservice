BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading--facial-expression-1-1318'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading--facial-expression-1-1318';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading--facial-expression-1-1318';
DELETE FROM exams WHERE "Slug" = 'ielts-reading--facial-expression-1-1318';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('1386f04a-9acb-5cf6-857a-26f6ebf21f18', 'ielts-reading--facial-expression-1-1318', $t$Facial Expression 1$t$, $md$## Facial Expression 1

Nguồn:
- Test: https://mini-ielts.com/1318/reading/-facial-expression-1
- Solution: https://mini-ielts.com/1318/view-solution/reading/-facial-expression-1$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e2c1a56d-8790-5d1a-9e21-4466c24c9007', '1386f04a-9acb-5cf6-857a-26f6ebf21f18', 1, $t$Reading — Facial Expression 1$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Facial Expression 1

A

A facial expression is one or more motions or positions of the muscles in the skin. These movements convey the emotional state of the individual to observers. Facial expressions are a form of nonverbal communication. They are a primary means of conveying social information among aliens, but also occur in most other mammals and some other animal species. Facial expressions and their significance in the perceiver can, to some extent, vary between cultures with evidence from descriptions in the works of Charles Darwin.

B

Humans can adopt a facial expression to read as a voluntary action. However, because expressions are closely tied to emotion, they are more often involuntary. It can be nearly impossible to avoid expressions for certain emotions, even when it would be strongly desirable to do so; a person who is trying to avoid insulting an individual he or she finds highly unattractive might, nevertheless, show a brief expression of disgust before being able to reassume a neutral expression. Microexpressions are one example of this phenomenon. The close link between emotion and expression can also work in the order direction; it has been observed that voluntarily assuming an expression can actually cause the associated emotion.

C

Some expressions can be accurately interpreted even between members of different species – anger and extreme contentment being the primary examples. Others, however, are difficult to interpret even in familiar individuals. For instance, disgust and fear can be tough to tell apart. Because faces have only a limited range of movement, expressions rely upon fairly minuscule differences in the proportion and relative position of facial features, and reading them requires considerable sensitivity to the same. Some faces are often falsely read as expressing some emotion, even when they are neutral because their proportions naturally resemble those another face would temporarily assume when emoting.

D

Also, a person’s eyes reveal much about hos they are feeling, or what they are thinking. Blink rate can reveal how nervous or at ease a person maybe. Research by Boston College professor Joe Tecce suggests that stress levels are revealed by blink rates. He supports his data with statistics on the relation between the blink rates of presidential candidates and their success in their races. Tecce claims that the faster blinker in the presidential debates has lost every election since 1980. Though Tecce’s data is interesting, it is important to recognize that non-verbal communication is multi-channelled, and focusing on only one aspect is reckless. Nervousness can also be measured by examining each candidates’ perspiration, eye contact and stiffness.

E

As Charles Darwin noted in his book The Expression of the Emotions in Man and Animals: the young and the old of widely different races, both with man and animals, express the same state of mind by the same movements. Still, up to the mid-20th century, most anthropologists believed that facial expressions were entirely learned and could, therefore, differ among cultures. Studies conducted in the 1960s by Paul Ekman eventually supported Darwin’s belief to a large degree.

F

Ekman’s work on facial expressions had its starting point in the work of psychologist Silvan Tomkins. Ekman showed that contrary to the belief of some anthropologists including Margaret Mead, facial expressions of emotion are not culturally determined, but universal across human cultures. The South Fore people of New Guinea were chosen as subjects for one such survey. The study consisted of 189 adults and 130 children from among a very isolated population, as well as twenty-three members of the culture who lived a less isolated lifestyle as a control group. Participants were told a story that described one particular emotion; they were then shown three pictures (two for children) of facial expressions and asked to match the picture which expressed the story’s emotion.

G

While the isolated South Fore people could identify emotions with the same accuracy as the non-isolated control group, problems associated with the study include the fact that both fear and surprise were constantly misidentified. The study concluded that certain facial expressions correspond to particular emotions and can not be covered, regardless of cultural background, and regardless of whether or not the culture has been isolated or exposed to the mainstream.

H

Expressions Ekman found to be universally included those indicating anger, disgust, fear, joy, sadness, and surprise (not that none of these emotions has a definitive social component, such as shame, pride, or schadenfreude). Findings on contempt (which is social) are less clear, though there is at least some preliminary evidence that this emotion and its expression are universally recognized. This may suggest that the facial expressions are largely related to the mind and each part on the face can express specific emotion.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f93059d7-9593-57ed-8a57-96d433b3168a', 'e2c1a56d-8790-5d1a-9e21-4466c24c9007', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Summary
Complete the Summary paragraph below. In boxes
1-5
on your answer sheet, write the correct answer with
NO MORE THAN TWO WORDS
The result of Ekman’s study demonstrates that fear and surprise are persistently
1
and made a conclusion that some facial expressions have something to do with certain
2
. Which is impossible covered, despite of
3
and whether the culture has been
4
or
5
to the mainstream.

The result of Ekman’s study demonstrates that fear and surprise are persistently 1 ____ and made a conclusion that some facial expressions have something to do with certain 2 ____ . Which is impossible covered, despite of 3 ____ and whether the culture has been 4 ____ or 5 ____ to the mainstream.$md$, NULL, ARRAY['.*misidentified.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fb01558c-e4e6-50df-958c-f01ba950c190', 'e2c1a56d-8790-5d1a-9e21-4466c24c9007', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Summary
Complete the Summary paragraph below. In boxes
1-5
on your answer sheet, write the correct answer with
NO MORE THAN TWO WORDS
The result of Ekman’s study demonstrates that fear and surprise are persistently
1
and made a conclusion that some facial expressions have something to do with certain
2
. Which is impossible covered, despite of
3
and whether the culture has been
4
or
5
to the mainstream.

The result of Ekman’s study demonstrates that fear and surprise are persistently 1 ____ and made a conclusion that some facial expressions have something to do with certain 2 ____ . Which is impossible covered, despite of 3 ____ and whether the culture has been 4 ____ or 5 ____ to the mainstream.$md$, NULL, ARRAY['.*misidentified.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f199962c-c9ee-5cf0-acbf-408e3470df95', 'e2c1a56d-8790-5d1a-9e21-4466c24c9007', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Summary
Complete the Summary paragraph below. In boxes
1-5
on your answer sheet, write the correct answer with
NO MORE THAN TWO WORDS
The result of Ekman’s study demonstrates that fear and surprise are persistently
1
and made a conclusion that some facial expressions have something to do with certain
2
. Which is impossible covered, despite of
3
and whether the culture has been
4
or
5
to the mainstream.

The result of Ekman’s study demonstrates that fear and surprise are persistently 1 ____ and made a conclusion that some facial expressions have something to do with certain 2 ____ . Which is impossible covered, despite of 3 ____ and whether the culture has been 4 ____ or 5 ____ to the mainstream.$md$, NULL, ARRAY['.*misidentified.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6eddba70-491c-56b3-ac2a-c6802bdd682b', 'e2c1a56d-8790-5d1a-9e21-4466c24c9007', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Summary
Complete the Summary paragraph below. In boxes
1-5
on your answer sheet, write the correct answer with
NO MORE THAN TWO WORDS
The result of Ekman’s study demonstrates that fear and surprise are persistently
1
and made a conclusion that some facial expressions have something to do with certain
2
. Which is impossible covered, despite of
3
and whether the culture has been
4
or
5
to the mainstream.

The result of Ekman’s study demonstrates that fear and surprise are persistently 1 ____ and made a conclusion that some facial expressions have something to do with certain 2 ____ . Which is impossible covered, despite of 3 ____ and whether the culture has been 4 ____ or 5 ____ to the mainstream.$md$, NULL, ARRAY['.*misidentified.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2e77750b-a734-5120-b631-1c25a1334e35', 'e2c1a56d-8790-5d1a-9e21-4466c24c9007', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Summary
Complete the Summary paragraph below. In boxes
1-5
on your answer sheet, write the correct answer with
NO MORE THAN TWO WORDS
The result of Ekman’s study demonstrates that fear and surprise are persistently
1
and made a conclusion that some facial expressions have something to do with certain
2
. Which is impossible covered, despite of
3
and whether the culture has been
4
or
5
to the mainstream.

The result of Ekman’s study demonstrates that fear and surprise are persistently 1 ____ and made a conclusion that some facial expressions have something to do with certain 2 ____ . Which is impossible covered, despite of 3 ____ and whether the culture has been 4 ____ or 5 ____ to the mainstream.$md$, NULL, ARRAY['.*misidentified.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('50d1ef04-3af2-57e8-905c-28832e83e378', 'e2c1a56d-8790-5d1a-9e21-4466c24c9007', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 6-11
Questions 6-11
The reading Passage has seven paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
6-11
on your answer sheet.
NB
You may use any letter more than once
.
6
the difficulty identifying the actual meaning of facial expressions
7
the importance of culture on facial expressions is initially described
8
collected data for the research on the relation between blink and the success in elections
9
the features on the sociality of several facial expressions
10
an indicator to reflect one’s extent of nervousness
11
the relation between emotion and facial expressions

6 ____ the difficulty identifying the actual meaning of facial expressions$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7877aad-c245-54c6-9655-9e9ee57f3d53', '50d1ef04-3af2-57e8-905c-28832e83e378', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe1fde23-3296-574d-8ef9-e77a5447a0a3', '50d1ef04-3af2-57e8-905c-28832e83e378', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43a749df-9f24-5f63-b1fb-ae5bb38bb35c', '50d1ef04-3af2-57e8-905c-28832e83e378', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33367c97-9cd7-52d0-a479-c8f1d24e7b9d', '50d1ef04-3af2-57e8-905c-28832e83e378', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81231c3e-c71c-5b00-8563-b2eaabca8f3e', '50d1ef04-3af2-57e8-905c-28832e83e378', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5018554e-e41c-5221-b828-1f20505cca16', '50d1ef04-3af2-57e8-905c-28832e83e378', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9223d8a0-b5f5-5303-b872-3399299b4b25', '50d1ef04-3af2-57e8-905c-28832e83e378', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cad9dd68-1bc7-5051-ba52-68d81c6f2aca', '50d1ef04-3af2-57e8-905c-28832e83e378', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('45480ffc-8554-5180-b94b-8472a4f11ce2', 'e2c1a56d-8790-5d1a-9e21-4466c24c9007', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 6-11
Questions 6-11
The reading Passage has seven paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
6-11
on your answer sheet.
NB
You may use any letter more than once
.
6
the difficulty identifying the actual meaning of facial expressions
7
the importance of culture on facial expressions is initially described
8
collected data for the research on the relation between blink and the success in elections
9
the features on the sociality of several facial expressions
10
an indicator to reflect one’s extent of nervousness
11
the relation between emotion and facial expressions

7 ____ the importance of culture on facial expressions is initially described$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0da3c82-f9f1-59e9-9e2f-4917903bd6ee', '45480ffc-8554-5180-b94b-8472a4f11ce2', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf77a4e2-d6ca-5643-b7d0-b1434e1a4226', '45480ffc-8554-5180-b94b-8472a4f11ce2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9edd754-ed0c-5b37-af94-5bd7ed4ccb78', '45480ffc-8554-5180-b94b-8472a4f11ce2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2567957d-3f7b-56ce-9b6c-93c12603cc0d', '45480ffc-8554-5180-b94b-8472a4f11ce2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c424466-a608-582d-a06e-9801a1343d87', '45480ffc-8554-5180-b94b-8472a4f11ce2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19599c4f-314e-5193-8ddc-1d4668207f03', '45480ffc-8554-5180-b94b-8472a4f11ce2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00b7e8ba-4e10-5111-ad7c-29b8749026e4', '45480ffc-8554-5180-b94b-8472a4f11ce2', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('911fecc3-bcb1-5451-bc7a-400976c9a9c3', '45480ffc-8554-5180-b94b-8472a4f11ce2', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac7c895f-6d7f-559c-b880-bd14ff23ace4', 'e2c1a56d-8790-5d1a-9e21-4466c24c9007', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 6-11
Questions 6-11
The reading Passage has seven paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
6-11
on your answer sheet.
NB
You may use any letter more than once
.
6
the difficulty identifying the actual meaning of facial expressions
7
the importance of culture on facial expressions is initially described
8
collected data for the research on the relation between blink and the success in elections
9
the features on the sociality of several facial expressions
10
an indicator to reflect one’s extent of nervousness
11
the relation between emotion and facial expressions

8 ____ collected data for the research on the relation between blink and the success in elections$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dc96b46-cfd2-5be2-bc3f-bd5ed9a5e455', 'ac7c895f-6d7f-559c-b880-bd14ff23ace4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b920d6bd-f38e-582a-b653-c1985f82c80f', 'ac7c895f-6d7f-559c-b880-bd14ff23ace4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fd57511-922e-5be0-b42e-24ce81934111', 'ac7c895f-6d7f-559c-b880-bd14ff23ace4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1f3d96f-ca3a-5f4d-bdb5-105b86dfaa82', 'ac7c895f-6d7f-559c-b880-bd14ff23ace4', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ff2747a-b5d5-585b-9d4d-aaee4395be1e', 'ac7c895f-6d7f-559c-b880-bd14ff23ace4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf51af4a-31e3-5f13-b8f5-04370a9559fc', 'ac7c895f-6d7f-559c-b880-bd14ff23ace4', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03d34784-d3e0-5fdc-89d5-2f9c40345c59', 'ac7c895f-6d7f-559c-b880-bd14ff23ace4', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('507838a1-78f4-59b3-bd47-7a1099b8c49a', 'ac7c895f-6d7f-559c-b880-bd14ff23ace4', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f0a5789c-5904-558f-8d64-fbcf61257ce8', 'e2c1a56d-8790-5d1a-9e21-4466c24c9007', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 6-11
Questions 6-11
The reading Passage has seven paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
6-11
on your answer sheet.
NB
You may use any letter more than once
.
6
the difficulty identifying the actual meaning of facial expressions
7
the importance of culture on facial expressions is initially described
8
collected data for the research on the relation between blink and the success in elections
9
the features on the sociality of several facial expressions
10
an indicator to reflect one’s extent of nervousness
11
the relation between emotion and facial expressions

9 ____ the features on the sociality of several facial expressions$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85472846-c930-5812-afff-cea335fdaff2', 'f0a5789c-5904-558f-8d64-fbcf61257ce8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5007d651-4563-57a1-b128-f841e4b7d189', 'f0a5789c-5904-558f-8d64-fbcf61257ce8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1593a533-5974-570f-9dc3-d98bbeb1b076', 'f0a5789c-5904-558f-8d64-fbcf61257ce8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab7fe014-7865-552e-9800-fa584f066b9f', 'f0a5789c-5904-558f-8d64-fbcf61257ce8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4c6fff0-370e-530f-ad09-a800c2893dfd', 'f0a5789c-5904-558f-8d64-fbcf61257ce8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1be0add-2bf4-530c-8bbb-41502c38bdc2', 'f0a5789c-5904-558f-8d64-fbcf61257ce8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ea2c8f9-c16a-546a-835e-5764aca33809', 'f0a5789c-5904-558f-8d64-fbcf61257ce8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13f9ba9d-116d-5fb4-a316-aa60b972f9ed', 'f0a5789c-5904-558f-8d64-fbcf61257ce8', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af255df6-5875-5c2b-b4e8-1b472de463b0', 'e2c1a56d-8790-5d1a-9e21-4466c24c9007', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Questions 6-11
Questions 6-11
The reading Passage has seven paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
6-11
on your answer sheet.
NB
You may use any letter more than once
.
6
the difficulty identifying the actual meaning of facial expressions
7
the importance of culture on facial expressions is initially described
8
collected data for the research on the relation between blink and the success in elections
9
the features on the sociality of several facial expressions
10
an indicator to reflect one’s extent of nervousness
11
the relation between emotion and facial expressions

10 ____ an indicator to reflect one’s extent of nervousness$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea8a8c25-92db-5eef-a300-4f4f32aeecd4', 'af255df6-5875-5c2b-b4e8-1b472de463b0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fec87e8-bfb9-56ff-a73c-ee0ed6b8f9a9', 'af255df6-5875-5c2b-b4e8-1b472de463b0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3680651b-cf71-5829-a6a4-7298f9d11e10', 'af255df6-5875-5c2b-b4e8-1b472de463b0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40ba133a-4c95-5d9e-96db-43780adb7eaa', 'af255df6-5875-5c2b-b4e8-1b472de463b0', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08aa52ae-ff74-544b-a4a9-741b189c5943', 'af255df6-5875-5c2b-b4e8-1b472de463b0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('529ec693-c3f5-5826-b222-e1d68d250c9b', 'af255df6-5875-5c2b-b4e8-1b472de463b0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63f07799-8f03-5af8-b472-f3c4b923be69', 'af255df6-5875-5c2b-b4e8-1b472de463b0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd9cdbd3-049e-51ae-b143-ffa7359a1324', 'af255df6-5875-5c2b-b4e8-1b472de463b0', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9468b61a-88b6-58ce-8503-98295cafa341', 'e2c1a56d-8790-5d1a-9e21-4466c24c9007', 11, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 11

Questions 6-11
Questions 6-11
The reading Passage has seven paragraphs
A-H
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
6-11
on your answer sheet.
NB
You may use any letter more than once
.
6
the difficulty identifying the actual meaning of facial expressions
7
the importance of culture on facial expressions is initially described
8
collected data for the research on the relation between blink and the success in elections
9
the features on the sociality of several facial expressions
10
an indicator to reflect one’s extent of nervousness
11
the relation between emotion and facial expressions

11 ____ the relation between emotion and facial expressions$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e7c807f-c5a4-59c2-8605-fbd8c1b25699', '9468b61a-88b6-58ce-8503-98295cafa341', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53111d86-23c0-5c88-91d2-b1d8ef06d08c', '9468b61a-88b6-58ce-8503-98295cafa341', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1177bc50-d8e5-5772-804b-b416d424637f', '9468b61a-88b6-58ce-8503-98295cafa341', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2869fa2e-86b3-5c5e-9cc6-f04879ce1318', '9468b61a-88b6-58ce-8503-98295cafa341', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe5a85dc-fc47-53ee-aa34-cbbea51132a4', '9468b61a-88b6-58ce-8503-98295cafa341', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85c3286f-6677-53ee-bd11-9b8123a05903', '9468b61a-88b6-58ce-8503-98295cafa341', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5ea34ba-5f57-5588-9bec-55975e915ed0', '9468b61a-88b6-58ce-8503-98295cafa341', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dad47c8f-d03b-57c6-a4a5-21a2c2190841', '9468b61a-88b6-58ce-8503-98295cafa341', 8, $md$H$md$, false);

COMMIT;
