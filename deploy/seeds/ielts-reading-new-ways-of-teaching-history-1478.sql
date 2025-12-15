BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-new-ways-of-teaching-history-1478'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-new-ways-of-teaching-history-1478';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-new-ways-of-teaching-history-1478';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-new-ways-of-teaching-history-1478';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('dbcaacd0-6c92-52b6-ad37-86d0003bfca8', 'ielts-reading-new-ways-of-teaching-history-1478', $t$New ways of teaching history$t$, $md$## New ways of teaching history

Nguồn:
- Test: https://mini-ielts.com/1478/reading/new-ways-of-teaching-history
- Solution: https://mini-ielts.com/1478/view-solution/reading/new-ways-of-teaching-history$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f4dadd85-ff09-5426-825a-c810880a1ea7', 'dbcaacd0-6c92-52b6-ad37-86d0003bfca8', 1, $t$Reading — New ways of teaching history$t$, $md$Read the passage and answer questions **1–13**.

### Passage: New ways of teaching history

{A} In technology and the media-driven world, it’s becoming increasingly difficult to get our students’ attention and keep them absorbed in classroom discussions. This generation, in particular, has brought a unique set of challenges to the educational table. Whereas youth are easily enraptured by high-definition television, computers, Pods, video games , and cell phones, they are less than enthralled by what to them are obsolete textbooks and boring classroom lectures. The question of how to teach history in a digital age is often contentious. On the one side, the old guard thinks the professional standards history is in mortal danger from flash-in-the-pan challenges by the digital that is all show and no substance. On the other side, the self-styled “disruptors” offer overblown rhetoric about how digital technology has changed everything while the moribund profession obstructs all progress in the name of outdated ideals. At least, that’s a parody (maybe not much of one) of how the debate proceeds. Both supporters and opponents of the digital share more disciplinary common ground than either admits.

{B} When provided with merely a textbook as a supplemental learning tool, test results have revealed that most students fail to pinpoint the significance of historical events and individuals. Fewer still are able to cite and substantiate primary historical sources. What does this say about the way our educators are presenting information? The quotation comes from a report of a 1917 test of 668 Texas students. Less than 10 per cent of school-age children attended high school in 1917; today, enrollments are nearly universal. The whole world has turned on its head during the last century but one thing has stayed the same: Young people remain woefully ignorant about history reflected from their history tests. Guess what? Historians are ignorant too, especially when we equate historical knowledge with the “Jeopardy” Daily Double. In a test, those specializing in American history did just fine. But those with specialities in medieval, European and African history failed miserably when confronted by items about Fort Ticonderoga, the Olive Branch Petition, or the Quebec Act–all taken from a typical textbook. According to the testers, the results from the recent National Assessment in History, like scores from earlier tests, show that young people are “abysmally ignorant” of their own history. Invoking the tragedy of last September, historian Diane Ravitch hitched her worries about our future to the idea that our nation’s strength is endangered by youth who do poorly on such tests. But if she were correct, we would have gone down the tubes in 1917!

{C} There is a huge difference between saying “Kids don’t know the history we want them to know” and saying “Kids don’t know history at all.” Historical knowledge burrows itself into our cultural pores even if young people can’t marshal it when faced with a multiple-choice test. If we weren’t such hypocrites (or maybe if we were better historians) we’d have to admit that today’s students follow in our own footsteps. For too long we’ve fantasized that by rewriting textbooks we could change how history is learned. The problem, however, is not the content of textbooks but the very idea of them. No human mind could retain the information crammed into these books in 1917, and it can do no better now. If we have learned anything from history that can be applied to every time period, it is that the only constant changes. The teaching of history, or any subject for that matter, is no exception. The question is no longer whether to bring new technologies into everyday education; now, the question is which technologies are most suitable for the range of topics covered in junior high and high school history classrooms. Fortunately, technology has provided us with opportunities to present our Civil War lesson plans or our American Revolution lesson plans in a variety of new ways.

{D} Teachers can easily target and engage the learners of this generation by effectively combining the study of history with innovative multimedia. PowerPoint and presentations, in particular, can expand the scope of traditional classroom discussion by helping teachers to explain abstract concepts while accommodating students’ unique learning styles. PowerPoint study units that have been pre-made for history classrooms include all manner of photos, prints, maps, audio clips, video clips and primary sources which help to make learning interactive and stimulating. Presenting lessons in these enticing formats helps technology-driven students retain the historical information they’ll need to know for standard exams.

{E} Whether you’re covering Revolutionary War lesson plans or World War II lesson plans, PowerPoint study units are available in formats to suit the needs of your classroom. Multimedia teaching instruments like PowerPoint software are getting positive results the world over, framing conventional lectures with captivating written, auditory and visual content that helps students recall names, dates and causal relationships within a historical context.

{F} History continues to show us that new times bring new realities. Education is no exception to the rule. The question is not whether to bring technology into the educational environment. Rather, the question is which technologies are suitable for U.S. and world history subjects, from Civil War lesson plans to World War II lesson plans. Whether you’re covering your American Revolution lesson plans or your Cold War lesson plans, PowerPoint presentations are available in pre-packaged formats to suit your classroom’s needs.

{G} Meanwhile, some academic historians hold a different view on the use of technology in teaching history. One reason they hold is that not all facts can be recorded by film or videos and literature is relatively feasible in this case. Another challenge they have to be faced with is the painful process of learning a new technology like the making of PowerPoint and the editing of audio and video clips which is also reasonable especially to some elderly historians.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aa9e72c3-dbf0-594b-963f-579164f527ec', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading this passage has eight paragraphs, A-G
Choosing the correct heading for paragraphs A-G from the list of heading below
Write the appropriate number, i -x, in boxes 1-7 on your answer sheet.
List of Headings
(i)
unavoidable changing facts to be considered when picking up technology means
(ii)
. A debatable place where the new technologies stand in for history teaching
(iii)
Hard to attract students in traditional ways of teaching history
(iv)
Display of the use of emerging multimedia as teaching tools
(V)
Both students and professionals as candidates did not produce decent results
(vi)
A good concrete example illustrated to show how multimedia animates the history class
(vii)
The comparisons of the new technologies applied in history class
(viii)
Enormous breakthroughs in new technologies
(ix)
Resistance of using new technologies from certain historian
(X)
Decisions needed on which technique to be used for history teaching instead of improvement in the textbooks
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

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bb81b8e-2038-5c47-ac86-cafe80c12dc9', 'aa9e72c3-dbf0-594b-963f-579164f527ec', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f890363e-fb92-54e5-9692-0fc65d1504f8', 'aa9e72c3-dbf0-594b-963f-579164f527ec', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc87bc33-77d1-59b6-8d6c-c73f39307731', 'aa9e72c3-dbf0-594b-963f-579164f527ec', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7168468a-69d6-577f-9fda-18ff16ae75a1', 'aa9e72c3-dbf0-594b-963f-579164f527ec', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7eff87c0-10b3-50ad-945b-43db63aa3615', 'aa9e72c3-dbf0-594b-963f-579164f527ec', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08aefa39-e7f8-54fa-853c-c8e2f72b9ba1', 'aa9e72c3-dbf0-594b-963f-579164f527ec', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49c021d7-8b1b-51bf-afdf-ad4e6f0dae57', 'aa9e72c3-dbf0-594b-963f-579164f527ec', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2830aac-84af-51f7-a87a-e2bf881ed675', 'aa9e72c3-dbf0-594b-963f-579164f527ec', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa9c526f-07a5-5d65-8188-b43ab0a8e872', 'aa9e72c3-dbf0-594b-963f-579164f527ec', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4830075e-20d4-5560-86d1-03cf366a2bd5', 'aa9e72c3-dbf0-594b-963f-579164f527ec', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('652381bd-ebde-534d-aab9-d9c9af18c770', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading this passage has eight paragraphs, A-G
Choosing the correct heading for paragraphs A-G from the list of heading below
Write the appropriate number, i -x, in boxes 1-7 on your answer sheet.
List of Headings
(i)
unavoidable changing facts to be considered when picking up technology means
(ii)
. A debatable place where the new technologies stand in for history teaching
(iii)
Hard to attract students in traditional ways of teaching history
(iv)
Display of the use of emerging multimedia as teaching tools
(V)
Both students and professionals as candidates did not produce decent results
(vi)
A good concrete example illustrated to show how multimedia animates the history class
(vii)
The comparisons of the new technologies applied in history class
(viii)
Enormous breakthroughs in new technologies
(ix)
Resistance of using new technologies from certain historian
(X)
Decisions needed on which technique to be used for history teaching instead of improvement in the textbooks
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
VALUES ('97108d9c-0d9c-5a36-95d0-79fb09dd8bd5', '652381bd-ebde-534d-aab9-d9c9af18c770', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2370b3b-8e5c-5b5e-8531-896bbe04e682', '652381bd-ebde-534d-aab9-d9c9af18c770', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba435080-14a4-5d55-b8c2-49e4f04f4f4f', '652381bd-ebde-534d-aab9-d9c9af18c770', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68c6ea5a-4ab8-5b7d-8dae-00b5f5c5dbc9', '652381bd-ebde-534d-aab9-d9c9af18c770', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd40ed38-e920-5ee5-a038-ed112914e8c1', '652381bd-ebde-534d-aab9-d9c9af18c770', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('790463a3-f57d-5db4-ab54-6169a3cb3ce8', '652381bd-ebde-534d-aab9-d9c9af18c770', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6dcaeb9d-7586-5008-8dd0-210066af72de', '652381bd-ebde-534d-aab9-d9c9af18c770', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d359bc7-9f46-5681-9b48-186ab0e11312', '652381bd-ebde-534d-aab9-d9c9af18c770', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('806787e1-a7ef-529b-b2a1-2adf5323d855', '652381bd-ebde-534d-aab9-d9c9af18c770', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04034958-c97a-5182-be59-b7b0a213e7e8', '652381bd-ebde-534d-aab9-d9c9af18c770', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8af4e07c-6791-5323-9f8b-867f53985cd5', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading this passage has eight paragraphs, A-G
Choosing the correct heading for paragraphs A-G from the list of heading below
Write the appropriate number, i -x, in boxes 1-7 on your answer sheet.
List of Headings
(i)
unavoidable changing facts to be considered when picking up technology means
(ii)
. A debatable place where the new technologies stand in for history teaching
(iii)
Hard to attract students in traditional ways of teaching history
(iv)
Display of the use of emerging multimedia as teaching tools
(V)
Both students and professionals as candidates did not produce decent results
(vi)
A good concrete example illustrated to show how multimedia animates the history class
(vii)
The comparisons of the new technologies applied in history class
(viii)
Enormous breakthroughs in new technologies
(ix)
Resistance of using new technologies from certain historian
(X)
Decisions needed on which technique to be used for history teaching instead of improvement in the textbooks
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
VALUES ('d17d5d2b-b4f9-56e6-9213-dcf3736abe3c', '8af4e07c-6791-5323-9f8b-867f53985cd5', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76536204-e5f7-50ca-a607-58656327c726', '8af4e07c-6791-5323-9f8b-867f53985cd5', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02342c2c-ba30-5df3-bd58-8e2389e5260c', '8af4e07c-6791-5323-9f8b-867f53985cd5', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e0f6b5a-4d9a-5c1c-ba1e-01b709f10fcf', '8af4e07c-6791-5323-9f8b-867f53985cd5', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40bd4bcf-0f00-5bd3-9b62-2dff841cc580', '8af4e07c-6791-5323-9f8b-867f53985cd5', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5654389c-ac31-5006-ab6a-6d84a719249c', '8af4e07c-6791-5323-9f8b-867f53985cd5', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5bf94d3-3260-597d-98a7-af4478471fff', '8af4e07c-6791-5323-9f8b-867f53985cd5', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ae42d9f-a45b-5c2a-9fb7-3d8464de1cf9', '8af4e07c-6791-5323-9f8b-867f53985cd5', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0f2704c-78be-5329-b0a4-5c3029b588b5', '8af4e07c-6791-5323-9f8b-867f53985cd5', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c5f5be9-4427-5f93-95b0-34098de735a6', '8af4e07c-6791-5323-9f8b-867f53985cd5', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('93f5308e-1f7d-5dfa-8a5d-a00cbe110241', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading this passage has eight paragraphs, A-G
Choosing the correct heading for paragraphs A-G from the list of heading below
Write the appropriate number, i -x, in boxes 1-7 on your answer sheet.
List of Headings
(i)
unavoidable changing facts to be considered when picking up technology means
(ii)
. A debatable place where the new technologies stand in for history teaching
(iii)
Hard to attract students in traditional ways of teaching history
(iv)
Display of the use of emerging multimedia as teaching tools
(V)
Both students and professionals as candidates did not produce decent results
(vi)
A good concrete example illustrated to show how multimedia animates the history class
(vii)
The comparisons of the new technologies applied in history class
(viii)
Enormous breakthroughs in new technologies
(ix)
Resistance of using new technologies from certain historian
(X)
Decisions needed on which technique to be used for history teaching instead of improvement in the textbooks
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
VALUES ('9d143ab0-9ae9-5eb1-881b-4fd8fc544803', '93f5308e-1f7d-5dfa-8a5d-a00cbe110241', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdd6b6d0-d9eb-50b3-9917-de1ba2625050', '93f5308e-1f7d-5dfa-8a5d-a00cbe110241', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('461b5cad-062f-53d8-a117-ff6e1f5f6d54', '93f5308e-1f7d-5dfa-8a5d-a00cbe110241', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('408882e2-4a8a-504a-b1c4-e2bc21a2766e', '93f5308e-1f7d-5dfa-8a5d-a00cbe110241', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd93b3bf-3b9b-55c6-a941-a3f7b0107ea8', '93f5308e-1f7d-5dfa-8a5d-a00cbe110241', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd8d3b11-3ff2-5fbc-961a-5ae0f046bd42', '93f5308e-1f7d-5dfa-8a5d-a00cbe110241', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b66f162-a885-5198-ba98-53cd81439ed4', '93f5308e-1f7d-5dfa-8a5d-a00cbe110241', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('859d2690-f621-5073-a54a-065a1ea00cd7', '93f5308e-1f7d-5dfa-8a5d-a00cbe110241', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad309ebd-12eb-5fd2-b00c-f13cc2b63c22', '93f5308e-1f7d-5dfa-8a5d-a00cbe110241', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d3954f9-3c73-5edd-b7fa-7b400dc6858a', '93f5308e-1f7d-5dfa-8a5d-a00cbe110241', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8504f6c3-78b5-5569-bdfb-65eab4febb37', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading this passage has eight paragraphs, A-G
Choosing the correct heading for paragraphs A-G from the list of heading below
Write the appropriate number, i -x, in boxes 1-7 on your answer sheet.
List of Headings
(i)
unavoidable changing facts to be considered when picking up technology means
(ii)
. A debatable place where the new technologies stand in for history teaching
(iii)
Hard to attract students in traditional ways of teaching history
(iv)
Display of the use of emerging multimedia as teaching tools
(V)
Both students and professionals as candidates did not produce decent results
(vi)
A good concrete example illustrated to show how multimedia animates the history class
(vii)
The comparisons of the new technologies applied in history class
(viii)
Enormous breakthroughs in new technologies
(ix)
Resistance of using new technologies from certain historian
(X)
Decisions needed on which technique to be used for history teaching instead of improvement in the textbooks
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
VALUES ('16459827-c4ba-53d3-b05c-034d0653dfbb', '8504f6c3-78b5-5569-bdfb-65eab4febb37', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0db82dc-00fd-55fb-8d60-ed632ed6bed8', '8504f6c3-78b5-5569-bdfb-65eab4febb37', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('112904e0-0c95-54d7-b703-388c7cb182c3', '8504f6c3-78b5-5569-bdfb-65eab4febb37', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8a3b3d3-236d-5105-a5d6-ae1f60fa581a', '8504f6c3-78b5-5569-bdfb-65eab4febb37', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f12df7f-c18e-5761-9344-8cab29db896b', '8504f6c3-78b5-5569-bdfb-65eab4febb37', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('027569ba-3b30-571e-8125-6f1605529a2b', '8504f6c3-78b5-5569-bdfb-65eab4febb37', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('377105a6-8efc-5776-9eac-243d62231feb', '8504f6c3-78b5-5569-bdfb-65eab4febb37', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d69296e-9a7b-5267-98f4-ecf0e5a64c52', '8504f6c3-78b5-5569-bdfb-65eab4febb37', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ee808ba-86dc-5b28-a61b-e235e4bcf745', '8504f6c3-78b5-5569-bdfb-65eab4febb37', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('873607fe-590a-56d0-b49f-08f238a3f614', '8504f6c3-78b5-5569-bdfb-65eab4febb37', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('768e71c3-0297-5d2b-98da-519475946cc3', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading this passage has eight paragraphs, A-G
Choosing the correct heading for paragraphs A-G from the list of heading below
Write the appropriate number, i -x, in boxes 1-7 on your answer sheet.
List of Headings
(i)
unavoidable changing facts to be considered when picking up technology means
(ii)
. A debatable place where the new technologies stand in for history teaching
(iii)
Hard to attract students in traditional ways of teaching history
(iv)
Display of the use of emerging multimedia as teaching tools
(V)
Both students and professionals as candidates did not produce decent results
(vi)
A good concrete example illustrated to show how multimedia animates the history class
(vii)
The comparisons of the new technologies applied in history class
(viii)
Enormous breakthroughs in new technologies
(ix)
Resistance of using new technologies from certain historian
(X)
Decisions needed on which technique to be used for history teaching instead of improvement in the textbooks
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
VALUES ('6e2c9bf0-e9c3-5daa-85d4-df2744149dd5', '768e71c3-0297-5d2b-98da-519475946cc3', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f4e3299-60b3-5668-95d6-3c1851469bc6', '768e71c3-0297-5d2b-98da-519475946cc3', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdffa6d6-c869-57bf-ae4c-0a79e42b1e08', '768e71c3-0297-5d2b-98da-519475946cc3', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5408ef2-f9eb-5603-b9e8-4d02d3247069', '768e71c3-0297-5d2b-98da-519475946cc3', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c18e4011-c787-554c-a058-472bef0f02d4', '768e71c3-0297-5d2b-98da-519475946cc3', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33dbe6e7-51f9-5c6b-8b9b-60e1b3f67669', '768e71c3-0297-5d2b-98da-519475946cc3', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eabd7231-5f9a-57cb-b232-8ae1669aa951', '768e71c3-0297-5d2b-98da-519475946cc3', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7baa2219-49e5-535c-a846-f4af4732c761', '768e71c3-0297-5d2b-98da-519475946cc3', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7259ed97-4140-5ea5-84d5-2f76dd8d35a9', '768e71c3-0297-5d2b-98da-519475946cc3', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba48d958-ac01-50dc-8f23-fe4730854fec', '768e71c3-0297-5d2b-98da-519475946cc3', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1699682f-57a3-585d-a252-66a36692cade', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading this passage has eight paragraphs, A-G
Choosing the correct heading for paragraphs A-G from the list of heading below
Write the appropriate number, i -x, in boxes 1-7 on your answer sheet.
List of Headings
(i)
unavoidable changing facts to be considered when picking up technology means
(ii)
. A debatable place where the new technologies stand in for history teaching
(iii)
Hard to attract students in traditional ways of teaching history
(iv)
Display of the use of emerging multimedia as teaching tools
(V)
Both students and professionals as candidates did not produce decent results
(vi)
A good concrete example illustrated to show how multimedia animates the history class
(vii)
The comparisons of the new technologies applied in history class
(viii)
Enormous breakthroughs in new technologies
(ix)
Resistance of using new technologies from certain historian
(X)
Decisions needed on which technique to be used for history teaching instead of improvement in the textbooks
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
VALUES ('73769eaa-e6a5-5929-9ac0-c17ccbaee218', '1699682f-57a3-585d-a252-66a36692cade', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dca86e52-75d6-543f-b671-ca9d0cca2fdc', '1699682f-57a3-585d-a252-66a36692cade', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cd40836-791e-5e90-9115-1ba6810296f6', '1699682f-57a3-585d-a252-66a36692cade', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62f627db-3586-583b-a27f-94267f624f22', '1699682f-57a3-585d-a252-66a36692cade', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30566564-43b4-593c-a4fa-7db97ccffd05', '1699682f-57a3-585d-a252-66a36692cade', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a15701b7-b2ca-50ec-ac6f-53660d898042', '1699682f-57a3-585d-a252-66a36692cade', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce38504d-bda7-500e-a1f2-45873472c71e', '1699682f-57a3-585d-a252-66a36692cade', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77525a39-7a4d-54f7-92c6-f346cec507cc', '1699682f-57a3-585d-a252-66a36692cade', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7381cfc3-a1ad-503a-a928-2853391b780f', '1699682f-57a3-585d-a252-66a36692cade', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7be6b1a-6ebf-5c9a-b884-49adbf92bdda', '1699682f-57a3-585d-a252-66a36692cade', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d499d0ba-87ae-59e0-8f48-3de82cbc3eba', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-10
Questions 8-10
Do the following statements agree with the information given in Reading Passage? In boxes 8-10 on your answer sheet, write
YES
if the statement agrees with the writer
NO
if the statement does not agree with the writer
NOT GIVEN
if there is no information about this in the passage
8
Modern people are better at memorizing historical information compared with their ancestors.
9
New technologies applied in history teaching are more vivid for students to memorize the details of historical events.
10
Conventional ways like literature are gradually out of fashion as time goes by.

8 ____ Modern people are better at memorizing historical information compared with their ancestors.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('350499a5-ee9d-5b5b-aa49-3e9da0d2a37a', 'd499d0ba-87ae-59e0-8f48-3de82cbc3eba', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ea0ed42-be31-5dbc-a350-52724215958d', 'd499d0ba-87ae-59e0-8f48-3de82cbc3eba', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16227a0c-4134-57df-a552-4bf0b9d5db44', 'd499d0ba-87ae-59e0-8f48-3de82cbc3eba', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cc7141dc-9e23-5736-a2e2-c343aca273da', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-10
Questions 8-10
Do the following statements agree with the information given in Reading Passage? In boxes 8-10 on your answer sheet, write
YES
if the statement agrees with the writer
NO
if the statement does not agree with the writer
NOT GIVEN
if there is no information about this in the passage
8
Modern people are better at memorizing historical information compared with their ancestors.
9
New technologies applied in history teaching are more vivid for students to memorize the details of historical events.
10
Conventional ways like literature are gradually out of fashion as time goes by.

9 ____ New technologies applied in history teaching are more vivid for students to memorize the details of historical events.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6acc7550-a422-5cd5-9702-52c35ecea98f', 'cc7141dc-9e23-5736-a2e2-c343aca273da', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2da16bd6-17b8-53d3-8b94-c1fff86878c8', 'cc7141dc-9e23-5736-a2e2-c343aca273da', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7d7e7f0-b6a8-5325-9025-d26307f3a9b8', 'cc7141dc-9e23-5736-a2e2-c343aca273da', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('de9ab8b5-042e-5422-98ef-bc2ffe0b1044', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-10
Questions 8-10
Do the following statements agree with the information given in Reading Passage? In boxes 8-10 on your answer sheet, write
YES
if the statement agrees with the writer
NO
if the statement does not agree with the writer
NOT GIVEN
if there is no information about this in the passage
8
Modern people are better at memorizing historical information compared with their ancestors.
9
New technologies applied in history teaching are more vivid for students to memorize the details of historical events.
10
Conventional ways like literature are gradually out of fashion as time goes by.

10 ____ Conventional ways like literature are gradually out of fashion as time goes by.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c96f0f1e-bddc-5bdd-bc42-9e91752ae305', 'de9ab8b5-042e-5422-98ef-bc2ffe0b1044', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da941c27-ffab-5ef0-95a4-3189cff50a57', 'de9ab8b5-042e-5422-98ef-bc2ffe0b1044', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bae03e9-3f08-5fa3-a240-26dc5e4a897f', 'de9ab8b5-042e-5422-98ef-bc2ffe0b1044', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bddc7993-85fd-5918-855f-218fc8e3b400', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using no more than three words from the Reading Passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
Contemporary students can be aimed at without many difficulties by integrating studying history with novels
11
. Conventional classroom discussion is specially extended by two ways to assist the teachers to interpret
12
and at the same time retain students’ distinct learning modes. PowerPoint study units prepared beforehand comprising a wide variety of elements make
13
learning feasible. Combined classes like this can also be helpful in taking required tests.

Contemporary students can be aimed at without many difficulties by integrating studying history with novels 11 ____ . Conventional classroom discussion is specially extended by two ways to assist the teachers to interpret 12 ____ and at the same time retain students’ distinct learning modes. PowerPoint study units prepared beforehand comprising a wide variety of elements make 13 ____ learning feasible. Combined classes like this can also be helpful in taking required tests.$md$, NULL, ARRAY['.*multimedia.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('68838e0f-5c09-5812-ac13-33283506f261', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using no more than three words from the Reading Passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
Contemporary students can be aimed at without many difficulties by integrating studying history with novels
11
. Conventional classroom discussion is specially extended by two ways to assist the teachers to interpret
12
and at the same time retain students’ distinct learning modes. PowerPoint study units prepared beforehand comprising a wide variety of elements make
13
learning feasible. Combined classes like this can also be helpful in taking required tests.

Contemporary students can be aimed at without many difficulties by integrating studying history with novels 11 ____ . Conventional classroom discussion is specially extended by two ways to assist the teachers to interpret 12 ____ and at the same time retain students’ distinct learning modes. PowerPoint study units prepared beforehand comprising a wide variety of elements make 13 ____ learning feasible. Combined classes like this can also be helpful in taking required tests.$md$, NULL, ARRAY['.*multimedia.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('23ffcff9-0434-5ff4-9df7-503411d36785', 'f4dadd85-ff09-5426-825a-c810880a1ea7', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using no more than three words from the Reading Passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
Contemporary students can be aimed at without many difficulties by integrating studying history with novels
11
. Conventional classroom discussion is specially extended by two ways to assist the teachers to interpret
12
and at the same time retain students’ distinct learning modes. PowerPoint study units prepared beforehand comprising a wide variety of elements make
13
learning feasible. Combined classes like this can also be helpful in taking required tests.

Contemporary students can be aimed at without many difficulties by integrating studying history with novels 11 ____ . Conventional classroom discussion is specially extended by two ways to assist the teachers to interpret 12 ____ and at the same time retain students’ distinct learning modes. PowerPoint study units prepared beforehand comprising a wide variety of elements make 13 ____ learning feasible. Combined classes like this can also be helpful in taking required tests.$md$, NULL, ARRAY['.*multimedia.*']);

COMMIT;
