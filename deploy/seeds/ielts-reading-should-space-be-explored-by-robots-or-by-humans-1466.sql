BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-should-space-be-explored-by-robots-or-by-humans-1466'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-should-space-be-explored-by-robots-or-by-humans-1466';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-should-space-be-explored-by-robots-or-by-humans-1466';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-should-space-be-explored-by-robots-or-by-humans-1466';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('26694952-1b7f-539d-b9e0-1afa6ec386e7', 'ielts-reading-should-space-be-explored-by-robots-or-by-humans-1466', $t$Should space be explored by robots or by humans?$t$, $md$## Should space be explored by robots or by humans?

Nguồn:
- Test: https://mini-ielts.com/1466/reading/should-space-be-explored-by-robots-or-by-humans
- Solution: https://mini-ielts.com/1466/view-solution/reading/should-space-be-explored-by-robots-or-by-humans$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('b458eab8-acc3-5615-b8ad-f7aae65672be', '26694952-1b7f-539d-b9e0-1afa6ec386e7', 1, $t$Reading — Should space be explored by robots or by humans?$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Should space be explored by robots or by humans?

A The advisability of humans participating directly in space travel continues to cause many debates. There is no doubt that the presence of people on board a space vehicle makes its design much more complex and challenging, and produces a large increase in costs, since safety requirements are greatly increased, and the technology providing necessities for human passengers such as oxygen, food water must be guaranteed. Moreover, the systems required are bulky and costly, and their complexity increases for long-duration missions. Meanwhile, advances in electronics and computer science allow increasingly complex tasks to be entrusted to robots, and unmanned space probes are becoming lighter, smaller and more convenient.

B However, experience has shown that the idea of humans in space is popular with the public. Humans can also be useful; there are many cases when only direct intervention by an astronaut or cosmonaut can correct the malfunction of an automatic device. Astronauts and cosmonauts have proved that they can adapt to conditions of weightlessness and work in space without encountering too many problems, as was seen in the operations to repair and to upgrade the Hubble Space Telescope. One human characteristic which is particularly precious in space missions, and which so far is lacking in robots, is the ability to perform a great variety of tasks. In addition, robots are not good at reacting to situations they have not been specifically prepared for. This is especially important in the case of deep space missions. While, in the case of the Moon, it is possible for someone on Earth to 'tele-operate' a robotic device such as a probe, as the two-way link time is only a couple of seconds, on Mars the two- way link time is several minutes, so sending instructions from Earth is more difficult.

C Many of the promises of artificial intelligence are still far from being fulfilled. The construction of machines simulating human logical reasoning moves towards ever more distant dates. The more the performance of computers improves, the more we realise how difficult it is to build machines which display logical abilities. In the past it was confidently predicted that we would soon have fully automated factories in which all operations were performed without any human intervention, and forecasts of the complete substitution of workers by robots in many production areas were made. Today, these perspectives are being revised. It seems that all machines, even the smartest ones, must cooperate with humans. Rather than replacing humans, the present need appears to be for an intelligent machine capable of helping a human operator without replacing him or her. The word 'cobot', from 'collaborative robot', has been invented to designate this type.

D A similar trend is also apparent in the field of space exploration. Tasks which were in the past entrusted only to machines are now performed by human beings, sometimes with the aim of using simpler and less costly devices, sometimes to obtain better performance. In many cases, to involve a person in the control loop is a welcome simplification which may lower the cost of a mission without compromising safety. Many operations originally designed to be performed under completely automatic control can be performed more efficiently by astronauts, perhaps helped by their 'cobots'. The human-machine relationship must evolve towards a closer collaboration.

E One way this could happen is by adopting the Mars Outposts approach, proposed by the Planetary Society. This would involve sending a number of robotic research stations to Mars, equipped with permanent communications and navigational systems. They would perform research, and establish the infrastructure needed to prepare future landing sites for the exploration of Mars by humans. It has also been suggested that in the most difficult environments, as on Venus or Jupiter, robots could be controlled by human beings located in spaceships which remain in orbit around the planet. In this case the link time for communication between humans and robots would be far less than it would be from Earth.

F But if space is to be more than a place to build automatic laboratories or set up industrial enterprises in the vicinity of our planet, the presence of humans is essential. They must learn how to voyage through space towards destinations which will be not only scientific bases but also places to live. If space is a frontier, that frontier must see the presence of people. So the aim for humankind in the future will be not just the exploration of space, but its colonisation. The result of exploring and living in space may be a deep change in the views which humankind has of itself. And this process is already under way. The images of Earth taken from the Moon in the Apollo programme have given humankind a new consciousness of its fragility, its smallness, and its unity. These impressions have triggered a realisation of the need to protect and preserve it, for it is the place in the solar system most suitable for US and above all it is the only place we have, at least for now.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cdf3ea56-5b23-50d7-bbaf-24651c10ad50', 'b458eab8-acc3-5615-b8ad-f7aae65672be', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-ix.
in boxes 1-6 on your answer sheet
List of Headings
Robots on Earth - a re-evaluation
The barriers to cooperation in space exploration
Some limitations of robots in space
Reduced expectations for space exploration
A general reconsideration of human/robot responsibilities in space
Problems in using humans for space exploration
The danger to humans of intelligent machines
Space settlement and the development of greater self-awareness
Possible examples of cooperation in space
1
Paragraph
A
2
Paragraph
B
3
Paragraph
c
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64ac5384-6b84-5a58-a771-a12203708b3b', 'cdf3ea56-5b23-50d7-bbaf-24651c10ad50', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12210abf-bbd3-5220-a1b1-37699d9cf6ce', 'cdf3ea56-5b23-50d7-bbaf-24651c10ad50', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dccc3657-fe9e-571c-ba3e-bfb01d3b9bfc', 'cdf3ea56-5b23-50d7-bbaf-24651c10ad50', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fa35565-4e05-5b9b-a254-eec8f0860a13', 'cdf3ea56-5b23-50d7-bbaf-24651c10ad50', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e27d7ab6-1179-5d44-941e-f29b7b54ba8c', 'cdf3ea56-5b23-50d7-bbaf-24651c10ad50', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45c83294-8c90-5f01-8625-8c456c72d774', 'cdf3ea56-5b23-50d7-bbaf-24651c10ad50', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81ee5219-cfb9-5330-b8aa-5613371ec0cb', 'cdf3ea56-5b23-50d7-bbaf-24651c10ad50', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c2610a8-a48f-551d-acdf-29240a1e8462', 'cdf3ea56-5b23-50d7-bbaf-24651c10ad50', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('685bca45-1c98-5e44-86d9-2e9a67073ddb', 'cdf3ea56-5b23-50d7-bbaf-24651c10ad50', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f0678d38-e906-5645-91ba-d0adc4d5ba5f', 'b458eab8-acc3-5615-b8ad-f7aae65672be', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-ix.
in boxes 1-6 on your answer sheet
List of Headings
Robots on Earth - a re-evaluation
The barriers to cooperation in space exploration
Some limitations of robots in space
Reduced expectations for space exploration
A general reconsideration of human/robot responsibilities in space
Problems in using humans for space exploration
The danger to humans of intelligent machines
Space settlement and the development of greater self-awareness
Possible examples of cooperation in space
1
Paragraph
A
2
Paragraph
B
3
Paragraph
c
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9639d13a-9280-55ac-9414-800db4c19e23', 'f0678d38-e906-5645-91ba-d0adc4d5ba5f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62bf8328-b9e2-543a-9813-9eba0f1ac3de', 'f0678d38-e906-5645-91ba-d0adc4d5ba5f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94630c2f-af01-5f3b-acc1-6fcfe2dbc167', 'f0678d38-e906-5645-91ba-d0adc4d5ba5f', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea089dfa-7fdd-59a4-9a87-20e072e44719', 'f0678d38-e906-5645-91ba-d0adc4d5ba5f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bac9fea6-845d-5ec8-9bcc-fa9e8a862daa', 'f0678d38-e906-5645-91ba-d0adc4d5ba5f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50ba169f-1141-51ef-ae10-bbb64393cdea', 'f0678d38-e906-5645-91ba-d0adc4d5ba5f', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1f4c73c-81a3-515a-8978-dbfe206f057a', 'f0678d38-e906-5645-91ba-d0adc4d5ba5f', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97fc7b13-d643-5c74-98d0-7e3234a01b15', 'f0678d38-e906-5645-91ba-d0adc4d5ba5f', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41919e9e-8358-5b94-81e9-020cd0988706', 'f0678d38-e906-5645-91ba-d0adc4d5ba5f', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('502182b6-bb64-5c7a-b8f3-deae46a0af6d', 'b458eab8-acc3-5615-b8ad-f7aae65672be', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-ix.
in boxes 1-6 on your answer sheet
List of Headings
Robots on Earth - a re-evaluation
The barriers to cooperation in space exploration
Some limitations of robots in space
Reduced expectations for space exploration
A general reconsideration of human/robot responsibilities in space
Problems in using humans for space exploration
The danger to humans of intelligent machines
Space settlement and the development of greater self-awareness
Possible examples of cooperation in space
1
Paragraph
A
2
Paragraph
B
3
Paragraph
c
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F

3 ____ Paragraph c$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98a48dd9-5f12-5613-a85f-15ae59fd2712', '502182b6-bb64-5c7a-b8f3-deae46a0af6d', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e5dfb09-125a-537e-aa92-87fdc3b8679f', '502182b6-bb64-5c7a-b8f3-deae46a0af6d', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8584d95-cbba-532a-9459-4f11dc2043ff', '502182b6-bb64-5c7a-b8f3-deae46a0af6d', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40aef16e-2cf5-5c74-bddf-28d1de6cd1e6', '502182b6-bb64-5c7a-b8f3-deae46a0af6d', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('caec2b81-85d8-52ff-916e-e394a6607d34', '502182b6-bb64-5c7a-b8f3-deae46a0af6d', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ac93941-41d8-5fda-9151-cacd87975b8d', '502182b6-bb64-5c7a-b8f3-deae46a0af6d', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa32bc72-e639-564f-9452-f56ce4d246e3', '502182b6-bb64-5c7a-b8f3-deae46a0af6d', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea570596-b136-5d5b-82bd-2381caf93dcf', '502182b6-bb64-5c7a-b8f3-deae46a0af6d', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b132b4e-be01-55be-8c20-3df81e05dc75', '502182b6-bb64-5c7a-b8f3-deae46a0af6d', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('be09182e-7c0d-5ed9-9df0-8d9d895c0953', 'b458eab8-acc3-5615-b8ad-f7aae65672be', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-ix.
in boxes 1-6 on your answer sheet
List of Headings
Robots on Earth - a re-evaluation
The barriers to cooperation in space exploration
Some limitations of robots in space
Reduced expectations for space exploration
A general reconsideration of human/robot responsibilities in space
Problems in using humans for space exploration
The danger to humans of intelligent machines
Space settlement and the development of greater self-awareness
Possible examples of cooperation in space
1
Paragraph
A
2
Paragraph
B
3
Paragraph
c
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68978a0a-6560-5d40-9b24-39c7d6aee4ea', 'be09182e-7c0d-5ed9-9df0-8d9d895c0953', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9328907-7cae-5e2d-84f9-7107e9fda1c2', 'be09182e-7c0d-5ed9-9df0-8d9d895c0953', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dda1c40c-bc1f-582e-8499-b0dc901a5ef7', 'be09182e-7c0d-5ed9-9df0-8d9d895c0953', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95dd15b2-d407-5929-8b90-14b63387008b', 'be09182e-7c0d-5ed9-9df0-8d9d895c0953', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3563729b-8e03-56ee-b400-4e33b9a6f727', 'be09182e-7c0d-5ed9-9df0-8d9d895c0953', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf780114-ad78-5ac2-a16b-41dd2308d2eb', 'be09182e-7c0d-5ed9-9df0-8d9d895c0953', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7ee9528-28ef-5a3a-83f4-0897d1b15145', 'be09182e-7c0d-5ed9-9df0-8d9d895c0953', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2cb4da6-337c-5e21-a56b-24d19c2054e2', 'be09182e-7c0d-5ed9-9df0-8d9d895c0953', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6795ae6-604e-5cbd-9ab1-0e770f195ee7', 'be09182e-7c0d-5ed9-9df0-8d9d895c0953', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c79f00fe-fd06-5177-a8ce-c9cdaa96a0fb', 'b458eab8-acc3-5615-b8ad-f7aae65672be', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-ix.
in boxes 1-6 on your answer sheet
List of Headings
Robots on Earth - a re-evaluation
The barriers to cooperation in space exploration
Some limitations of robots in space
Reduced expectations for space exploration
A general reconsideration of human/robot responsibilities in space
Problems in using humans for space exploration
The danger to humans of intelligent machines
Space settlement and the development of greater self-awareness
Possible examples of cooperation in space
1
Paragraph
A
2
Paragraph
B
3
Paragraph
c
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('daec97fe-ff14-51e0-ade8-6eeebb06246e', 'c79f00fe-fd06-5177-a8ce-c9cdaa96a0fb', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6673aa50-bc37-5461-a46d-d3c98333f724', 'c79f00fe-fd06-5177-a8ce-c9cdaa96a0fb', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd3c4ae0-d12d-5075-961d-9deae669398a', 'c79f00fe-fd06-5177-a8ce-c9cdaa96a0fb', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('018e58bb-fad3-5dc8-8cd2-8b82ddb75722', 'c79f00fe-fd06-5177-a8ce-c9cdaa96a0fb', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e88a40a-dc16-526e-a7f6-413fb5557fbf', 'c79f00fe-fd06-5177-a8ce-c9cdaa96a0fb', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8cb8376-064d-5aec-bfc9-b2ef7c9254da', 'c79f00fe-fd06-5177-a8ce-c9cdaa96a0fb', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca4b1822-27b6-5cd5-8905-9e28848d888f', 'c79f00fe-fd06-5177-a8ce-c9cdaa96a0fb', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82888c71-73c5-5452-aeaf-d6747d9a5ee5', 'c79f00fe-fd06-5177-a8ce-c9cdaa96a0fb', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('218dd1ba-e530-5043-bd96-46cd3a5a0c95', 'c79f00fe-fd06-5177-a8ce-c9cdaa96a0fb', 9, $md$ix$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2869012e-201d-5ba8-87c5-7eb58c9bdfee', 'b458eab8-acc3-5615-b8ad-f7aae65672be', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number,
i-ix.
in boxes 1-6 on your answer sheet
List of Headings
Robots on Earth - a re-evaluation
The barriers to cooperation in space exploration
Some limitations of robots in space
Reduced expectations for space exploration
A general reconsideration of human/robot responsibilities in space
Problems in using humans for space exploration
The danger to humans of intelligent machines
Space settlement and the development of greater self-awareness
Possible examples of cooperation in space
1
Paragraph
A
2
Paragraph
B
3
Paragraph
c
4
Paragraph
D
5
Paragraph
E
6
Paragraph
F

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5ea7175-a567-5443-8ab6-d17f804a52e9', '2869012e-201d-5ba8-87c5-7eb58c9bdfee', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d87440e-19b0-5b6b-b312-7f93bcce8883', '2869012e-201d-5ba8-87c5-7eb58c9bdfee', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7b66835-1df2-5507-93da-a97d3ef4c641', '2869012e-201d-5ba8-87c5-7eb58c9bdfee', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2970ce7-d69d-5221-aa78-306b5f060feb', '2869012e-201d-5ba8-87c5-7eb58c9bdfee', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a888e23-a095-550c-ab24-79662ccffe36', '2869012e-201d-5ba8-87c5-7eb58c9bdfee', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d44e6132-d605-5593-b964-fc543b658c5f', '2869012e-201d-5ba8-87c5-7eb58c9bdfee', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('321fdaf4-dc7d-5fb1-931e-f789ede3988f', '2869012e-201d-5ba8-87c5-7eb58c9bdfee', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef5db1bb-d612-501f-b0cb-2246b69d21b2', '2869012e-201d-5ba8-87c5-7eb58c9bdfee', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('240ee97a-d2c1-56a3-bcc2-c685add8b24e', '2869012e-201d-5ba8-87c5-7eb58c9bdfee', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('dcdf2565-b6df-586d-b7fc-e96da9d61c4a', 'b458eab8-acc3-5615-b8ad-f7aae65672be', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Complete the summary below. Choose
ONE WORD ONLY
from the passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
Humans in space - the Mars Outposts approach and its implications
One way of exploring space would be through collaboration between humans and robots. For example, when exploring the planet Mars, robots could be used to set up
9
and do initial research before humans arrive. In other cases, humans could stay in orbiting
10
and give orders to robots working on the surface of the planet.
This would increase the speed of
11
with the robots. In such ways, robots might be used to work in space in commercial enterprises or
12
. However, the final aim of humankind may be the
13
of space and this could in turn change people's attitudes towards Earth.

One way of exploring space would be through collaboration between humans and robots. For example, when exploring the planet Mars, robots could be used to set up 9 ____ and do initial research before humans arrive. In other cases, humans could stay in orbiting 10 ____ and give orders to robots working on the surface of the planet.$md$, NULL, ARRAY['.*infrastructure.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5ad896fa-f9cf-5cd1-a647-28468e1d763a', 'b458eab8-acc3-5615-b8ad-f7aae65672be', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Complete the summary below. Choose
ONE WORD ONLY
from the passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
Humans in space - the Mars Outposts approach and its implications
One way of exploring space would be through collaboration between humans and robots. For example, when exploring the planet Mars, robots could be used to set up
9
and do initial research before humans arrive. In other cases, humans could stay in orbiting
10
and give orders to robots working on the surface of the planet.
This would increase the speed of
11
with the robots. In such ways, robots might be used to work in space in commercial enterprises or
12
. However, the final aim of humankind may be the
13
of space and this could in turn change people's attitudes towards Earth.

One way of exploring space would be through collaboration between humans and robots. For example, when exploring the planet Mars, robots could be used to set up 9 ____ and do initial research before humans arrive. In other cases, humans could stay in orbiting 10 ____ and give orders to robots working on the surface of the planet.$md$, NULL, ARRAY['.*infrastructure.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('578e4a6a-2d47-5f43-ab89-d54317f31b51', 'b458eab8-acc3-5615-b8ad-f7aae65672be', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Complete the summary below. Choose
ONE WORD ONLY
from the passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
Humans in space - the Mars Outposts approach and its implications
One way of exploring space would be through collaboration between humans and robots. For example, when exploring the planet Mars, robots could be used to set up
9
and do initial research before humans arrive. In other cases, humans could stay in orbiting
10
and give orders to robots working on the surface of the planet.
This would increase the speed of
11
with the robots. In such ways, robots might be used to work in space in commercial enterprises or
12
. However, the final aim of humankind may be the
13
of space and this could in turn change people's attitudes towards Earth.

This would increase the speed of 11 ____ with the robots. In such ways, robots might be used to work in space in commercial enterprises or 12 ____ . However, the final aim of humankind may be the 13 ____ of space and this could in turn change people's attitudes towards Earth.$md$, NULL, ARRAY['.*communication.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('edd20516-9063-52a3-be3d-a2cdfceb8435', 'b458eab8-acc3-5615-b8ad-f7aae65672be', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Complete the summary below. Choose
ONE WORD ONLY
from the passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
Humans in space - the Mars Outposts approach and its implications
One way of exploring space would be through collaboration between humans and robots. For example, when exploring the planet Mars, robots could be used to set up
9
and do initial research before humans arrive. In other cases, humans could stay in orbiting
10
and give orders to robots working on the surface of the planet.
This would increase the speed of
11
with the robots. In such ways, robots might be used to work in space in commercial enterprises or
12
. However, the final aim of humankind may be the
13
of space and this could in turn change people's attitudes towards Earth.

This would increase the speed of 11 ____ with the robots. In such ways, robots might be used to work in space in commercial enterprises or 12 ____ . However, the final aim of humankind may be the 13 ____ of space and this could in turn change people's attitudes towards Earth.$md$, NULL, ARRAY['.*communication.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('621dfa2a-c278-5e86-8b3a-30960448e655', 'b458eab8-acc3-5615-b8ad-f7aae65672be', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Complete the summary below. Choose
ONE WORD ONLY
from the passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
Humans in space - the Mars Outposts approach and its implications
One way of exploring space would be through collaboration between humans and robots. For example, when exploring the planet Mars, robots could be used to set up
9
and do initial research before humans arrive. In other cases, humans could stay in orbiting
10
and give orders to robots working on the surface of the planet.
This would increase the speed of
11
with the robots. In such ways, robots might be used to work in space in commercial enterprises or
12
. However, the final aim of humankind may be the
13
of space and this could in turn change people's attitudes towards Earth.

This would increase the speed of 11 ____ with the robots. In such ways, robots might be used to work in space in commercial enterprises or 12 ____ . However, the final aim of humankind may be the 13 ____ of space and this could in turn change people's attitudes towards Earth.$md$, NULL, ARRAY['.*communication.*']);

COMMIT;
