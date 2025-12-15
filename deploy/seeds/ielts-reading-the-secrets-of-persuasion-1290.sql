BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-secrets-of-persuasion-1290'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-secrets-of-persuasion-1290';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-secrets-of-persuasion-1290';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-secrets-of-persuasion-1290';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('3af8ad38-bf27-5bae-a0e4-c720d31ff05b', 'ielts-reading-the-secrets-of-persuasion-1290', $t$The Secrets of Persuasion$t$, $md$## The Secrets of Persuasion

Nguồn:
- Test: https://mini-ielts.com/1290/reading/the-secrets-of-persuasion
- Solution: https://mini-ielts.com/1290/view-solution/reading/the-secrets-of-persuasion$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7d6aa12e-8622-5e6b-b193-8880ebdec91b', '3af8ad38-bf27-5bae-a0e4-c720d31ff05b', 1, $t$Reading — The Secrets of Persuasion$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Secrets of Persuasion

A

Our mother may have told you the secret to getting what you ask for was to say please. The reality is rather more surprising. Adam Dudding talks to a psychologist who has made a life’s work from the science of persuasion. Some scientists peer at things through high-powered microscopes. Others goad rats through mazes or mix bubbling fluids in glass beakers. Robert Cialdini, for his part, does curious things with towels and believes that by doing so he is discovering important insights into how society works.

B

Cialdini’s towel experiments (more of them later), are part of his research into how we persuade others to say yes. He wants to know why some people have a knack for bending the will of others, be it a telephone cold-caller talking to you about timeshares, or a parent whose children are compliant even without threats of extreme violence. While he’s anxious not to be seen as the man who’s written the bible for snake-oil salesmen, for decades the Arizona State University social psychology professor has been creating systems for the principles and methods of persuasion and writing bestsellers about them. Some people seem to be born with the skills; Cialdini’s claim is that by applying a little science, even those of us who aren’t should be able to get our own way more often. “All my life I’ve been an easy mark for the blandishment of salespeople and fundraisers and I’d always wondered why they could get me to buy things I didn’t want and give to causes I hadn’t heard of,” says Cialdini on the phone from London, where his is plugging his latest book.

C

He found that laboratory experiments on the psychology of persuasion were telling only part of the story, so he began to research influence in the real world, enrolling in sales-training programmes: “I learnt how to sell automobiles from a lot, how to sell insurance from an office, how to sell encyclopedias door to door.” He concluded there were six general “principles of influence” and has since put them to the test under slightly more scientific conditions. Most recently, that has meant messing about with towels. Many hotels leave a little card in each bathroom asking guests to reuse towels and thus conserve water and electricity and reduce pollution. Cialdini and his colleagues wanted to test the relative effectiveness of different words on those cards. Would guests be motivated to co-operate simply because it would help save the planet, or were other factors more compelling? To test this, the researchers changed the card’s message from an environmental one to the simple (and truthful) statement that the majority of guests at the hotel had reused their towel at least once. Guests given this message were 26% more likely to reuse their towels than those given the old message. In Cialdini’s book “Yes! 50 Secrets from the Science of Persuasion” , co-written with another social scientist and a business consultant, he explains that guests were responding to the persuasive force of “social proof”, the idea that our decisions are strongly influenced by what we believe other people like us are doing.

D

So much for towels. Cialdini has also learnt a lot from confectionery. Yes! Cites the work of New Jersey behavioural scientist David Strohmetz, who wanted to see how restaurant patrons would respond to ridiculously small favour from their food server, in the form of after-dinner chocolate for each diner. The secret, it seems, is in how you give the chocolate. When the chocolates arrived in a heap with the bill, tips went up a miserly 3% compared to when no chocolate was given. But when the chocolates were dropped individually in front of each diner, tips went up 14%. The scientific breakthrough, though, came when the waitress gave each diner one chocolate, headed away from the table then doubled back to give them one more each as if such generosity had only just occurred to her. Tips went up 23%. This is “reciprocity” in action: we want to return favours done to us, often without bothering to calculate the relative value of what is being received and given.

E

Geeling Ng, operations manager at Auckland’s Soul Bar, says she’s never heard of Kiwi waiting staff using such a cynical trick, not least because New Zealand tipping culture is so different from that of the US: “If you did that in New Zealand, as diners were leaving they’d say ‘can we have some more?” ‘ But she certainly understands the general principle of reciprocity. The way to a diner’s heart is “to give them something they’re not expecting in the way of service. It might be something as small as leaving a mint on their plate, or it might be remembering that last time they were in they wanted their water with no ice and no lemon. “In America, it would translate into an instant tip. In New Zealand, it translates into a huge smile and thanks to you.” And no doubt, return visits.

F

Reciprocity: People want to give back to those who have given to them. The trick here is to get in first. That’s why charities put a crummy pen inside a mailout, and why smiling women in supermarkets hand out dollops of free food. Scarcity: People want more of things they can have less of. Advertisers ruthlessly exploit scarcity (“limit four per customer”, “sale must end soon”), and Cialdini suggests parents do too: “Kids want things that are less available, so say ‘this is an unusual opportunity; you can only have this for a certain time’.”

G

Authority: We trust people who know what they’re talking about. So inform people honestly of your credentials before you set out to influence them. “You’d be surprised how many people fail to do that,” says Cialdini. “They feel it’s impolite to talk about their expertise.” In one study, therapists whose patients wouldn’t do their exercises were advised to display their qualification certificates prominently. They did and experienced an immediate leap in patient compliance.

H

Commitment/consistency: We want to act in a way that is consistent with the commitments we have already made. Exploit this to get a higher sign-up rate when soliciting charitable donations. First, ask workmates if they think they will sponsor you on your egg-and-spoon marathon. Later, return with the sponsorship form to those who said yes and remind them of their earlier commitment.

I

Linking: We say yes more often to people we like. Obvious enough, but reasons for “linking” can be weird. In one study, people were sent survey forms and asked to return them to a named researcher. When the researcher gave a fake name resembling that of the subject (eg, Cynthia Johnson is sent a survey by “Cindy Johansen”), surveys were twice as likely to be completed. We favour people who resemble us, even if the resemblance is as minor as the sound of their name.

J

Social proof: We decide what to do by looking around to see what others just like us are doing. Useful for parents, says Cialdini. “Find groups of children who are behaving in a way that you would like your child to, because the child looks to the side, rather than at you.” More perniciously, social proof is the force underpinning the competitive materialism of “keeping up with the Joneses”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f4bd1a17-bf43-5d1b-8cf5-191f94b9972f', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Choose the correct letter
A
,
B
,
C
or
D
.
1 . The main purpose of
Cialdini’
s research of writing is to
A
explain the reason way researcher should investigate in person
B
explore the secret that why some people become the famous salesperson
C
help people to sale products
D
prove maybe there is a science in the psychology of persuasion
2. Which of the statement is CORRECT according to
Cialdini’
s research methodology
A
he checked data in a lot of latest books
B
he conducted this experiment in the laboratory
C
he interviewed and contract with many salespeople
D
he made lot phone calls collecting what he wants to know
3. Which of the following is CORRECT according to towel experiment in the passage?
A
Different hotel guests act in a different response
B
Most guests act by the idea of environment preservation
C
more customers tend to cooperate as the message requires than simply act environmentally
D
people tend to follow the hotel’s original message more
4. Which of the following is CORRECT according to the candy shop experiment in the passage?
A
Presenting way affects diner’s tips
B
Regular customer gives tips more than irregulars
C
People give tips only when offered chocolate
D
Chocolate with bill got higher tips

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e20a6b17-5ecf-507c-b7dc-3c3ebfb19796', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Choose the correct letter
A
,
B
,
C
or
D
.
1 . The main purpose of
Cialdini’
s research of writing is to
A
explain the reason way researcher should investigate in person
B
explore the secret that why some people become the famous salesperson
C
help people to sale products
D
prove maybe there is a science in the psychology of persuasion
2. Which of the statement is CORRECT according to
Cialdini’
s research methodology
A
he checked data in a lot of latest books
B
he conducted this experiment in the laboratory
C
he interviewed and contract with many salespeople
D
he made lot phone calls collecting what he wants to know
3. Which of the following is CORRECT according to towel experiment in the passage?
A
Different hotel guests act in a different response
B
Most guests act by the idea of environment preservation
C
more customers tend to cooperate as the message requires than simply act environmentally
D
people tend to follow the hotel’s original message more
4. Which of the following is CORRECT according to the candy shop experiment in the passage?
A
Presenting way affects diner’s tips
B
Regular customer gives tips more than irregulars
C
People give tips only when offered chocolate
D
Chocolate with bill got higher tips

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc05bc7f-c024-5c62-bc29-f4b95abcefab', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Choose the correct letter
A
,
B
,
C
or
D
.
1 . The main purpose of
Cialdini’
s research of writing is to
A
explain the reason way researcher should investigate in person
B
explore the secret that why some people become the famous salesperson
C
help people to sale products
D
prove maybe there is a science in the psychology of persuasion
2. Which of the statement is CORRECT according to
Cialdini’
s research methodology
A
he checked data in a lot of latest books
B
he conducted this experiment in the laboratory
C
he interviewed and contract with many salespeople
D
he made lot phone calls collecting what he wants to know
3. Which of the following is CORRECT according to towel experiment in the passage?
A
Different hotel guests act in a different response
B
Most guests act by the idea of environment preservation
C
more customers tend to cooperate as the message requires than simply act environmentally
D
people tend to follow the hotel’s original message more
4. Which of the following is CORRECT according to the candy shop experiment in the passage?
A
Presenting way affects diner’s tips
B
Regular customer gives tips more than irregulars
C
People give tips only when offered chocolate
D
Chocolate with bill got higher tips

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bce6ae34-651a-534d-a31b-edc3791f2471', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Choose the correct letter
A
,
B
,
C
or
D
.
1 . The main purpose of
Cialdini’
s research of writing is to
A
explain the reason way researcher should investigate in person
B
explore the secret that why some people become the famous salesperson
C
help people to sale products
D
prove maybe there is a science in the psychology of persuasion
2. Which of the statement is CORRECT according to
Cialdini’
s research methodology
A
he checked data in a lot of latest books
B
he conducted this experiment in the laboratory
C
he interviewed and contract with many salespeople
D
he made lot phone calls collecting what he wants to know
3. Which of the following is CORRECT according to towel experiment in the passage?
A
Different hotel guests act in a different response
B
Most guests act by the idea of environment preservation
C
more customers tend to cooperate as the message requires than simply act environmentally
D
people tend to follow the hotel’s original message more
4. Which of the following is CORRECT according to the candy shop experiment in the passage?
A
Presenting way affects diner’s tips
B
Regular customer gives tips more than irregulars
C
People give tips only when offered chocolate
D
Chocolate with bill got higher tips

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('73ff1bd2-fce0-5ecf-b760-be7c303d0c8e', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
5
Robert Cialdini experienced “principles of influence” himself in realistic life.
6
Principle of persuasion has different types in different countries.
7
In New Zealand, people tend to give tips to attendants after being served chocolate.
8
Elder generation of New Zealand is easily attracted by extra service of restaurants by the principle of reciprocity.

5 ____ Robert Cialdini experienced “principles of influence” himself in realistic life.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('364b55b4-66b5-572d-b053-d1e3d344c375', '73ff1bd2-fce0-5ecf-b760-be7c303d0c8e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0328b0a2-5e2a-5f3f-b51f-b8fbade6d7a9', '73ff1bd2-fce0-5ecf-b760-be7c303d0c8e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0cdc87b-c3bb-5978-94c8-19b5f112afce', '73ff1bd2-fce0-5ecf-b760-be7c303d0c8e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('93b0c5a3-6af6-5392-8e9b-454c6c68a7a7', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
5
Robert Cialdini experienced “principles of influence” himself in realistic life.
6
Principle of persuasion has different types in different countries.
7
In New Zealand, people tend to give tips to attendants after being served chocolate.
8
Elder generation of New Zealand is easily attracted by extra service of restaurants by the principle of reciprocity.

6 ____ Principle of persuasion has different types in different countries.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('106523a6-f442-5225-9ce4-1849ac77eafb', '93b0c5a3-6af6-5392-8e9b-454c6c68a7a7', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5ace557-79c2-528d-9473-04ea64007ccd', '93b0c5a3-6af6-5392-8e9b-454c6c68a7a7', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09dbdb1a-cfd1-540a-af97-cb9c22ec840a', '93b0c5a3-6af6-5392-8e9b-454c6c68a7a7', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3e44eae7-e598-5996-aa2c-511b18338207', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
5
Robert Cialdini experienced “principles of influence” himself in realistic life.
6
Principle of persuasion has different types in different countries.
7
In New Zealand, people tend to give tips to attendants after being served chocolate.
8
Elder generation of New Zealand is easily attracted by extra service of restaurants by the principle of reciprocity.

7 ____ In New Zealand, people tend to give tips to attendants after being served chocolate.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e3f54c4-0b59-593a-8735-0b65379b1e8a', '3e44eae7-e598-5996-aa2c-511b18338207', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('051086b3-82eb-528e-ad37-24e2603772f2', '3e44eae7-e598-5996-aa2c-511b18338207', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8eeb4bf-e368-5d95-9d98-c0377354040c', '3e44eae7-e598-5996-aa2c-511b18338207', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d759df1b-011a-5e00-8a4a-dc55f8ef8d2d', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
5
Robert Cialdini experienced “principles of influence” himself in realistic life.
6
Principle of persuasion has different types in different countries.
7
In New Zealand, people tend to give tips to attendants after being served chocolate.
8
Elder generation of New Zealand is easily attracted by extra service of restaurants by the principle of reciprocity.

8 ____ Elder generation of New Zealand is easily attracted by extra service of restaurants by the principle of reciprocity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3e935ae-3e80-552a-902d-f0e4704d7a69', 'd759df1b-011a-5e00-8a4a-dc55f8ef8d2d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('287098b3-e570-5ebd-be91-664d4bd34f23', 'd759df1b-011a-5e00-8a4a-dc55f8ef8d2d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f774eb2-905c-5d2e-bce8-1ae0417c9c71', 'd759df1b-011a-5e00-8a4a-dc55f8ef8d2d', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7bf6c506-9b86-59a1-bc1c-e83f0c880b7d', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 9, 'CLASSIFICATION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Use the information in the passage to match the category (listed A-E) with correct description below.
Write the appropriate letters
A-E
in boxes
9-13
on answer sheet.
NB
You may use any letter more than once
.
A
Reciprocity of scarcity
B
Authority
C
previous comment
D
Linking
E
Social Proof
9
Some expert may reveal qualification in front of clients.
10
Parents tend to say something that other kids are doing the same.
11
Advertisers ruthlessly exploit the limitation of chances.
12
Use a familiar name in a survey.
13
Ask colleagues to offer a helping hand

9 ____ Some expert may reveal qualification in front of clients.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4ce87f8-8912-545f-9ee4-9a3e4716c657', '7bf6c506-9b86-59a1-bc1c-e83f0c880b7d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('493af45b-049b-5e4e-9780-d373ae5f1c4c', '7bf6c506-9b86-59a1-bc1c-e83f0c880b7d', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1865ae90-7190-58c3-a9a3-369ab2ac4858', '7bf6c506-9b86-59a1-bc1c-e83f0c880b7d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9d72bd5-c9f2-57b6-9f51-95739f34656f', '7bf6c506-9b86-59a1-bc1c-e83f0c880b7d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('810d9a71-2976-5ad5-a2bb-7739a1d39f3d', '7bf6c506-9b86-59a1-bc1c-e83f0c880b7d', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('864aa55a-998e-5d5e-97b1-255ed38c85a3', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 10, 'CLASSIFICATION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Use the information in the passage to match the category (listed A-E) with correct description below.
Write the appropriate letters
A-E
in boxes
9-13
on answer sheet.
NB
You may use any letter more than once
.
A
Reciprocity of scarcity
B
Authority
C
previous comment
D
Linking
E
Social Proof
9
Some expert may reveal qualification in front of clients.
10
Parents tend to say something that other kids are doing the same.
11
Advertisers ruthlessly exploit the limitation of chances.
12
Use a familiar name in a survey.
13
Ask colleagues to offer a helping hand

10 ____ Parents tend to say something that other kids are doing the same.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45f7686d-b921-50ed-900c-9d0ceb84d428', '864aa55a-998e-5d5e-97b1-255ed38c85a3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4defb79b-cb51-5eeb-95c1-73b8212a5130', '864aa55a-998e-5d5e-97b1-255ed38c85a3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da8469e2-3c0e-5729-96a7-1a2f71e25e15', '864aa55a-998e-5d5e-97b1-255ed38c85a3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('423370e3-d238-5da6-81c8-65274b6751a8', '864aa55a-998e-5d5e-97b1-255ed38c85a3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40a3b1f6-b653-50e0-b16e-dc3021771c38', '864aa55a-998e-5d5e-97b1-255ed38c85a3', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4ddbad3e-d351-5e55-b398-d1e337f95ea8', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 11, 'CLASSIFICATION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Use the information in the passage to match the category (listed A-E) with correct description below.
Write the appropriate letters
A-E
in boxes
9-13
on answer sheet.
NB
You may use any letter more than once
.
A
Reciprocity of scarcity
B
Authority
C
previous comment
D
Linking
E
Social Proof
9
Some expert may reveal qualification in front of clients.
10
Parents tend to say something that other kids are doing the same.
11
Advertisers ruthlessly exploit the limitation of chances.
12
Use a familiar name in a survey.
13
Ask colleagues to offer a helping hand

11 ____ Advertisers ruthlessly exploit the limitation of chances.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d5eef91-b958-54e1-ad0b-ab67ac0dd47c', '4ddbad3e-d351-5e55-b398-d1e337f95ea8', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c72959b1-757d-55ff-a4b9-d354886163cb', '4ddbad3e-d351-5e55-b398-d1e337f95ea8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('135b4e4f-f4bc-5a5a-95aa-ead0ddfb09a7', '4ddbad3e-d351-5e55-b398-d1e337f95ea8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cbd2508-8c89-598f-b334-3a71af8b8520', '4ddbad3e-d351-5e55-b398-d1e337f95ea8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd6892ab-849b-5b92-9c62-b831b748eec9', '4ddbad3e-d351-5e55-b398-d1e337f95ea8', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d6bd02e-4e16-58ea-b64b-1c4a7256bf67', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 12, 'CLASSIFICATION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Use the information in the passage to match the category (listed A-E) with correct description below.
Write the appropriate letters
A-E
in boxes
9-13
on answer sheet.
NB
You may use any letter more than once
.
A
Reciprocity of scarcity
B
Authority
C
previous comment
D
Linking
E
Social Proof
9
Some expert may reveal qualification in front of clients.
10
Parents tend to say something that other kids are doing the same.
11
Advertisers ruthlessly exploit the limitation of chances.
12
Use a familiar name in a survey.
13
Ask colleagues to offer a helping hand

12 ____ Use a familiar name in a survey.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26677b42-a380-517d-8c6e-f5dd0141f095', '3d6bd02e-4e16-58ea-b64b-1c4a7256bf67', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd04a561-6502-519a-b184-5dcbcf89d088', '3d6bd02e-4e16-58ea-b64b-1c4a7256bf67', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c46f12c-c2ec-5aa9-8197-4b3fa2c1e50a', '3d6bd02e-4e16-58ea-b64b-1c4a7256bf67', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6d384de-b1a8-5c04-8b1f-8c8099e2cbff', '3d6bd02e-4e16-58ea-b64b-1c4a7256bf67', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('004c4100-3506-545b-a909-00f08b5dd945', '3d6bd02e-4e16-58ea-b64b-1c4a7256bf67', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9d276abf-f666-5617-aed6-d64f3544bc53', '7d6aa12e-8622-5e6b-b193-8880ebdec91b', 13, 'CLASSIFICATION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Use the information in the passage to match the category (listed A-E) with correct description below.
Write the appropriate letters
A-E
in boxes
9-13
on answer sheet.
NB
You may use any letter more than once
.
A
Reciprocity of scarcity
B
Authority
C
previous comment
D
Linking
E
Social Proof
9
Some expert may reveal qualification in front of clients.
10
Parents tend to say something that other kids are doing the same.
11
Advertisers ruthlessly exploit the limitation of chances.
12
Use a familiar name in a survey.
13
Ask colleagues to offer a helping hand

13 ____ Ask colleagues to offer a helping hand$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c0a5217-c1a1-57e5-8513-a2d4d1c5fa01', '9d276abf-f666-5617-aed6-d64f3544bc53', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3a2c2ee-d806-5a73-85bd-ed0e57d7bfc8', '9d276abf-f666-5617-aed6-d64f3544bc53', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a4a4cf8-19eb-52ae-a00f-fc47da5b4592', '9d276abf-f666-5617-aed6-d64f3544bc53', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6de3cb16-ba6f-55ee-85ee-7618a053bd7d', '9d276abf-f666-5617-aed6-d64f3544bc53', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('333a38aa-1170-56c2-a2df-6860af099627', '9d276abf-f666-5617-aed6-d64f3544bc53', 5, $md$E$md$, false);

COMMIT;
