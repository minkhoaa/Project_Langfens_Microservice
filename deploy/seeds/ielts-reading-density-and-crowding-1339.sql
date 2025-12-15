BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-density-and-crowding-1339'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-density-and-crowding-1339';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-density-and-crowding-1339';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-density-and-crowding-1339';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('63961cb0-e0bf-55f9-b4fb-4c1b52b53ad3', 'ielts-reading-density-and-crowding-1339', $t$Density and Crowding$t$, $md$## Density and Crowding

Nguồn:
- Test: https://mini-ielts.com/1339/reading/density-and-crowding
- Solution: https://mini-ielts.com/1339/view-solution/reading/density-and-crowding$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('ad565451-f73d-52fd-bbaa-0c8395d9097c', '63961cb0-e0bf-55f9-b4fb-4c1b52b53ad3', 1, $t$Reading — Density and Crowding$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Density and Crowding

A. Of the great myriad of problems which man and the world face today, there are three significant fiends which stand above all others in importance: the uprecedented population growth throughout the world a net increase of 1,400,000 people per week and all of its associations and consequences; the increasing urbanization of these people, so that more and more of them are rushing into cities and urban areas of the world; and the tremendous explosion of communication and social contact throughout the world, so that every part of the world is now aware of every other part. All of these fiends are producing increased crowding and the perception of crowding.

B . It is important to emphasize at the outset that crowding and density are not necessarily the same. Density is the number of individuals per unit area or unit space. It is a simple physical measurement. Crowding is a product of density, communication, contact, and activity. It implies a pressure, a force, and a psychological reaction. It may occur at widely different densities.

The frontiersman may have felt crowded when someone built a homestead a mile away. The suburbanite may feel relatively uncrowded in a small house on a half-acre lot if it is surrounded by trees, bushes, and a hedgerow, even though he lives under much higher physical density than did the frontiersman. Hence, crowding is very much a psychological and ecological phenomenon, and not just a physical condition.

C. A classic crowding study was done by Calhoun (1962), who put rats into a physical environment designed to accommodate 50 rats and provided enough food, water, and nesting materials for the number of rats in the environment. The rat population peaked at 80, providing a look at ramped living conditions. Although the rats experienced no resource limitations other than space restriction, a number of negative conditions developed: the two most dominant males took harems of several female rats and occupied more than their share of space, leaving other rats even more crowded; many females stopped building nests and abandoned their infant rats; the pregnancy rate declined; infant and adult mortality rates increased; more aggressive and physical attacks occurred; sexual variation increased, including hypersexuality, inhibited sexuality, homosexuality, and bisexuality.

D . Calhoun’s results have led to other research on crowding’s effects on human beings, and these research findings have suggested that high density is not the single cause of negative effects on humans. When crowding is defined only in terms of spatial density (the amount of space per person), the effects of crowding are variable. However, if crowding is defined in terms of social density, or the number of people who must interact, then crowding better predicts negative psychological and physical effects.

E. There are several reasons why crowding makes US feel uncomfortable. One reason is related to stimulus overload there are just too many stimuli competing for our attention. We cannot notice or respond to all of them. This feeling is typical of the harried mother, who has several children competing for her attention, while she is on the phone and the doorbell is ringing. This leaves her feeling confused, fatigued and yearning to withdraw from the situation. There are strong feelings of a lack of privacy – being unable to pay attention to what you want without being repeatedly interrupted or observed by others.

F. Field studies done in a variety of settings illustrate that social density is associated with negative effects on human beings. In prison studies, males generally became more aggressive with increases in density. In male prison, inmate; living in conditions of higher densities were more likely to suffer from fight. Males rated themselves as more aggressive in small rooms (a situation of high spatial density), whilst the females rated themselves as more aggressive in large rooms (Stokols et al., 1973). These differences relate to the different personal space requirements of the genders.

Besides, Baum and Greenberg found that high density leads to decreased attraction, both physical attraction and liking towards others and it appears to have gender differences in the impact that density has on attraction levels, with males experiencing a more extreme reaction. Also, the greater the density is, the less the helping behavior. One reason why the level of helping behavior may be reduced in crowded situations links to the concept of diffusion of responsibility. The more people that are present in a situation that requires help, the less often help is given. This may be due to the fact that people diffuse responsibility among themselves with no-one feeling that they ought to be the one to help.

G . Facing all these problems, what are we going to do with them? The more control a person has over the crowded environment the less negatively they experience it, thus the perceived crowding is less (Schmidt and Keating). The ability to cope with crowding is also influenced by the relationship the individual has with the other people in the situation. The high density will be interpreted less negatively if the individual experiences it with people he likes. One of the main coping strategies employed to limit the impact of high density is social withdrawal. This includes behaviors such as averting the gaze and using negative body language to attempt to block any potential intrusions.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bda6cf48-065d-5b65-9009-230d3a4921ca', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading passage 1 has seven paragraphs, A-G
Choose the correct heading for paragraphs A -G from the list of headings below.
Write the correct number, i-x, in boxes
1-7
on your answer sheet.
List of headings
i Other experiments following Calhoun’s experiment offering a clearer indication
ii The effects of crowding on people in the social scope
iii Psychological reaction to crowding
iv Problems that result in crowding
v Responsibility does not work
vi What cause the upset feel of crowding
vii Definitions of crowding and density
viii Advice for crowded work environment
ix Difference between male and females’ attractiveness in a crowd
x Nature and results of Calboun’s experiment
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph c 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f78713d-5816-5cc7-9f32-51b132d86184', 'bda6cf48-065d-5b65-9009-230d3a4921ca', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ff840aa-cb31-5cac-9841-c12477bf1ad5', 'bda6cf48-065d-5b65-9009-230d3a4921ca', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71fe912c-c442-5bdc-a499-fcb1ffb58122', 'bda6cf48-065d-5b65-9009-230d3a4921ca', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ada34c3-a17c-58d2-8c21-a2dcb2e6b3c9', 'bda6cf48-065d-5b65-9009-230d3a4921ca', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0aebb67-634d-553e-bd12-173bbff50c8e', 'bda6cf48-065d-5b65-9009-230d3a4921ca', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('164a5d50-2cf0-5f3d-832f-3cfa41d47e94', 'bda6cf48-065d-5b65-9009-230d3a4921ca', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6b17ab6-73b1-5784-8534-8ca427c6caa2', 'bda6cf48-065d-5b65-9009-230d3a4921ca', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90af984a-3a83-5182-ab41-d231588b48bc', 'bda6cf48-065d-5b65-9009-230d3a4921ca', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbde34ef-3faf-5d52-997c-6a9d09e18080', 'bda6cf48-065d-5b65-9009-230d3a4921ca', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09012c48-40ca-5c89-8a0f-dce312dc895c', 'bda6cf48-065d-5b65-9009-230d3a4921ca', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e4c23e24-7bb9-5197-8e5c-d9d5b55376a1', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading passage 1 has seven paragraphs, A-G
Choose the correct heading for paragraphs A -G from the list of headings below.
Write the correct number, i-x, in boxes
1-7
on your answer sheet.
List of headings
i Other experiments following Calhoun’s experiment offering a clearer indication
ii The effects of crowding on people in the social scope
iii Psychological reaction to crowding
iv Problems that result in crowding
v Responsibility does not work
vi What cause the upset feel of crowding
vii Definitions of crowding and density
viii Advice for crowded work environment
ix Difference between male and females’ attractiveness in a crowd
x Nature and results of Calboun’s experiment
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph c 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f985cf9c-ff5f-5ba2-9377-6c95888de5f7', 'e4c23e24-7bb9-5197-8e5c-d9d5b55376a1', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7e6cdc7-ff17-5852-bd46-cc7a638a6574', 'e4c23e24-7bb9-5197-8e5c-d9d5b55376a1', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd714894-32bc-5924-823a-8b42f5ef0e17', 'e4c23e24-7bb9-5197-8e5c-d9d5b55376a1', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dae8998a-e362-572d-ba2d-d4a9f1c459df', 'e4c23e24-7bb9-5197-8e5c-d9d5b55376a1', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8c050af-aecf-53f7-893f-156ebf315fa0', 'e4c23e24-7bb9-5197-8e5c-d9d5b55376a1', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82f0d429-de92-57d8-a22f-fdbb75eef2b5', 'e4c23e24-7bb9-5197-8e5c-d9d5b55376a1', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7c8627c-57d7-5b9f-a533-10d13a4bec41', 'e4c23e24-7bb9-5197-8e5c-d9d5b55376a1', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a652ac3b-afd8-5615-bf59-9942b04b1af4', 'e4c23e24-7bb9-5197-8e5c-d9d5b55376a1', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d069858e-d536-517f-ae02-472af7593b82', 'e4c23e24-7bb9-5197-8e5c-d9d5b55376a1', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92331d84-13aa-5116-b69f-57204890653d', 'e4c23e24-7bb9-5197-8e5c-d9d5b55376a1', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e96f85ca-11d3-5146-96eb-917e4f58b74e', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading passage 1 has seven paragraphs, A-G
Choose the correct heading for paragraphs A -G from the list of headings below.
Write the correct number, i-x, in boxes
1-7
on your answer sheet.
List of headings
i Other experiments following Calhoun’s experiment offering a clearer indication
ii The effects of crowding on people in the social scope
iii Psychological reaction to crowding
iv Problems that result in crowding
v Responsibility does not work
vi What cause the upset feel of crowding
vii Definitions of crowding and density
viii Advice for crowded work environment
ix Difference between male and females’ attractiveness in a crowd
x Nature and results of Calboun’s experiment
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph c 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39f20207-8119-5df9-a613-4b3a2c5545ca', 'e96f85ca-11d3-5146-96eb-917e4f58b74e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('009dd757-0295-55ce-a2b0-ae149736e5ff', 'e96f85ca-11d3-5146-96eb-917e4f58b74e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e7c7809-0a0d-5201-bae4-266f096988f3', 'e96f85ca-11d3-5146-96eb-917e4f58b74e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b7b6b2e-d9f9-5315-bed8-ab08ed57e505', 'e96f85ca-11d3-5146-96eb-917e4f58b74e', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cab5c1d4-f8d3-5cfd-9a36-55f62707b649', 'e96f85ca-11d3-5146-96eb-917e4f58b74e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('588a3049-9c89-51a8-9938-490e07103881', 'e96f85ca-11d3-5146-96eb-917e4f58b74e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('709d7371-364f-5ddf-92c4-7ddd3dc71aa1', 'e96f85ca-11d3-5146-96eb-917e4f58b74e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2e9547b-fb7d-5445-b51b-990107f12f92', 'e96f85ca-11d3-5146-96eb-917e4f58b74e', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfb9d56b-8ea2-5805-acd9-fe663491fe39', 'e96f85ca-11d3-5146-96eb-917e4f58b74e', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ad24b44-1426-5d30-a5ea-5df085cd9343', 'e96f85ca-11d3-5146-96eb-917e4f58b74e', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae6729c1-e58c-56aa-a8d3-c05b76ab1095', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading passage 1 has seven paragraphs, A-G
Choose the correct heading for paragraphs A -G from the list of headings below.
Write the correct number, i-x, in boxes
1-7
on your answer sheet.
List of headings
i Other experiments following Calhoun’s experiment offering a clearer indication
ii The effects of crowding on people in the social scope
iii Psychological reaction to crowding
iv Problems that result in crowding
v Responsibility does not work
vi What cause the upset feel of crowding
vii Definitions of crowding and density
viii Advice for crowded work environment
ix Difference between male and females’ attractiveness in a crowd
x Nature and results of Calboun’s experiment
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph c 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d54be829-ba19-5e35-8f52-af1ce72381f1', 'ae6729c1-e58c-56aa-a8d3-c05b76ab1095', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('802a968c-4198-5830-a45c-108be80e79fc', 'ae6729c1-e58c-56aa-a8d3-c05b76ab1095', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6250ebe-f87c-5e24-8e2b-cc0348ba7a47', 'ae6729c1-e58c-56aa-a8d3-c05b76ab1095', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab58c432-da5a-5f9d-9dc6-bdc6c1d0943e', 'ae6729c1-e58c-56aa-a8d3-c05b76ab1095', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4d00e14-4241-5e83-be14-df17eb3ee3d6', 'ae6729c1-e58c-56aa-a8d3-c05b76ab1095', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fac0ccd8-a429-59ee-914a-ccb936f15b11', 'ae6729c1-e58c-56aa-a8d3-c05b76ab1095', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24218469-8a4b-5bf7-b3c0-5004f27ec38a', 'ae6729c1-e58c-56aa-a8d3-c05b76ab1095', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9cc93344-81c7-598b-bf13-13256acaeec9', 'ae6729c1-e58c-56aa-a8d3-c05b76ab1095', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4fcf4c2-107f-587e-86c8-2f1ba47525f7', 'ae6729c1-e58c-56aa-a8d3-c05b76ab1095', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af1e67ac-cc7e-5139-b92b-fc1fd0170274', 'ae6729c1-e58c-56aa-a8d3-c05b76ab1095', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0d2d9bc8-0367-50d3-b9c3-54c899f59bd2', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading passage 1 has seven paragraphs, A-G
Choose the correct heading for paragraphs A -G from the list of headings below.
Write the correct number, i-x, in boxes
1-7
on your answer sheet.
List of headings
i Other experiments following Calhoun’s experiment offering a clearer indication
ii The effects of crowding on people in the social scope
iii Psychological reaction to crowding
iv Problems that result in crowding
v Responsibility does not work
vi What cause the upset feel of crowding
vii Definitions of crowding and density
viii Advice for crowded work environment
ix Difference between male and females’ attractiveness in a crowd
x Nature and results of Calboun’s experiment
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph c 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ba20173-71e5-5ba7-a5da-06c446968097', '0d2d9bc8-0367-50d3-b9c3-54c899f59bd2', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81073670-6b5d-5607-aa0b-ed8c9287d18e', '0d2d9bc8-0367-50d3-b9c3-54c899f59bd2', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc8d34ee-1556-5458-8b2a-4f4c2c966ae1', '0d2d9bc8-0367-50d3-b9c3-54c899f59bd2', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e84ca0b5-fc45-588e-a0c3-e96bb3e007b0', '0d2d9bc8-0367-50d3-b9c3-54c899f59bd2', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07aaa87a-96b0-5411-885a-be884cfe3371', '0d2d9bc8-0367-50d3-b9c3-54c899f59bd2', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f691475-c95d-5974-8f25-82c7c6b1751a', '0d2d9bc8-0367-50d3-b9c3-54c899f59bd2', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12344f67-aa1c-5639-b3f3-02b9265adb5e', '0d2d9bc8-0367-50d3-b9c3-54c899f59bd2', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d294610-9076-5efa-8fe8-e698466a2bbb', '0d2d9bc8-0367-50d3-b9c3-54c899f59bd2', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9ac4e3e-4ab2-56bb-8de5-f08aa28b3607', '0d2d9bc8-0367-50d3-b9c3-54c899f59bd2', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a675c072-15ee-535a-8bdf-383411b73796', '0d2d9bc8-0367-50d3-b9c3-54c899f59bd2', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a255cf60-0713-5873-8210-14f3e7f57d29', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading passage 1 has seven paragraphs, A-G
Choose the correct heading for paragraphs A -G from the list of headings below.
Write the correct number, i-x, in boxes
1-7
on your answer sheet.
List of headings
i Other experiments following Calhoun’s experiment offering a clearer indication
ii The effects of crowding on people in the social scope
iii Psychological reaction to crowding
iv Problems that result in crowding
v Responsibility does not work
vi What cause the upset feel of crowding
vii Definitions of crowding and density
viii Advice for crowded work environment
ix Difference between male and females’ attractiveness in a crowd
x Nature and results of Calboun’s experiment
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph c 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9de70a33-1dcd-52e4-a68b-5f9b1500ed15', 'a255cf60-0713-5873-8210-14f3e7f57d29', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87f55681-1a26-582c-9d74-64430022ca86', 'a255cf60-0713-5873-8210-14f3e7f57d29', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bf2588e-be9a-5f1a-9306-9b4960173a88', 'a255cf60-0713-5873-8210-14f3e7f57d29', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd9b44ca-d7fd-5219-bd51-26543a61d7ab', 'a255cf60-0713-5873-8210-14f3e7f57d29', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('688ccc72-0c94-520a-89b2-146f99ff8dc9', 'a255cf60-0713-5873-8210-14f3e7f57d29', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc4b3b4c-3b5a-5919-9cb9-9160d0b68a02', 'a255cf60-0713-5873-8210-14f3e7f57d29', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4949595-3338-52b1-9016-5bf0abae32bf', 'a255cf60-0713-5873-8210-14f3e7f57d29', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14b93642-99d9-56cd-a55a-f0d7bc2bf987', 'a255cf60-0713-5873-8210-14f3e7f57d29', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a793deb9-df23-5365-b9a0-b99e040a63fa', 'a255cf60-0713-5873-8210-14f3e7f57d29', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7bc81a6-3650-5c03-b5cd-0533148d9deb', 'a255cf60-0713-5873-8210-14f3e7f57d29', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aef37de1-f1ec-5236-9520-9b047f16538f', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading passage 1 has seven paragraphs, A-G
Choose the correct heading for paragraphs A -G from the list of headings below.
Write the correct number, i-x, in boxes
1-7
on your answer sheet.
List of headings
i Other experiments following Calhoun’s experiment offering a clearer indication
ii The effects of crowding on people in the social scope
iii Psychological reaction to crowding
iv Problems that result in crowding
v Responsibility does not work
vi What cause the upset feel of crowding
vii Definitions of crowding and density
viii Advice for crowded work environment
ix Difference between male and females’ attractiveness in a crowd
x Nature and results of Calboun’s experiment
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

1 ____ Paragraph A 2 ____ Paragraph B 3 ____ Paragraph c 4 ____ Paragraph D 5 ____ Paragraph E 6 ____ Paragraph F 7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2f7f9c8-81fd-5f8d-ac89-6ddb51195136', 'aef37de1-f1ec-5236-9520-9b047f16538f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d54abfd9-b898-551e-840e-ad6bd21862a0', 'aef37de1-f1ec-5236-9520-9b047f16538f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef33615f-de9d-5552-adf7-cd543b1ca428', 'aef37de1-f1ec-5236-9520-9b047f16538f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ec8d357-af5d-55a7-ba96-9cd8d933dded', 'aef37de1-f1ec-5236-9520-9b047f16538f', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea5cd00f-6dcc-561b-ae42-af4d4b0614fc', 'aef37de1-f1ec-5236-9520-9b047f16538f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55cbc15d-9237-5690-b9bc-e9d0e10add31', 'aef37de1-f1ec-5236-9520-9b047f16538f', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62eb15ee-763a-59f4-8951-02e2a3c03abb', 'aef37de1-f1ec-5236-9520-9b047f16538f', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df5c5ae6-e72f-564b-9f9f-4dcdee7a0fa4', 'aef37de1-f1ec-5236-9520-9b047f16538f', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc129df8-3616-50e5-8fe3-1f174c942ed8', 'aef37de1-f1ec-5236-9520-9b047f16538f', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d9aad2d-895b-5ed1-bcf5-55c1198ebe7c', 'aef37de1-f1ec-5236-9520-9b047f16538f', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9da9d340-7e12-5f34-b88b-b9b47be4f18d', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 8, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
8
Being disturbed repeatedly, the harried mother feels frustrated for the lack of
8
9
Inmates in high density settings were more aggressive in
9
10
The different result between male and female is associated with the varying need of
10
11
Especially for male, Baum and Greenberg found that
11
declined with high density.
12
The idea of responsibility diffusion may explain a person’s reluctant to
12
##a
13
Schmidt and Keating suggest that if more
13
was present there would be a reduction in crowding stress.

8 Being disturbed repeatedly, the harried mother feels frustrated for the lack of 8 ____ 9 Inmates in high density settings were more aggressive in 9 ____ 10 The different result between male and female is associated with the varying need of 10 ____ 11 Especially for male, Baum and Greenberg found that 11 ____ declined with high density. 12 The idea of responsibility diffusion may explain a person’s reluctant to 12 ____ ##a 13 Schmidt and Keating suggest that if more 13 ____ was present there would be a reduction in crowding stress.$md$, NULL, ARRAY['.*privacy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6cbed426-5bd5-53a8-9445-097696af143b', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 9, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
8
Being disturbed repeatedly, the harried mother feels frustrated for the lack of
8
9
Inmates in high density settings were more aggressive in
9
10
The different result between male and female is associated with the varying need of
10
11
Especially for male, Baum and Greenberg found that
11
declined with high density.
12
The idea of responsibility diffusion may explain a person’s reluctant to
12
##a
13
Schmidt and Keating suggest that if more
13
was present there would be a reduction in crowding stress.

8 Being disturbed repeatedly, the harried mother feels frustrated for the lack of 8 ____ 9 Inmates in high density settings were more aggressive in 9 ____ 10 The different result between male and female is associated with the varying need of 10 ____ 11 Especially for male, Baum and Greenberg found that 11 ____ declined with high density. 12 The idea of responsibility diffusion may explain a person’s reluctant to 12 ____ ##a 13 Schmidt and Keating suggest that if more 13 ____ was present there would be a reduction in crowding stress.$md$, NULL, ARRAY['.*privacy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fd522bd3-9267-5527-bc39-a3fad98dea47', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 10, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
8
Being disturbed repeatedly, the harried mother feels frustrated for the lack of
8
9
Inmates in high density settings were more aggressive in
9
10
The different result between male and female is associated with the varying need of
10
11
Especially for male, Baum and Greenberg found that
11
declined with high density.
12
The idea of responsibility diffusion may explain a person’s reluctant to
12
##a
13
Schmidt and Keating suggest that if more
13
was present there would be a reduction in crowding stress.

8 Being disturbed repeatedly, the harried mother feels frustrated for the lack of 8 ____ 9 Inmates in high density settings were more aggressive in 9 ____ 10 The different result between male and female is associated with the varying need of 10 ____ 11 Especially for male, Baum and Greenberg found that 11 ____ declined with high density. 12 The idea of responsibility diffusion may explain a person’s reluctant to 12 ____ ##a 13 Schmidt and Keating suggest that if more 13 ____ was present there would be a reduction in crowding stress.$md$, NULL, ARRAY['.*privacy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2add7639-0ca8-5146-a21a-311c7fb21e9f', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
8
Being disturbed repeatedly, the harried mother feels frustrated for the lack of
8
9
Inmates in high density settings were more aggressive in
9
10
The different result between male and female is associated with the varying need of
10
11
Especially for male, Baum and Greenberg found that
11
declined with high density.
12
The idea of responsibility diffusion may explain a person’s reluctant to
12
##a
13
Schmidt and Keating suggest that if more
13
was present there would be a reduction in crowding stress.

8 Being disturbed repeatedly, the harried mother feels frustrated for the lack of 8 ____ 9 Inmates in high density settings were more aggressive in 9 ____ 10 The different result between male and female is associated with the varying need of 10 ____ 11 Especially for male, Baum and Greenberg found that 11 ____ declined with high density. 12 The idea of responsibility diffusion may explain a person’s reluctant to 12 ____ ##a 13 Schmidt and Keating suggest that if more 13 ____ was present there would be a reduction in crowding stress.$md$, NULL, ARRAY['.*privacy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5d8a4c3a-f779-585e-9e53-08be46f01d00', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
8
Being disturbed repeatedly, the harried mother feels frustrated for the lack of
8
9
Inmates in high density settings were more aggressive in
9
10
The different result between male and female is associated with the varying need of
10
11
Especially for male, Baum and Greenberg found that
11
declined with high density.
12
The idea of responsibility diffusion may explain a person’s reluctant to
12
##a
13
Schmidt and Keating suggest that if more
13
was present there would be a reduction in crowding stress.

8 Being disturbed repeatedly, the harried mother feels frustrated for the lack of 8 ____ 9 Inmates in high density settings were more aggressive in 9 ____ 10 The different result between male and female is associated with the varying need of 10 ____ 11 Especially for male, Baum and Greenberg found that 11 ____ declined with high density. 12 The idea of responsibility diffusion may explain a person’s reluctant to 12 ____ ##a 13 Schmidt and Keating suggest that if more 13 ____ was present there would be a reduction in crowding stress.$md$, NULL, ARRAY['.*privacy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5855900c-ef53-5bd4-a037-dc5aad434175', 'ad565451-f73d-52fd-bbaa-0c8395d9097c', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Complete the sentences below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
8
Being disturbed repeatedly, the harried mother feels frustrated for the lack of
8
9
Inmates in high density settings were more aggressive in
9
10
The different result between male and female is associated with the varying need of
10
11
Especially for male, Baum and Greenberg found that
11
declined with high density.
12
The idea of responsibility diffusion may explain a person’s reluctant to
12
##a
13
Schmidt and Keating suggest that if more
13
was present there would be a reduction in crowding stress.

8 Being disturbed repeatedly, the harried mother feels frustrated for the lack of 8 ____ 9 Inmates in high density settings were more aggressive in 9 ____ 10 The different result between male and female is associated with the varying need of 10 ____ 11 Especially for male, Baum and Greenberg found that 11 ____ declined with high density. 12 The idea of responsibility diffusion may explain a person’s reluctant to 12 ____ ##a 13 Schmidt and Keating suggest that if more 13 ____ was present there would be a reduction in crowding stress.$md$, NULL, ARRAY['.*privacy.*']);

COMMIT;
