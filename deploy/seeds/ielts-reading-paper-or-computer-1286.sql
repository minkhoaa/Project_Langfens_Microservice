BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-paper-or-computer-1286'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-paper-or-computer-1286';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-paper-or-computer-1286';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-paper-or-computer-1286';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('6f8f057e-40ee-53bd-bde0-05fd6a5bb65f', 'ielts-reading-paper-or-computer-1286', $t$Paper or Computer?$t$, $md$## Paper or Computer?

Nguồn:
- Test: https://mini-ielts.com/1286/reading/paper-or-computer
- Solution: https://mini-ielts.com/1286/view-solution/reading/paper-or-computer$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2063f7e2-41f2-555e-9e21-94f7270ae7c4', '6f8f057e-40ee-53bd-bde0-05fd6a5bb65f', 1, $t$Reading — Paper or Computer?$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Paper or Computer?

A . Computer technology was supposed to replace paper. But that hasn’t happened. Every country in the Western world uses more paper today, on a per- capita basis, than it did ten years ago. The consumption of uncoated free-sheet paper, for instance the most common kind of office paper — rose almost fifteen per cent in the United States between 1995 and 2000. This is generally taken as evidence of how hard it is to eradicate old, wasteful habits and of how stubbornly resistant we are to the efficiencies offered by computerization. A number of cognitive psychologists and ergonomics experts, however, don’t agree. Paper has persisted, they argue, for very good reasons: when it comes to performing certain kinds of cognitive tasks, paper has many advantages over computers. The dismay people feel at the sight of a messy desk — or the spectacle of air-traffic controllers tracking flights through notes scribbled on paper strips – arises from a fundamental confusion about the role that paper plays in our lives.

B . The case for paper is made most eloquently in “The Myth of the Paperless Office”, by two social scientists, Abigail Sellen and Richard Harper. They begin their book with an account of a study they conducted at the International Monetary Fund, in Washington, D.c. Economists at the I.M.F. spend most of their time writing reports on complicated economic questions, work that would seem to be perfectly suited to sitting in front of a computer. Nonetheless, the I.M.F. is awash in paper, and Sellen and Harper wanted to find out why. Their answer is that the business of writing reports – at least at the I.M.F. is an intensely collaborative process, involving the professional judgments and contributions of many people. The economists bring drafts of reports to conference rooms, spread out the relevant pages, and negotiate changes with one other. They go back to their offices and jot down comments in the margin, taking advantage of the freedom offered by the informality of the handwritten note. Then they deliver the annotated draft to the author in person, taking him, page by page, through the suggested changes. At the end of the process, the author spreads out all the pages with comments on his desk and starts to enter them on the computer — moving the pages around as he works, organizing and reorganizing, saving and discarding.

C . Without paper, this kind of collaborative and iterative work process would be much more difficult. According to Sellen and Harper, paper has a unique set of “affordances” — that is, qualities that permit specific kinds of uses. Paper is tangible: we can pick up a document, flip through it, read little bits here and there, and quickly get a sense of it. Paper is spatially flexible, meaning that we can spread it out and arrange it in the way that suits US best. And it’s tailorable: we can easily annotate it, and scribble on it as we read, without altering the original text. Digital documents, of course, have then own affordances. They can be easily searched, shared, stored, accessed remotely, and linked to other relevant material. But they lack the affordances that really matter to a group of people working together on a report. Sellen and Harper write:

D . Paper enables a certain kind of thinking. Picture, for instance, the top of your desk. Chances are that you have a keyboard and a computer screen off to one side, and a clear space roughly eighteen inches square in front of your chair. What covers the rest of the desktop is probably piles- piles of papers, journals, magazines, binders, postcards, videotapes, and all the other artifacts of the knowledge economy. The piles look like a mess, but they aren’t. When a group at Apple Computer studied piling behavior several years ago, they found that even the most disorderly piles usually make perfect sense to the piler, and that office workers could hold forth in great detail about the precise history and meaning of thefr piles. The pile closest to the cleared, eighteen-inch-square working area, for example, generally represents the most urgent business, and within that pile the most important document of all is likely to be at the top. Piles are living, breathing archives. Over time, they get broken down and resorted, sometimes chronologically and sometimes thematically and sometimes chronologically and thematically; clues about certain documents may be physically embedded in the file by, say, stacking a certain piece of paper at an angle or inserting dividers into the stack.

E . But why do we pile documents instead of filing them? Because piles represent the process of active, ongoing thinking. The psychologist Alison Kidd, whose research Sellen and Harper refer to extensively, argues that “knowledge workers” use the physical space of the desktop to hold “ideas which they cannot yet categorize or even decide how they might use.” The messy desk is not necessarily a sign of disorganization. It may be a sign of complexity: those who deal with many unresolved ideas simultaneously cannot sort and file the papers on their desks, because they haven’t yet sorted and filed the ideas in their head. Kidd writes that many of the people she talked to use the papers on their desks as contextual cues to’’ recover a complex set of threads without difficulty and delay” when they come in on a Monday morning, or after their work has been interrupted by a phone call. What we see when we look at the piles on our desks is, in a sense, the contents of our brains.

F . This idea that paper facilitates a highly specialized cognitive and social process is a far cry from the way we have historically thought about the stuff. Paper first began to proliferate in the workplace in the late nineteenth century as part of the move toward “systematic management.” To cope with the complexity of the industrial economy, managers were instituting company-wide policies and demanding monthly, weekly, or even daily updates from their subordinates. Thus was born the monthly sales report, and the office manual and the internal company newsletter. The typewriter took off in the eighteen-eighties, making it possible to create documents in a fraction of the time it had previously taken, and that was followed closely by the advent of carbon paper, which meant that a typist could create ten copies of that document simultaneously. Paper was important not to facilitate creative collaboration and thought but as an instrument of control.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0f34763c-4fdf-525e-9fe1-77132fe39221', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. paper continued as a sharing or managing must
ii
. piles can be more inspiring rather than disorgnising
iii
. Favorable situation that economists used paper pages
iv
. overview of an unexpected situation: paper survived
v
. comparison between efficiencies for using paper and using computer
vi
. IMF’ paperless office seemed to be a waste of papers
vii
. example of failure for avoidance of paper record
viii
. There are advantages of using a paper in offices
ix
.
piles reflect certain characteristics in people’ thought
x
.
joy of having the paper square in front of computer
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

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f591672f-a6cb-53aa-bd84-7666bc09fbda', '0f34763c-4fdf-525e-9fe1-77132fe39221', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57ff9afc-ba10-5f14-bc81-1e51238dd81f', '0f34763c-4fdf-525e-9fe1-77132fe39221', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('382c3e24-58db-5cdd-a53b-4d513cd470d1', '0f34763c-4fdf-525e-9fe1-77132fe39221', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50b1a3b4-ad62-5dcc-bac2-e1601bb7f4ce', '0f34763c-4fdf-525e-9fe1-77132fe39221', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37bc1632-8098-59d7-a6a7-3c9efcd4d330', '0f34763c-4fdf-525e-9fe1-77132fe39221', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7180f491-9b2c-53db-902f-92b5b10f387d', '0f34763c-4fdf-525e-9fe1-77132fe39221', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7d8eaaf-94f1-5bf7-88aa-4b98757d4d32', '0f34763c-4fdf-525e-9fe1-77132fe39221', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff298418-bf82-52ae-81d5-15e8d103c20b', '0f34763c-4fdf-525e-9fe1-77132fe39221', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f589650b-96b1-535b-bc09-d64446dae19e', '0f34763c-4fdf-525e-9fe1-77132fe39221', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a41a22c0-37c2-524d-80e1-93d6995e2956', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. paper continued as a sharing or managing must
ii
. piles can be more inspiring rather than disorgnising
iii
. Favorable situation that economists used paper pages
iv
. overview of an unexpected situation: paper survived
v
. comparison between efficiencies for using paper and using computer
vi
. IMF’ paperless office seemed to be a waste of papers
vii
. example of failure for avoidance of paper record
viii
. There are advantages of using a paper in offices
ix
.
piles reflect certain characteristics in people’ thought
x
.
joy of having the paper square in front of computer
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

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4cc37d4-b299-5de0-9eb8-123de3decb16', 'a41a22c0-37c2-524d-80e1-93d6995e2956', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7504522-b701-5920-a4e9-17eaa3f3622e', 'a41a22c0-37c2-524d-80e1-93d6995e2956', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34991ff1-9c73-52d7-a281-44637bc56154', 'a41a22c0-37c2-524d-80e1-93d6995e2956', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e40fe54-e2de-5eaf-8336-4beccf11e085', 'a41a22c0-37c2-524d-80e1-93d6995e2956', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('724574d1-b523-55ff-806e-615af571e756', 'a41a22c0-37c2-524d-80e1-93d6995e2956', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45dfd45c-f83d-5787-9001-1f3a1b1ea590', 'a41a22c0-37c2-524d-80e1-93d6995e2956', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d31652aa-285b-5ec6-8ad0-274f9c885bd1', 'a41a22c0-37c2-524d-80e1-93d6995e2956', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23259097-188f-5eed-a045-b6bfd5e07e48', 'a41a22c0-37c2-524d-80e1-93d6995e2956', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c67cca1-e777-5f69-8dae-033b23c8cad4', 'a41a22c0-37c2-524d-80e1-93d6995e2956', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('24c1dada-e7dc-5e13-9003-dde5eb39d64f', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. paper continued as a sharing or managing must
ii
. piles can be more inspiring rather than disorgnising
iii
. Favorable situation that economists used paper pages
iv
. overview of an unexpected situation: paper survived
v
. comparison between efficiencies for using paper and using computer
vi
. IMF’ paperless office seemed to be a waste of papers
vii
. example of failure for avoidance of paper record
viii
. There are advantages of using a paper in offices
ix
.
piles reflect certain characteristics in people’ thought
x
.
joy of having the paper square in front of computer
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

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2ca35b6-41fa-514a-ab60-47fdd5427ea5', '24c1dada-e7dc-5e13-9003-dde5eb39d64f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d570420f-c24d-5eb2-ac3d-6ab6f4d679ff', '24c1dada-e7dc-5e13-9003-dde5eb39d64f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d59020cc-582e-5922-ac43-dbc3d767ed14', '24c1dada-e7dc-5e13-9003-dde5eb39d64f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41a369a1-f155-5cd1-b696-b296b2114e95', '24c1dada-e7dc-5e13-9003-dde5eb39d64f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9247f3b6-1272-5c87-9ae0-3660ce5f04ce', '24c1dada-e7dc-5e13-9003-dde5eb39d64f', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96e6b182-c5df-5ed1-be45-19c261e3c9b7', '24c1dada-e7dc-5e13-9003-dde5eb39d64f', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d50dbd61-c20e-5ae0-8b47-156ddc6fcf5f', '24c1dada-e7dc-5e13-9003-dde5eb39d64f', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed47a2b2-a038-59ab-889f-f1894216c15b', '24c1dada-e7dc-5e13-9003-dde5eb39d64f', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8ef1115-9875-5380-a507-6b572a339ef6', '24c1dada-e7dc-5e13-9003-dde5eb39d64f', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9412596c-b114-59e9-b78f-7f0bfd42876e', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. paper continued as a sharing or managing must
ii
. piles can be more inspiring rather than disorgnising
iii
. Favorable situation that economists used paper pages
iv
. overview of an unexpected situation: paper survived
v
. comparison between efficiencies for using paper and using computer
vi
. IMF’ paperless office seemed to be a waste of papers
vii
. example of failure for avoidance of paper record
viii
. There are advantages of using a paper in offices
ix
.
piles reflect certain characteristics in people’ thought
x
.
joy of having the paper square in front of computer
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

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b3be6c0-a26e-520f-b3b7-0da79a51966d', '9412596c-b114-59e9-b78f-7f0bfd42876e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c7f8bca-3963-5987-8a99-c6d6b4cd4523', '9412596c-b114-59e9-b78f-7f0bfd42876e', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6da0af99-f5d7-5c44-b8e6-5778902295e8', '9412596c-b114-59e9-b78f-7f0bfd42876e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75a366b6-aa1e-5df0-9ad5-8fc1e38b5293', '9412596c-b114-59e9-b78f-7f0bfd42876e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('871c061c-c5d1-5173-832b-772890bca3ab', '9412596c-b114-59e9-b78f-7f0bfd42876e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f72445a6-0bec-5eff-af02-daf9ffa20d1d', '9412596c-b114-59e9-b78f-7f0bfd42876e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('811e6bd5-f10d-5272-927a-5b69f84ee75c', '9412596c-b114-59e9-b78f-7f0bfd42876e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55286fa9-6a0b-5a0e-bf6a-a1520d91d927', '9412596c-b114-59e9-b78f-7f0bfd42876e', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f13219d5-72bb-5f17-a28f-c1e028af5a89', '9412596c-b114-59e9-b78f-7f0bfd42876e', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0c37dd9e-5bc7-597b-95e4-8bf0452e33a2', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. paper continued as a sharing or managing must
ii
. piles can be more inspiring rather than disorgnising
iii
. Favorable situation that economists used paper pages
iv
. overview of an unexpected situation: paper survived
v
. comparison between efficiencies for using paper and using computer
vi
. IMF’ paperless office seemed to be a waste of papers
vii
. example of failure for avoidance of paper record
viii
. There are advantages of using a paper in offices
ix
.
piles reflect certain characteristics in people’ thought
x
.
joy of having the paper square in front of computer
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

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c67ad7c6-cfa4-5b09-bbcc-6a559b7be38e', '0c37dd9e-5bc7-597b-95e4-8bf0452e33a2', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cb81271-4be1-51b2-b9c1-d6a78cc945dc', '0c37dd9e-5bc7-597b-95e4-8bf0452e33a2', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e3c7bea-c48f-5936-b1a5-901e273db0b7', '0c37dd9e-5bc7-597b-95e4-8bf0452e33a2', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac4b744f-202b-5017-a366-c7e77b5ccfd3', '0c37dd9e-5bc7-597b-95e4-8bf0452e33a2', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0db815b5-53a3-514b-b179-e5231ee472d5', '0c37dd9e-5bc7-597b-95e4-8bf0452e33a2', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3f4a914-e2b9-555c-b10f-5065d92c63f7', '0c37dd9e-5bc7-597b-95e4-8bf0452e33a2', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1e11e5b-e2a6-59e7-b631-99467e765a56', '0c37dd9e-5bc7-597b-95e4-8bf0452e33a2', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d64fe974-56f9-5834-b215-b89c5184c176', '0c37dd9e-5bc7-597b-95e4-8bf0452e33a2', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1ceac34-470b-5ed8-9e0e-d41dc0dc8c38', '0c37dd9e-5bc7-597b-95e4-8bf0452e33a2', 9, $md$ix$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('376ad053-5fe9-523d-bf1d-aa5438413bf2', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below. Write the correct number,
i-xi
, in boxes
1-6
on your answer sheet.
List of Headings
i
. paper continued as a sharing or managing must
ii
. piles can be more inspiring rather than disorgnising
iii
. Favorable situation that economists used paper pages
iv
. overview of an unexpected situation: paper survived
v
. comparison between efficiencies for using paper and using computer
vi
. IMF’ paperless office seemed to be a waste of papers
vii
. example of failure for avoidance of paper record
viii
. There are advantages of using a paper in offices
ix
.
piles reflect certain characteristics in people’ thought
x
.
joy of having the paper square in front of computer
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

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a36b7a0-0605-57a8-aae3-f73f47c2a27a', '376ad053-5fe9-523d-bf1d-aa5438413bf2', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae30546c-c1f3-577b-805a-cc185a0b2e26', '376ad053-5fe9-523d-bf1d-aa5438413bf2', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c09d56de-736b-5db9-a689-cdb40f8d5dc5', '376ad053-5fe9-523d-bf1d-aa5438413bf2', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b55d426c-7184-5c5e-8a1f-b744aa965f1a', '376ad053-5fe9-523d-bf1d-aa5438413bf2', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('970524ec-e1df-5969-8924-9da99ddf053e', '376ad053-5fe9-523d-bf1d-aa5438413bf2', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('164a40a7-e909-50d8-94c6-21c1cd7fbc75', '376ad053-5fe9-523d-bf1d-aa5438413bf2', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e96019c-8133-5852-8c32-ab87dec7ddcf', '376ad053-5fe9-523d-bf1d-aa5438413bf2', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fee9ad0a-d2fc-52c6-a8f6-d6217446ac0c', '376ad053-5fe9-523d-bf1d-aa5438413bf2', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ba2df0c-dd08-5809-866b-0d462abdbf7e', '376ad053-5fe9-523d-bf1d-aa5438413bf2', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('aaa5685c-a205-53e8-b816-6370a6cb9d1b', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Complete the following summary of the paragraphs of
Reading Passage
, using
no more than three words
from the Reading Passage for each answer. Write your answers in boxes
7-10
on your answer sheet.
Compared with digital documents, paper has several advantages. First it allows clerks to work in a
7
. way among colleagues. Next, paper is not like virtual digital versions, it’s
8
.Finally, because it is
9
, note or comments can be effortlessly added as related information. However, shortcoming comes at the absence of convenience on task which is for a
10
.

Compared with digital documents, paper has several advantages. First it allows clerks to work in a 7 ____ . way among colleagues. Next, paper is not like virtual digital versions, it’s 8 ____ .Finally, because it is 9 ____ , note or comments can be effortlessly added as related information. However, shortcoming comes at the absence of convenience on task which is for a 10 ____ .$md$, NULL, ARRAY['.*collaborative.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3772668f-0ea1-5b27-aabe-ff0969c4ed7d', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Complete the following summary of the paragraphs of
Reading Passage
, using
no more than three words
from the Reading Passage for each answer. Write your answers in boxes
7-10
on your answer sheet.
Compared with digital documents, paper has several advantages. First it allows clerks to work in a
7
. way among colleagues. Next, paper is not like virtual digital versions, it’s
8
.Finally, because it is
9
, note or comments can be effortlessly added as related information. However, shortcoming comes at the absence of convenience on task which is for a
10
.

Compared with digital documents, paper has several advantages. First it allows clerks to work in a 7 ____ . way among colleagues. Next, paper is not like virtual digital versions, it’s 8 ____ .Finally, because it is 9 ____ , note or comments can be effortlessly added as related information. However, shortcoming comes at the absence of convenience on task which is for a 10 ____ .$md$, NULL, ARRAY['.*collaborative.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a08054db-1b0d-5ed7-be5d-13a09d6037e2', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Complete the following summary of the paragraphs of
Reading Passage
, using
no more than three words
from the Reading Passage for each answer. Write your answers in boxes
7-10
on your answer sheet.
Compared with digital documents, paper has several advantages. First it allows clerks to work in a
7
. way among colleagues. Next, paper is not like virtual digital versions, it’s
8
.Finally, because it is
9
, note or comments can be effortlessly added as related information. However, shortcoming comes at the absence of convenience on task which is for a
10
.

Compared with digital documents, paper has several advantages. First it allows clerks to work in a 7 ____ . way among colleagues. Next, paper is not like virtual digital versions, it’s 8 ____ .Finally, because it is 9 ____ , note or comments can be effortlessly added as related information. However, shortcoming comes at the absence of convenience on task which is for a 10 ____ .$md$, NULL, ARRAY['.*collaborative.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fd4b1acf-1a92-5b6e-ab1e-a8d62a6144b0', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Complete the following summary of the paragraphs of
Reading Passage
, using
no more than three words
from the Reading Passage for each answer. Write your answers in boxes
7-10
on your answer sheet.
Compared with digital documents, paper has several advantages. First it allows clerks to work in a
7
. way among colleagues. Next, paper is not like virtual digital versions, it’s
8
.Finally, because it is
9
, note or comments can be effortlessly added as related information. However, shortcoming comes at the absence of convenience on task which is for a
10
.

Compared with digital documents, paper has several advantages. First it allows clerks to work in a 7 ____ . way among colleagues. Next, paper is not like virtual digital versions, it’s 8 ____ .Finally, because it is 9 ____ , note or comments can be effortlessly added as related information. However, shortcoming comes at the absence of convenience on task which is for a 10 ____ .$md$, NULL, ARRAY['.*collaborative.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('58a25b2d-88bd-54a0-bb75-ef857006574e', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Choose the correct letter, A, B, c or D.
Write your answers in boxes 11-14 on your answer sheet.
11. What do the
economists
from
IMF
say that their way of writing documents?
A
they note down their comments for freedom on the drafts
B
they finish all writing individually
C
they share ideas on before electronic version was made
D
they use electronic version fully
12. What is the implication of the
“
Piles
” mentioned in the passage?
A
they have underlying orders
B
they are necessarily a mess
C
they are in time sequence order
D
they are in alphabetic order
13. What does the
manager
believe in sophisticated economy?
A
recorded paper can be as management tool
B
carbon paper should be compulsory
C
Teamwork is the most important
D
monthly report is the best way
14. According to the end of this passage, what is the reason
why paper is
not replaced
by electronic vision?
A
paper is inexpensive to buy
B
it contributed to management theories in western countries
C
people need time for changing their old habit
D
it is collaborative and functional for tasks implement and management

Choose the correct letter, A, B, c or D. Write your answers in boxes 11-14 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('48bfac32-ad5f-5119-a80f-df3c144091e3', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Choose the correct letter, A, B, c or D.
Write your answers in boxes 11-14 on your answer sheet.
11. What do the
economists
from
IMF
say that their way of writing documents?
A
they note down their comments for freedom on the drafts
B
they finish all writing individually
C
they share ideas on before electronic version was made
D
they use electronic version fully
12. What is the implication of the
“
Piles
” mentioned in the passage?
A
they have underlying orders
B
they are necessarily a mess
C
they are in time sequence order
D
they are in alphabetic order
13. What does the
manager
believe in sophisticated economy?
A
recorded paper can be as management tool
B
carbon paper should be compulsory
C
Teamwork is the most important
D
monthly report is the best way
14. According to the end of this passage, what is the reason
why paper is
not replaced
by electronic vision?
A
paper is inexpensive to buy
B
it contributed to management theories in western countries
C
people need time for changing their old habit
D
it is collaborative and functional for tasks implement and management

Choose the correct letter, A, B, c or D. Write your answers in boxes 11-14 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e7429c03-27f6-58cd-a6ff-ccfefd84fe94', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Choose the correct letter, A, B, c or D.
Write your answers in boxes 11-14 on your answer sheet.
11. What do the
economists
from
IMF
say that their way of writing documents?
A
they note down their comments for freedom on the drafts
B
they finish all writing individually
C
they share ideas on before electronic version was made
D
they use electronic version fully
12. What is the implication of the
“
Piles
” mentioned in the passage?
A
they have underlying orders
B
they are necessarily a mess
C
they are in time sequence order
D
they are in alphabetic order
13. What does the
manager
believe in sophisticated economy?
A
recorded paper can be as management tool
B
carbon paper should be compulsory
C
Teamwork is the most important
D
monthly report is the best way
14. According to the end of this passage, what is the reason
why paper is
not replaced
by electronic vision?
A
paper is inexpensive to buy
B
it contributed to management theories in western countries
C
people need time for changing their old habit
D
it is collaborative and functional for tasks implement and management

Choose the correct letter, A, B, c or D. Write your answers in boxes 11-14 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ef0963e2-f411-561c-b916-c84d9af80224', '2063f7e2-41f2-555e-9e21-94f7270ae7c4', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Choose the correct letter, A, B, c or D.
Write your answers in boxes 11-14 on your answer sheet.
11. What do the
economists
from
IMF
say that their way of writing documents?
A
they note down their comments for freedom on the drafts
B
they finish all writing individually
C
they share ideas on before electronic version was made
D
they use electronic version fully
12. What is the implication of the
“
Piles
” mentioned in the passage?
A
they have underlying orders
B
they are necessarily a mess
C
they are in time sequence order
D
they are in alphabetic order
13. What does the
manager
believe in sophisticated economy?
A
recorded paper can be as management tool
B
carbon paper should be compulsory
C
Teamwork is the most important
D
monthly report is the best way
14. According to the end of this passage, what is the reason
why paper is
not replaced
by electronic vision?
A
paper is inexpensive to buy
B
it contributed to management theories in western countries
C
people need time for changing their old habit
D
it is collaborative and functional for tasks implement and management

Choose the correct letter, A, B, c or D. Write your answers in boxes 11-14 on your answer sheet.$md$, NULL);

COMMIT;
