BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-a-new-stage-in-the-study-and-teaching-of-history-1532'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-new-stage-in-the-study-and-teaching-of-history-1532';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-new-stage-in-the-study-and-teaching-of-history-1532';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-a-new-stage-in-the-study-and-teaching-of-history-1532';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('882defeb-1acc-56ba-8215-e150ee48484c', 'ielts-reading-a-new-stage-in-the-study-and-teaching-of-history-1532', $t$A new stage in the study and teaching of history$t$, $md$## A new stage in the study and teaching of history

Nguồn:
- Test: https://mini-ielts.com/1532/reading/a-new-stage-in-the-study-and-teaching-of-history
- Solution: https://mini-ielts.com/1532/view-solution/reading/a-new-stage-in-the-study-and-teaching-of-history$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('b1223d52-a88d-599b-8957-45269817c950', '882defeb-1acc-56ba-8215-e150ee48484c', 1, $t$Reading — A new stage in the study and teaching of history$t$, $md$Read the passage and answer questions **1–14**.

### Passage: A new stage in the study and teaching of history

For hundreds of years, historians have relied on written or printed documents to provide the bulk of their source materials, and they have largely communicated with students and the wider public by writing books and journal articles. Today, however, the printed word is being superseded by a diversity of forms of communication, above all moving images on video or film

A The development of this new form of communication is leading to a growing gap between the practice of professional historians based in academia, and the practice of those aiming to popularise the study of history among the general public, and to encourage people to create their own records for the future. On the one hand, there are mainstream academics who continue to use only the written word as they examine more and more fields with an ever- increasing number of sophisticated methodologies. On the other hand, film and video, especially as broadcast on television, are probably the major influence on the public's consciousness of history, as they see film of events of fifty or a hundred years ago, events they had previously only read about.

B In a related development, a great many people now document local and family events in the form of videos; many schools, too, produce video yearbooks. All these visual records may well prove to be invaluable sources of information for future historians. The glaring contradiction is that the two approaches-the academic and what we might term the popular - have intersected very little: with a few notable exceptions, professional historians have tended to avoid involvement in television programmes about history, and have even less impact on what is being captured and preserved on video. And the potential of moving images has wielded negligible influence on the academic study of history.

C This gulf can be seen as resulting from the willingness or otherwise of individual historians to accept the validity of new forms of communication in the study of history. This is not the first time that the question has arisen. The study of history, as conceived of today, began with the transition from oral to literate culture, leading to the earliest written records and the earliest historical studies. The next great shift came with the advent of printing, which transformed everything. Today, as the printed word loses its dominance, historians are faced with a variety of forms of communication, ranging from simple audiotape to the promising complexities of videodiscs linked with computers. As yet, however, the use of moving images to record current events for the benefit of future historians does not even have a commonly agreed name.

D This does not mean that mainstream historians have totally rejected the use of moving images as sources: the majority seem intrigued by the idea, and valuable research has been carried out into the history and analysis of films with a broad circulation, using them as a source of information on the social and intellectual history of the twentieth century. Journals such as American History Review have played a significant role in this field.

E Yet the number of historians using moving images in their research or teaching is very small. The barrier seems to be that the profession is structured around the medium of the written word, and is somewhat insulated in its academic setting. The use of moving images presents a substantial challenge to this setting and its assumptions. As a result, historians have rejected the training, the institutions, the motivations and the professional structures that would be needed in order to use moving images effectively. Above all, they have rejected the necessity to learn complicated new skills.

F So why should historians make this change? clearly, films or videos of events and people can be used as solid evidence of the past, linked to the words of the narrator (whether a television presenter/historian or a university teacher giving a lecture) but carrying information in their own right. Film has reintroduced the oral form as a mode of research and communication for documenting historical events. Now, with moving images, people are reminded that oral communication is not limited to words: it also includes body language, expression and tone, and is embedded in a context. Little of this is evident in a written transcript. A further effect of video and film is that the narrator gives up some control and has less need to give explanations, while the viewer becomes involved in the process of interpreting and understanding history.

G Film or videotape can also aid historians by simplifying the work of the interviewer. Instead of trying to carry on an interview while simultaneously making notes about setting and other unspoken data, this new kind of historian can concentrate on the interview itself, and study the film later. The many benefits of using moving images as historical evidence easily outweigh worries about cost, technical skills, or the effect of a camera on a person telling his or her story. Moving images enhance the quality of historical research, and suggest new directions for historians to explore.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6a082d8d-a889-5c2c-bc1e-e827c1b90293', 'b1223d52-a88d-599b-8957-45269817c950', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-9
Questions 1-9
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter, A-G, in boxes 1-9 on your answer sheet.
NB
You may use any letter more than once.
1
an overview of the range of methods that have been used over time to document history
2
the main reason why many historians are unwilling to use films in their work
3
a reference to some differences between oral and written communication
4
how most citizens today gain an understanding of history
5
how current student events are sometimes captured for future audiences
6
mention of the fact that the advantages of film are greater than the disadvantages
7
the claim that there is no official title for film-based historical work
8
reference to the active role the audience plays when watching films
9
a list of requirements that historians see as obstacles to their use of film to record
history

1 ____ an overview of the range of methods that have been used over time to document history$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('524da470-857a-5a2c-911b-c0384c28934e', '6a082d8d-a889-5c2c-bc1e-e827c1b90293', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcb4f3d3-f315-5734-afe7-b662c1388384', '6a082d8d-a889-5c2c-bc1e-e827c1b90293', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8902d3e1-6055-5efd-b425-846736a3dbe4', '6a082d8d-a889-5c2c-bc1e-e827c1b90293', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ef7a202-5595-5b69-82c0-e2222a2963ff', '6a082d8d-a889-5c2c-bc1e-e827c1b90293', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5dc9fbd4-400f-5960-a654-7f37cdf9c3f0', '6a082d8d-a889-5c2c-bc1e-e827c1b90293', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bc28149-0849-598a-85ac-dd3e0d1f6e49', '6a082d8d-a889-5c2c-bc1e-e827c1b90293', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84eb1f34-d073-568d-b1df-5643d454a248', '6a082d8d-a889-5c2c-bc1e-e827c1b90293', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fb2394ba-07b3-5c7f-a687-14d0a1868930', 'b1223d52-a88d-599b-8957-45269817c950', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-9
Questions 1-9
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter, A-G, in boxes 1-9 on your answer sheet.
NB
You may use any letter more than once.
1
an overview of the range of methods that have been used over time to document history
2
the main reason why many historians are unwilling to use films in their work
3
a reference to some differences between oral and written communication
4
how most citizens today gain an understanding of history
5
how current student events are sometimes captured for future audiences
6
mention of the fact that the advantages of film are greater than the disadvantages
7
the claim that there is no official title for film-based historical work
8
reference to the active role the audience plays when watching films
9
a list of requirements that historians see as obstacles to their use of film to record
history

2 ____ the main reason why many historians are unwilling to use films in their work$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a29b8be-c5e4-56ba-aee1-316205f674a7', 'fb2394ba-07b3-5c7f-a687-14d0a1868930', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('550c9461-524c-5031-baff-34f2015d3449', 'fb2394ba-07b3-5c7f-a687-14d0a1868930', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1607d390-bce6-57e0-b0d3-178deb9492a9', 'fb2394ba-07b3-5c7f-a687-14d0a1868930', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('caff6cbc-5f20-5437-b887-392bc0e61bc0', 'fb2394ba-07b3-5c7f-a687-14d0a1868930', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15537e22-e923-5a02-886b-c3f864f24027', 'fb2394ba-07b3-5c7f-a687-14d0a1868930', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e31fdbe-217f-5d55-a73b-74633a188454', 'fb2394ba-07b3-5c7f-a687-14d0a1868930', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ddc07e9-aae8-5b06-828a-f696744d4d2f', 'fb2394ba-07b3-5c7f-a687-14d0a1868930', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d9675ff5-405e-5168-9920-4e1e56c51e80', 'b1223d52-a88d-599b-8957-45269817c950', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-9
Questions 1-9
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter, A-G, in boxes 1-9 on your answer sheet.
NB
You may use any letter more than once.
1
an overview of the range of methods that have been used over time to document history
2
the main reason why many historians are unwilling to use films in their work
3
a reference to some differences between oral and written communication
4
how most citizens today gain an understanding of history
5
how current student events are sometimes captured for future audiences
6
mention of the fact that the advantages of film are greater than the disadvantages
7
the claim that there is no official title for film-based historical work
8
reference to the active role the audience plays when watching films
9
a list of requirements that historians see as obstacles to their use of film to record
history

3 ____ a reference to some differences between oral and written communication$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7092c62-5d8f-5079-997a-fea9e87789b4', 'd9675ff5-405e-5168-9920-4e1e56c51e80', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d1e9428-d260-5193-a9d5-b9d7057fb016', 'd9675ff5-405e-5168-9920-4e1e56c51e80', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25814b12-5f5c-59e5-af4c-547ff91d053c', 'd9675ff5-405e-5168-9920-4e1e56c51e80', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b203a56f-185a-5d55-b826-7146400f87a6', 'd9675ff5-405e-5168-9920-4e1e56c51e80', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86af51f0-3242-5981-bddf-e7fe52610acc', 'd9675ff5-405e-5168-9920-4e1e56c51e80', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a8a7cd1-bc03-518e-8f04-fcb54a46d121', 'd9675ff5-405e-5168-9920-4e1e56c51e80', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbd14ff0-69c2-5795-9721-7050906aa274', 'd9675ff5-405e-5168-9920-4e1e56c51e80', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6bb8176f-499c-5f21-ab57-9a8da129264d', 'b1223d52-a88d-599b-8957-45269817c950', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-9
Questions 1-9
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter, A-G, in boxes 1-9 on your answer sheet.
NB
You may use any letter more than once.
1
an overview of the range of methods that have been used over time to document history
2
the main reason why many historians are unwilling to use films in their work
3
a reference to some differences between oral and written communication
4
how most citizens today gain an understanding of history
5
how current student events are sometimes captured for future audiences
6
mention of the fact that the advantages of film are greater than the disadvantages
7
the claim that there is no official title for film-based historical work
8
reference to the active role the audience plays when watching films
9
a list of requirements that historians see as obstacles to their use of film to record
history

4 ____ how most citizens today gain an understanding of history$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c6af21a-0b81-5953-b498-3319781a1011', '6bb8176f-499c-5f21-ab57-9a8da129264d', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f10764b-4591-5e1e-94db-5912a162b632', '6bb8176f-499c-5f21-ab57-9a8da129264d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb580475-3867-5d5b-acbd-4b76cf2da692', '6bb8176f-499c-5f21-ab57-9a8da129264d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aaabb0df-3fba-5e6c-a6f0-b2f7de45d1fd', '6bb8176f-499c-5f21-ab57-9a8da129264d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41d61592-2d13-5df2-99b9-f7458c735413', '6bb8176f-499c-5f21-ab57-9a8da129264d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24643390-6627-50ba-a35e-1b1def4986d2', '6bb8176f-499c-5f21-ab57-9a8da129264d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7cbe095-0296-569a-8cf5-3d0fd29338d2', '6bb8176f-499c-5f21-ab57-9a8da129264d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('25847ea2-3827-5bd0-8ddb-28ebd38e52d4', 'b1223d52-a88d-599b-8957-45269817c950', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-9
Questions 1-9
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter, A-G, in boxes 1-9 on your answer sheet.
NB
You may use any letter more than once.
1
an overview of the range of methods that have been used over time to document history
2
the main reason why many historians are unwilling to use films in their work
3
a reference to some differences between oral and written communication
4
how most citizens today gain an understanding of history
5
how current student events are sometimes captured for future audiences
6
mention of the fact that the advantages of film are greater than the disadvantages
7
the claim that there is no official title for film-based historical work
8
reference to the active role the audience plays when watching films
9
a list of requirements that historians see as obstacles to their use of film to record
history

5 ____ how current student events are sometimes captured for future audiences$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('549b8fe9-0d12-5464-9bba-ebc0885f6d55', '25847ea2-3827-5bd0-8ddb-28ebd38e52d4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1adf3f1-2c15-5c91-9ac4-81b03dc29508', '25847ea2-3827-5bd0-8ddb-28ebd38e52d4', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e0060e4-821a-5a9f-847f-f07b43fba510', '25847ea2-3827-5bd0-8ddb-28ebd38e52d4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('688848c3-763b-570b-9cac-72c60def741e', '25847ea2-3827-5bd0-8ddb-28ebd38e52d4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a274d46-8318-57d0-b953-2db4eba40e5a', '25847ea2-3827-5bd0-8ddb-28ebd38e52d4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6cbe14d-d9b3-59a4-a931-a1503bb859a8', '25847ea2-3827-5bd0-8ddb-28ebd38e52d4', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dea4e8f9-9eb8-552a-a860-a06e0b83f181', '25847ea2-3827-5bd0-8ddb-28ebd38e52d4', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7dd98987-22b9-5e61-99c8-8eb115fc0a35', 'b1223d52-a88d-599b-8957-45269817c950', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-9
Questions 1-9
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter, A-G, in boxes 1-9 on your answer sheet.
NB
You may use any letter more than once.
1
an overview of the range of methods that have been used over time to document history
2
the main reason why many historians are unwilling to use films in their work
3
a reference to some differences between oral and written communication
4
how most citizens today gain an understanding of history
5
how current student events are sometimes captured for future audiences
6
mention of the fact that the advantages of film are greater than the disadvantages
7
the claim that there is no official title for film-based historical work
8
reference to the active role the audience plays when watching films
9
a list of requirements that historians see as obstacles to their use of film to record
history

6 ____ mention of the fact that the advantages of film are greater than the disadvantages$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e80051f5-2345-5ac8-88df-e92bdcecaa94', '7dd98987-22b9-5e61-99c8-8eb115fc0a35', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bc2735a-3753-51c3-ac32-04d863d2386d', '7dd98987-22b9-5e61-99c8-8eb115fc0a35', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f7a5c58-c0be-53b8-9f2a-125112ea1d9e', '7dd98987-22b9-5e61-99c8-8eb115fc0a35', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e955ab5-4d21-59d0-8295-5e66cbd95ef2', '7dd98987-22b9-5e61-99c8-8eb115fc0a35', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d121cea3-0155-50fb-a11a-bb6b9e25c2e4', '7dd98987-22b9-5e61-99c8-8eb115fc0a35', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75601a1e-28c2-5f1f-9587-f356a4943a1f', '7dd98987-22b9-5e61-99c8-8eb115fc0a35', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad230d2f-2136-5538-9064-8ce9304b6989', '7dd98987-22b9-5e61-99c8-8eb115fc0a35', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fabcc623-69ab-5395-afb5-523cd2f81de4', 'b1223d52-a88d-599b-8957-45269817c950', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-9
Questions 1-9
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter, A-G, in boxes 1-9 on your answer sheet.
NB
You may use any letter more than once.
1
an overview of the range of methods that have been used over time to document history
2
the main reason why many historians are unwilling to use films in their work
3
a reference to some differences between oral and written communication
4
how most citizens today gain an understanding of history
5
how current student events are sometimes captured for future audiences
6
mention of the fact that the advantages of film are greater than the disadvantages
7
the claim that there is no official title for film-based historical work
8
reference to the active role the audience plays when watching films
9
a list of requirements that historians see as obstacles to their use of film to record
history

7 ____ the claim that there is no official title for film-based historical work$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('020278b2-e5ff-5487-aa6e-aecebec1eebd', 'fabcc623-69ab-5395-afb5-523cd2f81de4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4e1cfec-12e9-5ff9-8ef0-fdcffd1b2c5d', 'fabcc623-69ab-5395-afb5-523cd2f81de4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cce73922-f91c-553a-b8c4-0d95430425e7', 'fabcc623-69ab-5395-afb5-523cd2f81de4', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e279baaa-79ef-5769-808b-5de07daa5e81', 'fabcc623-69ab-5395-afb5-523cd2f81de4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d7e7bbc-bacd-5e8e-a1c2-193a8b63de4c', 'fabcc623-69ab-5395-afb5-523cd2f81de4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04235200-ce9a-5ae1-9dfb-6f2b64d8d65c', 'fabcc623-69ab-5395-afb5-523cd2f81de4', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0ac7530-4f5b-5e42-baa0-5c8db69d2dc6', 'fabcc623-69ab-5395-afb5-523cd2f81de4', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b9a9f6b4-2661-5dc3-bf1b-e99b74faa641', 'b1223d52-a88d-599b-8957-45269817c950', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 1-9
Questions 1-9
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter, A-G, in boxes 1-9 on your answer sheet.
NB
You may use any letter more than once.
1
an overview of the range of methods that have been used over time to document history
2
the main reason why many historians are unwilling to use films in their work
3
a reference to some differences between oral and written communication
4
how most citizens today gain an understanding of history
5
how current student events are sometimes captured for future audiences
6
mention of the fact that the advantages of film are greater than the disadvantages
7
the claim that there is no official title for film-based historical work
8
reference to the active role the audience plays when watching films
9
a list of requirements that historians see as obstacles to their use of film to record
history

8 ____ reference to the active role the audience plays when watching films$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de0330cc-d6c0-59f7-aad9-7981ff70875e', 'b9a9f6b4-2661-5dc3-bf1b-e99b74faa641', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1132cce3-b1bd-5601-acce-7d967e993855', 'b9a9f6b4-2661-5dc3-bf1b-e99b74faa641', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af8d6d52-bc3e-5571-aa66-3e3dd6a60e0c', 'b9a9f6b4-2661-5dc3-bf1b-e99b74faa641', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f849ab9d-ee45-5c17-8533-f481509b7689', 'b9a9f6b4-2661-5dc3-bf1b-e99b74faa641', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15892a49-6a22-5fb7-b860-03feb97256ee', 'b9a9f6b4-2661-5dc3-bf1b-e99b74faa641', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a53e54f2-5ccc-5098-a20c-98e2d7faf41e', 'b9a9f6b4-2661-5dc3-bf1b-e99b74faa641', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da495093-2d34-5910-a5f2-f4d9379ccd42', 'b9a9f6b4-2661-5dc3-bf1b-e99b74faa641', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d5032a50-537f-5405-bc28-5f5f69cfb72c', 'b1223d52-a88d-599b-8957-45269817c950', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 1-9
Questions 1-9
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter, A-G, in boxes 1-9 on your answer sheet.
NB
You may use any letter more than once.
1
an overview of the range of methods that have been used over time to document history
2
the main reason why many historians are unwilling to use films in their work
3
a reference to some differences between oral and written communication
4
how most citizens today gain an understanding of history
5
how current student events are sometimes captured for future audiences
6
mention of the fact that the advantages of film are greater than the disadvantages
7
the claim that there is no official title for film-based historical work
8
reference to the active role the audience plays when watching films
9
a list of requirements that historians see as obstacles to their use of film to record
history

9 ____ a list of requirements that historians see as obstacles to their use of film to record history$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('629a2862-3074-5696-b370-411c0aaa22ae', 'd5032a50-537f-5405-bc28-5f5f69cfb72c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88b26235-025d-5625-ac3b-2a4f5adfbe24', 'd5032a50-537f-5405-bc28-5f5f69cfb72c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d672dcd7-c95e-5786-abd5-5f87eb99042f', 'd5032a50-537f-5405-bc28-5f5f69cfb72c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('277156e7-e51d-5dee-a4ef-d0d904924901', 'd5032a50-537f-5405-bc28-5f5f69cfb72c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a001324-8d23-545b-b994-9d155697a2d7', 'd5032a50-537f-5405-bc28-5f5f69cfb72c', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12baac19-32bc-5f28-8642-7b352d19849d', 'd5032a50-537f-5405-bc28-5f5f69cfb72c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8331ffd-c839-5fa3-8052-cc7a8277b632', 'd5032a50-537f-5405-bc28-5f5f69cfb72c', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('25349061-1576-51aa-9c4b-567c1d6190a6', 'b1223d52-a88d-599b-8957-45269817c950', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 10-14 on your answer sheet, write
YES – if the statement reflects the claims of the writer
NO – if the statement contradicts the claims of the writer
NOT GIVEN – if it is impossible to say what the writer thinks about this
10
The needs of students in school have led to improvements in the teaching of history.
11
Academic and popular historians have different attitudes towards the value of innovations in communication.
12
It is common for historians to play a major role in creating historical documentaries for television.
13
Articles in American History Review have explored aspects of modern history through popular films.
14
Developments in technology are influencing a range of academic subjects.

10 ____ The needs of students in school have led to improvements in the teaching of history.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f53941dc-b86c-566a-a11c-b67c66911685', '25349061-1576-51aa-9c4b-567c1d6190a6', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23c18d60-b7a2-52c8-bc34-d2053636489c', '25349061-1576-51aa-9c4b-567c1d6190a6', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad6094c8-9e8d-56d6-92c3-45f4cc1badd6', '25349061-1576-51aa-9c4b-567c1d6190a6', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('11fa9f84-5411-54a1-b66a-6990525cd24f', 'b1223d52-a88d-599b-8957-45269817c950', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 10-14 on your answer sheet, write
YES – if the statement reflects the claims of the writer
NO – if the statement contradicts the claims of the writer
NOT GIVEN – if it is impossible to say what the writer thinks about this
10
The needs of students in school have led to improvements in the teaching of history.
11
Academic and popular historians have different attitudes towards the value of innovations in communication.
12
It is common for historians to play a major role in creating historical documentaries for television.
13
Articles in American History Review have explored aspects of modern history through popular films.
14
Developments in technology are influencing a range of academic subjects.

11 ____ Academic and popular historians have different attitudes towards the value of innovations in communication.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d94db0cd-f602-5545-85d2-b05c2653be49', '11fa9f84-5411-54a1-b66a-6990525cd24f', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fc568e2-ebb0-5a47-8a4e-e163d2ab1504', '11fa9f84-5411-54a1-b66a-6990525cd24f', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd290ab2-999c-5c89-b5f7-aa11f3c0b5f8', '11fa9f84-5411-54a1-b66a-6990525cd24f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae45990e-3574-5f92-ad1d-ae6b078229af', 'b1223d52-a88d-599b-8957-45269817c950', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 10-14 on your answer sheet, write
YES – if the statement reflects the claims of the writer
NO – if the statement contradicts the claims of the writer
NOT GIVEN – if it is impossible to say what the writer thinks about this
10
The needs of students in school have led to improvements in the teaching of history.
11
Academic and popular historians have different attitudes towards the value of innovations in communication.
12
It is common for historians to play a major role in creating historical documentaries for television.
13
Articles in American History Review have explored aspects of modern history through popular films.
14
Developments in technology are influencing a range of academic subjects.

12 ____ It is common for historians to play a major role in creating historical documentaries for television.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4bce634-7be7-5c68-b646-9ca54bb0cd31', 'ae45990e-3574-5f92-ad1d-ae6b078229af', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f003d36-95e2-58ad-85ec-3289710b165e', 'ae45990e-3574-5f92-ad1d-ae6b078229af', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab2768e2-eebb-52f3-af62-b517e0eac312', 'ae45990e-3574-5f92-ad1d-ae6b078229af', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d488ed20-ba5b-5163-b4bc-74b19aa0ca1e', 'b1223d52-a88d-599b-8957-45269817c950', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 10-14 on your answer sheet, write
YES – if the statement reflects the claims of the writer
NO – if the statement contradicts the claims of the writer
NOT GIVEN – if it is impossible to say what the writer thinks about this
10
The needs of students in school have led to improvements in the teaching of history.
11
Academic and popular historians have different attitudes towards the value of innovations in communication.
12
It is common for historians to play a major role in creating historical documentaries for television.
13
Articles in American History Review have explored aspects of modern history through popular films.
14
Developments in technology are influencing a range of academic subjects.

13 ____ Articles in American History Review have explored aspects of modern history through popular films.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bf968df-12a5-5075-9308-3bac85b252e2', 'd488ed20-ba5b-5163-b4bc-74b19aa0ca1e', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4108238-051e-56d0-b399-441716bfcd69', 'd488ed20-ba5b-5163-b4bc-74b19aa0ca1e', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6674c41-522f-5a7b-a290-ae05caf4bf7c', 'd488ed20-ba5b-5163-b4bc-74b19aa0ca1e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ca854e4e-2ebb-5a9b-97e0-89a0727f6955', 'b1223d52-a88d-599b-8957-45269817c950', 14, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 10-14 on your answer sheet, write
YES – if the statement reflects the claims of the writer
NO – if the statement contradicts the claims of the writer
NOT GIVEN – if it is impossible to say what the writer thinks about this
10
The needs of students in school have led to improvements in the teaching of history.
11
Academic and popular historians have different attitudes towards the value of innovations in communication.
12
It is common for historians to play a major role in creating historical documentaries for television.
13
Articles in American History Review have explored aspects of modern history through popular films.
14
Developments in technology are influencing a range of academic subjects.

14 ____ Developments in technology are influencing a range of academic subjects.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a499f9d0-15ee-5f26-bc24-c96519bb6959', 'ca854e4e-2ebb-5a9b-97e0-89a0727f6955', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e892b0f3-2f36-5d46-91c5-af9682fdca98', 'ca854e4e-2ebb-5a9b-97e0-89a0727f6955', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aaeb545f-f6bd-56c4-8781-36d0e97c16e7', 'ca854e4e-2ebb-5a9b-97e0-89a0727f6955', 3, $md$NOT GIVEN$md$, true);

COMMIT;
