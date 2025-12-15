BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-multitasks-1439'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-multitasks-1439';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-multitasks-1439';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-multitasks-1439';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('f86f0115-6eee-5c08-bcf9-ab7c76c179e3', 'ielts-reading-multitasks-1439', $t$Multitasks$t$, $md$## Multitasks

Nguồn:
- Test: https://mini-ielts.com/1439/reading/multitasks
- Solution: https://mini-ielts.com/1439/view-solution/reading/multitasks$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('34a8252d-726d-5019-ac20-ca2986d60493', 'f86f0115-6eee-5c08-bcf9-ab7c76c179e3', 1, $t$Reading — Multitasks$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Multitasks

A

Do you read while listening to music? Do you like to watch TV while finishing your homework? People who have these kinds of habits are called multi-taskers.

Multitasks are able to complete two tasks at the same time by dividing their focus. However, Thomas Lehman, a researcher in Psychology, believes people never really do multiple things simultaneously. Maybe a person is reading while listening to music, but in reality, the brain can only focus on one task. Reading thewords in a book will cause you to ignore some of the words of the music. When people think they are accomplishing two different tasks efficiently, what they are really doing is dividing their focus. While listening to music, people become less able to focus on their surroundings. For example, we all have experience of times when we talk with friends and they are not responding properly. Maybe they are listening to someone else talk, or maybe they are reading a text on their smart phone and don't hear what you are saying. Lehman called this phenomenon “email voice"

B

the world has been changed by computers and its spin offs like smart-phones or cellphones. Now that most individuals have a personal device, like a smart-phoneor a laptop, they are frequently reading, watching or listening to virtual information. This raises the occurrence of multitasking in our day to day life. Nowwhen you work, you work with your typewriter, your cellphone, and some colleagues who may drop by at any time to speak with you. In professional meetings, when one normally focuses and listens to one another, people are more likely to have a cell phone in their lap, reading or communicating silently with more people than ever, liven inventions such as the cordless phone has increased multitasking. In the old days, a traditional wall phone would ring, and then the housewife would have to stop her activities to answer it. When it rang, the housewife will sit down with her legs up. and chat, with no laundry or sweeping or answering the door. In the modern era, our technology is convenient enough to not interrupt our daily tasks.

C

Earl Miller, an expert at the Massachusetts Institute of Technology, studied the prefrontal cortex, which controls the brain while a person is multitasking. According to his studies, the size of this cortex varies between species, He found that for humans, the size of this part constitutes one third of the brain, while it is only 4 to 5 percent in dogs, and about 15% in monkeys. Given that this cortex is larger on a human, it allows a human to be more flexible and accurate in his or her multitasking.. However, Miller wanted to look further into whether the cortexwas truly processing information about two different tasks simultaneously. He designed an experiment where he presents visual stimulants to his subjects in a wax that mimics multi-tasking. Miller then attached sensors tothe patients " heads to pick up the electric patterns of the brain. This sensor would show if" the brain particles, called neurons, were truly processing two different tasks. What he found is that the brain neurons only lit up in singular areas one at a time, and never simultaneously.

D

Davis Meyer, a professor of University of Michigan, studied the young adults in a similar experiment. He instructed them to simultaneously do math problems and classify simple words into different categories. For this experiment. Meyer found that when you think you are doing several jobs at the same time, you are actuallyswitching between jobs. Even though the people tried to do the tasks at the sametime, and both tasks were eventually accomplished, overall, the task look more time than if the person focused on a single task one at a time.

E

People sacrifice efficiency when multitasking, Gloria Mark set office workers as his subjects. He found that they were constantly multitasking. He observed that nearly every 11 minutes people at work were disrupted. He found that doing different jobs at the same time may actually save time. However, despite the fact that they are faster, it does not mean they are more efficient. And we are equally likely to self-interrupt as be interrupted by outside sources. He found that in office nearly every 12 minutes an employee would stop and with no reason at all,cheek a website on their computer, call someone or write an email. If they concentrated for more than 20 minutes, they would feel distressed. He suggestedthat the average person may suffer from a short concentration span. This short attention span might be natural, but others suggest that new technology may be the problem. With cellphones and computers at our sides at all times, people will never run out of distractions. The format of media, such as advertisements, music, news articles and TV shows are also shortening, so people are used to paying attention to information for a very short time

F

So even though focusing on one single task is the most efficient way for our brainsto work, it is not practical to use this method in real life. According to human nature, people feel more comfortable and efficient in environments with a varietyof tasks, Edward Hallowell said that people are losing a lot of efficiency in the workplace due to multitasking, outside distractions and self-distractions. As it matter of fact, the changes made to the workplace do not have to be dramatic.

No one is suggesting we ban e-mail or make employees focus on only one task. However, certain common workplace tasks, such as group meetings, would be more efficient if we banned cell-phones, a common distraction. A person can alsoapply these tips to prevent self-distraction. Instead of arriving to your office and checking all of your e-mails for new tasks, a common workplace ritual, a person could dedicate an hour to a single task first thing in the morning. Self-timing is a great way to reduce distraction and efficiently finish tasks one by one, instead of slowing ourselves down with multi-tasking.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('77474cbd-09f3-5771-9be7-8b3c18ecd4e8', '34a8252d-726d-5019-ac20-ca2986d60493', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage 2 has six paragraphs, A-F.
Which paragraph contains the following information?
Write the correct letter, A-F, in boxes 1-5 on your answer sheet
1
a reference to a domestic situation that does not require multitasking
2
a possible explanation of why we always do multitask together
3
a practical solution to multitask in work environment
4
relating multitasking to the size of prefrontal cortex
5
longer time spent doing two tasks at the same time than one at a time

1 ____ a reference to a domestic situation that does not require multitasking$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb4ce923-91fd-5bd2-bba9-c5ded143981c', '77474cbd-09f3-5771-9be7-8b3c18ecd4e8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4bf06a65-0427-52d7-8fe0-38cb0929aa63', '77474cbd-09f3-5771-9be7-8b3c18ecd4e8', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('889c4d96-d093-591e-9bc6-73bdd1ac47fe', '77474cbd-09f3-5771-9be7-8b3c18ecd4e8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7346be63-7326-528b-b8cb-5b8dbb442003', '77474cbd-09f3-5771-9be7-8b3c18ecd4e8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('205e8c23-6bd6-5a24-a87a-a37cae2be56e', '77474cbd-09f3-5771-9be7-8b3c18ecd4e8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5da024d3-28df-5209-ba6f-84416e067a03', '77474cbd-09f3-5771-9be7-8b3c18ecd4e8', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e859ea97-bc59-5433-af00-e16a899df96e', '34a8252d-726d-5019-ac20-ca2986d60493', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage 2 has six paragraphs, A-F.
Which paragraph contains the following information?
Write the correct letter, A-F, in boxes 1-5 on your answer sheet
1
a reference to a domestic situation that does not require multitasking
2
a possible explanation of why we always do multitask together
3
a practical solution to multitask in work environment
4
relating multitasking to the size of prefrontal cortex
5
longer time spent doing two tasks at the same time than one at a time

2 ____ a possible explanation of why we always do multitask together$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a4dbf9f-d70e-5327-8692-d810d898dd49', 'e859ea97-bc59-5433-af00-e16a899df96e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7daae275-e0a8-576e-b70e-fa35d34ab8c3', 'e859ea97-bc59-5433-af00-e16a899df96e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b92a0338-766b-52c5-9dab-7f5a70246a2c', 'e859ea97-bc59-5433-af00-e16a899df96e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7ecf364-ae7b-561c-8db2-0757e56583d4', 'e859ea97-bc59-5433-af00-e16a899df96e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79335528-04c7-5bf4-be9c-1d4c6ec9c10e', 'e859ea97-bc59-5433-af00-e16a899df96e', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f8674dd-53d8-5010-8ebd-f9016c4fc7e6', 'e859ea97-bc59-5433-af00-e16a899df96e', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9f630760-007a-5fdb-b7b6-c1876b4e7eea', '34a8252d-726d-5019-ac20-ca2986d60493', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage 2 has six paragraphs, A-F.
Which paragraph contains the following information?
Write the correct letter, A-F, in boxes 1-5 on your answer sheet
1
a reference to a domestic situation that does not require multitasking
2
a possible explanation of why we always do multitask together
3
a practical solution to multitask in work environment
4
relating multitasking to the size of prefrontal cortex
5
longer time spent doing two tasks at the same time than one at a time

3 ____ a practical solution to multitask in work environment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85518821-ee69-5794-ac0c-5da970da6821', '9f630760-007a-5fdb-b7b6-c1876b4e7eea', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e98ca50a-c25f-5692-bc44-1860cd62a0b6', '9f630760-007a-5fdb-b7b6-c1876b4e7eea', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfc09a80-d58e-5708-a9a9-c91b84c53f94', '9f630760-007a-5fdb-b7b6-c1876b4e7eea', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ebfc6ac-ef45-5f77-b13f-76356d506cf1', '9f630760-007a-5fdb-b7b6-c1876b4e7eea', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14e02098-8c8a-5ff8-a3a9-4b9b701b126b', '9f630760-007a-5fdb-b7b6-c1876b4e7eea', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03d7b42a-b18e-5607-a694-1e993fe9bb52', '9f630760-007a-5fdb-b7b6-c1876b4e7eea', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d50b5a5-82c5-5d99-ab3f-7381859d733d', '34a8252d-726d-5019-ac20-ca2986d60493', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage 2 has six paragraphs, A-F.
Which paragraph contains the following information?
Write the correct letter, A-F, in boxes 1-5 on your answer sheet
1
a reference to a domestic situation that does not require multitasking
2
a possible explanation of why we always do multitask together
3
a practical solution to multitask in work environment
4
relating multitasking to the size of prefrontal cortex
5
longer time spent doing two tasks at the same time than one at a time

4 ____ relating multitasking to the size of prefrontal cortex$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d67e485f-3ffc-5617-ab59-f4f52939b052', '5d50b5a5-82c5-5d99-ab3f-7381859d733d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbc95251-e51e-5617-a628-090ee43f9f98', '5d50b5a5-82c5-5d99-ab3f-7381859d733d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d53101e2-f627-5e6e-9946-466f538c93c3', '5d50b5a5-82c5-5d99-ab3f-7381859d733d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77dad348-c605-56c3-ae92-b0e9674bf59a', '5d50b5a5-82c5-5d99-ab3f-7381859d733d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86dbfc95-827f-5868-962d-868d974fd95a', '5d50b5a5-82c5-5d99-ab3f-7381859d733d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('739049a0-b36d-50a9-ba7e-8f242d041566', '5d50b5a5-82c5-5d99-ab3f-7381859d733d', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b60551b9-d7b9-513c-8d71-6678fd8c5f43', '34a8252d-726d-5019-ac20-ca2986d60493', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage 2 has six paragraphs, A-F.
Which paragraph contains the following information?
Write the correct letter, A-F, in boxes 1-5 on your answer sheet
1
a reference to a domestic situation that does not require multitasking
2
a possible explanation of why we always do multitask together
3
a practical solution to multitask in work environment
4
relating multitasking to the size of prefrontal cortex
5
longer time spent doing two tasks at the same time than one at a time

5 ____ longer time spent doing two tasks at the same time than one at a time$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9632fcd0-49e9-53df-aafd-a85c682c5765', 'b60551b9-d7b9-513c-8d71-6678fd8c5f43', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d37e9d11-0a41-5823-8b66-0a2286bb360e', 'b60551b9-d7b9-513c-8d71-6678fd8c5f43', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0073970-386c-509d-80d3-b78ee27cf32c', 'b60551b9-d7b9-513c-8d71-6678fd8c5f43', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d42f68b0-8b50-58ff-8c36-6c35a75a9ebe', 'b60551b9-d7b9-513c-8d71-6678fd8c5f43', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('daecb8c5-2d62-5f12-8272-56ffdc527e0a', 'b60551b9-d7b9-513c-8d71-6678fd8c5f43', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23600036-0e46-5ab3-96fe-dd435b6d36bb', 'b60551b9-d7b9-513c-8d71-6678fd8c5f43', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7fe9c19d-ab7a-5af1-a4b8-b15a7bcccf10', '34a8252d-726d-5019-ac20-ca2986d60493', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Look at the following statements (Questions 6-10) and the list of scientists below.
Match each statement with the correct scientist, A-E.
Write the correct letter, A-E, in boxes 6-10 on your answer sheet. NB
You may use any letter more than once.
List of Scientists
A Thomas Lehman
B Earl Miller
c David Meyer
D Gloria Mark
E Edward Hallowell
6
When faced multiple visual stimulants, one can only concentrate on one of them.
7
Doing two things together may be faster but not better.
8
People never really do two things together even if you think you do.
9
The causes of multitask lie in the environment.
10
Even minor changes in the workplace will improve work efficiency

6 ____ When faced multiple visual stimulants, one can only concentrate on one of them. 7 ____ Doing two things together may be faster but not better. 8 ____ People never really do two things together even if you think you do. 9 ____ The causes of multitask lie in the environment. 10 ____ Even minor changes in the workplace will improve work efficiency$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e832f6f9-f7a2-5dce-9757-688bc12a55bf', '7fe9c19d-ab7a-5af1-a4b8-b15a7bcccf10', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39f5bbe5-2923-55db-8ff3-978b7ffcb521', '7fe9c19d-ab7a-5af1-a4b8-b15a7bcccf10', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a68d92f-43ac-5f3b-b218-d7d57714e3ea', '7fe9c19d-ab7a-5af1-a4b8-b15a7bcccf10', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d7fc161-ac54-50a3-897f-4ba89c3df614', '7fe9c19d-ab7a-5af1-a4b8-b15a7bcccf10', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9b45fd8-02f2-559b-9a35-977aed39872e', '7fe9c19d-ab7a-5af1-a4b8-b15a7bcccf10', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e7ce59ce-0a35-5bda-b62c-22a04e1f667d', '34a8252d-726d-5019-ac20-ca2986d60493', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Look at the following statements (Questions 6-10) and the list of scientists below.
Match each statement with the correct scientist, A-E.
Write the correct letter, A-E, in boxes 6-10 on your answer sheet. NB
You may use any letter more than once.
List of Scientists
A Thomas Lehman
B Earl Miller
c David Meyer
D Gloria Mark
E Edward Hallowell
6
When faced multiple visual stimulants, one can only concentrate on one of them.
7
Doing two things together may be faster but not better.
8
People never really do two things together even if you think you do.
9
The causes of multitask lie in the environment.
10
Even minor changes in the workplace will improve work efficiency

6 ____ When faced multiple visual stimulants, one can only concentrate on one of them. 7 ____ Doing two things together may be faster but not better. 8 ____ People never really do two things together even if you think you do. 9 ____ The causes of multitask lie in the environment. 10 ____ Even minor changes in the workplace will improve work efficiency$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d685d46e-d0a5-5f86-8eca-93cba1cdc424', 'e7ce59ce-0a35-5bda-b62c-22a04e1f667d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14dff566-b319-5ec5-bb9c-19153aef0413', 'e7ce59ce-0a35-5bda-b62c-22a04e1f667d', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd2e1f95-324c-5f11-a3ae-b79735039d08', 'e7ce59ce-0a35-5bda-b62c-22a04e1f667d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fb890ee-13f8-55be-a7cc-1b727fdaafd9', 'e7ce59ce-0a35-5bda-b62c-22a04e1f667d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc8ecec4-4f38-57df-ae10-087f7df9d02e', 'e7ce59ce-0a35-5bda-b62c-22a04e1f667d', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df8ac804-e69d-57e1-b16a-9463a70deef8', '34a8252d-726d-5019-ac20-ca2986d60493', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Look at the following statements (Questions 6-10) and the list of scientists below.
Match each statement with the correct scientist, A-E.
Write the correct letter, A-E, in boxes 6-10 on your answer sheet. NB
You may use any letter more than once.
List of Scientists
A Thomas Lehman
B Earl Miller
c David Meyer
D Gloria Mark
E Edward Hallowell
6
When faced multiple visual stimulants, one can only concentrate on one of them.
7
Doing two things together may be faster but not better.
8
People never really do two things together even if you think you do.
9
The causes of multitask lie in the environment.
10
Even minor changes in the workplace will improve work efficiency

6 ____ When faced multiple visual stimulants, one can only concentrate on one of them. 7 ____ Doing two things together may be faster but not better. 8 ____ People never really do two things together even if you think you do. 9 ____ The causes of multitask lie in the environment. 10 ____ Even minor changes in the workplace will improve work efficiency$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d07169b7-a5f2-5769-82a0-deec510ab580', 'df8ac804-e69d-57e1-b16a-9463a70deef8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e72ff37-fd33-5a4d-89e2-f5f88e81a600', 'df8ac804-e69d-57e1-b16a-9463a70deef8', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a693d40c-bbec-54b6-9816-067545d7f53f', 'df8ac804-e69d-57e1-b16a-9463a70deef8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8242190a-5054-5bf7-b142-3562da0af55a', 'df8ac804-e69d-57e1-b16a-9463a70deef8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fbff489-652e-5065-9376-4af7d7afaedc', 'df8ac804-e69d-57e1-b16a-9463a70deef8', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('55f1b91c-bb69-5a23-8b6a-6126f1917067', '34a8252d-726d-5019-ac20-ca2986d60493', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Look at the following statements (Questions 6-10) and the list of scientists below.
Match each statement with the correct scientist, A-E.
Write the correct letter, A-E, in boxes 6-10 on your answer sheet. NB
You may use any letter more than once.
List of Scientists
A Thomas Lehman
B Earl Miller
c David Meyer
D Gloria Mark
E Edward Hallowell
6
When faced multiple visual stimulants, one can only concentrate on one of them.
7
Doing two things together may be faster but not better.
8
People never really do two things together even if you think you do.
9
The causes of multitask lie in the environment.
10
Even minor changes in the workplace will improve work efficiency

6 ____ When faced multiple visual stimulants, one can only concentrate on one of them. 7 ____ Doing two things together may be faster but not better. 8 ____ People never really do two things together even if you think you do. 9 ____ The causes of multitask lie in the environment. 10 ____ Even minor changes in the workplace will improve work efficiency$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34d0099f-dd5a-5ca5-9f1f-afa18351e0be', '55f1b91c-bb69-5a23-8b6a-6126f1917067', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e6158bc-6524-5b8a-b8d2-9df585c8a20f', '55f1b91c-bb69-5a23-8b6a-6126f1917067', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b212302-cf80-592b-bba4-8454aa4d1406', '55f1b91c-bb69-5a23-8b6a-6126f1917067', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80ce4e75-e712-5b6f-89d4-c673c9e2fa22', '55f1b91c-bb69-5a23-8b6a-6126f1917067', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52ff26d3-80f3-5921-bc9b-c5ec1264257a', '55f1b91c-bb69-5a23-8b6a-6126f1917067', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bb009644-3720-5cb5-a990-a9e4af69ac2d', '34a8252d-726d-5019-ac20-ca2986d60493', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Look at the following statements (Questions 6-10) and the list of scientists below.
Match each statement with the correct scientist, A-E.
Write the correct letter, A-E, in boxes 6-10 on your answer sheet. NB
You may use any letter more than once.
List of Scientists
A Thomas Lehman
B Earl Miller
c David Meyer
D Gloria Mark
E Edward Hallowell
6
When faced multiple visual stimulants, one can only concentrate on one of them.
7
Doing two things together may be faster but not better.
8
People never really do two things together even if you think you do.
9
The causes of multitask lie in the environment.
10
Even minor changes in the workplace will improve work efficiency

6 ____ When faced multiple visual stimulants, one can only concentrate on one of them. 7 ____ Doing two things together may be faster but not better. 8 ____ People never really do two things together even if you think you do. 9 ____ The causes of multitask lie in the environment. 10 ____ Even minor changes in the workplace will improve work efficiency$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de050616-0bba-54a9-ab6b-deae80db5915', 'bb009644-3720-5cb5-a990-a9e4af69ac2d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8335423-6bc7-5e8e-b4db-5514ad9b4e75', 'bb009644-3720-5cb5-a990-a9e4af69ac2d', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4abe43ef-ae73-5f0f-a6a5-3917bd6b2f90', 'bb009644-3720-5cb5-a990-a9e4af69ac2d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ce2d3bd-bcec-5536-a97a-58ce676a0c1e', 'bb009644-3720-5cb5-a990-a9e4af69ac2d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5aa5264-938a-572d-904b-408a9a87d780', 'bb009644-3720-5cb5-a990-a9e4af69ac2d', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f0903452-cf72-5701-9d8b-1fd5f1f453e9', '34a8252d-726d-5019-ac20-ca2986d60493', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
A term used to refer to a situation when you are reading a text and cannot focuson your surroundings is
11
.
The
12
part of the brain controls multitasking.
The practical solution of multitask in work is not to allow use of cellphone in
13
.

A term used to refer to a situation when you are reading a text and cannot focuson your surroundings is 11 ____ .$md$, NULL, ARRAY['.*email.*voice.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b9ba61dd-912d-55d4-b958-9ceeb317a352', '34a8252d-726d-5019-ac20-ca2986d60493', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
A term used to refer to a situation when you are reading a text and cannot focuson your surroundings is
11
.
The
12
part of the brain controls multitasking.
The practical solution of multitask in work is not to allow use of cellphone in
13
.

The 12 ____ part of the brain controls multitasking.$md$, NULL, ARRAY['.*prefrontal.*cortex.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f5c463a7-a118-5b65-8f91-d829ca6f6d74', '34a8252d-726d-5019-ac20-ca2986d60493', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 11-13 on your answer sheet.
A term used to refer to a situation when you are reading a text and cannot focuson your surroundings is
11
.
The
12
part of the brain controls multitasking.
The practical solution of multitask in work is not to allow use of cellphone in
13
.

The practical solution of multitask in work is not to allow use of cellphone in 13 ____ .$md$, NULL, ARRAY['.*group.*meetings.*']);

COMMIT;
