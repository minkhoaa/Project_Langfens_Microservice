BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-beautiful-game-1206'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-beautiful-game-1206';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-beautiful-game-1206';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-beautiful-game-1206';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('096aad80-34d7-5dc7-b7ea-0cf63006a9d7', 'ielts-reading-the-beautiful-game-1206', $t$THE ‘BEAUTIFUL’ GAME$t$, $md$## THE ‘BEAUTIFUL’ GAME

Nguồn:
- Test: https://mini-ielts.com/1206/reading/the-beautiful-game
- Solution: https://mini-ielts.com/1206/view-solution/reading/the-beautiful-game$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e7be57d7-cb51-5f45-bd09-6b1ecec227ff', '096aad80-34d7-5dc7-b7ea-0cf63006a9d7', 1, $t$Reading — THE ‘BEAUTIFUL’ GAME$t$, $md$Read the passage and answer questions **1–9**.

### Passage: THE ‘BEAUTIFUL’ GAME

A

Every nation has a sport to represent it. In the U.S., there is baseball; in New Zealand, rugby. In the UK, football is the national sporting obsession. While many UK teams have gained international recognition, Manchester United is among those most well-known on a global scale. Yet while most people, regardless of the sporting preference or nationality, have some passing knowledge of Manchester United, fewer can claim knowledge of the origins of the team. Manchester United came into being in 1902 as a result of bankruptcy of the team formerly known as Newton Heath. Newton Heath began life as Newton Heath LYR (Lancashire and Yorkshire Railway) club and as the name suggests, the original team was comprised of railway workers. Despite turning professional in 1885 and becoming the founding member of the Football Lions in 1889, Newton Heath – nicknamed the ‘Heathens’ – was constantly troubled by financial difficulties .

B

Salvation came in the form of local brewer, John Henry Davis, who agreed to invest in the team on condition of being given some interest in running it . After consideration of the alternatives titles of Manchester Central and Manchester Celtic, the club was christened Manchester United in April 1902. United’s first manager, though officially titled Secretary, was Ernest Mangnall, who was appointed in September 1903, but it was not until the season of 1905/1906, that United experienced its first taste of success. His side reached the quarterfinals of the F.A, Cup and were runners up in the second division.

C

In 1907, United claimed the championship for the first time and won the first ever Charity Shield trophy in 1908. In the following year, United claimed the F.A. Cup trophy after beating Bristol City. Manchester United moved to its new stadium, Old Trafford, in early 1910. The move to the stadium, owned by the John Henry Davis brewery (a Manchester beer-making company), was proven to be fortunate as on the 17th of February, 1910, two days before the team’s first scheduled game, the previous stadium Banks Street was destroyed in a fire. The new stadium had a capacity for a crowd of 80,000 spectators and despite losing to their first visiting team Liverpool, Manchester United were once again league champions at the end of the first full season playing from Old Trafford.

D

The following years were to be less of a success. From 1912 to the onset of the First World War, no significant victories were achieved. During the war the football league was suspended and only regional competitions took place . 1919 saw the return of Manchester United to league football with only two of the original members in the team.

E

Although Britain has a long and proud history of football adoration, contemporary football supporters from the UK have gained a negative reputation for outbursts of violence against rival supporters, earning the label ‘football hooligan’. The football hooliganism phenomenon has attracted the attention of a number of researchers and psychologists who have offered theories relating to its causes. It is generally agreed that a combination of factors may initiate this type of anti-social behaviour and that it is unrealistic to contend that all such behaviour stems from a particular psychological make-up or belongs to a specific age or class . Experts do however believe that rampaging hooligan behaviour can instil a sense of belonging and ‘community’ in participants who feel that they can strongly identify with their group , regardless of the fact that the group’s behaviour is negative.

F

Analysts also argue that the motivations for outbursts of violence experienced in an international setting are even more complex. Whilst alcohol and xenophobia no doubt play a part they say, some psychologists hold that policing tactics, to a large degree, dictate the level of disturbance likely to occur. Evidence supports the view that confrontational policing is much more likely to escalate than calm any incidences of trouble . The media’s actions have also been criticised due to the belief by some that messages given in newspaper reporting may also exacerbate the existing problem of football hooliganism.

G

Critics say that certain headlines used by tabloid newspapers may glorify acts of violence and at least, the prolific news reports which are published in the UK about this issue cause perpetrators to receive undue attention and acknowledgement for their actions. Whilst few disagree that football hooliganism is a significant social problem, many researchers hold that sensationalist media reporting may also be creating undue panic since the problem is often presented as much more widespread than is the reality . Extreme cases of hooliganism from British fans has reduced significantly over recent years, and while it may take some considerable time for the negative reputation they have earned to subside, it is also true that a large proportion of supporters have no involvement in violence and simply share a love of the game.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('16b8b786-d3ef-521b-9f9c-f59fef869ff1', 'e7be57d7-cb51-5f45-bd09-6b1ecec227ff', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 4-7
Questions 4-7
Complete the summary with the list of words
A-K
below.
Write the correct letter
A-K
in boxes
4-7
on your answer sheet.
According to expert opinion, there is little
4
Locate
that football hooliganism occurs as a result of a number of issues and does not necessarily correlate with age, psychological profile or
5
Locate
. External triggers such as newspaper reports and antagonistic
6
Locate
can be attributed to escalation of the problem in certain situations. Some psychologists believe that such behaviour and membership of trouble-making groups can give certain individuals a sense of
7
Locate
that may otherwise be missing in their lives.
A
isolation
B
policing
C
anger
D
occupation
E
belief
F
proof
G
class
H
intelligence
I
excitement
J
unity
K
doubt

According to expert opinion, there is little 4 ____ Locate that football hooliganism occurs as a result of a number of issues and does not necessarily correlate with age, psychological profile or 5 ____ Locate . External triggers such as newspaper reports and antagonistic 6 ____ Locate can be attributed to escalation of the problem in certain situations. Some psychologists believe that such behaviour and membership of trouble-making groups can give certain individuals a sense of 7 ____ Locate that may otherwise be missing in their lives.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b583bd82-68a8-5dd4-8587-934b210421d8', '16b8b786-d3ef-521b-9f9c-f59fef869ff1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c44bf64-1585-50e7-b283-59beb02c6113', '16b8b786-d3ef-521b-9f9c-f59fef869ff1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c8a9b29-0600-58a0-8846-674fe24073d5', '16b8b786-d3ef-521b-9f9c-f59fef869ff1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd4b9a1d-3ac6-56ee-b90c-5af42da6fc27', '16b8b786-d3ef-521b-9f9c-f59fef869ff1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5770a2eb-fb01-577d-ab60-81c9edda9185', '16b8b786-d3ef-521b-9f9c-f59fef869ff1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54a00f84-eb4c-50e4-8288-2ae61f89d776', '16b8b786-d3ef-521b-9f9c-f59fef869ff1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea354ed2-9d88-56ff-bbfd-e87558104de5', '16b8b786-d3ef-521b-9f9c-f59fef869ff1', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3abd0ae0-6085-5c5a-a07d-1c8b5484ff5b', '16b8b786-d3ef-521b-9f9c-f59fef869ff1', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7272bcb2-d5ac-5b0f-af7c-91dbf33c8b6c', '16b8b786-d3ef-521b-9f9c-f59fef869ff1', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e560248-73ab-5634-bac0-9ee39b719193', '16b8b786-d3ef-521b-9f9c-f59fef869ff1', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e431bd6a-30e8-592b-b96c-696303e6f8b7', '16b8b786-d3ef-521b-9f9c-f59fef869ff1', 11, $md$K$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('255c2c32-2bbb-5c8c-8d04-726255192bb5', 'e7be57d7-cb51-5f45-bd09-6b1ecec227ff', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 4-7
Questions 4-7
Complete the summary with the list of words
A-K
below.
Write the correct letter
A-K
in boxes
4-7
on your answer sheet.
According to expert opinion, there is little
4
Locate
that football hooliganism occurs as a result of a number of issues and does not necessarily correlate with age, psychological profile or
5
Locate
. External triggers such as newspaper reports and antagonistic
6
Locate
can be attributed to escalation of the problem in certain situations. Some psychologists believe that such behaviour and membership of trouble-making groups can give certain individuals a sense of
7
Locate
that may otherwise be missing in their lives.
A
isolation
B
policing
C
anger
D
occupation
E
belief
F
proof
G
class
H
intelligence
I
excitement
J
unity
K
doubt

According to expert opinion, there is little 4 ____ Locate that football hooliganism occurs as a result of a number of issues and does not necessarily correlate with age, psychological profile or 5 ____ Locate . External triggers such as newspaper reports and antagonistic 6 ____ Locate can be attributed to escalation of the problem in certain situations. Some psychologists believe that such behaviour and membership of trouble-making groups can give certain individuals a sense of 7 ____ Locate that may otherwise be missing in their lives.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22517852-b03a-5ab2-bc21-fb11091d92b6', '255c2c32-2bbb-5c8c-8d04-726255192bb5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa8f08b2-7560-5e62-bfc9-6f6bda7e4bd1', '255c2c32-2bbb-5c8c-8d04-726255192bb5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbdbe844-5619-5997-8343-5282eea28ba4', '255c2c32-2bbb-5c8c-8d04-726255192bb5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ac5e5a6-ecf4-5174-b134-982af88c330c', '255c2c32-2bbb-5c8c-8d04-726255192bb5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a1f5546-4fd1-595a-8fea-362b72617679', '255c2c32-2bbb-5c8c-8d04-726255192bb5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77d57218-9a5c-5e23-a536-4ddde4eefd06', '255c2c32-2bbb-5c8c-8d04-726255192bb5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1aee965-b54c-5195-ae81-17f92632a259', '255c2c32-2bbb-5c8c-8d04-726255192bb5', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dbd20c3-24b5-555a-8b6d-ebd1bf06ec13', '255c2c32-2bbb-5c8c-8d04-726255192bb5', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d21697c-1115-59ce-bff3-b18668ab16d0', '255c2c32-2bbb-5c8c-8d04-726255192bb5', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de708576-ce1d-5b42-a8ab-50727761ded5', '255c2c32-2bbb-5c8c-8d04-726255192bb5', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d8c5e20-e515-5bf5-8b3a-b095564828cb', '255c2c32-2bbb-5c8c-8d04-726255192bb5', 11, $md$K$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7f88339f-8b9f-50f7-b241-9a910359aee8', 'e7be57d7-cb51-5f45-bd09-6b1ecec227ff', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 4-7
Questions 4-7
Complete the summary with the list of words
A-K
below.
Write the correct letter
A-K
in boxes
4-7
on your answer sheet.
According to expert opinion, there is little
4
Locate
that football hooliganism occurs as a result of a number of issues and does not necessarily correlate with age, psychological profile or
5
Locate
. External triggers such as newspaper reports and antagonistic
6
Locate
can be attributed to escalation of the problem in certain situations. Some psychologists believe that such behaviour and membership of trouble-making groups can give certain individuals a sense of
7
Locate
that may otherwise be missing in their lives.
A
isolation
B
policing
C
anger
D
occupation
E
belief
F
proof
G
class
H
intelligence
I
excitement
J
unity
K
doubt

According to expert opinion, there is little 4 ____ Locate that football hooliganism occurs as a result of a number of issues and does not necessarily correlate with age, psychological profile or 5 ____ Locate . External triggers such as newspaper reports and antagonistic 6 ____ Locate can be attributed to escalation of the problem in certain situations. Some psychologists believe that such behaviour and membership of trouble-making groups can give certain individuals a sense of 7 ____ Locate that may otherwise be missing in their lives.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edeb93a8-e84c-5b86-ba2e-d576840035ea', '7f88339f-8b9f-50f7-b241-9a910359aee8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3891b3c5-5dbd-540b-9b1e-e618c8020e44', '7f88339f-8b9f-50f7-b241-9a910359aee8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('075d8afc-a269-52d2-a1b5-d3ee685ef659', '7f88339f-8b9f-50f7-b241-9a910359aee8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eeedf434-1c98-536a-9384-08c09261be87', '7f88339f-8b9f-50f7-b241-9a910359aee8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efd6489d-8212-5d90-a471-79047aae2340', '7f88339f-8b9f-50f7-b241-9a910359aee8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d39ce4f-426d-5d93-b256-d3dabeba6155', '7f88339f-8b9f-50f7-b241-9a910359aee8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2ca9650-368c-5ea6-9b3a-8204788fbadf', '7f88339f-8b9f-50f7-b241-9a910359aee8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c3ae9db-7f98-57d2-a93b-18b5027fed74', '7f88339f-8b9f-50f7-b241-9a910359aee8', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f6e9df5-bc44-5aa0-a4a6-73f07cce0717', '7f88339f-8b9f-50f7-b241-9a910359aee8', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c36999f-8899-525c-b26a-8cf8eb0bd414', '7f88339f-8b9f-50f7-b241-9a910359aee8', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50f1daa5-e58e-5366-ac9c-64fd4ba38167', '7f88339f-8b9f-50f7-b241-9a910359aee8', 11, $md$K$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cf79be9b-35f0-5be2-ba54-dbf6588078c6', 'e7be57d7-cb51-5f45-bd09-6b1ecec227ff', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 4-7
Questions 4-7
Complete the summary with the list of words
A-K
below.
Write the correct letter
A-K
in boxes
4-7
on your answer sheet.
According to expert opinion, there is little
4
Locate
that football hooliganism occurs as a result of a number of issues and does not necessarily correlate with age, psychological profile or
5
Locate
. External triggers such as newspaper reports and antagonistic
6
Locate
can be attributed to escalation of the problem in certain situations. Some psychologists believe that such behaviour and membership of trouble-making groups can give certain individuals a sense of
7
Locate
that may otherwise be missing in their lives.
A
isolation
B
policing
C
anger
D
occupation
E
belief
F
proof
G
class
H
intelligence
I
excitement
J
unity
K
doubt

According to expert opinion, there is little 4 ____ Locate that football hooliganism occurs as a result of a number of issues and does not necessarily correlate with age, psychological profile or 5 ____ Locate . External triggers such as newspaper reports and antagonistic 6 ____ Locate can be attributed to escalation of the problem in certain situations. Some psychologists believe that such behaviour and membership of trouble-making groups can give certain individuals a sense of 7 ____ Locate that may otherwise be missing in their lives.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81c949cc-d245-5e56-a67a-41f1917469c3', 'cf79be9b-35f0-5be2-ba54-dbf6588078c6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e827c8db-12e5-5bff-8073-b15c824be135', 'cf79be9b-35f0-5be2-ba54-dbf6588078c6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77b18e2a-3504-5413-a490-2ea34f94176d', 'cf79be9b-35f0-5be2-ba54-dbf6588078c6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11796bd3-d72f-5c89-8020-712452cd4216', 'cf79be9b-35f0-5be2-ba54-dbf6588078c6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1826889-55d0-5b02-afda-d14044b626d3', 'cf79be9b-35f0-5be2-ba54-dbf6588078c6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e55f652b-b59c-58ec-9ba3-12c978f004d0', 'cf79be9b-35f0-5be2-ba54-dbf6588078c6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20a6286e-6ce5-511e-915f-41e57d95f234', 'cf79be9b-35f0-5be2-ba54-dbf6588078c6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8224b7ad-ef30-522c-81d6-236a814bcdd5', 'cf79be9b-35f0-5be2-ba54-dbf6588078c6', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89b1b77d-e9ec-5720-8ef0-fb213ade0a8f', 'cf79be9b-35f0-5be2-ba54-dbf6588078c6', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('499890a1-326b-5a67-88f7-86df2f524353', 'cf79be9b-35f0-5be2-ba54-dbf6588078c6', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f9b80c2-45b6-510f-9020-fb7087ad9e2e', 'cf79be9b-35f0-5be2-ba54-dbf6588078c6', 11, $md$K$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e1041fa-e25f-528d-8aef-6b17e5aded07', 'e7be57d7-cb51-5f45-bd09-6b1ecec227ff', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 8-12
Questions 8-12
Reading Passage has 7 paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
in boxes
8-12
on your answer sheet
NB
Each paragraph may be used
more than once
details about stipulations made to offer financial assistance to the club
reasons for disruption of national competitions
information about why the problem of violence at football matches may be perceived by the general public to be larger than it is.
deliberations about the Manchester United name
a reference to a new competition
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate

8 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3a44d9a-25b2-5cb9-9be5-c4fea4bd2623', '4e1041fa-e25f-528d-8aef-6b17e5aded07', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a51e0dec-e12e-5e85-a434-0f385ac6e4ae', '4e1041fa-e25f-528d-8aef-6b17e5aded07', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09044ed8-ade5-568a-9462-2b4ea0711fcf', '4e1041fa-e25f-528d-8aef-6b17e5aded07', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('151f9806-8218-52ca-9493-bc185c7c2e6d', '4e1041fa-e25f-528d-8aef-6b17e5aded07', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85e25319-88a0-5ce5-b831-6d9519076e82', '4e1041fa-e25f-528d-8aef-6b17e5aded07', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a00063ea-6fee-54c2-88e2-915e91abe606', '4e1041fa-e25f-528d-8aef-6b17e5aded07', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e719aad8-bb28-5dda-bc73-42a06a9aaf00', '4e1041fa-e25f-528d-8aef-6b17e5aded07', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e69977d3-2c5f-56f7-a22f-952ff7fd0765', 'e7be57d7-cb51-5f45-bd09-6b1ecec227ff', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 8-12
Questions 8-12
Reading Passage has 7 paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
in boxes
8-12
on your answer sheet
NB
Each paragraph may be used
more than once
details about stipulations made to offer financial assistance to the club
reasons for disruption of national competitions
information about why the problem of violence at football matches may be perceived by the general public to be larger than it is.
deliberations about the Manchester United name
a reference to a new competition
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate

9 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33f21637-ddff-5a61-828d-3144e6622c19', 'e69977d3-2c5f-56f7-a22f-952ff7fd0765', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b82097f4-6c6b-5d57-b418-53a2cdaa0df1', 'e69977d3-2c5f-56f7-a22f-952ff7fd0765', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99672c01-12e1-5ccf-8eaa-195f547e8890', 'e69977d3-2c5f-56f7-a22f-952ff7fd0765', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37921767-267b-5dc2-a901-53447224a03b', 'e69977d3-2c5f-56f7-a22f-952ff7fd0765', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56bb8d28-03d4-5a12-919d-88753d2947e7', 'e69977d3-2c5f-56f7-a22f-952ff7fd0765', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e7d4143-f495-5ba8-a9b3-5549e75fd5f2', 'e69977d3-2c5f-56f7-a22f-952ff7fd0765', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e731a536-31f2-5aa6-b3e4-35eecc661bd0', 'e69977d3-2c5f-56f7-a22f-952ff7fd0765', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b6ce9a76-d531-53c4-9473-70821a0ad01c', 'e7be57d7-cb51-5f45-bd09-6b1ecec227ff', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Questions 8-12
Questions 8-12
Reading Passage has 7 paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
in boxes
8-12
on your answer sheet
NB
Each paragraph may be used
more than once
details about stipulations made to offer financial assistance to the club
reasons for disruption of national competitions
information about why the problem of violence at football matches may be perceived by the general public to be larger than it is.
deliberations about the Manchester United name
a reference to a new competition
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate

10 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8fc7f3e-aa49-554f-ab91-f9f6d089150b', 'b6ce9a76-d531-53c4-9473-70821a0ad01c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3026106a-a584-5747-b569-95f0b666ce8b', 'b6ce9a76-d531-53c4-9473-70821a0ad01c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8542962e-b3cc-5e17-bd0f-3656c3292920', 'b6ce9a76-d531-53c4-9473-70821a0ad01c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('775bbe6d-571f-5b98-9083-4696af971207', 'b6ce9a76-d531-53c4-9473-70821a0ad01c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('863b13d0-da81-52b6-871a-1b6c2079c39a', 'b6ce9a76-d531-53c4-9473-70821a0ad01c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa88f6cf-88e1-5f19-9a68-2e46cd3b8951', 'b6ce9a76-d531-53c4-9473-70821a0ad01c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b37eb423-9b7d-5a09-8b10-50cdfdaa60c5', 'b6ce9a76-d531-53c4-9473-70821a0ad01c', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cb122100-d6ce-5fd5-800a-8097f80bc343', 'e7be57d7-cb51-5f45-bd09-6b1ecec227ff', 11, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 11

Questions 8-12
Questions 8-12
Reading Passage has 7 paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
in boxes
8-12
on your answer sheet
NB
Each paragraph may be used
more than once
details about stipulations made to offer financial assistance to the club
reasons for disruption of national competitions
information about why the problem of violence at football matches may be perceived by the general public to be larger than it is.
deliberations about the Manchester United name
a reference to a new competition
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate

11 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('752ea322-aabe-5c1f-90b2-cd49b5ac4fe2', 'cb122100-d6ce-5fd5-800a-8097f80bc343', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7934e93-d806-55db-a966-c0f09ae9b62d', 'cb122100-d6ce-5fd5-800a-8097f80bc343', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('421a581d-a599-52fa-bdc8-35a838e07289', 'cb122100-d6ce-5fd5-800a-8097f80bc343', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('318d466b-3959-5125-9276-d2120e2e701f', 'cb122100-d6ce-5fd5-800a-8097f80bc343', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c94b32f8-ba04-562b-aaea-644dc779e0f8', 'cb122100-d6ce-5fd5-800a-8097f80bc343', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04fd98a0-2c6e-535c-9ea6-64e5f6fe91dd', 'cb122100-d6ce-5fd5-800a-8097f80bc343', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04ddf34f-2140-586a-91bc-d10826329f39', 'cb122100-d6ce-5fd5-800a-8097f80bc343', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('85f74f35-2aa6-5b08-8f70-e71ad98c272f', 'e7be57d7-cb51-5f45-bd09-6b1ecec227ff', 12, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 12

Questions 8-12
Questions 8-12
Reading Passage has 7 paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
in boxes
8-12
on your answer sheet
NB
Each paragraph may be used
more than once
details about stipulations made to offer financial assistance to the club
reasons for disruption of national competitions
information about why the problem of violence at football matches may be perceived by the general public to be larger than it is.
deliberations about the Manchester United name
a reference to a new competition
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate

12 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71a24d06-bf43-5656-bd58-d849acbabb56', '85f74f35-2aa6-5b08-8f70-e71ad98c272f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca21fa11-8be1-5cd0-936c-e22f9857b979', '85f74f35-2aa6-5b08-8f70-e71ad98c272f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db41762a-b448-5d83-b74f-c84e0e0173b3', '85f74f35-2aa6-5b08-8f70-e71ad98c272f', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40aed6f4-9f2e-5d3c-9d7b-9c216a4c463e', '85f74f35-2aa6-5b08-8f70-e71ad98c272f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12872a3f-3fe6-55d8-afc8-7842c4f75ba7', '85f74f35-2aa6-5b08-8f70-e71ad98c272f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eda1bafd-1760-5f6f-9918-86d84be281ed', '85f74f35-2aa6-5b08-8f70-e71ad98c272f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24ed5450-cfa2-5655-b167-1bd559ad8ffc', '85f74f35-2aa6-5b08-8f70-e71ad98c272f', 7, $md$G$md$, false);

COMMIT;
