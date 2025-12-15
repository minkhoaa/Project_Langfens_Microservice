BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-decision-decision--1362'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-decision-decision--1362';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-decision-decision--1362';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-decision-decision--1362';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9b429b6a-7b9f-5e4c-a4a7-7f2639f7169d', 'ielts-reading-decision-decision--1362', $t$Decision, Decision !$t$, $md$## Decision, Decision !

Nguồn:
- Test: https://mini-ielts.com/1362/reading/decision-decision-
- Solution: https://mini-ielts.com/1362/view-solution/reading/decision-decision-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3483bd5d-1605-5854-ad7d-5146cd284970', '9b429b6a-7b9f-5e4c-a4a7-7f2639f7169d', 1, $t$Reading — Decision, Decision !$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Decision, Decision !

Research explores when we can make a vital decision quickly and we need to proceed more deliberately

A

A widely recognised legend tells us that in Gordium (in what is now Turkey) in the fourth century BC an oxcart was roped to a pole with a complex knot. It was said that the first person to untie it would become the king of Asia. Unfortunately, the knot proved impossible to untie. The story continues that when confronted with this problem, rather than deliberating on how to untie the Gordian knot. Alexander, the famous ruler of the Greeks in the ancient world, simply took out his sword and cut it in two – then went on to conquer Asia. Ever since the notion of a ‘Gordian solution’ has referred to the attractiveness of a simple answer to an otherwise intractable problem.

B

Among researchers in the psychology of decision making, however, such solutions have traditionally held little appeal. In particular, the ‘conflict model’ of decision making proposed by psychologists Irving Janis and Leon Mann in their 1977 book, Decision Making, argued that a complex decision-making process is essential for guarding individuals and groups from the peril of ‘group-think’. Decisions made without thorough canvassing, surveying, weighing, examining and reexamining relevant information and options would be suboptimal and often disastrous. One foreign affair decision made by a well-known US political leader in the 1960s is typically held us as an example of the perils of inadequate thought, whereas his successful handling of a water crisis is cited as an example of the advantages of careful deliberation. However, examination of these historical events by Peter Suedfield, a psychologist at the University of British Columbia, and Roderick Kramer, a psychologist at the Stanford Graduate School of Business, found little difference in the two decision-making processes; both crises required and received complex consideration by the political administration, but later only the second one was deemed to be the effective.

C

In general, however, organizational and political science offers little evidence that complex decisions fare better than simpler ones. In fact, a growing body of work suggests that in many situations simply ‘snap’ decisions with being routinely superior to more complex ones – an idea that gained widespread public appeal with Malcolm Gladwell’s best-selling book Blink (2005).

D

An article by Ap Dijksterhuis of the University of Amsterdam and his colleagues, Making the Right Choice: the Deliberation-without-attention Effect’, runs very much in the spirit of Gladwell’s influential text. Its core argument is that to be effective, conscious (deliberative) decision making requires cognitive resources. Because increasingly complex decisions place increasing strain on those resources, the quality of our decisions declines as their complexity increases. In short, complex decisions overrun our cognitive powers. On the other hand, unconscious decision making (what the author refer to as ‘deliberation without attention’) requires no cognitive resources, so task complexity does not Effectiveness. The seemingly counterintuitive conclusion is that although conscious thought enhances simple decisions, the opposite holds true for more complex decisions.

E

Dijksterhuis reports four Simple but elegant studies supporting this argument. In one, participants assessed the quality of four hypothetical cars by considering either four attributes (a simple task) or 12 attributes (a complex task). Among participants who considered four attributes, those who were allowed to engage in undistracted deliberative thought did better at discriminating between the best and worst cars. Those who were distracted and thus unable to deliberate had to rely on their unconscious thinking and did less well. The opposite pattern emerged when people considered 12 criteria. In this case, conscious deliberation led to inferior discrimination and poor decisions.

F

In other studies, Dijksterhuis surveyed people shopping for clothes (‘simple’ products) and furniture (‘complex’ products). Compared with those who said they had deliberated long and hard, shoppers who bought with little conscious deliberation felt less happy with their simple clothing purchase but happier with the complex furniture purchases. Deliberation without attention actually produced better results as the decisions became more complex.

G

From there, however, the researchers take a big leap. They write: There is no reason to assume that the deliberation-without-attention effect does not generalize to other types of choices – political, managerial or otherwise. In such cases, it should benefit the individual to think consciously about simple matters and to delegate thinking about more complicated matters to the unconscious.

H

This radical inference contradicts standard political and managerial theory but doubtless comforts those in politics and management who always find the simple solution to the complex problem an attractive proposition. Indeed, one suspects many of our political leaders already embrace this wisdom.

I

Still, it is there, in the realms of society and its governance, that the more problematic implications of deliberation without attention begin to surface. Variables that can be neatly circumscribed in decisions about shopping lose clarity in a world of group dynamics, social interaction, history and politics. Two pertinent questions arise. First, what counts as a complex decision? And second, what counts as a good outcome?

J

As social psychologist Kurt Lewin (1890 – 1947) noted, a ‘good’ decision that nobody respects is actually bad, his classic studies of decision making showed that participating in deliberative processes makes people more likely to abide by the results. The issue here is that when political decision-makers make mistakes, it is their politics, or the relationship between their politics and our own, rather than psychology which is at fault.

K

Gladwell’s book and Dijksterhuis’s paper are invaluable in pointing out the limitations of the conventional wisdom that decision quality rises with decision-making complexity. But this work still tempts us to believe that decision making is simply a matter of psychology, rather than also a question of politics, ideology and group membership. Avoiding social considerations in a search for general appeal rather than toward it.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3df2337f-6e54-50b4-a7aa-40e1436fa7e0', '3483bd5d-1605-5854-ad7d-5146cd284970', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

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
The legend of the Gordian knot is used to illustrate the idea that
A
anyone can solve a difficult problem
B
difficult problems can have easy solutions
C
the solution to any problem requires a lot of thought
D
people who can solve complex problems make good leaders
2.
The ‘conflict model’ of decision making proposed by Janis and Mann requires that
A
opposing political parties be involved
B
all-important facts be considered
C
people be encouraged to have different ideas
D
previous similar situations be thoroughly examined
3.
According to recent thinking reinforced by Malcolm Gladwell, the best decisions
A
involve consultation
B
involve complex thought
C
are made very quickly
D
are the most attractive option
4.
Dijksterhuis and his colleagues claim in their article that
A
our cognitive resources improve as tasks become more complex
B
conscious decision making is negatively affected by task complexity
C
unconscious decision making is a popular approach
D
deliberation without attention defines the way we make decisions
5.
Dijksterhuis’s car study found that, in simple tasks, participants
A
were involved in lengthy discussions
B
found it impossible to make decisions quickly
C
were unable to differentiate between the options
D
could make a better choice when allowed to concentrate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ee331b99-40d0-5633-8698-a34295c84e95', '3483bd5d-1605-5854-ad7d-5146cd284970', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

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
The legend of the Gordian knot is used to illustrate the idea that
A
anyone can solve a difficult problem
B
difficult problems can have easy solutions
C
the solution to any problem requires a lot of thought
D
people who can solve complex problems make good leaders
2.
The ‘conflict model’ of decision making proposed by Janis and Mann requires that
A
opposing political parties be involved
B
all-important facts be considered
C
people be encouraged to have different ideas
D
previous similar situations be thoroughly examined
3.
According to recent thinking reinforced by Malcolm Gladwell, the best decisions
A
involve consultation
B
involve complex thought
C
are made very quickly
D
are the most attractive option
4.
Dijksterhuis and his colleagues claim in their article that
A
our cognitive resources improve as tasks become more complex
B
conscious decision making is negatively affected by task complexity
C
unconscious decision making is a popular approach
D
deliberation without attention defines the way we make decisions
5.
Dijksterhuis’s car study found that, in simple tasks, participants
A
were involved in lengthy discussions
B
found it impossible to make decisions quickly
C
were unable to differentiate between the options
D
could make a better choice when allowed to concentrate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5ce19796-6a32-5fc9-9e19-44a44dfe916e', '3483bd5d-1605-5854-ad7d-5146cd284970', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

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
The legend of the Gordian knot is used to illustrate the idea that
A
anyone can solve a difficult problem
B
difficult problems can have easy solutions
C
the solution to any problem requires a lot of thought
D
people who can solve complex problems make good leaders
2.
The ‘conflict model’ of decision making proposed by Janis and Mann requires that
A
opposing political parties be involved
B
all-important facts be considered
C
people be encouraged to have different ideas
D
previous similar situations be thoroughly examined
3.
According to recent thinking reinforced by Malcolm Gladwell, the best decisions
A
involve consultation
B
involve complex thought
C
are made very quickly
D
are the most attractive option
4.
Dijksterhuis and his colleagues claim in their article that
A
our cognitive resources improve as tasks become more complex
B
conscious decision making is negatively affected by task complexity
C
unconscious decision making is a popular approach
D
deliberation without attention defines the way we make decisions
5.
Dijksterhuis’s car study found that, in simple tasks, participants
A
were involved in lengthy discussions
B
found it impossible to make decisions quickly
C
were unable to differentiate between the options
D
could make a better choice when allowed to concentrate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a1d9d3cb-f3c9-544d-ba63-0cf8d3c9212f', '3483bd5d-1605-5854-ad7d-5146cd284970', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

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
The legend of the Gordian knot is used to illustrate the idea that
A
anyone can solve a difficult problem
B
difficult problems can have easy solutions
C
the solution to any problem requires a lot of thought
D
people who can solve complex problems make good leaders
2.
The ‘conflict model’ of decision making proposed by Janis and Mann requires that
A
opposing political parties be involved
B
all-important facts be considered
C
people be encouraged to have different ideas
D
previous similar situations be thoroughly examined
3.
According to recent thinking reinforced by Malcolm Gladwell, the best decisions
A
involve consultation
B
involve complex thought
C
are made very quickly
D
are the most attractive option
4.
Dijksterhuis and his colleagues claim in their article that
A
our cognitive resources improve as tasks become more complex
B
conscious decision making is negatively affected by task complexity
C
unconscious decision making is a popular approach
D
deliberation without attention defines the way we make decisions
5.
Dijksterhuis’s car study found that, in simple tasks, participants
A
were involved in lengthy discussions
B
found it impossible to make decisions quickly
C
were unable to differentiate between the options
D
could make a better choice when allowed to concentrate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5efc8871-131d-5765-92bb-cf35130bd244', '3483bd5d-1605-5854-ad7d-5146cd284970', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

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
The legend of the Gordian knot is used to illustrate the idea that
A
anyone can solve a difficult problem
B
difficult problems can have easy solutions
C
the solution to any problem requires a lot of thought
D
people who can solve complex problems make good leaders
2.
The ‘conflict model’ of decision making proposed by Janis and Mann requires that
A
opposing political parties be involved
B
all-important facts be considered
C
people be encouraged to have different ideas
D
previous similar situations be thoroughly examined
3.
According to recent thinking reinforced by Malcolm Gladwell, the best decisions
A
involve consultation
B
involve complex thought
C
are made very quickly
D
are the most attractive option
4.
Dijksterhuis and his colleagues claim in their article that
A
our cognitive resources improve as tasks become more complex
B
conscious decision making is negatively affected by task complexity
C
unconscious decision making is a popular approach
D
deliberation without attention defines the way we make decisions
5.
Dijksterhuis’s car study found that, in simple tasks, participants
A
were involved in lengthy discussions
B
found it impossible to make decisions quickly
C
were unable to differentiate between the options
D
could make a better choice when allowed to concentrate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5a4a94d7-6e42-5ccf-9b6f-6537def4b076', '3483bd5d-1605-5854-ad7d-5146cd284970', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Complete the summary using the list of words
A-I
below.
Write the correct letter,
A-I
, in boxes
6-9
on your answer sheet.
Dijksterhuis’s shopping study and its conclusions
Using clothing and furniture as examples of different types of purchases, Dijksterhuis questioned shoppers on their satisfaction with what they had bought. People who spent
6
time buying simple clothing items were more satisfied than those who had not. However, when buying furniture, shoppers made
7
purchasing decisions if they didn’t think too hard. From this, the researchers concluded that in other choices, perhaps more important than shopping.
8
decisions are best made by the unconscious. The writer comments that Dijksterhuis’s finding is apparently
9
but nonetheless true.
A
more
B
counterintuitive
C
simple
D
better
E
conscious
F
obvious
G
complex
H
less
I
worse

Using clothing and furniture as examples of different types of purchases, Dijksterhuis questioned shoppers on their satisfaction with what they had bought. People who spent 6 ____ time buying simple clothing items were more satisfied than those who had not. However, when buying furniture, shoppers made 7 ____ purchasing decisions if they didn’t think too hard. From this, the researchers concluded that in other choices, perhaps more important than shopping. 8 ____ decisions are best made by the unconscious. The writer comments that Dijksterhuis’s finding is apparently 9 ____ but nonetheless true.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cdf7998-5ec7-5500-8cc0-4197e636347b', '5a4a94d7-6e42-5ccf-9b6f-6537def4b076', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ead5a577-3f76-5738-9d08-f0c3cdb2321e', '5a4a94d7-6e42-5ccf-9b6f-6537def4b076', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f1b513e-1be1-5d20-9cb1-03ac5299a3c0', '5a4a94d7-6e42-5ccf-9b6f-6537def4b076', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7b8f3e5-9470-544f-a3e3-76551ce9836e', '5a4a94d7-6e42-5ccf-9b6f-6537def4b076', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54152bba-f1b6-5eed-88e1-c345e8db6451', '5a4a94d7-6e42-5ccf-9b6f-6537def4b076', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b801a97-f50f-5a9a-8074-ccd0eca8ce6e', '5a4a94d7-6e42-5ccf-9b6f-6537def4b076', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79f64f1f-a996-5d06-ae45-36120cd8824b', '5a4a94d7-6e42-5ccf-9b6f-6537def4b076', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97c48851-5dbe-5061-8478-508294aa9abf', '5a4a94d7-6e42-5ccf-9b6f-6537def4b076', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7933730c-b6fa-5656-9512-b84b8d31e11d', '5a4a94d7-6e42-5ccf-9b6f-6537def4b076', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0d7c8f19-9a7b-58cc-af4b-a8435df25586', '3483bd5d-1605-5854-ad7d-5146cd284970', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Complete the summary using the list of words
A-I
below.
Write the correct letter,
A-I
, in boxes
6-9
on your answer sheet.
Dijksterhuis’s shopping study and its conclusions
Using clothing and furniture as examples of different types of purchases, Dijksterhuis questioned shoppers on their satisfaction with what they had bought. People who spent
6
time buying simple clothing items were more satisfied than those who had not. However, when buying furniture, shoppers made
7
purchasing decisions if they didn’t think too hard. From this, the researchers concluded that in other choices, perhaps more important than shopping.
8
decisions are best made by the unconscious. The writer comments that Dijksterhuis’s finding is apparently
9
but nonetheless true.
A
more
B
counterintuitive
C
simple
D
better
E
conscious
F
obvious
G
complex
H
less
I
worse

Using clothing and furniture as examples of different types of purchases, Dijksterhuis questioned shoppers on their satisfaction with what they had bought. People who spent 6 ____ time buying simple clothing items were more satisfied than those who had not. However, when buying furniture, shoppers made 7 ____ purchasing decisions if they didn’t think too hard. From this, the researchers concluded that in other choices, perhaps more important than shopping. 8 ____ decisions are best made by the unconscious. The writer comments that Dijksterhuis’s finding is apparently 9 ____ but nonetheless true.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c0f1492-87fb-55fa-bd91-19d2717e6bff', '0d7c8f19-9a7b-58cc-af4b-a8435df25586', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4bacbb42-4a8b-5eb8-9235-6ad173d415c6', '0d7c8f19-9a7b-58cc-af4b-a8435df25586', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b03d2a3e-bfdb-5060-9613-32fcf1a37a27', '0d7c8f19-9a7b-58cc-af4b-a8435df25586', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21edae3f-f999-5e43-94f0-667200b277c7', '0d7c8f19-9a7b-58cc-af4b-a8435df25586', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3b3681a-6476-50f6-801a-ce5203a3b372', '0d7c8f19-9a7b-58cc-af4b-a8435df25586', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d55150d4-2420-5aae-ac81-02fe4c4bcfdb', '0d7c8f19-9a7b-58cc-af4b-a8435df25586', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b71d2e5e-d60f-5230-96e3-43f26bcb2e65', '0d7c8f19-9a7b-58cc-af4b-a8435df25586', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c43da24f-9e70-5ff9-9ae0-713f1f921b77', '0d7c8f19-9a7b-58cc-af4b-a8435df25586', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62ed035d-5466-5950-9089-60d90daca4b4', '0d7c8f19-9a7b-58cc-af4b-a8435df25586', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1751e54f-70d8-5e90-9ebc-5363a1690a0b', '3483bd5d-1605-5854-ad7d-5146cd284970', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Complete the summary using the list of words
A-I
below.
Write the correct letter,
A-I
, in boxes
6-9
on your answer sheet.
Dijksterhuis’s shopping study and its conclusions
Using clothing and furniture as examples of different types of purchases, Dijksterhuis questioned shoppers on their satisfaction with what they had bought. People who spent
6
time buying simple clothing items were more satisfied than those who had not. However, when buying furniture, shoppers made
7
purchasing decisions if they didn’t think too hard. From this, the researchers concluded that in other choices, perhaps more important than shopping.
8
decisions are best made by the unconscious. The writer comments that Dijksterhuis’s finding is apparently
9
but nonetheless true.
A
more
B
counterintuitive
C
simple
D
better
E
conscious
F
obvious
G
complex
H
less
I
worse

Using clothing and furniture as examples of different types of purchases, Dijksterhuis questioned shoppers on their satisfaction with what they had bought. People who spent 6 ____ time buying simple clothing items were more satisfied than those who had not. However, when buying furniture, shoppers made 7 ____ purchasing decisions if they didn’t think too hard. From this, the researchers concluded that in other choices, perhaps more important than shopping. 8 ____ decisions are best made by the unconscious. The writer comments that Dijksterhuis’s finding is apparently 9 ____ but nonetheless true.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2adf42c-868c-5eef-9613-bbfd7e578a5f', '1751e54f-70d8-5e90-9ebc-5363a1690a0b', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bafa4cae-5477-5528-a3c2-d535ff110aff', '1751e54f-70d8-5e90-9ebc-5363a1690a0b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75ad274a-3d32-5f67-a977-42d4403e3528', '1751e54f-70d8-5e90-9ebc-5363a1690a0b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0431c0c0-d323-59a3-bfdd-3a698d93ae21', '1751e54f-70d8-5e90-9ebc-5363a1690a0b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12b7572c-999a-5288-a7a2-09dc44071968', '1751e54f-70d8-5e90-9ebc-5363a1690a0b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15f2b314-4797-5f81-bc0e-08c0a8a9bfdf', '1751e54f-70d8-5e90-9ebc-5363a1690a0b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6d81439-ee83-5357-8da7-4307a6534cc3', '1751e54f-70d8-5e90-9ebc-5363a1690a0b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('194f148c-85a0-54a5-9a01-9bb18c55f2ca', '1751e54f-70d8-5e90-9ebc-5363a1690a0b', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da9a1969-5b56-50b1-9c52-54482db98a5c', '1751e54f-70d8-5e90-9ebc-5363a1690a0b', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('35851ab9-7fb4-508b-b95e-c76d66b97498', '3483bd5d-1605-5854-ad7d-5146cd284970', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Complete the summary using the list of words
A-I
below.
Write the correct letter,
A-I
, in boxes
6-9
on your answer sheet.
Dijksterhuis’s shopping study and its conclusions
Using clothing and furniture as examples of different types of purchases, Dijksterhuis questioned shoppers on their satisfaction with what they had bought. People who spent
6
time buying simple clothing items were more satisfied than those who had not. However, when buying furniture, shoppers made
7
purchasing decisions if they didn’t think too hard. From this, the researchers concluded that in other choices, perhaps more important than shopping.
8
decisions are best made by the unconscious. The writer comments that Dijksterhuis’s finding is apparently
9
but nonetheless true.
A
more
B
counterintuitive
C
simple
D
better
E
conscious
F
obvious
G
complex
H
less
I
worse

Using clothing and furniture as examples of different types of purchases, Dijksterhuis questioned shoppers on their satisfaction with what they had bought. People who spent 6 ____ time buying simple clothing items were more satisfied than those who had not. However, when buying furniture, shoppers made 7 ____ purchasing decisions if they didn’t think too hard. From this, the researchers concluded that in other choices, perhaps more important than shopping. 8 ____ decisions are best made by the unconscious. The writer comments that Dijksterhuis’s finding is apparently 9 ____ but nonetheless true.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72d93e5f-9482-5825-9ac1-aba609a0ec52', '35851ab9-7fb4-508b-b95e-c76d66b97498', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ce320bb-6026-5719-a5b0-c0315278769e', '35851ab9-7fb4-508b-b95e-c76d66b97498', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a086883e-7635-533c-8f2a-4b41fa9d3f19', '35851ab9-7fb4-508b-b95e-c76d66b97498', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fa4cc3e-2db8-5716-a95a-c8b10703841c', '35851ab9-7fb4-508b-b95e-c76d66b97498', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2a3bfac-f61d-5d3d-8cfc-6495217b90d5', '35851ab9-7fb4-508b-b95e-c76d66b97498', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6937e55c-764b-52dc-aefe-f2fdf1556792', '35851ab9-7fb4-508b-b95e-c76d66b97498', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('373ee3fa-ffd2-5262-96a4-4e7f591dec5c', '35851ab9-7fb4-508b-b95e-c76d66b97498', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45888004-9961-5060-9f66-ed1327ff3e7b', '35851ab9-7fb4-508b-b95e-c76d66b97498', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80494e1f-21fa-5a18-afe7-d4ac78fc575e', '35851ab9-7fb4-508b-b95e-c76d66b97498', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('58fed220-5912-53ae-8c9c-809011ff389a', '3483bd5d-1605-5854-ad7d-5146cd284970', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Dijksterhuis’s findings agree with existing political and management theories.
11
Some political leaders seem to use deliberation without attention when making complex decisions.
12
All political decisions are complex ones.
13
We judge political errors according to our own political beliefs.
14
Social considerations must be taken into account for any examination of decision making to prove useful.

10 ____ Dijksterhuis’s findings agree with existing political and management theories.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70516548-d316-501a-9bb6-bdf22fd9c829', '58fed220-5912-53ae-8c9c-809011ff389a', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e15390ff-61a8-50e6-8a20-39c382859b7e', '58fed220-5912-53ae-8c9c-809011ff389a', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('921c7065-48b9-54e5-9f5e-0553c08fa1a2', '58fed220-5912-53ae-8c9c-809011ff389a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('96fdb4f8-f176-527f-8e16-54055a48ab28', '3483bd5d-1605-5854-ad7d-5146cd284970', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Dijksterhuis’s findings agree with existing political and management theories.
11
Some political leaders seem to use deliberation without attention when making complex decisions.
12
All political decisions are complex ones.
13
We judge political errors according to our own political beliefs.
14
Social considerations must be taken into account for any examination of decision making to prove useful.

11 ____ Some political leaders seem to use deliberation without attention when making complex decisions.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f26b8346-3ac4-5ebb-8807-c29e4fdfa42b', '96fdb4f8-f176-527f-8e16-54055a48ab28', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f80583f-2ea7-5383-b16b-16e8ef43ee72', '96fdb4f8-f176-527f-8e16-54055a48ab28', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09047106-0822-5385-bb82-1d661fc67c3e', '96fdb4f8-f176-527f-8e16-54055a48ab28', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('53640251-78c9-5be9-bd16-0615309e1a44', '3483bd5d-1605-5854-ad7d-5146cd284970', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Dijksterhuis’s findings agree with existing political and management theories.
11
Some political leaders seem to use deliberation without attention when making complex decisions.
12
All political decisions are complex ones.
13
We judge political errors according to our own political beliefs.
14
Social considerations must be taken into account for any examination of decision making to prove useful.

12 ____ All political decisions are complex ones.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('389ed526-c48e-5491-ab7e-839243d86a8d', '53640251-78c9-5be9-bd16-0615309e1a44', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff39c8ed-8c16-536a-81a8-ef634f382017', '53640251-78c9-5be9-bd16-0615309e1a44', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70477a91-6a3b-599e-ae7d-e95bd39c0be9', '53640251-78c9-5be9-bd16-0615309e1a44', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d2dfd866-003b-5fd3-a6e6-397230d464c7', '3483bd5d-1605-5854-ad7d-5146cd284970', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Dijksterhuis’s findings agree with existing political and management theories.
11
Some political leaders seem to use deliberation without attention when making complex decisions.
12
All political decisions are complex ones.
13
We judge political errors according to our own political beliefs.
14
Social considerations must be taken into account for any examination of decision making to prove useful.

13 ____ We judge political errors according to our own political beliefs.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba6de16d-34ce-5f1e-80d5-825e6cb77046', 'd2dfd866-003b-5fd3-a6e6-397230d464c7', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('721d801b-6f33-5ac6-821b-f6175a257180', 'd2dfd866-003b-5fd3-a6e6-397230d464c7', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6e5be5d-99e7-5044-bd2c-76bcee56661e', 'd2dfd866-003b-5fd3-a6e6-397230d464c7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6966fcfe-65b5-5edb-b4eb-2a741bc450bb', '3483bd5d-1605-5854-ad7d-5146cd284970', 14, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Dijksterhuis’s findings agree with existing political and management theories.
11
Some political leaders seem to use deliberation without attention when making complex decisions.
12
All political decisions are complex ones.
13
We judge political errors according to our own political beliefs.
14
Social considerations must be taken into account for any examination of decision making to prove useful.

14 ____ Social considerations must be taken into account for any examination of decision making to prove useful.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0409984-017e-5d28-926b-b823cded8a7d', '6966fcfe-65b5-5edb-b4eb-2a741bc450bb', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5509df8a-afa6-5e5f-b1d7-0c435623ffa6', '6966fcfe-65b5-5edb-b4eb-2a741bc450bb', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e49c159a-8709-5e23-a57b-d827c7ed846e', '6966fcfe-65b5-5edb-b4eb-2a741bc450bb', 3, $md$NOT GIVEN$md$, true);

COMMIT;
