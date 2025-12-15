BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-computer-games-for-preschoolers-nintendos-research-and-design-process-1192'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-computer-games-for-preschoolers-nintendos-research-and-design-process-1192';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-computer-games-for-preschoolers-nintendos-research-and-design-process-1192';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-computer-games-for-preschoolers-nintendos-research-and-design-process-1192';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('cefd8048-1f83-5fbc-9baf-14ad046a7037', 'ielts-reading-computer-games-for-preschoolers-nintendos-research-and-design-process-1192', $t$Computer Games for Preschoolers: Nintendo’s Research and Design Process$t$, $md$## Computer Games for Preschoolers: Nintendo’s Research and Design Process

Nguồn:
- Test: https://mini-ielts.com/1192/reading/computer-games-for-preschoolers-nintendos-research-and-design-process
- Solution: https://mini-ielts.com/1192/view-solution/reading/computer-games-for-preschoolers-nintendos-research-and-design-process$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('621794a2-ef73-5836-9763-3a6b2d3ca6f5', 'cefd8048-1f83-5fbc-9baf-14ad046a7037', 1, $t$Reading — Computer Games for Preschoolers: Nintendo’s Research and Design Process$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Computer Games for Preschoolers: Nintendo’s Research and Design Process

Designing computer games for young children is a daunting task for game producers, who, for a long time, have concentrated on more “hard core” game fans. This article chronicles the design process and research involved in creating Nintendo DS for preschool gamers.

After speaking with our producers who have a keen interest in designing for the DS, we finally agreed on three key goals for our project. First, to understand the range of physical and cognitive abilities of preschoolers in the context of handheld system game play; second, to understand how preschool gamers interact with the DS, specifically how they control the different forms of play and game mechanics offered by the games presently on the market for this platform; third, to understand the expectation of preschooler’s parents concerning the handheld systems as well as the purchase and play contexts within which game play occurs. The team of research decided that in-home ethnographies with preschoolers and their families would yield comprehensive database with which to give our producers more information and insights, so we start by conducting 26 in-home ethnographies in three markets across the United States: an East coast urban/suburban area, a West coast urban/suburban area, and a Midwest suburban/rural area.

The subject is this study included 15 girls and 11 boys ranging from 3 years and 3 months old to 5 years and 11 months old. Also, because previous research had shown the effects of older siblings on game play (demonstrated, for example, by more advanced motor coordination when using a computer mouse), households were employed to have a combination of preschoolers with and without elder peers. In order to understand both “experienced” and “new” preschool users of the platform, we divided the sample so that 13 families owned at least one Nintendo DS and the others did not. For those households that did not own a DS, one was brought to the interview for the kid to play. This allowed us to see both the instinctive and intuitive movements of the new players (and of the more experienced players when playing new games), as well as the learned movements of the more experienced players. Each of those interviews took about 60 to 120 minutes and included the preschooler, at least one parent, and often siblings and another caregiver.

Three kinds of information were collected after each interview. From any older siblings and the parents that were available, we gathered data about: the buying decisions surrounding game systems in the household, the family’s typical game play patterns, levels of parental moderation with regard to computer gaming, and the most favorite games play by family members. We could also understand the ideology of gaming in these homes because of these in-home interviews: what types of spaces were used for game play, how the system were installed, where the handheld play occurred in the house (as well as on-the-go play), and the number and type of games and game systems owned. The most important is, we gathered the game-playing information for every single kid.

Before carrying out the interviews, the research team had closely discussed with the in-house game producers to create a list of game mechanics and problems tied to preschoolers’ motor and cognitive capabilities that were critical for them to understand prior to writing the games. These ranged from general dexterity issues related to game controllers to the effectiveness of in-game instructions to specific mechanics in current games that the producers were interested in implementing for future preschool titles. During the interviews, the moderator gave specific guidance to the preschooler through a series of games, so that he or she could observe the interaction and probe both the preschooler and his or her parents on feelings, attitudes, and frustrations that arose in the different circumstances.

If the subject in the experiment had previous exposure to the DS system, he or she was first asked to play his or her favorite game on the machine. This gave the researchers information about current level of gaming skill related to the complexity of the chosen one, allowing them to see the child playing a game with mechanics he or she was already familiar with. Across the 26 preschoolers, the Nintendo DS selections scope were very broad, including New Super Mario Bros, Sonic Rush, Nintendogs, and Tony Hawk’s Proving Ground. The interview observed the child play, noting preferences for game mechanic and motor interactions with device as well as the complexity level each game mechanic was for the tested subject. The researchers asked all of the preschoolers to play with a specific game in consultation with our producers, The Little Mermaid: Ariel’s Undersea Adventure. The game was chosen for two major reasons. First, it was one of the few games on the market with characters that appeal to this young age group. Second, it incorporated a large variety of mechanics that highlighted the uniqueness of the DS platform, including using the microphone for blowing or singing.

The findings from this initial experiment were extensive. After reviewing the outcomes and discussing the implications for the game design with our internal game production team, we then outlined the designing needs and presented the findings to a firm specializing in game design. We worked closely with those experts to set the game design for the two preschool-targeted DS games under development on what we had gathered.

As the two DS games went into the development process, a formative research course of action was set up. Whenever we developed new game mechanics, we brought preschoolers into our in-house utility lab to test the mechanics and to evaluate both their simplicity, and whether they were engaging. We tested either alpha or beta versions of different elements of the game, in addition to looking at overarching game structure. Once a full version of the DS game was ready, we went back into the field test with a dozen preschoolers and their parents to make sure that each of the game elements worked for the children, and that the overall objective of the game was understandable and the process was enjoyable for players. We also collected parent’s feedback on whether they thought the game is appropriate, engaging, and worth the purchase.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('de551ba3-0423-54d4-8c40-51c4fb3e5080', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 1, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
Exploratory Research Project
Main Objectives:
Determine the relevant
1
in the context
Observe how preschoolers manage playing
Investigate attitudes of
2
towards games
Subjects:
26 children from different US
3
Age range: 3 years and 3 months to 5 years and 11 months
Some children have older
4
Equal number of new and
5
players
Some households have Nintendo DS and some don’t
Length of Interview:
1-2 hours

1 ____$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7fc9e0f1-1f9b-5c32-b567-cfc3bae193a8', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 2, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
Exploratory Research Project
Main Objectives:
Determine the relevant
1
in the context
Observe how preschoolers manage playing
Investigate attitudes of
2
towards games
Subjects:
26 children from different US
3
Age range: 3 years and 3 months to 5 years and 11 months
Some children have older
4
Equal number of new and
5
players
Some households have Nintendo DS and some don’t
Length of Interview:
1-2 hours

2 ____$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c8fd0980-461d-597d-96f4-1455b6080feb', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 3, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
Exploratory Research Project
Main Objectives:
Determine the relevant
1
in the context
Observe how preschoolers manage playing
Investigate attitudes of
2
towards games
Subjects:
26 children from different US
3
Age range: 3 years and 3 months to 5 years and 11 months
Some children have older
4
Equal number of new and
5
players
Some households have Nintendo DS and some don’t
Length of Interview:
1-2 hours

3 ____$md$, NULL, ARRAY['.*markets.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1c14c681-2a2f-5b08-be7a-b2fc86135bc8', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 4, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
Exploratory Research Project
Main Objectives:
Determine the relevant
1
in the context
Observe how preschoolers manage playing
Investigate attitudes of
2
towards games
Subjects:
26 children from different US
3
Age range: 3 years and 3 months to 5 years and 11 months
Some children have older
4
Equal number of new and
5
players
Some households have Nintendo DS and some don’t
Length of Interview:
1-2 hours

4 ____$md$, NULL, ARRAY['.*siblings.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b3f6932d-fc4d-5f0e-b564-465bf3c5b21b', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 5, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
Exploratory Research Project
Main Objectives:
Determine the relevant
1
in the context
Observe how preschoolers manage playing
Investigate attitudes of
2
towards games
Subjects:
26 children from different US
3
Age range: 3 years and 3 months to 5 years and 11 months
Some children have older
4
Equal number of new and
5
players
Some households have Nintendo DS and some don’t
Length of Interview:
1-2 hours

5 ____$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('88a1f1a1-b6c9-5f02-af73-45d16b4e9c28', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes
6-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if these is no information on this
6
One area of research is how far mothers and fathers controlled children’s playing after school.
7
The researchers are allowed a free access to the subject’s houses.
8
The researchers regarded
The Little Mermaid: Ariel’s Undersea Adventure
as likely appeal to preschoolers.
9
The Little Mermaid: Ariel’s Undersea Adventure
is operated entirely by hand controls.

6 ____ One area of research is how far mothers and fathers controlled children’s playing after school.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('690276e6-5195-522b-b658-48571c42bd1d', '88a1f1a1-b6c9-5f02-af73-45d16b4e9c28', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('636291f7-b3a0-5873-94c3-d2730c565c57', '88a1f1a1-b6c9-5f02-af73-45d16b4e9c28', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7594a13-40bd-5f43-a940-38ab174ce917', '88a1f1a1-b6c9-5f02-af73-45d16b4e9c28', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('57dd28fa-9e0f-5f06-8025-3026e7539ab4', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes
6-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if these is no information on this
6
One area of research is how far mothers and fathers controlled children’s playing after school.
7
The researchers are allowed a free access to the subject’s houses.
8
The researchers regarded
The Little Mermaid: Ariel’s Undersea Adventure
as likely appeal to preschoolers.
9
The Little Mermaid: Ariel’s Undersea Adventure
is operated entirely by hand controls.

7 ____ The researchers are allowed a free access to the subject’s houses.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('171ac848-5354-591c-9701-74af5242a3a7', '57dd28fa-9e0f-5f06-8025-3026e7539ab4', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d4cb08a-7a1c-5715-8562-30c512118bf1', '57dd28fa-9e0f-5f06-8025-3026e7539ab4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b726a05-0978-5855-8f87-0546fbc1b5ec', '57dd28fa-9e0f-5f06-8025-3026e7539ab4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f675fcaa-61ad-54f0-a8b6-e4649315a72c', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes
6-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if these is no information on this
6
One area of research is how far mothers and fathers controlled children’s playing after school.
7
The researchers are allowed a free access to the subject’s houses.
8
The researchers regarded
The Little Mermaid: Ariel’s Undersea Adventure
as likely appeal to preschoolers.
9
The Little Mermaid: Ariel’s Undersea Adventure
is operated entirely by hand controls.

8 ____ The researchers regarded The Little Mermaid: Ariel’s Undersea Adventure as likely appeal to preschoolers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9fefd79-7cfa-53ba-96a5-ce5554ee1878', 'f675fcaa-61ad-54f0-a8b6-e4649315a72c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98983328-e14d-5420-8f9e-d2af79cc4652', 'f675fcaa-61ad-54f0-a8b6-e4649315a72c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff600c4d-f97a-5905-8b1c-35b52a98997d', 'f675fcaa-61ad-54f0-a8b6-e4649315a72c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c15602a3-c1bb-5ec8-b2cb-274b4f4b73c3', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in Reading Passage?
In boxes
6-9
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if these is no information on this
6
One area of research is how far mothers and fathers controlled children’s playing after school.
7
The researchers are allowed a free access to the subject’s houses.
8
The researchers regarded
The Little Mermaid: Ariel’s Undersea Adventure
as likely appeal to preschoolers.
9
The Little Mermaid: Ariel’s Undersea Adventure
is operated entirely by hand controls.

9 ____ The Little Mermaid: Ariel’s Undersea Adventure is operated entirely by hand controls.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('791915cc-be4d-5bd4-8d47-e5eab598b774', 'c15602a3-c1bb-5ec8-b2cb-274b4f4b73c3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2536628f-0702-52c1-9dd3-71370f8355b4', 'c15602a3-c1bb-5ec8-b2cb-274b4f4b73c3', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad02988e-b58c-5690-8f15-05aabbe51334', 'c15602a3-c1bb-5ec8-b2cb-274b4f4b73c3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b7d536e4-2f73-50c1-aa1a-3627f0e3a5bd', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the flow-chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answer in boxes
10-13
on your answer sheet.
Using the results of the study
↓
Presentation of design requirements to a specialist
10
↓
Testing the mechanics of two new games in the Nintendo lab (assess
11
and interest)
↓
A
12
of the games trailed be twelve children
↓
Collection of
13
from parents

Presentation of design requirements to a specialist 10 ____$md$, NULL, ARRAY['.*firm.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a16dd023-2892-5006-bd30-75768871e9d6', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the flow-chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answer in boxes
10-13
on your answer sheet.
Using the results of the study
↓
Presentation of design requirements to a specialist
10
↓
Testing the mechanics of two new games in the Nintendo lab (assess
11
and interest)
↓
A
12
of the games trailed be twelve children
↓
Collection of
13
from parents

Testing the mechanics of two new games in the Nintendo lab (assess 11 ____ and interest)$md$, NULL, ARRAY['.*simplicity.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('211a69b5-bcf7-5476-b126-8545284b08fb', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the flow-chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answer in boxes
10-13
on your answer sheet.
Using the results of the study
↓
Presentation of design requirements to a specialist
10
↓
Testing the mechanics of two new games in the Nintendo lab (assess
11
and interest)
↓
A
12
of the games trailed be twelve children
↓
Collection of
13
from parents

A 12 ____ of the games trailed be twelve children$md$, NULL, ARRAY['.*full.*version.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7e2bbca9-c557-5a11-8b89-04fa2652f445', '621794a2-ef73-5836-9763-3a6b2d3ca6f5', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the flow-chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answer in boxes
10-13
on your answer sheet.
Using the results of the study
↓
Presentation of design requirements to a specialist
10
↓
Testing the mechanics of two new games in the Nintendo lab (assess
11
and interest)
↓
A
12
of the games trailed be twelve children
↓
Collection of
13
from parents

Collection of 13 ____ from parents$md$, NULL, ARRAY['.*feedback.*']);

COMMIT;
