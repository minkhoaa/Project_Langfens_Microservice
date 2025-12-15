BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-insect-decision-making-1528'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-insect-decision-making-1528';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-insect-decision-making-1528';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-insect-decision-making-1528';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('355ab060-c2ea-5383-a543-fda37a0f125e', 'ielts-reading-insect-decision-making-1528', $t$Insect decision-making$t$, $md$## Insect decision-making

Nguồn:
- Test: https://mini-ielts.com/1528/reading/insect-decision-making
- Solution: https://mini-ielts.com/1528/view-solution/reading/insect-decision-making$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e8798b47-dc79-5c1c-9287-b40789ed5963', '355ab060-c2ea-5383-a543-fda37a0f125e', 1, $t$Reading — Insect decision-making$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Insect decision-making

It has long been held that decision made collectively by large groups of people are more likely to turn out to be accurate than decisions made by individuals. The idea goes back to the 'jury theorem’ of Nicolas de Condorcet, an 18 th -century French philosopher who was one of the first to apply mathematics to the social sciences. Condorcet’s theory describes collective decisions, outlining how democratic decisions tend to outperform dictatorial ones. If, for example, each member of a jury has only partial information ,the majority decision is more likely to be correct than a decision arrived at by a single juror. Moreover, the probability of a correct decision increases with the size of the jury.

Now it is becoming clear that group decisions are also extremely valuable for the success of social animals, such as ants ,bees .birds and dolphins .Bees make collective decisions ,and they do it rather well, according to Christian List of the London School of Economics ,who has studied group decision-making in humans and animals. Researchers led by Dr List looked at colonies once the original colony reaches a certain size. The queen goes off with about two-thirds of the worker bees to live in a new home or nest, leaving a daughter queen in the old nest with the remaining workers. Among the bees that depart are some that have searched for and found some new nest sites, and reported back using a characteristic body movement known as a 'waggle dance' to indicate to the other bees the suitable places they have located. The longer the dance, the better the site. After a while, other bees start to visit the sites signaled by their companions to see for themselves and, on their return, also perform more waggle dances. The process eventually leads to a consensus on the best site and the breakaway swarm migrates. The decision is remarkably reliable ,with the bees choosing the best site even when there are only small difference between alternative sites.

But exactly how do bees reach such a robust consensus? To find out ,Dr List and his colleagues used a computer generated model of the decision-making process. By experimenting with it they found that, when bees in the model were very good at finding nesting sites but did not share their information, this dramatically slowed down the migration .leaving the swarm homelss and vulnerable .Conversely .bees in the model blindly following the waggle dances of others without first checking. The researchers concluded that the ability of bees to identify successfully and quickly the best site depends on both the bees ‘interdependence in communicating the whereabouts of the bees site, and their independence in confirming this information for themselves.

Another situation in which collective decisions are taken occurs when animals are either isolated from crucial sources of information or dominated by other members of the group. José Halloy of the Free University of Brussels in Belgium used robotic cockroaches to subvert the behaviour of living cockroaches and control their decision-making process. In his experiment, the artificial bugs were introduced to the live ones and soon became sufficiently socially integrated that they were perceived by the real cockroaches as equals. By manipulating the robots, which were in the minority, Halloy was able to persuade the living cockroaches to choose an inappropriate shelter-even one which they had rejected before being infiltrated by the robots.

The way insects put into effect collective decisions can be complex and as important as the decisions themselves .At the University of Bristol, in the UK, Nigel Franks and his colleagues studied how a species of ant establishes a new nest. Franks and his associates reported how the insects reduce the problems associated with making a necessarily swift choice. If the ants’ existing nest become suddenly threatened, the insects choose certain ants to act as scouts to find a new nest.

How quickly they accomplish the transfer to a new home depends not only on how soon the best available site is found, but also on how quickly the migration there can be achieved.

Once the suitable new nest is identified , the chosen ants begin to lead others , which have made it to the new site or which may simply be in the vicinity, back to the original threatened nest. In this way, those ants which are familiar with the route can help transport ,for example ,the queen and young ants to the new site, and simultaneously show the way to those ants which have been left behind to guard the old nest. In this way moving processes are accomplished faster and more efficiently. Thus the dynamics of collective decision-making are closely related to the efficient implementation of those decisions .How this might apply to choices that humans make is , as yet,unclear. But it does suggest, even for humans ,the importance of recruiting dynamic leaders to a cause,because the most important thing about collective decision-making ,as shown by these insect experiments, is to get others to follow.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9574ccba-32e5-5426-8f5e-e992f384cbd1', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 1, 'SHORT_ANSWER', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-vii,
in boxes -16 on your answer sheet.
List of Headings
i
The effect of man-made imitations on insects
ii
The need to instruct additional insect guides
iii
Signals used by certain insects to indicate a discovery
iv
How urgency can affect the process of finding a new home
v
The use of trained insects in testing scientific theories
vi
The use of virtual scenarios in the study of insect behaviour
vii
How the number of decision-makers affects the decision
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

1 ____ Paragraph A$md$, NULL, ARRAY['.*vii.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('74e4f460-c8a5-5f71-b751-a81e53526ae7', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 2, 'SHORT_ANSWER', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-vii,
in boxes -16 on your answer sheet.
List of Headings
i
The effect of man-made imitations on insects
ii
The need to instruct additional insect guides
iii
Signals used by certain insects to indicate a discovery
iv
How urgency can affect the process of finding a new home
v
The use of trained insects in testing scientific theories
vi
The use of virtual scenarios in the study of insect behaviour
vii
How the number of decision-makers affects the decision
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

2 ____ Paragraph B$md$, NULL, ARRAY['.*iii.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6d22f668-bf21-54cc-b9c8-c275410649ca', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 3, 'SHORT_ANSWER', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-vii,
in boxes -16 on your answer sheet.
List of Headings
i
The effect of man-made imitations on insects
ii
The need to instruct additional insect guides
iii
Signals used by certain insects to indicate a discovery
iv
How urgency can affect the process of finding a new home
v
The use of trained insects in testing scientific theories
vi
The use of virtual scenarios in the study of insect behaviour
vii
How the number of decision-makers affects the decision
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

3 ____ Paragraph C$md$, NULL, ARRAY['.*vi.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9b6aee9b-e4f8-512f-ad26-8f38b2f4af7b', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 4, 'SHORT_ANSWER', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-vii,
in boxes -16 on your answer sheet.
List of Headings
i
The effect of man-made imitations on insects
ii
The need to instruct additional insect guides
iii
Signals used by certain insects to indicate a discovery
iv
How urgency can affect the process of finding a new home
v
The use of trained insects in testing scientific theories
vi
The use of virtual scenarios in the study of insect behaviour
vii
How the number of decision-makers affects the decision
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

4 ____ Paragraph D$md$, NULL, ARRAY['.*i.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('67ed0faa-a5cf-5b5d-935a-008bcfacb49f', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 5, 'SHORT_ANSWER', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-vii,
in boxes -16 on your answer sheet.
List of Headings
i
The effect of man-made imitations on insects
ii
The need to instruct additional insect guides
iii
Signals used by certain insects to indicate a discovery
iv
How urgency can affect the process of finding a new home
v
The use of trained insects in testing scientific theories
vi
The use of virtual scenarios in the study of insect behaviour
vii
How the number of decision-makers affects the decision
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

5 ____ Paragraph E$md$, NULL, ARRAY['.*iv.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7adfa389-5398-595f-bad4-188f435ea3c4', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-vii,
in boxes -16 on your answer sheet.
List of Headings
i
The effect of man-made imitations on insects
ii
The need to instruct additional insect guides
iii
Signals used by certain insects to indicate a discovery
iv
How urgency can affect the process of finding a new home
v
The use of trained insects in testing scientific theories
vi
The use of virtual scenarios in the study of insect behaviour
vii
How the number of decision-makers affects the decision
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

6 ____ Paragraph F$md$, NULL, ARRAY['.*ii.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('424a7d8b-89ce-5b1a-a62b-579dfe41bf60', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Look at the
following findings (Questions 7-10) and the list of academics below.
Match each
finding with the correct academic, A-D
Write the
correct letter, A-D, in boxes 7-10 on your answer sheet.
NB
you
may use any letter
more than
once
.
7
Certain
members can influence the rest of the group to alter a previous decision.
8
Individual verification of a proposed choice is important for successful decision
outcome.
9
The
more individuals taking part in
a
decision, the better the decision will be.
10
The
decision-making process of certain insects produces excellent results even
when fine
distinctions are required.
List of Academics
A
Nicolas de Condorcet
B
Christian List and colleagues
C
José Halloy
D
Nigel Franks and colleagues

7 ____ Certain members can influence the rest of the group to alter a previous decision.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80a1f5d4-94e3-5829-9ba6-16103c763b8e', '424a7d8b-89ce-5b1a-a62b-579dfe41bf60', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f422d868-7884-5b00-a410-0372ee031d49', '424a7d8b-89ce-5b1a-a62b-579dfe41bf60', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c6484d8-febc-5d6a-b906-9c015d48d16f', '424a7d8b-89ce-5b1a-a62b-579dfe41bf60', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e9dd0a7-7885-5a56-8ad8-02cf91cae765', '424a7d8b-89ce-5b1a-a62b-579dfe41bf60', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('80105bc6-6e55-5cad-8bf5-d03e09a7ca73', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Look at the
following findings (Questions 7-10) and the list of academics below.
Match each
finding with the correct academic, A-D
Write the
correct letter, A-D, in boxes 7-10 on your answer sheet.
NB
you
may use any letter
more than
once
.
7
Certain
members can influence the rest of the group to alter a previous decision.
8
Individual verification of a proposed choice is important for successful decision
outcome.
9
The
more individuals taking part in
a
decision, the better the decision will be.
10
The
decision-making process of certain insects produces excellent results even
when fine
distinctions are required.
List of Academics
A
Nicolas de Condorcet
B
Christian List and colleagues
C
José Halloy
D
Nigel Franks and colleagues

8 ____ Individual verification of a proposed choice is important for successful decision outcome.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0f9e90c-4c30-552f-9458-ccd8d7414e5b', '80105bc6-6e55-5cad-8bf5-d03e09a7ca73', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15f7eb2c-6734-5c82-a06f-949712811996', '80105bc6-6e55-5cad-8bf5-d03e09a7ca73', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d0166f9-fe0f-59e2-b488-4179b8e36484', '80105bc6-6e55-5cad-8bf5-d03e09a7ca73', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('202daab2-5195-57ff-8d01-5d9e0bea95f7', '80105bc6-6e55-5cad-8bf5-d03e09a7ca73', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('38fb3b97-5cb2-5659-a205-0a621513b5b9', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Look at the
following findings (Questions 7-10) and the list of academics below.
Match each
finding with the correct academic, A-D
Write the
correct letter, A-D, in boxes 7-10 on your answer sheet.
NB
you
may use any letter
more than
once
.
7
Certain
members can influence the rest of the group to alter a previous decision.
8
Individual verification of a proposed choice is important for successful decision
outcome.
9
The
more individuals taking part in
a
decision, the better the decision will be.
10
The
decision-making process of certain insects produces excellent results even
when fine
distinctions are required.
List of Academics
A
Nicolas de Condorcet
B
Christian List and colleagues
C
José Halloy
D
Nigel Franks and colleagues

9 ____ The more individuals taking part in a decision, the better the decision will be.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99e30991-6723-595d-b443-112d2fcaf4b9', '38fb3b97-5cb2-5659-a205-0a621513b5b9', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('041e27e6-4c6c-5886-bd55-24a9e66f6a89', '38fb3b97-5cb2-5659-a205-0a621513b5b9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad24f984-6582-54fa-98a3-99cade47c860', '38fb3b97-5cb2-5659-a205-0a621513b5b9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13407e66-e7e1-5da3-b32d-e5a9b7891aa7', '38fb3b97-5cb2-5659-a205-0a621513b5b9', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('85ff2506-c710-5eba-81c4-d0df150aac82', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Look at the
following findings (Questions 7-10) and the list of academics below.
Match each
finding with the correct academic, A-D
Write the
correct letter, A-D, in boxes 7-10 on your answer sheet.
NB
you
may use any letter
more than
once
.
7
Certain
members can influence the rest of the group to alter a previous decision.
8
Individual verification of a proposed choice is important for successful decision
outcome.
9
The
more individuals taking part in
a
decision, the better the decision will be.
10
The
decision-making process of certain insects produces excellent results even
when fine
distinctions are required.
List of Academics
A
Nicolas de Condorcet
B
Christian List and colleagues
C
José Halloy
D
Nigel Franks and colleagues

10 ____ The decision-making process of certain insects produces excellent results even when fine distinctions are required.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ace238a-bd19-5d94-8fb6-84d511435744', '85ff2506-c710-5eba-81c4-d0df150aac82', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad119dfb-5e00-5621-974f-cde03648c732', '85ff2506-c710-5eba-81c4-d0df150aac82', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76467fdd-9e8a-59a0-a5a6-79b2cb609e48', '85ff2506-c710-5eba-81c4-d0df150aac82', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d396237f-b8b4-57c3-a9bb-fa9206c9a9ca', '85ff2506-c710-5eba-81c4-d0df150aac82', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('513d2025-afa0-51ad-b701-e57199a38343', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
A study of insect decision-making
A Bristol University study looked at how insects make decisions when their home has been
11
.
The ants in the experiment relied on the use of individuals called
12
new nest and efficiently direct the others to go there. The study concluded that the effective implementation of the ants' decision meant that the insects could change homes quickly. The study emphasized the necessity, for people well as insects,of having active
13
in order to execute decisions successfully.

A Bristol University study looked at how insects make decisions when their home has been 11 ____ . The ants in the experiment relied on the use of individuals called 12 ____ new nest and efficiently direct the others to go there. The study concluded that the effective implementation of the ants' decision meant that the insects could change homes quickly. The study emphasized the necessity, for people well as insects,of having active 13 ____ in order to execute decisions successfully.$md$, NULL, ARRAY['.*threatened.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('34a3c8a0-8f42-5068-bfc4-ded850b8753b', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
A study of insect decision-making
A Bristol University study looked at how insects make decisions when their home has been
11
.
The ants in the experiment relied on the use of individuals called
12
new nest and efficiently direct the others to go there. The study concluded that the effective implementation of the ants' decision meant that the insects could change homes quickly. The study emphasized the necessity, for people well as insects,of having active
13
in order to execute decisions successfully.

A Bristol University study looked at how insects make decisions when their home has been 11 ____ . The ants in the experiment relied on the use of individuals called 12 ____ new nest and efficiently direct the others to go there. The study concluded that the effective implementation of the ants' decision meant that the insects could change homes quickly. The study emphasized the necessity, for people well as insects,of having active 13 ____ in order to execute decisions successfully.$md$, NULL, ARRAY['.*threatened.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2a6e4be3-f68e-59b3-8e23-6df529101f57', 'e8798b47-dc79-5c1c-9287-b40789ed5963', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
A study of insect decision-making
A Bristol University study looked at how insects make decisions when their home has been
11
.
The ants in the experiment relied on the use of individuals called
12
new nest and efficiently direct the others to go there. The study concluded that the effective implementation of the ants' decision meant that the insects could change homes quickly. The study emphasized the necessity, for people well as insects,of having active
13
in order to execute decisions successfully.

A Bristol University study looked at how insects make decisions when their home has been 11 ____ . The ants in the experiment relied on the use of individuals called 12 ____ new nest and efficiently direct the others to go there. The study concluded that the effective implementation of the ants' decision meant that the insects could change homes quickly. The study emphasized the necessity, for people well as insects,of having active 13 ____ in order to execute decisions successfully.$md$, NULL, ARRAY['.*threatened.*']);

COMMIT;
