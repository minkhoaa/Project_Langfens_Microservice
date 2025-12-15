BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-whats-the-purpose-of-gaining-knowledge-1138'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-whats-the-purpose-of-gaining-knowledge-1138';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-whats-the-purpose-of-gaining-knowledge-1138';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-whats-the-purpose-of-gaining-knowledge-1138';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('7827212e-39a9-519f-8c3b-e165e2a7d774', 'ielts-reading-whats-the-purpose-of-gaining-knowledge-1138', $t$What’s the purpose of gaining knowledge?$t$, $md$## What’s the purpose of gaining knowledge?

Nguồn:
- Test: https://mini-ielts.com/1138/reading/whats-the-purpose-of-gaining-knowledge
- Solution: https://mini-ielts.com/1138/view-solution/reading/whats-the-purpose-of-gaining-knowledge$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3c6c910b-9184-574e-8982-1e0eb42d5043', '7827212e-39a9-519f-8c3b-e165e2a7d774', 1, $t$Reading — What’s the purpose of gaining knowledge?$t$, $md$Read the passage and answer questions **1–14**.

### Passage: What’s the purpose of gaining knowledge?

A

‘I would found an institution where any person can find instruction in any subject' That was the founders motto for Cornell University, and it seems an apt characterization of the different university, also in the USA, where I currently teach philosophy. A student can prepare for a career in resort management, engineering, interior design, accounting, music, law enforcement, you name it. But what would the founders of these two institutions have thought of a course called Arson for Profit’? I kid you not: we have it on the books. Any undergraduates who have met the academic requirements can sign up for the course in our program in ' fire science ’.

B

Naturally, the course is intended for prospective arson investigators , who can learn all the tricks of the trade for detecting whether a fire was deliberately set, discovering who did it, and establishing a chain of evidence for effective prosecution in a court of law. But wouldn’t this also be the perfect course for prospective arsonists to sign up for? My point is not to criticize academic programs in fire science: they are highly welcome as part of the increasing professionalization of this and many other occupations. However, it’s not unknown for a firefighter to torch a building. This example suggests how dishonest and illegal behavior, with the help of higher education, can creep into every aspect of public and business life.

C

I realized this anew when I was invited to speak before a class in marketing, which is another of our degree programs. The regular instructor is a colleague who appreciates the kind of ethical perspective I can bring as a philosopher. There are endless ways I could have approached this assignment , but I took my cue from the title of the course: 'Principles of Marketing’. It made me think to ask the students, 'Is marketing principled?’ After all, a subject matter can have principles in the sense of being codified, having rules, as with football or chess, without being principled in the sense of being ethical. Many of the students immediately assumed that the answer to my question about marketing principles was obvious: no. Just look at the ways in which everything under the sun has been marketed; obviously it need not be done in a principled (=ethical) fashion.

D

Is that obvious? I made the suggestion, which may sound downright crazy in light of the evidence, that perhaps marketing is by definition principled. My inspiration for this judgement is the philosopher Immanuel Kant, who argued that any body of knowledge consists of an end (or purpose) and a means.

E

Let us apply both the terms 'means' and ‘end' to marketing. The students have signed up for a course in order to learn how to market effectively. But to what end? There seem to be two main attitudes toward that question. One is that the answer is obvious: the purpose of marketing is to sell things and to make money. The other attitude is that the purpose of marketing is irrelevant: Each person comes to the program and course with his or her own plans, and these need not even concern the acquisition of marketing expertise as such. My proposal, which I believe would also be Kant's, is that neither of these attitudes captures the significance of the end to the means for marketing. A field of knowledge or a professional endeavor is defined by both the means and the end;hence both deserve scrutiny. Students need to study both how to achieve X, and also what X is.

F

It is at this point that ‘Arson for Profit’ becomes supremely relevant . That course is presumably all about means: how to detect and prosecute criminal activity. It is therefore assumed that the end is good in an ethical sense. When I ask fire science students to articulate the end, or purpose, of their field, they eventually generalize to something like, ‘The safety and welfare of society,’ which seems right. As we have seen, someone could use the very same knowledge of means to achieve a much less noble end, such as personal profit via destructive, dangerous, reckless activity. But we would not call that firefighting. We have a separate word for it: arson. Similarly, if you employed the ‘principles of marketing’ in an unprincipled way, you would not be doing marketing. We have another term for it: fraud. Kant gives the example of a doctor and a poisoner, who use the identical knowledge to achieve their divergent ends. We would say that one is practicing medicine, the other, murder.

----------------------------------------------------

Great thanks to volunteer Thuy Do has contributed these explanations and question markings.

If you want to make a better world like this, please contact us$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('02496543-632c-560a-b447-7a2c70d96855', '3c6c910b-9184-574e-8982-1e0eb42d5043', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage has six sections,
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-6
on your answer sheet.
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
List of Headings
i
Courses that require a high level of commitment
ii
A course title with two meanings
iii
The equal importance of two key issues
iv
Applying a theory in an unexpected context
v
The financial benefits of studying
vi
A surprising course title
vii
Different names for different outcomes
viii
The possibility of attracting the wrong kind of student

1 ____ Section A Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8412789-5023-52bd-a069-b8b30f0e1057', '02496543-632c-560a-b447-7a2c70d96855', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be2007e4-23d1-5684-aa42-40fd95635f34', '02496543-632c-560a-b447-7a2c70d96855', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39aeca18-032b-5583-9f4a-628394a20bb6', '02496543-632c-560a-b447-7a2c70d96855', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f5b459f-94ae-57a9-b416-43d35fb2da93', '02496543-632c-560a-b447-7a2c70d96855', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('908b4e95-a7d8-5fec-8c02-f96c37498828', '02496543-632c-560a-b447-7a2c70d96855', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d32fedc-df37-5d30-8bd7-8afe2480ac2b', '02496543-632c-560a-b447-7a2c70d96855', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b7418ee-2e81-5d94-85da-22144e41becd', '02496543-632c-560a-b447-7a2c70d96855', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4314ee10-f46e-56f1-8276-610dfb96240b', '02496543-632c-560a-b447-7a2c70d96855', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8a87dd75-7c3b-5299-973e-a2b6a61cefda', '3c6c910b-9184-574e-8982-1e0eb42d5043', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage has six sections,
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-6
on your answer sheet.
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
List of Headings
i
Courses that require a high level of commitment
ii
A course title with two meanings
iii
The equal importance of two key issues
iv
Applying a theory in an unexpected context
v
The financial benefits of studying
vi
A surprising course title
vii
Different names for different outcomes
viii
The possibility of attracting the wrong kind of student

2 ____ Section B Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e60bab33-7325-584f-9468-5e08eec2fdc6', '8a87dd75-7c3b-5299-973e-a2b6a61cefda', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a24d6d0c-7423-5f16-bec8-d57cc3c2c85a', '8a87dd75-7c3b-5299-973e-a2b6a61cefda', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21be324b-cb38-5fd8-94b2-c90d565b4622', '8a87dd75-7c3b-5299-973e-a2b6a61cefda', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9652c005-4caf-5cee-a225-e5f574ce39ab', '8a87dd75-7c3b-5299-973e-a2b6a61cefda', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9522c7f-1b14-5654-b616-8b68e9aab0d6', '8a87dd75-7c3b-5299-973e-a2b6a61cefda', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('294d9c77-cb44-5b51-a587-fcc34c2db84c', '8a87dd75-7c3b-5299-973e-a2b6a61cefda', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4243b60-be34-5171-9b4f-10d7e75d79f3', '8a87dd75-7c3b-5299-973e-a2b6a61cefda', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('417a5349-4625-5108-a877-b4d34a304362', '8a87dd75-7c3b-5299-973e-a2b6a61cefda', 8, $md$viii$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc7961e6-9d5e-528a-b482-abb5e9e1ae9d', '3c6c910b-9184-574e-8982-1e0eb42d5043', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage has six sections,
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-6
on your answer sheet.
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
List of Headings
i
Courses that require a high level of commitment
ii
A course title with two meanings
iii
The equal importance of two key issues
iv
Applying a theory in an unexpected context
v
The financial benefits of studying
vi
A surprising course title
vii
Different names for different outcomes
viii
The possibility of attracting the wrong kind of student

3 ____ Section C Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a04fef4-e576-5e67-a76d-eb8fa5855e1b', 'fc7961e6-9d5e-528a-b482-abb5e9e1ae9d', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56a12309-de1b-5168-b9b9-33fb5b37ce0b', 'fc7961e6-9d5e-528a-b482-abb5e9e1ae9d', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2e2a37f-b2e9-5a0e-970f-1b9802c58f6d', 'fc7961e6-9d5e-528a-b482-abb5e9e1ae9d', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7aaefffe-c3f9-5797-994c-25f8271a7b08', 'fc7961e6-9d5e-528a-b482-abb5e9e1ae9d', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcfa4df9-0c76-5a53-aecc-000a92830437', 'fc7961e6-9d5e-528a-b482-abb5e9e1ae9d', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f80b6a53-1365-516b-bc52-43dd68fe3eda', 'fc7961e6-9d5e-528a-b482-abb5e9e1ae9d', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc21d057-db57-5b6d-8a97-c3eec9612c7f', 'fc7961e6-9d5e-528a-b482-abb5e9e1ae9d', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fcee663-e487-55b7-ba81-f246b014723c', 'fc7961e6-9d5e-528a-b482-abb5e9e1ae9d', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae5182b5-4e5a-5883-9a5e-742e6d40a8c3', '3c6c910b-9184-574e-8982-1e0eb42d5043', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage has six sections,
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-6
on your answer sheet.
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
List of Headings
i
Courses that require a high level of commitment
ii
A course title with two meanings
iii
The equal importance of two key issues
iv
Applying a theory in an unexpected context
v
The financial benefits of studying
vi
A surprising course title
vii
Different names for different outcomes
viii
The possibility of attracting the wrong kind of student

4 ____ Section D Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a03982f-65ef-52ca-a7e4-f13f8a114515', 'ae5182b5-4e5a-5883-9a5e-742e6d40a8c3', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c76661b-614c-5c5b-a03c-464b2d0938c1', 'ae5182b5-4e5a-5883-9a5e-742e6d40a8c3', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a695263a-4819-5a4c-854d-4e4702a51965', 'ae5182b5-4e5a-5883-9a5e-742e6d40a8c3', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94243e33-28ab-5057-8593-324e9207db37', 'ae5182b5-4e5a-5883-9a5e-742e6d40a8c3', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91415134-3d2a-5884-8820-1ff9865c4299', 'ae5182b5-4e5a-5883-9a5e-742e6d40a8c3', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('475b1115-d1b3-503a-b491-367efb1e0bef', 'ae5182b5-4e5a-5883-9a5e-742e6d40a8c3', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fafed78-8211-56b5-9624-65e692544b2a', 'ae5182b5-4e5a-5883-9a5e-742e6d40a8c3', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40f493ac-4066-5ab6-a904-891b28d4fc5b', 'ae5182b5-4e5a-5883-9a5e-742e6d40a8c3', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('08dc81db-fd17-5f7c-92a1-e6300a9f45a4', '3c6c910b-9184-574e-8982-1e0eb42d5043', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage has six sections,
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-6
on your answer sheet.
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
List of Headings
i
Courses that require a high level of commitment
ii
A course title with two meanings
iii
The equal importance of two key issues
iv
Applying a theory in an unexpected context
v
The financial benefits of studying
vi
A surprising course title
vii
Different names for different outcomes
viii
The possibility of attracting the wrong kind of student

5 ____ Section E Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('952c95b3-eec3-52f0-8777-8d98b9923885', '08dc81db-fd17-5f7c-92a1-e6300a9f45a4', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b34cba68-626e-5cf4-8f0f-b5059b392461', '08dc81db-fd17-5f7c-92a1-e6300a9f45a4', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdfcd15b-b041-569b-b01a-5d535cea318d', '08dc81db-fd17-5f7c-92a1-e6300a9f45a4', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('236c6f62-cd2c-5005-bbec-326959265c4b', '08dc81db-fd17-5f7c-92a1-e6300a9f45a4', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd2e97ec-e23d-5695-a73d-3f254ecd3e98', '08dc81db-fd17-5f7c-92a1-e6300a9f45a4', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bcde644-7624-521f-8266-7eca313d8c56', '08dc81db-fd17-5f7c-92a1-e6300a9f45a4', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33df728e-4c52-51bc-9e45-dd54f98e58d2', '08dc81db-fd17-5f7c-92a1-e6300a9f45a4', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a49679a-2ce4-5852-b936-3ba8ec4bea2e', '08dc81db-fd17-5f7c-92a1-e6300a9f45a4', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('38fa9b81-0daf-5942-832e-4b3f8e68c1a8', '3c6c910b-9184-574e-8982-1e0eb42d5043', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage has six sections,
A-F
.
Choose the correct heading for each section from the list of headings below.
Write the correct number,
i-viii
, in boxes
1-6
on your answer sheet.
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
List of Headings
i
Courses that require a high level of commitment
ii
A course title with two meanings
iii
The equal importance of two key issues
iv
Applying a theory in an unexpected context
v
The financial benefits of studying
vi
A surprising course title
vii
Different names for different outcomes
viii
The possibility of attracting the wrong kind of student

6 ____ Section F Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2b377ca-8581-55ee-8a9e-1a4ac63ad727', '38fa9b81-0daf-5942-832e-4b3f8e68c1a8', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a633f0ff-2fb9-5ea6-932f-6ad6ab7bf903', '38fa9b81-0daf-5942-832e-4b3f8e68c1a8', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80a5da0e-83f3-5f09-a56f-2a94c158df2d', '38fa9b81-0daf-5942-832e-4b3f8e68c1a8', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1487ffa-a2d8-5006-9e02-c0c2e1b257b5', '38fa9b81-0daf-5942-832e-4b3f8e68c1a8', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4dc27e4-a729-5809-afa5-453cfb3cb2a2', '38fa9b81-0daf-5942-832e-4b3f8e68c1a8', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3796cc3a-5a0f-5428-a2d9-d8e415505909', '38fa9b81-0daf-5942-832e-4b3f8e68c1a8', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4fd58c2-fb1a-59d2-b3a0-f919328ac30d', '38fa9b81-0daf-5942-832e-4b3f8e68c1a8', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28b6c342-392b-5ff8-8f7e-ecbc2a0feb6c', '38fa9b81-0daf-5942-832e-4b3f8e68c1a8', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a5b79982-6308-51f6-8ee8-31a1970ae8ab', '3c6c910b-9184-574e-8982-1e0eb42d5043', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
The ‘Arson for Profit’ course
This is a university course intended for students who are undergraduates and who are studying
7
Locate
. The expectation is that they will become
8
Locate
specialising in arson. The course will help them to detect cases of arson and find
9
Locate
of criminal intent, leading to successful
10
Locate
in the courts.

This is a university course intended for students who are undergraduates and who are studying 7 ____ Locate . The expectation is that they will become 8 ____ Locate specialising in arson. The course will help them to detect cases of arson and find 9 ____ Locate of criminal intent, leading to successful 10 ____ Locate in the courts.$md$, NULL, ARRAY['.*fire.*science.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1180e523-d261-51c3-b5ba-adbbf629e230', '3c6c910b-9184-574e-8982-1e0eb42d5043', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
The ‘Arson for Profit’ course
This is a university course intended for students who are undergraduates and who are studying
7
Locate
. The expectation is that they will become
8
Locate
specialising in arson. The course will help them to detect cases of arson and find
9
Locate
of criminal intent, leading to successful
10
Locate
in the courts.

This is a university course intended for students who are undergraduates and who are studying 7 ____ Locate . The expectation is that they will become 8 ____ Locate specialising in arson. The course will help them to detect cases of arson and find 9 ____ Locate of criminal intent, leading to successful 10 ____ Locate in the courts.$md$, NULL, ARRAY['.*fire.*science.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ce247d75-f1f5-54a7-94af-869e7e37b9bd', '3c6c910b-9184-574e-8982-1e0eb42d5043', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
The ‘Arson for Profit’ course
This is a university course intended for students who are undergraduates and who are studying
7
Locate
. The expectation is that they will become
8
Locate
specialising in arson. The course will help them to detect cases of arson and find
9
Locate
of criminal intent, leading to successful
10
Locate
in the courts.

This is a university course intended for students who are undergraduates and who are studying 7 ____ Locate . The expectation is that they will become 8 ____ Locate specialising in arson. The course will help them to detect cases of arson and find 9 ____ Locate of criminal intent, leading to successful 10 ____ Locate in the courts.$md$, NULL, ARRAY['.*fire.*science.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('45d1d93a-6ebc-5f18-aca4-c4ed55c72014', '3c6c910b-9184-574e-8982-1e0eb42d5043', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
The ‘Arson for Profit’ course
This is a university course intended for students who are undergraduates and who are studying
7
Locate
. The expectation is that they will become
8
Locate
specialising in arson. The course will help them to detect cases of arson and find
9
Locate
of criminal intent, leading to successful
10
Locate
in the courts.

This is a university course intended for students who are undergraduates and who are studying 7 ____ Locate . The expectation is that they will become 8 ____ Locate specialising in arson. The course will help them to detect cases of arson and find 9 ____ Locate of criminal intent, leading to successful 10 ____ Locate in the courts.$md$, NULL, ARRAY['.*fire.*science.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('44927d21-4876-5356-923a-d8815beb82a6', '3c6c910b-9184-574e-8982-1e0eb42d5043', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
11-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
11
It is difficult to attract students onto courses that do not focus on a career.
Locate
12
The ‘Arson for Profit’ course would be useful for people intending to set fire to buildings.
Locate
13
Fire science courses are too academic to help people to be good at the job of firefighting.
Locate
14
The writer’s fire science students provided a detailed definition of the purpose of their studies.
Locate

11 ____ It is difficult to attract students onto courses that do not focus on a career. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0da6ff70-4ece-50f4-ae3c-e7adb17b023f', '44927d21-4876-5356-923a-d8815beb82a6', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0642b7f5-3269-5c11-b057-f6954e3d1526', '44927d21-4876-5356-923a-d8815beb82a6', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('934a9690-cdeb-56e2-a97a-b0b62ec8b5b1', '44927d21-4876-5356-923a-d8815beb82a6', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1d09be76-9951-520e-9f6b-2b1733261519', '3c6c910b-9184-574e-8982-1e0eb42d5043', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
11-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
11
It is difficult to attract students onto courses that do not focus on a career.
Locate
12
The ‘Arson for Profit’ course would be useful for people intending to set fire to buildings.
Locate
13
Fire science courses are too academic to help people to be good at the job of firefighting.
Locate
14
The writer’s fire science students provided a detailed definition of the purpose of their studies.
Locate

12 ____ The ‘Arson for Profit’ course would be useful for people intending to set fire to buildings. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0c63eea-02ce-57bd-a43f-0acff274f932', '1d09be76-9951-520e-9f6b-2b1733261519', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('613853ec-6e45-5fe2-b0f3-3506ad3b56d0', '1d09be76-9951-520e-9f6b-2b1733261519', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fe31e4b-0563-57d6-8ea0-28f06bf15237', '1d09be76-9951-520e-9f6b-2b1733261519', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4bdf1eed-faa1-5c36-ba8e-cbfa36c371e5', '3c6c910b-9184-574e-8982-1e0eb42d5043', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
11-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
11
It is difficult to attract students onto courses that do not focus on a career.
Locate
12
The ‘Arson for Profit’ course would be useful for people intending to set fire to buildings.
Locate
13
Fire science courses are too academic to help people to be good at the job of firefighting.
Locate
14
The writer’s fire science students provided a detailed definition of the purpose of their studies.
Locate

13 ____ Fire science courses are too academic to help people to be good at the job of firefighting. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6e59ec6-246b-5166-863c-01e10a468a80', '4bdf1eed-faa1-5c36-ba8e-cbfa36c371e5', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('586555cc-bb52-5328-b9a4-b422b569dbd6', '4bdf1eed-faa1-5c36-ba8e-cbfa36c371e5', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4179a4c7-6f8e-5d38-baf0-b2d3de4e9c58', '4bdf1eed-faa1-5c36-ba8e-cbfa36c371e5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fa3929f0-6f82-5841-86b8-2a8f04ba28bc', '3c6c910b-9184-574e-8982-1e0eb42d5043', 14, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
11-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
11
It is difficult to attract students onto courses that do not focus on a career.
Locate
12
The ‘Arson for Profit’ course would be useful for people intending to set fire to buildings.
Locate
13
Fire science courses are too academic to help people to be good at the job of firefighting.
Locate
14
The writer’s fire science students provided a detailed definition of the purpose of their studies.
Locate

14 ____ The writer’s fire science students provided a detailed definition of the purpose of their studies. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03e0e351-11ea-5738-b61e-7acf9323e135', 'fa3929f0-6f82-5841-86b8-2a8f04ba28bc', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e43c1e67-91bf-5de1-bb44-b162fa435cd7', 'fa3929f0-6f82-5841-86b8-2a8f04ba28bc', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68925a0d-04ed-5045-9c7d-317a70512f8e', 'fa3929f0-6f82-5841-86b8-2a8f04ba28bc', 3, $md$NOT GIVEN$md$, false);

COMMIT;
