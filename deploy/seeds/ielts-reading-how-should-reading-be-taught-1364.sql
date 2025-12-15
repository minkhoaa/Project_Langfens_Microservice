BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-how-should-reading-be-taught-1364'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-should-reading-be-taught-1364';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-should-reading-be-taught-1364';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-how-should-reading-be-taught-1364';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('3c0cfed7-c450-5d14-94a9-18a812eb1485', 'ielts-reading-how-should-reading-be-taught-1364', $t$How should reading be taught?$t$, $md$## How should reading be taught?

Nguồn:
- Test: https://mini-ielts.com/1364/reading/how-should-reading-be-taught
- Solution: https://mini-ielts.com/1364/view-solution/reading/how-should-reading-be-taught$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('cebd4f14-df85-5483-a16c-036212a30bef', '3c0cfed7-c450-5d14-94a9-18a812eb1485', 1, $t$Reading — How should reading be taught?$t$, $md$Read the passage and answer questions **1–14**.

### Passage: How should reading be taught?

By Keith Rayncr a Barbara R Foorman

A

Learning to speak is automatic for almost all children, but learning to read requires elaborate instruction and conscious effort. Well aware of the difficulties, educators have given a great deal of thought to how they can best help children learn to read. No single method has triumphed. Indeed, heated arguments about the most appropriate form of reading instruction continue to polarize the teaching community.

B

Three general approaches have been tried. In one, called whole-word instruction, children learn by rote how to recognise at a glance a vocabulary of 50 to 100 words. Then they gradually acquire other words, often through seeing them used over and over again in the context of a story.

Speakers of most languages learn the relationship between letters and the sounds associated with them (phonemes). That is, children are taught how to use their knowledge of the alphabet to sound out words. This procedure constitutes a second approach to teaching reading – phonics.

Many schools have adopted a different approach: the whole-language method. The strategy here relies on the child’s experience with the language. For example, students are offered engaging books and are encouraged to guess the words that they do not know by considering the context of the sentence or by looking for clues in the storyline and illustrations, rather than trying to sound them out.

Many teachers adopted the whole-language approach because of its intuitive appeal. Making reading fun promises to keep children motivated, and learning to read depends more on what the student does than on what the teacher does. The presumed benefits of whole-language instruction – and the contrast to the perceived dullness of phonics – led to its growing acceptance across American during the 1990s and a movement away from phonics.

C

However, many linguists and psychologists objected strongly to the abandonment of phonics in American schools. Why was this so? In short, because research had clearly demonstrated that understanding how letters related to the component sounds in words is critically important in reading. This conclusion rests, in part, on knowledge of how experienced readers make sense of words on a page. Advocates of whole-language instruction have argued forcefully that people often derive meanings directly from print without ever determining the sound of the word. Some psychologists today accept this view, but most believe that reading is typically a process of rapidly sounding out words mentally. Compelling evidence for this comes from experiments which show that subjects often confuse homophones (words that sound the same, such as Jrose and ‘rows5). This supports the idea that readers convert strings of letters to sounds.

D

In order to evaluate different approaches to teaching reading, a number of experiments have been carried out, firstly with college students, then with school pupils. Investigators trained English-speaking college students to read using unfamiliar symbols such as Arabic letters (the phonics approach), while another group learned entire words associated with certain strings of Arabic letters (whole-word). Then both groups were required to read a new set of words constructed from the original characters. In general, readers who were taught the rules of phonics could read many more new words than those trained with a whole-word procedure.

Classroom studies comparing phonics with either whole-word or whole-language instruction are also quite illuminating. One particularly persuasive study compared two programmes used in 20 first-grade classrooms. Half the students were offered traditional reading instruction, which included the use of phonics drills and applications. The other half were taught using an individualised method that drew from their experiences with languages; these children produce their own booklets of stories and developed sets of words to be recognised (common components of the whole-language approach). This study found that the first group scored higher at year’s end on tests of reading and comprehension.

E

If researchers are so convinced about the need for phonics instruction, why does the debate continue? Because the controversy is enmeshed in the philosophical differences between traditional and progressive (or new) approaches, differences that have divided educators for years. The progressive challenge the results of laboratory tests and classroom studies on the basis of a broad philosophical skepticism about the values of such research. They champion student-centred learned and teacher empowerment. Sadly, they fail to realise that these very admirable educational values are equally consistent with the teaching of phonics.

F

If schools of education insisted that would-be reading teachers learned something about the vast research in linguistics and psychology that bears on reading, their graduates would be more eager to use phonics and would be prepared to do so effectively. They could allow their pupils to apply the principles of phonics while reading for pleasure. Using whole-language activities to supplement phonics instruction certainly helps to make reading fun and meaningful for children, so no one would want to see such tools discarded. Indeed, recent work has indicated that the combination of literature-based instruction and phonics is more powerful than either method used alone.

Teachers need to strike a balance. But in doing so, we urge them to remember that reading must be grounded in a firm understanding of the connections between letters and sounds. Educators who deny this reality are neglecting decades of research. They are also neglecting the needs of their students.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a0722c34-4e3f-539a-b36f-a4821cdb79fc', 'cebd4f14-df85-5483-a16c-036212a30bef', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage has six sections,
A-F
.
Choose the correct heading for sections
B-F
from the list of headings below.
Write the correct number,
i-ix
, in boxes
1-5
on your answer sheet.
List of Headings
i
Disagreement about the reading process
ii
The roots of the debate
iii
A combined approach
iv
Methods of teaching reading
v
A controversial approach
vi
Inconclusive research
vii
Research with learners
vii
Allowing teachers more control
ix
A debate amongst educators
Example
Section
A
ix
1
Section B
2
Section C
3
Section D
4
Section E
5
Section F

1 ____ Section B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf23b816-4738-5c4e-9309-f6e17f44cce6', 'a0722c34-4e3f-539a-b36f-a4821cdb79fc', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df8b1e7d-7a35-5126-b3c2-9a4b1fddc188', 'a0722c34-4e3f-539a-b36f-a4821cdb79fc', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b83e5b80-c942-5f54-b01e-37bed07e1b72', 'a0722c34-4e3f-539a-b36f-a4821cdb79fc', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e94741bc-7057-5dc1-adb9-adf1ad6fe0bc', 'a0722c34-4e3f-539a-b36f-a4821cdb79fc', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('269bb58e-5a8b-5ed6-8ce1-a852762f4dd7', 'a0722c34-4e3f-539a-b36f-a4821cdb79fc', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a70117c-bbcf-52fc-9971-b8e068084212', 'a0722c34-4e3f-539a-b36f-a4821cdb79fc', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ab1a860-5178-5038-8dc1-2ea7c75dd4a9', 'a0722c34-4e3f-539a-b36f-a4821cdb79fc', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('568e3099-1fd4-55cf-8a7f-1a6d7fed036f', 'a0722c34-4e3f-539a-b36f-a4821cdb79fc', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f8787d1-167f-58d8-915b-9b67f7dc7d73', 'a0722c34-4e3f-539a-b36f-a4821cdb79fc', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8649d93-65b1-5df4-880a-d300fdd83ff4', 'a0722c34-4e3f-539a-b36f-a4821cdb79fc', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f6362690-06a7-51b1-a1eb-a901181061a6', 'cebd4f14-df85-5483-a16c-036212a30bef', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage has six sections,
A-F
.
Choose the correct heading for sections
B-F
from the list of headings below.
Write the correct number,
i-ix
, in boxes
1-5
on your answer sheet.
List of Headings
i
Disagreement about the reading process
ii
The roots of the debate
iii
A combined approach
iv
Methods of teaching reading
v
A controversial approach
vi
Inconclusive research
vii
Research with learners
vii
Allowing teachers more control
ix
A debate amongst educators
Example
Section
A
ix
1
Section B
2
Section C
3
Section D
4
Section E
5
Section F

2 ____ Section C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a261d8fc-39ac-543c-a578-3ed551bd8efb', 'f6362690-06a7-51b1-a1eb-a901181061a6', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('008473b9-a730-5f70-978c-b350df8da807', 'f6362690-06a7-51b1-a1eb-a901181061a6', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ecfd1b1-a0c3-52b4-9f6d-0eeb44d42c55', 'f6362690-06a7-51b1-a1eb-a901181061a6', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a0124f2-e412-54c2-bd17-7a28632cf804', 'f6362690-06a7-51b1-a1eb-a901181061a6', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53aa7c63-b0e2-5dc4-9d32-b958ffbe9d9c', 'f6362690-06a7-51b1-a1eb-a901181061a6', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62d2416b-4673-5b30-82f8-e7caa6131a4d', 'f6362690-06a7-51b1-a1eb-a901181061a6', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6ba9a17-e5b9-5275-908d-5811d9c1d1e6', 'f6362690-06a7-51b1-a1eb-a901181061a6', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9cde195-38b8-5465-9e25-41129558d7c8', 'f6362690-06a7-51b1-a1eb-a901181061a6', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a235ce46-57d1-54f5-9e4b-735ff45f04c2', 'f6362690-06a7-51b1-a1eb-a901181061a6', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8958e3ba-0665-56d0-a51a-faeeb0b5242f', 'f6362690-06a7-51b1-a1eb-a901181061a6', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('346fffeb-4ab1-584c-851b-2a8d64a41768', 'cebd4f14-df85-5483-a16c-036212a30bef', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage has six sections,
A-F
.
Choose the correct heading for sections
B-F
from the list of headings below.
Write the correct number,
i-ix
, in boxes
1-5
on your answer sheet.
List of Headings
i
Disagreement about the reading process
ii
The roots of the debate
iii
A combined approach
iv
Methods of teaching reading
v
A controversial approach
vi
Inconclusive research
vii
Research with learners
vii
Allowing teachers more control
ix
A debate amongst educators
Example
Section
A
ix
1
Section B
2
Section C
3
Section D
4
Section E
5
Section F

3 ____ Section D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee72f4f3-5690-53b3-aff5-a4d00220ab09', '346fffeb-4ab1-584c-851b-2a8d64a41768', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9dc5e4e-22bc-568f-821e-ae4a7c4ad68b', '346fffeb-4ab1-584c-851b-2a8d64a41768', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c569d547-8171-5546-8311-8831ab57275f', '346fffeb-4ab1-584c-851b-2a8d64a41768', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7070a8b6-723a-5b82-971a-60bd24759066', '346fffeb-4ab1-584c-851b-2a8d64a41768', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7d90539-5cf9-519f-8e00-a1185a5d5c66', '346fffeb-4ab1-584c-851b-2a8d64a41768', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42f47ca8-757f-5856-accf-d265d783f65c', '346fffeb-4ab1-584c-851b-2a8d64a41768', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7dc55265-5a7f-5584-8a4b-91b20d52c328', '346fffeb-4ab1-584c-851b-2a8d64a41768', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0972f5c0-234b-589d-a5ed-5ab8321567c1', '346fffeb-4ab1-584c-851b-2a8d64a41768', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f70ef15d-3f5e-567e-ae20-b95a9e2e75db', '346fffeb-4ab1-584c-851b-2a8d64a41768', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fc9047c-9ee8-59e8-9a38-c1e975426ad3', '346fffeb-4ab1-584c-851b-2a8d64a41768', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5913f4ef-3e20-5ef0-8fb0-2d16f50302ec', 'cebd4f14-df85-5483-a16c-036212a30bef', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage has six sections,
A-F
.
Choose the correct heading for sections
B-F
from the list of headings below.
Write the correct number,
i-ix
, in boxes
1-5
on your answer sheet.
List of Headings
i
Disagreement about the reading process
ii
The roots of the debate
iii
A combined approach
iv
Methods of teaching reading
v
A controversial approach
vi
Inconclusive research
vii
Research with learners
vii
Allowing teachers more control
ix
A debate amongst educators
Example
Section
A
ix
1
Section B
2
Section C
3
Section D
4
Section E
5
Section F

4 ____ Section E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58876874-6a35-5ea6-935f-0eb6df781eed', '5913f4ef-3e20-5ef0-8fb0-2d16f50302ec', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8dfed4a-80b9-509a-9eb2-bf7fe4438f31', '5913f4ef-3e20-5ef0-8fb0-2d16f50302ec', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('744a8816-21f6-500f-bb0d-af9efe711f3c', '5913f4ef-3e20-5ef0-8fb0-2d16f50302ec', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46c28b8d-adcb-5f2d-8583-860d4ad87b96', '5913f4ef-3e20-5ef0-8fb0-2d16f50302ec', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('285bf049-542f-50c1-8c4b-656a88d0faac', '5913f4ef-3e20-5ef0-8fb0-2d16f50302ec', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d18db5d3-9994-5038-9d5c-4e040e0a7e6c', '5913f4ef-3e20-5ef0-8fb0-2d16f50302ec', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23d020e4-6438-522a-b7e7-f55ad7b3e8c1', '5913f4ef-3e20-5ef0-8fb0-2d16f50302ec', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad80113e-9b65-5cd5-8f87-4738b9355cac', '5913f4ef-3e20-5ef0-8fb0-2d16f50302ec', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be8a1ef6-ea7c-5fc5-bcd2-8b772156f91a', '5913f4ef-3e20-5ef0-8fb0-2d16f50302ec', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ff68be7-43f8-505e-8425-99cb0f054ad1', '5913f4ef-3e20-5ef0-8fb0-2d16f50302ec', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('941568ee-985e-5d40-b4c3-39df983c3fb9', 'cebd4f14-df85-5483-a16c-036212a30bef', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage has six sections,
A-F
.
Choose the correct heading for sections
B-F
from the list of headings below.
Write the correct number,
i-ix
, in boxes
1-5
on your answer sheet.
List of Headings
i
Disagreement about the reading process
ii
The roots of the debate
iii
A combined approach
iv
Methods of teaching reading
v
A controversial approach
vi
Inconclusive research
vii
Research with learners
vii
Allowing teachers more control
ix
A debate amongst educators
Example
Section
A
ix
1
Section B
2
Section C
3
Section D
4
Section E
5
Section F

5 ____ Section F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('606ff1b7-23ea-58fd-a321-a32c5f3632c9', '941568ee-985e-5d40-b4c3-39df983c3fb9', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37359a2c-76de-5cfe-b8cb-d4667320237a', '941568ee-985e-5d40-b4c3-39df983c3fb9', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d00031c5-3c09-536e-86f0-ebd3e112e18b', '941568ee-985e-5d40-b4c3-39df983c3fb9', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('501abf05-e293-5739-a52b-92ab98bcf0b4', '941568ee-985e-5d40-b4c3-39df983c3fb9', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0dea669b-5c0d-5919-9df0-2f6ea2b054e0', '941568ee-985e-5d40-b4c3-39df983c3fb9', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74d712c3-f0c2-5e49-8db2-eed13dd335bc', '941568ee-985e-5d40-b4c3-39df983c3fb9', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a1fb853-9c9b-513a-81b4-7179cac266d7', '941568ee-985e-5d40-b4c3-39df983c3fb9', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('324128bc-9e89-57a0-9d30-0a1118f6b53c', '941568ee-985e-5d40-b4c3-39df983c3fb9', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8f85f40-416d-5242-95e5-c9b30c3bd1cc', '941568ee-985e-5d40-b4c3-39df983c3fb9', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8cea74f5-98f1-5a8d-b6c8-dec1445ed709', '941568ee-985e-5d40-b4c3-39df983c3fb9', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8e6c9099-2d6c-5f02-890e-441c47e9ba94', 'cebd4f14-df85-5483-a16c-036212a30bef', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in Reading Passage?
In boxes
6-10
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
The whole-language approach relates letters to sounds.
7
Many educators believe the whole-language approach to be the most interesting way to teach children to read.
8
Research supports the theory that we read without linking words to sounds.
9
Research has shown that the whole-word approach is less effective than the whole-language approach.
10
Research has shown that phonics is more successful than both the whole-word and whole-language approaches.

6 ____ The whole-language approach relates letters to sounds.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('395c2bf7-91fd-5450-9e02-9f2ddce12cdc', '8e6c9099-2d6c-5f02-890e-441c47e9ba94', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd8df0f6-ba89-5616-a2aa-f3842a13f021', '8e6c9099-2d6c-5f02-890e-441c47e9ba94', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7d8b268-bf24-543b-95ed-c1a8a96cb8bb', '8e6c9099-2d6c-5f02-890e-441c47e9ba94', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d218f649-21f3-51fb-8c1c-13971fe51443', 'cebd4f14-df85-5483-a16c-036212a30bef', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in Reading Passage?
In boxes
6-10
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
The whole-language approach relates letters to sounds.
7
Many educators believe the whole-language approach to be the most interesting way to teach children to read.
8
Research supports the theory that we read without linking words to sounds.
9
Research has shown that the whole-word approach is less effective than the whole-language approach.
10
Research has shown that phonics is more successful than both the whole-word and whole-language approaches.

7 ____ Many educators believe the whole-language approach to be the most interesting way to teach children to read.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9b5d89a-82c9-537d-b612-d3808a0a5870', 'd218f649-21f3-51fb-8c1c-13971fe51443', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('629dbe4d-3a26-57c5-b1dd-badb54a8a240', 'd218f649-21f3-51fb-8c1c-13971fe51443', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6d265a4-116f-5cce-937a-eca5301cb098', 'd218f649-21f3-51fb-8c1c-13971fe51443', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('37e09ffc-5fa6-5cd3-b93b-3a3226b17d2f', 'cebd4f14-df85-5483-a16c-036212a30bef', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in Reading Passage?
In boxes
6-10
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
The whole-language approach relates letters to sounds.
7
Many educators believe the whole-language approach to be the most interesting way to teach children to read.
8
Research supports the theory that we read without linking words to sounds.
9
Research has shown that the whole-word approach is less effective than the whole-language approach.
10
Research has shown that phonics is more successful than both the whole-word and whole-language approaches.

8 ____ Research supports the theory that we read without linking words to sounds.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be40788d-12d1-59c5-a5a2-d6367cb90b49', '37e09ffc-5fa6-5cd3-b93b-3a3226b17d2f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2a46421-0268-5361-8004-15bc5eb1c4ec', '37e09ffc-5fa6-5cd3-b93b-3a3226b17d2f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d51cea28-efc4-5112-8d07-df9d26affb05', '37e09ffc-5fa6-5cd3-b93b-3a3226b17d2f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('184ebbb0-88cb-5779-93d9-10ad8cfac12e', 'cebd4f14-df85-5483-a16c-036212a30bef', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in Reading Passage?
In boxes
6-10
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
The whole-language approach relates letters to sounds.
7
Many educators believe the whole-language approach to be the most interesting way to teach children to read.
8
Research supports the theory that we read without linking words to sounds.
9
Research has shown that the whole-word approach is less effective than the whole-language approach.
10
Research has shown that phonics is more successful than both the whole-word and whole-language approaches.

9 ____ Research has shown that the whole-word approach is less effective than the whole-language approach.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3570aa5-16b6-5673-b730-effa7486f288', '184ebbb0-88cb-5779-93d9-10ad8cfac12e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b648307-892a-5fbd-a005-f4975020bfe9', '184ebbb0-88cb-5779-93d9-10ad8cfac12e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04336452-306d-5ca8-86f2-a32af51867db', '184ebbb0-88cb-5779-93d9-10ad8cfac12e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('999c2b11-48f7-5835-a3ad-b0528e57e6e4', 'cebd4f14-df85-5483-a16c-036212a30bef', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in Reading Passage?
In boxes
6-10
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
6
The whole-language approach relates letters to sounds.
7
Many educators believe the whole-language approach to be the most interesting way to teach children to read.
8
Research supports the theory that we read without linking words to sounds.
9
Research has shown that the whole-word approach is less effective than the whole-language approach.
10
Research has shown that phonics is more successful than both the whole-word and whole-language approaches.

10 ____ Research has shown that phonics is more successful than both the whole-word and whole-language approaches.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31d4670c-48ef-5984-9799-3b284c8359a3', '999c2b11-48f7-5835-a3ad-b0528e57e6e4', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec03c66d-d6a3-5351-bca7-a53ac7a513b6', '999c2b11-48f7-5835-a3ad-b0528e57e6e4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fa59912-0b2d-55a1-ac11-61547317faf6', '999c2b11-48f7-5835-a3ad-b0528e57e6e4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3caf6bc4-a6e3-59f9-9eb7-b89a6117d98d', 'cebd4f14-df85-5483-a16c-036212a30bef', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete the summary of sections
E
and
F
using the list of words,
A-G
, below.
Write the correct letter,
A-G
, in boxes
11-14
on your answer sheet.
In the teaching community,
11
question the usefulness of research into methods of teaching reading. These critics believe that
12
is incompatible with student-centred learning. In the future, teachers need to be aware of
13
so that they understand the importance of phonics. They should not, however, ignore the ideas of
14
which make reading enjoyable for learners.
A
the phonics method
B
the whole-word method
C
the whole-language method
D
traditionalists
E
progressives
F
linguistics
G
research studies

In the teaching community, 11 ____ question the usefulness of research into methods of teaching reading. These critics believe that 12 ____ is incompatible with student-centred learning. In the future, teachers need to be aware of 13 ____ so that they understand the importance of phonics. They should not, however, ignore the ideas of 14 ____ which make reading enjoyable for learners.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0798ae7-f804-5dea-b43b-c27e061d77c3', '3caf6bc4-a6e3-59f9-9eb7-b89a6117d98d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab4278df-5e7f-5148-a714-d8a6d22dac3c', '3caf6bc4-a6e3-59f9-9eb7-b89a6117d98d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ff8289d-d92b-5525-b694-a65938631f88', '3caf6bc4-a6e3-59f9-9eb7-b89a6117d98d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('063efb4d-3bc9-541e-9d83-0926a3f96d38', '3caf6bc4-a6e3-59f9-9eb7-b89a6117d98d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1da21de-44ad-594a-8a15-cf685f2bea82', '3caf6bc4-a6e3-59f9-9eb7-b89a6117d98d', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6229f7ed-e482-5c45-be41-329c6b21b9d1', '3caf6bc4-a6e3-59f9-9eb7-b89a6117d98d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aba69dbc-1001-5936-b0be-b933dbb681a9', '3caf6bc4-a6e3-59f9-9eb7-b89a6117d98d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cc73715c-86e4-5dab-8098-a6f7f51e92ea', 'cebd4f14-df85-5483-a16c-036212a30bef', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete the summary of sections
E
and
F
using the list of words,
A-G
, below.
Write the correct letter,
A-G
, in boxes
11-14
on your answer sheet.
In the teaching community,
11
question the usefulness of research into methods of teaching reading. These critics believe that
12
is incompatible with student-centred learning. In the future, teachers need to be aware of
13
so that they understand the importance of phonics. They should not, however, ignore the ideas of
14
which make reading enjoyable for learners.
A
the phonics method
B
the whole-word method
C
the whole-language method
D
traditionalists
E
progressives
F
linguistics
G
research studies

In the teaching community, 11 ____ question the usefulness of research into methods of teaching reading. These critics believe that 12 ____ is incompatible with student-centred learning. In the future, teachers need to be aware of 13 ____ so that they understand the importance of phonics. They should not, however, ignore the ideas of 14 ____ which make reading enjoyable for learners.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28728522-ab6c-5df6-82f1-c154d0963310', 'cc73715c-86e4-5dab-8098-a6f7f51e92ea', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('733adb6a-9597-5282-b596-7c4d04157e07', 'cc73715c-86e4-5dab-8098-a6f7f51e92ea', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a8fba33-13df-5d82-bb0e-bc995863a1a3', 'cc73715c-86e4-5dab-8098-a6f7f51e92ea', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac613ae1-6cb3-5cd1-b3ae-f742f21ade8f', 'cc73715c-86e4-5dab-8098-a6f7f51e92ea', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4351e5d4-d728-5e5e-8f88-e54ee42464b1', 'cc73715c-86e4-5dab-8098-a6f7f51e92ea', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a87d06ce-0b97-5e56-ab94-dfe62e6a1e9c', 'cc73715c-86e4-5dab-8098-a6f7f51e92ea', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e32c5ea-118d-5b50-9266-c46a5e03cc40', 'cc73715c-86e4-5dab-8098-a6f7f51e92ea', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b9fdff4e-4587-5564-b684-5079ff91efee', 'cebd4f14-df85-5483-a16c-036212a30bef', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete the summary of sections
E
and
F
using the list of words,
A-G
, below.
Write the correct letter,
A-G
, in boxes
11-14
on your answer sheet.
In the teaching community,
11
question the usefulness of research into methods of teaching reading. These critics believe that
12
is incompatible with student-centred learning. In the future, teachers need to be aware of
13
so that they understand the importance of phonics. They should not, however, ignore the ideas of
14
which make reading enjoyable for learners.
A
the phonics method
B
the whole-word method
C
the whole-language method
D
traditionalists
E
progressives
F
linguistics
G
research studies

In the teaching community, 11 ____ question the usefulness of research into methods of teaching reading. These critics believe that 12 ____ is incompatible with student-centred learning. In the future, teachers need to be aware of 13 ____ so that they understand the importance of phonics. They should not, however, ignore the ideas of 14 ____ which make reading enjoyable for learners.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87188870-a592-5a55-87d3-df1114919ee4', 'b9fdff4e-4587-5564-b684-5079ff91efee', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52dc6131-642b-5e43-86b1-caaf67cfed6a', 'b9fdff4e-4587-5564-b684-5079ff91efee', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db62d1e8-7b70-5dd0-b2d2-1490b2fe9982', 'b9fdff4e-4587-5564-b684-5079ff91efee', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c1b1866-b244-53b8-b46e-2f018df959fb', 'b9fdff4e-4587-5564-b684-5079ff91efee', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4f0e8e6-b6fa-5284-9647-35ec44e9cadb', 'b9fdff4e-4587-5564-b684-5079ff91efee', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('821b77f6-68ab-5911-b9f3-a82d5aed36fd', 'b9fdff4e-4587-5564-b684-5079ff91efee', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c9777f1-b937-57c5-a2ad-09542331cf75', 'b9fdff4e-4587-5564-b684-5079ff91efee', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2c181972-297f-5a38-b6b2-af39f74c4cb9', 'cebd4f14-df85-5483-a16c-036212a30bef', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete the summary of sections
E
and
F
using the list of words,
A-G
, below.
Write the correct letter,
A-G
, in boxes
11-14
on your answer sheet.
In the teaching community,
11
question the usefulness of research into methods of teaching reading. These critics believe that
12
is incompatible with student-centred learning. In the future, teachers need to be aware of
13
so that they understand the importance of phonics. They should not, however, ignore the ideas of
14
which make reading enjoyable for learners.
A
the phonics method
B
the whole-word method
C
the whole-language method
D
traditionalists
E
progressives
F
linguistics
G
research studies

In the teaching community, 11 ____ question the usefulness of research into methods of teaching reading. These critics believe that 12 ____ is incompatible with student-centred learning. In the future, teachers need to be aware of 13 ____ so that they understand the importance of phonics. They should not, however, ignore the ideas of 14 ____ which make reading enjoyable for learners.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('778d1f12-7500-54cf-a21b-18beaa6b41d7', '2c181972-297f-5a38-b6b2-af39f74c4cb9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67f8ed8c-0f6f-51b3-b9fb-aafbd41ca6cc', '2c181972-297f-5a38-b6b2-af39f74c4cb9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ccc8086-8928-5cea-8988-4b093f921bfc', '2c181972-297f-5a38-b6b2-af39f74c4cb9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2b5f182-60d5-55fd-8bcd-76d3376dedf8', '2c181972-297f-5a38-b6b2-af39f74c4cb9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b8ee390-959e-5c71-adfb-dacac9f4d832', '2c181972-297f-5a38-b6b2-af39f74c4cb9', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19db0a14-dd7e-58f7-83a6-6890526632f9', '2c181972-297f-5a38-b6b2-af39f74c4cb9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0131074-aaa6-5c2f-9bc4-2c2fc15a5a94', '2c181972-297f-5a38-b6b2-af39f74c4cb9', 7, $md$G$md$, false);

COMMIT;
