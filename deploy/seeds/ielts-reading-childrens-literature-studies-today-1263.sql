BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-childrens-literature-studies-today-1263'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-childrens-literature-studies-today-1263';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-childrens-literature-studies-today-1263';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-childrens-literature-studies-today-1263';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2fa84083-8473-5bb1-8983-3d3e23bd699d', 'ielts-reading-childrens-literature-studies-today-1263', $t$Children’s literature studies today$t$, $md$## Children’s literature studies today

Nguồn:
- Test: https://mini-ielts.com/1263/reading/childrens-literature-studies-today
- Solution: https://mini-ielts.com/1263/view-solution/reading/childrens-literature-studies-today$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('126160d7-2d48-50a4-93ff-0fa4a991aca1', '2fa84083-8473-5bb1-8983-3d3e23bd699d', 1, $t$Reading — Children’s literature studies today$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Children’s literature studies today

Who studies children’s literature and what is it that they study? The answers to this question are complex and messy, because of the many confounding factors which exist in this field.

Firstly, unlike literature for adults. Children’s literature is not generally written by its own readers. Adults write for children, and thus adult perceptions of what children are and of what they could and should be become woven into the literature.

Furthermore, some of those who study children’s literature (and those who write certain kinds of children’s books) are less interested in literary values than in the kinds of lessons it can teach- either in terms of creating better children or in terms of serving a particular curriculum. The issue of how a teacher can use a children’s book is often contentious, but even outside the classroom, much material for children is still didactic.

Thirdly, while almost all literature is currently promoted within a strong commercial matrix, children’s literature is often especially targeted for marketing initiatives. This fact means that readers are often recruited with a message that is negligibly literary and significantly oriented to ideas of consumption. Daniel Hade (2002) has raised useful questions about whether children’s experience of reading is altered when their books are part of a larger marketing framework involving the movie, the game, and the toy of a popular children’s book. How children perceive and respond to their stories in this new context is an important question.

It is also important to note that texts in an ever-increasing range of new media compete with print media for the attention of the child reader, and create definitional issues for scholars. Does the term literature’ exclusively imply a verbal text? If not, where are the limits? Could a literary computer game ever be considered a work of literature? If not, what kind of attention should be paid to it, since children themselves undoubtedly perceive their print literature as part of a broader continuum? The internet provides one forum through which children now communicate with each other. (In 2003, the internet search engine Google listed 7,920,000 sites relating to the Harry Potter novels; even allowing for duplication and dead ends, that is a number with revolutionary implications.)

Finally, in the context of the higher education institutions where the formal study of children’s literature of often located, at least three disciplinary frameworks (English, education, and librarianship) fragment the focus of scholarly study of children’s literature.

How is the value of the imaginative encounter with the work of literature sustained and honored among such a welter of conflicting interests? One route through this maze is to ask the child readers for help. As David Lewis (2001) has perceptively noted, what children think of reading is not usually the same as what adults think, whether teachers or parents. As Lewis points out children ‘sometimes see more and they often see differently’. If those who study reading can explore children’s perceptions as well as those of adults, their understanding of the nature of reading will be enhanced.

Lewis makes a further valid point when he adds that exploring children’s perceptions is usually justified for educational reasons: “It is true that a better understanding of how children read and how they learn to read, is a prerequisite to improved approaches to teaching. However, it can also be argued, as Lewis rightly does, that when children’s responses to literature are accessed and interpreted, they frequently lead to an understanding of how picture books appeal to children.

Young people’s accounts of what and how they read also enable a more sophisticated description of many of the complex processes involved in reading. All descriptions of reading run the risk of solipsism: i.e. this is how I read so this is what reading is for everyone. Asking other readers how they read, however, reduces that risk. For example, if I am a strong visualizer as I read, I may consider that visualization is a key component of successful reading and I may judge books by their capacity to evoke a vivid visual response. Other readers, however, may help me to realize that not everyone reads with mental pictures. Some readers respond to the patterns of the words, ‘hearing’ them inaudibly like a subliminal radio program. Others respond to the patterns of feelings in the story, responding with an emotional connection. Talking to competent readers, of all ages, provides a better understanding of reading experiences.

Children’s insights are even more important when it comes to understanding the significance of print literature as one aspect of literary culture. Too often adults assume that reading any book at all is a more worthwhile experience than playing a digital game of any kind. A humbler approach would include asking why the game appeals to the player. Many adults will probably never develop the automatic skills to precess a game as readily as they can read a book. This does not indicate that a book is better, but that a particular set of skills is absent Non-players must acknowledge that some fictional universes are thus closed to them, and a logical response would be to find someone who can guide them to the pleasures and challenges of the gaming world. Games need to be judged individually just as books do, and any evaluative framework needs to take this into account.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3dfe43cd-a8f7-59dc-b00f-94ece74a99c2', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

QUESTIONS 1-3
QUESTIONS 1-3
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct answer on boxes 27-29, on your answer sheet.
27.
Which of the following best summarises the writer’s argument in the second paragraph?
A
Children are portrayed as adults see them.
B
Children are unable to write their own stories.
C
Adults fail to stimulate children’s imaginations.
D
Adult literature is too difficult for children.
28.
In the third paragraph, what does the writer say is the main interest of some people who study children’s literature?
A
the quality of the writing
B
the imaginative content of stories
C
the instructive nature of children’s books
D
the way children are written about in stories
29.
The main point of the writer’s argument in the fifth paragraph is to
A
demonstrate that academics consider computer games to be a logical extension of children’s literature.
B
explore the impact of computers on the boundaries of children’s literature.
C
illustrate that literature and computer games have from different origins.
D
prove that children are using computers more than they are reading literature.

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac26e1fb-8c87-56b0-8031-c2cecea2a092', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

QUESTIONS 1-3
QUESTIONS 1-3
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct answer on boxes 27-29, on your answer sheet.
27.
Which of the following best summarises the writer’s argument in the second paragraph?
A
Children are portrayed as adults see them.
B
Children are unable to write their own stories.
C
Adults fail to stimulate children’s imaginations.
D
Adult literature is too difficult for children.
28.
In the third paragraph, what does the writer say is the main interest of some people who study children’s literature?
A
the quality of the writing
B
the imaginative content of stories
C
the instructive nature of children’s books
D
the way children are written about in stories
29.
The main point of the writer’s argument in the fifth paragraph is to
A
demonstrate that academics consider computer games to be a logical extension of children’s literature.
B
explore the impact of computers on the boundaries of children’s literature.
C
illustrate that literature and computer games have from different origins.
D
prove that children are using computers more than they are reading literature.

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2c8cadae-96c6-5a07-83f3-8126ddc85db8', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

QUESTIONS 1-3
QUESTIONS 1-3
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct answer on boxes 27-29, on your answer sheet.
27.
Which of the following best summarises the writer’s argument in the second paragraph?
A
Children are portrayed as adults see them.
B
Children are unable to write their own stories.
C
Adults fail to stimulate children’s imaginations.
D
Adult literature is too difficult for children.
28.
In the third paragraph, what does the writer say is the main interest of some people who study children’s literature?
A
the quality of the writing
B
the imaginative content of stories
C
the instructive nature of children’s books
D
the way children are written about in stories
29.
The main point of the writer’s argument in the fifth paragraph is to
A
demonstrate that academics consider computer games to be a logical extension of children’s literature.
B
explore the impact of computers on the boundaries of children’s literature.
C
illustrate that literature and computer games have from different origins.
D
prove that children are using computers more than they are reading literature.

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7728a757-5372-5e96-94a8-2e7c3498028a', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

QUESTIONS 4-8
QUESTIONS 4-8
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
4-8
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Children tend to make a clear distinction between print literature and electronic media.
5
The study of children’s literature at higher education institutions is restricted to one subject area.
6
Exploring children’s perceptions of reading will assist parents to choose suitable books for children.
7
Adults may appreciate the appeal of illustrated stories better, if they have more information on how children read.
8
Children should be asked what features they would like digital games to include.

4 ____ Children tend to make a clear distinction between print literature and electronic media.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2113a2a2-a2d9-5b61-a35f-e54e88baa271', '7728a757-5372-5e96-94a8-2e7c3498028a', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd9de45a-1d90-537e-915a-944d93305446', '7728a757-5372-5e96-94a8-2e7c3498028a', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53f2922b-4e4b-58a5-988c-13df11ab726f', '7728a757-5372-5e96-94a8-2e7c3498028a', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('314aa30e-9ad1-5dbc-87f5-3438dad7affa', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

QUESTIONS 4-8
QUESTIONS 4-8
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
4-8
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Children tend to make a clear distinction between print literature and electronic media.
5
The study of children’s literature at higher education institutions is restricted to one subject area.
6
Exploring children’s perceptions of reading will assist parents to choose suitable books for children.
7
Adults may appreciate the appeal of illustrated stories better, if they have more information on how children read.
8
Children should be asked what features they would like digital games to include.

5 ____ The study of children’s literature at higher education institutions is restricted to one subject area.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0be4ae4-9194-5755-876b-93769876b26b', '314aa30e-9ad1-5dbc-87f5-3438dad7affa', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('701cf23a-557b-5533-92b5-fb36e7b70036', '314aa30e-9ad1-5dbc-87f5-3438dad7affa', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8b35ce1-d14e-58ca-a529-af2082469dea', '314aa30e-9ad1-5dbc-87f5-3438dad7affa', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5aa71b42-2847-5e5e-b357-5ca43f9c01de', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

QUESTIONS 4-8
QUESTIONS 4-8
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
4-8
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Children tend to make a clear distinction between print literature and electronic media.
5
The study of children’s literature at higher education institutions is restricted to one subject area.
6
Exploring children’s perceptions of reading will assist parents to choose suitable books for children.
7
Adults may appreciate the appeal of illustrated stories better, if they have more information on how children read.
8
Children should be asked what features they would like digital games to include.

6 ____ Exploring children’s perceptions of reading will assist parents to choose suitable books for children.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4f6f010-2733-5c8e-bf41-33c712706068', '5aa71b42-2847-5e5e-b357-5ca43f9c01de', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82c5333a-1e77-5763-a188-27e1041a947d', '5aa71b42-2847-5e5e-b357-5ca43f9c01de', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b77a68e-bf47-540c-8702-c5bb6276fa85', '5aa71b42-2847-5e5e-b357-5ca43f9c01de', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5f158b7-6e32-5547-9426-c60e2c11d665', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

QUESTIONS 4-8
QUESTIONS 4-8
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
4-8
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Children tend to make a clear distinction between print literature and electronic media.
5
The study of children’s literature at higher education institutions is restricted to one subject area.
6
Exploring children’s perceptions of reading will assist parents to choose suitable books for children.
7
Adults may appreciate the appeal of illustrated stories better, if they have more information on how children read.
8
Children should be asked what features they would like digital games to include.

7 ____ Adults may appreciate the appeal of illustrated stories better, if they have more information on how children read.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c659bd91-3c14-5cac-8495-c47ac09fb43f', 'a5f158b7-6e32-5547-9426-c60e2c11d665', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3df5d74b-1174-56ca-90b6-8afd3f4d8cf1', 'a5f158b7-6e32-5547-9426-c60e2c11d665', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f51c7bb-c40f-5fb4-9cf1-337408250be5', 'a5f158b7-6e32-5547-9426-c60e2c11d665', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ccacaf8-7088-5101-bec4-6c1d417c5e5c', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

QUESTIONS 4-8
QUESTIONS 4-8
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
4-8
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
4
Children tend to make a clear distinction between print literature and electronic media.
5
The study of children’s literature at higher education institutions is restricted to one subject area.
6
Exploring children’s perceptions of reading will assist parents to choose suitable books for children.
7
Adults may appreciate the appeal of illustrated stories better, if they have more information on how children read.
8
Children should be asked what features they would like digital games to include.

8 ____ Children should be asked what features they would like digital games to include.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64923cac-8fee-5e22-b69c-afe6013d1bad', '7ccacaf8-7088-5101-bec4-6c1d417c5e5c', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06942ef4-723d-500e-8f21-c2c302ec7f71', '7ccacaf8-7088-5101-bec4-6c1d417c5e5c', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c04ee39-b38e-537b-ab88-7062209a2bc9', '7ccacaf8-7088-5101-bec4-6c1d417c5e5c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('05e6291e-0b9d-5fc2-977b-e4e9c9a3a5a0', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

QUESTIONS 9-13
QUESTIONS 9-13
Complete each sentence with the correct ending,
A-H
, below. easily
Write the correct letter,
A-H
, in boxes 9-13 on your answer sheet.
List of endings
A
accepting that literature exists in a variety of forms today
B
verbalising the words in their heads
C
discovering the reading techniques used by others
D
the style of written stories changing over time
E
the lack of some specific abilities
F
a deeper knowledge of the intricacies of reading
G
children teaching adults to play computer games
H
creating a variety of images in their minds.
9
Young people’s accounts of how they read lead to
10
The risk of solipsism is reduced by
11
Strong visualisers judge books on the basis that they are
12
Children’s insights are important in
13
When adults read a book more easily than they play a digital game it simply suggests

9 ____ Young people’s accounts of how they read lead to$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e832b2b-ece5-541e-80d3-db611de60cd7', '05e6291e-0b9d-5fc2-977b-e4e9c9a3a5a0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a35d5eb3-751f-5840-b5fb-39ec50098709', '05e6291e-0b9d-5fc2-977b-e4e9c9a3a5a0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76183675-308c-5ef3-85d4-705f1d9a6b04', '05e6291e-0b9d-5fc2-977b-e4e9c9a3a5a0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e3d3b42-6a5a-5c34-8ab4-1132d1fdbc52', '05e6291e-0b9d-5fc2-977b-e4e9c9a3a5a0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f2b84ff-c782-534c-a29e-52962049ff32', '05e6291e-0b9d-5fc2-977b-e4e9c9a3a5a0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9e90aa2-ef5f-52e3-a584-aaefe10ab0ff', '05e6291e-0b9d-5fc2-977b-e4e9c9a3a5a0', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c012f02-189b-5a02-b963-3b5164e52a43', '05e6291e-0b9d-5fc2-977b-e4e9c9a3a5a0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34cbe98a-ba68-51b3-b644-338581f0f914', '05e6291e-0b9d-5fc2-977b-e4e9c9a3a5a0', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b69bf7f1-2eb0-5e8a-821c-f8a355ea556a', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

QUESTIONS 9-13
QUESTIONS 9-13
Complete each sentence with the correct ending,
A-H
, below. easily
Write the correct letter,
A-H
, in boxes 9-13 on your answer sheet.
List of endings
A
accepting that literature exists in a variety of forms today
B
verbalising the words in their heads
C
discovering the reading techniques used by others
D
the style of written stories changing over time
E
the lack of some specific abilities
F
a deeper knowledge of the intricacies of reading
G
children teaching adults to play computer games
H
creating a variety of images in their minds.
9
Young people’s accounts of how they read lead to
10
The risk of solipsism is reduced by
11
Strong visualisers judge books on the basis that they are
12
Children’s insights are important in
13
When adults read a book more easily than they play a digital game it simply suggests

10 ____ The risk of solipsism is reduced by$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6fe4e5ee-5f7b-5af5-bbbf-63592ccca656', 'b69bf7f1-2eb0-5e8a-821c-f8a355ea556a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f27a9102-14cb-56bf-af2d-15ac8b82d181', 'b69bf7f1-2eb0-5e8a-821c-f8a355ea556a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90b01531-6bee-5fac-894f-2020e23f6079', 'b69bf7f1-2eb0-5e8a-821c-f8a355ea556a', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12ccda97-05a9-5c84-b23a-363b8b7dced2', 'b69bf7f1-2eb0-5e8a-821c-f8a355ea556a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9554ed87-4857-5196-becf-14d386ab3cdc', 'b69bf7f1-2eb0-5e8a-821c-f8a355ea556a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b9a446a-b88d-57c6-9afd-e8d8ea76d895', 'b69bf7f1-2eb0-5e8a-821c-f8a355ea556a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('856cc476-6dae-5738-8f8b-c7eec6483130', 'b69bf7f1-2eb0-5e8a-821c-f8a355ea556a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('771c51e3-339d-5411-9c62-7bd751dd4b37', 'b69bf7f1-2eb0-5e8a-821c-f8a355ea556a', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3a2f972e-c89f-5871-ab48-22bc32c87354', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

QUESTIONS 9-13
QUESTIONS 9-13
Complete each sentence with the correct ending,
A-H
, below. easily
Write the correct letter,
A-H
, in boxes 9-13 on your answer sheet.
List of endings
A
accepting that literature exists in a variety of forms today
B
verbalising the words in their heads
C
discovering the reading techniques used by others
D
the style of written stories changing over time
E
the lack of some specific abilities
F
a deeper knowledge of the intricacies of reading
G
children teaching adults to play computer games
H
creating a variety of images in their minds.
9
Young people’s accounts of how they read lead to
10
The risk of solipsism is reduced by
11
Strong visualisers judge books on the basis that they are
12
Children’s insights are important in
13
When adults read a book more easily than they play a digital game it simply suggests

11 ____ Strong visualisers judge books on the basis that they are$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edfbc8c7-c39a-57be-bcf9-05d04762c0c7', '3a2f972e-c89f-5871-ab48-22bc32c87354', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e88682d2-121f-5004-9159-d4399ecd920d', '3a2f972e-c89f-5871-ab48-22bc32c87354', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b410993d-9fd9-529e-a8e0-18b2b3a3e9f5', '3a2f972e-c89f-5871-ab48-22bc32c87354', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ded75af6-640c-50f8-a813-dcf0e70dd160', '3a2f972e-c89f-5871-ab48-22bc32c87354', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a3497d0-3373-5037-b081-aa4aefc5f260', '3a2f972e-c89f-5871-ab48-22bc32c87354', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b79738c-ea72-583c-b16a-c84665724fa0', '3a2f972e-c89f-5871-ab48-22bc32c87354', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6a05bab-f474-5f54-bcc1-c4894a1d6cc2', '3a2f972e-c89f-5871-ab48-22bc32c87354', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4b01ff2-11c0-5531-890e-d981c549df37', '3a2f972e-c89f-5871-ab48-22bc32c87354', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8e25ed0-4fa3-5399-a208-abd94d9bc8b1', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

QUESTIONS 9-13
QUESTIONS 9-13
Complete each sentence with the correct ending,
A-H
, below. easily
Write the correct letter,
A-H
, in boxes 9-13 on your answer sheet.
List of endings
A
accepting that literature exists in a variety of forms today
B
verbalising the words in their heads
C
discovering the reading techniques used by others
D
the style of written stories changing over time
E
the lack of some specific abilities
F
a deeper knowledge of the intricacies of reading
G
children teaching adults to play computer games
H
creating a variety of images in their minds.
9
Young people’s accounts of how they read lead to
10
The risk of solipsism is reduced by
11
Strong visualisers judge books on the basis that they are
12
Children’s insights are important in
13
When adults read a book more easily than they play a digital game it simply suggests

12 ____ Children’s insights are important in$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be3a244d-dfec-5d95-a531-0039b2d8ac7d', 'd8e25ed0-4fa3-5399-a208-abd94d9bc8b1', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a010a228-2e74-556c-8337-2b191fa4fbb6', 'd8e25ed0-4fa3-5399-a208-abd94d9bc8b1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7323eb3-0e09-5dc1-8020-f20609e8b4d3', 'd8e25ed0-4fa3-5399-a208-abd94d9bc8b1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14b94a12-1149-5b61-9f2f-caa7c4093839', 'd8e25ed0-4fa3-5399-a208-abd94d9bc8b1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cbc3721-b567-5598-b6ba-32a7f834e0ea', 'd8e25ed0-4fa3-5399-a208-abd94d9bc8b1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b84d4661-047a-5446-99e3-0e995e3f0636', 'd8e25ed0-4fa3-5399-a208-abd94d9bc8b1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc4a06a9-6f6c-532f-b979-a09d04e1af10', 'd8e25ed0-4fa3-5399-a208-abd94d9bc8b1', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('621b4cde-7f28-5245-896b-20c636d65065', 'd8e25ed0-4fa3-5399-a208-abd94d9bc8b1', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('28aa46b1-4c4d-5aee-b617-eae2a177e380', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

QUESTIONS 9-13
QUESTIONS 9-13
Complete each sentence with the correct ending,
A-H
, below. easily
Write the correct letter,
A-H
, in boxes 9-13 on your answer sheet.
List of endings
A
accepting that literature exists in a variety of forms today
B
verbalising the words in their heads
C
discovering the reading techniques used by others
D
the style of written stories changing over time
E
the lack of some specific abilities
F
a deeper knowledge of the intricacies of reading
G
children teaching adults to play computer games
H
creating a variety of images in their minds.
9
Young people’s accounts of how they read lead to
10
The risk of solipsism is reduced by
11
Strong visualisers judge books on the basis that they are
12
Children’s insights are important in
13
When adults read a book more easily than they play a digital game it simply suggests

13 ____ When adults read a book more easily than they play a digital game it simply suggests$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a278d8c-9725-51db-a82e-d07d0f5b3636', '28aa46b1-4c4d-5aee-b617-eae2a177e380', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4392f1c1-efa4-5571-8d20-c5077d8cd428', '28aa46b1-4c4d-5aee-b617-eae2a177e380', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f9013e7-ff96-5180-948e-9e02034b3ad0', '28aa46b1-4c4d-5aee-b617-eae2a177e380', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3da6f121-b574-59ac-83ff-05ab239434c8', '28aa46b1-4c4d-5aee-b617-eae2a177e380', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f30633cb-1450-5f45-885c-d6219b3e33ca', '28aa46b1-4c4d-5aee-b617-eae2a177e380', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c951727-c4fa-5f13-8928-9b5cc973e72c', '28aa46b1-4c4d-5aee-b617-eae2a177e380', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('153cc81c-5fe9-5f63-8443-afffcd0ed88b', '28aa46b1-4c4d-5aee-b617-eae2a177e380', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('642747b4-1855-558b-983d-7abc6d3b7a45', '28aa46b1-4c4d-5aee-b617-eae2a177e380', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('395fcf8e-a877-5dd6-97d3-2c16b802d0d8', '126160d7-2d48-50a4-93ff-0fa4a991aca1', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

QUESTION 14
QUESTION 14
Choose the correct letter
A
,
B
,
C
or
D
.
Write the correct letter in box 14 on your answer sheet.
What was the writer’s main purpose in writing this article?
A
to evaluate how the process of reading fits into children’s literature studies
B
to discuss the impact of the increasing commercial influence on children’s literature studies
C
to review the challenges in the field of children’s literature studies and suggest how to proceed
D
to provide arguments in favor of including computerized forms of me children’s literature studies

Choose the correct letter A , B , C or D .$md$, NULL);

COMMIT;
