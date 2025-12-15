BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-compliance-or-noncompliance-for-children--1374'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-compliance-or-noncompliance-for-children--1374';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-compliance-or-noncompliance-for-children--1374';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-compliance-or-noncompliance-for-children--1374';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('f4c94128-30ae-5810-a997-3b254f9c40a2', 'ielts-reading-compliance-or-noncompliance-for-children--1374', $t$Compliance Or Noncompliance For Children$t$, $md$## Compliance Or Noncompliance For Children

Nguồn:
- Test: https://mini-ielts.com/1374/reading/compliance-or-noncompliance-for-children-
- Solution: https://mini-ielts.com/1374/view-solution/reading/compliance-or-noncompliance-for-children-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2430d192-65a9-5df3-abc7-794af4a2d9de', 'f4c94128-30ae-5810-a997-3b254f9c40a2', 1, $t$Reading — Compliance Or Noncompliance For Children$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Compliance Or Noncompliance For Children

A

Many Scientists believe that socialization takes a long process, while compliance is the outset of it. Accordingly, compliance for the education of children is the priority . Motivationally distinct forms of child compliance, mutually positive affect, and maternal control, observed in 3 control contexts in 103 dyads of mothers and their 26-41-month-old children, were examined as correlates of internalization, assessed using observations of children while alone with prohibited temptations and maternal ratings. One form of compliance (committed compliance), when the child appeared committed wholeheartedly to the maternal agenda and eager to endorse and accept it, was emphasized. Mother-child mutually positive affect was both a predictor and a concomitant of committed compliance. Children who shared positive effect with their mothers showed a high level of committed compliance and were also more internalized. Differences and similarities between children’s compliance with requests and prohibitions (“Do” vs. “Don’t” demand contexts) were also explored. Maternal “Dos” appeared more challenging to toddlers than the “Don’ts.” Some individual coherence of behavior was also found across both demand contexts. The implication of committed compliance for emerging internalized regulators of conduct is discussed.

B

A number of parents were not easy to be aware of the compliance, some even overlooked their children’s noncompliance. Despite good education, these children did not follow the words from their parents on several occasion, especially boys in certain ages. Fortunately, this rate was acceptable, some parents could be patient with the noncompliance. Someone held that noncompliance is probably not a wrong thing. In order to determine the effects of different parental disciplinary techniques on young children’s compliance and noncompliance, mothers were trained to observe emotional incidents involving their own toddler-aged children. Reports of disciplinary encounters were analyzed in terms of the types of discipline used (reasoning, verbal prohibition, physical coercion, love withdrawal, and combinations thereof) and children’s responses to that discipline (compliance/ noncompliance and avoidance). The relation between compliance/ noncompliance and type of misdeed (harm to persons, harm to property, and lapses of self-control) was also analyzed. Results indicated that love withdrawal combined with other techniques was most effective in securing children’s compliance and that its effectiveness was not a function of the type of technique with which it was combined. Avoidant responses and affective reunification with the parent were more likely to follow love withdrawal than any other technique. Physical coercion was somewhat less effective than love withdrawal, while reasoning and verbal prohibition were not at all effective except when both were combined with physical coercion.

C

“Noncompliant Children sometimes prefer to say to directly as they were younger, they are easy to deal with the relationship with contemporaries . When they are growing up. During the period that children are getting elder, who may learn to use more advanced approaches for their noncompliance. They are more skillful to negotiate or give reasons for refusal rather than show their opposite idea to parents directly.” Said Henry Porter, a scholar working in Psychology Institute of UK. He indicated that noncompliance means growth in some way, may have benefit for children. Many Experts held different viewpoints in recent years, they tried drilling compliance into children. His collaborator Wallace Friesen believed that Organizing a child’s daily activities so that they occur in the same order each day as much as possible. This first strategy for defiant children is ultimately the most important. Developing a routine helps a child to know what to expect and increases the chances that he or she will comply with things such as chores, homework, and hygiene requests. When undesirable activities occur in the same order at optimal times during the day, they become habits that are not questioned but done without thought.

Chances are that you have developed some type of routine for yourself in terms of showering, cleaning your house, or doing other types of work. You have an idea in your mind when you will do these things on a regular basis and this helps you to know what to expect. In fact, you have probably already been using most of these compliance strategies for yourself without realizing it. For children, without setting these expectations on a daily basis by making them part of a regular routine , they can become very upset. Just like adults, children think about what they plan to do that day and expect to be able to do what they want. So, when you come along and ask them to do something they weren’t already planning to do that day, this can result in automatic refusals and other undesirable defiant behaviors. However, by using this compliance strategy with defiant children, these activities are done almost every day in the same general order and the child expects to already do them.

D

Doctor Steven Walson addressed that organizing fun activities to occur after frequently refused activities. This strategy also works as a positive reinforcer when the child complies with your requests. By arranging your day so that things often refused to occur right before highly preferred activities, you are able to eliminate defiant behavior and motivate your child’s behavior of doing the undesirable activity. This is not to be presented in a way that the preferred activity is only allowed if a defiant child does the non-preferred activity. However, you can word your request in a way so that your child assumes that you have to do the non-preferred activity before moving on to the next preferred activity. For example, you do not want to say something such as, “If you clean your room we can play a game.” Instead of the word your request like this, “As soon as you are done cleaning your room we will be able to play that really fun game you wanted to play.”

E

Psychologist Paul Edith insisted praise is the best way to make children comply with. This is probably a common term you are used to hearing by now. If you praise your child’s behavior, he or she will be more likely to do that behavior. So, it is essential to use praise when working with defiant children. It also provides your child with positive attention. However, it is important to know how to praise children in a way that encourages future automatic reinforcement for your child when doing a similar behavior.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5268efe4-fd30-5fe5-9b57-e9089e945976', '2430d192-65a9-5df3-abc7-794af4a2d9de', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-5
on your answer sheet.
1.
The children, especially boys received good education may
A
always comply with their parents’ words
B
be good at math
C
have a high score at school
D
disobey their parents’ order sometimes
2.
Face to their children’s compliance and noncompliance, parents
A
must be aware of the compliance
B
ask for help from their teachers
C
some of them may ignore their noncompliance
D
pretend not to see
3.
According to Henry Porter, noncompliance for children
A
are entirely harmful
B
may have positive effects
C
needs medicine assistance
D
should be treated by an expert doctor
4.
When children are growing up, they
A
always try to directly say no
B
are more skillful to negotiate
C
learn to cheat instead of noncompliance
D
tend to keep silent
5.
Which is the possible reaction the passage mentioned for elder children and younger ones if they don’t want to comply with the order
A
elder children prefer to refuse directly
B
elder ones refuse to answer
C
younger children may reject directly
D
younger ones may save any words

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('81c26490-b7fd-57c6-96ba-50e83fc35c36', '2430d192-65a9-5df3-abc7-794af4a2d9de', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-5
on your answer sheet.
1.
The children, especially boys received good education may
A
always comply with their parents’ words
B
be good at math
C
have a high score at school
D
disobey their parents’ order sometimes
2.
Face to their children’s compliance and noncompliance, parents
A
must be aware of the compliance
B
ask for help from their teachers
C
some of them may ignore their noncompliance
D
pretend not to see
3.
According to Henry Porter, noncompliance for children
A
are entirely harmful
B
may have positive effects
C
needs medicine assistance
D
should be treated by an expert doctor
4.
When children are growing up, they
A
always try to directly say no
B
are more skillful to negotiate
C
learn to cheat instead of noncompliance
D
tend to keep silent
5.
Which is the possible reaction the passage mentioned for elder children and younger ones if they don’t want to comply with the order
A
elder children prefer to refuse directly
B
elder ones refuse to answer
C
younger children may reject directly
D
younger ones may save any words

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4b90a547-d1f5-5bfe-b811-aa405fa2a003', '2430d192-65a9-5df3-abc7-794af4a2d9de', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-5
on your answer sheet.
1.
The children, especially boys received good education may
A
always comply with their parents’ words
B
be good at math
C
have a high score at school
D
disobey their parents’ order sometimes
2.
Face to their children’s compliance and noncompliance, parents
A
must be aware of the compliance
B
ask for help from their teachers
C
some of them may ignore their noncompliance
D
pretend not to see
3.
According to Henry Porter, noncompliance for children
A
are entirely harmful
B
may have positive effects
C
needs medicine assistance
D
should be treated by an expert doctor
4.
When children are growing up, they
A
always try to directly say no
B
are more skillful to negotiate
C
learn to cheat instead of noncompliance
D
tend to keep silent
5.
Which is the possible reaction the passage mentioned for elder children and younger ones if they don’t want to comply with the order
A
elder children prefer to refuse directly
B
elder ones refuse to answer
C
younger children may reject directly
D
younger ones may save any words

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('73bf6a5d-b59a-5fba-8d4b-72099e21f9aa', '2430d192-65a9-5df3-abc7-794af4a2d9de', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-5
on your answer sheet.
1.
The children, especially boys received good education may
A
always comply with their parents’ words
B
be good at math
C
have a high score at school
D
disobey their parents’ order sometimes
2.
Face to their children’s compliance and noncompliance, parents
A
must be aware of the compliance
B
ask for help from their teachers
C
some of them may ignore their noncompliance
D
pretend not to see
3.
According to Henry Porter, noncompliance for children
A
are entirely harmful
B
may have positive effects
C
needs medicine assistance
D
should be treated by an expert doctor
4.
When children are growing up, they
A
always try to directly say no
B
are more skillful to negotiate
C
learn to cheat instead of noncompliance
D
tend to keep silent
5.
Which is the possible reaction the passage mentioned for elder children and younger ones if they don’t want to comply with the order
A
elder children prefer to refuse directly
B
elder ones refuse to answer
C
younger children may reject directly
D
younger ones may save any words

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('694a4b33-c02b-5705-8f52-f37c9a02bcc3', '2430d192-65a9-5df3-abc7-794af4a2d9de', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
1-5
on your answer sheet.
1.
The children, especially boys received good education may
A
always comply with their parents’ words
B
be good at math
C
have a high score at school
D
disobey their parents’ order sometimes
2.
Face to their children’s compliance and noncompliance, parents
A
must be aware of the compliance
B
ask for help from their teachers
C
some of them may ignore their noncompliance
D
pretend not to see
3.
According to Henry Porter, noncompliance for children
A
are entirely harmful
B
may have positive effects
C
needs medicine assistance
D
should be treated by an expert doctor
4.
When children are growing up, they
A
always try to directly say no
B
are more skillful to negotiate
C
learn to cheat instead of noncompliance
D
tend to keep silent
5.
Which is the possible reaction the passage mentioned for elder children and younger ones if they don’t want to comply with the order
A
elder children prefer to refuse directly
B
elder ones refuse to answer
C
younger children may reject directly
D
younger ones may save any words

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1b9b1739-8bfa-52a0-9909-270d8413c0b2', '2430d192-65a9-5df3-abc7-794af4a2d9de', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Look at the following people and list of statements below.
Match each person with the correct statement.
Write the correct letter
A-G
in boxes
6-9
on your answer sheet.
6
Henry Porter
7
Wallace Friesen
8
Steven Walson
9
Paul Edith
List of statements
A
children of all ages will indirectly show noncompliance
B
elder children tend to negotiate rather than show noncompliance
C
converse behavior means noncompliance
D
organizing fun activities to occur after frequently refused activities
E
organizing child’s daily activities in the same order as much as possible.
F
use praise in order to make children compliant
G
take the children to school at an early age

6 ____ Henry Porter$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bd2a3e3-5d45-59cf-b8ec-e9e439e6db80', '1b9b1739-8bfa-52a0-9909-270d8413c0b2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da561bdb-3df6-5090-b8db-b0ed1c1601c5', '1b9b1739-8bfa-52a0-9909-270d8413c0b2', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('356b39b7-fc7c-50ed-b293-b73596b536ae', '1b9b1739-8bfa-52a0-9909-270d8413c0b2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7aa1c45c-4f30-53ed-98e4-7edd45f87196', '1b9b1739-8bfa-52a0-9909-270d8413c0b2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eee13b1d-63d3-55be-b3e8-efd6f20c098e', '1b9b1739-8bfa-52a0-9909-270d8413c0b2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a1002ff-3fcc-5ff3-a03f-fd8c3ac926af', '1b9b1739-8bfa-52a0-9909-270d8413c0b2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79bbb8bf-e6ed-50a5-addf-10babf5feb7d', '1b9b1739-8bfa-52a0-9909-270d8413c0b2', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ab1d99a5-c460-5dbe-8284-defd88fc1cb8', '2430d192-65a9-5df3-abc7-794af4a2d9de', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Look at the following people and list of statements below.
Match each person with the correct statement.
Write the correct letter
A-G
in boxes
6-9
on your answer sheet.
6
Henry Porter
7
Wallace Friesen
8
Steven Walson
9
Paul Edith
List of statements
A
children of all ages will indirectly show noncompliance
B
elder children tend to negotiate rather than show noncompliance
C
converse behavior means noncompliance
D
organizing fun activities to occur after frequently refused activities
E
organizing child’s daily activities in the same order as much as possible.
F
use praise in order to make children compliant
G
take the children to school at an early age

7 ____ Wallace Friesen$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77946a54-ef94-59db-bf9b-ba517d4f8b24', 'ab1d99a5-c460-5dbe-8284-defd88fc1cb8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce94eaa9-4e35-5989-9817-5d7b29061bfa', 'ab1d99a5-c460-5dbe-8284-defd88fc1cb8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18f96ae8-01c6-5b97-a492-76c8af4b6ce0', 'ab1d99a5-c460-5dbe-8284-defd88fc1cb8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aaf17227-8276-55bb-aab4-a2e46ffc7f82', 'ab1d99a5-c460-5dbe-8284-defd88fc1cb8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5009826a-d2e5-52af-bd30-cb357fd1363f', 'ab1d99a5-c460-5dbe-8284-defd88fc1cb8', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69a8be29-90a3-5b0b-9d31-f62b9fce518c', 'ab1d99a5-c460-5dbe-8284-defd88fc1cb8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffecd1f5-9632-5000-98d3-d86817e23715', 'ab1d99a5-c460-5dbe-8284-defd88fc1cb8', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ec353032-a7d5-5157-a7ac-27fa3138596c', '2430d192-65a9-5df3-abc7-794af4a2d9de', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Look at the following people and list of statements below.
Match each person with the correct statement.
Write the correct letter
A-G
in boxes
6-9
on your answer sheet.
6
Henry Porter
7
Wallace Friesen
8
Steven Walson
9
Paul Edith
List of statements
A
children of all ages will indirectly show noncompliance
B
elder children tend to negotiate rather than show noncompliance
C
converse behavior means noncompliance
D
organizing fun activities to occur after frequently refused activities
E
organizing child’s daily activities in the same order as much as possible.
F
use praise in order to make children compliant
G
take the children to school at an early age

8 ____ Steven Walson$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e062aac8-ace4-5c9a-84b4-5006e659c7ca', 'ec353032-a7d5-5157-a7ac-27fa3138596c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8adca8c7-82c6-5173-8a46-9a242ccf62e0', 'ec353032-a7d5-5157-a7ac-27fa3138596c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85c25d32-ff51-582b-b49f-c3942c014845', 'ec353032-a7d5-5157-a7ac-27fa3138596c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8969baee-5d09-5b2a-97be-69201ac2a3ed', 'ec353032-a7d5-5157-a7ac-27fa3138596c', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b2a55cb-ba2c-586a-b2d7-85b72f3039a9', 'ec353032-a7d5-5157-a7ac-27fa3138596c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1253391d-6054-5d80-a512-c57d9106c46e', 'ec353032-a7d5-5157-a7ac-27fa3138596c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cb035a4-c8bb-5ef8-bb75-298143cc9d4d', 'ec353032-a7d5-5157-a7ac-27fa3138596c', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d881697c-7273-5fe7-8ebb-4d4568c7aeaa', '2430d192-65a9-5df3-abc7-794af4a2d9de', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Look at the following people and list of statements below.
Match each person with the correct statement.
Write the correct letter
A-G
in boxes
6-9
on your answer sheet.
6
Henry Porter
7
Wallace Friesen
8
Steven Walson
9
Paul Edith
List of statements
A
children of all ages will indirectly show noncompliance
B
elder children tend to negotiate rather than show noncompliance
C
converse behavior means noncompliance
D
organizing fun activities to occur after frequently refused activities
E
organizing child’s daily activities in the same order as much as possible.
F
use praise in order to make children compliant
G
take the children to school at an early age

9 ____ Paul Edith$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f385aca-1228-56de-955f-ce369addea4d', 'd881697c-7273-5fe7-8ebb-4d4568c7aeaa', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9f738f6-8a16-573b-a29d-0de7a5806679', 'd881697c-7273-5fe7-8ebb-4d4568c7aeaa', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a50a793-ab6b-5a46-b608-bee772233284', 'd881697c-7273-5fe7-8ebb-4d4568c7aeaa', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('088cb612-2704-5c4a-9425-7cd2139d7d87', 'd881697c-7273-5fe7-8ebb-4d4568c7aeaa', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f04b1cf-c950-5eca-bf29-57225746f5a1', 'd881697c-7273-5fe7-8ebb-4d4568c7aeaa', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46a4327f-4132-5b91-a195-15f2371a7780', 'd881697c-7273-5fe7-8ebb-4d4568c7aeaa', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae10747d-3684-5289-b6f5-1dfb94b3bfa0', 'd881697c-7273-5fe7-8ebb-4d4568c7aeaa', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d55f224d-43ac-54db-afca-e3b74a66b584', '2430d192-65a9-5df3-abc7-794af4a2d9de', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Socialization takes a long process, while compliance is the beginning of it.
11
Many parents were difficult to be aware of compliance or noncompliance.
12
Noncompliant Children are simple to deal with the relationship with the people at the same age when they are growing up.
13
Experts never tried drilling compliance into children.
14
Psychologist Paul Edith negated the importance that knowing how to praise children in an encouraging way.

10 ____ Socialization takes a long process, while compliance is the beginning of it.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0210742a-0ef6-5d5a-b117-9a3c96acfbb3', 'd55f224d-43ac-54db-afca-e3b74a66b584', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b62f72a4-d362-52c9-b4d6-d03be3ca0f5e', 'd55f224d-43ac-54db-afca-e3b74a66b584', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b01c84f5-65f7-59de-b6ff-ba0cba23a2bc', 'd55f224d-43ac-54db-afca-e3b74a66b584', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8b172093-f827-5713-a663-9e1d91a4bcbb', '2430d192-65a9-5df3-abc7-794af4a2d9de', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Socialization takes a long process, while compliance is the beginning of it.
11
Many parents were difficult to be aware of compliance or noncompliance.
12
Noncompliant Children are simple to deal with the relationship with the people at the same age when they are growing up.
13
Experts never tried drilling compliance into children.
14
Psychologist Paul Edith negated the importance that knowing how to praise children in an encouraging way.

11 ____ Many parents were difficult to be aware of compliance or noncompliance.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8164f6b-b33f-5c94-8e86-d78038b4fb6b', '8b172093-f827-5713-a663-9e1d91a4bcbb', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('421b38f4-6ccc-5c05-91ca-4ec5cc91ef23', '8b172093-f827-5713-a663-9e1d91a4bcbb', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3ce3df6-a802-50b7-9e1d-e0bd2f448372', '8b172093-f827-5713-a663-9e1d91a4bcbb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('84bad7b1-7bad-57d1-8353-bed574007d64', '2430d192-65a9-5df3-abc7-794af4a2d9de', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Socialization takes a long process, while compliance is the beginning of it.
11
Many parents were difficult to be aware of compliance or noncompliance.
12
Noncompliant Children are simple to deal with the relationship with the people at the same age when they are growing up.
13
Experts never tried drilling compliance into children.
14
Psychologist Paul Edith negated the importance that knowing how to praise children in an encouraging way.

12 ____ Noncompliant Children are simple to deal with the relationship with the people at the same age when they are growing up.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b29b9402-bb91-5aca-8dee-1cdd8cffd4e5', '84bad7b1-7bad-57d1-8353-bed574007d64', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f84a84f-9c5d-5765-b1cb-32f09559786c', '84bad7b1-7bad-57d1-8353-bed574007d64', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4c08c72-4a78-5b2d-9c5f-e0916479bdbc', '84bad7b1-7bad-57d1-8353-bed574007d64', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f017d086-17a7-5c1f-a4ba-1b124c2f2e30', '2430d192-65a9-5df3-abc7-794af4a2d9de', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Socialization takes a long process, while compliance is the beginning of it.
11
Many parents were difficult to be aware of compliance or noncompliance.
12
Noncompliant Children are simple to deal with the relationship with the people at the same age when they are growing up.
13
Experts never tried drilling compliance into children.
14
Psychologist Paul Edith negated the importance that knowing how to praise children in an encouraging way.

13 ____ Experts never tried drilling compliance into children.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74a0becb-6d79-5c3b-976f-cda9a09fd4b2', 'f017d086-17a7-5c1f-a4ba-1b124c2f2e30', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d39d341f-5543-591a-bd26-ddffc677527d', 'f017d086-17a7-5c1f-a4ba-1b124c2f2e30', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b33d3eda-9597-5d0d-a5e4-0954d092a9d9', 'f017d086-17a7-5c1f-a4ba-1b124c2f2e30', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ed9febe3-c0f4-5de3-91cc-43ff21cf1f14', '2430d192-65a9-5df3-abc7-794af4a2d9de', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Socialization takes a long process, while compliance is the beginning of it.
11
Many parents were difficult to be aware of compliance or noncompliance.
12
Noncompliant Children are simple to deal with the relationship with the people at the same age when they are growing up.
13
Experts never tried drilling compliance into children.
14
Psychologist Paul Edith negated the importance that knowing how to praise children in an encouraging way.

14 ____ Psychologist Paul Edith negated the importance that knowing how to praise children in an encouraging way.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61084cd4-ebd4-5b77-8a4f-3fc0f7ffd937', 'ed9febe3-c0f4-5de3-91cc-43ff21cf1f14', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f8f061d-b25b-53c9-baae-584727b19790', 'ed9febe3-c0f4-5de3-91cc-43ff21cf1f14', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fa71b0e-f8a6-58d5-9a4c-5f1b2f6b6602', 'ed9febe3-c0f4-5de3-91cc-43ff21cf1f14', 3, $md$NOT GIVEN$md$, false);

COMMIT;
