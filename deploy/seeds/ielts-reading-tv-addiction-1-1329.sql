BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-tv-addiction-1-1329'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-tv-addiction-1-1329';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-tv-addiction-1-1329';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-tv-addiction-1-1329';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4e1dbb23-6eb7-5016-a756-4f0392997ff0', 'ielts-reading-tv-addiction-1-1329', $t$TV Addiction 1$t$, $md$## TV Addiction 1

Nguồn:
- Test: https://mini-ielts.com/1329/reading/tv-addiction-1
- Solution: https://mini-ielts.com/1329/view-solution/reading/tv-addiction-1$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('280793b7-6c17-5d04-92ce-f90714c68213', '4e1dbb23-6eb7-5016-a756-4f0392997ff0', 1, $t$Reading — TV Addiction 1$t$, $md$Read the passage and answer questions **1–13**.

### Passage: TV Addiction 1

A

The amount of time people spend watching television is astonishing. On average, individuals in the industrialized world devote three hours a day to the pursuit – fully half of their leisure time, and more than on any single activity save work and sleep. At this rate, someone who lives to 75 would spend nine years in front of the tube. To some commentators, this devotion means simply that people enjoy TV and make a conscious decision to watch it. But if that is the whole story, why do so many people experience misgivings about how much they view? In Gallup polls in 1992 and 1999, two out of five adult respondents and seven out of 10 teenagers said they spent too much time watching TV. Other surveys have consistently shown that roughly 10 percent of adults calls themselves TV addicts.

B

To study people’s reactions to TV, researches have undertaken laboratory experiments in which they have monitored the brain waves (using an electroencephalograph, or EEG) to track behavior and emotion in the normal course of life, as opposed to the artificial conditions of the lab. Participants carried a beeper, and we signaled them six to eight times a day, at random, over the period of a week; whenever they heard the beep, they wrote down what they were doing and how they were feeling using a standardized scorecard.

C

As one might expect, people who were watching TV when we beeped them reported feeling relaxed and passive. The EEG studies similarly show less mental stimulation, as measured by alpha brain-wave production, during viewing than during reading. What is more surprising is that the sense of relaxation ends when the set is turned off, but the feelings of passivity and lowered alertness continue. Survey participants say they have more difficulty concentrating after viewing than before. In contrast, they rarely indicate such difficulty after reading. After playing sports or engaging in hobbies, people report improvements in mood. After watching TV, people’s moods are about the same or worse than before. That may be because of viewers’ vague learned sense that they will feel less relaxed if they stop viewing. So they tend not to turn the set-off. Viewing begets more viewing which is the same as the experience of habit-forming drugs. Thus, the irony of TV: people watch a great deal longer than they plan to, even though prolonged viewing is less rewarding. In our ESM studies the longer people sat in front of the set, the less satisfaction they said they derived from it. For some, a twinge of unease or guilt that they aren’t doing something more productive may also accompany and depreciate the enjoyment of prolonged viewing. Researchers in Japan, the U.K. and the U.S. have found that this guilt occurs much more among middle-class viewers than among less affluent ones.

D

What is it about TV that has such a hold on us? In part, the attraction seems to spring from our biological ‘orienting response.’ First described by Ivan Pavlov in 1927, the orienting response is our instinctive visual or auditory reaction to any sudden or novel stimulus. It is part of our evolutionary heritage, a built-in sensitivity to movement and potential predatory threats. In 1986 Byron Reeves of Stanford University, Esther Thorson of the University of Missouri and their colleagues began to study whether the simple formal features of television – cuts, edits, zooms, pans, sudden noises – activate the orienting response, thereby keeping attention on the screen. By watching how brain waves were affected by formal features, the researchers concluded that these stylistic tricks can indeed trigger involuntary responses and ‘derive their attentional value through the evolutionary significance of detecting movement… It is the form, not the content, of television that is unique.’

E

The natural attraction to television’s sound and the light starts very early in life. Dafna Lemish of Tel Aviv University has described babies at six to eight weeks attending to television. We have observed slightly older infants who, when lying on their backs on the floor, crane their necks around 180 degrees to catch what light through yonder window breaks. This inclination suggests how deeply rooted the orienting response is.

F

The Experience Sampling Method permitted us to look closely at most every domain of everyday life: working, eating, reading, talking to friends, playing a sport, and so on. We found that heavy viewers report feeling significantly more anxious and less happy than light viewers do in unstructured situations, such as doing nothing, daydreaming or waiting in line. The difference widens when the viewer is alone. Subsequently, Robert D. McIlwraith of the University of Manitoba extensively studies those who called themselves TV addicts on surveys. On a measure called the Short Imaginal Processes Inventory (SIPI), he found that the self-described addicts are more easily bored and distracted and have poorer attentional control than the non-addicts. The addicts said they used TV to distract themselves from unpleasant thoughts and to fill time. Other studies over the years have shown that heavy viewers are less likely to participate in community activities and sports and are more likely to be obese than moderate viewers or non-viewers.

G

More than 25 years ago psychologist Tannis M. MacBeth Williams of the University of British Columbia studied a mountain community that had no television until cable finally arrived. Over time, both adults and children in the town became less creative in problem-solving, less able to persevere at tasks, and less tolerant of unstructured time.

H

Nearly 40 years ago Gary A. Steiner of the University of Chicago collected fascinating individual accounts of families whose set had broken. In experiments, families have volunteered or been paid to stop viewing, typically for a week or a month. Some fought, verbally and physically. In a review of these could-turkey studies, Charles Winick of the City University of New York concluded: ‘The first three or four days for most persons were the worst, even in many homes where the viewing was minimal and where there were other ongoing activities. In over half of all the households, during these first few days of loss, the regular routines were disrupted, family members had difficulties in dealing with the newly available time, anxiety and aggressions were expressed…. By the second week, a move toward adaptation to the situation was common.’ Unfortunately, researchers have yet to flesh out these anecdotes; no one has systematically gathered statistics on the prevalence of these withdrawal symptoms.

I

Even though TV does seem to meet the criteria for substance dependence, not all researchers would go so far as to call TV addictive. McIlwraith said in 1988 that ‘displacement of other activities by television may be socially significant but still fall short of the clinical requirement of significant impairment.’ He argued that a new category of ‘TV addiction’ may not be necessary if heavy viewing stems from conditions such as depression and social phobia. Nevertheless, whether or not we formally diagnose someone as TV-dependent, millions of people sense that they cannot readily control the amount of television they watch.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6ed337be-5744-564b-a071-cc27241e93b5', '280793b7-6c17-5d04-92ce-f90714c68213', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Study shows that males are more likely to be addicted to TV than females.
2
Greater improvements in mood are experienced after watching TV than playing sports.
3
TV addiction works in similar ways as drugs.
4
It is reported that people’s satisfaction is in proportion to the time they spend watching TV.
5
Middle-class viewers are more likely to feel guilty about watching TV than the poor.

1 ____ Study shows that males are more likely to be addicted to TV than females.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2a26a6c-1288-5551-a812-dbea290ef178', '6ed337be-5744-564b-a071-cc27241e93b5', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2283e7dd-bafb-5a7f-aa9e-ac29a6dba66e', '6ed337be-5744-564b-a071-cc27241e93b5', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08e83eb9-481c-5ce5-b220-7c946b891aac', '6ed337be-5744-564b-a071-cc27241e93b5', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d35dbb51-a725-5665-8319-8d7e7e687d1a', '280793b7-6c17-5d04-92ce-f90714c68213', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Study shows that males are more likely to be addicted to TV than females.
2
Greater improvements in mood are experienced after watching TV than playing sports.
3
TV addiction works in similar ways as drugs.
4
It is reported that people’s satisfaction is in proportion to the time they spend watching TV.
5
Middle-class viewers are more likely to feel guilty about watching TV than the poor.

2 ____ Greater improvements in mood are experienced after watching TV than playing sports.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e2c7456-b11b-52cf-a78e-b7eb4de48dde', 'd35dbb51-a725-5665-8319-8d7e7e687d1a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a0d9cd5-b8cf-53c6-920a-bb042ee7cd68', 'd35dbb51-a725-5665-8319-8d7e7e687d1a', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fbd2148-7200-5033-8570-222b497ba338', 'd35dbb51-a725-5665-8319-8d7e7e687d1a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8138428-1db0-5447-8ac5-9b2042dad5fa', '280793b7-6c17-5d04-92ce-f90714c68213', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Study shows that males are more likely to be addicted to TV than females.
2
Greater improvements in mood are experienced after watching TV than playing sports.
3
TV addiction works in similar ways as drugs.
4
It is reported that people’s satisfaction is in proportion to the time they spend watching TV.
5
Middle-class viewers are more likely to feel guilty about watching TV than the poor.

3 ____ TV addiction works in similar ways as drugs.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91e93509-1ca9-5de6-97b7-b47306e8a8c9', 'd8138428-1db0-5447-8ac5-9b2042dad5fa', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e02ef4a6-8677-5849-bd04-da855cb365f0', 'd8138428-1db0-5447-8ac5-9b2042dad5fa', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23405536-f7d7-53f7-8609-041762e14c0e', 'd8138428-1db0-5447-8ac5-9b2042dad5fa', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0fed24bc-2a45-543f-b3a2-4af1bb726921', '280793b7-6c17-5d04-92ce-f90714c68213', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Study shows that males are more likely to be addicted to TV than females.
2
Greater improvements in mood are experienced after watching TV than playing sports.
3
TV addiction works in similar ways as drugs.
4
It is reported that people’s satisfaction is in proportion to the time they spend watching TV.
5
Middle-class viewers are more likely to feel guilty about watching TV than the poor.

4 ____ It is reported that people’s satisfaction is in proportion to the time they spend watching TV.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3df5de09-b077-59cc-9860-0526c2550b01', '0fed24bc-2a45-543f-b3a2-4af1bb726921', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42365aaa-4707-5ccf-a712-46cb4df6c5b8', '0fed24bc-2a45-543f-b3a2-4af1bb726921', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dde7078f-f7c8-54eb-9889-4bdc923febeb', '0fed24bc-2a45-543f-b3a2-4af1bb726921', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('514f453d-f242-5ef2-8381-f08aee36be3d', '280793b7-6c17-5d04-92ce-f90714c68213', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Study shows that males are more likely to be addicted to TV than females.
2
Greater improvements in mood are experienced after watching TV than playing sports.
3
TV addiction works in similar ways as drugs.
4
It is reported that people’s satisfaction is in proportion to the time they spend watching TV.
5
Middle-class viewers are more likely to feel guilty about watching TV than the poor.

5 ____ Middle-class viewers are more likely to feel guilty about watching TV than the poor.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('121d08f4-1921-5ad1-a1e0-bab0f3aa59f2', '514f453d-f242-5ef2-8381-f08aee36be3d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2731b1d3-a104-54d0-bf27-3058a2627654', '514f453d-f242-5ef2-8381-f08aee36be3d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54a13484-591d-53f8-aa6a-934cc2a1a167', '514f453d-f242-5ef2-8381-f08aee36be3d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('31162f1c-64ca-5568-ab0f-21ab47a617d9', '280793b7-6c17-5d04-92ce-f90714c68213', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Look at the following researchers (Questions 6-10) and the list of statements below.
Match each researcher with the correct statements.
Write the correct letter
A-H
in boxes 6-10
on your answer sheets.
6
Byron Reeves and Esther Thorson
7
Dafna Lemish
8
Robert D. McIlwraith
9
Tannis M. MacBeth Williams
10
Charles Winick
List of Statements
A
Audiences would get hypnotized from viewing too much television.
B
People have been sensitive to the TV signals since a younger age.
C
People are less likely to accomplish their work with television.
D
A handful of studies have attempted to study other types of media addiction.
E
The addictive power of television could probably minimize the problems.
F
Various media formal characters stimulate people’s reaction on the screen.
G
People who believe themselves to be TV addicts are less likely to join in the group activities.
H
It is hard for people to accept life without a TV at the beginning.

6 ____ Byron Reeves and Esther Thorson$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35c362ba-c904-51c8-87ba-69c6a81f53fd', '31162f1c-64ca-5568-ab0f-21ab47a617d9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcd4026a-1bf5-50b3-8d30-61e34c46ce62', '31162f1c-64ca-5568-ab0f-21ab47a617d9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0996773-8f37-5f8f-ad56-d59e78ef5eba', '31162f1c-64ca-5568-ab0f-21ab47a617d9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2150a3cc-4866-527c-9d56-dd9b79e22e49', '31162f1c-64ca-5568-ab0f-21ab47a617d9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('191a0ca7-310a-518e-9bcd-4ca18d13c1dc', '31162f1c-64ca-5568-ab0f-21ab47a617d9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21ad190b-772c-54d2-a9f6-8bcc988b8418', '31162f1c-64ca-5568-ab0f-21ab47a617d9', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('797b628e-3a36-5885-9f17-a4ea6b479231', '31162f1c-64ca-5568-ab0f-21ab47a617d9', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('100c4c09-acc2-5962-986d-b9948afda349', '31162f1c-64ca-5568-ab0f-21ab47a617d9', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac5e464d-56d8-50d4-9062-756e588f1118', '280793b7-6c17-5d04-92ce-f90714c68213', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Look at the following researchers (Questions 6-10) and the list of statements below.
Match each researcher with the correct statements.
Write the correct letter
A-H
in boxes 6-10
on your answer sheets.
6
Byron Reeves and Esther Thorson
7
Dafna Lemish
8
Robert D. McIlwraith
9
Tannis M. MacBeth Williams
10
Charles Winick
List of Statements
A
Audiences would get hypnotized from viewing too much television.
B
People have been sensitive to the TV signals since a younger age.
C
People are less likely to accomplish their work with television.
D
A handful of studies have attempted to study other types of media addiction.
E
The addictive power of television could probably minimize the problems.
F
Various media formal characters stimulate people’s reaction on the screen.
G
People who believe themselves to be TV addicts are less likely to join in the group activities.
H
It is hard for people to accept life without a TV at the beginning.

7 ____ Dafna Lemish$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4288d9e1-703e-503b-8c21-3eab440b5070', 'ac5e464d-56d8-50d4-9062-756e588f1118', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d0ee9b8-4e92-5e15-988c-ae41cc1fd729', 'ac5e464d-56d8-50d4-9062-756e588f1118', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f85620e3-c5c4-558e-bfa4-3a8069d56fa1', 'ac5e464d-56d8-50d4-9062-756e588f1118', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d401629-eaec-5f6c-ab79-4ce567da9c6d', 'ac5e464d-56d8-50d4-9062-756e588f1118', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4be07bc8-3c3e-534f-a966-8081fdcd3157', 'ac5e464d-56d8-50d4-9062-756e588f1118', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f74048d-307f-546e-9f61-f59cf1363029', 'ac5e464d-56d8-50d4-9062-756e588f1118', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0f4cca4-0e76-552a-88e9-12991a8f27af', 'ac5e464d-56d8-50d4-9062-756e588f1118', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c8e7d3a-3db2-5dcc-9be3-418e38567c7b', 'ac5e464d-56d8-50d4-9062-756e588f1118', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('995082f5-f83b-5341-a5df-de4156763f68', '280793b7-6c17-5d04-92ce-f90714c68213', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Look at the following researchers (Questions 6-10) and the list of statements below.
Match each researcher with the correct statements.
Write the correct letter
A-H
in boxes 6-10
on your answer sheets.
6
Byron Reeves and Esther Thorson
7
Dafna Lemish
8
Robert D. McIlwraith
9
Tannis M. MacBeth Williams
10
Charles Winick
List of Statements
A
Audiences would get hypnotized from viewing too much television.
B
People have been sensitive to the TV signals since a younger age.
C
People are less likely to accomplish their work with television.
D
A handful of studies have attempted to study other types of media addiction.
E
The addictive power of television could probably minimize the problems.
F
Various media formal characters stimulate people’s reaction on the screen.
G
People who believe themselves to be TV addicts are less likely to join in the group activities.
H
It is hard for people to accept life without a TV at the beginning.

8 ____ Robert D. McIlwraith$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42b2fda1-16a7-5c65-8a3c-89a4bbea27fc', '995082f5-f83b-5341-a5df-de4156763f68', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46d6e577-c36b-5950-8ade-8b4461040a3b', '995082f5-f83b-5341-a5df-de4156763f68', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eea1f262-f207-5cb8-a151-ec0e85bdd4eb', '995082f5-f83b-5341-a5df-de4156763f68', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5bf66c28-0bb6-5fa6-a568-f03002e9ffb8', '995082f5-f83b-5341-a5df-de4156763f68', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('349facde-b8ed-5abe-b1c8-bf5923d2e355', '995082f5-f83b-5341-a5df-de4156763f68', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e55e9c9-40a7-5a26-9e36-8ad40bb93bee', '995082f5-f83b-5341-a5df-de4156763f68', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('749d9d57-042e-5314-a686-601f2792bfd1', '995082f5-f83b-5341-a5df-de4156763f68', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('510e6809-a21c-5247-9a5d-3408beb592b7', '995082f5-f83b-5341-a5df-de4156763f68', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1315d0aa-537d-577b-9b2d-6c50ee669ec8', '280793b7-6c17-5d04-92ce-f90714c68213', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Look at the following researchers (Questions 6-10) and the list of statements below.
Match each researcher with the correct statements.
Write the correct letter
A-H
in boxes 6-10
on your answer sheets.
6
Byron Reeves and Esther Thorson
7
Dafna Lemish
8
Robert D. McIlwraith
9
Tannis M. MacBeth Williams
10
Charles Winick
List of Statements
A
Audiences would get hypnotized from viewing too much television.
B
People have been sensitive to the TV signals since a younger age.
C
People are less likely to accomplish their work with television.
D
A handful of studies have attempted to study other types of media addiction.
E
The addictive power of television could probably minimize the problems.
F
Various media formal characters stimulate people’s reaction on the screen.
G
People who believe themselves to be TV addicts are less likely to join in the group activities.
H
It is hard for people to accept life without a TV at the beginning.

9 ____ Tannis M. MacBeth Williams$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('367a2278-7b84-540c-a763-7ff1930706ae', '1315d0aa-537d-577b-9b2d-6c50ee669ec8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4c8e093-ad5b-5398-a72b-eb90effc52cd', '1315d0aa-537d-577b-9b2d-6c50ee669ec8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e78edfd4-ef76-5fe7-befc-c92b05249815', '1315d0aa-537d-577b-9b2d-6c50ee669ec8', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('417d43d6-1593-5c64-8ecc-483ad3b4a8e4', '1315d0aa-537d-577b-9b2d-6c50ee669ec8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd9caa57-6f6e-5236-bb09-6443aaf45033', '1315d0aa-537d-577b-9b2d-6c50ee669ec8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a43b18c6-a347-5ca2-8d18-0a56f98cbbbe', '1315d0aa-537d-577b-9b2d-6c50ee669ec8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5367617-54fe-50c0-b755-eb7e0687fcbc', '1315d0aa-537d-577b-9b2d-6c50ee669ec8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4d89007-537e-57ce-ad62-7127af2523bf', '1315d0aa-537d-577b-9b2d-6c50ee669ec8', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1ebff1e2-72c8-5ead-b55b-14c2e416fc74', '280793b7-6c17-5d04-92ce-f90714c68213', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Look at the following researchers (Questions 6-10) and the list of statements below.
Match each researcher with the correct statements.
Write the correct letter
A-H
in boxes 6-10
on your answer sheets.
6
Byron Reeves and Esther Thorson
7
Dafna Lemish
8
Robert D. McIlwraith
9
Tannis M. MacBeth Williams
10
Charles Winick
List of Statements
A
Audiences would get hypnotized from viewing too much television.
B
People have been sensitive to the TV signals since a younger age.
C
People are less likely to accomplish their work with television.
D
A handful of studies have attempted to study other types of media addiction.
E
The addictive power of television could probably minimize the problems.
F
Various media formal characters stimulate people’s reaction on the screen.
G
People who believe themselves to be TV addicts are less likely to join in the group activities.
H
It is hard for people to accept life without a TV at the beginning.

10 ____ Charles Winick$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f119068b-1662-5866-b45e-d3608716e902', '1ebff1e2-72c8-5ead-b55b-14c2e416fc74', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1273afd-bc1c-5104-97d7-c3b199beb515', '1ebff1e2-72c8-5ead-b55b-14c2e416fc74', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bb3c5a8-ba0f-55cb-a173-27c4dd812ee3', '1ebff1e2-72c8-5ead-b55b-14c2e416fc74', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b85aa53e-cdb0-5e7c-abb1-d27ad115dccd', '1ebff1e2-72c8-5ead-b55b-14c2e416fc74', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a6d1cc0-5148-50b4-acae-19ca32482986', '1ebff1e2-72c8-5ead-b55b-14c2e416fc74', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96bb7928-2268-5239-bb6d-02986416ee94', '1ebff1e2-72c8-5ead-b55b-14c2e416fc74', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc7abcb7-e5d6-5b39-af11-e0ca0d115390', '1ebff1e2-72c8-5ead-b55b-14c2e416fc74', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf0e0924-a781-5a5d-ae6e-0e58d10c08f9', '1ebff1e2-72c8-5ead-b55b-14c2e416fc74', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6049ca8c-5a55-5468-8037-dbbafd72478c', '280793b7-6c17-5d04-92ce-f90714c68213', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes
11-13
on your answer sheet.
11.
People in the industrialized world
A
devote ten hours watching TV on average
B
spend more time on TV than other entertainment
C
call themselves TV addicts.
D
enjoy working best.
12.
When compared with light viewers, heavy viewers
A
like playing sport more than reading.
B
feel relaxed after watching TV.
C
spend more time in daydreaming.
D
are more easily bored while waiting in line.
13.
Which of the following statements is true about the family experiment?
A
Not all subjects participate in the experiment for free.
B
There has been complete gathered data.
C
People are prevented from other activities during the experiment.
D
People can not adapt to the situation until the end.

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72aab714-d3f4-54c9-841b-9a896ed7fe39', '280793b7-6c17-5d04-92ce-f90714c68213', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes
11-13
on your answer sheet.
11.
People in the industrialized world
A
devote ten hours watching TV on average
B
spend more time on TV than other entertainment
C
call themselves TV addicts.
D
enjoy working best.
12.
When compared with light viewers, heavy viewers
A
like playing sport more than reading.
B
feel relaxed after watching TV.
C
spend more time in daydreaming.
D
are more easily bored while waiting in line.
13.
Which of the following statements is true about the family experiment?
A
Not all subjects participate in the experiment for free.
B
There has been complete gathered data.
C
People are prevented from other activities during the experiment.
D
People can not adapt to the situation until the end.

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1e6da934-1735-5959-8ca9-9979dfe7a487', '280793b7-6c17-5d04-92ce-f90714c68213', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in boxes
11-13
on your answer sheet.
11.
People in the industrialized world
A
devote ten hours watching TV on average
B
spend more time on TV than other entertainment
C
call themselves TV addicts.
D
enjoy working best.
12.
When compared with light viewers, heavy viewers
A
like playing sport more than reading.
B
feel relaxed after watching TV.
C
spend more time in daydreaming.
D
are more easily bored while waiting in line.
13.
Which of the following statements is true about the family experiment?
A
Not all subjects participate in the experiment for free.
B
There has been complete gathered data.
C
People are prevented from other activities during the experiment.
D
People can not adapt to the situation until the end.

Choose the correct letter A , B , C or D .$md$, NULL);

COMMIT;
