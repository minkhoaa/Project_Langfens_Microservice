BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-adolescents-1395'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-adolescents-1395';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-adolescents-1395';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-adolescents-1395';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('08b30921-566a-571b-9ffc-98abe6383806', 'ielts-reading-the-adolescents-1395', $t$The Adolescents$t$, $md$## The Adolescents

Nguồn:
- Test: https://mini-ielts.com/1395/reading/the-adolescents
- Solution: https://mini-ielts.com/1395/view-solution/reading/the-adolescents$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3e9c1c08-3422-5dab-9c85-c85ed2643f00', '08b30921-566a-571b-9ffc-98abe6383806', 1, $t$Reading — The Adolescents$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Adolescents

A

The American Academy of Pediatrics recognizes three stages of adolescence. These are early, middle and late adolescence, and each has its own developmental tasks. Teenagers move through these tasks at their own speed depending on their physical development and hormone levels. Although these stages are common to all teenagers, each child will go through them in his or her own highly individual ways.

B

During the early years young people make the first attempts to leave the dependent, secure role of a child and to establish themselves as unique individuals, independent of their parents. Early adolescence is marked by rapid physical growth and maturation. The focus of adolescents’ self-concepts is thus often on their physical self and their evaluation of their physical acceptability. Early adolescence is also a period of intense conformity to peers. ‘Getting along,’ not being different, and being accepted seem somehow pressing to the early adolescent. The worst possibility, from the view of the early adolescent, is to be seen by peers as ‘different’.

C

Middle adolescence is marked by the emergence of new thinking skills. The intellectual world of the young person is suddenly greatly expanded. Their concerns about peers are more directed toward their opposite sexed peers. It is also during this period that the move to establish psychological independence from one’s parents accelerates. Delinquency behavior may emerge since parental views are no longer seen as absolutely correct by adolescents. Despite some delinquent behavior, middle adolescence is a period during which young people are oriented toward what is right and proper. They are developing a sense of behavioral maturity and learning to control their impulsiveness.

D

Late adolescence is marked by the final preparations for adult roles. The developmental demands of late adolescence often extend into the period that we think of as young adulthood. Late adolescents attempt to crystallize their vocational goals and to establish a sense of personal identity. Their needs for peer approval are diminished and they are largely psychologically independent from their parents. The shift to adulthood is nearly complete.

E

Some years ago, Professor Robert Havighurst of the University of Chicago proposed that stages in human development can best be thought of in terms of the developmental tasks that are part of the normal transition. He identified eleven developmental tasks associated with the adolescent transition. One developmental task an adolescent needs to achieve is to adjust to a new physical sense of self. At no other time since birth does an individual undergo such rapid and profound physical changes as during early adolescence. Puberty is marked by sudden rapid growth in height and weight. Also, the young person experiences the emergence and accentuation of those physical traits that make him or her a boy or girl. The effect of this rapid change is that young adolescent often becomes focused on his or her body.

F

Before adolescence, children’s thinking is dominated by a need to have a concrete example for any problem that they solve. Their thinking is constrained to what is real and physical. During adolescence, young people begin to recognize and understand abstractions. The adolescent must adjust to increased cognitive demands at school. Adults see high school in part as a place where adolescents prepare for adult roles and responsibilities and in part as preparatory for further education. School curricula are frequently dominated by the inclusion of more abstract, demanding material, regardless of whether the adolescents have achieved formal thought. Since not all adolescents make the intellectual transition at the same rate, demands for abstract thinking prior to achievement of that ability may be frustrating.

G

During adolescence, as teens develop increasingly complex knowledge systems and a sense of self, they also adopt an integrated set of values and morals. During the early stages of moral development, parents provide their child with a structured set of rules of what is right and wrong, what is acceptable and unacceptable. Eventually, the adolescent must assess the parents’ values as they come into conflict with values expressed by peers and other segments of society. To reconcile differences, the adolescent restructures those beliefs into a personal ideology.

H

The adolescent must develop expanded verbal skills. As adolescents mature intellectually, as they face increased school demands, and as they prepare for adult roles, they must develop new verbal skills to accommodate more complex concepts and tasks. Their limited language of childhood is no longer adequate. Adolescents may appear less competent because of their inability to express themselves meaningfully.

I

The adolescent must establish emotional and psychological independence from his or her parents. Childhood is marked by a strong dependence on one’s parents. Adolescents may yearn to keep that safe, secure, supportive, dependent relationship. Yet, to be an adult implies a sense of independence, of autonomy, of being one’s own person. Adolescents may vacillate between their desire for dependence and their need to be independent. In an attempt to assert their need for independence and individuality, adolescents may respond with what appears to be hostility and lack of cooperation.

J

Adolescents do not progress through these multiple developmental tasks separately. At any given time, adolescents may be dealing with several. Further, the centrality of specific developmental tasks varies with early, middle, and late periods of the transition.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c40a9312-d140-563e-bccc-f980532a795d', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Match the following characteristics with the correct stages of the adolescent.
Write the correct letter,
A
,
B
or
C
, in boxes
1-6
on your answer sheet.
A
early adolescence
B
middle adolescence
C
later adolescence
1
interested in the opposite sex
2
exposure to danger
3
the same as others
4
beginning to form individual thinking without family context
5
less need the approval of friends
6
intellectual booming

1 ____ interested in the opposite sex$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50cc9e27-8ebf-5ba5-ad75-5499f64880f8', 'c40a9312-d140-563e-bccc-f980532a795d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e025848-b3a9-5226-9044-a0192de42290', 'c40a9312-d140-563e-bccc-f980532a795d', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60119d9d-7456-5f2c-82a9-130f16ba9725', 'c40a9312-d140-563e-bccc-f980532a795d', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('33552326-3613-55e9-88b2-0b12a9296731', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Match the following characteristics with the correct stages of the adolescent.
Write the correct letter,
A
,
B
or
C
, in boxes
1-6
on your answer sheet.
A
early adolescence
B
middle adolescence
C
later adolescence
1
interested in the opposite sex
2
exposure to danger
3
the same as others
4
beginning to form individual thinking without family context
5
less need the approval of friends
6
intellectual booming

2 ____ exposure to danger$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d195b3fd-0821-5fc1-a55b-a6795e672cc6', '33552326-3613-55e9-88b2-0b12a9296731', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f914b499-9627-563a-8368-2ab703e5edb0', '33552326-3613-55e9-88b2-0b12a9296731', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b907435-8db0-53cd-8540-9ef5d15cbf20', '33552326-3613-55e9-88b2-0b12a9296731', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('35b8046b-9c49-539c-b115-183e673a5fa7', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Match the following characteristics with the correct stages of the adolescent.
Write the correct letter,
A
,
B
or
C
, in boxes
1-6
on your answer sheet.
A
early adolescence
B
middle adolescence
C
later adolescence
1
interested in the opposite sex
2
exposure to danger
3
the same as others
4
beginning to form individual thinking without family context
5
less need the approval of friends
6
intellectual booming

3 ____ the same as others$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0425fd0-d600-5198-a277-b7221f9f1764', '35b8046b-9c49-539c-b115-183e673a5fa7', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4c868e7-f358-57a6-83f0-2a07c15b6155', '35b8046b-9c49-539c-b115-183e673a5fa7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3f786c8-8b43-5187-919f-68c2b0858460', '35b8046b-9c49-539c-b115-183e673a5fa7', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('14c38759-e0a2-5404-940d-1f9f96daeb7b', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Match the following characteristics with the correct stages of the adolescent.
Write the correct letter,
A
,
B
or
C
, in boxes
1-6
on your answer sheet.
A
early adolescence
B
middle adolescence
C
later adolescence
1
interested in the opposite sex
2
exposure to danger
3
the same as others
4
beginning to form individual thinking without family context
5
less need the approval of friends
6
intellectual booming

4 ____ beginning to form individual thinking without family context$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('938c5616-f7c9-544c-8840-43bc679a8e5c', '14c38759-e0a2-5404-940d-1f9f96daeb7b', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9233166-688e-54fd-98c4-740ea7da24d4', '14c38759-e0a2-5404-940d-1f9f96daeb7b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e9eee63-cbd4-5ec1-aee1-7e3d25487cda', '14c38759-e0a2-5404-940d-1f9f96daeb7b', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('361ff5e2-ef90-5038-81fe-267840c643a5', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Match the following characteristics with the correct stages of the adolescent.
Write the correct letter,
A
,
B
or
C
, in boxes
1-6
on your answer sheet.
A
early adolescence
B
middle adolescence
C
later adolescence
1
interested in the opposite sex
2
exposure to danger
3
the same as others
4
beginning to form individual thinking without family context
5
less need the approval of friends
6
intellectual booming

5 ____ less need the approval of friends$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('919f3a7d-b491-5c2a-8cd8-568ce1aa7013', '361ff5e2-ef90-5038-81fe-267840c643a5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e230d3f0-b25c-5a28-b70f-9c2496bdca75', '361ff5e2-ef90-5038-81fe-267840c643a5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a8eb5d3-5a01-5fe2-8c9f-ba83ff6857c3', '361ff5e2-ef90-5038-81fe-267840c643a5', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dad97bef-0463-5243-9d32-17fa2346213f', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Match the following characteristics with the correct stages of the adolescent.
Write the correct letter,
A
,
B
or
C
, in boxes
1-6
on your answer sheet.
A
early adolescence
B
middle adolescence
C
later adolescence
1
interested in the opposite sex
2
exposure to danger
3
the same as others
4
beginning to form individual thinking without family context
5
less need the approval of friends
6
intellectual booming

6 ____ intellectual booming$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('050545c3-0b3b-5d47-becd-a9b464f03067', 'dad97bef-0463-5243-9d32-17fa2346213f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b98e2dc-3d77-5e85-b0a7-fb3479ecfbb3', 'dad97bef-0463-5243-9d32-17fa2346213f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f28c0aa-b1ad-5e3f-9d05-49e3227732c8', 'dad97bef-0463-5243-9d32-17fa2346213f', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8763bc30-c559-5d87-a20d-5df8f1024119', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letters,
A-F
, in boxes
7-10
on your answer sheet.
7
One of Havighurst’s research
8
High School Courses
9
Adolescence is a time when young people
10
The developmental speed of thinking patterns
List of the statements
A
form personal identity with a set of morals and values
B
develops a table and productive peer relationships
C
are designed to be more challenging than some can accept
D
varies from people to people
E
focuses on creating a self-image
F
become an extension of their parents

7 ____ One of Havighurst’s research$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44c2c625-e418-508a-ab0a-ec6896217a6f', '8763bc30-c559-5d87-a20d-5df8f1024119', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28e1bfcb-51b8-5846-a609-6a059a270eb3', '8763bc30-c559-5d87-a20d-5df8f1024119', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b2ff3f7-225b-5ee7-b561-7b893dfceb44', '8763bc30-c559-5d87-a20d-5df8f1024119', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6f4f0db-44b1-5821-88ca-b5517524e2ea', '8763bc30-c559-5d87-a20d-5df8f1024119', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('041d4e2e-c4fa-536e-94e1-f1a681be1f7a', '8763bc30-c559-5d87-a20d-5df8f1024119', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40427a60-646b-5957-a993-b1823aee6791', '8763bc30-c559-5d87-a20d-5df8f1024119', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d2fc077a-24db-5641-adae-7e4bf67c4b63', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letters,
A-F
, in boxes
7-10
on your answer sheet.
7
One of Havighurst’s research
8
High School Courses
9
Adolescence is a time when young people
10
The developmental speed of thinking patterns
List of the statements
A
form personal identity with a set of morals and values
B
develops a table and productive peer relationships
C
are designed to be more challenging than some can accept
D
varies from people to people
E
focuses on creating a self-image
F
become an extension of their parents

8 ____ High School Courses$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31e91134-6490-58ca-948d-35c4a6c2c9d1', 'd2fc077a-24db-5641-adae-7e4bf67c4b63', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6acd9be6-5e34-5c13-b1e1-9ae8f9956e74', 'd2fc077a-24db-5641-adae-7e4bf67c4b63', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6864394e-0bf1-505a-bf33-7dcb2992c189', 'd2fc077a-24db-5641-adae-7e4bf67c4b63', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2373b42e-2ced-5847-9ac5-52b7dbd8b1a7', 'd2fc077a-24db-5641-adae-7e4bf67c4b63', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91f5f7a8-0ec9-59e6-9320-88e61ad457bd', 'd2fc077a-24db-5641-adae-7e4bf67c4b63', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27ee1fc2-a77e-538e-9f1e-337684b4be39', 'd2fc077a-24db-5641-adae-7e4bf67c4b63', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a1bef616-dfb8-5383-9a7f-eda7a96298b7', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letters,
A-F
, in boxes
7-10
on your answer sheet.
7
One of Havighurst’s research
8
High School Courses
9
Adolescence is a time when young people
10
The developmental speed of thinking patterns
List of the statements
A
form personal identity with a set of morals and values
B
develops a table and productive peer relationships
C
are designed to be more challenging than some can accept
D
varies from people to people
E
focuses on creating a self-image
F
become an extension of their parents

9 ____ Adolescence is a time when young people$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbf44a21-8b88-5c7a-a8e5-cc4f5927caf8', 'a1bef616-dfb8-5383-9a7f-eda7a96298b7', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be803ebd-5a92-58d8-9934-8db16b508f36', 'a1bef616-dfb8-5383-9a7f-eda7a96298b7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d0e217e-7a2c-57f1-a26b-0cfeb0dfeb84', 'a1bef616-dfb8-5383-9a7f-eda7a96298b7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eecd4f69-cb17-584e-88ae-03889898b4b4', 'a1bef616-dfb8-5383-9a7f-eda7a96298b7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dc33603-36af-5f50-9153-5eecc04b18cd', 'a1bef616-dfb8-5383-9a7f-eda7a96298b7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('930baf76-aac5-59b9-b438-fbcc303ba72f', 'a1bef616-dfb8-5383-9a7f-eda7a96298b7', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ed7a8281-3cc6-54fc-9b2e-8c78fd481881', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letters,
A-F
, in boxes
7-10
on your answer sheet.
7
One of Havighurst’s research
8
High School Courses
9
Adolescence is a time when young people
10
The developmental speed of thinking patterns
List of the statements
A
form personal identity with a set of morals and values
B
develops a table and productive peer relationships
C
are designed to be more challenging than some can accept
D
varies from people to people
E
focuses on creating a self-image
F
become an extension of their parents

10 ____ The developmental speed of thinking patterns$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1d3f8d9-d170-5553-a2c1-01ed962b3fab', 'ed7a8281-3cc6-54fc-9b2e-8c78fd481881', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('918380c0-81bf-5adc-bb1b-30806689cf75', 'ed7a8281-3cc6-54fc-9b2e-8c78fd481881', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4cef25e-853c-5dfd-8a38-278516973b16', 'ed7a8281-3cc6-54fc-9b2e-8c78fd481881', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f092592-e346-595c-84e2-aa9df4f418c9', 'ed7a8281-3cc6-54fc-9b2e-8c78fd481881', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('443174f7-d442-50f4-b52b-c211a09a6433', 'ed7a8281-3cc6-54fc-9b2e-8c78fd481881', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb4258b7-f455-55dc-b2bf-95c61eb8effb', 'ed7a8281-3cc6-54fc-9b2e-8c78fd481881', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dd410c66-17df-5469-99ba-aefe496052c9', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage 1?
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
The adolescent lacks the ability to think abstractly.
12
Adolescents may have a deficit in their language ability.
13
The adolescent experiences a transition from reliance on his parents to independence.

11 ____ The adolescent lacks the ability to think abstractly.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3cfce3d-3b53-599c-96c3-fc7cd3506a95', 'dd410c66-17df-5469-99ba-aefe496052c9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffe59047-37d9-5f54-a755-dfb375716610', 'dd410c66-17df-5469-99ba-aefe496052c9', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bc7457f-2e93-5b37-a00e-6d30b7922a66', 'dd410c66-17df-5469-99ba-aefe496052c9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4fc00289-5ff2-5e95-b173-7d5374337532', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage 1?
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
The adolescent lacks the ability to think abstractly.
12
Adolescents may have a deficit in their language ability.
13
The adolescent experiences a transition from reliance on his parents to independence.

12 ____ Adolescents may have a deficit in their language ability.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3175841f-a73a-53db-aed1-d777284478a4', '4fc00289-5ff2-5e95-b173-7d5374337532', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be70911a-1c27-5e4c-8fb0-9a9b9d759636', '4fc00289-5ff2-5e95-b173-7d5374337532', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b820d43-981a-54b8-920d-8b9dc54da428', '4fc00289-5ff2-5e95-b173-7d5374337532', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c2f6d2d0-9d72-5efa-8009-ed2e8dca900f', '3e9c1c08-3422-5dab-9c85-c85ed2643f00', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage 1?
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
The adolescent lacks the ability to think abstractly.
12
Adolescents may have a deficit in their language ability.
13
The adolescent experiences a transition from reliance on his parents to independence.

13 ____ The adolescent experiences a transition from reliance on his parents to independence.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc8e56f4-6dda-5240-9f28-e6bbc2fa6391', 'c2f6d2d0-9d72-5efa-8009-ed2e8dca900f', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63ca8a48-8d18-528e-89f8-a0b5fbf14e6a', 'c2f6d2d0-9d72-5efa-8009-ed2e8dca900f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4996069f-dbaf-51cd-b67d-3e230d5b7b8b', 'c2f6d2d0-9d72-5efa-8009-ed2e8dca900f', 3, $md$NOT GIVEN$md$, false);

COMMIT;
