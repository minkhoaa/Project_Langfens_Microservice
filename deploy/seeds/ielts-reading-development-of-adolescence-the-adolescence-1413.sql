BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-development-of-adolescence-the-adolescence-1413'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-development-of-adolescence-the-adolescence-1413';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-development-of-adolescence-the-adolescence-1413';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-development-of-adolescence-the-adolescence-1413';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('297a7d0e-435c-5c25-a4a9-5fc78b4a3dfc', 'ielts-reading-development-of-adolescence-the-adolescence-1413', $t$Development of Adolescence (The Adolescence)$t$, $md$## Development of Adolescence (The Adolescence)

Nguồn:
- Test: https://mini-ielts.com/1413/reading/development-of-adolescence-the-adolescence
- Solution: https://mini-ielts.com/1413/view-solution/reading/development-of-adolescence-the-adolescence$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', '297a7d0e-435c-5c25-a4a9-5fc78b4a3dfc', 1, $t$Reading — Development of Adolescence (The Adolescence)$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Development of Adolescence (The Adolescence)

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
VALUES ('95a4533f-d0f5-5900-b6e9-ce6aff7ee52c', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

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
VALUES ('1b244259-1201-52df-87c4-0f3c5260234f', '95a4533f-d0f5-5900-b6e9-ce6aff7ee52c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('280415ca-0eaa-525e-8f5b-34b761891e5c', '95a4533f-d0f5-5900-b6e9-ce6aff7ee52c', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('930466c7-d871-59b1-a835-9c21a58d9fd1', '95a4533f-d0f5-5900-b6e9-ce6aff7ee52c', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('febeaaf5-e60b-566b-b888-554af4ca1fc1', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

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
VALUES ('542f53a8-5fde-58f3-bdd5-c035a463dfaf', 'febeaaf5-e60b-566b-b888-554af4ca1fc1', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf8cc3bc-e8fa-5f94-977c-accf934efb45', 'febeaaf5-e60b-566b-b888-554af4ca1fc1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5aa8cd7c-e69a-512a-9413-eb1840a6ed22', 'febeaaf5-e60b-566b-b888-554af4ca1fc1', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d1cb5dc3-6ab1-505c-918d-413923836491', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

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
VALUES ('6c6343d1-9f93-5fd9-ac2e-c94e702a71b4', 'd1cb5dc3-6ab1-505c-918d-413923836491', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6d7dfd7-fdba-5f06-bf2c-f7bcd263f9db', 'd1cb5dc3-6ab1-505c-918d-413923836491', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('778b97f5-3f20-5cac-9a81-7cc5ed023747', 'd1cb5dc3-6ab1-505c-918d-413923836491', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fe8d1882-9161-5196-9848-a37087c9f8b1', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

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
VALUES ('ddd03966-c934-5d5b-b225-ff3bf1f2caec', 'fe8d1882-9161-5196-9848-a37087c9f8b1', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae09967c-fb73-59e2-a7c3-61de0ce7da2c', 'fe8d1882-9161-5196-9848-a37087c9f8b1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae169dfa-6516-5070-a883-46c9b31ecba0', 'fe8d1882-9161-5196-9848-a37087c9f8b1', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8625ad85-bb5c-556d-b1dd-e15f2b12eeaf', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

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
VALUES ('f004f893-bdb1-53cf-8e34-11a09c7c5c65', '8625ad85-bb5c-556d-b1dd-e15f2b12eeaf', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87aef3be-2f91-502e-9bbd-581f336ff73c', '8625ad85-bb5c-556d-b1dd-e15f2b12eeaf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8766e1ad-d041-5be4-8a64-69564fb3be1e', '8625ad85-bb5c-556d-b1dd-e15f2b12eeaf', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a2188865-5838-5976-902a-8f0e4c38143a', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

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
VALUES ('1988fdbc-504f-5bc5-afed-eb908e60554c', 'a2188865-5838-5976-902a-8f0e4c38143a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03d48a29-7040-5457-ba4e-b0d5eb169d52', 'a2188865-5838-5976-902a-8f0e4c38143a', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('372fed88-422f-58ed-a8f1-81a0703e3bb3', 'a2188865-5838-5976-902a-8f0e4c38143a', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7b42e405-ba81-5720-aa29-855723212a97', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

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
VALUES ('09dc7504-4f65-52a8-b779-887b30e4821f', '7b42e405-ba81-5720-aa29-855723212a97', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bc11d8c-63e9-5826-82ef-6b9aa8fd3d7a', '7b42e405-ba81-5720-aa29-855723212a97', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7dac4acb-bb0f-515e-a4cb-ec599be55153', '7b42e405-ba81-5720-aa29-855723212a97', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e7acac5-0544-5156-9f57-e364acc0fdb0', '7b42e405-ba81-5720-aa29-855723212a97', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94ca14f9-36d1-5cfd-b918-268eb2ac4f4d', '7b42e405-ba81-5720-aa29-855723212a97', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7be6662a-8bc0-5c6d-a677-40d40c7437dd', '7b42e405-ba81-5720-aa29-855723212a97', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e6deb05f-1629-5d62-a596-02aaa6440a9d', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

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
VALUES ('0ba6bda0-4ea0-585f-8ca7-f961dafc1ae4', 'e6deb05f-1629-5d62-a596-02aaa6440a9d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a29a3cb-c9dd-5655-b4d7-2658a64ea35c', 'e6deb05f-1629-5d62-a596-02aaa6440a9d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('049da32c-3f78-5224-91bd-cc9b9428bbe3', 'e6deb05f-1629-5d62-a596-02aaa6440a9d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed46c1ee-063d-5c73-ad05-a53539c2f1d7', 'e6deb05f-1629-5d62-a596-02aaa6440a9d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('023f546f-247f-59a7-bc92-9f1eed03666d', 'e6deb05f-1629-5d62-a596-02aaa6440a9d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba2cd3af-667c-50bc-8213-e65b7d6ceb0d', 'e6deb05f-1629-5d62-a596-02aaa6440a9d', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5bd8f838-bc9e-5160-a1a4-92a5d755f740', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

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
VALUES ('a793304e-559d-5888-be59-d3069aac1d8b', '5bd8f838-bc9e-5160-a1a4-92a5d755f740', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18d017cf-c089-52c3-a262-5fd2c92dc693', '5bd8f838-bc9e-5160-a1a4-92a5d755f740', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43c6ec14-8413-5969-8ebc-cd967c291ffe', '5bd8f838-bc9e-5160-a1a4-92a5d755f740', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bb73d61-b67d-5d0f-9c51-ba886e48ad4a', '5bd8f838-bc9e-5160-a1a4-92a5d755f740', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60ac1780-286e-5df1-bec9-cf023df5948e', '5bd8f838-bc9e-5160-a1a4-92a5d755f740', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63daa028-5f44-5b58-a01d-50d618136938', '5bd8f838-bc9e-5160-a1a4-92a5d755f740', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c26bcfb3-b561-5526-81fd-3c0e73afac2e', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

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
VALUES ('615394a9-2a6d-5011-b46b-1553926c1e90', 'c26bcfb3-b561-5526-81fd-3c0e73afac2e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d7084af-dee7-51ad-9816-67e31be02456', 'c26bcfb3-b561-5526-81fd-3c0e73afac2e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dae8dad9-3f8e-552f-837a-97e8889d9ab7', 'c26bcfb3-b561-5526-81fd-3c0e73afac2e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('823b923b-2e8e-597f-9a54-d453e91b3045', 'c26bcfb3-b561-5526-81fd-3c0e73afac2e', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85eb223f-897d-58eb-ac34-d33759fdfaeb', 'c26bcfb3-b561-5526-81fd-3c0e73afac2e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c453c122-56b9-5603-8d22-df6325dc1e9a', 'c26bcfb3-b561-5526-81fd-3c0e73afac2e', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d6ab1517-ecee-5c61-905f-c3bc6bc63920', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

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
VALUES ('0c5dc45e-f9ba-512d-9f83-c11d7220fc3e', 'd6ab1517-ecee-5c61-905f-c3bc6bc63920', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('503b7e10-3c27-5b40-b8bf-fb401e106a0a', 'd6ab1517-ecee-5c61-905f-c3bc6bc63920', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f6755f8-435e-5a14-85a8-9beb5c3bfcad', 'd6ab1517-ecee-5c61-905f-c3bc6bc63920', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1859c84c-2510-51d1-839a-9f6221ed3163', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

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
VALUES ('429a22eb-86d1-5465-a9a5-e5b8680e4011', '1859c84c-2510-51d1-839a-9f6221ed3163', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('527a34ec-a069-5dcb-a318-fb084e67fd89', '1859c84c-2510-51d1-839a-9f6221ed3163', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a10be479-9525-50d7-8e0e-0fac09b4e17d', '1859c84c-2510-51d1-839a-9f6221ed3163', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('316e2e9c-20fd-5d0c-a21e-09ad9652f177', '6f1c5c8f-eadb-5db8-b802-635dfa6bb8d7', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

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
VALUES ('acb9fa09-f23d-59ba-a24d-617b3e0958e3', '316e2e9c-20fd-5d0c-a21e-09ad9652f177', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93b8f2e4-e101-5770-9f34-d0a47f496c06', '316e2e9c-20fd-5d0c-a21e-09ad9652f177', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d00e5859-e862-5d52-bcee-1c64311e6812', '316e2e9c-20fd-5d0c-a21e-09ad9652f177', 3, $md$NOT GIVEN$md$, false);

COMMIT;
