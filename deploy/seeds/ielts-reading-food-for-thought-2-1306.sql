BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-food-for-thought-2-1306'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-food-for-thought-2-1306';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-food-for-thought-2-1306';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-food-for-thought-2-1306';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('e4b0f0f8-b49b-55a3-9877-c782c4259af6', 'ielts-reading-food-for-thought-2-1306', $t$Food for thought 2$t$, $md$## Food for thought 2

Nguồn:
- Test: https://mini-ielts.com/1306/reading/food-for-thought-2
- Solution: https://mini-ielts.com/1306/view-solution/reading/food-for-thought-2$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 'e4b0f0f8-b49b-55a3-9877-c782c4259af6', 1, $t$Reading — Food for thought 2$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Food for thought 2

A

There are not enough classrooms at the Msekeni primary school, so half the lessons take place in the shade of yellow-blossomed acacia trees. Given this shortage, it might seem odd that one of the school’s purpose-built classrooms has been emptied of pupils and turned into a storeroom for sacks of grain. But it makes sense. Food matters more than shelter.

B

Msekeni is in one of the poorer parts of Malawi, a landlocked southern African country of exceptional beauty and great poverty. No war lays waste Malawi, nor is the land unusually crowed or infertile, but Malawians still have trouble finding enough to eat. Half of the children under five are underfed to the point of stunting. Hunger blights most aspects of Malawian life, so the country is as good a place as any to investigate how nutrition affects development, and vice versa.

C

The headmaster at Msekeni, Bernard Kumanda, has strong views on the subject. He thinks food is a priceless teaching aid. Since 1999, his pupils have received free school lunches. Donors such as the World Food Programme (WFP) provide the food: those sacks of grain (mostly mixed maize and soya bean flour, enriched with vitamin A) in that converted classroom. Local volunteers do the cooking – turning the dry ingredients into a bland but nutritious slop and spooning it out on to plastic plates. The children line up in large crowds, cheerfully singing a song called “We are getting porridge”.

D

When the school’s feeding programme was introduced, enrolment at Msekeni doubled. Some of the new pupils had switched from nearby schools that did not give out free porridge, but most were children whose families had previously kept them at home to work. These families were so poor that the long-term benefits of education seemed unattractive when setting against the short-term gain of sending children out to gather firewood or help in the fields. One plate of porridge a day completely altered the calculation. A child fed at school will not howl so plaintively for food at home. Girls, who are more likely than boys to be kept out of school, are given extra snacks to take home.

E

When a school takes in a horde of extra students from the poorest homes, you would expect standards to drop. Anywhere in the world, poor kids tend to perform worse than their better-off classmates. When the influx of new pupils is not accompanied by an increase in the number of teachers, as was the case at Msekeni, you would expect standards to fall even further. But they have not. Pass rates at Msekeni improved dramatically, from 30% to 85%. Although this was an exceptional example, the nationwide results of school feeding programmes were still pretty good. On average, after a Malawian school started handing out free food it attracted 38% more girls and 24% more boys. The pass rate for boys stayed about the same, while for girls it improved by 9.5%.

F

Better nutrition makes for brighter children. Most immediately, well-fed children find it easier to concentrate. It is hard to focus the mind on long division when your stomach is screaming for food. Mr Kumanda says that it used to be easy to spot the kids who were really undernourished. “They were the ones who stared into space and didn’t respond when you asked the question,” he says. More crucially, though, more and better food helps brains grow and develop. Like any other organ in the body, the brain needs nutrition and exercise. But if it is starved of the necessary calories, proteins and micronutrients, it is stunted, perhaps not as severely as a muscle would be, but stunted nonetheless. That is why feeding children at schools work so well. And the fact that the effect of feeding was more pronounced in girls than in boys gives a clue to who eats first in rural Malawian households. It isn’t the girls.

G

On a global scale, the good news is that people are eating better than ever before. Homo sapiens has grown 50% bigger since the industrial revolution. Three centuries ago, chronic malnutrition was more or less universal. Now, it is extremely rare in rich countries. In developing countries, where most people live, plates and rice bowls are also fuller than ever before. The proportion of children under five in the developing world who are malnourished to the point of stunting fell from 39% in 1990 to 30% in 2000, says the World Health Organisation (WHO). In other places, the battle against hunger is steadily being won. Better nutrition is making people cleverer and more energetic, which will help them grow more prosperous. And when they eventually join the ranks of the well off, they can start fretting about growing too fast.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f1b59b6b-b1a9-5355-8cef-e06a2e58ae0f', '97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of Headings
i
Why better food helps students’ learning
ii
A song for getting porridge
iii
Surprising use of school premises
iv
Global perspective
v
Brains can be starved
vi
Surprising academics outcome
vii
Girls are specially treated in the program
viii
How food program is operated
ix
How food program affects school attendance
x
None of the usual reasons
xi
How to maintain an academic standard
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
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph C 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac1c38d0-a559-58cd-9b41-50be71a6ddd9', 'f1b59b6b-b1a9-5355-8cef-e06a2e58ae0f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0004b60-4a49-5bca-8756-5378b29acebb', 'f1b59b6b-b1a9-5355-8cef-e06a2e58ae0f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7e64009-8ab2-5d81-86e1-b668cd8e255c', 'f1b59b6b-b1a9-5355-8cef-e06a2e58ae0f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38d0dff6-d51a-5a29-87ef-0e2363c0f844', 'f1b59b6b-b1a9-5355-8cef-e06a2e58ae0f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7558a21d-45b5-54a5-9e89-6e9b7defceac', 'f1b59b6b-b1a9-5355-8cef-e06a2e58ae0f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88c2f4d9-d082-5c6e-bc8b-9bca23ec8635', 'f1b59b6b-b1a9-5355-8cef-e06a2e58ae0f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4c14552-c70e-541d-88a9-2a20ad35bf9b', 'f1b59b6b-b1a9-5355-8cef-e06a2e58ae0f', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('177d13fe-c490-5d83-ab19-4265ed4b367e', '97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of Headings
i
Why better food helps students’ learning
ii
A song for getting porridge
iii
Surprising use of school premises
iv
Global perspective
v
Brains can be starved
vi
Surprising academics outcome
vii
Girls are specially treated in the program
viii
How food program is operated
ix
How food program affects school attendance
x
None of the usual reasons
xi
How to maintain an academic standard
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
7
Paragraph G

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98ee2a09-8c6f-5153-b4e7-3a82d8a0deb0', '177d13fe-c490-5d83-ab19-4265ed4b367e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96719db9-9714-5ff8-92fc-f647d92febb2', '177d13fe-c490-5d83-ab19-4265ed4b367e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e02db3e0-c5b2-5633-b718-6d4a4e2aaa64', '177d13fe-c490-5d83-ab19-4265ed4b367e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf0e80e6-3c0c-560b-bd41-ce887d25732a', '177d13fe-c490-5d83-ab19-4265ed4b367e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9261fc81-9390-57d2-ba89-ced6fc9b19cd', '177d13fe-c490-5d83-ab19-4265ed4b367e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('834d301c-b963-5c57-895d-f8f6a1292fdb', '177d13fe-c490-5d83-ab19-4265ed4b367e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5db68777-968c-51f5-ae7c-d8c1ba986383', '177d13fe-c490-5d83-ab19-4265ed4b367e', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2f5aa4e2-b896-5e52-a3e3-65901c81d3c8', '97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of Headings
i
Why better food helps students’ learning
ii
A song for getting porridge
iii
Surprising use of school premises
iv
Global perspective
v
Brains can be starved
vi
Surprising academics outcome
vii
Girls are specially treated in the program
viii
How food program is operated
ix
How food program affects school attendance
x
None of the usual reasons
xi
How to maintain an academic standard
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
7
Paragraph G

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af0c2b1b-6856-56a8-b828-0d6f2b6c0550', '2f5aa4e2-b896-5e52-a3e3-65901c81d3c8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2fbb1d5-ecd6-5788-9984-d908f1c6c99d', '2f5aa4e2-b896-5e52-a3e3-65901c81d3c8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb0379e4-1c3f-5d79-b8b4-b95976db4c55', '2f5aa4e2-b896-5e52-a3e3-65901c81d3c8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26aeb5f1-742d-567b-850b-df0d51f63e16', '2f5aa4e2-b896-5e52-a3e3-65901c81d3c8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('271e5553-bd01-5db4-9d4f-efdcbbc80177', '2f5aa4e2-b896-5e52-a3e3-65901c81d3c8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3adedefd-b1a9-5ce5-bf7a-64ff3bb5e0cb', '2f5aa4e2-b896-5e52-a3e3-65901c81d3c8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ad9564d-9c9f-523b-9b20-ecb7a8442cc9', '2f5aa4e2-b896-5e52-a3e3-65901c81d3c8', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac88c8d1-486b-536f-a60d-3271f37c3c8c', '97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of Headings
i
Why better food helps students’ learning
ii
A song for getting porridge
iii
Surprising use of school premises
iv
Global perspective
v
Brains can be starved
vi
Surprising academics outcome
vii
Girls are specially treated in the program
viii
How food program is operated
ix
How food program affects school attendance
x
None of the usual reasons
xi
How to maintain an academic standard
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
7
Paragraph G

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4dea0a1-9349-5fd1-8e6a-74ffc05e8b97', 'ac88c8d1-486b-536f-a60d-3271f37c3c8c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce4a720a-836d-5411-bd67-88b0e2326d8e', 'ac88c8d1-486b-536f-a60d-3271f37c3c8c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0403b58c-5e94-5f19-a90c-f35c93a8e67e', 'ac88c8d1-486b-536f-a60d-3271f37c3c8c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07735807-db62-5a56-bf2f-036f0a5f95aa', 'ac88c8d1-486b-536f-a60d-3271f37c3c8c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('302c0f1e-6ae6-5733-8b8c-ee0c62f51a78', 'ac88c8d1-486b-536f-a60d-3271f37c3c8c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70547a12-5150-527a-b556-99ae25fa3dce', 'ac88c8d1-486b-536f-a60d-3271f37c3c8c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e602d4d7-597c-5625-8cc4-152181ce3992', 'ac88c8d1-486b-536f-a60d-3271f37c3c8c', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1bfbaf84-bdc0-5b16-881b-763d071fc47f', '97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of Headings
i
Why better food helps students’ learning
ii
A song for getting porridge
iii
Surprising use of school premises
iv
Global perspective
v
Brains can be starved
vi
Surprising academics outcome
vii
Girls are specially treated in the program
viii
How food program is operated
ix
How food program affects school attendance
x
None of the usual reasons
xi
How to maintain an academic standard
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
7
Paragraph G

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09f05a13-c639-5f48-871d-0feff055bae4', '1bfbaf84-bdc0-5b16-881b-763d071fc47f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ab141c1-bc51-5f51-99f0-dd9f8d694a25', '1bfbaf84-bdc0-5b16-881b-763d071fc47f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbf61ed5-a8b0-5998-856c-36590718b05e', '1bfbaf84-bdc0-5b16-881b-763d071fc47f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4f9e254-cf50-5700-a12d-e43cc370a2c8', '1bfbaf84-bdc0-5b16-881b-763d071fc47f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('644b732d-6c82-529b-b0ef-6365154dcf3b', '1bfbaf84-bdc0-5b16-881b-763d071fc47f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b630262f-b64a-5c10-8f8d-5e379b45f11a', '1bfbaf84-bdc0-5b16-881b-763d071fc47f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cac3d249-8e8f-5fb1-803e-917c8566e241', '1bfbaf84-bdc0-5b16-881b-763d071fc47f', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9da8d3ba-fd7a-55af-aed7-4465b5495eb9', '97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of Headings
i
Why better food helps students’ learning
ii
A song for getting porridge
iii
Surprising use of school premises
iv
Global perspective
v
Brains can be starved
vi
Surprising academics outcome
vii
Girls are specially treated in the program
viii
How food program is operated
ix
How food program affects school attendance
x
None of the usual reasons
xi
How to maintain an academic standard
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
7
Paragraph G

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('289ce7a0-41cb-5506-9abb-657878004dab', '9da8d3ba-fd7a-55af-aed7-4465b5495eb9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e7d3c5f-5122-5127-a161-5ac9b0da7cd4', '9da8d3ba-fd7a-55af-aed7-4465b5495eb9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f8c21c6-e432-5f79-a184-c1ee065a9e52', '9da8d3ba-fd7a-55af-aed7-4465b5495eb9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dca8f387-245f-50c5-af10-8c2917b4429d', '9da8d3ba-fd7a-55af-aed7-4465b5495eb9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('844e3848-3ab3-5f4a-a53f-d5aa61ad4109', '9da8d3ba-fd7a-55af-aed7-4465b5495eb9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff7b7d07-ea18-5a86-9854-e2a3f42d687e', '9da8d3ba-fd7a-55af-aed7-4465b5495eb9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc1818f8-b470-57ec-a15e-5df986b2a216', '9da8d3ba-fd7a-55af-aed7-4465b5495eb9', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('32cb9030-b76b-529c-b2d4-161f011dc619', '97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-xi
, in boxes
1-7
on your answer sheet.
List of Headings
i
Why better food helps students’ learning
ii
A song for getting porridge
iii
Surprising use of school premises
iv
Global perspective
v
Brains can be starved
vi
Surprising academics outcome
vii
Girls are specially treated in the program
viii
How food program is operated
ix
How food program affects school attendance
x
None of the usual reasons
xi
How to maintain an academic standard
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
7
Paragraph G

7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5849633b-757d-571d-94f2-874778173503', '32cb9030-b76b-529c-b2d4-161f011dc619', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ec74cbb-2592-5daf-afad-771288991c5a', '32cb9030-b76b-529c-b2d4-161f011dc619', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3aa7cce-6b71-5cb0-8a24-14b5d25ce3de', '32cb9030-b76b-529c-b2d4-161f011dc619', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9bd93a5-b81a-5814-a4a5-c11c28fa90b5', '32cb9030-b76b-529c-b2d4-161f011dc619', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2446c06d-f95d-5298-a81c-7a5a2830735c', '32cb9030-b76b-529c-b2d4-161f011dc619', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0694c32f-19d2-5cdf-9e73-5515fe419c07', '32cb9030-b76b-529c-b2d4-161f011dc619', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76e2b09c-70fe-59e4-9191-256bee085747', '32cb9030-b76b-529c-b2d4-161f011dc619', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2d69b7eb-3497-5f5d-909d-983e44d1e357', '97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 8, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-11
Questions 8-11
Complete the sentences below using
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage?
Write your answers in boxes
8-11
on your answer sheet
8
8
are exclusively offered to girls in the feeding programme.
9
Instead of going to school, many children in poverty are sent to collect
9
in the fields.
10
The pass rate as Msekeni has risen to
10
with the help of the feeding programme.
11
Since the industrial revolution, the size of the modern human has grown by
11
.

8 8 ____ are exclusively offered to girls in the feeding programme.$md$, NULL, ARRAY['.*extra.*snacks.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('76f0c5a6-6b59-5054-bf5a-a9e998114faf', '97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 9, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-11
Questions 8-11
Complete the sentences below using
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage?
Write your answers in boxes
8-11
on your answer sheet
8
8
are exclusively offered to girls in the feeding programme.
9
Instead of going to school, many children in poverty are sent to collect
9
in the fields.
10
The pass rate as Msekeni has risen to
10
with the help of the feeding programme.
11
Since the industrial revolution, the size of the modern human has grown by
11
.

9 Instead of going to school, many children in poverty are sent to collect 9 ____ in the fields.$md$, NULL, ARRAY['.*firewood.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('93b48d57-1dcd-5b5c-b30a-ffb0397eb988', '97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 10, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-11
Questions 8-11
Complete the sentences below using
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage?
Write your answers in boxes
8-11
on your answer sheet
8
8
are exclusively offered to girls in the feeding programme.
9
Instead of going to school, many children in poverty are sent to collect
9
in the fields.
10
The pass rate as Msekeni has risen to
10
with the help of the feeding programme.
11
Since the industrial revolution, the size of the modern human has grown by
11
.

10 The pass rate as Msekeni has risen to 10 ____ with the help of the feeding programme.$md$, NULL, ARRAY['.*85.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d392314f-0882-54d9-b925-e4578401250e', '97819d5b-9c7a-57c5-8fe7-ebb3f1d1ea3f', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8-11
Questions 8-11
Complete the sentences below using
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage?
Write your answers in boxes
8-11
on your answer sheet
8
8
are exclusively offered to girls in the feeding programme.
9
Instead of going to school, many children in poverty are sent to collect
9
in the fields.
10
The pass rate as Msekeni has risen to
10
with the help of the feeding programme.
11
Since the industrial revolution, the size of the modern human has grown by
11
.

11 Since the industrial revolution, the size of the modern human has grown by 11 ____ .$md$, NULL, ARRAY['.*50.*']);

COMMIT;
