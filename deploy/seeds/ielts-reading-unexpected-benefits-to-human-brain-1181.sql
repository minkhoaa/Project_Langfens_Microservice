BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-unexpected-benefits-to-human-brain-1181'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-unexpected-benefits-to-human-brain-1181';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-unexpected-benefits-to-human-brain-1181';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-unexpected-benefits-to-human-brain-1181';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('fb1f20ad-c872-51ca-a12d-61ce88fd1dd9', 'ielts-reading-unexpected-benefits-to-human-brain-1181', $t$Unexpected Benefits to Human Brain$t$, $md$## Unexpected Benefits to Human Brain

Nguồn:
- Test: https://mini-ielts.com/1181/reading/unexpected-benefits-to-human-brain
- Solution: https://mini-ielts.com/1181/view-solution/reading/unexpected-benefits-to-human-brain$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 'fb1f20ad-c872-51ca-a12d-61ce88fd1dd9', 1, $t$Reading — Unexpected Benefits to Human Brain$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Unexpected Benefits to Human Brain

James Paul Gee, professor of education at the University of Wisconsin-Madison, played his first video game years ago when his six-year-old son Sam was playing Pajama Sam: No Need to Hide When It’s Dark Outside. He wanted to play the game so he could support Sam’s problem solving. Though Pajama Sam is not an “educational game”, it is replete with the types of problems psychologists study when they study thinking and learning. When he saw how well the game held Sam’s attention, he wondered what sort of beast a more mature video game might be.

Video and computer games, like many other popular, entertaining and addicting kid’s activities, are looked down upon by many parents as time-wasters, and worse, parents think that these games rot the brain. Violent video games are readily blamed by the media and some experts as the reason why some youth become violent or commit extreme anti-social behavior. Recent content analyses of video games show that as many as 89% of games contain some violent content, but there is no form of aggressive content for 70% of popular games. Many scientists and psychologists, like James Paul Gee, find that video games actually have many benefits – the main one being making kids smart . Video games may actually teach kids high-level thinking skills that they will need in the future.

“ Video games change your brain ,” according to University of Wisconsin psychologist Shawn Green. Video games change the brain’s physical structure the same way as do learning to read, playing the piano, or navigating using a map. Much like exercise can build muscle, the powerful combination of concentration and rewarding surges of neurotransmitters like dopamine, which strengthens neural circuits, can build the player’s brain.

Video games give your child’s brain a real workout . In many video games, the skills required to win involve abstract and high level thinking. These skills are not even taught at school. Some of the mental skills trained by video games include: following instructions, problem solving, logic, hand-eye coordination, fine motor and spatial skills. Research also suggests that people can learn iconic, spatial, and visual attention skills from video games. There have been even studies with adults showing that experience with video games is related to better surgical skills. Jacob Benjamin, doctor from Beth Israel Medical Center NY, found a direct link between skill at video gaming and skill at keyhole or laparoscopic surgery. Also, a reason given by experts as to why fighter pilots of today are more skillful is that this generation’s pilots are being weaned on video games.

The players learn to manage resources that are limited, and decide the best use of resources, the same way as in real life. In strategy games, for instance, while developing a city, an unexpected surprise like an enemy might emerge. This forces the player to be flexible and quickly change tactics. Sometimes the player does this almost every second of the game giving the brain a real workout. According to researchers at the University of Rochester, led by Daphne Bavelier, a cognitive scientist, games simulating stressful events such as those found in battle or action games could be a training tool for real-world situations . The study suggests that playing action video games primes the brain to make quick decisions. Video games can be used to train soldiers and surgeons, according to the study. Steven n, author of Everything Bad is Good For You: How Today’s Popular Culture, says gamers must deal with immediate problems while keeping their long-term goals on their horizon . Young gamers force themselves to read to get instructions, follow storylines of games, and get information from the game texts.

James Paul Gee, professor of education at the University of Wisconsin-Madison, says that playing a video game is similar to working through a science problem Like students in a laboratory, gamers must come up with a hypothesis. For example, players in some games constantly try out combinations of weapons and powers to use to defeat an enemy. If one does not work, they change hypothesis and try the next one. Video games are goal-ven experiences, says Gee, which are fundamental to learning . Also, using math skills is important to win in many games that involve quantitative analysis like managing resources. In higher levels of a game, players usually fail the first time around, but they keep on trying until they succeed and move on to the next level.

Many games are yed online and involve cooperation with other online players in order to win . Video and computer games also help children gain self-confidence and many games are based on history, city building, and governance and so on. Such games indirectly teach children about aspects of life on earth.

In an upcoming study in the journal Current Biology, authors Daphne Bavelier, Alexandre Pouget, and C. Shawn Green report that video games could provide a potent training regimen for speeding up reactions in many types of real-life situations. The researchers tested dozens of 18- to 25-year-olds who were not ordinarily video game players. They split the subjects into two groups. One group played 50 hours of the fast-paced action video games “Call of Duty 2” and “Unreal Tournament,” and the other group played 50 hours of the slow-moving strategy game “The Sims 2.” After this training period, all of the subjects were asked to make quick decisions in several tasks designed by the researchers. The action game players were up to 25 percent faster at coming to a conclusion and answered just as many questions correctly as their strategy game playing peers.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('128d544b-c1d5-57f5-9cd4-d701429fd084', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
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
1-4
on your answer sheet.
1
What is the main purpose of paragraph one
A
Introduction of professor James Paul Gee.
B
Introduction of the video game: Pajamas Sam.
C
Introduction of types of video games.
D
Introduction of the background of this passage.
2
What does the author want to express in the second paragraph
A
Video games are widely considered harmful for children’s brain.
B
Most violent video games are the direct reason of juvenile delinquency.
C
Even there is a certain proportion of violence in most video games; scientists and psychologists see its benefits of children’s intellectual abilities.
D
Many parents regard video games as time-wasters, which rot children’s brain.
Locate
3
What is correctly mentioned in paragraph four
A
Some schools use video games to teach students abstract and high level thinking.
B
Video games improves the brain ability in various aspects.
C
Some surgeons have better skills because they play more video games.
D
Skillful fighter pilots in this generation love to play video games.
Locate
4
What is the expectation of the experiment the three researchers did
A
Gamers have to make the best use of the limited resource.
B
Gamers with better math skills will win in the end.
C
Strategy game players have better ability to make quick decisions.
D
Video games help increase the speed of players’ reaction effectively.
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e6ee4d71-d3b6-5482-9b78-aad1d6d1cd92', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
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
1-4
on your answer sheet.
1
What is the main purpose of paragraph one
A
Introduction of professor James Paul Gee.
B
Introduction of the video game: Pajamas Sam.
C
Introduction of types of video games.
D
Introduction of the background of this passage.
2
What does the author want to express in the second paragraph
A
Video games are widely considered harmful for children’s brain.
B
Most violent video games are the direct reason of juvenile delinquency.
C
Even there is a certain proportion of violence in most video games; scientists and psychologists see its benefits of children’s intellectual abilities.
D
Many parents regard video games as time-wasters, which rot children’s brain.
Locate
3
What is correctly mentioned in paragraph four
A
Some schools use video games to teach students abstract and high level thinking.
B
Video games improves the brain ability in various aspects.
C
Some surgeons have better skills because they play more video games.
D
Skillful fighter pilots in this generation love to play video games.
Locate
4
What is the expectation of the experiment the three researchers did
A
Gamers have to make the best use of the limited resource.
B
Gamers with better math skills will win in the end.
C
Strategy game players have better ability to make quick decisions.
D
Video games help increase the speed of players’ reaction effectively.
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eb7a6929-bd12-5791-8c36-72229739dc86', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
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
1-4
on your answer sheet.
1
What is the main purpose of paragraph one
A
Introduction of professor James Paul Gee.
B
Introduction of the video game: Pajamas Sam.
C
Introduction of types of video games.
D
Introduction of the background of this passage.
2
What does the author want to express in the second paragraph
A
Video games are widely considered harmful for children’s brain.
B
Most violent video games are the direct reason of juvenile delinquency.
C
Even there is a certain proportion of violence in most video games; scientists and psychologists see its benefits of children’s intellectual abilities.
D
Many parents regard video games as time-wasters, which rot children’s brain.
Locate
3
What is correctly mentioned in paragraph four
A
Some schools use video games to teach students abstract and high level thinking.
B
Video games improves the brain ability in various aspects.
C
Some surgeons have better skills because they play more video games.
D
Skillful fighter pilots in this generation love to play video games.
Locate
4
What is the expectation of the experiment the three researchers did
A
Gamers have to make the best use of the limited resource.
B
Gamers with better math skills will win in the end.
C
Strategy game players have better ability to make quick decisions.
D
Video games help increase the speed of players’ reaction effectively.
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1bb98754-9de2-55d6-9be6-307d3c301e56', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
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
1-4
on your answer sheet.
1
What is the main purpose of paragraph one
A
Introduction of professor James Paul Gee.
B
Introduction of the video game: Pajamas Sam.
C
Introduction of types of video games.
D
Introduction of the background of this passage.
2
What does the author want to express in the second paragraph
A
Video games are widely considered harmful for children’s brain.
B
Most violent video games are the direct reason of juvenile delinquency.
C
Even there is a certain proportion of violence in most video games; scientists and psychologists see its benefits of children’s intellectual abilities.
D
Many parents regard video games as time-wasters, which rot children’s brain.
Locate
3
What is correctly mentioned in paragraph four
A
Some schools use video games to teach students abstract and high level thinking.
B
Video games improves the brain ability in various aspects.
C
Some surgeons have better skills because they play more video games.
D
Skillful fighter pilots in this generation love to play video games.
Locate
4
What is the expectation of the experiment the three researchers did
A
Gamers have to make the best use of the limited resource.
B
Gamers with better math skills will win in the end.
C
Strategy game players have better ability to make quick decisions.
D
Video games help increase the speed of players’ reaction effectively.
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('52615598-9229-5391-bdf5-0d25889061c4', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Do the following statement with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
Most video games are popular because of their violent content.
6
The action game players minimized the percentage of making mistakes in the experiment.
Locate
7
It would be a good idea for schools to apply video games in their classrooms.
8
Those People who are addicted to video games have lots of dopamine in their brains.
Locate

5 ____ Most video games are popular because of their violent content.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de02f3a8-fc59-5421-833b-2564fd4d2c14', '52615598-9229-5391-bdf5-0d25889061c4', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('191ffe35-6f68-5bfb-a78b-36ea54461097', '52615598-9229-5391-bdf5-0d25889061c4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddee0f6c-ac1c-5e3e-b131-01e0d1d45b17', '52615598-9229-5391-bdf5-0d25889061c4', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d9b5e2a-36f5-5feb-b207-4e1ab0a480e3', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Do the following statement with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
Most video games are popular because of their violent content.
6
The action game players minimized the percentage of making mistakes in the experiment.
Locate
7
It would be a good idea for schools to apply video games in their classrooms.
8
Those People who are addicted to video games have lots of dopamine in their brains.
Locate

6 ____ The action game players minimized the percentage of making mistakes in the experiment. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcb6857d-17aa-54c9-895e-f6cdaf6becab', '5d9b5e2a-36f5-5feb-b207-4e1ab0a480e3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5bda2b4-6def-5770-8bcc-c7e755c1fcb7', '5d9b5e2a-36f5-5feb-b207-4e1ab0a480e3', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb92af2d-82d0-554c-9e8c-c2ac78503d1d', '5d9b5e2a-36f5-5feb-b207-4e1ab0a480e3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b4b55e44-b9a2-53c5-addc-6edaab6346e8', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Do the following statement with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
Most video games are popular because of their violent content.
6
The action game players minimized the percentage of making mistakes in the experiment.
Locate
7
It would be a good idea for schools to apply video games in their classrooms.
8
Those People who are addicted to video games have lots of dopamine in their brains.
Locate

7 ____ It would be a good idea for schools to apply video games in their classrooms.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b83de29f-50f0-525f-8d2b-315440a8642e', 'b4b55e44-b9a2-53c5-addc-6edaab6346e8', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0dc53dac-974f-502c-9e68-e2aca170dd62', 'b4b55e44-b9a2-53c5-addc-6edaab6346e8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95fdc841-c119-59a0-a309-6400eda68ba0', 'b4b55e44-b9a2-53c5-addc-6edaab6346e8', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8cf04105-6bd4-5345-8cef-2707d6dda15e', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Do the following statement with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
Most video games are popular because of their violent content.
6
The action game players minimized the percentage of making mistakes in the experiment.
Locate
7
It would be a good idea for schools to apply video games in their classrooms.
8
Those People who are addicted to video games have lots of dopamine in their brains.
Locate

8 ____ Those People who are addicted to video games have lots of dopamine in their brains. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ccee4216-aa08-59b6-89dd-00c06f72db5b', '8cf04105-6bd4-5345-8cef-2707d6dda15e', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff272dbd-bd1d-58cf-b731-274b8d71a7bb', '8cf04105-6bd4-5345-8cef-2707d6dda15e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d41f3af4-f95a-55f5-93f3-e57320600947', '8cf04105-6bd4-5345-8cef-2707d6dda15e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('52d442a2-e7a9-58b5-97a8-04550eb801bb', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters,
A-F
, in boxes
9-13
on your answer sheet.
A
The writer’s opinion
B
James Paul Gee
C
Shawn Green
D
Daphne Bavelier
E
Steven Johnson
F
Jacob Benjamin
9
Video games as other daily life skills alter the brain’s physical structure.
Locate
10
Brain is ready to make decisions without hesitation when players are immersed in playing stressful games.
Locate
11
The purpose-motivated experience that video games offer plays an essential role in studying.
Locate
12
Players are good at tackling prompt issues with future intensions.
Locate
13
It helps children broaden their horizon in many aspects and gain self-confidence.
Locate

9 ____ Video games as other daily life skills alter the brain’s physical structure. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f20651a2-35a6-5faa-ad4b-6f7f118cad3a', '52d442a2-e7a9-58b5-97a8-04550eb801bb', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('285304a1-2fcc-500f-adf6-f36f0e18d2c0', '52d442a2-e7a9-58b5-97a8-04550eb801bb', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f170bf7-11a3-537d-b8ed-d0d49d7a8d80', '52d442a2-e7a9-58b5-97a8-04550eb801bb', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ce54424-81a7-59c1-898f-84883bd83822', '52d442a2-e7a9-58b5-97a8-04550eb801bb', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06332cc7-f442-5cd8-9aa9-c0da44f140b9', '52d442a2-e7a9-58b5-97a8-04550eb801bb', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('824f6c23-b1c4-5a7b-99b6-24428b14e24e', '52d442a2-e7a9-58b5-97a8-04550eb801bb', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5de21a9c-e7a6-5334-90fc-352369197465', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters,
A-F
, in boxes
9-13
on your answer sheet.
A
The writer’s opinion
B
James Paul Gee
C
Shawn Green
D
Daphne Bavelier
E
Steven Johnson
F
Jacob Benjamin
9
Video games as other daily life skills alter the brain’s physical structure.
Locate
10
Brain is ready to make decisions without hesitation when players are immersed in playing stressful games.
Locate
11
The purpose-motivated experience that video games offer plays an essential role in studying.
Locate
12
Players are good at tackling prompt issues with future intensions.
Locate
13
It helps children broaden their horizon in many aspects and gain self-confidence.
Locate

10 ____ Brain is ready to make decisions without hesitation when players are immersed in playing stressful games. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27e692fe-40cf-5811-9f86-f18eec502d26', '5de21a9c-e7a6-5334-90fc-352369197465', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb80e6e7-7db8-5df7-98cd-48b5cb8f7702', '5de21a9c-e7a6-5334-90fc-352369197465', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ce5b211-2d7e-5b7d-be3c-1c4d939141a3', '5de21a9c-e7a6-5334-90fc-352369197465', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3164d953-bcaf-5217-942f-d9e88354f3a0', '5de21a9c-e7a6-5334-90fc-352369197465', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dac73fa5-270c-5bb2-bd19-d23a5846d5dc', '5de21a9c-e7a6-5334-90fc-352369197465', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a125cf3f-06ee-5828-be6d-b272bbbc6bdd', '5de21a9c-e7a6-5334-90fc-352369197465', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('50a0c593-782a-5cdd-abbb-004232386409', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters,
A-F
, in boxes
9-13
on your answer sheet.
A
The writer’s opinion
B
James Paul Gee
C
Shawn Green
D
Daphne Bavelier
E
Steven Johnson
F
Jacob Benjamin
9
Video games as other daily life skills alter the brain’s physical structure.
Locate
10
Brain is ready to make decisions without hesitation when players are immersed in playing stressful games.
Locate
11
The purpose-motivated experience that video games offer plays an essential role in studying.
Locate
12
Players are good at tackling prompt issues with future intensions.
Locate
13
It helps children broaden their horizon in many aspects and gain self-confidence.
Locate

11 ____ The purpose-motivated experience that video games offer plays an essential role in studying. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41720d6f-45c3-54f4-a961-7ce832b73016', '50a0c593-782a-5cdd-abbb-004232386409', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f249ecc8-02b8-5a07-8cc1-06e2dee76efa', '50a0c593-782a-5cdd-abbb-004232386409', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f83af3d6-fdb9-5d52-b5eb-e365bd25c8dc', '50a0c593-782a-5cdd-abbb-004232386409', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1a3fde4-6cba-5fb4-a841-e7154bd43d14', '50a0c593-782a-5cdd-abbb-004232386409', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bed7a190-c20a-584c-b53f-b095371b6093', '50a0c593-782a-5cdd-abbb-004232386409', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90b228bb-aac3-5a8e-87fb-89d1b06d47b6', '50a0c593-782a-5cdd-abbb-004232386409', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3ee98ed9-a574-5db5-b339-25d9a15acd13', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters,
A-F
, in boxes
9-13
on your answer sheet.
A
The writer’s opinion
B
James Paul Gee
C
Shawn Green
D
Daphne Bavelier
E
Steven Johnson
F
Jacob Benjamin
9
Video games as other daily life skills alter the brain’s physical structure.
Locate
10
Brain is ready to make decisions without hesitation when players are immersed in playing stressful games.
Locate
11
The purpose-motivated experience that video games offer plays an essential role in studying.
Locate
12
Players are good at tackling prompt issues with future intensions.
Locate
13
It helps children broaden their horizon in many aspects and gain self-confidence.
Locate

12 ____ Players are good at tackling prompt issues with future intensions. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c831e85-3603-5c22-a85e-88e8ff398d22', '3ee98ed9-a574-5db5-b339-25d9a15acd13', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cefa11cb-827e-57c7-b23b-5b331a94ad57', '3ee98ed9-a574-5db5-b339-25d9a15acd13', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1e98674-6cb5-5f2e-8207-4eddfb7eeb3b', '3ee98ed9-a574-5db5-b339-25d9a15acd13', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11161a03-b3a9-571a-a0d5-142782d0157e', '3ee98ed9-a574-5db5-b339-25d9a15acd13', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a838fde-722c-5494-a87b-48b46ad9b620', '3ee98ed9-a574-5db5-b339-25d9a15acd13', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89d4cd33-9ac9-548e-9edd-0ea34b9f8fbd', '3ee98ed9-a574-5db5-b339-25d9a15acd13', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8c42a819-647f-544c-bc3c-2bf035e16e79', 'bcbe30de-a77a-59ca-8a7d-dfa8a29b9463', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Use the information in the passage to match the people (listed
A-F
) with opinions or deeds below.
Write the appropriate letters,
A-F
, in boxes
9-13
on your answer sheet.
A
The writer’s opinion
B
James Paul Gee
C
Shawn Green
D
Daphne Bavelier
E
Steven Johnson
F
Jacob Benjamin
9
Video games as other daily life skills alter the brain’s physical structure.
Locate
10
Brain is ready to make decisions without hesitation when players are immersed in playing stressful games.
Locate
11
The purpose-motivated experience that video games offer plays an essential role in studying.
Locate
12
Players are good at tackling prompt issues with future intensions.
Locate
13
It helps children broaden their horizon in many aspects and gain self-confidence.
Locate

13 ____ It helps children broaden their horizon in many aspects and gain self-confidence. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('364a1838-1dbc-54a3-bffc-54a3c0074ddb', '8c42a819-647f-544c-bc3c-2bf035e16e79', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9375fea4-c648-5eb5-9a3d-a19f9da81d83', '8c42a819-647f-544c-bc3c-2bf035e16e79', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c0acc72-76d1-50bd-b84f-591c37b86d51', '8c42a819-647f-544c-bc3c-2bf035e16e79', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a6b0961-00df-5489-ba8c-7e6323d92d37', '8c42a819-647f-544c-bc3c-2bf035e16e79', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b64b0729-cd2b-505b-8862-2c4f994c89f3', '8c42a819-647f-544c-bc3c-2bf035e16e79', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9fa468f-083d-5568-9275-5cec780350e5', '8c42a819-647f-544c-bc3c-2bf035e16e79', 6, $md$F$md$, false);

COMMIT;
