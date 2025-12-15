BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-e-training-1521'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-e-training-1521';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-e-training-1521';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-e-training-1521';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('04d2f8bc-eacf-570b-bcdd-fd2a2b182aaa', 'ielts-reading-e-training-1521', $t$E-training$t$, $md$## E-training

Nguồn:
- Test: https://mini-ielts.com/1521/reading/e-training
- Solution: https://mini-ielts.com/1521/view-solution/reading/e-training$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f846bd80-6b21-5bf5-b92d-24df1a6a8566', '04d2f8bc-eacf-570b-bcdd-fd2a2b182aaa', 1, $t$Reading — E-training$t$, $md$Read the passage and answer questions **1–10**.

### Passage: E-training

A

E-learning is the unifying term to describe the fields of online learning, web-based training, and technology-delivered instruction, which can be a great benefit to corporate e-learning. IBM, for instance, claims that the institution of its e-training program, Basic Blue, whose purpose is to train new managers, saved the company in the range of $200 million in 1999. Cutting the travel expenses required to bring employees and instructors to a central classroom account for the lion’s share of the savings. With an online course, employees can learn from any Internet-connected PC, anywhere in the world. Ernst and Young reduced training costs by 35 percent while improving consistency and scalability.

B

In addition to generally positive economic benefits, other advantages such as convenience, standardized delivery, self-paced learning, and a variety of available content, have made e-learning a high priority for many corporations. E-learning is widely believed to offer flexible “any time, any place” learning. The claim for “any place” is valid in principle and is a great development. Many people can engage with rich learning materials that simply were not possible in a paper of broadcast distance learning era. For teaching specific information and skills, e-training holds great promise. It can be especially effective at helping employees prepare for IT certification programs. E-learning also seems to effectively address topics such as sexual harassment education’, safety training and management training – all areas where a clear set of objectives can be identified. Ultimately, training experts recommend a “blended” approach that combines both online and in-person training as the instruction requires. E-learning is not an end-all solution. But if it helps decrease costs and windowless classrooms filled with snoring students, it definitely has its advantages.

C

Much of the discussion about implementing e-learning has focused on the technology, but as Driscoll and others have reminded us, e-learning is not just about the technology, but also many human factors. As any capable manager knows, teaching employees new skills is critical to a smoothly run business. Having said that, however, the traditional route of classroom instruction runs the risk of being expensive, slow and, oftentimes, ineffective. Perhaps the classroom’s greatest disadvantage is the fact that it takes employees out of their jobs. Every minute an employee is sitting in a classroom training session is a minute they’re not out on the floor working. It now looks as if there is a way to circumvent these traditional training drawbacks. E-training promises more effective teaching techniques by integrating audio, video, animation, text and interactive materials with the intent of teaching each student at his or her own pace. In addition to higher performance results, there are other immediate benefits to students such as increased time on task, higher levels of motivation, and reduced test anxiety for many learners.

D

On the other hand, nobody said E-training technology would be cheap. E-training service providers, on the average, charge from $10,000 to $60,000 to develop one hour of online instruction. This price varies depending on the complexity of the training topic and the media used. HTML pages are a little cheaper to develop while streaming-video presentations or flash animations cost more. Course content is just the starting place for the cost. A complete e-learning solution also includes the technology platform (the computers, applications and network connections that are used to deliver the courses). This technology platform, known as a learning management system (LMS), can either be installed onsite or outsourced. Add to that cost the necessary investments in network bandwidth to deliver multimedia courses, and you’re left holding one heck of a bill. For the LMS infrastructure and a dozen or so online courses, costs can top $500,000 in the first year. These kinds of costs mean that custom e-training is, for the time being, an option only for large organizations. For those companies that have a large enough staff, the e-training concept pays for itself. Aware of this fact, large companies are investing heavily in online training. Today, over half of the 400-plus courses that Rockwell Collins offers are delivered instantly to its clients in an e-learning format, a change that has reduced its annual training costs by 40%. Many other success stories exist.

E

E-learning isn’t expected to replace the classroom entirely. For one thing, bandwidth limitations are still an issue in presenting multimedia over the Internet. Furthermore, e-training isn’t suited to every mode of instruction or topic. For instance, it’s rather ineffective imparting cultural values or building teams. If your company has a unique corporate culture is would be difficult to convey that to first-time employees through a computer monitor. Group training sessions are more ideal for these purposes. In addition, there is a perceived loss of research time because of the work involved in developing and teaching online classes. Professor Wallin estimated that it required between 500 and 1,000 person-hours, that is, Wallin-hours, to keep the course at the appropriate level of currency and usefulness. (Distance learning instructors often need technical skills, no matter how advanced the courseware system.) That amounts to between a quarter and half of a person-year. Finally, teaching materials require computer literacy and access to equipment. Any e-Learning system involves basic equipment and a minimum level of computer knowledge in order to perform the tasks required by the system. A student that does not possess these skills, or have access to these tools, cannot succeed in an e-Learning program.

F

While few people debate the obvious advantages of e-learning, systematic research is needed to confirm that learners are actually acquiring and using the skills that are being taught online, and that e-learning is the best way to achieve the outcomes in a corporate environment. Nowadays, a go-between style of Blended learning, which refers to a mixing of different learning environments, is gaining popularity. It combines traditional face-to-face classroom methods with more modern computer-mediated activities. According to its proponents, the strategy creates a more integrated approach for both instructors and learners. Formerly, technology-based materials played a supporting role in face-to-face instruction. Through a blended learning approach, technology will be more important.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7236d8fc-3617-5325-b997-79bdc3cb60d3', 'f846bd80-6b21-5bf5-b92d-24df1a6a8566', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below.
Write the correct number,
i-xi
, in boxes 1-6 on your answer sheet.
List of Headings
i
overview of the benefits for application of E-training
ii
IBM’s successful choice of training
iii
Future directions and a new style of teaching
iv
learners’ achievement and advanced teaching materials
v
limitations when E-training compares with traditional class
vi
multimedia over the Internet can be a solution
vii
technology can be a huge financial burden
viii
the distance learners outperformed the traditional university learners worldwide
ix
other advantages besides economic consideration
x
Training offered to help people learn using computers
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
VALUES ('8f85a96e-e68b-5e0d-b44a-b516a14cbad1', '7236d8fc-3617-5325-b997-79bdc3cb60d3', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('061f0ffe-1dd2-5cd6-89b2-f16b918203a8', '7236d8fc-3617-5325-b997-79bdc3cb60d3', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0f41dbb-5574-55ab-8547-b3127c2dc9c1', '7236d8fc-3617-5325-b997-79bdc3cb60d3', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c007acd-78ec-5e86-9a57-a20a470f56f3', '7236d8fc-3617-5325-b997-79bdc3cb60d3', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bd2bd77-f3ee-5d08-a176-b1f5ce10199b', '7236d8fc-3617-5325-b997-79bdc3cb60d3', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6818ddd-877a-5439-a993-074a40ebfe7b', '7236d8fc-3617-5325-b997-79bdc3cb60d3', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ab399ff-37b7-536a-9a9a-50fcd8bfe88f', '7236d8fc-3617-5325-b997-79bdc3cb60d3', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17e4655d-3daf-5b98-ada5-75edafb960c6', '7236d8fc-3617-5325-b997-79bdc3cb60d3', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17e3d023-31dd-54af-a1c3-c8c17d1ea3d8', '7236d8fc-3617-5325-b997-79bdc3cb60d3', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('212df7ee-7558-57f4-bd5b-761390a8ab60', '7236d8fc-3617-5325-b997-79bdc3cb60d3', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e7588ef3-8724-51a4-9fb3-84b1079d6013', 'f846bd80-6b21-5bf5-b92d-24df1a6a8566', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below.
Write the correct number,
i-xi
, in boxes 1-6 on your answer sheet.
List of Headings
i
overview of the benefits for application of E-training
ii
IBM’s successful choice of training
iii
Future directions and a new style of teaching
iv
learners’ achievement and advanced teaching materials
v
limitations when E-training compares with traditional class
vi
multimedia over the Internet can be a solution
vii
technology can be a huge financial burden
viii
the distance learners outperformed the traditional university learners worldwide
ix
other advantages besides economic consideration
x
Training offered to help people learn using computers
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
VALUES ('8d6f2afc-7860-5816-829f-ef148ee2e10a', 'e7588ef3-8724-51a4-9fb3-84b1079d6013', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9208b2d-a2f0-5d19-bcd3-5dcafb7f6c59', 'e7588ef3-8724-51a4-9fb3-84b1079d6013', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7401edaf-f6b9-5ed5-aa6a-aa9032090c61', 'e7588ef3-8724-51a4-9fb3-84b1079d6013', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb832a88-f51c-5ab4-af38-6849fcd122b5', 'e7588ef3-8724-51a4-9fb3-84b1079d6013', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdf544e5-1865-56a3-827a-4a05dd71a075', 'e7588ef3-8724-51a4-9fb3-84b1079d6013', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25da145c-e92f-5dcf-b9b1-539762328142', 'e7588ef3-8724-51a4-9fb3-84b1079d6013', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0b696d0-11f0-5170-b7a7-db39fbe19402', 'e7588ef3-8724-51a4-9fb3-84b1079d6013', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dba6902c-c2ff-50c7-bde8-567655a9ff63', 'e7588ef3-8724-51a4-9fb3-84b1079d6013', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04aa1c02-1732-5306-a5e8-312556f8ac59', 'e7588ef3-8724-51a4-9fb3-84b1079d6013', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('634dc7a6-9031-5aa1-abcc-a1852215a3b4', 'e7588ef3-8724-51a4-9fb3-84b1079d6013', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('43f7e3c7-b317-59c0-8a08-a69f705f98c1', 'f846bd80-6b21-5bf5-b92d-24df1a6a8566', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below.
Write the correct number,
i-xi
, in boxes 1-6 on your answer sheet.
List of Headings
i
overview of the benefits for application of E-training
ii
IBM’s successful choice of training
iii
Future directions and a new style of teaching
iv
learners’ achievement and advanced teaching materials
v
limitations when E-training compares with traditional class
vi
multimedia over the Internet can be a solution
vii
technology can be a huge financial burden
viii
the distance learners outperformed the traditional university learners worldwide
ix
other advantages besides economic consideration
x
Training offered to help people learn using computers
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
VALUES ('1a9eccb1-7a73-5781-826b-3e752e3620f1', '43f7e3c7-b317-59c0-8a08-a69f705f98c1', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dc0e6cc-2538-59a7-88ce-8aa0b887e0e2', '43f7e3c7-b317-59c0-8a08-a69f705f98c1', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('496e8c8b-df40-5862-8e48-6829ca7a8447', '43f7e3c7-b317-59c0-8a08-a69f705f98c1', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a86f60e3-6db3-53ee-9365-c9217386c465', '43f7e3c7-b317-59c0-8a08-a69f705f98c1', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67f7d58a-5bcf-5e7e-9d78-37b6b45fb008', '43f7e3c7-b317-59c0-8a08-a69f705f98c1', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99a8eb74-58c0-59cb-87c3-c25a63b75b15', '43f7e3c7-b317-59c0-8a08-a69f705f98c1', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fc078d1-78b0-52bb-9b23-161e96f98dca', '43f7e3c7-b317-59c0-8a08-a69f705f98c1', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50cf1e57-c00a-5677-b6ca-b38a8ee88064', '43f7e3c7-b317-59c0-8a08-a69f705f98c1', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b2a5e6b-0fe1-50be-bd89-d5fabde771b4', '43f7e3c7-b317-59c0-8a08-a69f705f98c1', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afdd68a9-9cae-5271-ae29-89836b6841b6', '43f7e3c7-b317-59c0-8a08-a69f705f98c1', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('76f10c3e-426c-5abe-bfab-b93d75dbbe0f', 'f846bd80-6b21-5bf5-b92d-24df1a6a8566', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below.
Write the correct number,
i-xi
, in boxes 1-6 on your answer sheet.
List of Headings
i
overview of the benefits for application of E-training
ii
IBM’s successful choice of training
iii
Future directions and a new style of teaching
iv
learners’ achievement and advanced teaching materials
v
limitations when E-training compares with traditional class
vi
multimedia over the Internet can be a solution
vii
technology can be a huge financial burden
viii
the distance learners outperformed the traditional university learners worldwide
ix
other advantages besides economic consideration
x
Training offered to help people learn using computers
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
VALUES ('e26cc785-0288-5a92-8592-e76642178a34', '76f10c3e-426c-5abe-bfab-b93d75dbbe0f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1332f64c-46b8-530f-98ff-d486198765b4', '76f10c3e-426c-5abe-bfab-b93d75dbbe0f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9eed1eed-cdd5-5787-8e61-956a798699a3', '76f10c3e-426c-5abe-bfab-b93d75dbbe0f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8634e91a-22e1-52f3-b863-e5cfdb524663', '76f10c3e-426c-5abe-bfab-b93d75dbbe0f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc822736-0d7d-5b96-89c3-3cf678b5e659', '76f10c3e-426c-5abe-bfab-b93d75dbbe0f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca37369f-21a8-584a-9587-fd1129c2442e', '76f10c3e-426c-5abe-bfab-b93d75dbbe0f', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5823b1ed-32cc-5de0-8adb-2cd0cc3725ea', '76f10c3e-426c-5abe-bfab-b93d75dbbe0f', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eed0c597-6ff4-5383-8ab7-5ebb0f5d6ef5', '76f10c3e-426c-5abe-bfab-b93d75dbbe0f', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6419fc20-4fe4-5be3-9342-9107bb2748b2', '76f10c3e-426c-5abe-bfab-b93d75dbbe0f', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad453018-74af-51f4-a47e-c1a0526bbcd9', '76f10c3e-426c-5abe-bfab-b93d75dbbe0f', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('562a3ad2-e7ff-502b-ab1e-6896597ee5c8', 'f846bd80-6b21-5bf5-b92d-24df1a6a8566', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below.
Write the correct number,
i-xi
, in boxes 1-6 on your answer sheet.
List of Headings
i
overview of the benefits for application of E-training
ii
IBM’s successful choice of training
iii
Future directions and a new style of teaching
iv
learners’ achievement and advanced teaching materials
v
limitations when E-training compares with traditional class
vi
multimedia over the Internet can be a solution
vii
technology can be a huge financial burden
viii
the distance learners outperformed the traditional university learners worldwide
ix
other advantages besides economic consideration
x
Training offered to help people learn using computers
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
VALUES ('3d0cded6-e539-53bf-9c01-9fc85acaeff7', '562a3ad2-e7ff-502b-ab1e-6896597ee5c8', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86892a9b-eb06-5092-b605-9aecb024a0fa', '562a3ad2-e7ff-502b-ab1e-6896597ee5c8', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea89926b-f553-5ee5-98fe-b236c6a86f50', '562a3ad2-e7ff-502b-ab1e-6896597ee5c8', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('feedaf08-418b-5903-97c7-77532c89d4e8', '562a3ad2-e7ff-502b-ab1e-6896597ee5c8', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f492e497-7d85-5e88-a38a-5be8daf56dd1', '562a3ad2-e7ff-502b-ab1e-6896597ee5c8', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ad3074c-c598-5f6a-8708-e8b6ef493518', '562a3ad2-e7ff-502b-ab1e-6896597ee5c8', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99df5ff6-bdaf-5179-a60e-8ff430cdf987', '562a3ad2-e7ff-502b-ab1e-6896597ee5c8', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6944265d-ca19-5ab2-8d21-9af5067406e8', '562a3ad2-e7ff-502b-ab1e-6896597ee5c8', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4207d5aa-a76e-5d38-aaf3-56e11b0f8bdb', '562a3ad2-e7ff-502b-ab1e-6896597ee5c8', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1541d1d-104e-56c8-b281-0a89dd352659', '562a3ad2-e7ff-502b-ab1e-6896597ee5c8', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b9964b3c-2dc3-5aef-ae19-780438afb61d', 'f846bd80-6b21-5bf5-b92d-24df1a6a8566', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading passage has six paragraphs,
A-F
Choose the correct heading for paragraphs
A-F
from the list below.
Write the correct number,
i-xi
, in boxes 1-6 on your answer sheet.
List of Headings
i
overview of the benefits for application of E-training
ii
IBM’s successful choice of training
iii
Future directions and a new style of teaching
iv
learners’ achievement and advanced teaching materials
v
limitations when E-training compares with traditional class
vi
multimedia over the Internet can be a solution
vii
technology can be a huge financial burden
viii
the distance learners outperformed the traditional university learners worldwide
ix
other advantages besides economic consideration
x
Training offered to help people learn using computers
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
VALUES ('c2ffba48-b056-5ab6-b4ab-d85d40dd4243', 'b9964b3c-2dc3-5aef-ae19-780438afb61d', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16078b6e-8df1-518b-867c-3f692752caea', 'b9964b3c-2dc3-5aef-ae19-780438afb61d', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9aa02c85-9506-54e9-afaa-f0fdd95df7a4', 'b9964b3c-2dc3-5aef-ae19-780438afb61d', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e42d63c4-9ed4-592c-abea-9fe3767a2526', 'b9964b3c-2dc3-5aef-ae19-780438afb61d', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b1aa49f-ae6d-5955-ab05-753d6d97ce40', 'b9964b3c-2dc3-5aef-ae19-780438afb61d', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b16701e7-ee8f-5440-b098-82a7cce54146', 'b9964b3c-2dc3-5aef-ae19-780438afb61d', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abef74fa-e26d-522f-bc86-ebc5a93c8264', 'b9964b3c-2dc3-5aef-ae19-780438afb61d', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b4e118b-60b1-5fde-b556-005bcfe85d3d', 'b9964b3c-2dc3-5aef-ae19-780438afb61d', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de17c15c-6683-579d-a0a1-fc6fb842d367', 'b9964b3c-2dc3-5aef-ae19-780438afb61d', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52a661dc-76a0-550c-b510-df9452a8a838', 'b9964b3c-2dc3-5aef-ae19-780438afb61d', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1cba38c9-1d24-55df-9371-50af5bbcc145', 'f846bd80-6b21-5bf5-b92d-24df1a6a8566', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
The reading Passage has six paragraphs
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
, in boxes 7-10 on your answer sheet.
7
Projected Basic Blue in IBM achieved great success.
8
E-learning wins as a priority for many corporations as its flexibility.
9
The combination of traditional and e-training environments may prevail.
10
Example of fast electronic delivery for a company’s products to its customers.

7 ____ Projected Basic Blue in IBM achieved great success.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d491280c-ad34-59ba-af4f-0ed15090bb0a', 'f846bd80-6b21-5bf5-b92d-24df1a6a8566', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
The reading Passage has six paragraphs
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
, in boxes 7-10 on your answer sheet.
7
Projected Basic Blue in IBM achieved great success.
8
E-learning wins as a priority for many corporations as its flexibility.
9
The combination of traditional and e-training environments may prevail.
10
Example of fast electronic delivery for a company’s products to its customers.

8 ____ E-learning wins as a priority for many corporations as its flexibility.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('270eed7f-d4ab-5458-9813-44dc059fe423', 'f846bd80-6b21-5bf5-b92d-24df1a6a8566', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
The reading Passage has six paragraphs
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
, in boxes 7-10 on your answer sheet.
7
Projected Basic Blue in IBM achieved great success.
8
E-learning wins as a priority for many corporations as its flexibility.
9
The combination of traditional and e-training environments may prevail.
10
Example of fast electronic delivery for a company’s products to its customers.

9 ____ The combination of traditional and e-training environments may prevail.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a66447cb-dba6-5803-81b3-20af5746ee6d', 'f846bd80-6b21-5bf5-b92d-24df1a6a8566', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
The reading Passage has six paragraphs
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
, in boxes 7-10 on your answer sheet.
7
Projected Basic Blue in IBM achieved great success.
8
E-learning wins as a priority for many corporations as its flexibility.
9
The combination of traditional and e-training environments may prevail.
10
Example of fast electronic delivery for a company’s products to its customers.

10 ____ Example of fast electronic delivery for a company’s products to its customers.$md$, NULL);

COMMIT;
