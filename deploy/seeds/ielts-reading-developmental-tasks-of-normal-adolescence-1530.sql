BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-developmental-tasks-of-normal-adolescence-1530'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-developmental-tasks-of-normal-adolescence-1530';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-developmental-tasks-of-normal-adolescence-1530';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-developmental-tasks-of-normal-adolescence-1530';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('856b7948-1d0d-50d5-8f08-106dcea3b918', 'ielts-reading-developmental-tasks-of-normal-adolescence-1530', $t$Developmental Tasks of Normal Adolescence$t$, $md$## Developmental Tasks of Normal Adolescence

Nguồn:
- Test: https://mini-ielts.com/1530/reading/developmental-tasks-of-normal-adolescence
- Solution: https://mini-ielts.com/1530/view-solution/reading/developmental-tasks-of-normal-adolescence$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('a9fee519-115c-557c-b3dd-cb295c97f972', '856b7948-1d0d-50d5-8f08-106dcea3b918', 1, $t$Reading — Developmental Tasks of Normal Adolescence$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Developmental Tasks of Normal Adolescence

Some years ago, Professor Robert Havighurst of the University of Chicago, USA, proposed that stages in human development can best be thought of in terms of the developmental ‘tasks’ that are part of the normal transition. He identified ten developmental tasks associated with the adolescent transition. Each of the Havighurst tasks can also be seen as elements of the overall sense of self that adolescents carry with them as they move towards and into young adulthood. Adolescents do not progress through these multiple developmental tasks separately; at any given time they may be dealing with several.

The adolescent must adjust to a new physical sense of self. At no other time since birth does an individual undergo such profound physical changes as during early adolescence. Puberty is marked by sudden rapid growth in height and weight. Also, the young person experiences the emergence and accentuation of those physical traits that make the person a boy or a girl. The young person looks less like a child and more like a physically mature adult. The effect of this rapid change is that mid-adolescents are body-conscious, and their concerns are directed towards their opposite-sexed peers.

The adolescent must adjust to new intellectual abilities. In addition to a sudden spurt in physical growth, adolescents experience a sudden increase in their ability to think about their world. As a normal part of maturity, they are able to think more things. However, they are also able to conceive of their world with awareness. Before adolescence, children's thinking is dominated by a concrete example for any problem that they solve; their thinking is constrained to what is real and physical. During adolescence, young people begin to recognise and understand abstractions. The growth in ability to deal with abstractions accelerates during the middle stages of adolescence.

The adolescent must adjust to increased cognitive demands at school. Adults see high school in part as a place where adolescents prepare for adult roles and responsibilities and in part as preparatory for further education. School curricula are frequently dominated by the inclusion of more abstract, demanding material, regardless of whether the adolescents have achieved formal thought. Since not all adolescents make the intellectual transition at the same rate, demands for abstract thinking prior to the achievement of that ability may be frustrating.

The adolescent must adopt a personal value system. During adolescence, as teens develop increasingly complex knowledge systems, they also adopt an integrated set of values and morals. During the early stages of moral development, parents provide their child with a structured set of rules of what is right and wrong, what is acceptable and unacceptable. Eventually the adolescent must assess the parent's values as they come into conflict with values expressed by peers and other segments of society. To reconcile differences, the adolescent restructures those beliefs into a personal ideology.

The adolescent must develop expanded verbal skills to accommodate more complex concepts and tasks. Their limited language of childhood is no longer adequate. As their conceptual development may outstrip their verbal development, adolescents may appear less competent than they really are.

The adolescent must establish adult vocational goals. As part of the process of establishing a personal identity, the adolescent must also begin the process of focusing on the question, 'What do you plan to be when you grow up? 1 Mid-adolescents must identify, at least at a preliminary level, what their adult vocational goals are and how they intend to achieve them.

The adolescent must develop a personal sense of identity. Prior to adolescence, one's identity is an extension of one's parents' identity. During the early adolescent years a young person begins to recognise their uniqueness and to establish themselves as separate individuals, independent of their parents. As such, one must reconsider the answer to the question, ‘what does it mean to be me?' or "who am l?"

The adolescent must establish emotional and psychological independence from his or her parents, childhood is marked by strong dependence on one's parents. Adolescents may yearn to keep that safe, secure, supportive, dependent relationship. Yet, to be an adult implies a sense of independence, of autonomy, of being one's own person. In an attempt to assert their need for independence and individuality, adolescents may respond with what appears to be hostility and lack of cooperation.

The adolescent must develop stable and productive peer relationships. Although peer interaction is not unique to adolescence, it seems to hit a peak of importance during early adolescence. Certainly by late adolescence or early adulthood the need for peer approval has diminished. This degree to which an adolescent is able to make friends and have an accepting peer group, though, is a major indicator of how well the adolescent will adjust in other areas of social and psychological development. Early adolescence is also a period of intense conformity to peers.” Fitting in' not being different, and being accepted seem somehow pressing to this age group. The worst possibility, from the view of the young teen, is to be seen by peers as different.

The adolescent must develop increased impulse control and behavioural maturity. In their shift to adulthood, most young people engage in one or more behaviours that place them at physical, social, or educational risk. Risky behaviours are sufficiently pervasive among adolescents to suggest that risk-taking may be a normal developmental process of middle adolescence. Gradually adolescents develop a set of behavioural self-controls through which they assess which behaviours are acceptable and adult-like.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('be4e4e44-f698-55cc-a15a-fab26f5091dc', 'a9fee519-115c-557c-b3dd-cb295c97f972', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Classify the following developments as characterising
A early adolescence
B middle adolescence
C late adolescence
Write the correct letter, A, B or C, in boxes 1-6 on your answer sheet
1
becoming interested in people of the other gender
2
beginning to choose a future career
3
needing to feel the same as one's friends
4
beginning to form a self-image separate from the family context
5
having less need for the good opinion of friends
6
exposing oneself to dangers

1 ____ becoming interested in people of the other gender$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('903e6a51-4240-5962-b37b-2ebc6d48af38', 'be4e4e44-f698-55cc-a15a-fab26f5091dc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf1d9f7b-8d71-51b8-afb3-38c26b93c37a', 'be4e4e44-f698-55cc-a15a-fab26f5091dc', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9cbebf2b-1b62-5748-9030-842bc7fabcf0', 'be4e4e44-f698-55cc-a15a-fab26f5091dc', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1f281d67-119b-530b-a4f4-ee6de95c2625', 'a9fee519-115c-557c-b3dd-cb295c97f972', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Classify the following developments as characterising
A early adolescence
B middle adolescence
C late adolescence
Write the correct letter, A, B or C, in boxes 1-6 on your answer sheet
1
becoming interested in people of the other gender
2
beginning to choose a future career
3
needing to feel the same as one's friends
4
beginning to form a self-image separate from the family context
5
having less need for the good opinion of friends
6
exposing oneself to dangers

2 ____ beginning to choose a future career$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29034c03-cefc-5dcd-a5b3-0ae0161e7bc4', '1f281d67-119b-530b-a4f4-ee6de95c2625', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0920716-3bb7-5766-97cd-e48520961ac5', '1f281d67-119b-530b-a4f4-ee6de95c2625', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddb94d31-59e9-5217-8a4d-7724c7697b04', '1f281d67-119b-530b-a4f4-ee6de95c2625', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4a69160b-fab3-5a94-8aca-1243d583f422', 'a9fee519-115c-557c-b3dd-cb295c97f972', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Classify the following developments as characterising
A early adolescence
B middle adolescence
C late adolescence
Write the correct letter, A, B or C, in boxes 1-6 on your answer sheet
1
becoming interested in people of the other gender
2
beginning to choose a future career
3
needing to feel the same as one's friends
4
beginning to form a self-image separate from the family context
5
having less need for the good opinion of friends
6
exposing oneself to dangers

3 ____ needing to feel the same as one's friends$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d32285b-e7fd-5360-9f4b-06e2881ccf9a', '4a69160b-fab3-5a94-8aca-1243d583f422', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7eb60d2c-e7d1-5716-b8ef-ce89b9f97d86', '4a69160b-fab3-5a94-8aca-1243d583f422', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdbfd375-d3ae-5822-be1d-8b4206e14160', '4a69160b-fab3-5a94-8aca-1243d583f422', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('67096d9b-37bf-515d-af4c-2cf55e3b793b', 'a9fee519-115c-557c-b3dd-cb295c97f972', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Classify the following developments as characterising
A early adolescence
B middle adolescence
C late adolescence
Write the correct letter, A, B or C, in boxes 1-6 on your answer sheet
1
becoming interested in people of the other gender
2
beginning to choose a future career
3
needing to feel the same as one's friends
4
beginning to form a self-image separate from the family context
5
having less need for the good opinion of friends
6
exposing oneself to dangers

4 ____ beginning to form a self-image separate from the family context$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12faaba9-a948-587e-86a3-7a83e125060f', '67096d9b-37bf-515d-af4c-2cf55e3b793b', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27f97d28-f058-514f-9a57-79abf02bd0b1', '67096d9b-37bf-515d-af4c-2cf55e3b793b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2680f48-897f-5538-93c9-f0b6bdafa9b8', '67096d9b-37bf-515d-af4c-2cf55e3b793b', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('81633a20-420b-57cd-816e-4cb4e4052cdc', 'a9fee519-115c-557c-b3dd-cb295c97f972', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Classify the following developments as characterising
A early adolescence
B middle adolescence
C late adolescence
Write the correct letter, A, B or C, in boxes 1-6 on your answer sheet
1
becoming interested in people of the other gender
2
beginning to choose a future career
3
needing to feel the same as one's friends
4
beginning to form a self-image separate from the family context
5
having less need for the good opinion of friends
6
exposing oneself to dangers

5 ____ having less need for the good opinion of friends$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd46a65f-1157-52ae-b9d7-5fda58070ca9', '81633a20-420b-57cd-816e-4cb4e4052cdc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a07a6e6f-d552-5081-9b26-696fd6be0c88', '81633a20-420b-57cd-816e-4cb4e4052cdc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea528f26-4e1b-5a3d-b141-e931be189752', '81633a20-420b-57cd-816e-4cb4e4052cdc', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c9a4dc3-881e-5e9a-ae49-8c2e4f912441', 'a9fee519-115c-557c-b3dd-cb295c97f972', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Classify the following developments as characterising
A early adolescence
B middle adolescence
C late adolescence
Write the correct letter, A, B or C, in boxes 1-6 on your answer sheet
1
becoming interested in people of the other gender
2
beginning to choose a future career
3
needing to feel the same as one's friends
4
beginning to form a self-image separate from the family context
5
having less need for the good opinion of friends
6
exposing oneself to dangers

6 ____ exposing oneself to dangers$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90e236cb-6831-5880-935a-821ffa4c0a5b', '1c9a4dc3-881e-5e9a-ae49-8c2e4f912441', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c1ec065-dafe-5a1d-b3dd-b3c69614fbeb', '1c9a4dc3-881e-5e9a-ae49-8c2e4f912441', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a10589f6-d06e-5c8e-8c38-fe3260371346', '1c9a4dc3-881e-5e9a-ae49-8c2e4f912441', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('55ba7c4e-51c2-51f7-90a4-70aa69785241', 'a9fee519-115c-557c-b3dd-cb295c97f972', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Complete each sentence with the correct ending, A-E, below.
Write the correct letter, A-E in boxes 7-10 on your answer sheet.
7
Havighurst proposed a set of tasks which
8
A course of study at high school
9
The speed of development of thinking ability during adolescence
10
Adolescence is a time when the young person
A reflects an adolescent's emerging self-perception.
B cannot solve a problem without an example.
C is designed to become more challenging.
D formulates a personal set of moral beliefs and values.
E varies according to the individual.

7 ____ Havighurst proposed a set of tasks which$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb20afcd-7f36-5d88-b0c3-7e1005f78388', '55ba7c4e-51c2-51f7-90a4-70aa69785241', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0552f60f-9d86-5cc0-8c2a-2b3c18876e5a', '55ba7c4e-51c2-51f7-90a4-70aa69785241', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e1a451e-a983-5bb7-8f45-2b9b2128551e', '55ba7c4e-51c2-51f7-90a4-70aa69785241', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f918a12-a7b4-533d-9a29-4bb8ed86c87f', '55ba7c4e-51c2-51f7-90a4-70aa69785241', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b64c4315-0f16-5663-a963-e75d439262de', '55ba7c4e-51c2-51f7-90a4-70aa69785241', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3fb83b72-3163-517b-a0c0-0960120295e1', 'a9fee519-115c-557c-b3dd-cb295c97f972', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Complete each sentence with the correct ending, A-E, below.
Write the correct letter, A-E in boxes 7-10 on your answer sheet.
7
Havighurst proposed a set of tasks which
8
A course of study at high school
9
The speed of development of thinking ability during adolescence
10
Adolescence is a time when the young person
A reflects an adolescent's emerging self-perception.
B cannot solve a problem without an example.
C is designed to become more challenging.
D formulates a personal set of moral beliefs and values.
E varies according to the individual.

8 ____ A course of study at high school$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af347c56-79bc-5f34-ab70-3d4c967ef358', '3fb83b72-3163-517b-a0c0-0960120295e1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7cbe3a2-06d6-5c39-9faa-1a703407e03c', '3fb83b72-3163-517b-a0c0-0960120295e1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc0a505b-cc32-5f03-9f6a-d233f9872f47', '3fb83b72-3163-517b-a0c0-0960120295e1', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f03da7c4-17a7-503b-a81e-ff6dddf4c1ba', '3fb83b72-3163-517b-a0c0-0960120295e1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61c593ac-9a07-5ff4-a19f-ae8c147d9cc2', '3fb83b72-3163-517b-a0c0-0960120295e1', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b01d97f4-0bb5-50af-b09d-84ec7fd87ca7', 'a9fee519-115c-557c-b3dd-cb295c97f972', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Complete each sentence with the correct ending, A-E, below.
Write the correct letter, A-E in boxes 7-10 on your answer sheet.
7
Havighurst proposed a set of tasks which
8
A course of study at high school
9
The speed of development of thinking ability during adolescence
10
Adolescence is a time when the young person
A reflects an adolescent's emerging self-perception.
B cannot solve a problem without an example.
C is designed to become more challenging.
D formulates a personal set of moral beliefs and values.
E varies according to the individual.

9 ____ The speed of development of thinking ability during adolescence$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58a7f875-f7f8-58fc-8304-817f15ef7ac1', 'b01d97f4-0bb5-50af-b09d-84ec7fd87ca7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d9e53ef-959e-57a3-8fae-932a6f69de6c', 'b01d97f4-0bb5-50af-b09d-84ec7fd87ca7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53d6aaa9-4e91-5648-b64f-01c3126cbc6e', 'b01d97f4-0bb5-50af-b09d-84ec7fd87ca7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77893cac-c958-5d6b-83b8-651e113f1468', 'b01d97f4-0bb5-50af-b09d-84ec7fd87ca7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a455c3a-925c-58e5-8066-660974278aaf', 'b01d97f4-0bb5-50af-b09d-84ec7fd87ca7', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a112bbb-f5a2-524b-b289-5e0d334d7c20', 'a9fee519-115c-557c-b3dd-cb295c97f972', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Complete each sentence with the correct ending, A-E, below.
Write the correct letter, A-E in boxes 7-10 on your answer sheet.
7
Havighurst proposed a set of tasks which
8
A course of study at high school
9
The speed of development of thinking ability during adolescence
10
Adolescence is a time when the young person
A reflects an adolescent's emerging self-perception.
B cannot solve a problem without an example.
C is designed to become more challenging.
D formulates a personal set of moral beliefs and values.
E varies according to the individual.

10 ____ Adolescence is a time when the young person$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b1f650d-2428-5230-8ccf-aa13e79f8650', '9a112bbb-f5a2-524b-b289-5e0d334d7c20', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c028ed2-7a50-525a-af30-d7ac0ee9f8eb', '9a112bbb-f5a2-524b-b289-5e0d334d7c20', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('974ba03f-7765-58ea-a894-a165578df996', '9a112bbb-f5a2-524b-b289-5e0d334d7c20', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7c83089-6b41-5374-a671-8a6eb181e8de', '9a112bbb-f5a2-524b-b289-5e0d334d7c20', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52f7b08e-3f34-5ced-af4b-e5c64344a3b6', '9a112bbb-f5a2-524b-b289-5e0d334d7c20', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('78dd4219-2ed4-5cb5-902d-7ffece1d9460', 'a9fee519-115c-557c-b3dd-cb295c97f972', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN if there is no information on this
11
Most pre-adolescent children are capable of abstract thought.
12
Adolescents ‘limited skills with words may give a false impression of their ability.
13
Whether or not an adolescent is accepted by their age-group is an important clue to other aspects of their social adjustment.

11 ____ Most pre-adolescent children are capable of abstract thought.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3958096b-9b6b-57c5-9aa9-f2730f719255', '78dd4219-2ed4-5cb5-902d-7ffece1d9460', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a37f71c-a30d-543a-b8e9-fefade16c214', '78dd4219-2ed4-5cb5-902d-7ffece1d9460', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5459cc05-faf6-5bf9-ba84-bdb362365d60', '78dd4219-2ed4-5cb5-902d-7ffece1d9460', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('60f116a8-3858-5c8a-bbd1-012e7d4ba28a', 'a9fee519-115c-557c-b3dd-cb295c97f972', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN if there is no information on this
11
Most pre-adolescent children are capable of abstract thought.
12
Adolescents ‘limited skills with words may give a false impression of their ability.
13
Whether or not an adolescent is accepted by their age-group is an important clue to other aspects of their social adjustment.

12 ____ Adolescents ‘limited skills with words may give a false impression of their ability.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95996c00-f5db-5bc5-96ce-bf319a730130', '60f116a8-3858-5c8a-bbd1-012e7d4ba28a', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13f5621d-df2d-5ff4-a54c-96f934e8b8df', '60f116a8-3858-5c8a-bbd1-012e7d4ba28a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84dd95c6-12fb-555a-9865-f39dc086105b', '60f116a8-3858-5c8a-bbd1-012e7d4ba28a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5ba4088c-4c7e-5350-9dc7-b0e96babce6b', 'a9fee519-115c-557c-b3dd-cb295c97f972', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN if there is no information on this
11
Most pre-adolescent children are capable of abstract thought.
12
Adolescents ‘limited skills with words may give a false impression of their ability.
13
Whether or not an adolescent is accepted by their age-group is an important clue to other aspects of their social adjustment.

13 ____ Whether or not an adolescent is accepted by their age-group is an important clue to other aspects of their social adjustment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f8bd241-0711-537a-ac59-ded1402763f1', '5ba4088c-4c7e-5350-9dc7-b0e96babce6b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4fab0d3-457d-5342-9195-19793eeac53e', '5ba4088c-4c7e-5350-9dc7-b0e96babce6b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab16c020-3abe-5a06-aa91-81b20258c77f', '5ba4088c-4c7e-5350-9dc7-b0e96babce6b', 3, $md$NOT GIVEN$md$, false);

COMMIT;
