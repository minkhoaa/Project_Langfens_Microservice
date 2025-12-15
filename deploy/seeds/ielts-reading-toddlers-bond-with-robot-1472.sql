BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-toddlers-bond-with-robot-1472'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-toddlers-bond-with-robot-1472';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-toddlers-bond-with-robot-1472';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-toddlers-bond-with-robot-1472';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('36740dc1-ff11-5965-91df-67c4afd17a76', 'ielts-reading-toddlers-bond-with-robot-1472', $t$Toddlers Bond With Robot$t$, $md$## Toddlers Bond With Robot

Nguồn:
- Test: https://mini-ielts.com/1472/reading/toddlers-bond-with-robot
- Solution: https://mini-ielts.com/1472/view-solution/reading/toddlers-bond-with-robot$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('af454402-9c4b-5413-acc9-8d5983acb6ca', '36740dc1-ff11-5965-91df-67c4afd17a76', 1, $t$Reading — Toddlers Bond With Robot$t$, $md$Read the passage and answer questions **1–15**.

### Passage: Toddlers Bond With Robot

(A) Will the robot revolution begin in nursery school? Researchers introduced a state-of-the-art social robot into a classroom of 18- to 24-month-olds for five months as a way of studying human-robot interactions. The children not only came to accept the robot, but treated it as they would a human buddy - hugging it and helping it - a new study says. "The results imply that current robot technology is surprisingly close to achieving autonomous bonding and socialization with human toddlers," said Fumihide Tanaka, a researcher at the University of California, San Diego

(B) The development of robots that interact socially with people has been difficult to achieve, experts say, partly because such interactions are hard to study. "To my knowledge, this is the first long-term study of this sort," said Ronald Arkin, a roboticist at the Georgia Institute of Technology, who was not involved with the study. "It is groundbreaking and helps to forward human-robot interaction studies significantly," he said.

(C) The most successful robots so far have been storytellers, but they have only been able to hold human interest for a limited time. For the new study, researchers introduced a toddler-size humanoid robot into a classroom at a UCSD childhood education center. Initially the researchers wanted to use a 22-inch-tall model, but later they decided to use another robot of the QRIO series, the 23-inch-tall (58-centimeter-tall) machine was originally developed by Sony. Children of toddler age were chosen because they have no preconceived notions of robots, said Tanaka, the lead researcher, who also works for Sony. The researchers sent instructions about every two minutes to the robot to do things like giggle, dance, sit down, or walk in a certain direction. The 45 sessions were videotaped, and interactions between toddlers and the robot were later analyzed.

(D) The results showed that the quality of those interactions improved steadily over 27 sessions. The tots began to increasingly interact with the robot and treat it more like a peer than an object during the first 11 sessions. The level of social activity increased dramatically when researchers added a new behavior to QRIO's repertoire: If a child touched the humanoid on its head, it would make a giggling noise. The interactions deteriorated quickly over the next 15 sessions, when the robot was reprogrammed to behave in a more limited, predictable manner. Finally, the human-robot relations improved in the last three sessions, after the robot had been reprogrammed to display its full range of behaviors. "Initially the children treated the robot very differently than the way they treated each other," Tanaka said. "But by the end they treated the robot as a peer rather than a toy."

(E) Early in the study some children cried when QRIO fell. But a month into the study, the toddlers helped QRIO stand up by pushing its back or pulling its hands. “The most important aspect of interaction was touch”, Tanaka said. “At first the toddlers would touch the robot on its face, but later on they would touch only on its hands and arms, like they would with other humans”. Another robotlike toy named Robby, which resembled QRIO but did not move, was used as a control toy in the study. While hugging of QRIO increased, hugging of Robby decreased throughout the study. Furthermore, when QRIO laid down on the floor as its batteries ran down, a toddler would put a blanket over his silver-colored "friend" and say "night-night."

(F) "Our work suggests that touch integrated on the time-scale of a few minutes is a surprisingly effective index of social connectedness," Tanaka says. "Something akin to this index may be used by the human brain to evaluate its own sense of social well-being." He adds that social robots like QRIO could greatly enrich classrooms and assist teachers in early learning programs. Hiroshi Ishiguro - robotics expert at Osaka University in Japan - says, "I think this study has clearly reported the possibilities of small, almost autonomous humanoid robots for toddlers. Nowadays robots can perform a variety of functions that were thought to be incident to people only - in short time we’ll have electronic baby-sitters and peer-robots in every kindergarten," said Ishiguro, who was not involved with the study but has collaborated with its authors on other projects.

(G) Now this study has taken a new direction - the researchers are now developing autonomous robots for the toddler classroom. "I cannot avoid underlining how great potential it could have in educational settings assisting teachers and enriching the classroom environment," Tanaka said. However, some scientists don’t share his opinion.

(H) Arkin, the Georgia Tech roboticist, said he was not surprised by the affection showed by the toddlers toward the robot. "Humans have a tremendous propensity to bond with artifacts with any or all sort, whether it be a car, a doll, or a robot," he said. But he also cautioned that researchers don't yet understand the consequences of increased human-robot interaction. "Just studying how robots and humans work together can give us insight into whether this is a good thing or a bad thing for society," Akrin said. "What are the consequences of introducing a robot artifact into a cadre of children? How will that enhance, or potentially interfere with, their social development? It might make life easier for the teacher, but we really don't understand the long-term impact of having a robot as a childhood friend, do we?"$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('767a2df3-f4a9-5201-80ee-d8c7fa885e79', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage 3 has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes 1-7 on your answer sheet. You may use any letter more than once.
1.
Changes in toddler-robot interactions quality.
1
2.
Comparison of two different robots.
2
3.
The fact that previous robots could maintain people’s interest only for a short time.
3
4.
The importance of touch.
4
5.
The new direction of the study.
5
6.
Technical parameters of the introduced robot.
6
7.
The significance and novelty of the conducted study.
7

1. Changes in toddler-robot interactions quality. 1 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc7dcd64-80ab-5245-9dd6-e97f8fce0217', '767a2df3-f4a9-5201-80ee-d8c7fa885e79', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf628ffb-d34a-5a81-b91b-886f9eeb247c', '767a2df3-f4a9-5201-80ee-d8c7fa885e79', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21df4d0f-ad26-5ea7-ad9b-298d8ab0b7c8', '767a2df3-f4a9-5201-80ee-d8c7fa885e79', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('443c474d-fc00-5d36-b0d7-cf9a78dd2e00', '767a2df3-f4a9-5201-80ee-d8c7fa885e79', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d28475bd-963b-53ac-b48a-c8e4e8279908', '767a2df3-f4a9-5201-80ee-d8c7fa885e79', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1eb9a6c6-92a4-5875-92f9-54743c679867', '767a2df3-f4a9-5201-80ee-d8c7fa885e79', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9558614-11ed-51af-b53e-b200ddc8833e', '767a2df3-f4a9-5201-80ee-d8c7fa885e79', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d829f60f-02da-5093-93f7-953e1ccedf6e', '767a2df3-f4a9-5201-80ee-d8c7fa885e79', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aa45609b-7e35-5ec5-a7cc-d9219ecc1261', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage 3 has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes 1-7 on your answer sheet. You may use any letter more than once.
1.
Changes in toddler-robot interactions quality.
1
2.
Comparison of two different robots.
2
3.
The fact that previous robots could maintain people’s interest only for a short time.
3
4.
The importance of touch.
4
5.
The new direction of the study.
5
6.
Technical parameters of the introduced robot.
6
7.
The significance and novelty of the conducted study.
7

2. Comparison of two different robots. 2 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60a15bb1-aa6c-5db4-8388-55e2855eca3b', 'aa45609b-7e35-5ec5-a7cc-d9219ecc1261', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c97b44bd-0fbb-57ed-b8dc-a1c898f17bd2', 'aa45609b-7e35-5ec5-a7cc-d9219ecc1261', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4794ccf-64de-55dd-82a2-398e9a0f5d06', 'aa45609b-7e35-5ec5-a7cc-d9219ecc1261', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13a3a337-95a1-5d33-bd47-df3e62d98ad3', 'aa45609b-7e35-5ec5-a7cc-d9219ecc1261', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06eb43b1-fbac-5325-83ba-b67f504eac84', 'aa45609b-7e35-5ec5-a7cc-d9219ecc1261', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fe3f255-47df-5fc6-89ff-48487a2970db', 'aa45609b-7e35-5ec5-a7cc-d9219ecc1261', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0869dbcc-6cde-5ec0-85a6-2cb6714ebd87', 'aa45609b-7e35-5ec5-a7cc-d9219ecc1261', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cf88b23-2280-5f3e-86be-13ca20b83282', 'aa45609b-7e35-5ec5-a7cc-d9219ecc1261', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('11c6e836-0100-50e3-9a76-06a7e9e71f55', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage 3 has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes 1-7 on your answer sheet. You may use any letter more than once.
1.
Changes in toddler-robot interactions quality.
1
2.
Comparison of two different robots.
2
3.
The fact that previous robots could maintain people’s interest only for a short time.
3
4.
The importance of touch.
4
5.
The new direction of the study.
5
6.
Technical parameters of the introduced robot.
6
7.
The significance and novelty of the conducted study.
7

3. The fact that previous robots could maintain people’s interest only for a short time. 3 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3ca6973-0245-551a-8ea1-0d09bcb93360', '11c6e836-0100-50e3-9a76-06a7e9e71f55', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('570cc679-3a60-53e2-9d50-d13c2a1f88de', '11c6e836-0100-50e3-9a76-06a7e9e71f55', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a18d9155-17f6-52f2-9336-83978eb7c48e', '11c6e836-0100-50e3-9a76-06a7e9e71f55', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc558ecf-5c32-5648-ad7d-6b1efec2e8ae', '11c6e836-0100-50e3-9a76-06a7e9e71f55', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1364e5fe-2b1a-5442-9a89-b59059268af9', '11c6e836-0100-50e3-9a76-06a7e9e71f55', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8a716e1-d42f-585a-a580-d07437042e8b', '11c6e836-0100-50e3-9a76-06a7e9e71f55', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2be6fbbb-b54c-598c-a677-435f9ae39abd', '11c6e836-0100-50e3-9a76-06a7e9e71f55', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc62745d-6d03-5e17-a6c5-d2d43edd689c', '11c6e836-0100-50e3-9a76-06a7e9e71f55', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('20929fe3-d4a9-540f-975b-9eee905a504b', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage 3 has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes 1-7 on your answer sheet. You may use any letter more than once.
1.
Changes in toddler-robot interactions quality.
1
2.
Comparison of two different robots.
2
3.
The fact that previous robots could maintain people’s interest only for a short time.
3
4.
The importance of touch.
4
5.
The new direction of the study.
5
6.
Technical parameters of the introduced robot.
6
7.
The significance and novelty of the conducted study.
7

4. The importance of touch. 4 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b08bfd5d-584b-5ccc-beef-725fd1d409e0', '20929fe3-d4a9-540f-975b-9eee905a504b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc09d63d-373b-5773-b556-70c25e55583c', '20929fe3-d4a9-540f-975b-9eee905a504b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e222c90-fa56-5d8a-b285-da7809b3a0e0', '20929fe3-d4a9-540f-975b-9eee905a504b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6374365-b2d8-5ed3-a4ea-2054546d34ea', '20929fe3-d4a9-540f-975b-9eee905a504b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94d89a0a-71f1-536c-9f18-897c7b53983b', '20929fe3-d4a9-540f-975b-9eee905a504b', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35daa4db-7a3a-50c4-96c0-f1af5c4c7a52', '20929fe3-d4a9-540f-975b-9eee905a504b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84656850-74d1-51d7-90c3-0802eab5c643', '20929fe3-d4a9-540f-975b-9eee905a504b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('859ea061-67cc-54aa-a454-4e1b7e2a69d4', '20929fe3-d4a9-540f-975b-9eee905a504b', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1255fe29-d335-507f-93a2-1497a604156c', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage 3 has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes 1-7 on your answer sheet. You may use any letter more than once.
1.
Changes in toddler-robot interactions quality.
1
2.
Comparison of two different robots.
2
3.
The fact that previous robots could maintain people’s interest only for a short time.
3
4.
The importance of touch.
4
5.
The new direction of the study.
5
6.
Technical parameters of the introduced robot.
6
7.
The significance and novelty of the conducted study.
7

5. The new direction of the study. 5 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d4487df-2f8d-5cf3-b94d-b13eed227f1b', '1255fe29-d335-507f-93a2-1497a604156c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('792a5666-02a3-5a52-8dbe-83ff6c8dfa61', '1255fe29-d335-507f-93a2-1497a604156c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed52b854-df53-5603-983b-5acae897274d', '1255fe29-d335-507f-93a2-1497a604156c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b197cd0-7827-5e32-95b5-35729dae37cc', '1255fe29-d335-507f-93a2-1497a604156c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3dcd08c2-de3c-52a3-9905-bd704c460eb2', '1255fe29-d335-507f-93a2-1497a604156c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4906976-a173-5cd6-a7b7-8db13c6c6b11', '1255fe29-d335-507f-93a2-1497a604156c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e8c7109-255a-503d-8b24-9a045b7c4a8a', '1255fe29-d335-507f-93a2-1497a604156c', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7237a227-6f0b-59d5-8b3b-0e60c3660d6e', '1255fe29-d335-507f-93a2-1497a604156c', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2b4e8067-fadb-5bb8-acbe-406c8550d0b8', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage 3 has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes 1-7 on your answer sheet. You may use any letter more than once.
1.
Changes in toddler-robot interactions quality.
1
2.
Comparison of two different robots.
2
3.
The fact that previous robots could maintain people’s interest only for a short time.
3
4.
The importance of touch.
4
5.
The new direction of the study.
5
6.
Technical parameters of the introduced robot.
6
7.
The significance and novelty of the conducted study.
7

6. Technical parameters of the introduced robot. 6 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0811c8f2-a796-59bc-b621-d7d178ae4a59', '2b4e8067-fadb-5bb8-acbe-406c8550d0b8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f54841e-efa4-5374-a11b-15bdc079d0a8', '2b4e8067-fadb-5bb8-acbe-406c8550d0b8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c028556-0fb4-5dc9-abd5-cd2860701c3f', '2b4e8067-fadb-5bb8-acbe-406c8550d0b8', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6b90511-0793-5afa-862e-2adebc906282', '2b4e8067-fadb-5bb8-acbe-406c8550d0b8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a34d6a56-ba4a-5c52-87aa-903207610da3', '2b4e8067-fadb-5bb8-acbe-406c8550d0b8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c01341b-4e46-5356-8286-4464a6654230', '2b4e8067-fadb-5bb8-acbe-406c8550d0b8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82fd4eb6-79df-50b8-9b6f-0c1c485894a2', '2b4e8067-fadb-5bb8-acbe-406c8550d0b8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2c2cd09-07d3-51ca-ba9b-fe81d2fa80a2', '2b4e8067-fadb-5bb8-acbe-406c8550d0b8', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae3d688f-c33f-5645-9fa5-7fd0f5346396', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage 3 has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter,
A-H
, in boxes 1-7 on your answer sheet. You may use any letter more than once.
1.
Changes in toddler-robot interactions quality.
1
2.
Comparison of two different robots.
2
3.
The fact that previous robots could maintain people’s interest only for a short time.
3
4.
The importance of touch.
4
5.
The new direction of the study.
5
6.
Technical parameters of the introduced robot.
6
7.
The significance and novelty of the conducted study.
7

7. The significance and novelty of the conducted study. 7 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('623a2dab-0e05-5095-ac32-3c28e4eb0981', 'ae3d688f-c33f-5645-9fa5-7fd0f5346396', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d344c35c-d909-55e1-9588-cd0c72e92af8', 'ae3d688f-c33f-5645-9fa5-7fd0f5346396', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('491692b7-398d-5ec7-a9a7-089912173e80', 'ae3d688f-c33f-5645-9fa5-7fd0f5346396', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54ce306a-86bb-5d6b-8253-6dfe6e546eee', 'ae3d688f-c33f-5645-9fa5-7fd0f5346396', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2915852-e550-5f70-a645-728af7d1b567', 'ae3d688f-c33f-5645-9fa5-7fd0f5346396', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b9b17fd-f0b2-5105-bd84-6fba589d7295', 'ae3d688f-c33f-5645-9fa5-7fd0f5346396', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5789c8d-116c-5940-9e93-51faa6cd7a66', 'ae3d688f-c33f-5645-9fa5-7fd0f5346396', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4251f8e3-5837-5532-991b-b05924e3f47b', 'ae3d688f-c33f-5645-9fa5-7fd0f5346396', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f8c1f892-6b3a-59a9-aeb7-f09c045298ac', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-12
Questions 8-12
Connect each of the statements below with the name of scientist who expressed it. Answer
A
,
B
, or
C
to questions 8-12.
A
Fumihide Tanaka
B
Ronald Arkin
C
Hiroshi Ishiguro
8.
Robots will perform duties of baby-sitters in the nearest future.
8
9.
By the end of the study children treated the robot as a living creature rather than a toy.
9
10.
The long-term impact of having a robot as a childhood friend can be negative.
10
11.
The conducted study is the first major study of this sort.
11
12.
Robots can be used in classrooms and assist teachers.
12

8. Robots will perform duties of baby-sitters in the nearest future. 8 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54fadf24-3d27-563e-bace-5beb26a75d60', 'f8c1f892-6b3a-59a9-aeb7-f09c045298ac', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ba18f33-0cef-501b-ab6a-f7348921a416', 'f8c1f892-6b3a-59a9-aeb7-f09c045298ac', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a2548db-6c83-50f2-b6af-4f7078eaf127', 'f8c1f892-6b3a-59a9-aeb7-f09c045298ac', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0bb4957c-ccde-5e91-9803-f4937ba50529', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-12
Questions 8-12
Connect each of the statements below with the name of scientist who expressed it. Answer
A
,
B
, or
C
to questions 8-12.
A
Fumihide Tanaka
B
Ronald Arkin
C
Hiroshi Ishiguro
8.
Robots will perform duties of baby-sitters in the nearest future.
8
9.
By the end of the study children treated the robot as a living creature rather than a toy.
9
10.
The long-term impact of having a robot as a childhood friend can be negative.
10
11.
The conducted study is the first major study of this sort.
11
12.
Robots can be used in classrooms and assist teachers.
12

9. By the end of the study children treated the robot as a living creature rather than a toy. 9 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('863e74c9-057a-58cc-a2bd-7216be02bfcb', '0bb4957c-ccde-5e91-9803-f4937ba50529', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46085067-532a-53ef-841e-3f83ade2efc3', '0bb4957c-ccde-5e91-9803-f4937ba50529', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8505567-5bf9-52d2-84de-18bd9f57b1cf', '0bb4957c-ccde-5e91-9803-f4937ba50529', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c1cd4fca-ef47-5f07-a60d-05e6d1edb641', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-12
Questions 8-12
Connect each of the statements below with the name of scientist who expressed it. Answer
A
,
B
, or
C
to questions 8-12.
A
Fumihide Tanaka
B
Ronald Arkin
C
Hiroshi Ishiguro
8.
Robots will perform duties of baby-sitters in the nearest future.
8
9.
By the end of the study children treated the robot as a living creature rather than a toy.
9
10.
The long-term impact of having a robot as a childhood friend can be negative.
10
11.
The conducted study is the first major study of this sort.
11
12.
Robots can be used in classrooms and assist teachers.
12

10. The long-term impact of having a robot as a childhood friend can be negative. 10 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c6e8d3a-d9bc-5d1a-9314-b9052e41d0d2', 'c1cd4fca-ef47-5f07-a60d-05e6d1edb641', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ddd8084-e90f-51c0-aaad-16ba67013179', 'c1cd4fca-ef47-5f07-a60d-05e6d1edb641', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84970525-b680-57e3-9473-45cdbb4b7413', 'c1cd4fca-ef47-5f07-a60d-05e6d1edb641', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0af52440-8fcd-5e9b-9702-0a1d06b3aa91', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-12
Questions 8-12
Connect each of the statements below with the name of scientist who expressed it. Answer
A
,
B
, or
C
to questions 8-12.
A
Fumihide Tanaka
B
Ronald Arkin
C
Hiroshi Ishiguro
8.
Robots will perform duties of baby-sitters in the nearest future.
8
9.
By the end of the study children treated the robot as a living creature rather than a toy.
9
10.
The long-term impact of having a robot as a childhood friend can be negative.
10
11.
The conducted study is the first major study of this sort.
11
12.
Robots can be used in classrooms and assist teachers.
12

11. The conducted study is the first major study of this sort. 11 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a31458b9-a35f-5252-8275-e5265c608bc1', '0af52440-8fcd-5e9b-9702-0a1d06b3aa91', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('891fba55-75d0-5826-9ab4-9bc3f5b27d70', '0af52440-8fcd-5e9b-9702-0a1d06b3aa91', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0de4cc91-1644-5a25-9de1-04398ad2472b', '0af52440-8fcd-5e9b-9702-0a1d06b3aa91', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('53fbd3bc-f054-5527-8810-a21bcf4b2f26', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 8-12
Questions 8-12
Connect each of the statements below with the name of scientist who expressed it. Answer
A
,
B
, or
C
to questions 8-12.
A
Fumihide Tanaka
B
Ronald Arkin
C
Hiroshi Ishiguro
8.
Robots will perform duties of baby-sitters in the nearest future.
8
9.
By the end of the study children treated the robot as a living creature rather than a toy.
9
10.
The long-term impact of having a robot as a childhood friend can be negative.
10
11.
The conducted study is the first major study of this sort.
11
12.
Robots can be used in classrooms and assist teachers.
12

12. Robots can be used in classrooms and assist teachers. 12 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc12d180-d3e7-51e6-a246-a0534ebd7f1b', '53fbd3bc-f054-5527-8810-a21bcf4b2f26', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bff45fbf-ddb7-5180-85b0-edf4073ff6eb', '53fbd3bc-f054-5527-8810-a21bcf4b2f26', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f08326b-3cca-53c7-8c92-f6c5edfcf039', '53fbd3bc-f054-5527-8810-a21bcf4b2f26', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e82dc563-183c-58d6-9f85-7dea1ace9c72', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 13-15
Questions 13-15
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes 13-15 on your answer sheet.
13. the study, researchers introduced a toddler-size humanoid robot that was
A
58-inch-tall
B
22-inch-tall
C
23-inch-tall
D
45-inch-tall
14. The researchers sent instructions to the robot to perform different actions EXCEPT
A
laugh
B
dance
C
sit down
D
crawl
15. The toddlers began to increasingly interact with the robot during
A
the first 11 sessions
B
the next 15 sessions
C
the first 27 sessions
D
the last 15 sessions

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ccf782e7-52cf-5b51-a462-78d71001e8cd', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 13-15
Questions 13-15
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes 13-15 on your answer sheet.
13. the study, researchers introduced a toddler-size humanoid robot that was
A
58-inch-tall
B
22-inch-tall
C
23-inch-tall
D
45-inch-tall
14. The researchers sent instructions to the robot to perform different actions EXCEPT
A
laugh
B
dance
C
sit down
D
crawl
15. The toddlers began to increasingly interact with the robot during
A
the first 11 sessions
B
the next 15 sessions
C
the first 27 sessions
D
the last 15 sessions

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7bac5fba-ba05-5bba-9598-42a2b1f495ef', 'af454402-9c4b-5413-acc9-8d5983acb6ca', 15, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 15

Questions 13-15
Questions 13-15
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes 13-15 on your answer sheet.
13. the study, researchers introduced a toddler-size humanoid robot that was
A
58-inch-tall
B
22-inch-tall
C
23-inch-tall
D
45-inch-tall
14. The researchers sent instructions to the robot to perform different actions EXCEPT
A
laugh
B
dance
C
sit down
D
crawl
15. The toddlers began to increasingly interact with the robot during
A
the first 11 sessions
B
the next 15 sessions
C
the first 27 sessions
D
the last 15 sessions

Choose the correct letter, A, B, C or D .$md$, NULL);

COMMIT;
