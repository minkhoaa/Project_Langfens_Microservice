BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-childrens-literature-1063'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-childrens-literature-1063';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-childrens-literature-1063';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-childrens-literature-1063';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c8e9676f-47b7-56d8-a9e8-f29827feff2b', 'ielts-reading-childrens-literature-1063', $t$Children’s Literature$t$, $md$## Children’s Literature

Nguồn:
- Test: https://mini-ielts.com/1063/reading/childrens-literature
- Solution: https://mini-ielts.com/1063/view-solution/reading/childrens-literature$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e52d9a9e-649c-5146-936e-002faea83580', 'c8e9676f-47b7-56d8-a9e8-f29827feff2b', 1, $t$Reading — Children’s Literature$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Children’s Literature

Stories and poems aimed at children have an exceedingly long history:lullabies, for example, were sung in Roman times, and a few nursery games and rhymes are almost as ancient. Yet so far as written-down literature is concerned, while there were stories in print before 1700 that children often seized on when they had the chance, such as translations of Aesop’s fables, fairy-stories and popular ballads and romances, these were not aimed at young people in particular. Since the only genuinely child-oriented literature at this time would have been a few instructional works to help with reading and general knowledge, plus the odd Puritanical tract as an aid to morality, the only course for keen child readers was to read adult literature. This still occurs today, especially with adult thrillers or romances that include more exciting, graphic detail than is normally found in the literature for younger readers.

By the middle of the 18th century there were enough eager child readers, and enough parents glad to cater to this interest, for publishers to specialize in children’s books whose first aim was pleasure rather than education or morality. In Britain, a London merchant named Thomas Boreham produced Cajanus, The Swedish Giant in 1742, while the more famous John Newbery published A Little Pretty Pocket Book in 1744 . Its contents - rhymes, stories , children’s games plus a free gift (‘A ball and a pincushion’)——in many ways anticipated the similar lucky-dip contents of children’s annuals this century. It is a tribute to Newbery’s flair that he hit upon a winning formula quite so quickly, to be pirated almost immediately in America .

Such pleasing levity was not to last. Influenced by Rousseau, whose Emile(1762) decreed that all books for children save Robinson Crusoe were a dangerous diversion, contemporary critics saw to it that children’s literature should be instructive and uplifting. Prominent among such voices was Mrs. Sarah Trimmer, whose magazine The Guardian of Education (1802) carried the first regular reviews of children’s books. It was she who condemned fairy-tales for their violence and general absurdity; her own stories, Fabulous Histories (1786) described talking animals who were always models of sense and decorum .

So the moral story for children was always threatened from within, given the way children have of drawing out entertainment from the sternest moralist. But the greatest blow to the improving children’s book was to come from an unlikely source indeed : early 19th century interest in folklore . Both nursery rhymes, selected by James Orchard Halliwell for a folklore society in 1842, and collection of fairy-stories by the scholarly Grimm brothers, swiftly translated into English in 1823 ,soon rocket to popularity with the young, quickly leading to new editions, each one more child-centered than the last. From now on younger children could expect stories written for their particular interest and with the needs of their own limited experience of life kept well to the fore.

What eventually determined the reading of older children was often not the availability of special children’s literature as such but access to books that contained characters, such as young people or animals, with whom they could more easily empathize, or action, such as exploring or fighting, that made few demands on adult maturity or understanding.

The final apotheosis of literary childhood as something to be protected from unpleasant reality came with the arrival in the late 1930s of child-centered best-sellers intend on entertainment at its most escapist. In Britain novelist such as Enid Blyton and Richmal Crompton described children who were always free to have the most unlikely adventures , secure in the knowledge that nothing bad could ever happen to them in the end. The fact that war broke out again during her books’ greatest popularity fails to register at all in the self-enclosed world inhabited by Enid Blyton’s young characters. Reaction against such dream-worlds was inevitable after World War II, coinciding with the growth of paperback sales, children’s libraries and a new spirit of moral and social concern. Urged on by committed publishers and progressive librarians, writers slowly began to explore new areas of interest while also shifting the settings of their plots from the middle-class world to which their chiefly adult patrons had always previously belonged.

Critical emphasis, during this development, has been divided. For some the most important task was to rid children’s books of the social prejudice and exclusiveness no longer found acceptable. Others concentrated more on the positive achievements of contemporary children’s literature. That writers of these works are now often recommended to the attentions of adult as well as child readers echoes the 19th-century belief that children’s literature can be shared by the generations, rather than being a defensive barrier between childhood and the necessary growth towards adult understanding.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('18e91329-6253-5a21-b39b-c447b1bb1b0d', 'e52d9a9e-649c-5146-936e-002faea83580', 1, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the table below.
Choose
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
DATE
FEATURES
AIM
EXAMPLE
Before 1700
Not aimed at young children
Education and morality
Puritanical tract
By the middle of 18th century
Collection of
1
and games
Locate
Read for pleasure
A Little Pretty Pocket Book
(exported to
2
)
Locate
Early 19
th
century
Growing interest in
3
Locate
To be more children-centered
Nursery rhymes and
4
Locate
Late 1930s
Stories of harm-free
5
Locate
Entertainment
Enid Blyton and Richarnal Crompton’s novels

Collection of 1 ____ and games Locate$md$, NULL, ARRAY['.*rhymes.*stories.*','.*stories.*rhymes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('20daae42-30c2-5092-a43f-0bf59d49570f', 'e52d9a9e-649c-5146-936e-002faea83580', 2, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the table below.
Choose
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
DATE
FEATURES
AIM
EXAMPLE
Before 1700
Not aimed at young children
Education and morality
Puritanical tract
By the middle of 18th century
Collection of
1
and games
Locate
Read for pleasure
A Little Pretty Pocket Book
(exported to
2
)
Locate
Early 19
th
century
Growing interest in
3
Locate
To be more children-centered
Nursery rhymes and
4
Locate
Late 1930s
Stories of harm-free
5
Locate
Entertainment
Enid Blyton and Richarnal Crompton’s novels

A Little Pretty Pocket Book (exported to 2 ____ ) Locate$md$, NULL, ARRAY['.*america.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ad06d613-147e-595b-ae87-a324690fd3c3', 'e52d9a9e-649c-5146-936e-002faea83580', 3, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the table below.
Choose
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
DATE
FEATURES
AIM
EXAMPLE
Before 1700
Not aimed at young children
Education and morality
Puritanical tract
By the middle of 18th century
Collection of
1
and games
Locate
Read for pleasure
A Little Pretty Pocket Book
(exported to
2
)
Locate
Early 19
th
century
Growing interest in
3
Locate
To be more children-centered
Nursery rhymes and
4
Locate
Late 1930s
Stories of harm-free
5
Locate
Entertainment
Enid Blyton and Richarnal Crompton’s novels

Growing interest in 3 ____ Locate$md$, NULL, ARRAY['.*folklore.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('61c9d0b9-a4cc-5da9-8f2e-2c7fe980d205', 'e52d9a9e-649c-5146-936e-002faea83580', 4, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the table below.
Choose
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
DATE
FEATURES
AIM
EXAMPLE
Before 1700
Not aimed at young children
Education and morality
Puritanical tract
By the middle of 18th century
Collection of
1
and games
Locate
Read for pleasure
A Little Pretty Pocket Book
(exported to
2
)
Locate
Early 19
th
century
Growing interest in
3
Locate
To be more children-centered
Nursery rhymes and
4
Locate
Late 1930s
Stories of harm-free
5
Locate
Entertainment
Enid Blyton and Richarnal Crompton’s novels

Nursery rhymes and 4 ____ Locate$md$, NULL, ARRAY['.*fairy.*tales.*','.*fairy.*stories.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('839397d2-6a82-59c4-a1d9-8cb2ff59fe2c', 'e52d9a9e-649c-5146-936e-002faea83580', 5, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the table below.
Choose
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
DATE
FEATURES
AIM
EXAMPLE
Before 1700
Not aimed at young children
Education and morality
Puritanical tract
By the middle of 18th century
Collection of
1
and games
Locate
Read for pleasure
A Little Pretty Pocket Book
(exported to
2
)
Locate
Early 19
th
century
Growing interest in
3
Locate
To be more children-centered
Nursery rhymes and
4
Locate
Late 1930s
Stories of harm-free
5
Locate
Entertainment
Enid Blyton and Richarnal Crompton’s novels

Stories of harm-free 5 ____ Locate$md$, NULL, ARRAY['.*fairy.*tales.*','.*fairy.*stories.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0a1a4d3a-d71d-5198-95b1-537b75022cc3', 'e52d9a9e-649c-5146-936e-002faea83580', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-8
Questions 6-8
Look at the following people and the list of statements below.
Match each person with the correct statement.
Write the correct letter
A-E
in boxes
6-8
on your answer sheet.
List of statements
A
Wrote criticisms of children’s literature
B
Used animals to demonstrate the absurdity of fairy tales
C
Was not a writer originally
D
Translated a book into English
E
Didn’t write in the English language
6
Thomas Boreham
Locate
7
Mrs. Sarah trimmer
Locate
8
Grimm Brothers
Locate

6 ____ Thomas Boreham Locate 7 ____ Mrs. Sarah trimmer Locate 8 ____ Grimm Brothers Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48da62df-2758-5606-bd30-973ccdaa3469', '0a1a4d3a-d71d-5198-95b1-537b75022cc3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f037dcad-202f-58d5-a756-3ee720247c04', '0a1a4d3a-d71d-5198-95b1-537b75022cc3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7231b655-29a0-5f77-8a48-9f752f81ebf1', '0a1a4d3a-d71d-5198-95b1-537b75022cc3', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8233be9d-020e-5864-8245-5f770db4217c', '0a1a4d3a-d71d-5198-95b1-537b75022cc3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bb28c0a-2d5d-5f49-b7c5-13f69befea9f', '0a1a4d3a-d71d-5198-95b1-537b75022cc3', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('52f1855e-2084-5f6d-ae82-8477a8a2ec17', 'e52d9a9e-649c-5146-936e-002faea83580', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-8
Questions 6-8
Look at the following people and the list of statements below.
Match each person with the correct statement.
Write the correct letter
A-E
in boxes
6-8
on your answer sheet.
List of statements
A
Wrote criticisms of children’s literature
B
Used animals to demonstrate the absurdity of fairy tales
C
Was not a writer originally
D
Translated a book into English
E
Didn’t write in the English language
6
Thomas Boreham
Locate
7
Mrs. Sarah trimmer
Locate
8
Grimm Brothers
Locate

6 ____ Thomas Boreham Locate 7 ____ Mrs. Sarah trimmer Locate 8 ____ Grimm Brothers Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd366794-449b-5fdf-87d9-5514dc1bfa36', '52f1855e-2084-5f6d-ae82-8477a8a2ec17', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0742bfe-7338-527d-87a2-7e5f8535721f', '52f1855e-2084-5f6d-ae82-8477a8a2ec17', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1500551-b598-5fa1-9bc4-5f738ff859b0', '52f1855e-2084-5f6d-ae82-8477a8a2ec17', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c16d5ef3-8a2c-5a62-b8e2-fcecf45d12b8', '52f1855e-2084-5f6d-ae82-8477a8a2ec17', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('542ab65f-f472-50f5-b5c6-21e789e7647a', '52f1855e-2084-5f6d-ae82-8477a8a2ec17', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('de12b166-fc0b-58df-8df0-12577a4977b3', 'e52d9a9e-649c-5146-936e-002faea83580', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-8
Questions 6-8
Look at the following people and the list of statements below.
Match each person with the correct statement.
Write the correct letter
A-E
in boxes
6-8
on your answer sheet.
List of statements
A
Wrote criticisms of children’s literature
B
Used animals to demonstrate the absurdity of fairy tales
C
Was not a writer originally
D
Translated a book into English
E
Didn’t write in the English language
6
Thomas Boreham
Locate
7
Mrs. Sarah trimmer
Locate
8
Grimm Brothers
Locate

6 ____ Thomas Boreham Locate 7 ____ Mrs. Sarah trimmer Locate 8 ____ Grimm Brothers Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e77f9fef-c58c-5356-9566-029d58632ed1', 'de12b166-fc0b-58df-8df0-12577a4977b3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12ff8602-2526-5a20-aaa2-319231205857', 'de12b166-fc0b-58df-8df0-12577a4977b3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4f287bc-1927-5cbb-bcde-3058387c6f45', 'de12b166-fc0b-58df-8df0-12577a4977b3', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b854266-3009-54cd-ab35-6c41181dd36a', 'de12b166-fc0b-58df-8df0-12577a4977b3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1094d36a-f04e-5f29-b920-a2056cb7f953', 'de12b166-fc0b-58df-8df0-12577a4977b3', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('568381ec-6f03-5a72-92ed-07692ce2ce26', 'e52d9a9e-649c-5146-936e-002faea83580', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
Children didn’t start to read books until 1700.
Locate
10
Sarah Trimmer believed that children’s books should set good examples.
Locate
11
Parents were concerned about the violence in children’s books.
12
An interest in the folklore changed the direction of the development of children’s books.
Locate
13
Today children’s book writers believe their works should appeal to both children and adults.
Locate

9 ____ Children didn’t start to read books until 1700. Locate 10 ____ Sarah Trimmer believed that children’s books should set good examples. Locate 11 ____ Parents were concerned about the violence in children’s books. 12 ____ An interest in the folklore changed the direction of the development of children’s books. Locate 13 ____ Today children’s book writers believe their works should appeal to both children and adults. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52c98553-d102-57d9-9359-467cfcce5e76', '568381ec-6f03-5a72-92ed-07692ce2ce26', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48ce81bb-7423-5e6b-8ed7-ad49971935fd', '568381ec-6f03-5a72-92ed-07692ce2ce26', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d764766d-801e-5fd9-973e-76c1c6cc3383', '568381ec-6f03-5a72-92ed-07692ce2ce26', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f6594f1a-370b-5feb-b0ad-c47226308eb1', 'e52d9a9e-649c-5146-936e-002faea83580', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
Children didn’t start to read books until 1700.
Locate
10
Sarah Trimmer believed that children’s books should set good examples.
Locate
11
Parents were concerned about the violence in children’s books.
12
An interest in the folklore changed the direction of the development of children’s books.
Locate
13
Today children’s book writers believe their works should appeal to both children and adults.
Locate

9 ____ Children didn’t start to read books until 1700. Locate 10 ____ Sarah Trimmer believed that children’s books should set good examples. Locate 11 ____ Parents were concerned about the violence in children’s books. 12 ____ An interest in the folklore changed the direction of the development of children’s books. Locate 13 ____ Today children’s book writers believe their works should appeal to both children and adults. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae912b8f-aec2-58da-b511-fb7e62b60293', 'f6594f1a-370b-5feb-b0ad-c47226308eb1', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5d0b191-2b32-5ad9-aad8-53f22c4c2e9e', 'f6594f1a-370b-5feb-b0ad-c47226308eb1', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4db538d5-400a-5abf-9dcc-c661f7b946e3', 'f6594f1a-370b-5feb-b0ad-c47226308eb1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d74b2b31-5ad7-5074-be91-7c16d8c8fc3b', 'e52d9a9e-649c-5146-936e-002faea83580', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
Children didn’t start to read books until 1700.
Locate
10
Sarah Trimmer believed that children’s books should set good examples.
Locate
11
Parents were concerned about the violence in children’s books.
12
An interest in the folklore changed the direction of the development of children’s books.
Locate
13
Today children’s book writers believe their works should appeal to both children and adults.
Locate

9 ____ Children didn’t start to read books until 1700. Locate 10 ____ Sarah Trimmer believed that children’s books should set good examples. Locate 11 ____ Parents were concerned about the violence in children’s books. 12 ____ An interest in the folklore changed the direction of the development of children’s books. Locate 13 ____ Today children’s book writers believe their works should appeal to both children and adults. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00f4fc32-e6d3-56b8-a60b-b1a6fed90be5', 'd74b2b31-5ad7-5074-be91-7c16d8c8fc3b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c260d5b-ea5a-5290-bcb2-012a1dd1f019', 'd74b2b31-5ad7-5074-be91-7c16d8c8fc3b', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5337e802-395d-5241-a4ab-8f6e81c3af07', 'd74b2b31-5ad7-5074-be91-7c16d8c8fc3b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('34c5b7a0-3114-5fc3-a655-61b1477345c3', 'e52d9a9e-649c-5146-936e-002faea83580', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
Children didn’t start to read books until 1700.
Locate
10
Sarah Trimmer believed that children’s books should set good examples.
Locate
11
Parents were concerned about the violence in children’s books.
12
An interest in the folklore changed the direction of the development of children’s books.
Locate
13
Today children’s book writers believe their works should appeal to both children and adults.
Locate

9 ____ Children didn’t start to read books until 1700. Locate 10 ____ Sarah Trimmer believed that children’s books should set good examples. Locate 11 ____ Parents were concerned about the violence in children’s books. 12 ____ An interest in the folklore changed the direction of the development of children’s books. Locate 13 ____ Today children’s book writers believe their works should appeal to both children and adults. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f70b889e-c029-50d8-bcdc-3c5e37ba6fd4', '34c5b7a0-3114-5fc3-a655-61b1477345c3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('104fda3b-7a39-5874-802d-ad5b115565f6', '34c5b7a0-3114-5fc3-a655-61b1477345c3', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77e216d3-61cf-58b9-bbb3-9286c2318b02', '34c5b7a0-3114-5fc3-a655-61b1477345c3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4b43a88b-3c00-56f1-aea1-c689375752ad', 'e52d9a9e-649c-5146-936e-002faea83580', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
Children didn’t start to read books until 1700.
Locate
10
Sarah Trimmer believed that children’s books should set good examples.
Locate
11
Parents were concerned about the violence in children’s books.
12
An interest in the folklore changed the direction of the development of children’s books.
Locate
13
Today children’s book writers believe their works should appeal to both children and adults.
Locate

9 ____ Children didn’t start to read books until 1700. Locate 10 ____ Sarah Trimmer believed that children’s books should set good examples. Locate 11 ____ Parents were concerned about the violence in children’s books. 12 ____ An interest in the folklore changed the direction of the development of children’s books. Locate 13 ____ Today children’s book writers believe their works should appeal to both children and adults. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e9c73a5-884b-595e-9db2-ad24c31d9f52', '4b43a88b-3c00-56f1-aea1-c689375752ad', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('860761a3-7efc-59bc-8b1a-18d124e441a4', '4b43a88b-3c00-56f1-aea1-c689375752ad', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d46a879f-51ae-540a-ba66-87140f489497', '4b43a88b-3c00-56f1-aea1-c689375752ad', 3, $md$NOT GIVEN$md$, false);

COMMIT;
