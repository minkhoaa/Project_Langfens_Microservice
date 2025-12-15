BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-father-of-modern-management-1275'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-father-of-modern-management-1275';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-father-of-modern-management-1275';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-father-of-modern-management-1275';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('03767e28-43e7-5243-b280-ea97910bc8fb', 'ielts-reading-father-of-modern-management-1275', $t$Father of modern management$t$, $md$## Father of modern management

Nguồn:
- Test: https://mini-ielts.com/1275/reading/father-of-modern-management
- Solution: https://mini-ielts.com/1275/view-solution/reading/father-of-modern-management$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('9d35fc1b-fafb-5c5c-b747-6f029e3936a6', '03767e28-43e7-5243-b280-ea97910bc8fb', 1, $t$Reading — Father of modern management$t$, $md$Read the passage and answer questions **1–10**.

### Passage: Father of modern management

A

Peter Drucker was one of the most important management thinkers of the past hundred years. He wrote about 40 book and thousands of articles and he never rested in his mission to persuade the world that management matters. “Management is an organ of institutions … the organ that converts a mob into an organisation, and human efforts into performance.” Did he succeed? The range of his influence was extraordinary. Wherever people grapple with tricky management problems, from big organizations to small ones, from the public sector to the private, and increasingly in the voluntary sector, you can find Drucker’s fingerprints.

B

His first two books – The End of Economic Man (1939) and The Future of Industrial Man (1942) – had their admirers, including Winston Churchill, but they annoyed academic critics by ranging so widely over so many different subjects. Still, the second of these books attracted attention with its passionate insistence that companies had a social dimension as well as an economic purpose. His third book, The Concept of the Corporation , became an instant bestseller and has remained in print ever since.

C

The two most interesting arguments in The Concept of the Corporation actually had little to do with the decentralization fad. They were to dominate his work. The first had to do with “empowering” workers. Drucker believed in treating workers as resources rather than just as costs. He was a harsh critic of the assembly-line system of production that then dominated the manufacturing sector – partly because assembly lines moved at the speed of the slowest and partly because they failed to engage the creativity of individual workers. The second argument had to do with the rise of knowledge workers. Drucker argued that the world is moving from an “economy of goods” to an economy of “knowledge” – and from a society dominated by an industrial proletariat to one dominated by brain workers. He insisted that this had profound implications for both managers and politicians. Managers had to stop treating workers like cogs in a huge inhuman machine and start treating them as brain workers. In turn, politicians had to realise that knowledge, and hence education, was the single most important resource for any advanced society. Yet Drucker also thought that this economy had implications for knowledge workers themselves. They had to come to terms with the fact that they were neither “bosses” nor “workers”, but something in between: entrepreneurs who had responsibility for developing their most important resource, brainpower, and who also needed to take more control of their own careers, including their pension plans.

D

However, there was also a hard side to his work. Drucker was responsible for inventing one of the rational school of management’s most successful products – “management by objectives”. In one of his most substantial works, The Practice of Management (1954), he emphasised the importance of managers and corporations setting clear long-term objectives and then translating those long-term objectives into more immediate goals. He argued that firms should have an elite corps of general managers, who set these long-term objectives, and then a group of more specialised managers. For his critics, this was a retreat from his earlier emphasis on the soft side of management. For Drucker it was all perfectly consistent: if you rely too much on empowerment you risk anarchy, whereas if you rely too much on command-and-control you sacrifice creativity. The trick is for managers to set long-term goals, but then allow their employees to work out ways of achieving those goals. If Drucker helped make management a global industry, he also helped push it beyond its business base. He was emphatically a management thinker, not just a business one. He believed that management is “the defining organ of all modern institutions”, not just corporations.

E

There are three persistent criticisms of Drucker’s work. The first is that he focused on big organisations rather than small ones. The Concept of the Corporation was in many ways a fanfare to big organisations. As Drucker said, “We know today that in modern industrial production, particularly in modern mass production, the small unit is not only inefficient, it cannot produce at all.” The book helped to launch the “big organisation boom” that dominated business thinking for the next 20 years. The second criticism is that Drucker’s enthusiasm for management by objectives helped to lead the business down a dead end. They prefer to allow ideas, including ideas for long-term strategies, to bubble up from the bottom and middle of the organisations rather than being imposed from on high. Thirdly, Drucker is criticised for being a maverick who has increasingly been left behind by the increasing rigour of his chosen field. There is no single area of academic management theory that he made his own.

F

There is some truth in the first two arguments. Drucker never wrote anything as good as The Concept of the Corporation on entrepreneurial start-ups. Drucker’s work on management by objectives sits uneasily with his earlier and later writings on the importance of knowledge workers and self-directed teams. But the third argument is short-sighted and unfair because it ignores Drucker’s pioneering role in creating the modern profession of management. He produced one of the first systematic studies of a big company. He pioneered the idea that ideas can help galvanise companies. The biggest problem with evaluating Drucker’s influence is that so many of his ideas have passed into conventional wisdom. In other words, he is the victim of his own success. His writings on the importance of knowledge workers and empowerment may sound a little banal today. But they certainly weren’t banal when he first dreamed them up in the 1940s, or when they were first put in to practice in the Anglo-Saxon world in the 1980s. Moreover, Drucker continued to produce new ideas up until his 90s. His work on the management of voluntary organisations remained at the cutting edge.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b3d2119d-64a1-5a1d-b184-6d87f4e3df9d', '9d35fc1b-fafb-5c5c-b747-6f029e3936a6', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list below.
Write the correct number,
i-ix
, in boxes 1-6 on your answer sheet.
List of Headings
i
The popularity and impact of Drucker’s work
ii
Finding fault with Drucker
iii
The impact of economic globalisation
iv
Government regulation of business
v
Early publications of Drucker’s
vi
Drucker’s view of balanced management
vii
Drucker’s rejection of big business
viii
An appreciation of the pros and cons of Drucker’s work
ix
The changing role of the employee
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
VALUES ('ebb56132-a856-5a96-b8cb-072b7c7e6f59', 'b3d2119d-64a1-5a1d-b184-6d87f4e3df9d', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('174fc8af-0925-52e3-bd33-e2a184a53146', 'b3d2119d-64a1-5a1d-b184-6d87f4e3df9d', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d454a0e2-69a6-540f-8ef7-1bed077ee34d', 'b3d2119d-64a1-5a1d-b184-6d87f4e3df9d', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f4bb103-3712-52a8-8421-9d87f205064b', 'b3d2119d-64a1-5a1d-b184-6d87f4e3df9d', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bae474fb-11b6-5432-a454-91629168d437', 'b3d2119d-64a1-5a1d-b184-6d87f4e3df9d', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52d4d7bc-db64-525d-a482-0bfaccc08fb1', 'b3d2119d-64a1-5a1d-b184-6d87f4e3df9d', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1035cb1c-e826-5e1b-9a88-be5c34453cfe', 'b3d2119d-64a1-5a1d-b184-6d87f4e3df9d', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f06fdf6b-1fb6-571e-8902-80515e5b7635', 'b3d2119d-64a1-5a1d-b184-6d87f4e3df9d', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fdbd441-b089-5a74-9dc1-4a591f41e3fc', 'b3d2119d-64a1-5a1d-b184-6d87f4e3df9d', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e7b4db8b-8bf7-52cc-84c0-e1ef24b9a60d', '9d35fc1b-fafb-5c5c-b747-6f029e3936a6', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list below.
Write the correct number,
i-ix
, in boxes 1-6 on your answer sheet.
List of Headings
i
The popularity and impact of Drucker’s work
ii
Finding fault with Drucker
iii
The impact of economic globalisation
iv
Government regulation of business
v
Early publications of Drucker’s
vi
Drucker’s view of balanced management
vii
Drucker’s rejection of big business
viii
An appreciation of the pros and cons of Drucker’s work
ix
The changing role of the employee
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
VALUES ('47314eb8-832c-5bde-97a4-2db5c00cca76', 'e7b4db8b-8bf7-52cc-84c0-e1ef24b9a60d', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb496514-f53b-5e42-8b1d-92909692459d', 'e7b4db8b-8bf7-52cc-84c0-e1ef24b9a60d', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3c2fb9d-f93e-5406-a264-29e07c746eeb', 'e7b4db8b-8bf7-52cc-84c0-e1ef24b9a60d', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8cc63eb7-42d2-5a0d-b87c-5d46b6fe76b5', 'e7b4db8b-8bf7-52cc-84c0-e1ef24b9a60d', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6b9b18d-4117-51e1-8fca-91c0dfcfedd7', 'e7b4db8b-8bf7-52cc-84c0-e1ef24b9a60d', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd614f97-f085-512e-a5c1-41ae645f6b16', 'e7b4db8b-8bf7-52cc-84c0-e1ef24b9a60d', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6de3719-1a62-5260-9fbc-f835d5c6f02a', 'e7b4db8b-8bf7-52cc-84c0-e1ef24b9a60d', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf305f25-1cad-514c-b249-ad7d1744ab17', 'e7b4db8b-8bf7-52cc-84c0-e1ef24b9a60d', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a613f381-dac5-5e77-8bfe-beb469310025', 'e7b4db8b-8bf7-52cc-84c0-e1ef24b9a60d', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('be2eb66e-938c-5bd0-a87d-61af6c7091e3', '9d35fc1b-fafb-5c5c-b747-6f029e3936a6', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list below.
Write the correct number,
i-ix
, in boxes 1-6 on your answer sheet.
List of Headings
i
The popularity and impact of Drucker’s work
ii
Finding fault with Drucker
iii
The impact of economic globalisation
iv
Government regulation of business
v
Early publications of Drucker’s
vi
Drucker’s view of balanced management
vii
Drucker’s rejection of big business
viii
An appreciation of the pros and cons of Drucker’s work
ix
The changing role of the employee
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
VALUES ('ec768257-a811-53c3-96b4-a0436a762615', 'be2eb66e-938c-5bd0-a87d-61af6c7091e3', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7ba3054-3746-5096-997c-a2d7ccad42f6', 'be2eb66e-938c-5bd0-a87d-61af6c7091e3', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56e6c636-2835-5e46-beab-0a2dd722bb62', 'be2eb66e-938c-5bd0-a87d-61af6c7091e3', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ae8bad4-a39a-58de-bfa3-fde46e1992de', 'be2eb66e-938c-5bd0-a87d-61af6c7091e3', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b052e4a-a8d9-56df-83d0-c00dddeda7d6', 'be2eb66e-938c-5bd0-a87d-61af6c7091e3', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e810cd2d-56e6-56b4-8bfd-e13cad074020', 'be2eb66e-938c-5bd0-a87d-61af6c7091e3', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59f942d1-095d-508f-814b-fa7908495332', 'be2eb66e-938c-5bd0-a87d-61af6c7091e3', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69a4c238-47e2-5c01-a0f1-938cf86602d6', 'be2eb66e-938c-5bd0-a87d-61af6c7091e3', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67b413c6-6476-56bf-b787-484ba1979e7f', 'be2eb66e-938c-5bd0-a87d-61af6c7091e3', 9, $md$ix$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3aa9967f-c840-5a12-ba1a-19d44225e531', '9d35fc1b-fafb-5c5c-b747-6f029e3936a6', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list below.
Write the correct number,
i-ix
, in boxes 1-6 on your answer sheet.
List of Headings
i
The popularity and impact of Drucker’s work
ii
Finding fault with Drucker
iii
The impact of economic globalisation
iv
Government regulation of business
v
Early publications of Drucker’s
vi
Drucker’s view of balanced management
vii
Drucker’s rejection of big business
viii
An appreciation of the pros and cons of Drucker’s work
ix
The changing role of the employee
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
VALUES ('c31ccf98-0a76-5ad8-b609-13899f909b0a', '3aa9967f-c840-5a12-ba1a-19d44225e531', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b59e120-7431-5bd9-83b1-28a69a2600c5', '3aa9967f-c840-5a12-ba1a-19d44225e531', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a25b3292-909a-5d42-99d6-173af9dc4248', '3aa9967f-c840-5a12-ba1a-19d44225e531', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e60bba47-87f5-530b-8bad-cc902c0721ff', '3aa9967f-c840-5a12-ba1a-19d44225e531', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63b552e2-3604-57e0-8214-ef3e086ae50b', '3aa9967f-c840-5a12-ba1a-19d44225e531', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c021b0c-0df7-5374-ad16-7794c938a5f5', '3aa9967f-c840-5a12-ba1a-19d44225e531', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a22d5660-ec66-5eae-a282-78b16a1035c4', '3aa9967f-c840-5a12-ba1a-19d44225e531', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a6bc39f-22be-502a-af94-2c34a11aa149', '3aa9967f-c840-5a12-ba1a-19d44225e531', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8ffb146-be0a-5ac5-a32e-2993aedfcd58', '3aa9967f-c840-5a12-ba1a-19d44225e531', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4b26c090-3ba0-51ab-a9a0-98890b883fbf', '9d35fc1b-fafb-5c5c-b747-6f029e3936a6', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list below.
Write the correct number,
i-ix
, in boxes 1-6 on your answer sheet.
List of Headings
i
The popularity and impact of Drucker’s work
ii
Finding fault with Drucker
iii
The impact of economic globalisation
iv
Government regulation of business
v
Early publications of Drucker’s
vi
Drucker’s view of balanced management
vii
Drucker’s rejection of big business
viii
An appreciation of the pros and cons of Drucker’s work
ix
The changing role of the employee
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
VALUES ('3cf11740-e92e-5b6b-92f0-cc024724cce1', '4b26c090-3ba0-51ab-a9a0-98890b883fbf', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a343ac5d-d4b5-5758-9f2e-3a4ab6bd74fe', '4b26c090-3ba0-51ab-a9a0-98890b883fbf', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ae32829-3371-5ee7-ba9f-751ddca0c50e', '4b26c090-3ba0-51ab-a9a0-98890b883fbf', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58c24506-9619-57b6-80ee-d72ecdd62456', '4b26c090-3ba0-51ab-a9a0-98890b883fbf', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8669d4d0-679c-5371-a574-ac1e443837ab', '4b26c090-3ba0-51ab-a9a0-98890b883fbf', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c8966c0-eca8-5c18-8308-f6af08b625ca', '4b26c090-3ba0-51ab-a9a0-98890b883fbf', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31e9cd5d-6a21-5100-a644-6c2d52d10a48', '4b26c090-3ba0-51ab-a9a0-98890b883fbf', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c46ff28-e381-5b08-a86a-14107dd85db0', '4b26c090-3ba0-51ab-a9a0-98890b883fbf', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3cb567e-acf3-552c-a975-34dd9d5bd762', '4b26c090-3ba0-51ab-a9a0-98890b883fbf', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d626d413-4a5f-5a9c-a1a9-b4a672fc85bf', '9d35fc1b-fafb-5c5c-b747-6f029e3936a6', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
Choose the correct heading for each paragraph from the list below.
Write the correct number,
i-ix
, in boxes 1-6 on your answer sheet.
List of Headings
i
The popularity and impact of Drucker’s work
ii
Finding fault with Drucker
iii
The impact of economic globalisation
iv
Government regulation of business
v
Early publications of Drucker’s
vi
Drucker’s view of balanced management
vii
Drucker’s rejection of big business
viii
An appreciation of the pros and cons of Drucker’s work
ix
The changing role of the employee
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
VALUES ('155d2392-48a3-571a-91e8-fcab6004a6a5', 'd626d413-4a5f-5a9c-a1a9-b4a672fc85bf', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0116c1d-c999-525d-9139-807aa5d8f3d4', 'd626d413-4a5f-5a9c-a1a9-b4a672fc85bf', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73962048-ef79-58b7-a0a6-0f0edf95b18f', 'd626d413-4a5f-5a9c-a1a9-b4a672fc85bf', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('059f381a-7dcb-5562-a076-8b8b95355ab3', 'd626d413-4a5f-5a9c-a1a9-b4a672fc85bf', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db85eeb3-04d8-50bf-95de-3ba269ed4764', 'd626d413-4a5f-5a9c-a1a9-b4a672fc85bf', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2263255b-ed43-529d-8882-845fb1180bb8', 'd626d413-4a5f-5a9c-a1a9-b4a672fc85bf', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c340fb72-9b33-58f2-bd5b-69ff645a1601', 'd626d413-4a5f-5a9c-a1a9-b4a672fc85bf', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26561631-95c3-554a-861f-2f232bbf07f7', 'd626d413-4a5f-5a9c-a1a9-b4a672fc85bf', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ff2b8b9-65a5-52e0-8f4b-7e47efa04936', 'd626d413-4a5f-5a9c-a1a9-b4a672fc85bf', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('58750542-848a-580e-bd3e-2a4e16a50d73', '9d35fc1b-fafb-5c5c-b747-6f029e3936a6', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage 2?
In boxes 7-10 on your answer sheet, write
YES
if the statement agrees with what is stated in the passage
NO
if the statement counters to what is stated in the passage
NOT GIVEN
if there is no relevant information given in the passage
7
Drucker believed the employees should enjoy the same status as the employers in a company
8
Drucker argued the managers and politicians will dominate the economy during a social transition
9
Drucker support that workers are not simply put themselves just in the employment relationship and should develop their resources of intelligence voluntarily
10
Drucker’s work on the management is out of date in moderns days

7 ____ Drucker believed the employees should enjoy the same status as the employers in a company$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e26b0a4c-0519-5235-a886-8c3b14bdcb15', '58750542-848a-580e-bd3e-2a4e16a50d73', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdea0938-ec8d-5c61-9d19-eb68c55932c2', '58750542-848a-580e-bd3e-2a4e16a50d73', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4a90c5f-bb1b-5e25-9415-292ceeee6a33', '58750542-848a-580e-bd3e-2a4e16a50d73', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b7617e3e-f284-5327-ad90-cd5e25da88d4', '9d35fc1b-fafb-5c5c-b747-6f029e3936a6', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage 2?
In boxes 7-10 on your answer sheet, write
YES
if the statement agrees with what is stated in the passage
NO
if the statement counters to what is stated in the passage
NOT GIVEN
if there is no relevant information given in the passage
7
Drucker believed the employees should enjoy the same status as the employers in a company
8
Drucker argued the managers and politicians will dominate the economy during a social transition
9
Drucker support that workers are not simply put themselves just in the employment relationship and should develop their resources of intelligence voluntarily
10
Drucker’s work on the management is out of date in moderns days

8 ____ Drucker argued the managers and politicians will dominate the economy during a social transition$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a996af7c-e1e7-59ce-b68d-f5dffc383218', 'b7617e3e-f284-5327-ad90-cd5e25da88d4', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a186416-2dd5-5543-b0b2-f26a7ce83402', 'b7617e3e-f284-5327-ad90-cd5e25da88d4', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc83bdae-59ec-5140-b0fa-44e4d1b8c8dc', 'b7617e3e-f284-5327-ad90-cd5e25da88d4', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5733ecfb-b402-5a84-a509-7b7ef4083bbb', '9d35fc1b-fafb-5c5c-b747-6f029e3936a6', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage 2?
In boxes 7-10 on your answer sheet, write
YES
if the statement agrees with what is stated in the passage
NO
if the statement counters to what is stated in the passage
NOT GIVEN
if there is no relevant information given in the passage
7
Drucker believed the employees should enjoy the same status as the employers in a company
8
Drucker argued the managers and politicians will dominate the economy during a social transition
9
Drucker support that workers are not simply put themselves just in the employment relationship and should develop their resources of intelligence voluntarily
10
Drucker’s work on the management is out of date in moderns days

9 ____ Drucker support that workers are not simply put themselves just in the employment relationship and should develop their resources of intelligence voluntarily$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3574ce33-9f20-5d28-8dc2-e4f9cae75a9e', '5733ecfb-b402-5a84-a509-7b7ef4083bbb', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55816e7e-86d7-5439-9baf-54d060a73f5f', '5733ecfb-b402-5a84-a509-7b7ef4083bbb', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16218557-3206-5a5c-a936-5d41bf393dce', '5733ecfb-b402-5a84-a509-7b7ef4083bbb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1dce6d43-1636-5ee8-acdb-54a71f49163e', '9d35fc1b-fafb-5c5c-b747-6f029e3936a6', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in Reading Passage 2?
In boxes 7-10 on your answer sheet, write
YES
if the statement agrees with what is stated in the passage
NO
if the statement counters to what is stated in the passage
NOT GIVEN
if there is no relevant information given in the passage
7
Drucker believed the employees should enjoy the same status as the employers in a company
8
Drucker argued the managers and politicians will dominate the economy during a social transition
9
Drucker support that workers are not simply put themselves just in the employment relationship and should develop their resources of intelligence voluntarily
10
Drucker’s work on the management is out of date in moderns days

10 ____ Drucker’s work on the management is out of date in moderns days$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5046b84-752e-5bda-86fb-d10024e1c58d', '1dce6d43-1636-5ee8-acdb-54a71f49163e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f9b2be7-4e75-5595-b9ec-35809fb19378', '1dce6d43-1636-5ee8-acdb-54a71f49163e', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e1f3031-c61c-563b-8452-9a3a075cd280', '1dce6d43-1636-5ee8-acdb-54a71f49163e', 3, $md$NOT GIVEN$md$, false);

COMMIT;
